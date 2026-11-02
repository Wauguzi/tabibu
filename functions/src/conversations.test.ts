// cspell:ignore Amina Otieno Wanjiru Njeri Mwangi Achieng mvhd mdts maumivu kichwa makali
import assert from 'node:assert/strict';

import {
  caseDoc,
  docData,
  noteId,
  orderInput,
  acceptedCase,
  seedWorld,
  signedCase,
  type World,
} from './case.test-support';
import {
  INVITE_TTL_MS,
  MEDIA_PAGE,
  closeConversationHandler,
  emptyCaseSummary,
  inviteToMdtHandler,
  leaveMdtHandler,
  mdtAgeBand,
  measureM4aMs,
  onMessageCreatedHandler,
  openDirectConversationHandler,
  openMdtHandler,
  removeFromMdtHandler,
  respondToMdtInviteHandler,
  shareTranscriptHandler,
  sweepConversationsHandler,
  withdrawMessageHandler,
} from './conversations';
import {
  acceptCaseHandler,
  cancelOrderHandler,
  createOrderHandler,
  reassignPathologistHandler,
  removeCaseViewerHandler,
} from './cases';
import type { Caller } from './common';
import {
  ahead,
  allOff,
  bucket,
  farAhead,
  m4aOf,
  newId,
  objectExists,
  putObject,
  runtime,
} from './domain.test-support';
import { refused, refusedWith, resetEmulators, callerWithoutRole } from './emulator.test-support';
import { CLINICAL_SPECIALTIES } from './identity';
import { DAY_MS, MINUTE_MS, type RuntimeDeps, type StorageLike } from './runtime-deps';

const NOW = '2026-10-27T09:00:00.000Z';
const SENT = '2026-10-27T08:59:30.000Z';
const SPECIALTY = CLINICAL_SPECIALTIES[0];
const DAY_KEY = '20261027';
const MACHINE_TEXT = 'Nina maumivu ya kichwa.';

type Row = Record<string, unknown>;

describe('conversations', () => {
  let w: World;
  let deps: RuntimeDeps;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
    await bucket().deleteFiles({ prefix: 'conversations/', force: true });
    deps = runtime(w);
  });

  const members = (c: Row | undefined) => (c?.members ?? {}) as Record<string, Row>;
  const conv = (uid: string) => docData(w, `conversations/${uid}`);
  const message = (c: string, m: string) => docData(w, `conversations/${c}/messages/${m}`);
  const transcript = (c: string, m: string, id: 'machine' | 'shared') =>
    docData(w, `conversations/${c}/messages/${m}/transcript/${id}`);
  const quota = (uid: string) => docData(w, `messageQuotas/${uid}`);

  async function signal(field: string): Promise<unknown> {
    const docs = await w.deps.db.collection('modelSignals').get();
    return docs.docs[0]?.get(field);
  }

  async function direct(): Promise<string> {
    await w.deps.db.collection('appointments').doc(w.appointmentUid).update({ patientUid: w.patient.uid });
    const { conversationUid } = await openDirectConversationHandler(deps, w.patient, {
      resourceType: 'Appointment',
      resourceUid: w.appointmentUid,
    });
    return conversationUid;
  }

  async function openMdt(
    invitees: string[] = [w.colleague.uid],
    extra: Record<string, unknown> = {},
  ): Promise<{ conversationUid: string; caseUid: string }> {
    const caseUid = await acceptedCase(w);
    const conversationUid = newId();
    await openMdtHandler(deps, w.doctor, {
      conversationUid,
      caseUid,
      specialty: SPECIALTY,
      description: 'Please look at this lesion with me.',
      inviteeUids: invitees,
      ...extra,
    });
    return { conversationUid, caseUid };
  }

  async function acceptedMdt(): Promise<{ conversationUid: string; caseUid: string }> {
    const made = await openMdt();
    await respondToMdtInviteHandler(deps, w.colleague, { conversationUid: made.conversationUid, accept: true });
    return made;
  }

  async function post(conversationUid: string, fields: Row = {}): Promise<string> {
    const uid = newId();
    await w.deps.db
      .doc(`conversations/${conversationUid}/messages/${uid}`)
      .set({
        uid,
        senderUid: w.doctor.uid,
        kind: 'Text',
        text: 'Hello there',
        hasAttachment: false,
        attachmentPath: '',
        status: 'Sent',
        sentAt: SENT,
        deliveredAt: '',
        transcriptStatus: 'None',
        transcriptShared: false,
        identifierFlagged: false,
        lastUpdatedAt: SENT,
        ...fields,
      });
    return uid;
  }

  async function postVoice(
    conversationUid: string,
    opts: {
      sender?: string;
      bytes?: Buffer | null;
      contentType?: string;
      claimedMs?: number;
      extra?: Row;
    } = {},
  ): Promise<string> {
    const uid = newId();
    const path = `conversations/${conversationUid}/voice/${uid}.m4a`;
    if (opts.bytes !== null) await putObject(path, opts.bytes ?? m4aOf(30), opts.contentType ?? 'audio/mp4');
    await w.deps.db
      .doc(`conversations/${conversationUid}/messages/${uid}`)
      .set({
        uid,
        senderUid: opts.sender ?? w.doctor.uid,
        kind: 'Voice',
        text: '',
        hasAttachment: true,
        attachmentPath: path,
        voiceDurationMs: opts.claimedMs ?? 30_000,
        status: 'Sent',
        sentAt: SENT,
        deliveredAt: '',
        transcriptStatus: 'Queued',
        transcriptShared: false,
        identifierFlagged: false,
        lastUpdatedAt: SENT,
        ...opts.extra,
      });
    return uid;
  }

  async function deliverVoice(c: string, opts: Parameters<typeof postVoice>[1] = {}): Promise<string> {
    const m = await postVoice(c, opts);
    await onMessageCreatedHandler(deps, c, m);
    return m;
  }

  function ai(transcribeAudio: NonNullable<RuntimeDeps['ai']>['transcribeAudio']): RuntimeDeps {
    return runtime(w, { ai: { ...deps.ai!, transcribeAudio } });
  }

  describe('openDirectConversation', () => {
    it('opens an appointment thread between the patient and the doctor', async () => {
      const uid = await direct();
      assert.equal(uid, `appt_${w.appointmentUid}`);
      const c = await conv(uid);
      assert.equal(c?.type, 'Direct');
      assert.equal(c?.status, 'Open');
      assert.equal(c?.createdByUid, w.patient.uid);
      assert.equal(c?.linkedResourceType, 'Appointment');
      assert.deepEqual([...(c?.participantUids as string[])].sort(), [w.doctor.uid, w.patient.uid].sort());
      const patient = members(c)[w.patient.uid];
      assert.equal(patient.actorRole, 'patient');
      assert.equal(patient.status, 'Accepted');
      assert.equal(patient.title, '');
      assert.equal(patient.profilePictureUrl, '');
      assert.equal(members(c)[w.doctor.uid].actorRole, 'doctor');
      assert.equal(members(c)[w.doctor.uid].firstName, 'Njeri');
      assert.equal(c?.nextInviteExpiresAt, '');
    });

    it('is idempotent and keeps the first opener', async () => {
      const uid = await direct();
      const again = await openDirectConversationHandler(deps, w.doctor, {
        resourceType: 'Appointment',
        resourceUid: w.appointmentUid,
      });
      assert.deepEqual(again, { conversationUid: uid });
      assert.equal((await conv(uid))?.createdByUid, w.patient.uid);
    });

    it('refuses a stranger, a request not yet accepted and a missing resource', async () => {
      await w.deps.db.collection('appointments').doc(w.appointmentUid).update({ patientUid: w.patient.uid });
      const input = { resourceType: 'Appointment', resourceUid: w.appointmentUid };
      await refusedWith(openDirectConversationHandler(deps, w.colleague, input), 'notParticipant');
      await refusedWith(openDirectConversationHandler(deps, w.pathologist, input), 'notParticipant');
      await refusedWith(openDirectConversationHandler(deps, null, input), 'unauthenticated');
      await refusedWith(
        openDirectConversationHandler(deps, w.patient, { resourceType: 'Appointment', resourceUid: 'nope' }),
        'conversationUnavailable',
      );
      await refusedWith(
        openDirectConversationHandler(deps, w.patient, { resourceType: 'Other', resourceUid: 'x' }),
        'conversationUnavailable',
      );
      await w.deps.db.collection('appointments').doc(w.appointmentUid).update({ status: 'Requested' });
      await refusedWith(openDirectConversationHandler(deps, w.patient, input), 'conversationUnavailable');
    });

    it('refuses a closed thread', async () => {
      const uid = await direct();
      await closeConversationHandler(deps, w.doctor, { conversationUid: uid });
      await refusedWith(
        openDirectConversationHandler(deps, w.doctor, { resourceType: 'Appointment', resourceUid: w.appointmentUid }),
        'conversationClosed',
      );
    });

    it('rebuilds the order thread id from the case’s own pathologist', async () => {
      const caseUid = await acceptedCase(w);
      const expected = `case_${caseUid}_${w.pathologist.uid}`;
      const fromDoctor = await openDirectConversationHandler(deps, w.doctor, {
        resourceType: 'Order',
        resourceUid: caseUid,
        conversationUid: 'spoofed',
      });
      assert.deepEqual(fromDoctor, { conversationUid: expected });
      const fromPathologist = await openDirectConversationHandler(deps, w.pathologist, {
        resourceType: 'Order',
        resourceUid: caseUid,
        pathologistUid: w.pathologist.uid,
      });
      assert.deepEqual(fromPathologist, { conversationUid: expected });
      const c = await conv(expected);
      assert.equal(c?.linkedResourceType, 'Order');
      assert.equal(members(c)[w.pathologist.uid].actorRole, 'pathologist');
      assert.equal(await conv('spoofed'), undefined);
    });

    it('refuses a pathologist the case does not name and anyone outside the pair', async () => {
      const caseUid = await acceptedCase(w);
      const input = { resourceType: 'Order', resourceUid: caseUid };
      await refusedWith(
        openDirectConversationHandler(deps, w.doctor, { ...input, pathologistUid: w.otherPathologist.uid }),
        'conversationUnavailable',
      );
      await refusedWith(openDirectConversationHandler(deps, w.otherPathologist, input), 'notParticipant');
      await refusedWith(openDirectConversationHandler(deps, w.colleague, input), 'notParticipant');
      await refusedWith(openDirectConversationHandler(deps, w.patient, input), 'notParticipant');
      await refusedWith(
        openDirectConversationHandler(deps, w.doctor, { ...input, resourceUid: newId() }),
        'conversationUnavailable',
      );
    });

    it('refuses an order that has no pathologist yet', async () => {
      const input = orderInput(w);
      await createOrderHandler(w.deps, w.doctor, input);
      const caseUid = input.caseUid as string;
      assert.equal((await caseDoc(w, caseUid)).pathologistUid ?? '', '');
      await refusedWith(
        openDirectConversationHandler(deps, w.doctor, { resourceType: 'Order', resourceUid: caseUid }),
        'conversationUnavailable',
      );
    });
  });

  describe('openMdt', () => {
    it('creates the group, invites the practitioners and notifies each once', async () => {
      const { conversationUid, caseUid } = await openMdt([w.colleague.uid, w.otherPathologist.uid]);
      const c = await conv(conversationUid);
      const expires = new Date(Date.parse(NOW) + INVITE_TTL_MS).toISOString();
      assert.equal(c?.type, 'GroupConsult');
      assert.equal(c?.status, 'Open');
      assert.equal(c?.createdByUid, w.doctor.uid);
      assert.equal(c?.linkedResourceType, 'Order');
      assert.equal(c?.linkedResourceUid, caseUid);
      assert.equal(c?.specialty, SPECIALTY);
      assert.deepEqual(c?.participantUids, [w.doctor.uid]);
      assert.equal(c?.nextInviteExpiresAt, expires);
      assert.equal(members(c)[w.doctor.uid].memberRole, 'Owner');
      assert.equal(members(c)[w.doctor.uid].status, 'Accepted');
      assert.equal(members(c)[w.colleague.uid].status, 'Invited');
      assert.equal(members(c)[w.colleague.uid].inviteRound, 1);
      assert.equal(members(c)[w.colleague.uid].invitedByUid, w.doctor.uid);
      assert.equal(members(c)[w.otherPathologist.uid].actorRole, 'pathologist');

      const row = await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.colleague.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Pending');
      assert.equal((row?.metadata as { expiresAt: string }).expiresAt, expires);
      assert.equal(row?.threadUid, conversationUid);
      assert.ok(await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.otherPathologist.uid)));
      assert.equal((await docData(w, `rateCounters/mdts:${w.doctor.uid}:${DAY_KEY}`))?.count, 1);
    });

    it('lets the case’s pathologist open one too', async () => {
      const caseUid = await acceptedCase(w);
      const conversationUid = newId();
      await openMdtHandler(deps, w.pathologist, {
        conversationUid,
        caseUid,
        specialty: SPECIALTY,
        description: 'A second look, please.',
      });
      const c = await conv(conversationUid);
      assert.equal(members(c)[w.pathologist.uid].actorRole, 'pathologist');
      assert.deepEqual(c?.participantUids, [w.pathologist.uid]);
      assert.equal(c?.nextInviteExpiresAt, '');
    });

    it('is idempotent for the creator and refuses another primary’s reuse of the uid', async () => {
      const { conversationUid, caseUid } = await openMdt();
      const input = { conversationUid, caseUid, specialty: SPECIALTY, description: 'Again.' };
      assert.deepEqual(await openMdtHandler(deps, w.doctor, input), { conversationUid });
      assert.equal((await docData(w, `rateCounters/mdts:${w.doctor.uid}:${DAY_KEY}`))?.count, 1);
      await refusedWith(openMdtHandler(deps, w.pathologist, input), 'alreadyExists');
    });

    it('is only for the case’s own doctor or pathologist, and only for practitioners', async () => {
      const caseUid = await acceptedCase(w);
      const input = { conversationUid: newId(), caseUid, specialty: SPECIALTY, description: 'Look.' };
      await refusedWith(openMdtHandler(deps, w.colleague, input), 'notPrimaryViewer');
      await refusedWith(openMdtHandler(deps, w.otherPathologist, input), 'notPrimaryViewer');
      await refusedWith(openMdtHandler(deps, w.patient, input), 'notParticipant');
      await refusedWith(openMdtHandler(deps, w.doctor, { ...input, caseUid: newId() }), 'invalidConversation');
    });

    it('validates the id, the specialty, the description and the invitees', async () => {
      const caseUid = await acceptedCase(w);
      const base = { conversationUid: newId(), caseUid, specialty: SPECIALTY, description: 'Look.' };
      const open = (extra: Row) => openMdtHandler(deps, w.doctor, { ...base, ...extra });
      await refusedWith(open({ conversationUid: 'not-a-uuid' }), 'invalidConversation');
      await refusedWith(open({ specialty: 'Astrology' }), 'invalidSpecialty');
      await refusedWith(open({ description: '   ' }), 'invalidDescription');
      await refusedWith(open({ description: 42 }), 'invalidDescription');
      await refusedWith(open({ description: 'See <b>this</b>' }), 'invalidDescription');
      await refusedWith(open({ inviteeUids: [w.doctor.uid] }), 'invalidInvitee');
      await refusedWith(open({ inviteeUids: [w.colleague.uid, w.colleague.uid] }), 'invalidInvitee');
      await refusedWith(open({ inviteeUids: [w.patient.uid] }), 'invalidInvitee');
      await refusedWith(open({ inviteeUids: 'nobody' }), 'invalidInvitee');
      await refusedWith(open({ inviteeUids: Array.from({ length: 10 }, () => newId()) }), 'invalidInvitee');
      assert.equal(await conv(base.conversationUid), undefined);
    });

    it('allows ten a day and refuses the eleventh', async () => {
      await w.deps.db.doc(`rateCounters/mdts:${w.doctor.uid}:${DAY_KEY}`).set({ count: 10 });
      const caseUid = await acceptedCase(w);
      await refusedWith(
        openMdtHandler(deps, w.doctor, { conversationUid: newId(), caseUid, specialty: SPECIALTY, description: 'x' }),
        'rateLimited',
      );
    });

    it('refuses a case with no pathologist yet', async () => {
      const input = orderInput(w);
      await createOrderHandler(w.deps, w.doctor, input);
      await refusedWith(
        openMdtHandler(deps, w.doctor, {
          conversationUid: newId(),
          caseUid: input.caseUid,
          specialty: SPECIALTY,
          description: 'x',
        }),
        'conversationUnavailable',
      );
    });

    it('keeps the summary to an allow-list with no pre-read and no patient identifiers', async () => {
      const { conversationUid } = await openMdt();
      const summary = (await conv(conversationUid))?.caseSummary as Row;
      assert.deepEqual(Object.keys(summary).sort(), Object.keys(emptyCaseSummary()).sort());
      assert.equal(summary.caseRef, `MDT-${conversationUid.slice(0, 6).toUpperCase()}`);
      assert.equal(summary.ageBand, '30-39');
      assert.equal(summary.sex, 'Female');
      assert.equal(summary.reportStatus, 'Pending');
      assert.equal(summary.signedDiagnosisExcerpt, '');
      assert.ok((summary.testNames as string[]).length > 0);
      const text = JSON.stringify(await conv(conversationUid));
      for (const identifier of ['Amina', 'Otieno', '+254712345678', 'patient@example.com', 'record-1']) {
        assert.ok(!text.includes(identifier), `leaked ${identifier}`);
      }
    });

    it('carries only a signed report’s excerpt, scrubbed of the patient’s names', async () => {
      const signed = await signedCase(w);
      await w.deps.db
        .doc(`cases/${signed.caseUid}/reports/${signed.reportUid}`)
        .update({ diagnosis: 'Amina Otieno has invasive ductal carcinoma, call +254712345678.' });
      const conversationUid = newId();
      await openMdtHandler(deps, w.doctor, {
        conversationUid,
        caseUid: signed.caseUid,
        specialty: SPECIALTY,
        description: 'Signed result.',
      });
      const summary = (await conv(conversationUid))?.caseSummary as Row;
      assert.equal(summary.reportStatus, 'Signed');
      assert.equal(summary.reportLanguage, 'en');
      assert.ok(String(summary.signedByName).length > 0);
      assert.match(String(summary.signedDiagnosisExcerpt), /invasive ductal carcinoma/);
      assert.ok(!String(summary.signedDiagnosisExcerpt).includes('Amina'));
      assert.ok(!String(summary.signedDiagnosisExcerpt).includes('Otieno'));
      assert.ok(!String(summary.signedDiagnosisExcerpt).includes('254712345678'));
    });

    it('bands ages', () => {
      assert.equal(mdtAgeBand(0), '<1');
      assert.equal(mdtAgeBand(5), '1-9');
      assert.equal(mdtAgeBand(36), '30-39');
      assert.equal(mdtAgeBand(89), '80-89');
      assert.equal(mdtAgeBand(90), '90+');
    });
  });

  describe('inviteToMdt', () => {
    it('invites a new practitioner and moves the sweep marker', async () => {
      const { conversationUid } = await openMdt([]);
      assert.equal((await conv(conversationUid))?.nextInviteExpiresAt, '');
      await inviteToMdtHandler(deps, w.doctor, { conversationUid, inviteeUids: [w.colleague.uid] });
      const c = await conv(conversationUid);
      assert.equal(members(c)[w.colleague.uid].status, 'Invited');
      assert.equal(c?.nextInviteExpiresAt, new Date(Date.parse(NOW) + INVITE_TTL_MS).toISOString());
      assert.ok(await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.colleague.uid)));
    });

    it('starts a new round for someone who declined, left or expired', async () => {
      const { conversationUid } = await openMdt();
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: false });
      await inviteToMdtHandler(deps, w.doctor, { conversationUid, inviteeUids: [w.colleague.uid] });
      assert.equal(members(await conv(conversationUid))[w.colleague.uid].inviteRound, 2);
      assert.ok(await docData(w, noteId('mdtInvited', `${conversationUid}-r2`, w.colleague.uid)));
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: true });
      await leaveMdtHandler(deps, w.colleague, { conversationUid });
      await inviteToMdtHandler(deps, w.doctor, { conversationUid, inviteeUids: [w.colleague.uid] });
      assert.equal(members(await conv(conversationUid))[w.colleague.uid].inviteRound, 3);
    });

    it('refuses a live member, a non-owner, a closed group, the wrong kind and an empty list', async () => {
      const { conversationUid } = await acceptedMdt();
      const invite = (who = w.doctor, uids: unknown = [w.otherPathologist.uid], c = conversationUid) =>
        inviteToMdtHandler(deps, who, { conversationUid: c, inviteeUids: uids });
      await refusedWith(invite(w.doctor, [w.colleague.uid]), 'invalidInvitee');
      await refusedWith(invite(w.colleague), 'notParticipant');
      await refusedWith(invite(w.doctor, []), 'invalidInvitee');
      await refusedWith(invite(w.patient), 'notParticipant');
      await refusedWith(invite(w.doctor, [w.otherPathologist.uid], newId()), 'conversationUnavailable');
      await refusedWith(invite(w.doctor, [w.otherPathologist.uid], await direct()), 'invalidConversation');
      await closeConversationHandler(deps, w.doctor, { conversationUid });
      await refusedWith(invite(), 'conversationClosed');
    });

    it('stops at ten live members', async () => {
      const { conversationUid } = await openMdt([]);
      const crowd: Record<string, Row> = {};
      for (let i = 0; i < 9; i++) crowd[`extra${i}`] = { uid: `extra${i}`, status: 'Accepted' };
      await w.deps.db.doc(`conversations/${conversationUid}`).update({
        [`members.${w.doctor.uid}.status`]: 'Accepted',
        ...Object.fromEntries(Object.entries(crowd).map(([k, v]) => [`members.${k}`, v])),
      });
      await refusedWith(
        inviteToMdtHandler(deps, w.doctor, { conversationUid, inviteeUids: [w.colleague.uid] }),
        'tooManyMembers',
      );
    });
  });

  describe('respondToMdtInvite', () => {
    it('accepts: joins the participants, settles the invite and tells the owner', async () => {
      const { conversationUid } = await openMdt();
      assert.deepEqual(await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: true }), {
        status: 'Accepted',
      });
      const c = await conv(conversationUid);
      assert.equal(members(c)[w.colleague.uid].status, 'Accepted');
      assert.equal(members(c)[w.colleague.uid].inviteExpiresAt, '');
      assert.deepEqual([...(c?.participantUids as string[])].sort(), [w.doctor.uid, w.colleague.uid].sort());
      assert.equal(c?.nextInviteExpiresAt, '');
      const row = await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.colleague.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Accepted');
      assert.equal((row?.metadata as { actionedByUid: string }).actionedByUid, w.colleague.uid);
      assert.ok(await docData(w, noteId('mdtInviteAccepted', `${conversationUid}-r1`, w.doctor.uid)));
    });

    it('declines: stays out and tells the owner', async () => {
      const { conversationUid } = await openMdt();
      assert.deepEqual(await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: false }), {
        status: 'Declined',
      });
      const c = await conv(conversationUid);
      assert.equal(members(c)[w.colleague.uid].status, 'Declined');
      assert.deepEqual(c?.participantUids, [w.doctor.uid]);
      const row = await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.colleague.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Declined');
      assert.ok(await docData(w, noteId('mdtInviteDeclined', `${conversationUid}-r1`, w.doctor.uid)));
    });

    it('repeats the same answer but refuses the opposite one', async () => {
      const { conversationUid } = await openMdt();
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: true });
      assert.deepEqual(await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: true }), {
        status: 'Accepted',
      });
      await refusedWith(respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: false }), 'inviteClosed');
    });

    it('refuses an expired invite, a closed group, a stranger and a bad decision', async () => {
      const { conversationUid } = await openMdt();
      const late = ahead(deps, 8 * DAY_MS);
      await refusedWith(respondToMdtInviteHandler(late, w.colleague, { conversationUid, accept: true }), 'inviteClosed');
      await refusedWith(respondToMdtInviteHandler(deps, w.otherPathologist, { conversationUid, accept: true }), 'inviteClosed');
      await refusedWith(respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: 'yes' }), 'invalidDecision');
      await refusedWith(respondToMdtInviteHandler(deps, w.patient, { conversationUid, accept: true }), 'notParticipant');
      await closeConversationHandler(deps, w.doctor, { conversationUid });
      await refusedWith(respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: true }), 'inviteClosed');
    });
  });

  describe('leaveMdt and removeFromMdt', () => {
    it('lets an accepted member leave, once', async () => {
      const { conversationUid } = await acceptedMdt();
      assert.deepEqual(await leaveMdtHandler(deps, w.colleague, { conversationUid }), { status: 'Left' });
      const c = await conv(conversationUid);
      assert.equal(members(c)[w.colleague.uid].status, 'Left');
      assert.deepEqual(c?.participantUids, [w.doctor.uid]);
      assert.deepEqual(await leaveMdtHandler(deps, w.colleague, { conversationUid }), { status: 'Left' });
    });

    it('refuses the owner leaving, a stranger leaving and an invitee who has not joined', async () => {
      const { conversationUid } = await openMdt([w.colleague.uid]);
      await refusedWith(leaveMdtHandler(deps, w.doctor, { conversationUid }), 'invalidMember');
      await refusedWith(leaveMdtHandler(deps, w.otherPathologist, { conversationUid }), 'notParticipant');
      await refusedWith(leaveMdtHandler(deps, w.colleague, { conversationUid }), 'invalidMember');
      const directUid = await direct();
      await refusedWith(
        Promise.resolve().then(() => leaveMdtHandler(deps, w.colleague, { conversationUid: directUid })),
        'invalidConversation',
      );
    });

    it('lets the owner remove an accepted member or an open invite', async () => {
      const { conversationUid } = await openMdt([w.colleague.uid, w.otherPathologist.uid]);
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: true });
      assert.deepEqual(await removeFromMdtHandler(deps, w.doctor, { conversationUid, memberUid: w.colleague.uid }), {
        status: 'Removed',
      });
      let c = await conv(conversationUid);
      assert.equal(members(c)[w.colleague.uid].status, 'Removed');
      assert.deepEqual(c?.participantUids, [w.doctor.uid]);
      assert.notEqual(c?.nextInviteExpiresAt, '');
      await removeFromMdtHandler(deps, w.doctor, { conversationUid, memberUid: w.otherPathologist.uid });
      c = await conv(conversationUid);
      assert.equal(members(c)[w.otherPathologist.uid].status, 'Removed');
      assert.equal(c?.nextInviteExpiresAt, '');
    });

    it('refuses a removal by a non-owner, of the owner or of an unknown member', async () => {
      const { conversationUid } = await acceptedMdt();
      await refusedWith(
        removeFromMdtHandler(deps, w.colleague, { conversationUid, memberUid: w.doctor.uid }),
        'notParticipant',
      );
      await refusedWith(removeFromMdtHandler(deps, w.doctor, { conversationUid, memberUid: w.doctor.uid }), 'invalidMember');
      await refusedWith(removeFromMdtHandler(deps, w.doctor, { conversationUid, memberUid: newId() }), 'invalidMember');
    });
  });

  describe('closeConversation', () => {
    it('lets a group’s owner close it, and nobody else', async () => {
      const { conversationUid } = await acceptedMdt();
      await refusedWith(closeConversationHandler(deps, w.colleague, { conversationUid }), 'notParticipant');
      assert.deepEqual(await closeConversationHandler(deps, w.doctor, { conversationUid }), { status: 'Closed' });
      const c = await conv(conversationUid);
      assert.equal(c?.status, 'Closed');
      assert.equal(c?.closedAt, NOW);
      assert.deepEqual(await closeConversationHandler(deps, w.doctor, { conversationUid }), { status: 'Closed' });
    });

    it('lets the doctor of a direct thread close it, not the patient or the pathologist', async () => {
      const uid = await direct();
      await refusedWith(closeConversationHandler(deps, w.patient, { conversationUid: uid }), 'notParticipant');
      await refusedWith(closeConversationHandler(deps, w.pathologist, { conversationUid: uid }), 'notParticipant');
      await closeConversationHandler(deps, w.doctor, { conversationUid: uid });
      assert.equal((await conv(uid))?.status, 'Closed');
      await refusedWith(closeConversationHandler(deps, w.doctor, { conversationUid: newId() }), 'conversationUnavailable');
    });
  });

  describe('onMessageCreated', () => {
    it('ignores a message that is gone or already handled', async () => {
      const c = await direct();
      await onMessageCreatedHandler(deps, c, newId());
      const m = await post(c);
      await onMessageCreatedHandler(deps, c, m);
      await onMessageCreatedHandler(deps, c, m);
      assert.equal((await quota(w.doctor.uid))?.textMinuteCount, 1);
      assert.equal((await message(c, m))?.status, 'Delivered');
    });

    it('delivers a text, updates the thread and notifies the other side', async () => {
      const c = await direct();
      const m = await post(c, { text: 'x'.repeat(200) });
      await onMessageCreatedHandler(deps, c, m);
      const delivered = await message(c, m);
      assert.equal(delivered?.status, 'Delivered');
      assert.equal(delivered?.deliveredAt, NOW);
      const thread = await conv(c);
      const last = thread?.lastMessage as Row;
      assert.equal(last.uid, m);
      assert.equal(last.senderUid, w.doctor.uid);
      assert.equal(last.sentAt, SENT);
      assert.equal(String(last.text).length, 120);
      assert.equal(last.hasAttachment, false);
      assert.equal(thread?.lastMessageAt, SENT);
      const row = await docData(w, noteId('messageReceived', c, w.patient.uid));
      assert.equal(row?.recipientRole, 'patient');
      assert.deepEqual(row?.templateArgs, { newCount: '1' });
      assert.equal(await docData(w, noteId('messageReceived', c, w.doctor.uid)), undefined);
      assert.equal((await quota(w.doctor.uid))?.textDayCount, 1);
      assert.equal((await quota(w.doctor.uid))?.textDay, DAY_KEY);
    });

    it('collapses further messages into one counted notification and keeps the newest as last', async () => {
      const c = await direct();
      const first = await post(c, { sentAt: '2026-10-27T08:59:00.000Z', text: 'first' });
      const second = await post(c, { sentAt: '2026-10-27T08:59:20.000Z', text: 'second' });
      const older = await post(c, { sentAt: '2026-10-27T08:58:00.000Z', text: 'older' });
      for (const m of [first, second, older]) await onMessageCreatedHandler(deps, c, m);
      const row = await docData(w, noteId('messageReceived', c, w.patient.uid));
      assert.deepEqual(row?.templateArgs, { newCount: '3' });
      assert.equal(((await conv(c))?.lastMessage as Row).text, 'second');
    });

    it('tells only the accepted members of a group, with the group template', async () => {
      const { conversationUid: c } = await openMdt([w.colleague.uid, w.otherPathologist.uid]);
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid: c, accept: true });
      await onMessageCreatedHandler(deps, c, await post(c));
      assert.ok(await docData(w, noteId('mdtMessageReceived', c, w.colleague.uid)));
      assert.equal(await docData(w, noteId('mdtMessageReceived', c, w.otherPathologist.uid)), undefined);
      assert.equal(await docData(w, noteId('mdtMessageReceived', c, w.doctor.uid)), undefined);
      assert.equal(await docData(w, noteId('messageReceived', c, w.colleague.uid)), undefined);
    });

    describe('quota and withholding', () => {
      const withheld = async (c: string, m: string, reason: string) => {
        const doc = await message(c, m);
        assert.equal(doc?.status, 'Withheld');
        assert.equal(doc?.withheldReason, reason);
        assert.equal(await docData(w, noteId('messageReceived', c, w.patient.uid)), undefined);
        assert.equal(((await conv(c))?.lastMessage as Row).uid, '');
      };

      it('allows thirty a minute and withholds the thirty-first, blocking the sender', async () => {
        const c = await direct();
        await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({ textMinuteStart: NOW, textMinuteCount: 29 });
        const thirtieth = await post(c);
        await onMessageCreatedHandler(deps, c, thirtieth);
        assert.equal((await message(c, thirtieth))?.status, 'Delivered');
        const thirtyFirst = await post(c, { sentAt: '2026-10-27T08:59:40.000Z' });
        await onMessageCreatedHandler(deps, c, thirtyFirst);
        const doc = await message(c, thirtyFirst);
        assert.equal(doc?.status, 'Withheld');
        assert.equal(doc?.withheldReason, 'rateLimited');
        const q = await quota(w.doctor.uid);
        assert.equal(q?.blocked, true);
        assert.equal(q?.blockedUntil, new Date(Date.parse(NOW) + 15 * MINUTE_MS).toISOString());
        assert.deepEqual(
          ((await docData(w, noteId('messageReceived', c, w.patient.uid)))?.templateArgs),
          { newCount: '1' },
        );
        assert.equal(((await conv(c))?.lastMessage as Row).uid, thirtieth);
      });

      it('starts a fresh minute once the window has passed', async () => {
        const c = await direct();
        await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({
          textMinuteStart: '2026-10-27T08:58:00.000Z',
          textMinuteCount: 30,
        });
        const m = await post(c);
        await onMessageCreatedHandler(deps, c, m);
        assert.equal((await message(c, m))?.status, 'Delivered');
        assert.equal((await quota(w.doctor.uid))?.textMinuteCount, 1);
      });

      it('withholds past six hundred a day and resets on the next day', async () => {
        const c = await direct();
        await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({ textDay: DAY_KEY, textDayCount: 600 });
        const over = await post(c);
        await onMessageCreatedHandler(deps, c, over);
        await withheld(c, over, 'rateLimited');
        await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({ textDay: '20261026', textDayCount: 600 });
        const next = await post(c, { sentAt: '2026-10-27T08:59:40.000Z' });
        await onMessageCreatedHandler(deps, c, next);
        assert.equal((await message(c, next))?.status, 'Delivered');
        assert.equal((await quota(w.doctor.uid))?.textDayCount, 1);
      });

      it('counts each sender on their own', async () => {
        const c = await direct();
        await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({ textMinuteStart: NOW, textMinuteCount: 30 });
        const m = await post(c, { senderUid: w.patient.uid });
        await onMessageCreatedHandler(deps, c, m);
        assert.equal((await message(c, m))?.status, 'Delivered');
        assert.ok(await docData(w, noteId('messageReceived', c, w.doctor.uid)));
      });

      it('withholds a message stamped well into the future', async () => {
        const c = await direct();
        const m = await post(c, { sentAt: '2026-10-27T09:10:00.000Z' });
        await onMessageCreatedHandler(deps, c, m);
        await withheld(c, m, 'rateLimited');
        const near = await post(c, { sentAt: '2026-10-27T09:01:00.000Z' });
        await onMessageCreatedHandler(deps, c, near);
        assert.equal((await message(c, near))?.status, 'Delivered');
      });
    });

    describe('voice notes', () => {
      it('measures, delivers and writes the machine transcript beside the message', async () => {
        const c = await direct();
        const m = await deliverVoice(c, { claimedMs: 5_000 });
        const doc = await message(c, m);
        assert.equal(doc?.status, 'Delivered');
        assert.equal(doc?.voiceDurationMs, 30_000);
        assert.equal(doc?.transcriptStatus, 'Ready');
        assert.equal(doc?.transcriptLanguage, 'sw');
        assert.equal(doc?.identifierFlagged, false);
        assert.equal(doc?.text, '');
        const machine = await transcript(c, m, 'machine');
        assert.equal(machine?.text, MACHINE_TEXT);
        assert.equal(machine?.language, 'sw');
        assert.equal(machine?.senderUid, w.doctor.uid);
        assert.equal(machine?.acceptedUnchanged, false);
        assert.equal(machine?.sharedAt, '');
        assert.deepEqual(machine?.models, { stub: 'fixture' });
        assert.equal(await transcript(c, m, 'shared'), undefined);
        assert.equal(await signal('voiceTranscriptReady'), 1);
        const q = await quota(w.doctor.uid);
        assert.equal(q?.voiceHourCount, 1);
        assert.equal(q?.voiceDayMs, 30_000);
        assert.ok(await docData(w, noteId('messageReceived', c, w.patient.uid)));
        assert.equal(((await conv(c))?.lastMessage as Row).hasAttachment, true);
      });

      it('sends the model the audio and nothing else', async () => {
        const c = await direct();
        let seen: unknown;
        const spying = ai((req) => {
          seen = req;
          return Promise.resolve({ transcript: 'ok', language: 'en', models: {} });
        });
        const m = await postVoice(c);
        await onMessageCreatedHandler(spying, c, m);
        assert.deepEqual(Object.keys(seen as object).sort(), ['bytes', 'contentType']);
      });

      it('transcribes once, however often the trigger fires', async () => {
        const c = await direct();
        let calls = 0;
        const counting = ai(() => {
          calls += 1;
          return Promise.resolve({ transcript: 'ok', language: 'en', models: {} });
        });
        const m = await postVoice(c);
        await onMessageCreatedHandler(counting, c, m);
        await onMessageCreatedHandler(counting, c, m);
        assert.equal(calls, 1);
        assert.equal((await quota(w.doctor.uid))?.voiceHourCount, 1);
      });

      it('finishes the transcript of a note a retry finds delivered but still queued', async () => {
        const c = await direct();
        const m = await postVoice(c, { extra: { status: 'Delivered', deliveredAt: NOW } });
        await onMessageCreatedHandler(deps, c, m);
        const doc = await message(c, m);
        assert.equal(doc?.transcriptStatus, 'Ready');
        assert.equal(doc?.status, 'Delivered');
        assert.equal((await transcript(c, m, 'machine'))?.text, MACHINE_TEXT);
        // Phase 1 did not run again: no quota was spent and nobody was told twice.
        assert.equal(await quota(w.doctor.uid), undefined);
      });

      it('leaves a delivered text, and a note with no transcript to make, alone', async () => {
        const c = await direct();
        const text = await post(c, { status: 'Delivered', deliveredAt: NOW });
        const done = await postVoice(c, { extra: { status: 'Delivered', deliveredAt: NOW, transcriptStatus: 'Failed' } });
        await onMessageCreatedHandler(deps, c, text);
        await onMessageCreatedHandler(deps, c, done);
        assert.equal((await message(c, done))?.transcriptStatus, 'Failed');
        assert.equal(await transcript(c, done, 'machine'), undefined);
      });

      it('withholds a note whose audio never arrived', async () => {
        const c = await direct();
        let calls = 0;
        const counting = ai(() => {
          calls += 1;
          return Promise.resolve({ transcript: 'ok', language: 'en', models: {} });
        });
        const m = await postVoice(c, { bytes: null });
        await onMessageCreatedHandler(counting, c, m);
        const doc = await message(c, m);
        assert.equal(doc?.status, 'Withheld');
        assert.equal(doc?.withheldReason, 'missingAudio');
        assert.equal(doc?.transcriptStatus, 'Queued');
        assert.equal(calls, 0);
        assert.equal(await transcript(c, m, 'machine'), undefined);
        assert.equal(await docData(w, noteId('messageReceived', c, w.patient.uid)), undefined);
        assert.equal(((await conv(c))?.lastMessage as Row).uid, '');
      });

      it('withholds a note that runs past two minutes, however short it claims to be', async () => {
        const c = await direct();
        const long = await deliverVoice(c, { bytes: m4aOf(121), claimedMs: 10_000 });
        assert.equal((await message(c, long))?.withheldReason, 'voiceTooLong');
        const edge = await deliverVoice(c, { bytes: m4aOf(120.4) });
        assert.equal((await message(c, edge))?.status, 'Delivered');
        assert.equal((await message(c, edge))?.voiceDurationMs, 120_400);
        assert.equal(await transcript(c, long, 'machine'), undefined);
      });

      it('withholds a file that is not audio or is too large', async () => {
        const c = await direct();
        const wrongType = await deliverVoice(c, { contentType: 'audio/wav' });
        assert.equal((await message(c, wrongType))?.withheldReason, 'voiceTooLong');
        const big = await deliverVoice(c, { bytes: Buffer.alloc(512 * 1024 + 1) });
        assert.equal((await message(c, big))?.withheldReason, 'voiceTooLong');
      });

      it('falls back on the claimed length when the file has no header, within its bound', async () => {
        const c = await direct();
        const ok = await deliverVoice(c, { bytes: Buffer.from('audio'), claimedMs: 60_000 });
        assert.equal((await message(c, ok))?.voiceDurationMs, 60_000);
        const none = await deliverVoice(c, { bytes: Buffer.from('audio'), claimedMs: 0 });
        assert.equal((await message(c, none))?.withheldReason, 'voiceTooLong');
        const over = await deliverVoice(c, { bytes: Buffer.from('audio'), claimedMs: 130_000 });
        assert.equal((await message(c, over))?.withheldReason, 'voiceTooLong');
      });

      it('measures a version 1 movie header and nothing without one', () => {
        const bytes = Buffer.alloc(48);
        bytes.write('mvhd', 4, 'latin1');
        bytes[8] = 1;
        bytes.writeUInt32BE(1000, 28);
        bytes.writeBigUInt64BE(BigInt(2500), 32);
        assert.equal(measureM4aMs(bytes), 2500);
        assert.equal(measureM4aMs(Buffer.from('nothing here')), null);
        assert.equal(measureM4aMs(Buffer.alloc(10)), null);
      });

      it('withholds a twenty-first note in an hour and blocks voice, not text', async () => {
        const c = await direct();
        await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({ voiceHourStart: NOW, voiceHourCount: 19 });
        const twentieth = await deliverVoice(c);
        assert.equal((await message(c, twentieth))?.status, 'Delivered');
        const over = await deliverVoice(c);
        const doc = await message(c, over);
        assert.equal(doc?.status, 'Withheld');
        assert.equal(doc?.withheldReason, 'rateLimited');
        assert.equal(await transcript(c, over, 'machine'), undefined);
        const q = await quota(w.doctor.uid);
        assert.equal(q?.voiceBlocked, true);
        assert.equal(q?.voiceBlockedUntil, new Date(Date.parse(NOW) + 15 * MINUTE_MS).toISOString());
        assert.notEqual(q?.blocked, true);
      });

      it('withholds a note that would pass thirty minutes of audio in a day', async () => {
        const c = await direct();
        await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({ voiceDay: DAY_KEY, voiceDayMs: 30 * MINUTE_MS - 30_000 });
        const fits = await deliverVoice(c);
        assert.equal((await message(c, fits))?.status, 'Delivered');
        const over = await deliverVoice(c, { bytes: m4aOf(1) });
        assert.equal((await message(c, over))?.withheldReason, 'rateLimited');
      });

      it('delivers but does not transcribe when the voice switch is off', async () => {
        const c = await direct();
        let calls = 0;
        const off = runtime(w, {
          config: allOff,
          ai: {
            ...deps.ai!,
            transcribeAudio: () => {
              calls += 1;
              return Promise.resolve({ transcript: 'ok', language: 'en', models: {} });
            },
          },
        });
        const m = await postVoice(c);
        await onMessageCreatedHandler(off, c, m);
        const doc = await message(c, m);
        assert.equal(doc?.status, 'Delivered');
        assert.equal(doc?.transcriptStatus, 'None');
        assert.equal(calls, 0);
        assert.equal(await transcript(c, m, 'machine'), undefined);
      });

      it('marks the transcript Failed, and still delivers, when the model fails or says nothing', async () => {
        const c = await direct();
        const failing = ai(() => Promise.reject(new Error('down')));
        const first = await postVoice(c);
        await onMessageCreatedHandler(failing, c, first);
        assert.equal((await message(c, first))?.status, 'Delivered');
        assert.equal((await message(c, first))?.transcriptStatus, 'Failed');
        assert.equal(await transcript(c, first, 'machine'), undefined);
        const silent = ai(() => Promise.resolve({ transcript: '   ', language: 'en', models: {} }));
        const second = await postVoice(c);
        await onMessageCreatedHandler(silent, c, second);
        assert.equal((await message(c, second))?.transcriptStatus, 'Failed');
        const missing = runtime(w, { ai: { ...deps.ai!, transcribeAudio: undefined } });
        const third = await postVoice(c);
        await onMessageCreatedHandler(missing, c, third);
        assert.equal((await message(c, third))?.transcriptStatus, 'Failed');
        assert.equal(await signal('voiceTranscriptFailed'), 3);
        assert.equal(await signal('voiceTranscriptReady'), undefined);
      });

      it('keeps only a known language', async () => {
        const c = await direct();
        const odd = ai(() => Promise.resolve({ transcript: 'bonjour', language: 'fr', models: {} }));
        const m = await postVoice(c);
        await onMessageCreatedHandler(odd, c, m);
        assert.equal((await transcript(c, m, 'machine'))?.language, '');
        assert.equal((await message(c, m))?.transcriptLanguage, '');
      });

      it('does not bring a withdrawn message’s transcript back', async () => {
        const c = await direct();
        const m = await postVoice(c);
        const racing = ai(async () => {
          await withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: m });
          return { transcript: MACHINE_TEXT, language: 'sw', models: {} };
        });
        await onMessageCreatedHandler(racing, c, m);
        assert.equal((await message(c, m))?.withheldReason, 'withdrawn');
        assert.equal(await transcript(c, m, 'machine'), undefined);
      });
    });

    describe('transcripts and the patient', () => {
      it('writes only the machine document, and nothing a patient can read, when a doctor sends a note', async () => {
        const c = await direct();
        const m = await deliverVoice(c);
        const written = await w.deps.db.collection(`conversations/${c}/messages/${m}/transcript`).get();
        assert.deepEqual(
          written.docs.map((d) => d.id),
          ['machine'],
        );
        assert.ok(!JSON.stringify(await message(c, m)).includes(MACHINE_TEXT));
        assert.ok(!JSON.stringify(await conv(c)).includes(MACHINE_TEXT));
        const rows = await w.deps.db.collection('notifications').where('recipientUid', '==', w.patient.uid).get();
        assert.ok(rows.size > 0);
        assert.ok(!JSON.stringify(rows.docs.map((d) => d.data())).includes(MACHINE_TEXT));
      });

      it('cannot be shared by a patient, even the sender of the note', async () => {
        const c = await direct();
        const m = await deliverVoice(c, { sender: w.patient.uid });
        assert.equal((await transcript(c, m, 'machine'))?.senderUid, w.patient.uid);
        await refusedWith(
          shareTranscriptHandler(deps, w.patient, { conversationUid: c, messageUid: m, decision: 'Approve' }),
          'notParticipant',
        );
        assert.equal(await transcript(c, m, 'shared'), undefined);
        assert.equal((await message(c, m))?.transcriptShared, false);
      });
    });

    describe('identifier flag in a group', () => {
      it('flags a transcript that names the patient and leaves a clean one unflagged', async () => {
        const { conversationUid: c } = await acceptedMdt();
        const named = ai(() =>
          Promise.resolve({ transcript: 'This is Amina Otieno, call +254712345678.', language: 'en', models: {} }),
        );
        const flagged = await postVoice(c);
        await onMessageCreatedHandler(named, c, flagged);
        assert.equal((await message(c, flagged))?.identifierFlagged, true);
        assert.equal((await message(c, flagged))?.transcriptStatus, 'Ready');
        const clean = await deliverVoice(c);
        assert.equal((await message(c, clean))?.identifierFlagged, false);
      });

      it('flags a transcript that carries a date, which can identify when someone was seen', async () => {
        const { conversationUid: c } = await acceptedMdt();
        const dated = ai(() =>
          Promise.resolve({ transcript: 'The biopsy was taken on 14 May 2026.', language: 'en', models: {} }),
        );
        const m = await postVoice(c);
        await onMessageCreatedHandler(dated, c, m);
        assert.equal((await message(c, m))?.identifierFlagged, true);
        const iso = ai(() => Promise.resolve({ transcript: 'Seen on 2026-05-14.', language: 'en', models: {} }));
        const n = await postVoice(c);
        await onMessageCreatedHandler(iso, c, n);
        assert.equal((await message(c, n))?.identifierFlagged, true);
      });

      it('does not look for the patient in a direct thread', async () => {
        const c = await direct();
        const named = ai(() => Promise.resolve({ transcript: 'Amina Otieno', language: 'en', models: {} }));
        const m = await postVoice(c);
        await onMessageCreatedHandler(named, c, m);
        assert.equal((await message(c, m))?.identifierFlagged, false);
      });
    });
  });

  describe('withdrawMessage', () => {
    it('deletes the object and both transcripts and clears the thread’s last message', async () => {
      const c = await direct();
      const m = await deliverVoice(c);
      await shareTranscriptHandler(deps, w.doctor, { conversationUid: c, messageUid: m, decision: 'Approve' });
      const path = `conversations/${c}/voice/${m}.m4a`;
      assert.ok(await objectExists(path));
      assert.ok(await transcript(c, m, 'machine'));
      assert.ok(await transcript(c, m, 'shared'));

      assert.deepEqual(await withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: m }), {
        status: 'Withdrawn',
      });
      assert.equal(await objectExists(path), false);
      assert.equal(await transcript(c, m, 'machine'), undefined);
      assert.equal(await transcript(c, m, 'shared'), undefined);
      const doc = await message(c, m);
      assert.equal(doc?.status, 'Withheld');
      assert.equal(doc?.withheldReason, 'withdrawn');
      assert.equal(doc?.text, '');
      assert.equal(doc?.transcriptShared, false);
      assert.equal(doc?.identifierFlagged, false);
      assert.equal(((await conv(c))?.lastMessage as Row).uid, '');
    });

    it('clears a text and leaves a later last message alone', async () => {
      const c = await direct();
      const first = await post(c, { sentAt: '2026-10-27T08:58:00.000Z' });
      const second = await post(c, { sentAt: '2026-10-27T08:59:00.000Z' });
      await onMessageCreatedHandler(deps, c, first);
      await onMessageCreatedHandler(deps, c, second);
      await withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: first });
      assert.equal((await message(c, first))?.text, '');
      assert.equal(((await conv(c))?.lastMessage as Row).uid, second);
    });

    it('lets a patient withdraw their own message and is idempotent', async () => {
      const c = await direct();
      const m = await post(c, { senderUid: w.patient.uid });
      await onMessageCreatedHandler(deps, c, m);
      await withdrawMessageHandler(deps, w.patient, { conversationUid: c, messageUid: m });
      assert.deepEqual(await withdrawMessageHandler(deps, w.patient, { conversationUid: c, messageUid: m }), {
        status: 'Withdrawn',
      });
    });

    it('refuses another sender, a message not delivered and one past fifteen minutes', async () => {
      const c = await direct();
      const m = await post(c);
      await onMessageCreatedHandler(deps, c, m);
      await refusedWith(withdrawMessageHandler(deps, w.patient, { conversationUid: c, messageUid: m }), 'invalidMessage');
      await refusedWith(withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: newId() }), 'invalidMessage');
      await refusedWith(withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: 'nope' }), 'invalidMessage');
      const waiting = await post(c);
      await refusedWith(withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: waiting }), 'notDelivered');
      const late = ahead(deps, 16 * MINUTE_MS);
      await refusedWith(withdrawMessageHandler(late, w.doctor, { conversationUid: c, messageUid: m }), 'withdrawWindowClosed');
      const justInside = ahead(deps, 15 * MINUTE_MS);
      await withdrawMessageHandler(justInside, w.doctor, { conversationUid: c, messageUid: m });
    });

    it('stops, and keeps the message, when the object cannot be deleted', async () => {
      const c = await direct();
      const m = await deliverVoice(c);
      const broken = {
        bucket: () => ({ file: () => ({ delete: () => Promise.reject(new Error('storage down')) }) }),
      } as unknown as StorageLike;
      await assert.rejects(
        withdrawMessageHandler(runtime(w, { storage: broken }), w.doctor, { conversationUid: c, messageUid: m }),
        /storage down/,
      );
      assert.equal((await message(c, m))?.status, 'Delivered');
      assert.ok(await transcript(c, m, 'machine'));
      assert.ok(await objectExists(`conversations/${c}/voice/${m}.m4a`));
    });

    it('counts an object that is already gone as deleted', async () => {
      const c = await direct();
      const m = await deliverVoice(c);
      await bucket().file(`conversations/${c}/voice/${m}.m4a`).delete();
      await withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: m });
      assert.equal((await message(c, m))?.withheldReason, 'withdrawn');
    });
  });

  describe('shareTranscript', () => {
    const share = (c: string, m: string, extra: Row = {}, who = w.doctor) =>
      shareTranscriptHandler(deps, who, { conversationUid: c, messageUid: m, decision: 'Approve', ...extra });

    it('shares the machine text unchanged and records acceptedUnchanged', async () => {
      const c = await direct();
      const m = await deliverVoice(c);
      assert.deepEqual(await share(c, m), { status: 'Shared' });
      const shared = await transcript(c, m, 'shared');
      assert.equal(shared?.text, MACHINE_TEXT);
      assert.equal(shared?.acceptedUnchanged, true);
      assert.equal(shared?.editDistance, 0);
      assert.equal(shared?.language, 'sw');
      assert.equal(shared?.senderUid, w.doctor.uid);
      assert.equal(shared?.sharedAt, NOW);
      assert.deepEqual(shared?.models, {});
      assert.equal((await message(c, m))?.transcriptShared, true);
      assert.equal((await transcript(c, m, 'machine'))?.text, MACHINE_TEXT);
      assert.equal(await signal('voiceTranscriptShared'), 1);
      assert.equal(await signal('voiceTranscriptSharedUnchanged'), 1);
    });

    it('shares an edit with its distance and no unchanged signal', async () => {
      const c = await direct();
      const m = await deliverVoice(c);
      await share(c, m, { decision: 'ApproveEdited', text: 'Nina maumivu makali ya kichwa.' });
      const shared = await transcript(c, m, 'shared');
      assert.equal(shared?.text, 'Nina maumivu makali ya kichwa.');
      assert.equal(shared?.acceptedUnchanged, false);
      assert.ok(Number(shared?.editDistance) > 0);
      assert.equal((await transcript(c, m, 'machine'))?.text, MACHINE_TEXT);
      assert.equal(await signal('voiceTranscriptShared'), 1);
      assert.equal(await signal('voiceTranscriptSharedUnchanged'), undefined);
    });

    it('shares once: a second call changes nothing and counts nothing', async () => {
      const c = await direct();
      const m = await deliverVoice(c);
      await share(c, m);
      assert.deepEqual(await share(c, m, { decision: 'ApproveEdited', text: 'Different.' }), { status: 'Shared' });
      assert.equal((await transcript(c, m, 'shared'))?.text, MACHINE_TEXT);
      assert.equal(await signal('voiceTranscriptShared'), 1);
    });

    it('works inside a group for a practitioner sender', async () => {
      const { conversationUid: c } = await acceptedMdt();
      const m = await deliverVoice(c, { sender: w.colleague.uid });
      await share(c, m, {}, w.colleague);
      assert.equal((await transcript(c, m, 'shared'))?.senderUid, w.colleague.uid);
    });

    it('refuses before the transcript is ready, after a withdrawal and for the wrong message', async () => {
      const c = await direct();
      const queued = await postVoice(c);
      await refusedWith(share(c, queued), 'transcriptNotReady');
      const delivered = await deliverVoice(c);
      await refusedWith(share(c, delivered, {}, w.colleague), 'invalidMessage');
      const text = await post(c);
      await refusedWith(share(c, text), 'invalidMessage');
      await refusedWith(share(c, newId()), 'invalidMessage');
      await withdrawMessageHandler(deps, w.doctor, { conversationUid: c, messageUid: delivered });
      await refusedWith(share(c, delivered), 'transcriptNotReady');
      assert.equal(await transcript(c, delivered, 'shared'), undefined);
    });

    it('refuses a bad decision, an edit with no text and a stranger', async () => {
      const c = await direct();
      const m = await deliverVoice(c);
      await refusedWith(share(c, m, { decision: 'Reject' }), 'invalidDecision');
      await refusedWith(share(c, m, { decision: 'ApproveEdited' }), 'invalidText');
      await refusedWith(share(c, m, { decision: 'ApproveEdited', text: '  ' }), 'invalidText');
      await refusedWith(share(c, 'not-a-uuid'), 'invalidMessage');
      await refusedWith(shareTranscriptHandler(deps, null, { conversationUid: c, messageUid: m, decision: 'Approve' }), 'unauthenticated');
      assert.equal(await transcript(c, m, 'shared'), undefined);
    });
  });

  describe('sweepConversations', () => {
    it('expires an invite past its week, settles its row and clears the marker', async () => {
      const { conversationUid } = await openMdt([w.colleague.uid, w.otherPathologist.uid]);
      await respondToMdtInviteHandler(deps, w.otherPathologist, { conversationUid, accept: true });
      assert.equal((await sweepConversationsHandler(ahead(deps, 6 * DAY_MS))).invitesExpired, 0);
      const result = await sweepConversationsHandler(ahead(deps, 8 * DAY_MS));
      assert.equal(result.invitesExpired, 1);
      const c = await conv(conversationUid);
      assert.equal(members(c)[w.colleague.uid].status, 'Expired');
      assert.equal(members(c)[w.otherPathologist.uid].status, 'Accepted');
      assert.equal(c?.nextInviteExpiresAt, '');
      assert.deepEqual([...(c?.participantUids as string[])].sort(), [w.doctor.uid, w.otherPathologist.uid].sort());
      const row = await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.colleague.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Expired');
      assert.equal((await sweepConversationsHandler(ahead(deps, 8 * DAY_MS))).invitesExpired, 0);
    });

    it('lifts a sender’s block once it has run out', async () => {
      const c = await direct();
      await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({ textMinuteStart: NOW, textMinuteCount: 30 });
      await onMessageCreatedHandler(deps, c, await post(c));
      assert.equal((await quota(w.doctor.uid))?.blocked, true);
      assert.equal((await sweepConversationsHandler(ahead(deps, 10 * MINUTE_MS))).quotasUnblocked, 0);
      assert.equal((await sweepConversationsHandler(ahead(deps, 16 * MINUTE_MS))).quotasUnblocked, 1);
      const q = await quota(w.doctor.uid);
      assert.equal(q?.blocked, false);
      assert.equal(q?.blockedUntil, '');
    });

    it('lifts a voice block on its own', async () => {
      await w.deps.db.doc(`messageQuotas/${w.doctor.uid}`).set({
        voiceBlocked: true,
        voiceBlockedUntil: '2026-10-27T08:00:00.000Z',
      });
      assert.equal((await sweepConversationsHandler(deps)).quotasUnblocked, 1);
      assert.equal((await quota(w.doctor.uid))?.voiceBlocked, false);
    });

    it('fails a transcript stuck running for ten minutes and leaves a fresh one', async () => {
      const c = await direct();
      const stuck = await post(c, { transcriptStatus: 'Running', lastUpdatedAt: '2026-10-27T08:40:00.000Z' });
      const fresh = await post(c, { transcriptStatus: 'Running', lastUpdatedAt: '2026-10-27T08:55:00.000Z' });
      const result = await sweepConversationsHandler(deps);
      assert.equal(result.transcriptsFailed, 1);
      assert.equal((await message(c, stuck))?.transcriptStatus, 'Failed');
      assert.equal((await message(c, fresh))?.transcriptStatus, 'Running');
      assert.equal(await signal('voiceTranscriptFailed'), 1);
      assert.equal((await sweepConversationsHandler(deps)).transcriptsFailed, 0);
    });

    it('deletes an upload with no message after a day and keeps everything else', async () => {
      const c = newId();
      const orphanVoice = `conversations/${c}/voice/${newId()}.m4a`;
      const orphanImage = `conversations/${c}/images/${newId()}/image.jpg`;
      const kept = `conversations/${c}/voice/${newId()}.m4a`;
      const stray = `conversations/${c}/notes.txt`;
      await putObject(orphanVoice, Buffer.from('a'), 'audio/mp4');
      await putObject(orphanImage, Buffer.from('i'), 'image/jpeg');
      await putObject(kept, Buffer.from('k'), 'audio/mp4');
      await putObject(stray, Buffer.from('s'), 'text/plain');
      const keptUid = kept.split('/').pop()!.replace('.m4a', '');
      await w.deps.db.doc(`conversations/${c}/messages/${keptUid}`).set({ uid: keptUid, status: 'Sent' });

      const fresh = await sweepConversationsHandler(runtime(w, { now: () => new Date() }));
      assert.equal(fresh.mediaDeleted, 0);
      assert.ok(await objectExists(orphanVoice));

      const old = await sweepConversationsHandler(farAhead(deps, 2 * DAY_MS));
      assert.equal(old.mediaDeleted, 2);
      assert.equal(await objectExists(orphanVoice), false);
      assert.equal(await objectExists(orphanImage), false);
      assert.ok(await objectExists(kept));
      assert.ok(await objectExists(stray));
    });

    it('deletes the media of a withheld message after a day, and not before', async () => {
      const c = await direct();
      const uid = newId();
      const path = `conversations/${c}/voice/${uid}.m4a`;
      await putObject(path, Buffer.from('w'), 'audio/mp4');
      await w.deps.db.doc(`conversations/${c}/messages/${uid}`).set({ uid, status: 'Withheld' });
      assert.equal((await sweepConversationsHandler(runtime(w, { now: () => new Date() }))).mediaDeleted, 0);
      assert.ok(await objectExists(path));
      assert.equal((await sweepConversationsHandler(farAhead(deps, 2 * DAY_MS))).mediaDeleted, 1);
      assert.equal(await objectExists(path), false);
    });

    it('reaches an orphan beyond the first pages of a bucket full of live media', async function () {
      this.timeout(240_000);
      const c = newId();
      const uids = Array.from({ length: 2 * MEDIA_PAGE + 1 }, () => newId());
      for (let i = 0; i < uids.length; i += 50) {
        await Promise.all(
          uids.slice(i, i + 50).map((uid) => putObject(`conversations/${c}/voice/${uid}.m4a`, Buffer.from('v'), 'audio/mp4')),
        );
      }
      for (let i = 0; i < uids.length; i += 400) {
        const batch = w.deps.db.batch();
        for (const uid of uids.slice(i, i + 400)) {
          batch.set(w.deps.db.doc(`conversations/${c}/messages/${uid}`), { uid, status: 'Delivered' });
        }
        await batch.commit();
      }
      // Sorted after every uuid, so it is on the last page.
      const orphan = `conversations/zz-${newId()}/voice/${newId()}.m4a`;
      await putObject(orphan, Buffer.from('o'), 'audio/mp4');

      const runs = Math.ceil((uids.length + 1) / MEDIA_PAGE);
      let deleted = 0;
      for (let i = 0; i < runs; i += 1) deleted += (await sweepConversationsHandler(farAhead(deps, 2 * DAY_MS))).mediaDeleted;

      assert.equal(deleted, 1);
      assert.equal(await objectExists(orphan), false);
      assert.ok(await objectExists(`conversations/${c}/voice/${uids[0]}.m4a`));
      assert.ok(await objectExists(`conversations/${c}/voice/${uids[uids.length - 1]}.m4a`));
      // The walk started over at the end of the bucket: the cursor is empty again.
      assert.equal((await docData(w, 'rateCounters/sweep:conversationMedia'))?.pageToken, '');
    });

    it('reports an empty run', async () => {
      assert.deepEqual(await sweepConversationsHandler(deps), {
        invitesExpired: 0,
        quotasUnblocked: 0,
        transcriptsFailed: 0,
        mediaDeleted: 0,
      });
    });
  });

  describe('when someone’s place on a case ends (F-18)', () => {
    const ids = (c: Row | undefined) => [...((c?.participantUids ?? []) as string[])].sort();
    const sorted = (...uids: string[]) => [...uids].sort();
    /** The rule for posting: an open thread the person is a participant of. */
    const canPost = (c: Row | undefined, uid: string) => c?.status === 'Open' && ids(c).includes(uid);
    const canRead = (c: Row | undefined, uid: string) => ids(c).includes(uid);
    const invite = (uid: string, c: string, round = 1) => docData(w, noteId('mdtInvited', `${c}-r${round}`, uid));
    const actionStatus = (row: Row | undefined) => (row?.metadata as { actionStatus: string }).actionStatus;

    async function mdtOn(caseUid: string, owner: Caller, invitees: string[], specialty: string = SPECIALTY): Promise<string> {
      const conversationUid = newId();
      await openMdtHandler(deps, owner, {
        conversationUid,
        caseUid,
        specialty,
        description: 'Please look at this lesion with me.',
        inviteeUids: invitees,
      });
      return conversationUid;
    }

    async function directOn(caseUid: string): Promise<string> {
      const { conversationUid } = await openDirectConversationHandler(deps, w.doctor, {
        resourceType: 'Order',
        resourceUid: caseUid,
      });
      return conversationUid;
    }

    it('closes a reassigned pathologist’s thread, the groups they own, and takes them out of the rest', async () => {
      const caseUid = await acceptedCase(w);
      const thread = await directOn(caseUid);
      const owned = await mdtOn(caseUid, w.pathologist, [w.colleague.uid, w.otherPathologist.uid]);
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid: owned, accept: true });
      const joined = await mdtOn(caseUid, w.doctor, [w.pathologist.uid, w.colleague.uid]);
      await respondToMdtInviteHandler(deps, w.pathologist, { conversationUid: joined, accept: true });
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid: joined, accept: true });
      assert.ok(canPost(await conv(thread), w.pathologist.uid));

      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });

      const direct = await conv(thread);
      assert.equal(direct?.status, 'Closed');
      assert.equal(canPost(direct, w.pathologist.uid), false);
      assert.equal(canPost(direct, w.doctor.uid), false);

      const ownedNow = await conv(owned);
      assert.equal(ownedNow?.status, 'Closed');
      assert.notEqual(ownedNow?.closedAt, '');
      // Those who stay on the case keep what was said; the person who left keeps nothing.
      assert.equal(canPost(ownedNow, w.colleague.uid), false);
      assert.equal(canRead(ownedNow, w.colleague.uid), true);
      assert.equal(members(ownedNow)[w.pathologist.uid].status, 'Removed');
      assert.equal(canRead(ownedNow, w.pathologist.uid), false);
      assert.equal(members(ownedNow)[w.otherPathologist.uid].status, 'Removed');
      assert.equal(ownedNow?.nextInviteExpiresAt, '');
      // The invitation nobody answered no longer waits for an answer.
      assert.equal(actionStatus(await invite(w.otherPathologist.uid, owned)), 'Cancelled');
      assert.equal(actionStatus(await invite(w.colleague.uid, owned)), 'Accepted');

      const joinedNow = await conv(joined);
      assert.equal(joinedNow?.status, 'Open');
      assert.equal(members(joinedNow)[w.pathologist.uid].status, 'Removed');
      assert.deepEqual(ids(joinedNow), sorted(w.doctor.uid, w.colleague.uid));
      assert.equal(canPost(joinedNow, w.pathologist.uid), false);
      assert.equal(canRead(joinedNow, w.pathologist.uid), false);
      assert.equal(canPost(joinedNow, w.colleague.uid), true);

      // Nothing they could still call reaches the closed group, or the one they left.
      await refusedWith(
        inviteToMdtHandler(deps, w.pathologist, { conversationUid: owned, inviteeUids: [w.colleague.uid] }),
        'conversationClosed',
      );
      await refusedWith(
        inviteToMdtHandler(deps, w.pathologist, { conversationUid: joined, inviteeUids: [w.otherPathologist.uid] }),
        'notParticipant',
      );
      await refusedWith(leaveMdtHandler(deps, w.pathologist, { conversationUid: joined }), 'invalidMember');
    });

    it('reopens the order thread, history and all, when the pathologist is again the case’s own', async () => {
      const caseUid = await acceptedCase(w);
      const thread = await directOn(caseUid);
      const said = await post(thread);
      const order = { resourceType: 'Order', resourceUid: caseUid };
      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      assert.equal((await conv(thread))?.status, 'Closed');
      await refusedWith(openDirectConversationHandler(deps, w.pathologist, order), 'conversationUnavailable');

      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.pathologist.uid });
      await acceptCaseHandler(w.deps, w.pathologist, { caseUid });
      assert.deepEqual(await openDirectConversationHandler(deps, w.pathologist, order), { conversationUid: thread });

      const reopened = await conv(thread);
      assert.equal(reopened?.status, 'Open');
      assert.equal(reopened?.closedAt, '');
      assert.equal(members(reopened)[w.pathologist.uid].status, 'Accepted');
      assert.deepEqual(ids(reopened), sorted(w.doctor.uid, w.pathologist.uid));
      assert.equal(canPost(reopened, w.pathologist.uid), true);
      assert.equal(canPost(reopened, w.doctor.uid), true);
      assert.ok(await message(thread, said), 'what was said before is still there');
      assert.deepEqual(await openDirectConversationHandler(deps, w.doctor, order), { conversationUid: thread });
    });

    it('does not reopen the thread for a pathologist who is not the case’s own', async () => {
      const caseUid = await acceptedCase(w);
      const thread = await directOn(caseUid);
      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      await refusedWith(
        openDirectConversationHandler(deps, w.doctor, { resourceType: 'Order', resourceUid: caseUid }),
        'conversationUnavailable',
      );
      assert.equal((await conv(thread))?.status, 'Closed');
    });

    it('leaves a doctor’s group open when the departing pathologist was never in it', async () => {
      const caseUid = await acceptedCase(w);
      const thread = await directOn(caseUid);
      const group = await mdtOn(caseUid, w.doctor, [w.colleague.uid]);
      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      assert.equal((await conv(group))?.status, 'Open');
      assert.equal((await conv(thread))?.status, 'Closed');
    });

    it('removes a viewer from the groups on the case, and settles the invitation they had not answered', async () => {
      const caseUid = await acceptedCase(w);
      await w.deps.db.collection('cases').doc(caseUid).update({ viewerUids: [w.colleague.uid] });
      const joined = await mdtOn(caseUid, w.doctor, [w.colleague.uid]);
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid: joined, accept: true });
      const waiting = await mdtOn(caseUid, w.doctor, [w.colleague.uid], CLINICAL_SPECIALTIES[1]);
      assert.ok(canPost(await conv(joined), w.colleague.uid));

      await removeCaseViewerHandler(w.deps, w.doctor, { caseUid, viewerUid: w.colleague.uid });

      const joinedNow = await conv(joined);
      assert.equal(joinedNow?.status, 'Open');
      assert.equal(members(joinedNow)[w.colleague.uid].status, 'Removed');
      assert.deepEqual(ids(joinedNow), [w.doctor.uid]);
      assert.equal(canPost(joinedNow, w.colleague.uid), false);
      assert.equal(canRead(joinedNow, w.colleague.uid), false);
      const waitingNow = await conv(waiting);
      assert.equal(members(waitingNow)[w.colleague.uid].status, 'Removed');
      assert.equal(waitingNow?.nextInviteExpiresAt, '');
      assert.equal(actionStatus(await invite(w.colleague.uid, waiting)), 'Cancelled');
      await refusedWith(respondToMdtInviteHandler(deps, w.colleague, { conversationUid: waiting, accept: true }), 'inviteClosed');
      await refusedWith(leaveMdtHandler(deps, w.colleague, { conversationUid: joined }), 'invalidMember');
    });

    it('keeps the threads of a viewer who is also the pathologist', async () => {
      const caseUid = await acceptedCase(w);
      await w.deps.db.collection('cases').doc(caseUid).update({ viewerUids: [w.pathologist.uid] });
      const thread = await directOn(caseUid);
      await removeCaseViewerHandler(w.deps, w.doctor, { caseUid, viewerUid: w.pathologist.uid });
      const c = await conv(thread);
      assert.equal(c?.status, 'Open');
      assert.ok(canPost(c, w.pathologist.uid));
    });

    it('closes every thread on a cancelled case and settles every open invitation', async () => {
      const caseUid = await acceptedCase(w);
      const thread = await directOn(caseUid);
      const group = await mdtOn(caseUid, w.pathologist, [w.colleague.uid, w.otherPathologist.uid]);
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid: group, accept: true });
      const other = await mdtOn(caseUid, w.doctor, [w.otherPathologist.uid], CLINICAL_SPECIALTIES[1]);

      await cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode: 'OrderedInError' });

      for (const id of [thread, group, other]) {
        const c = await conv(id);
        assert.equal(c?.status, 'Closed');
        for (const uid of [w.doctor.uid, w.pathologist.uid, w.colleague.uid]) assert.equal(canPost(c, uid), false);
      }
      assert.equal(actionStatus(await invite(w.otherPathologist.uid, group)), 'Cancelled');
      assert.equal(actionStatus(await invite(w.otherPathologist.uid, other)), 'Cancelled');
      assert.equal((await conv(other))?.nextInviteExpiresAt, '');
      await refusedWith(
        inviteToMdtHandler(deps, w.doctor, { conversationUid: other, inviteeUids: [w.colleague.uid] }),
        'conversationClosed',
      );
      await refusedWith(
        openDirectConversationHandler(deps, w.doctor, { resourceType: 'Order', resourceUid: caseUid }),
        'conversationUnavailable',
      );
      await refusedWith(
        mdtOn(caseUid, w.doctor, [w.colleague.uid], CLINICAL_SPECIALTIES[2]),
        'conversationUnavailable',
      );
    });

    it('leaves other cases’ threads alone', async () => {
      const caseUid = await acceptedCase(w);
      const elsewhere = await acceptedCase(w);
      const keptThread = await directOn(elsewhere);
      const keptGroup = await mdtOn(elsewhere, w.doctor, [w.colleague.uid]);
      await directOn(caseUid);
      await cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode: 'OrderedInError' });
      assert.equal((await conv(keptThread))?.status, 'Open');
      assert.equal((await conv(keptGroup))?.status, 'Open');
    });

    it('is a no-op for a case with no threads', async () => {
      const caseUid = await acceptedCase(w);
      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      assert.equal(await conv(`case_${caseUid}_${w.pathologist.uid}`), undefined);
    });

    describe('backstops, when the case moved before the closer ran', () => {
      it('refuses an invitation from an owner who is no longer on the case', async () => {
        const caseUid = await acceptedCase(w);
        const group = await mdtOn(caseUid, w.pathologist, [w.colleague.uid]);
        await w.deps.db.collection('cases').doc(caseUid).update({ pathologistUid: w.otherPathologist.uid });
        await refusedWith(
          inviteToMdtHandler(deps, w.pathologist, { conversationUid: group, inviteeUids: [w.otherPathologist.uid] }),
          'notParticipant',
        );
      });

      it('refuses to open the order thread of a cancelled case', async () => {
        const caseUid = await acceptedCase(w);
        await w.deps.db.collection('cases').doc(caseUid).update({ currentStage: 'Cancelled' });
        await refusedWith(
          openDirectConversationHandler(deps, w.doctor, { resourceType: 'Order', resourceUid: caseUid }),
          'conversationUnavailable',
        );
      });

      it('refuses to accept an invitation to a group whose owner has left', async () => {
        const caseUid = await acceptedCase(w);
        const group = await mdtOn(caseUid, w.pathologist, [w.colleague.uid]);
        await w.deps.db.collection('cases').doc(caseUid).update({ pathologistUid: w.otherPathologist.uid });
        await refusedWith(
          respondToMdtInviteHandler(deps, w.colleague, { conversationUid: group, accept: true }),
          'inviteClosed',
        );
        assert.equal(members(await conv(group))[w.colleague.uid].status, 'Invited');
      });
    });
  });

  describe('settling invitations', () => {
    it('settles a pending invitation when the owner removes the invitee', async () => {
      const { conversationUid } = await openMdt([w.colleague.uid]);
      await removeFromMdtHandler(deps, w.doctor, { conversationUid, memberUid: w.colleague.uid });
      const row = await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.colleague.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Cancelled');
    });

    it('leaves a settled round settled when a new one replaces it', async () => {
      const { conversationUid } = await openMdt([w.colleague.uid]);
      await respondToMdtInviteHandler(deps, w.colleague, { conversationUid, accept: false });
      await inviteToMdtHandler(deps, w.doctor, { conversationUid, inviteeUids: [w.colleague.uid] });
      const first = await docData(w, noteId('mdtInvited', `${conversationUid}-r1`, w.colleague.uid));
      const second = await docData(w, noteId('mdtInvited', `${conversationUid}-r2`, w.colleague.uid));
      assert.equal((first?.metadata as { actionStatus: string }).actionStatus, 'Declined');
      assert.equal((second?.metadata as { actionStatus: string }).actionStatus, 'Pending');
    });
  });

  it('refuses a caller with no role in every callable', async () => {
    const { conversationUid, caseUid } = await openMdt();
    const m = await deliverVoice(await direct());
    const nobody = callerWithoutRole();
    const calls = [
      () => openDirectConversationHandler(deps, nobody, { resourceType: 'Appointment', resourceUid: w.appointmentUid }),
      () =>
        openMdtHandler(deps, nobody, {
          conversationUid: newId(),
          caseUid,
          specialty: SPECIALTY,
          description: 'Please look.',
          inviteeUids: [w.colleague.uid],
        }),
      () => inviteToMdtHandler(deps, nobody, { conversationUid, inviteeUids: [w.otherPathologist.uid] }),
      () => respondToMdtInviteHandler(deps, nobody, { conversationUid, accept: true }),
      () => leaveMdtHandler(deps, nobody, { conversationUid }),
      () => removeFromMdtHandler(deps, nobody, { conversationUid, memberUid: w.colleague.uid }),
      () => closeConversationHandler(deps, nobody, { conversationUid }),
      () => withdrawMessageHandler(deps, nobody, { conversationUid: `appt_${w.appointmentUid}`, messageUid: m }),
      () => shareTranscriptHandler(deps, nobody, { conversationUid: `appt_${w.appointmentUid}`, messageUid: m, decision: 'Approve' }),
    ];
    for (const call of calls) await refused(Promise.resolve().then(call as () => Promise<unknown>));
    assert.equal(members(await conv(conversationUid))[w.colleague.uid].status, 'Invited');
  });

  it('only practitioners reach the practitioner callables', async () => {
    const { conversationUid } = await openMdt();
    const asPatient = [
      () => leaveMdtHandler(deps, w.patient, { conversationUid }),
      () => closeConversationHandler(deps, w.patient, { conversationUid }),
      () => removeFromMdtHandler(deps, w.patient, { conversationUid, memberUid: w.colleague.uid }),
    ];
    for (const call of asPatient) await refusedWith(Promise.resolve().then(call), 'notParticipant');
  });
});
