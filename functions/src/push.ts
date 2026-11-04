/**
 * The push trigger (plan §3.5 `sendPush`, 04 §6.8). It sends the copy the inbox row already
 * carries: that text was rendered from the fixed template table when the row was written, so it
 * names no diagnosis, person, order number or model text (S-3). Nothing here invents wording.
 *
 * The claim is `pushSentAt = N`, taken only once a token is known, so a recipient with no device
 * costs nothing and is never marked as pushed.
 */
import { FieldValue, type DocumentData, type DocumentReference } from 'firebase-admin/firestore';

import { str, strings } from './case-support';
import { timestamp } from './common';
import { buildQuery, queryById } from './queries';
import { HOUR_MS, nowOf, type PushMessage, type RuntimeDeps } from './runtime-deps';

export type PushDeps = Pick<RuntimeDeps, 'db' | 'messaging' | 'now'>;

export type PushOutcome = 'skipped' | 'noToken' | 'sent' | 'deadTokens' | 'lostClaim';

const DEAD_TOKEN_CODES = [
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'registration-token-not-registered',
  'invalid-registration-token',
];

const STALE_REQUEST_MS = HOUR_MS;

interface Recipient {
  ref: DocumentReference;
  tokens: string[];
  allowed: boolean;
}

/** Who holds the device tokens: staff rows for an approver, the profile for everyone else. */
async function recipientOf(deps: PushDeps, role: string, uid: string): Promise<Recipient | null> {
  const { db } = deps;
  if (role === 'admin') {
    const ref = db.collection('alertApprovers').doc(uid);
    const data = (await ref.get()).data();
    return data ? { ref, tokens: strings(data.fcmTokens), allowed: true } : null;
  }
  if (role === 'patient') {
    const found = await buildQuery(db, queryById('patients.byUid'), [uid]).limit(1).get();
    if (found.empty) return null;
    const doc = found.docs[0];
    return { ref: doc.ref, tokens: strings(doc.get('fcmTokens')), allowed: doc.get('receiveNotifications') !== false };
  }
  const ref = db.collection('doctors').doc(uid);
  const data = (await ref.get()).data();
  return data ? { ref, tokens: strings(data.fcmTokens), allowed: data.receiveNotifications !== false } : null;
}

function messageFor(row: DocumentData, tokens: string[]): PushMessage {
  const metadata = (row.metadata ?? {}) as Record<string, unknown>;
  const thread = str(row.threadUid);
  const category = str(row.category);
  const collapses = str(row.templateKey) === 'messageReceived' || str(row.templateKey) === 'mdtMessageReceived';
  const title = str(row.title);
  const channel = category === 'Account' ? 'account' : category === 'Alert' ? 'alerts' : 'case_updates';
  return {
    tokens,
    notification: { ...(title === '' ? {} : { title }), body: str(row.message) },
    data: {
      notificationUid: str(row.uid),
      threadUid: thread,
      category,
      resourceType: str(row.resourceType),
      resourceUid: str(row.resourceUid),
      actionType: str(metadata.actionType),
      expiresAt: str(metadata.expiresAt),
      deepLink: str(metadata.deepLink),
      channel,
    },
    // Every cloud notification is a person's own news and is delivered at high priority, on the
    // app's own Android channel, with its title and body: the device shows it at once.
    android: {
      priority: 'high',
      ...(collapses ? { collapseKey: thread } : {}),
      notification: { channelId: channel, ...(collapses ? { tag: thread } : {}) },
    },
    apns: {
      headers: {
        'apns-priority': '10',
        ...(collapses ? { 'apns-collapse-id': thread } : {}),
      },
      payload: { aps: { ...(collapses ? { 'thread-id': thread } : {}) } },
    },
  };
}

/** The trigger's own event: a retry of it redelivers the same pair, so it still passes the edge. */
export interface PushEvent {
  before: DocumentData | undefined;
  after: DocumentData | undefined;
}

/**
 * Acts only on a push request: `pushRequestedAt` set or moved. The claim and its release also
 * write this document, and neither may start a send, or one failure would loop at once instead
 * of waiting for the platform's backoff.
 */
export async function sendPushHandler(
  deps: PushDeps,
  notificationUid: string,
  event: PushEvent,
): Promise<PushOutcome> {
  const asked = str(event.after?.pushRequestedAt);
  if (asked === '' || asked === str(event.before?.pushRequestedAt)) return 'skipped';
  const { db } = deps;
  const now = nowOf(deps);
  const ref = db.collection('notifications').doc(notificationUid);
  const row = (await ref.get()).data();
  if (!row) return 'skipped';

  const requested = str(row.pushRequestedAt);
  const sent = str(row.pushSentAt);
  // A collapsed row asks again after its throttle; an answered request is not asked twice.
  if (row.scope !== 'Cloud' || requested === '' || (sent !== '' && sent >= requested)) return 'skipped';
  const metadata = (row.metadata ?? {}) as Record<string, unknown>;
  if (metadata.actionType === 'Approval' && metadata.actionStatus !== 'Pending') return 'skipped';
  const expiresAt = str(metadata.expiresAt);
  if (expiresAt !== '' && Date.parse(expiresAt) <= now.getTime()) return 'skipped';
  if (now.getTime() - Date.parse(requested) > STALE_REQUEST_MS) return 'skipped';

  const recipient = await recipientOf(deps, str(row.recipientRole), str(row.recipientUid));
  if (!recipient || !recipient.allowed || recipient.tokens.length === 0) return 'noToken';

  const claim = await claimPush(deps, ref, requested, now);
  if (claim === null) return 'lostClaim';

  const message = messageFor(row, recipient.tokens);
  let responses: { success: boolean; error?: { code?: string } }[];
  try {
    if (!deps.messaging) throw new Error('messaging unavailable');
    responses = (await deps.messaging.sendEachForMulticast(message)).responses;
  } catch (error) {
    await releaseClaim(deps, ref, claim.at, claim.previous, now);
    throw error;
  }

  const dead = recipient.tokens.filter((_, i) => {
    const response = responses[i];
    return response && !response.success && DEAD_TOKEN_CODES.includes(str(response.error?.code));
  });
  if (dead.length > 0) {
    await recipient.ref
      .update({ fcmTokens: FieldValue.arrayRemove(...dead), lastUpdatedAt: timestamp(now) })
      .catch(() => undefined);
  }
  if (responses.some((r) => r.success)) return 'sent';
  if (dead.length === recipient.tokens.length) return 'deadTokens';

  await releaseClaim(deps, ref, claim.at, claim.previous, now);
  throw new Error('pushTransientFailure');
}

/** `pushSentAt = N`, read and written in one transaction so two invocations cannot both win. */
async function claimPush(
  deps: PushDeps,
  ref: DocumentReference,
  requested: string,
  now: Date,
): Promise<{ at: string; previous: string } | null> {
  return deps.db.runTransaction(async (tx) => {
    const current = (await tx.get(ref)).data();
    if (!current) return null;
    const previous = str(current.pushSentAt);
    if (str(current.pushRequestedAt) !== requested || (previous !== '' && previous >= requested)) return null;
    const stamped = timestamp(now);
    const at = stamped >= requested ? stamped : requested;
    tx.update(ref, { pushSentAt: at, lastUpdatedAt: stamped });
    return { at, previous };
  });
}

/** Clears the claim only when it is still ours: a newer request's claim is left alone (I-Q). */
async function releaseClaim(
  deps: PushDeps,
  ref: DocumentReference,
  claimed: string,
  previous: string,
  now: Date,
): Promise<void> {
  await deps.db.runTransaction(async (tx) => {
    const current = (await tx.get(ref)).data();
    if (!current || str(current.pushSentAt) !== claimed) return;
    tx.update(ref, { pushSentAt: previous, lastUpdatedAt: timestamp(now) });
  });
}
