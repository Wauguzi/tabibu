// cspell:ignore Wambui Kiprop Otieno kinauma siku tatu
import assert from 'node:assert/strict';

import { seedWorld, signedCase, caseDoc, docData, type World } from './case.test-support';
import {
  cancelAppointmentHandler,
  completeAppointmentHandler,
  expireAppointmentsHandler,
  onAppointmentWrittenHandler,
  SPEECH_PAGE,
  requestAppointmentHandler,
  respondToAppointmentHandler,
  transcribeSymptomsHandler,
} from './appointments';
import {
  SLOT,
  SLOT_2,
  ahead,
  allOff,
  bucket,
  doctorDoc,
  farAhead,
  newId,
  objectExists,
  putObject,
  runtime,
  secondPatient,
} from './domain.test-support';
import { refused, refusedWith, resetEmulators, callerWithoutRole } from './emulator.test-support';
import { DAY_MS, HOUR_MS, MINUTE_MS, type RuntimeDeps } from './runtime-deps';
import { noteId } from './case.test-support';

const SYMPTOMS = 'A headache that has lasted three days, worse in the evening.';

describe('appointments', () => {
  let w: World;
  let deps: RuntimeDeps;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
    deps = runtime(w);
    await bucket().deleteFiles({ prefix: 'speechAudio/', force: true });
  });

  async function request(extra: Record<string, unknown> = {}, who = w.patient): Promise<string> {
    const appointmentUid = newId();
    await requestAppointmentHandler(deps, who, {
      appointmentUid,
      type: 'Consultation',
      doctorUid: w.doctor.uid,
      scheduledStart: SLOT,
      symptomText: SYMPTOMS,
      ...extra,
    });
    return appointmentUid;
  }

  describe('requestAppointment', () => {
    it('creates the request, the doctor’s approval row and the queued intake', async () => {
      const uid = await request();
      const appt = await docData(w, `appointments/${uid}`);
      assert.equal(appt?.status, 'Requested');
      assert.equal(appt?.patientUid, w.patient.uid);
      assert.equal(appt?.scheduledEnd, '2026-10-28T07:30:00.000Z');
      assert.equal(appt?.expiresAt, SLOT);
      assert.equal(appt?.intakeStatus, 'Queued');
      const row = await docData(w, noteId('appointmentRequested', uid, w.doctor.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Pending');
      assert.equal((await docData(w, `appointments/${uid}/intake/summary`))?.status, 'Queued');
    });

    it('de-identifies the text the intake model will read', async () => {
      const uid = await request({ symptomText: `I am Amina Otieno and ${SYMPTOMS}` });
      const input = String((await docData(w, `appointments/${uid}/intake/summary`))?.inputText);
      assert.ok(!input.includes('Otieno'));
      assert.ok(!input.includes('Amina'));
    });

    it('writes a None intake, with no text, when the switch is off', async () => {
      deps = runtime(w, { config: allOff });
      const uid = await request();
      assert.equal((await docData(w, `appointments/${uid}`))?.intakeStatus, 'None');
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.status, 'None');
      assert.equal(summary?.inputText, '');
      // Nothing reads it, so nothing is made from it.
      await onAppointmentWrittenHandler(deps, uid, undefined, (await docData(w, `appointments/${uid}`)) ?? {});
      assert.equal((await docData(w, `appointments/${uid}/intake/summary`))?.status, 'None');
    });

    it('keeps the transcript fields on the None intake when a voice request is made with the switch off', async () => {
      await putObject(`speechAudio/${w.patient.uid}/dictation-off.m4a`, Buffer.from('audio'), 'audio/mp4');
      const { transcriptionUid } = await transcribeSymptomsHandler(deps, w.patient, { audioUid: 'dictation-off' });
      const intakeOff = runtime(w, { config: { enabled: (key: string) => key !== 'symptom_intake_enabled' } });
      const uid = newId();
      await requestAppointmentHandler(intakeOff, w.patient, {
        appointmentUid: uid,
        type: 'Consultation',
        doctorUid: w.doctor.uid,
        scheduledStart: SLOT,
        symptomText: 'Nina maumivu ya kichwa.',
        inputMode: 'Voice',
        transcriptionUid,
      });
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.status, 'None');
      assert.equal(summary?.inputText, '');
      assert.equal(summary?.transcriptAcceptedUnchanged, true);
      assert.equal(summary?.transcriptLanguage, 'sw');
      assert.equal((await docData(w, `appointments/${uid}`))?.symptomLanguage, 'sw');
    });

    it('stores an edited transcript’s distance and never the machine text', async () => {
      await putObject(`speechAudio/${w.patient.uid}/dictation-edit.m4a`, Buffer.from('audio'), 'audio/mp4');
      const { transcriptionUid } = await transcribeSymptomsHandler(deps, w.patient, { audioUid: 'dictation-edit' });
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'Consultation',
        doctorUid: w.doctor.uid,
        scheduledStart: SLOT,
        symptomText: 'Kichwa kinauma kwa siku tatu.',
        inputMode: 'Voice',
        transcriptionUid,
      });
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.transcriptAcceptedUnchanged, false);
      assert.ok(Number(summary?.transcriptEditDistance) > 0);
      for (const doc of [await docData(w, `appointments/${uid}`), summary]) {
        assert.ok(!JSON.stringify(doc).includes('maumivu ya kichwa'));
      }
    });

    it('is idempotent on the appointment uid and refuses another patient’s uid', async () => {
      const uid = await request();
      const again = await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'Consultation',
        doctorUid: w.doctor.uid,
        scheduledStart: SLOT,
        symptomText: SYMPTOMS,
      });
      assert.deepEqual(again, { status: 'Requested', appointmentUid: uid });
      const other = await secondPatient(w);
      await refusedWith(request({ appointmentUid: uid }, other.caller), 'alreadyExists');
    });

    it('refuses a slot off the grid, in the past, outside hours or already taken', async () => {
      await refusedWith(request({ scheduledStart: '2026-10-28T07:10:00.000Z' }), 'invalidSlot');
      await refusedWith(request({ scheduledStart: '2026-10-27T09:30:00.000Z' }), 'invalidSlot');
      await refusedWith(request({ scheduledStart: '2026-10-28T16:00:00.000Z' }), 'outsideWorkingHours');
      await refusedWith(request({ scheduledStart: '2026-11-01T07:00:00.000Z' }), 'outsideWorkingHours');
      await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ busySlots: [SLOT] });
      await refusedWith(request(), 'slotTaken');
    });

    it('refuses a second pending request to the same doctor and an unavailable doctor', async () => {
      await request();
      await refusedWith(request({ scheduledStart: SLOT_2 }), 'tooManyPending');
      const other = await secondPatient(w);
      await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ isAvailable: false });
      await refusedWith(request({}, other.caller), 'doctorUnavailable');
    });

    it('refuses a pathologist as the doctor and a caller who is not a patient', async () => {
      await refusedWith(request({ doctorUid: w.pathologist.uid }), 'doctorUnavailable');
      await refusedWith(request({}, w.doctor), 'patientsOnly');
    });

    it('opens a case discussion and moves the case to DiscussionRequested', async () => {
      const signed = await signedCase(w);
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'CaseDiscussion',
        caseUid: signed.caseUid,
        scheduledStart: SLOT,
      });
      const s = await caseDoc(w, signed.caseUid);
      assert.equal(s.currentStage, 'DiscussionRequested');
      assert.equal(s.discussionAppointmentUid, uid);
      assert.ok(await docData(w, noteId('caseDiscussionRequested', uid, w.doctor.uid)));
      assert.equal(await docData(w, `appointments/${uid}/intake/summary`), undefined);
    });

    it('refuses a discussion before the result is with the doctor', async () => {
      await refusedWith(
        requestAppointmentHandler(deps, w.patient, {
          appointmentUid: newId(),
          type: 'CaseDiscussion',
          caseUid: newId(),
          scheduledStart: SLOT,
        }),
        'invalidAppointment',
      );
    });
  });

  describe('respondToAppointment', () => {
    it('accepts: books the slot, adds the doctor to the care team and settles the approval', async () => {
      const uid = await request();
      assert.deepEqual(await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' }), {
        status: 'Accepted',
      });
      assert.deepEqual((await doctorDoc(w, w.doctor.uid)).busySlots, [SLOT]);
      assert.equal((await docData(w, `appointments/${uid}`))?.acceptedAt, '2026-10-27T09:00:00.000Z');
      assert.ok(((await docData(w, `patients/${w.patientId}`))?.doctorUids as string[]).includes(w.doctor.uid));
      const row = await docData(w, noteId('appointmentRequested', uid, w.doctor.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Accepted');
      assert.ok(await docData(w, noteId('appointmentAccepted', uid, w.patient.uid)));
    });

    it('declines with a reason, frees nothing and tells the patient', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, {
        appointmentUid: uid,
        decision: 'Decline',
        declineReason: 'SlotUnavailable',
        declineNote: 'Away that morning.',
      });
      const appt = await docData(w, `appointments/${uid}`);
      assert.equal(appt?.status, 'Declined');
      assert.equal(appt?.declineReason, 'SlotUnavailable');
      assert.deepEqual((await doctorDoc(w, w.doctor.uid)).busySlots ?? [], []);
      assert.ok(await docData(w, noteId('appointmentDeclined', uid, w.patient.uid)));
    });

    it('refuses a decline without a known reason and another doctor’s request', async () => {
      const uid = await request();
      await refusedWith(respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Decline' }), 'invalidReason');
      await refusedWith(
        respondToAppointmentHandler(deps, w.colleague, { appointmentUid: uid, decision: 'Accept' }),
        'invalidAppointment',
      );
    });

    it('answers an expired request with Expired, never Accepted', async () => {
      const uid = await request();
      const late = ahead(deps, 23 * HOUR_MS);
      assert.deepEqual(await respondToAppointmentHandler(late, w.doctor, { appointmentUid: uid, decision: 'Accept' }), {
        status: 'Expired',
      });
      assert.deepEqual((await doctorDoc(w, w.doctor.uid)).busySlots ?? [], []);
    });

    it('refuses an accept for a slot the doctor has booked in the meantime', async () => {
      const uid = await request();
      await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ busySlots: [SLOT] });
      await refusedWith(respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' }), 'slotTaken');
      assert.equal((await docData(w, `appointments/${uid}`))?.status, 'Requested');
      assert.deepEqual((await doctorDoc(w, w.doctor.uid)).busySlots, [SLOT]);
      assert.equal(await docData(w, noteId('appointmentAccepted', uid, w.patient.uid)), undefined);
    });

    it('lets exactly one of two concurrent accepts for the same slot succeed', async () => {
      const first = await request();
      const other = await secondPatient(w);
      const second = await request({}, other.caller);

      const results = await Promise.all([
        respondToAppointmentHandler(deps, w.doctor, { appointmentUid: first, decision: 'Accept' }),
        respondToAppointmentHandler(deps, w.doctor, { appointmentUid: second, decision: 'Accept' }),
      ]);

      assert.deepEqual(results.map((r) => r.status).sort(), ['Accepted', 'Declined']);
      assert.deepEqual((await doctorDoc(w, w.doctor.uid)).busySlots, [SLOT]);
      const statuses = [
        (await docData(w, `appointments/${first}`))?.status,
        (await docData(w, `appointments/${second}`))?.status,
      ].sort();
      assert.deepEqual(statuses, ['Accepted', 'Declined']);
      const loser = results[0].status === 'Accepted' ? second : first;
      assert.equal((await docData(w, `appointments/${loser}`))?.declineReason, 'SlotTaken');
    });

    it('declines a sibling request for the slot, including a case discussion, and closes its discussion', async () => {
      const signed = await signedCase(w);
      const discussion = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: discussion,
        type: 'CaseDiscussion',
        caseUid: signed.caseUid,
        scheduledStart: SLOT,
      });
      const other = await secondPatient(w);
      const consultation = await request({}, other.caller);

      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: consultation, decision: 'Accept' });

      const sibling = await docData(w, `appointments/${discussion}`);
      assert.equal(sibling?.status, 'Declined');
      assert.equal(sibling?.declineReason, 'SlotTaken');
      const s = await caseDoc(w, signed.caseUid);
      assert.notEqual(s.currentStage, 'DiscussionRequested');
      assert.equal(s.discussionAppointmentUid, '');
      assert.ok(await docData(w, noteId('appointmentDeclined', discussion, w.patient.uid)));
    });

    it('books a case discussion', async () => {
      const signed = await signedCase(w);
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'CaseDiscussion',
        caseUid: signed.caseUid,
        scheduledStart: SLOT,
      });
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      assert.equal((await caseDoc(w, signed.caseUid)).currentStage, 'DiscussionBooked');
    });
  });

  describe('cancelAppointment', () => {
    it('lets the patient cancel and frees the doctor’s slot', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      assert.deepEqual(await cancelAppointmentHandler(deps, w.patient, { appointmentUid: uid }), { status: 'Cancelled' });
      assert.deepEqual((await doctorDoc(w, w.doctor.uid)).busySlots, []);
      assert.ok(await docData(w, noteId('appointmentCancelledByPatient', uid, w.doctor.uid)));
    });

    it('requires the doctor to give a note', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      await refusedWith(cancelAppointmentHandler(deps, w.doctor, { appointmentUid: uid }), 'noteRequired');
      await cancelAppointmentHandler(deps, w.doctor, { appointmentUid: uid, cancelNote: 'Called away.' });
      assert.ok(await docData(w, noteId('appointmentCancelledByDoctor', uid, w.patient.uid)));
    });

    it('refuses once the slot has started', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      await refusedWith(cancelAppointmentHandler(ahead(deps, 23 * HOUR_MS), w.patient, { appointmentUid: uid }), 'tooLate');
    });
  });

  describe('completeAppointment', () => {
    it('is refused before the slot and records Completed after it', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      await refusedWith(completeAppointmentHandler(deps, w.doctor, { appointmentUid: uid, outcome: 'Completed' }), 'tooEarly');
      const after = ahead(deps, 23 * HOUR_MS);
      assert.deepEqual(await completeAppointmentHandler(after, w.doctor, { appointmentUid: uid, outcome: 'Completed' }), {
        status: 'Completed',
      });
    });

    it('records a no-show only after the slot has ended', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      const during = ahead(deps, 22 * HOUR_MS + 10 * MINUTE_MS);
      await refusedWith(completeAppointmentHandler(during, w.doctor, { appointmentUid: uid, outcome: 'NoShow' }), 'tooEarly');
      const after = ahead(deps, 23 * HOUR_MS);
      await completeAppointmentHandler(after, w.doctor, { appointmentUid: uid, outcome: 'NoShow' });
    });

    it('a case-discussion NoShow closes the discussion so a new booking is allowed', async () => {
      const signed = await signedCase(w);
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'CaseDiscussion',
        caseUid: signed.caseUid,
        scheduledStart: SLOT,
      });
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      assert.equal((await caseDoc(w, signed.caseUid)).currentStage, 'DiscussionBooked');
      const after = ahead(deps, 23 * HOUR_MS);
      await completeAppointmentHandler(after, w.doctor, { appointmentUid: uid, outcome: 'NoShow' });
      const closed = await caseDoc(w, signed.caseUid);
      assert.equal(closed.currentStage, 'ReportSigned');
      assert.equal(closed.discussionAppointmentUid, '');
      // Rebook after the no-show on a later slot.
      const next = newId();
      await requestAppointmentHandler(ahead(deps, 24 * HOUR_MS), w.patient, {
        appointmentUid: next,
        type: 'CaseDiscussion',
        caseUid: signed.caseUid,
        scheduledStart: '2026-10-29T07:00:00.000Z',
      });
      assert.equal((await caseDoc(w, signed.caseUid)).currentStage, 'DiscussionRequested');
    });

    it('a completed case discussion also returns the case to ReportSigned', async () => {
      const signed = await signedCase(w);
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'CaseDiscussion',
        caseUid: signed.caseUid,
        scheduledStart: SLOT,
      });
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      await completeAppointmentHandler(ahead(deps, 23 * HOUR_MS), w.doctor, { appointmentUid: uid, outcome: 'Completed' });
      const closed = await caseDoc(w, signed.caseUid);
      assert.equal(closed.currentStage, 'ReportSigned');
      assert.equal(closed.discussionAppointmentUid, '');
    });
  });

  it('a Declined or Expired case-discussion request clears the discussion for rebooking', async () => {
    const declined = await signedCase(w);
    const declinedUid = newId();
    await requestAppointmentHandler(deps, w.patient, {
      appointmentUid: declinedUid,
      type: 'CaseDiscussion',
      caseUid: declined.caseUid,
      scheduledStart: SLOT,
    });
    await respondToAppointmentHandler(deps, w.doctor, {
      appointmentUid: declinedUid,
      decision: 'Decline',
      declineReason: 'SlotUnavailable',
    });
    assert.equal((await caseDoc(w, declined.caseUid)).currentStage, 'ReportSigned');
    assert.equal((await caseDoc(w, declined.caseUid)).discussionAppointmentUid, '');

    const expired = await signedCase(w);
    const expiredUid = newId();
    await requestAppointmentHandler(deps, w.patient, {
      appointmentUid: expiredUid,
      type: 'CaseDiscussion',
      caseUid: expired.caseUid,
      scheduledStart: SLOT_2,
    });
    await respondToAppointmentHandler(ahead(deps, 23 * HOUR_MS), w.doctor, {
      appointmentUid: expiredUid,
      decision: 'Accept',
    });
    assert.equal((await docData(w, `appointments/${expiredUid}`))?.status, 'Expired');
    assert.equal((await caseDoc(w, expired.caseUid)).currentStage, 'ReportSigned');
    assert.equal((await caseDoc(w, expired.caseUid)).discussionAppointmentUid, '');
  });

  describe('onAppointmentWritten', () => {
    it('counts a booking and a completion once each, on the edge', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      const accepted = (await docData(w, `appointments/${uid}`)) ?? {};
      const created = { ...accepted, acceptedAt: '', status: 'Requested' };
      await onAppointmentWrittenHandler(deps, uid, created, accepted);
      await onAppointmentWrittenHandler(deps, uid, created, accepted);
      assert.equal((await docData(w, `patients/${w.patientId}`))?.appointmentsBooked, 1);

      const after = ahead(deps, 23 * HOUR_MS);
      await completeAppointmentHandler(after, w.doctor, { appointmentUid: uid, outcome: 'Completed' });
      const completed = (await docData(w, `appointments/${uid}`)) ?? {};
      await onAppointmentWrittenHandler(after, uid, accepted, completed);
      await onAppointmentWrittenHandler(after, uid, accepted, completed);
      assert.equal((await doctorDoc(w, w.doctor.uid)).appointmentsHandled, 1);
      // An unrelated later write is not an edge.
      await onAppointmentWrittenHandler(after, uid, completed, { ...completed, cancelNote: 'x' });
      assert.equal((await doctorDoc(w, w.doctor.uid)).appointmentsHandled, 1);
    });

    it('counts nothing for a later write once the booking’s mark has expired', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      const accepted = (await docData(w, `appointments/${uid}`)) ?? {};
      const created = { ...accepted, acceptedAt: '', status: 'Requested' };
      await onAppointmentWrittenHandler(deps, uid, created, accepted);
      assert.equal((await docData(w, `patients/${w.patientId}`))?.appointmentsBooked, 1);

      await w.deps.db.collection('counterMarks').doc(`appointmentsBooked:${uid}`).delete();
      await onAppointmentWrittenHandler(ahead(deps, 31 * DAY_MS), uid, accepted, { ...accepted, cancelNote: 'x' });
      assert.equal((await docData(w, `patients/${w.patientId}`))?.appointmentsBooked, 1);
    });

    it('counts a booking once when the request is cancelled before the event arrives', async () => {
      const uid = await request();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      const accepted = (await docData(w, `appointments/${uid}`)) ?? {};
      const created = { ...accepted, acceptedAt: '', status: 'Requested' };
      await cancelAppointmentHandler(deps, w.patient, { appointmentUid: uid });
      const cancelled = (await docData(w, `appointments/${uid}`)) ?? {};

      await onAppointmentWrittenHandler(deps, uid, created, accepted);
      await onAppointmentWrittenHandler(deps, uid, accepted, cancelled);
      await onAppointmentWrittenHandler(deps, uid, created, accepted);
      assert.equal((await docData(w, `patients/${w.patientId}`))?.appointmentsBooked, 1);
      assert.equal((await doctorDoc(w, w.doctor.uid)).appointmentsHandled ?? 0, 0);
    });

    it('fails the intake with Disabled, and calls no model, when the switch went off after the request', async () => {
      const uid = await request();
      let calls = 0;
      const off = runtime(w, {
        config: allOff,
        ai: {
          ...deps.ai!,
          summarizeSymptoms: (req) => {
            calls += 1;
            return Promise.resolve({ en: req.inputText, sw: req.inputText, models: {} });
          },
        },
      });
      await onAppointmentWrittenHandler(off, uid, undefined, (await docData(w, `appointments/${uid}`)) ?? {});
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.status, 'Failed');
      assert.equal(summary?.failureReason, 'Disabled');
      assert.ok(typeof summary?.readyAt === 'string' && summary.readyAt !== '');
      assert.equal((await docData(w, `appointments/${uid}`))?.intakeStatus, 'Failed');
      assert.equal(calls, 0);
    });

    it('records the language the model found and gives it to an appointment that has none', async () => {
      const found = runtime(w, {
        ai: {
          ...deps.ai!,
          summarizeSymptoms: (req) =>
            Promise.resolve({ en: req.inputText, sw: req.inputText, models: {}, inputLanguage: 'en' }),
        },
      });
      const uid = await request();
      assert.equal((await docData(w, `appointments/${uid}`))?.symptomLanguage, '');
      await onAppointmentWrittenHandler(found, uid, undefined, (await docData(w, `appointments/${uid}`)) ?? {});
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.inputLanguage, 'en');
      const drafts = summary?.drafts as { en: { isTranslation: boolean }; sw: { isTranslation: boolean } };
      assert.equal(drafts.en.isTranslation, false);
      assert.equal(drafts.sw.isTranslation, true);
      assert.equal((await docData(w, `appointments/${uid}`))?.symptomLanguage, 'en');
    });

    it('keeps the transcript’s language on the appointment, and ignores a language it does not know', async () => {
      await putObject(`speechAudio/${w.patient.uid}/dictation-lang.m4a`, Buffer.from('audio'), 'audio/mp4');
      const { transcriptionUid } = await transcribeSymptomsHandler(deps, w.patient, { audioUid: 'dictation-lang' });
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'Consultation',
        doctorUid: w.doctor.uid,
        scheduledStart: SLOT,
        symptomText: 'Nina maumivu ya kichwa.',
        inputMode: 'Voice',
        transcriptionUid,
      });
      const odd = runtime(w, {
        ai: {
          ...deps.ai!,
          summarizeSymptoms: (req) =>
            Promise.resolve({ en: req.inputText, sw: req.inputText, models: {}, inputLanguage: 'klingon' }),
        },
      });
      await onAppointmentWrittenHandler(odd, uid, undefined, (await docData(w, `appointments/${uid}`)) ?? {});
      assert.equal((await docData(w, `appointments/${uid}/intake/summary`))?.inputLanguage, 'sw');
      assert.equal((await docData(w, `appointments/${uid}`))?.symptomLanguage, 'sw');
    });

    it('fills the intake summary from the de-identified text', async () => {
      const uid = await request({ symptomText: `I am Amina Otieno and ${SYMPTOMS}` });
      const created = (await docData(w, `appointments/${uid}`)) ?? {};
      await onAppointmentWrittenHandler(deps, uid, undefined, created);
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.status, 'Ready');
      const drafts = summary?.drafts as { en: { summary: string }; sw: { summary: string } };
      assert.ok(!drafts.en.summary.includes('Otieno'));
      assert.match(drafts.sw.summary, /^Muhtasari: /);
      assert.equal((await docData(w, `appointments/${uid}`))?.intakeStatus, 'Ready');
    });

    it('writes Failed, and does not throw, when the model fails or has nothing to say', async () => {
      const failing = runtime(w, {
        ai: { ...deps.ai!, summarizeSymptoms: () => Promise.reject(new Error('down')) },
      });
      const uid = await request();
      await onAppointmentWrittenHandler(failing, uid, undefined, (await docData(w, `appointments/${uid}`)) ?? {});
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.status, 'Failed');
      assert.equal(summary?.failureReason, 'ServiceError');
      assert.ok(typeof summary?.readyAt === 'string' && summary.readyAt !== '');

      const other = await secondPatient(w);
      const invented = runtime(w, {
        ai: { ...deps.ai!, summarizeSymptoms: () => Promise.resolve({ en: 'Pain for 99 days', sw: 'x', models: {} }) },
      });
      const second = await request({ doctorUid: w.doctor.uid, scheduledStart: SLOT_2 }, other.caller);
      await onAppointmentWrittenHandler(invented, second, undefined, (await docData(w, `appointments/${second}`)) ?? {});
      assert.equal((await docData(w, `appointments/${second}/intake/summary`))?.failureReason, 'OffSchema');
    });

    it('does not summarise twice', async () => {
      let calls = 0;
      const counting = runtime(w, {
        ai: {
          ...deps.ai!,
          summarizeSymptoms: (req) => {
            calls += 1;
            return Promise.resolve({ en: req.inputText, sw: req.inputText, models: {} });
          },
        },
      });
      const uid = await request();
      const created = (await docData(w, `appointments/${uid}`)) ?? {};
      await onAppointmentWrittenHandler(counting, uid, undefined, created);
      await onAppointmentWrittenHandler(counting, uid, undefined, created);
      assert.equal(calls, 1);
    });
  });

  describe('a discussion the case has moved on from', () => {
    async function requested(): Promise<{ uid: string; caseUid: string }> {
      const signed = await signedCase(w);
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'CaseDiscussion',
        caseUid: signed.caseUid,
        scheduledStart: SLOT,
      });
      return { uid, caseUid: signed.caseUid };
    }

    const moveOn = (caseUid: string, patch: Record<string, unknown> = {}) =>
      w.deps.db
        .collection('cases')
        .doc(caseUid)
        .update({ currentStage: 'ResultReleased', discussionAppointmentUid: '', ...patch });

    async function logSize(caseUid: string): Promise<number> {
      return (await w.deps.db.collection('cases').doc(caseUid).collection('log').get()).size;
    }

    it('changes only the appointment when the doctor declines', async () => {
      const { uid, caseUid } = await requested();
      await moveOn(caseUid);
      const before = await caseDoc(w, caseUid);
      await respondToAppointmentHandler(deps, w.doctor, {
        appointmentUid: uid,
        decision: 'Decline',
        declineReason: 'SlotUnavailable',
      });
      assert.equal((await docData(w, `appointments/${uid}`))?.status, 'Declined');
      assert.deepEqual(await caseDoc(w, caseUid), before);
    });

    it('changes only the appointment when the patient cancels', async () => {
      const { uid, caseUid } = await requested();
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: uid, decision: 'Accept' });
      await moveOn(caseUid);
      const before = await caseDoc(w, caseUid);
      await cancelAppointmentHandler(deps, w.patient, { appointmentUid: uid });
      assert.equal((await docData(w, `appointments/${uid}`))?.status, 'Cancelled');
      assert.deepEqual(await caseDoc(w, caseUid), before);
    });

    it('changes only the appointment when the request expires', async () => {
      const { uid, caseUid } = await requested();
      await moveOn(caseUid);
      const before = await caseDoc(w, caseUid);
      assert.equal((await expireAppointmentsHandler(ahead(deps, 23 * HOUR_MS))).expired, 1);
      assert.equal((await docData(w, `appointments/${uid}`))?.status, 'Expired');
      assert.deepEqual(await caseDoc(w, caseUid), before);
    });

    it('changes only the appointment when another booking takes its slot', async () => {
      const { uid, caseUid } = await requested();
      await moveOn(caseUid);
      const before = await caseDoc(w, caseUid);
      const other = await secondPatient(w);
      const consultation = await request({}, other.caller);
      await respondToAppointmentHandler(deps, w.doctor, { appointmentUid: consultation, decision: 'Accept' });
      assert.equal((await docData(w, `appointments/${uid}`))?.declineReason, 'SlotTaken');
      assert.deepEqual(await caseDoc(w, caseUid), before);
    });

    it('leaves a case that waits on a different appointment alone', async () => {
      const { uid, caseUid } = await requested();
      await w.deps.db.collection('cases').doc(caseUid).update({ discussionAppointmentUid: 'another-request' });
      const before = await caseDoc(w, caseUid);
      const logged = await logSize(caseUid);
      await respondToAppointmentHandler(deps, w.doctor, {
        appointmentUid: uid,
        decision: 'Decline',
        declineReason: 'SlotUnavailable',
      });
      assert.deepEqual(await caseDoc(w, caseUid), before);
      assert.equal(await logSize(caseUid), logged);
    });
  });

  it('refuses a caller with no role in every callable', async () => {
    const uid = await request();
    const nobody = callerWithoutRole();
    const calls: (() => Promise<unknown>)[] = [
      () => requestAppointmentHandler(deps, nobody, { appointmentUid: newId(), type: 'Consultation', doctorUid: w.doctor.uid, scheduledStart: SLOT_2, symptomText: SYMPTOMS }),
      () => respondToAppointmentHandler(deps, nobody, { appointmentUid: uid, decision: 'Accept' }),
      () => cancelAppointmentHandler(deps, nobody, { appointmentUid: uid }),
      () => completeAppointmentHandler(deps, nobody, { appointmentUid: uid, outcome: 'Completed' }),
      () => transcribeSymptomsHandler(deps, nobody, { audioUid: 'dictation-1' }),
    ];
    for (const call of calls) await refused(Promise.resolve().then(call));
    assert.equal((await docData(w, `appointments/${uid}`))?.status, 'Requested');
  });

  describe('expireAppointments', () => {
    it('expires a request past its window and settles its approval', async () => {
      const uid = await request();
      const late = ahead(deps, 23 * HOUR_MS);
      const result = await expireAppointmentsHandler(late);
      assert.equal(result.expired, 1);
      assert.equal((await docData(w, `appointments/${uid}`))?.status, 'Expired');
      assert.ok(await docData(w, noteId('appointmentExpired', uid, w.patient.uid)));
      assert.equal((await expireAppointmentsHandler(late)).expired, 0);
    });

    it('leaves a request still inside its window', async () => {
      const uid = await request();
      assert.equal((await expireAppointmentsHandler(ahead(deps, HOUR_MS))).expired, 0);
      assert.equal((await docData(w, `appointments/${uid}`))?.status, 'Requested');
    });

    it('fails an intake still queued after half an hour', async () => {
      const uid = await request();
      assert.equal((await expireAppointmentsHandler(ahead(deps, 10 * MINUTE_MS))).intakeFailed, 0);
      const result = await expireAppointmentsHandler(ahead(deps, 31 * MINUTE_MS));
      assert.equal(result.intakeFailed, 1);
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.status, 'Failed');
      assert.equal(summary?.failureReason, 'Stale');
      assert.ok(typeof summary?.readyAt === 'string' && summary.readyAt !== '');
      assert.equal((await docData(w, `appointments/${uid}`))?.intakeStatus, 'Failed');
    });

    it('deletes speech audio older than an hour and keeps a fresh upload', async () => {
      const path = `speechAudio/${w.patient.uid}/old.m4a`;
      await putObject(path, Buffer.from('audio'), 'audio/mp4');
      assert.equal((await expireAppointmentsHandler(runtime(w, { now: () => new Date() }))).audioDeleted, 0);
      assert.ok(await objectExists(path));
      const result = await expireAppointmentsHandler(farAhead(deps, 2 * HOUR_MS));
      assert.equal(result.audioDeleted, 1);
      assert.equal(await objectExists(path), false);
    });
  });

  describe('a stale speech sweep past one page', () => {
    it('deletes every stale recording, however many there are', async function () {
      this.timeout(240_000);
      const paths = Array.from({ length: SPEECH_PAGE + 1 }, (_, i) => `speechAudio/${w.patient.uid}/bulk-${i}.m4a`);
      for (let i = 0; i < paths.length; i += 50) {
        await Promise.all(paths.slice(i, i + 50).map((path) => putObject(path, Buffer.from('a'), 'audio/mp4')));
      }
      const result = await expireAppointmentsHandler(farAhead(deps, 2 * HOUR_MS));
      assert.equal(result.audioDeleted, SPEECH_PAGE + 1);
      assert.equal(await objectExists(paths[paths.length - 1]), false);
      assert.equal(await objectExists(paths[0]), false);
    });
  });

  describe('transcribeSymptoms', () => {
    const audioUid = 'dictation-1';
    const path = () => `speechAudio/${w.patient.uid}/${audioUid}.m4a`;

    it('returns the transcript, records it and deletes the audio', async () => {
      await putObject(path(), Buffer.from('audio'), 'audio/mp4');
      const result = await transcribeSymptomsHandler(deps, w.patient, { audioUid });
      assert.equal(result.transcript, 'Nina maumivu ya kichwa.');
      assert.equal(result.detectedLanguage, 'sw');
      assert.equal(await objectExists(path()), false);
      const stored = await docData(w, `transcriptions/${result.transcriptionUid}`);
      assert.equal(stored?.patientUid, w.patient.uid);
      assert.equal(stored?.transcript, 'Nina maumivu ya kichwa.');
      const signals = await w.deps.db.collection('modelSignals').get();
      assert.equal(signals.docs[0].get('transcriptionCount'), 1);
    });

    it('deletes the audio when the model fails', async () => {
      await putObject(path(), Buffer.from('audio'), 'audio/mp4');
      const failing = runtime(w, { ai: { ...deps.ai!, transcribeAudio: () => Promise.reject(new Error('down')) } });
      await refusedWith(transcribeSymptomsHandler(failing, w.patient, { audioUid }), 'transcriptionFailed');
      assert.equal(await objectExists(path()), false);
      assert.equal((await w.deps.db.collection('transcriptions').get()).size, 0);
    });

    it('deletes the audio of a refused recording too', async () => {
      await putObject(path(), Buffer.from('audio'), 'text/plain');
      await refusedWith(transcribeSymptomsHandler(deps, w.patient, { audioUid }), 'invalidAudio');
      assert.equal(await objectExists(path()), false);
    });

    it('an object over the cap never reaches the client', async () => {
      await putObject(path(), Buffer.alloc(512 * 1024 + 1), 'audio/mp4');
      let calls = 0;
      const counting = runtime(w, {
        ai: {
          ...deps.ai!,
          transcribeAudio: () => {
            calls += 1;
            return Promise.resolve({ transcript: 'unreached', language: 'en', models: {} });
          },
        },
      });
      await refusedWith(transcribeSymptomsHandler(counting, w.patient, { audioUid }), 'audioTooLarge');
      assert.equal(calls, 0);
      assert.equal(await objectExists(path()), false);
    });

    // No timer test: a hanging fetch rejects (ai-meta), and any rejection deletes (above).
    // Never patch setTimeout suite-wide for one: it wedges the emulator channel.

    it('sends the model the audio and nothing else', async () => {
      await putObject(path(), Buffer.from('audio'), 'audio/mp4');
      let seen: unknown;
      const spying = runtime(w, {
        ai: {
          ...deps.ai!,
          transcribeAudio: (req) => {
            seen = req;
            return Promise.resolve({ transcript: 'ok', language: 'en', models: {} });
          },
        },
      });
      await transcribeSymptomsHandler(spying, w.patient, { audioUid });
      assert.deepEqual(Object.keys(seen as object).sort(), ['bytes', 'contentType']);
    });

    it('fails closed when the switch is off', async () => {
      await putObject(path(), Buffer.from('audio'), 'audio/mp4');
      let calls = 0;
      const off = runtime(w, {
        config: allOff,
        ai: {
          ...deps.ai!,
          transcribeAudio: () => {
            calls += 1;
            return Promise.resolve({ transcript: 'unreached', language: 'en', models: {} });
          },
        },
      });
      await refusedWith(transcribeSymptomsHandler(off, w.patient, { audioUid }), 'voiceDisabled');
      assert.equal(calls, 0);
      assert.equal(await objectExists(path()), false);
    });

    it('fails closed when no client is wired, and still deletes the audio', async () => {
      await putObject(path(), Buffer.from('audio'), 'audio/mp4');
      const noAi = runtime(w, { ai: undefined });
      await refusedWith(transcribeSymptomsHandler(noAi, w.patient, { audioUid }), 'transcriptionFailed');
      assert.equal(await objectExists(path()), false);
    });

    it('allows twenty attempts a day and refuses the next', async () => {
      for (let i = 0; i < 20; i++) {
        await refusedWith(transcribeSymptomsHandler(deps, w.patient, { audioUid: `missing-${i}` }), 'audioMissing');
      }
      await refusedWith(transcribeSymptomsHandler(deps, w.patient, { audioUid: 'missing-21' }), 'rateLimited');
    });

    it('deletes the audio of an attempt refused for the rate, too', async () => {
      for (let i = 0; i < 20; i++) {
        await refusedWith(transcribeSymptomsHandler(deps, w.patient, { audioUid: `missing-${i}` }), 'audioMissing');
      }
      await putObject(path(), Buffer.from('audio'), 'audio/mp4');
      await refusedWith(transcribeSymptomsHandler(deps, w.patient, { audioUid }), 'rateLimited');
      assert.equal(await objectExists(path()), false);
    });

    it('lets a patient use a transcript in a voice request, once', async () => {
      await putObject(path(), Buffer.from('audio'), 'audio/mp4');
      const { transcriptionUid } = await transcribeSymptomsHandler(deps, w.patient, { audioUid });
      const uid = newId();
      await requestAppointmentHandler(deps, w.patient, {
        appointmentUid: uid,
        type: 'Consultation',
        doctorUid: w.doctor.uid,
        scheduledStart: SLOT,
        symptomText: 'Nina maumivu ya kichwa.',
        inputMode: 'Voice',
        transcriptionUid,
      });
      const summary = await docData(w, `appointments/${uid}/intake/summary`);
      assert.equal(summary?.transcriptAcceptedUnchanged, true);
      assert.equal(summary?.transcriptLanguage, 'sw');
      assert.equal(await docData(w, `transcriptions/${transcriptionUid}`), undefined);
    });
  });
});
