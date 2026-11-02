import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

import { cancelOrderHandler, removeCaseViewerHandler } from './cases';
import {
  acceptedCase,
  caseDoc,
  codeInRow,
  docData,
  fillDraft,
  later,
  noteId,
  requestedCase,
  seedWorld,
  signaturePng,
  signedCase,
  unlockCodeOf,
  unlockUidOf,
  wrongCode,
  type World,
} from './case.test-support';
import { DAY_MS } from './case-support';
import { DOCTORS, PRACTITIONERS } from './common';
import { account, emulatorDeps, refusedWith, resetEmulators } from './emulator.test-support';
import { markDiscussedHandler, signReportHandler, startReportHandler } from './reports';
import {
  createShareCodeHandler,
  redeemShareCodeHandler,
  reissueShareCodeHandler,
  revokeShareCodeHandler,
} from './shares-callables';

describe('share-code callables', () => {
  let w: World;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
  });

  async function shareTo(caseUid: string, recipientUid = w.colleague.uid): Promise<{ shareUid: string; code: string }> {
    const shareUid = randomUUID();
    await createShareCodeHandler(w.deps, w.doctor, { shareUid, caseUid, recipientUid });
    return { shareUid, code: await codeInRow(w, noteId('caseShared', shareUid, recipientUid)) };
  }

  describe('createShareCode', () => {
    it('mints a pending share whose code reaches only the recipient’s row', async () => {
      const caseUid = await acceptedCase(w);
      const shareUid = randomUUID();
      const result = await createShareCodeHandler(w.deps, w.doctor, { shareUid, caseUid, recipientUid: w.colleague.uid });
      assert.deepEqual(Object.keys(result).sort(), ['expiresAt', 'shareUid', 'status']);
      assert.equal(result.status, 'created');
      assert.equal(result.expiresAt, '2026-10-28T09:00:00.000Z');

      const share = await docData(w, `shareCodes/${shareUid}`);
      assert.equal(share?.status, 'Pending');
      assert.equal(share?.purpose, 'Join');
      assert.equal(share?.recipientUid, w.colleague.uid);
      assert.ok(!('code' in (share ?? {})));
      assert.ok(await docData(w, `shareSecrets/${shareUid}`));
      assert.match(await codeInRow(w, noteId('caseShared', shareUid, w.colleague.uid)), /^\d{4}$/);
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 1);
      assert.equal(await docData(w, noteId('caseShared', shareUid, w.doctor.uid)), undefined);
    });

    it('is idempotent for the creator and refuses another account’s share id', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      const again = await createShareCodeHandler(w.deps, w.doctor, { shareUid, caseUid, recipientUid: w.colleague.uid });
      assert.equal(again.status, 'exists');
      assert.equal(await codeInRow(w, noteId('caseShared', shareUid, w.colleague.uid)), code);
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 1);
      await refusedWith(
        createShareCodeHandler(w.deps, w.pathologist, { shareUid, caseUid, recipientUid: w.colleague.uid }),
        'shareExists',
      );
    });

    it('refuses with a stable reason', async () => {
      const caseUid = await acceptedCase(w);
      const create = (who: World['doctor'], overrides: Record<string, unknown>) =>
        createShareCodeHandler(w.deps, who, {
          shareUid: randomUUID(),
          caseUid,
          recipientUid: w.colleague.uid,
          ...overrides,
        });
      await refusedWith(create(w.doctor, { shareUid: 'nope' }), 'invalidShare');
      await refusedWith(create(w.doctor, { caseUid: 'nope' }), 'invalidCase');
      await refusedWith(create(w.doctor, { recipientUid: '' }), 'invalidRecipient');
      await refusedWith(create(w.doctor, { recipientUid: w.doctor.uid }), 'invalidRecipient');
      await refusedWith(create(w.doctor, { recipientUid: w.patient.uid }), 'invalidRecipient');
      await refusedWith(create(w.doctor, { recipientUid: w.pathologist.uid }), 'alreadyParticipant');
      await refusedWith(create(w.colleague, {}), 'notOnCase');
      await refusedWith(create(w.patient, {}), 'notReleased');
      await refusedWith(createShareCodeHandler({ ...w.deps, shareCodeKey: undefined }, w.doctor, {
        shareUid: randomUUID(),
        caseUid,
        recipientUid: w.colleague.uid,
      }), 'shareKeyMissing');
    });

    it('caps pending shares per case and shares per day', async () => {
      const caseUid = await acceptedCase(w);
      await w.deps.db.collection('rateCounters').doc(`pendingShares:${caseUid}`).set({ count: 5 });
      await refusedWith(
        createShareCodeHandler(w.deps, w.doctor, { shareUid: randomUUID(), caseUid, recipientUid: w.colleague.uid }),
        'tooManyShares',
      );
      await w.deps.db.collection('rateCounters').doc(`pendingShares:${caseUid}`).set({ count: 0 });
      await w.deps.db.collection('rateCounters').doc(`shares:${w.doctor.uid}:20261027`).set({ count: 20 });
      await refusedWith(
        createShareCodeHandler(w.deps, w.doctor, { shareUid: randomUUID(), caseUid, recipientUid: w.colleague.uid }),
        'shareLimit',
      );
    });

    it('refuses a cancelled case', async () => {
      const caseUid = await acceptedCase(w);
      await cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode: 'Other' });
      await refusedWith(
        createShareCodeHandler(w.deps, w.doctor, { shareUid: randomUUID(), caseUid, recipientUid: w.colleague.uid }),
        'caseCancelled',
      );
    });
  });

  describe('redeemShareCode', () => {
    it('five wrong codes lock the share, and the right one no longer works', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      const wrong = wrongCode(code);
      for (let attempt = 1; attempt <= 4; attempt++) {
        await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code: wrong }), 'wrongCode');
        assert.equal((await docData(w, `shareCodes/${shareUid}`))?.attempts, attempt);
        assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Pending');
      }
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code: wrong }), 'wrongCode');
      const share = await docData(w, `shareCodes/${shareUid}`);
      assert.equal(share?.status, 'Locked');
      assert.equal(await docData(w, `shareSecrets/${shareUid}`), undefined);
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 0);

      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code }), 'shareLocked');
      assert.deepEqual((await caseDoc(w, caseUid)).viewerUids, []);
    });

    it('an expired share is closed as Expired and refused', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await refusedWith(redeemShareCodeHandler(later(w.deps, DAY_MS + 1), w.colleague, { shareUid, code }), 'shareExpired');
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Expired');
      assert.equal(await docData(w, `shareSecrets/${shareUid}`), undefined);
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 0);
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code }), 'shareClosed');
    });

    it('the right code joins the recipient as a viewer and tells the sharer', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      assert.deepEqual(await redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code }), { status: 'ok' });
      const doc = await caseDoc(w, caseUid);
      assert.deepEqual(doc.viewerUids, [w.colleague.uid]);
      assert.ok((doc.participantUids as string[]).includes(w.colleague.uid));
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Redeemed');
      assert.equal(await docData(w, `shareSecrets/${shareUid}`), undefined);
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 0);
      assert.ok(await docData(w, noteId('shareRedeemed', shareUid, w.doctor.uid)));
      const row = await docData(w, noteId('caseShared', shareUid, w.colleague.uid));
      assert.equal((row?.metadata as { shareCode: string }).shareCode, '');

      const seq = doc.stageSeq;
      assert.deepEqual(await redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code }), { status: 'ok' });
      assert.equal((await caseDoc(w, caseUid)).stageSeq, seq);
    });

    it('is the recipient’s alone and takes four digits', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await refusedWith(redeemShareCodeHandler(w.deps, w.otherPathologist, { shareUid, code }), 'notRecipient');
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code: '12' }), 'invalidCode');
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code: 'abcd' }), 'invalidCode');
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid: 'missing', code }), 'invalidShare');
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid: '', code }), 'invalidShare');
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.attempts, 0);
    });

    it('a recipient who became a participant meanwhile is refused', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await w.deps.db.collection('cases').doc(caseUid).update({ viewerUids: [w.colleague.uid] });
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code }), 'alreadyParticipant');
    });

    it('unlocks a report for the ordering doctor, and never for the patient', async () => {
      const signed = await signedCase(w);
      const code = await unlockCodeOf(w, signed);
      const shareUid = unlockUidOf(signed);
      await refusedWith(redeemShareCodeHandler(w.deps, w.pathologist, { shareUid, code }), 'notRecipient');
      await redeemShareCodeHandler(w.deps, w.doctor, { shareUid, code });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Redeemed');
      const report = await docData(w, `cases/${signed.caseUid}/reports/${signed.reportUid}`);
      const readers = report?.readerUids as string[];
      assert.ok(readers.includes(w.doctor.uid));
      assert.ok(readers.includes(w.pathologist.uid));
      assert.ok(!readers.includes(w.patient.uid));
    });
  });

  describe('revokeShareCode', () => {
    it('the creator closes a pending share; anyone else is refused', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await refusedWith(revokeShareCodeHandler(w.deps, w.colleague, { shareUid }), 'notCreator');
      await refusedWith(revokeShareCodeHandler(w.deps, w.pathologist, { shareUid }), 'notCreator');
      await revokeShareCodeHandler(w.deps, w.doctor, { shareUid });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Revoked');
      assert.equal(await docData(w, `shareSecrets/${shareUid}`), undefined);
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 0);
      assert.deepEqual(await revokeShareCodeHandler(w.deps, w.doctor, { shareUid }), { status: 'ok' });
      await refusedWith(redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code }), 'shareClosed');
      await refusedWith(revokeShareCodeHandler(w.deps, w.doctor, { shareUid: 'missing' }), 'invalidShare');
    });

    it('a redeemed share cannot be revoked', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code });
      await refusedWith(revokeShareCodeHandler(w.deps, w.doctor, { shareUid }), 'notPending');
    });
  });

  describe('reissueShareCode', () => {
    it('after expiry, mints a fresh code on the same share, and the new code redeems', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      const old = await unlockCodeOf(w, signed);
      const week = later(w.deps, 7 * DAY_MS + 1);
      await refusedWith(redeemShareCodeHandler(week, w.doctor, { shareUid, code: old }), 'shareExpired');
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Expired');

      const result = await reissueShareCodeHandler(week, w.doctor, { shareUid });
      assert.equal(result.shareUid, shareUid);
      assert.equal(result.expiresAt, '2026-11-10T09:00:00.001Z');
      const share = await docData(w, `shareCodes/${shareUid}`);
      assert.equal(share?.status, 'Pending');
      assert.equal(share?.reissueCount, 1);
      assert.equal(share?.attempts, 0);
      const fresh = await codeInRow(w, noteId('shareCodeReissued', `${shareUid}-r1`, w.doctor.uid));
      assert.match(fresh, /^\d{4}$/);

      await redeemShareCodeHandler(week, w.doctor, { shareUid, code: fresh });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Redeemed');
      const report = await docData(w, `cases/${signed.caseUid}/reports/${signed.reportUid}`);
      assert.ok((report?.readerUids as string[]).includes(w.doctor.uid));
    });

    it('after a lock, the signer or the recipient asks again, and the attempts start over', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      const wrong = wrongCode(await unlockCodeOf(w, signed));
      for (let i = 0; i < 5; i++) {
        await refusedWith(redeemShareCodeHandler(w.deps, w.doctor, { shareUid, code: wrong }), 'wrongCode');
      }
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Locked');
      await reissueShareCodeHandler(w.deps, w.pathologist, { shareUid });
      const share = await docData(w, `shareCodes/${shareUid}`);
      assert.equal(share?.status, 'Pending');
      assert.equal(share?.attempts, 0);
    });

    it('is throttled to three an hour, and refused to a stranger or a Join share', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      await refusedWith(reissueShareCodeHandler(w.deps, w.colleague, { shareUid }), 'notRecipient');
      await refusedWith(reissueShareCodeHandler(w.deps, w.patient, { shareUid }), 'roleNotAllowed');
      await refusedWith(reissueShareCodeHandler(w.deps, w.otherPathologist, { shareUid }), 'notRecipient');
      for (let i = 0; i < 3; i++) await reissueShareCodeHandler(w.deps, w.doctor, { shareUid });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.reissueCount, 3);
      await refusedWith(reissueShareCodeHandler(w.deps, w.doctor, { shareUid }), 'reissueThrottled');

      const caseUid = await acceptedCase(w);
      const join = await shareTo(caseUid);
      await refusedWith(reissueShareCodeHandler(w.deps, w.doctor, { shareUid: join.shareUid }), 'shareNotReusable');
    });

    it('a redeemed unlock cannot be reissued', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      await redeemShareCodeHandler(w.deps, w.doctor, { shareUid, code: await unlockCodeOf(w, signed) });
      await refusedWith(reissueShareCodeHandler(w.deps, w.doctor, { shareUid }), 'shareNotReusable');
    });
  });

  describe('removeCaseViewer', () => {
    it('the doctor removes a viewer, who leaves the participants; a repeat is ok', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code });
      await refusedWith(removeCaseViewerHandler(w.deps, w.colleague, { caseUid, viewerUid: w.colleague.uid }), 'notOnCase');
      await refusedWith(removeCaseViewerHandler(w.deps, w.pathologist, { caseUid, viewerUid: w.colleague.uid }), 'roleNotAllowed');
      await removeCaseViewerHandler(w.deps, w.doctor, { caseUid, viewerUid: w.colleague.uid });
      const doc = await caseDoc(w, caseUid);
      assert.deepEqual(doc.viewerUids, []);
      assert.ok(!(doc.participantUids as string[]).includes(w.colleague.uid));
      const seq = doc.stageSeq;
      assert.deepEqual(await removeCaseViewerHandler(w.deps, w.doctor, { caseUid, viewerUid: w.colleague.uid }), { status: 'ok' });
      assert.equal((await caseDoc(w, caseUid)).stageSeq, seq);
    });

    it('the patient may remove a viewer too', async () => {
      const caseUid = await acceptedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code });
      await removeCaseViewerHandler(w.deps, w.patient, { caseUid, viewerUid: w.colleague.uid });
      assert.deepEqual((await caseDoc(w, caseUid)).viewerUids, []);
    });
  });

  describe('the unlock code is never withdrawn from the ordering doctor (T-18)', () => {
    it('the signer cannot revoke it, and the doctor still redeems', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      await refusedWith(revokeShareCodeHandler(w.deps, w.pathologist, { shareUid }), 'reportUnlockNotRevocable');
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Pending');
      await redeemShareCodeHandler(w.deps, w.doctor, { shareUid, code: await unlockCodeOf(w, signed) });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Redeemed');
    });

    it('a revoked share of the current version is reissued, and the new code redeems', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      // As if a revoke had reached it: the secret is gone and the row is cancelled.
      await w.deps.db.collection('shareCodes').doc(shareUid).update({ status: 'Revoked' });
      await w.deps.db.collection('shareSecrets').doc(shareUid).delete();

      await reissueShareCodeHandler(w.deps, w.doctor, { shareUid });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Pending');
      const fresh = await codeInRow(w, noteId('shareCodeReissued', `${shareUid}-r1`, w.doctor.uid));
      await redeemShareCodeHandler(w.deps, w.doctor, { shareUid, code: fresh });
      const report = await docData(w, `cases/${signed.caseUid}/reports/${signed.reportUid}`);
      assert.ok((report?.readerUids as string[]).includes(w.doctor.uid));
    });

    it('a revoked share of a superseded version stays closed', async () => {
      const signed = await signedCase(w);
      await startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Addendum' });
      const stamp = await fillDraft(w, signed.caseUid, { addendumText: 'More.' }, '2026-10-27T09:06:00.000Z');
      await signReportHandler(w.deps, w.pathologist, {
        caseUid: signed.caseUid,
        draftLastUpdatedAt: stamp,
        signaturePng: signaturePng(),
      });
      assert.equal((await docData(w, `shareCodes/${unlockUidOf(signed)}`))?.status, 'Revoked');
      await refusedWith(reissueShareCodeHandler(w.deps, w.doctor, { shareUid: unlockUidOf(signed) }), 'shareNotReusable');
    });

    it('a fourth expiry still reissues', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      for (let round = 1; round <= 4; round++) {
        const weeks = later(w.deps, round * (7 * DAY_MS + 1));
        await refusedWith(redeemShareCodeHandler(weeks, w.doctor, { shareUid, code: '1234' }), 'shareExpired');
        await reissueShareCodeHandler(weeks, w.doctor, { shareUid });
        assert.equal((await docData(w, `shareCodes/${shareUid}`))?.reissueCount, round);
      }
      const last = later(w.deps, 4 * (7 * DAY_MS + 1));
      const fresh = await codeInRow(w, noteId('shareCodeReissued', `${shareUid}-r4`, w.doctor.uid));
      await redeemShareCodeHandler(last, w.doctor, { shareUid, code: fresh });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Redeemed');
    });

    it('is reissued by the signer and the recipient only, with the right role', async () => {
      const signed = await signedCase(w);
      const shareUid = unlockUidOf(signed);
      await refusedWith(reissueShareCodeHandler(w.deps, w.otherPathologist, { shareUid }), 'notRecipient');
      await refusedWith(reissueShareCodeHandler(w.deps, w.colleague, { shareUid }), 'notRecipient');
      await reissueShareCodeHandler(w.deps, w.pathologist, { shareUid });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.reissueCount, 1);
    });

    it('a critical report reaches the doctor at High priority, and so does its reissue', async () => {
      const signed = await signedCase(w, w.deps, { isCritical: true });
      const shareUid = unlockUidOf(signed);
      const row = await docData(w, noteId('reportSigned', `${signed.caseUid}_${signed.reportUid}`, w.doctor.uid));
      assert.equal(row?.priority, 'High');
      await reissueShareCodeHandler(w.deps, w.doctor, { shareUid });
      assert.equal((await docData(w, noteId('shareCodeReissued', `${shareUid}-r1`, w.doctor.uid)))?.priority, 'High');

      const ordinary = await signedCase(w);
      const plain = await docData(w, noteId('reportSigned', `${ordinary.caseUid}_${ordinary.reportUid}`, w.doctor.uid));
      assert.equal(plain?.priority, 'Normal');
    });

    it('unlock codes leave the pending-share counter alone (F-23)', async () => {
      const signed = await signedCase(w);
      await shareTo(signed.caseUid);
      const counter = `rateCounters/pendingShares:${signed.caseUid}`;
      assert.equal((await docData(w, counter))?.count, 1);
      const shareUid = unlockUidOf(signed);
      await redeemShareCodeHandler(w.deps, w.doctor, { shareUid, code: await unlockCodeOf(w, signed) });
      assert.equal((await docData(w, counter))?.count, 1);
      await w.deps.db.collection('shareCodes').doc(shareUid).update({ status: 'Pending', expiresAt: '2026-10-01T00:00:00.000Z' });
      await refusedWith(redeemShareCodeHandler(w.deps, w.doctor, { shareUid, code: '1234' }), 'shareClosed');
      assert.equal((await docData(w, counter))?.count, 1);
    });
  });

  describe('who is on the share', () => {
    it('refuses a requested pathologist who has not accepted', async () => {
      const caseUid = await requestedCase(w);
      await refusedWith(
        createShareCodeHandler(w.deps, w.pathologist, { shareUid: randomUUID(), caseUid, recipientUid: w.colleague.uid }),
        'notOnCase',
      );
    });

    it('keeps a pending request pending when a viewer joins (a log-only row)', async () => {
      const caseUid = await requestedCase(w);
      const { shareUid, code } = await shareTo(caseUid);
      await redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PathologistRequested');
      assert.equal(doc.requestedPathologistUid, w.pathologist.uid);
      assert.deepEqual(doc.viewerUids, [w.colleague.uid]);
      const log = await w.deps.db.collection('cases').doc(caseUid).collection('log').get();
      assert.ok(log.docs.some((d) => d.get('actionType') === 'Share'));
    });

    it('names a pathologist by role on the row they receive and on the sharer’s row', async () => {
      const caseUid = await acceptedCase(w);
      const sent = await shareTo(caseUid, w.otherPathologist.uid);
      assert.equal((await docData(w, noteId('caseShared', sent.shareUid, w.otherPathologist.uid)))?.recipientRole, 'pathologist');
      const toDoctor = await shareTo(caseUid, w.colleague.uid);
      assert.equal((await docData(w, noteId('caseShared', toDoctor.shareUid, w.colleague.uid)))?.recipientRole, 'doctor');

      const mine = randomUUID();
      await createShareCodeHandler(w.deps, w.pathologist, { shareUid: mine, caseUid, recipientUid: w.colleague.uid });
      const code = await codeInRow(w, noteId('caseShared', mine, w.colleague.uid));
      await redeemShareCodeHandler(w.deps, w.colleague, { shareUid: mine, code });
      assert.equal((await docData(w, noteId('shareRedeemed', mine, w.pathologist.uid)))?.recipientRole, 'pathologist');
    });

    it('a patient’s share, once redeemed, puts the recipient in the patient’s care', async () => {
      const signed = await signedCase(w);
      await redeemShareCodeHandler(w.deps, w.doctor, { shareUid: unlockUidOf(signed), code: await unlockCodeOf(w, signed) });
      await markDiscussedHandler(w.deps, w.doctor, { caseUid: signed.caseUid, reportUid: signed.reportUid });
      const shareUid = randomUUID();
      await createShareCodeHandler(w.deps, w.patient, { shareUid, caseUid: signed.caseUid, recipientUid: w.colleague.uid });
      const code = await codeInRow(w, noteId('caseShared', shareUid, w.colleague.uid));
      assert.ok(!((await docData(w, `patients/${w.patientId}`))?.doctorUids as string[]).includes(w.colleague.uid));
      await redeemShareCodeHandler(w.deps, w.colleague, { shareUid, code });
      assert.ok(((await docData(w, `patients/${w.patientId}`))?.doctorUids as string[]).includes(w.colleague.uid));
      assert.ok(((await caseDoc(w, signed.caseUid)).viewerUids as string[]).includes(w.colleague.uid));
    });

    it('concurrent redemptions at the viewer cap let exactly one in', async () => {
      const caseUid = await acceptedCase(w);
      const base = emulatorDeps();
      const third = await account(base, 'third@example.com', { role: 'doctor' });
      await w.deps.db.collection(DOCTORS).doc(third.uid).set({ uid: third.uid, verificationStatus: 'Verified', language: 'en' });
      await w.deps.db.collection(PRACTITIONERS).doc(third.uid).set({ uid: third.uid, isPathologist: false });
      const first = await shareTo(caseUid, w.colleague.uid);
      const second = await shareTo(caseUid, w.otherPathologist.uid);
      const thirdShare = randomUUID();
      await createShareCodeHandler(w.deps, w.doctor, { shareUid: thirdShare, caseUid, recipientUid: third.uid });
      const thirdCode = await codeInRow(w, noteId('caseShared', thirdShare, third.uid));
      await w.deps.db.collection('cases').doc(caseUid).update({
        viewerUids: Array.from({ length: 9 }, (_, i) => `viewer-${i}`),
      });

      const results = await Promise.allSettled([
        redeemShareCodeHandler(w.deps, w.colleague, { shareUid: first.shareUid, code: first.code }),
        redeemShareCodeHandler(w.deps, w.otherPathologist, { shareUid: second.shareUid, code: second.code }),
        redeemShareCodeHandler(w.deps, third, { shareUid: thirdShare, code: thirdCode }),
      ]);
      assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
      for (const r of results) {
        if (r.status === 'rejected') assert.equal((r.reason as Error).message, 'viewerCap');
      }
      assert.equal(((await caseDoc(w, caseUid)).viewerUids as string[]).length, 10);
    });
  });
});
