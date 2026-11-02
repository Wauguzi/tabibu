/**
 * Share codes (plan §3.2). The plain code lives only in the recipient's
 * notification metadata — never returned to the handler, never logged.
 */
import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';

import {
  FieldValue,
  type DocumentData,
  type DocumentReference,
  type DocumentSnapshot,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';

import { refuse, timestamp } from './common';
import {
  NotificationTx,
  type LoadedNotification,
  notificationId,
} from './notifications';

export type SharePurpose = 'Join' | 'ReportUnlock';
export type ShareStatus = 'Pending' | 'Redeemed' | 'Expired' | 'Locked' | 'Revoked';

export interface ShareRecord {
  uid: string;
  caseUid: string;
  reportUid: string;
  purpose: SharePurpose;
  createdByUid: string;
  createdByRole: string;
  recipientUid: string;
  status: ShareStatus;
  attempts: number;
  reissueCount: number;
  expiresAt: string;
  redeemedAt: string;
  notificationUid: string;
  createdAt: string;
  lastUpdatedAt: string;
}

export type MintMode = 'create' | 'reissue';

export interface MintShareArgs {
  shareUid: string;
  caseUid: string;
  reportUid?: string;
  purpose: SharePurpose;
  createdByUid: string;
  createdByRole: string;
  recipientUid: string;
  expiresAt: string;
  /** Template that carries the code (caseShared | reportSigned | reportUpdated | shareCodeReissued). */
  template: 'caseShared' | 'reportSigned' | 'reportUpdated' | 'shareCodeReissued';
  resourceKey?: string;
  threadUid?: string;
  language?: 'en' | 'sw';
  deepLink?: string;
  mode?: MintMode;
  /** Who reads the code; a share to a pathologist (the signer) is not for a doctor. */
  recipientRole?: 'doctor' | 'pathologist';
  /** A critical result: the row goes out at High priority, whatever the template's usual one. */
  critical?: boolean;
}

export interface LoadedShareClose {
  shareUid: string;
  share: ShareRecord | null;
  shareRef: DocumentReference;
  secretRef: DocumentReference;
  secretExists: boolean;
  notification: LoadedNotification | null;
}

/** HMAC-SHA256 hex of `shareUid:code` under the injected key. */
export function hmacCode(shareCodeKey: string, shareUid: string, code: string): string {
  return createHmac('sha256', shareCodeKey).update(`${shareUid}:${code}`).digest('hex');
}

/** Four-digit code, zero-padded. */
export function generateShareCode(): string {
  return String(randomInt(0, 10000)).padStart(4, '0');
}

export function codesEqual(left: string, right: string): boolean {
  const a = Buffer.from(left);
  const b = Buffer.from(right);
  if (a.length !== b.length) return false;
  return timingSafeEqual(a, b);
}

function asShare(data: DocumentData | undefined, uid: string): ShareRecord | null {
  if (!data) return null;
  return {
    uid,
    caseUid: typeof data.caseUid === 'string' ? data.caseUid : '',
    reportUid: typeof data.reportUid === 'string' ? data.reportUid : '',
    purpose: (data.purpose as SharePurpose) ?? 'Join',
    createdByUid: typeof data.createdByUid === 'string' ? data.createdByUid : '',
    createdByRole: typeof data.createdByRole === 'string' ? data.createdByRole : '',
    recipientUid: typeof data.recipientUid === 'string' ? data.recipientUid : '',
    status: (data.status as ShareStatus) ?? 'Pending',
    attempts: typeof data.attempts === 'number' ? data.attempts : 0,
    reissueCount: typeof data.reissueCount === 'number' ? data.reissueCount : 0,
    expiresAt: typeof data.expiresAt === 'string' ? data.expiresAt : '',
    redeemedAt: typeof data.redeemedAt === 'string' ? data.redeemedAt : '',
    notificationUid: typeof data.notificationUid === 'string' ? data.notificationUid : '',
    createdAt: typeof data.createdAt === 'string' ? data.createdAt : '',
    lastUpdatedAt: typeof data.lastUpdatedAt === 'string' ? data.lastUpdatedAt : '',
  };
}

/** Read half for closing a share. Call before any write. */
export async function loadShareClose(
  tx: Transaction,
  db: Firestore,
  shareUid: string,
): Promise<LoadedShareClose> {
  const shareRef = db.collection('shareCodes').doc(shareUid);
  const secretRef = db.collection('shareSecrets').doc(shareUid);
  const shareSnap = await tx.get(shareRef);
  const secretSnap = await tx.get(secretRef);
  const share = asShare(shareSnap.data(), shareUid);
  let notification: LoadedNotification | null = null;
  if (share?.notificationUid) {
    const nRef = db.collection('notifications').doc(share.notificationUid);
    const nSnap = await tx.get(nRef);
    notification = {
      id: share.notificationUid,
      ref: nRef,
      snap: nSnap,
      exists: nSnap.exists,
    };
  }
  return {
    shareUid,
    share,
    shareRef,
    secretRef,
    secretExists: secretSnap.exists,
    notification,
  };
}

function settleStatus(status: ShareStatus): string {
  switch (status) {
    case 'Redeemed':
      return 'Acknowledged';
    case 'Expired':
      return 'Expired';
    default:
      return 'Cancelled';
  }
}

/**
 * Write half: the only exit from Pending. Deletes the secret, clears shareCode
 * on the linked notification, adjusts pendingShares for Join.
 */
export function closeShare(
  tx: Transaction,
  db: Firestore,
  loaded: LoadedShareClose,
  status: Exclude<ShareStatus, 'Pending'>,
  now: Date,
): void {
  if (!loaded.share || loaded.share.status !== 'Pending') return;
  const at = timestamp(now);
  const share = loaded.share;
  tx.update(loaded.shareRef, {
    status,
    redeemedAt: status === 'Redeemed' ? at : share.redeemedAt,
    lastUpdatedAt: at,
  });
  if (loaded.secretExists) tx.delete(loaded.secretRef);
  if (share.purpose === 'Join') {
    tx.set(
      db.collection('rateCounters').doc(`pendingShares:${share.caseUid}`),
      { count: FieldValue.increment(-1), lastUpdatedAt: at },
      { merge: true },
    );
  }
  if (loaded.notification?.exists) {
    NotificationTx.settle(tx, loaded.notification, settleStatus(status), '', now);
  }
}

function resourceKeyFor(args: MintShareArgs): string {
  if (args.resourceKey) return args.resourceKey;
  if (args.mode === 'reissue') {
    // reissueCount on the existing record is applied after mint; caller passes
    // the key including -r{n} when known. Default: shareUid alone for first mint.
    return args.shareUid;
  }
  return args.shareUid;
}

/**
 * Create or reissue a share, writing the recipient notification (with the code)
 * itself. Returns only `{ shareUid }` — never the plain code.
 *
 * Callers must [NotificationTx.load] the notification id first and pass it in.
 */
export function mintShareCode(
  tx: Transaction,
  db: Firestore,
  args: MintShareArgs,
  loadedNotification: LoadedNotification,
  shareCodeKey: string,
  now: Date,
  priorShare?: DocumentSnapshot | null,
  generate: () => string = generateShareCode,
): { shareUid: string } {
  if (!shareCodeKey) throw refuse('failed-precondition', 'shareKeyMissing');
  const mode: MintMode = args.mode ?? 'create';
  const code = generate();
  if (!/^\d{4}$/.test(code)) throw refuse('invalid-argument', 'invalidShareCode');

  const at = timestamp(now);
  const key = resourceKeyFor(args);
  const expectedId = notificationId(args.template, key, args.recipientUid);
  if (loadedNotification.id !== expectedId) {
    throw refuse('invalid-argument', 'notificationMismatch');
  }

  let reissueCount = 0;
  let createdAt = at;
  if (mode === 'reissue') {
    const prior = priorShare?.data();
    if (!prior) throw refuse('failed-precondition', 'shareMissing');
    const prevStatus = prior.status as ShareStatus;
    // A revoke that landed on a current-version unlock is undone here, so the ordering doctor is
    // never left without a way in; the caller has checked the version is still current.
    const reusable =
      prevStatus === 'Expired' ||
      prevStatus === 'Locked' ||
      prevStatus === 'Pending' ||
      (prevStatus === 'Revoked' && args.purpose === 'ReportUnlock');
    if (!reusable) throw refuse('failed-precondition', 'shareNotReusable');
    reissueCount = (typeof prior.reissueCount === 'number' ? prior.reissueCount : 0) + 1;
    createdAt = typeof prior.createdAt === 'string' ? prior.createdAt : at;
  } else if (priorShare?.exists) {
    throw refuse('already-exists', 'shareExists');
  }

  const notificationUid = expectedId;
  const share: ShareRecord = {
    uid: args.shareUid,
    caseUid: args.caseUid,
    reportUid: args.reportUid ?? '',
    purpose: args.purpose,
    createdByUid: args.createdByUid,
    createdByRole: args.createdByRole,
    recipientUid: args.recipientUid,
    status: 'Pending',
    attempts: 0,
    reissueCount,
    expiresAt: args.expiresAt,
    redeemedAt: '',
    notificationUid,
    createdAt,
    lastUpdatedAt: at,
  };

  const shareRef = db.collection('shareCodes').doc(args.shareUid);
  const secretRef = db.collection('shareSecrets').doc(args.shareUid);
  if (mode === 'reissue') {
    tx.set(shareRef, share as unknown as DocumentData);
    tx.set(secretRef, {
      uid: args.shareUid,
      codeHmac: hmacCode(shareCodeKey, args.shareUid, code),
      createdAt: at,
      lastUpdatedAt: at,
    });
  } else {
    tx.create(shareRef, share as unknown as DocumentData);
    tx.create(secretRef, {
      uid: args.shareUid,
      codeHmac: hmacCode(shareCodeKey, args.shareUid, code),
      createdAt: at,
      lastUpdatedAt: at,
    });
    if (args.purpose === 'Join') {
      tx.set(
        db.collection('rateCounters').doc(`pendingShares:${args.caseUid}`),
        { count: FieldValue.increment(1), lastUpdatedAt: at },
        { merge: true },
      );
    }
  }

  NotificationTx.create(
    tx,
    loadedNotification,
    {
      template: args.template,
      resourceKey: key,
      resourceUid: args.caseUid,
      threadUid: args.threadUid ?? args.caseUid,
      recipientUid: args.recipientUid,
      recipientRole: args.recipientRole ?? 'doctor',
      language: args.language ?? 'en',
      deepLink: args.deepLink,
      priority: args.critical === true ? 'High' : undefined,
      shareCode: code,
      expiresAt: args.expiresAt,
    },
    now,
  );

  return { shareUid: args.shareUid };
}

export type RedemptionJudgement =
  | { outcome: 'Expired' }
  | { outcome: 'Locked'; attempts: number }
  | { outcome: 'Wrong'; attempts: number; lock: boolean }
  | { outcome: 'Right' };

/**
 * Pure redeem decision: Pending, not expired, attempts < 5, then compare.
 */
export function judgeRedemption(
  share: ShareRecord,
  codeHmac: string,
  shareCodeKey: string,
  code: string,
  now: Date,
): RedemptionJudgement {
  if (!/^\d{4}$/.test(code)) {
    return { outcome: 'Wrong', attempts: share.attempts, lock: false };
  }
  if (share.status === 'Locked') return { outcome: 'Locked', attempts: share.attempts };
  if (share.status !== 'Pending') {
    return { outcome: 'Wrong', attempts: share.attempts, lock: false };
  }
  if (share.expiresAt && share.expiresAt <= now.toISOString()) {
    return { outcome: 'Expired' };
  }
  if (share.attempts >= 5) return { outcome: 'Locked', attempts: share.attempts };
  if (verifyShareCode(shareCodeKey, share.uid, code, codeHmac)) {
    return { outcome: 'Right' };
  }
  const attempts = share.attempts + 1;
  return { outcome: 'Wrong', attempts, lock: attempts >= 5 };
}

/** Verify a submitted code against the stored HMAC. */
export function verifyShareCode(
  shareCodeKey: string,
  shareUid: string,
  code: string,
  codeHmac: string,
): boolean {
  const expected = hmacCode(shareCodeKey, shareUid, code);
  return codesEqual(expected, codeHmac);
}
