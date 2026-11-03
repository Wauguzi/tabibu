import assert from 'node:assert/strict';

import { seedWorld, docData, type World } from './case.test-support';
import { newId, runtime } from './domain.test-support';
import { resetEmulators } from './emulator.test-support';
import { sendPushHandler, type PushEvent } from './push';
import type { MessagingLike, PushMessage, PushResult } from './runtime-deps';

const REQUESTED = '2026-10-27T08:59:00.000Z';
const NOW = '2026-10-27T09:00:00.000Z';

class FakeMessaging implements MessagingLike {
  sent: PushMessage[] = [];
  respond: (message: PushMessage) => Promise<PushResult> = (m) =>
    Promise.resolve({ responses: m.tokens.map(() => ({ success: true })) });

  sendEachForMulticast(message: PushMessage): Promise<PushResult> {
    this.sent.push(message);
    return this.respond(message);
  }
}

describe('sendPush', () => {
  let w: World;
  let messaging: FakeMessaging;

  const deps = () => runtime(w, { messaging });

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
    messaging = new FakeMessaging();
    await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ fcmTokens: ['token-a', 'token-b'] });
  });

  async function row(extra: Record<string, unknown> = {}, recipientUid = w.doctor.uid, role = 'doctor'): Promise<string> {
    const uid = newId();
    await w.deps.db
      .collection('notifications')
      .doc(uid)
      .set({
        uid,
        scope: 'Cloud',
        recipientUid,
        recipientRole: role,
        templateKey: 'appointmentRequested',
        category: 'Appointment',
        priority: 'Normal',
        title: 'New appointment request',
        message: 'A patient asked to book you.',
        resourceType: 'Appointment',
        resourceUid: 'a-1',
        threadUid: '',
        metadata: { actionType: '', actionStatus: '', expiresAt: '', deepLink: '/appointments/a-1' },
        pushRequestedAt: REQUESTED,
        pushSentAt: '',
        lastUpdatedAt: REQUESTED,
        ...extra,
      });
    return uid;
  }

  const rowOf = (uid: string) => docData(w, `notifications/${uid}`);
  const pushSentAt = async (uid: string) => (await rowOf(uid))?.pushSentAt;

  /** The row's creation event: the document as it stands, with nothing before it. */
  const send = async (uid: string) =>
    sendPushHandler(deps(), uid, { before: undefined, after: await rowOf(uid) });
  const fire = (uid: string, event: PushEvent) => sendPushHandler(deps(), uid, event);

  it('sends the copy the row already carries and claims after finding a token', async () => {
    const uid = await row();
    assert.equal(await send(uid), 'sent');
    assert.equal(messaging.sent.length, 1);
    const [message] = messaging.sent;
    assert.deepEqual(message.tokens, ['token-a', 'token-b']);
    assert.deepEqual(message.notification, { title: 'New appointment request', body: 'A patient asked to book you.' });
    assert.equal(message.data.deepLink, '/appointments/a-1');
    assert.equal(message.data.notificationUid, uid);
    assert.equal(await pushSentAt(uid), NOW);
  });

  it('sends every cloud notification at high priority, on the app channel, with its title and body', async () => {
    // Normal in the registry, like the explanation-ready row: still delivered as urgent news.
    const uid = await row({
      templateKey: 'explanationReady',
      category: 'Case',
      priority: 'Normal',
      title: 'Explanation ready',
      message: 'An explanation is ready to review.',
    });
    assert.equal(await send(uid), 'sent');
    const [message] = messaging.sent;
    assert.deepEqual(message.notification, {
      title: 'Explanation ready',
      body: 'An explanation is ready to review.',
    });
    const android = message.android as { priority?: string; notification?: { channelId?: string } };
    const apns = message.apns as { headers?: Record<string, string> };
    assert.equal(android.priority, 'high');
    assert.equal(android.notification?.channelId, 'case_updates');
    assert.equal(apns.headers?.['apns-priority'], '10');
    assert.equal(message.data.channel, 'case_updates');

    const alert = await row({ category: 'Alert', title: 'Health notice', message: 'A notice for your area.' });
    await send(alert);
    assert.equal(
      (messaging.sent[1].android as { notification?: { channelId?: string } }).notification?.channelId,
      'alerts',
    );
  });

  it('does not send twice for one request', async () => {
    const uid = await row();
    await send(uid);
    assert.equal(await send(uid), 'skipped');
    assert.equal(messaging.sent.length, 1);
  });

  it('sends once when two invocations race', async () => {
    const uid = await row();
    const outcomes = await Promise.all([send(uid), send(uid)]);
    assert.equal(messaging.sent.length, 1);
    assert.ok(outcomes.includes('sent'));
  });

  it('skips a row that never asked for a push', async () => {
    const uid = await row({ pushRequestedAt: '' });
    assert.equal(await send(uid), 'skipped');
    assert.equal(messaging.sent.length, 0);
  });

  it('does not claim a row whose recipient has no token, so a later token can still be pushed', async () => {
    await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ fcmTokens: [] });
    const uid = await row();
    assert.equal(await send(uid), 'noToken');
    assert.equal(await pushSentAt(uid), '');
    assert.equal(messaging.sent.length, 0);

    await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ fcmTokens: ['token-c'] });
    assert.equal(await send(uid), 'sent');
  });

  it('keeps the claim and drops the token when it is no longer registered', async () => {
    await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ fcmTokens: ['dead'] });
    messaging.respond = () =>
      Promise.resolve({ responses: [{ success: false, error: { code: 'messaging/registration-token-not-registered' } }] });
    const uid = await row();
    assert.equal(await send(uid), 'deadTokens');
    assert.equal(await pushSentAt(uid), NOW);
    assert.deepEqual((await docData(w, `doctors/${w.doctor.uid}`))?.fcmTokens, []);
    assert.equal(await send(uid), 'skipped');
  });

  it('removes only the dead token when another one was delivered', async () => {
    messaging.respond = () =>
      Promise.resolve({
        responses: [{ success: false, error: { code: 'messaging/registration-token-not-registered' } }, { success: true }],
      });
    const uid = await row();
    assert.equal(await send(uid), 'sent');
    assert.deepEqual((await docData(w, `doctors/${w.doctor.uid}`))?.fcmTokens, ['token-b']);
  });

  it('clears the claim and throws on a transient failure, so the retry sends', async () => {
    messaging.respond = () => Promise.reject(new Error('unavailable'));
    const uid = await row();
    await assert.rejects(send(uid), /unavailable/);
    assert.equal(await pushSentAt(uid), '');

    messaging.respond = (m) => Promise.resolve({ responses: m.tokens.map(() => ({ success: true })) });
    assert.equal(await send(uid), 'sent');
  });

  it('does not send again when its own claim and release writes come back as events', async () => {
    const uid = await row();
    let claimed: Record<string, unknown> | undefined;
    messaging.respond = async () => {
      claimed = await rowOf(uid);
      throw new Error('unavailable');
    };
    const created = await rowOf(uid);
    await assert.rejects(send(uid), /unavailable/);
    const released = await rowOf(uid);
    assert.equal(claimed?.pushSentAt, NOW);
    assert.equal(released?.pushSentAt, '');

    // The platform delivers each write the handler itself made: neither is a push request.
    assert.equal(await fire(uid, { before: created, after: claimed }), 'skipped');
    assert.equal(await fire(uid, { before: claimed, after: released }), 'skipped');
    assert.equal(messaging.sent.length, 1);

    // A retry of the original event is a redelivery of the request, and it sends.
    messaging.respond = (m) => Promise.resolve({ responses: m.tokens.map(() => ({ success: true })) });
    assert.equal(await fire(uid, { before: undefined, after: created }), 'sent');
    assert.equal(messaging.sent.length, 2);
  });

  it('sends again for a new request, which moves pushRequestedAt', async () => {
    const uid = await row();
    await send(uid);
    const before = await rowOf(uid);
    await w.deps.db.collection('notifications').doc(uid).update({ pushRequestedAt: '2026-10-27T09:00:30.000Z' });
    const after = await rowOf(uid);
    assert.equal(await fire(uid, { before, after }), 'sent');
    assert.equal(messaging.sent.length, 2);
  });

  it('clears the claim when every token fails for a reason that is not a dead token', async () => {
    messaging.respond = (m) =>
      Promise.resolve({ responses: m.tokens.map(() => ({ success: false, error: { code: 'messaging/internal-error' } })) });
    const uid = await row();
    await assert.rejects(send(uid), /pushTransientFailure/);
    assert.equal(await pushSentAt(uid), '');
  });

  it('leaves a newer request’s claim alone when its own attempt fails', async () => {
    const uid = await row();
    const newer = '2026-10-27T09:30:00.000Z';
    messaging.respond = async () => {
      await w.deps.db.collection('notifications').doc(uid).update({ pushSentAt: newer });
      throw new Error('unavailable');
    };
    await assert.rejects(send(uid), /unavailable/);
    assert.equal(await pushSentAt(uid), newer);
  });

  it('reads an approver’s tokens from the registry', async () => {
    await w.deps.db.collection('alertApprovers').doc('admin-1').set({ uid: 'admin-1', fcmTokens: ['staff-token'], language: 'en' });
    const uid = await row({ category: 'Alert' }, 'admin-1', 'admin');
    assert.equal(await send(uid), 'sent');
    assert.deepEqual(messaging.sent[0].tokens, ['staff-token']);
    assert.equal(messaging.sent[0].data.channel, 'alerts');
  });

  it('reads a patient’s tokens from their record and honours the notification switch', async () => {
    const patients = w.deps.db.collection('patients').doc(w.patientId);
    await patients.update({ fcmTokens: ['patient-token'] });
    const first = await row({ category: 'Result' }, w.patient.uid, 'patient');
    assert.equal(await send(first), 'sent');
    assert.deepEqual(messaging.sent[0].tokens, ['patient-token']);

    await patients.update({ receiveNotifications: false });
    const second = await row({}, w.patient.uid, 'patient');
    assert.equal(await send(second), 'noToken');
  });

  it('does not push an approval that has been answered or has expired', async () => {
    const answered = await row({ metadata: { actionType: 'Approval', actionStatus: 'Accepted', expiresAt: '', deepLink: '' } });
    assert.equal(await send(answered), 'skipped');
    const expired = await row({ metadata: { actionType: 'Approval', actionStatus: 'Pending', expiresAt: REQUESTED, deepLink: '' } });
    assert.equal(await send(expired), 'skipped');
    assert.equal(messaging.sent.length, 0);
  });

  it('collapses message pushes by thread and sends nothing from an in-app row', async () => {
    const message = await row({ templateKey: 'messageReceived', category: 'Message', threadUid: 'thread-1' });
    await send(message);
    assert.equal(messaging.sent[0].android?.collapseKey, 'thread-1');
    const local = await row({ scope: 'Local' });
    assert.equal(await send(local), 'skipped');
    assert.equal(messaging.sent.length, 1);
  });
});
