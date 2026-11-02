/**
 * Share-code callables (plan §3.2, §3.4). A code is an acknowledgement bound to one recipient,
 * not a credential. The plain code lives only in the recipient's inbox row: it is never returned,
 * logged, pushed or put in an event. Every exit from `Pending` goes through `closeShare`.
 */
import { FieldValue, type Firestore, type Transaction } from 'firebase-admin/firestore';

import { participants, syncCaseReaders, unlockReport } from './access';
import {
  DAY_MS,
  MAX_VIEWERS,
  OK,
  languageIn,
  languageOf,
  loadCase,
  loadVersions,
  nowOf,
  num,
  planNotes,
  requireRoleIn,
  sendNotes,
  str,
  ttl,
  uuidOf,
  type Deps,
} from './case-support';
import {
  DOCTORS,
  PATIENTS,
  PRACTITIONERS,
  input,
  nairobiDayKey,
  nairobiHourKey,
  refuse,
  timestamp,
  type Caller,
} from './common';
import { NotificationTx, type NotifyLanguage } from './notifications';
import { CaseState, commitCase, transition } from './orchestrator';
import { buildQuery, queryById } from './queries';
import {
  closeShare,
  judgeRedemption,
  loadShareClose,
  mintShareCode,
  type ShareRecord,
} from './shares';

const JOIN_TTL_MS = DAY_MS;
const UNLOCK_TTL_MS = 7 * DAY_MS;
const PENDING_SHARE_CAP = 5;
const DAILY_SHARE_CAP = 20;
const HOURLY_REISSUE_CAP = 3;

function keyOf(deps: Deps): string {
  if (!deps.shareCodeKey) throw refuse('failed-precondition', 'shareKeyMissing');
  return deps.shareCodeKey;
}

async function languageOfUser(
  tx: Transaction,
  db: Firestore,
  uid: string,
  role: string,
): Promise<NotifyLanguage> {
  if (role === 'patient') {
    const found = await tx.get(buildQuery(db, queryById('patients.byUid'), [uid]).limit(1));
    return languageIn(found.docs[0]?.data());
  }
  return languageOf(tx, db, DOCTORS, uid);
}

/** Who may share the case (§3.2): the doctor, the patient once released, the accepted pathologist. */
function sharerOf(c: Caller, s: CaseState): void {
  if (c.role === 'doctor' && s.doctorUid === c.uid) return;
  if (c.role === 'pathologist' && s.pathologistUid === c.uid) return;
  if (c.role === 'patient' && s.patientUid === c.uid) {
    if (s.fields.releasedToPatient !== true) throw refuse('permission-denied', 'notReleased');
    return;
  }
  throw refuse('permission-denied', 'notOnCase');
}

export async function createShareCodeHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'created' | 'exists'; shareUid: string; expiresAt: string }> {
  const c = requireRoleIn(caller, ['doctor', 'pathologist', 'patient']);
  const raw = input(data);
  const now = nowOf(deps);
  const shareUid = uuidOf(raw.shareUid, 'invalidShare');
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const recipientUid = typeof raw.recipientUid === 'string' ? raw.recipientUid : '';
  if (recipientUid === '' || recipientUid.length > 128 || recipientUid.includes('/')) {
    throw refuse('invalid-argument', 'invalidRecipient');
  }
  const key = keyOf(deps);
  const { db } = deps;
  const expiresAt = timestamp(new Date(now.getTime() + JOIN_TTL_MS));

  return db.runTransaction(async (tx) => {
    const prior = await tx.get(db.collection('shareCodes').doc(shareUid));
    if (prior.exists) {
      if (prior.get('createdByUid') === c.uid && prior.get('caseUid') === caseUid) {
        return { status: 'exists' as const, shareUid, expiresAt: String(prior.get('expiresAt') ?? '') };
      }
      throw refuse('already-exists', 'shareExists');
    }
    const { s } = await loadCase(tx, db, caseUid);
    sharerOf(c, s);
    if (s.currentStage === 'Cancelled') throw refuse('failed-precondition', 'caseCancelled');
    if (recipientUid === c.uid) throw refuse('invalid-argument', 'invalidRecipient');
    // A patient is only ever in the participants as the case's own patient (F-25).
    const recipient = await tx.get(db.collection(PRACTITIONERS).doc(recipientUid));
    if (!recipient.exists) throw refuse('failed-precondition', 'invalidRecipient');
    if (participants(s).includes(recipientUid)) throw refuse('failed-precondition', 'alreadyParticipant');
    if (s.viewerUids.length >= MAX_VIEWERS) throw refuse('failed-precondition', 'viewerCap');

    const pendingRef = db.collection('rateCounters').doc(`pendingShares:${caseUid}`);
    const dailyRef = db.collection('rateCounters').doc(`shares:${c.uid}:${nairobiDayKey(now)}`);
    if (num((await tx.get(pendingRef)).get('count')) >= PENDING_SHARE_CAP) {
      throw refuse('resource-exhausted', 'tooManyShares');
    }
    if (num((await tx.get(dailyRef)).get('count')) >= DAILY_SHARE_CAP) {
      throw refuse('resource-exhausted', 'shareLimit');
    }
    const loaded = await NotificationTx.load(tx, db, 'caseShared', shareUid, recipientUid);
    const language = await languageOf(tx, db, DOCTORS, recipientUid);

    tx.set(
      dailyRef,
      { count: FieldValue.increment(1), expireAt: ttl(now), lastUpdatedAt: timestamp(now) },
      { merge: true },
    );
    mintShareCode(
      tx,
      db,
      {
        shareUid,
        caseUid,
        purpose: 'Join',
        createdByUid: c.uid,
        createdByRole: c.role,
        recipientUid,
        expiresAt,
        template: 'caseShared',
        language,
        recipientRole: recipient.get('isPathologist') === true ? 'pathologist' : 'doctor',
        deepLink: `/cases/${caseUid}`,
      },
      loaded,
      key,
      now,
      prior,
      deps.generateShareCode,
    );
    return { status: 'created' as const, shareUid, expiresAt };
  });
}

type Refusal = { refusal: string } | null;

/** Which version a `ReportUnlock` share was minted for: `unlock_{case}_{vN}` carries `reportUid: vN`. */
function unlockVersionOf(share: ShareRecord): number {
  const n = Number(share.reportUid.replace(/^v/, ''));
  return Number.isInteger(n) && n > 0 ? n : 0;
}

export async function redeemShareCodeHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRoleIn(caller, ['doctor', 'pathologist']);
  const raw = input(data);
  const now = nowOf(deps);
  const shareUid = typeof raw.shareUid === 'string' && raw.shareUid.length <= 128 && !raw.shareUid.includes('/')
    ? raw.shareUid
    : '';
  if (shareUid === '') throw refuse('invalid-argument', 'invalidShare');
  const code = typeof raw.code === 'string' ? raw.code : '';
  if (!/^\d{4}$/.test(code)) throw refuse('invalid-argument', 'invalidCode');
  const key = keyOf(deps);
  const { db } = deps;
  const at = timestamp(now);

  const outcome = await db.runTransaction(async (tx): Promise<Refusal> => {
    const loaded = await loadShareClose(tx, db, shareUid);
    const share = loaded.share;
    if (!share) throw refuse('not-found', 'invalidShare');
    if (share.recipientUid !== c.uid) throw refuse('permission-denied', 'notRecipient');
    if (share.status === 'Redeemed') return null;
    if (share.status === 'Locked') throw refuse('failed-precondition', 'shareLocked');
    if (share.status !== 'Pending') throw refuse('failed-precondition', 'shareClosed');

    const secret = await tx.get(loaded.secretRef);
    if (!secret.exists) throw refuse('failed-precondition', 'shareClosed');
    const { ref, s } = await loadCase(tx, db, share.caseUid);
    const versions = await loadVersions(tx, ref);
    const sharerLanguage = await languageOfUser(tx, db, share.createdByUid, share.createdByRole);
    const notes = await planNotes(tx, db, [
      share.purpose === 'Join'
        ? {
            template: 'shareRedeemed',
            resourceKey: shareUid,
            caseUid: s.uid,
            recipientUid: share.createdByUid,
            recipientRole: share.createdByRole === 'patient' || share.createdByRole === 'pathologist' ? share.createdByRole : 'doctor',
            language: sharerLanguage,
          }
        : null,
    ]);

    const judged = judgeRedemption(share, String(secret.get('codeHmac') ?? ''), key, code, now);
    switch (judged.outcome) {
      case 'Expired':
        closeShare(tx, db, loaded, 'Expired', now);
        return { refusal: 'shareExpired' };
      case 'Locked':
        closeShare(tx, db, loaded, 'Locked', now);
        return { refusal: 'shareLocked' };
      case 'Wrong':
        tx.update(loaded.shareRef, { attempts: judged.attempts, lastUpdatedAt: at });
        if (judged.lock) closeShare(tx, db, loaded, 'Locked', now);
        return { refusal: 'wrongCode' };
      case 'Right':
        break;
    }

    if (share.purpose === 'Join') {
      // Re-checked here: the code was minted when these held, and they may not any more.
      if (c.role !== 'doctor' && c.role !== 'pathologist') throw refuse('permission-denied', 'notClinician');
      if (s.currentStage === 'Cancelled') throw refuse('failed-precondition', 'caseCancelled');
      if (participants(s).includes(c.uid)) throw refuse('failed-precondition', 'alreadyParticipant');
      if (s.viewerUids.length >= MAX_VIEWERS) throw refuse('failed-precondition', 'viewerCap');
      closeShare(tx, db, loaded, 'Redeemed', now);
      const next = transition(s.with({ viewerUids: [...s.viewerUids, c.uid] }), s.currentStage, {
        actorUid: c.uid,
        actorRole: c.role === 'pathologist' ? 'Pathologist' : 'Doctor',
        action: 'Share',
      });
      commitCase(tx, ref, next, now);
      syncCaseReaders(tx, next, versions.map((v) => v.access), now);
      if (share.createdByRole === 'patient') {
        tx.update(db.collection(PATIENTS).doc(String(s.fields.patientId ?? '')), {
          doctorUids: FieldValue.arrayUnion(c.uid),
          lastUpdatedAt: at,
        });
      }
      sendNotes(tx, notes, now);
      return null;
    }

    if (c.role !== 'doctor' || s.doctorUid !== c.uid) throw refuse('permission-denied', 'notDoctor');
    closeShare(tx, db, loaded, 'Redeemed', now);
    const limit = unlockVersionOf(share);
    unlockReport(tx, s, versions.filter((v) => v.version <= limit).map((v) => v.access), c.uid, now);
    return null;
  });

  // The attempt, the lock or the close is committed above; only now is the caller told.
  if (outcome) throw refuse('failed-precondition', outcome.refusal);
  return OK;
}

export async function revokeShareCodeHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRoleIn(caller, ['doctor', 'pathologist', 'patient']);
  const now = nowOf(deps);
  const shareUid = typeof input(data).shareUid === 'string' ? (input(data).shareUid as string) : '';
  if (shareUid === '' || shareUid.length > 128 || shareUid.includes('/')) {
    throw refuse('invalid-argument', 'invalidShare');
  }
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const loaded = await loadShareClose(tx, db, shareUid);
    const share = loaded.share;
    if (!share) throw refuse('not-found', 'invalidShare');
    if (share.createdByUid !== c.uid || share.createdByRole !== c.role) {
      throw refuse('permission-denied', 'notCreator');
    }
    // The signer made an unlock code for the ordering doctor; withdrawing it would strand the report.
    // Only signing a newer version retires one (F-23).
    if (share.purpose === 'ReportUnlock') throw refuse('failed-precondition', 'reportUnlockNotRevocable');
    if (share.status === 'Revoked') return OK;
    if (share.status !== 'Pending') throw refuse('failed-precondition', 'notPending');
    closeShare(tx, db, loaded, 'Revoked', now);
    return OK;
  });
}

export async function reissueShareCodeHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ shareUid: string; expiresAt: string }> {
  const c = requireRoleIn(caller, ['doctor', 'pathologist']);
  const now = nowOf(deps);
  const shareUid = typeof input(data).shareUid === 'string' ? (input(data).shareUid as string) : '';
  if (shareUid === '' || shareUid.length > 128 || shareUid.includes('/')) {
    throw refuse('invalid-argument', 'invalidShare');
  }
  const key = keyOf(deps);
  const { db } = deps;
  const at = timestamp(now);
  const expiresAt = timestamp(new Date(now.getTime() + UNLOCK_TTL_MS));

  return db.runTransaction(async (tx) => {
    const loaded = await loadShareClose(tx, db, shareUid);
    const share = loaded.share;
    if (!share) throw refuse('not-found', 'invalidShare');
    if (share.purpose !== 'ReportUnlock') throw refuse('failed-precondition', 'shareNotReusable');
    // The recipient (a doctor) asks for a fresh code; the signer (a pathologist) asks on their behalf.
    const asRecipient = c.role === 'doctor' && share.recipientUid === c.uid;
    const asSigner = c.role === 'pathologist' && share.createdByUid === c.uid && share.createdByRole === 'pathologist';
    if (!asRecipient && !asSigner) throw refuse('permission-denied', 'notRecipient');
    const { s } = await loadCase(tx, db, share.caseUid);
    const report = (await tx.get(db.collection('cases').doc(share.caseUid).collection('reports').doc(share.reportUid))).data();
    // A revoke that reached an unlock code must never leave the current version unreachable, so
    // that one case is reissued; an older version's revoked code stays closed.
    const revokedCurrent = share.status === 'Revoked' && share.reportUid === str(s.fields.currentReportUid);
    if (!revokedCurrent && share.status !== 'Expired' && share.status !== 'Locked' && share.status !== 'Pending') {
      throw refuse('failed-precondition', 'shareNotReusable');
    }
    const prior = await tx.get(loaded.shareRef);
    const throttleRef = db.collection('rateCounters').doc(`reissues:${shareUid}:${nairobiHourKey(now)}`);
    if (num((await tx.get(throttleRef)).get('count')) >= HOURLY_REISSUE_CAP) {
      throw refuse('resource-exhausted', 'reissueThrottled');
    }
    const resourceKey = `${shareUid}-r${share.reissueCount + 1}`;
    const note = await NotificationTx.load(tx, db, 'shareCodeReissued', resourceKey, share.recipientUid);
    const language = await languageOf(tx, db, DOCTORS, share.recipientUid);

    tx.set(
      throttleRef,
      { count: FieldValue.increment(1), expireAt: ttl(now), lastUpdatedAt: at },
      { merge: true },
    );
    // Only a Pending share still has a live row and secret to close; the others closed already.
    if (share.status === 'Pending') {
      closeShare(tx, db, loaded, share.expiresAt <= at ? 'Expired' : 'Revoked', now);
    }
    mintShareCode(
      tx,
      db,
      {
        shareUid,
        caseUid: share.caseUid,
        reportUid: share.reportUid,
        purpose: 'ReportUnlock',
        createdByUid: share.createdByUid,
        createdByRole: share.createdByRole,
        recipientUid: share.recipientUid,
        expiresAt,
        template: 'shareCodeReissued',
        resourceKey,
        language,
        deepLink: `/cases/${share.caseUid}/reports/${share.reportUid}`,
        mode: 'reissue',
        critical: report?.isCritical === true,
      },
      note,
      key,
      now,
      prior,
      deps.generateShareCode,
    );
    return { shareUid, expiresAt };
  });
}
