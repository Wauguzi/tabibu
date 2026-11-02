// cspell:ignore Amina Otieno Wanjiru Kamau Uvimbe kwenye kushoto
import assert from 'node:assert/strict';
import { createHash, randomUUID } from 'node:crypto';

import { AiError, type AiClient, type CaseAiRequest } from './ai';
import {
  acceptCaseHandler,
  cancelOrderHandler,
  completeCaseHandler,
  createOrderHandler,
  onCaseWrittenHandler,
  reassignPathologistHandler,
  recordSampleReceivedHandler,
  registerSlidesHandler,
  rejectCaseHandler,
  requestPathologistHandler,
  reserveSlideUploadsHandler,
  sweepCasesHandler,
} from './cases';
import {
  HISTOLOGY,
  acceptedCase,
  caseDoc,
  docData,
  later,
  noteId,
  orderInput,
  prereadQueuedCase,
  putSlide,
  receivedCase,
  requestedCase,
  seedWorld,
  signedCase,
  unlockCodeOf,
  type World,
} from './case.test-support';
import { DAY_MS, REQUEST_WINDOW_MS, type Deps } from './case-support';
import { refusedWith, resetEmulators } from './emulator.test-support';
import { labTestById } from './lab-tests';
import { createShareCodeHandler, redeemShareCodeHandler } from './shares-callables';

const HOUR = 60 * 60 * 1000;

describe('cases', () => {
  let w: World;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
  });

  describe('createOrder', () => {
    it('is for doctors only', async () => {
      await refusedWith(createOrderHandler(w.deps, w.patient, orderInput(w)), 'doctorsOnly');
      await refusedWith(createOrderHandler(w.deps, w.pathologist, orderInput(w)), 'doctorsOnly');
      await refusedWith(createOrderHandler(w.deps, null, orderInput(w)), 'unauthenticated');
    });

    it('prices from the server list, never the client', async () => {
      const test = labTestById(HISTOLOGY)!;
      const input = orderInput(w, { priceKes: 1, totalPriceKes: 1, tests: [{ labTestId: HISTOLOGY, priceKes: 1 }] });
      await createOrderHandler(w.deps, w.doctor, input);
      const doc = await caseDoc(w, input.caseUid as string);
      assert.equal(doc.totalPriceKes, Math.round(test.testPriceKes));
      assert.deepEqual(doc.tests, [
        {
          labTestId: test.labTestId,
          testTypeId: test.testTypeId,
          testTypeName: test.testTypeName,
          name: test.name,
          priceKes: Math.round(test.testPriceKes),
          isPriceEstimate: test.isPriceEstimate,
        },
      ]);
      assert.equal(doc.requiresSlides, true);
    });

    it('mints ODR-{doctor}-{patient}-{DDMMYYYY}-{00N} and skips a number already held', async () => {
      const first = orderInput(w);
      await createOrderHandler(w.deps, w.doctor, first);
      assert.match(String((await caseDoc(w, first.caseUid as string)).orderNumber), /^ODR-NK-AO-27102026-001$/);

      await w.deps.db.collection('orderNumbers').doc('ODR-NK-AO-27102026-002').set({ doctorUid: 'someone' });
      const second = orderInput(w);
      await createOrderHandler(w.deps, w.doctor, second);
      assert.equal((await caseDoc(w, second.caseUid as string)).orderNumber, 'ODR-NK-AO-27102026-003');
      const counter = await docData(w, `orderCounters/${w.doctor.uid}_20261027`);
      assert.equal(counter?.count, 3);
      assert.ok(counter?.expireAt, 'the counter carries a TTL');
      assert.ok((await docData(w, 'orderNumbers/ODR-NK-AO-27102026-003')) !== undefined);
    });

    it('names the day in Nairobi time: 20:59:59Z is still the 27th, 21:00:00Z is the 28th', async () => {
      const at = (iso: string): Deps => ({ ...w.deps, now: () => new Date(iso) });
      const late = orderInput(w);
      await createOrderHandler(at('2026-10-27T20:59:59.000Z'), w.doctor, late);
      const next = orderInput(w);
      await createOrderHandler(at('2026-10-27T21:00:00.000Z'), w.doctor, next);
      assert.equal((await caseDoc(w, late.caseUid as string)).orderNumber, 'ODR-NK-AO-27102026-001');
      assert.equal((await caseDoc(w, next.caseUid as string)).orderNumber, 'ODR-NK-AO-28102026-001');
    });

    it('is for a verified doctor only', async () => {
      await w.deps.db.collection('doctors').doc(w.doctor.uid).update({ verificationStatus: 'Pending' });
      await refusedWith(createOrderHandler(w.deps, w.doctor, orderInput(w)), 'notVerified');
      assert.equal((await w.deps.db.collection('cases').get()).size, 0);
    });

    it('records no age for a patient without a date of birth, rather than a guess', async () => {
      await w.deps.db.collection('patients').doc(w.patientId).update({ dateOfBirth: '' });
      const input = orderInput(w);
      await createOrderHandler(w.deps, w.doctor, input);
      assert.equal((await caseDoc(w, input.caseUid as string)).patientAgeYears, -1);
    });

    it('refuses the 51st order of the day', async () => {
      await w.deps.db.collection('orderCounters').doc(`${w.doctor.uid}_20261027`).set({ count: 50 });
      await refusedWith(createOrderHandler(w.deps, w.doctor, orderInput(w)), 'dailyOrderLimit');
    });

    it('puts the doctor, the patient and the requested pathologist in the participants', async () => {
      const caseUid = await requestedCase(w);
      const doc = await caseDoc(w, caseUid);
      assert.deepEqual(new Set(doc.participantUids as string[]), new Set([w.doctor.uid, w.patient.uid, w.pathologist.uid]));
      assert.equal(doc.currentStage, 'PathologistRequested');
      assert.equal(doc.requestedPathologistUid, w.pathologist.uid);
      assert.equal(doc.patientAgeYears, 36);
      assert.equal(doc.doctorFacilityName, 'Test Hospital');
      const log = await w.deps.db.collection('cases').doc(caseUid).collection('log').get();
      assert.deepEqual(log.docs.map((d) => d.id).sort(), ['0001', '0002']);
    });

    it('waits at OrderCreated when no pathologist is named', async () => {
      const input = orderInput(w);
      await createOrderHandler(w.deps, w.doctor, input);
      const doc = await caseDoc(w, input.caseUid as string);
      assert.equal(doc.currentStage, 'OrderCreated');
      assert.deepEqual(doc.participantUids, [w.doctor.uid, w.patient.uid]);
    });

    it('records the events without an order number, and links the appointment', async () => {
      const caseUid = await requestedCase(w);
      const patientRow = await docData(w, noteId('orderCreated', `${caseUid}-r1`, w.patient.uid));
      const pathologistRow = await docData(w, noteId('pathologistRequested', `${caseUid}-r2`, w.pathologist.uid));
      assert.ok(patientRow);
      assert.ok(pathologistRow);
      assert.equal((pathologistRow.metadata as { actionStatus: string }).actionStatus, 'Pending');
      const orderNumber = String((await caseDoc(w, caseUid)).orderNumber);
      assert.ok(!JSON.stringify([patientRow, pathologistRow]).includes(orderNumber));
      assert.deepEqual((await docData(w, `appointments/${w.appointmentUid}`))?.caseUids, [caseUid]);
    });

    it('stores the payment, with an insurer from the list', async () => {
      const input = orderInput(w, {
        payment: { method: 'Insurance', insurerId: 'other', insurerName: ' Acacia  Mutual ', policyNumber: 'POL 123/4' },
      });
      await createOrderHandler(w.deps, w.doctor, input);
      const payment = await docData(w, `cases/${input.caseUid as string}/private/payment`);
      assert.equal(payment?.method, 'Insurance');
      assert.equal(payment?.insurerName, 'Acacia Mutual');
      assert.equal(payment?.policyNumber, 'POL 123/4');
    });

    it('refuses bad input with a stable reason', async () => {
      const refuse = (overrides: Record<string, unknown>, reason: string) =>
        refusedWith(createOrderHandler(w.deps, w.doctor, orderInput(w, overrides)), reason);
      await refuse({ caseUid: 'not-a-uuid' }, 'invalidCase');
      await refuse({ labTestIds: [] }, 'invalidTest');
      await refuse({ labTestIds: ['nope'] }, 'invalidTest');
      await refuse({ labTestIds: [HISTOLOGY, HISTOLOGY] }, 'invalidTest');
      await refuse({ priority: 'Now' }, 'invalidPriority');
      await refuse({ sampleCollectedAt: '2026-10-27T10:00:00.000Z' }, 'invalidCollectedAt');
      await refuse({ sampleCollectedAt: '2026-10-01T10:00:00.000Z' }, 'invalidCollectedAt');
      await refuse({ clinicalNotes: 'x'.repeat(2001) }, 'invalidNotes');
      await refuse({ sampleNotes: 'x'.repeat(1001) }, 'invalidNotes');
      await refuse({ payment: { method: 'Insurance', insurerId: 'sha' } }, 'invalidPayment');
      await refuse({ payment: { method: 'Barter' } }, 'invalidPayment');
      await refuse({ patientId: 'someone-else' }, 'notInCare');
      await refuse({ appointmentUid: 'missing' }, 'invalidAppointment');
      await refuse({ pathologistUid: w.colleague.uid }, 'invalidPathologist');
      await refuse({ pathologistUid: w.doctor.uid }, 'invalidPathologist');
    });

    it('refuses an appointment that is not this doctor’s, this patient’s or accepted', async () => {
      const db = w.deps.db;
      await db.collection('appointments').doc('theirs').set({ doctorUid: w.colleague.uid, patientId: w.patientId, status: 'Accepted' });
      await db.collection('appointments').doc('other-patient').set({ doctorUid: w.doctor.uid, patientId: 'x', status: 'Accepted' });
      await db.collection('appointments').doc('pending').set({ doctorUid: w.doctor.uid, patientId: w.patientId, status: 'Requested' });
      for (const appointmentUid of ['theirs', 'other-patient', 'pending']) {
        await refusedWith(createOrderHandler(w.deps, w.doctor, orderInput(w, { appointmentUid })), 'invalidAppointment');
      }
    });

    it('is idempotent on the client caseUid, and refuses another doctor’s', async () => {
      const input = orderInput(w);
      assert.deepEqual(await createOrderHandler(w.deps, w.doctor, input), { status: 'created', caseUid: input.caseUid });
      assert.deepEqual(await createOrderHandler(w.deps, w.doctor, input), { status: 'exists', caseUid: input.caseUid });
      assert.equal((await w.deps.db.collection('orderNumbers').get()).size, 1);
      await refusedWith(createOrderHandler(w.deps, w.colleague, input), 'caseExists');
    });
  });

  describe('assignment', () => {
    it('accepts: the pathologist joins, the worklist opens, the request row settles', async () => {
      const caseUid = await requestedCase(w);
      assert.deepEqual(await acceptCaseHandler(w.deps, w.pathologist, { caseUid }), { status: 'ok' });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PathologistAccepted');
      assert.equal(doc.pathologistUid, w.pathologist.uid);
      assert.equal(doc.pathologistName, 'Dr. Wanjiru Kamau');
      assert.equal(doc.requestedPathologistUid, '');
      const worklist = await docData(w, `worklist/${caseUid}`);
      assert.equal(worklist?.status, 'Open');
      assert.equal(worklist?.pathologistUid, w.pathologist.uid);
      const row = await docData(w, noteId('pathologistRequested', `${caseUid}-r2`, w.pathologist.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Accepted');
      assert.ok(await docData(w, noteId('pathologistAccepted', `${caseUid}-r3`, w.doctor.uid)));
      assert.ok(await docData(w, noteId('pathologistAcceptedPatient', `${caseUid}-r3`, w.patient.uid)));
    });

    it('accepting twice is ok and raises no second event', async () => {
      const caseUid = await acceptedCase(w);
      const seq = (await caseDoc(w, caseUid)).stageSeq;
      assert.deepEqual(await acceptCaseHandler(w.deps, w.pathologist, { caseUid }), { status: 'ok' });
      assert.equal((await caseDoc(w, caseUid)).stageSeq, seq);
    });

    it('only the requested pathologist accepts', async () => {
      const caseUid = await requestedCase(w);
      await refusedWith(acceptCaseHandler(w.deps, w.otherPathologist, { caseUid }), 'notRequested');
      await refusedWith(acceptCaseHandler(w.deps, w.doctor, { caseUid }), 'pathologistsOnly');
    });

    it('a request past its 24 hours returns to the doctor and tells the caller', async () => {
      const caseUid = await requestedCase(w);
      const stale = later(w.deps, 25 * HOUR);
      await refusedWith(acceptCaseHandler(stale, w.pathologist, { caseUid }), 'requestClosed');
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PathologistRejected');
      assert.deepEqual(doc.declinedPathologistUids, [w.pathologist.uid]);
      assert.equal(doc.pathologistUid, '');
      assert.ok(await docData(w, noteId('pathologistRequestExpired', `${caseUid}-r3`, w.doctor.uid)));
      const row = await docData(w, noteId('pathologistRequested', `${caseUid}-r2`, w.pathologist.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Expired');
    });

    it('queues a pre-read when the switch is on and slides are in', async () => {
      const on = { ...w.deps, config: { enabled: (key: string) => key === 'preread_enabled' } };
      const caseUid = await requestedCase({ ...w, deps: on });
      const reserved = await reserveSlideUploadsHandler(on, w.doctor, { caseUid, count: 2 });
      for (const imageUid of reserved.imageUids) await putSlide(caseUid, imageUid);
      await registerSlidesHandler(on, w.doctor, {
        caseUid,
        images: reserved.imageUids.map((imageUid) => ({ imageUid, contentType: 'image/jpeg', micronsPerPixel: 0.25 })),
      });
      await acceptCaseHandler(on, w.pathologist, { caseUid });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PrereadQueued');
      const runs = await w.deps.db.collection('cases').doc(caseUid).collection('preread').get();
      assert.equal(runs.size, 1);
      assert.equal(doc.prereadRunUid, runs.docs[0].id);
      assert.equal(runs.docs[0].get('status'), 'Queued');
      assert.equal(runs.docs[0].get('profile'), 'Cancer');
      assert.equal((await docData(w, `worklist/${caseUid}`))?.prereadStatus, 'Queued');
    });

    it('queues nothing when the switch is off or unreadable', async () => {
      for (const config of [undefined, { enabled: () => { throw new Error('unreadable'); } }]) {
        const deps = { ...w.deps, config };
        const caseUid = await requestedCase({ ...w, deps });
        const reserved = await reserveSlideUploadsHandler(deps, w.doctor, { caseUid, count: 1 });
        await putSlide(caseUid, reserved.imageUids[0]);
        await registerSlidesHandler(deps, w.doctor, {
          caseUid,
          images: [{ imageUid: reserved.imageUids[0], contentType: 'image/jpeg', micronsPerPixel: 0.25 }],
        });
        await acceptCaseHandler(deps, w.pathologist, { caseUid });
        assert.equal((await caseDoc(w, caseUid)).currentStage, 'PathologistAccepted');
        assert.equal((await w.deps.db.collection('cases').doc(caseUid).collection('preread').get()).size, 0);
      }
    });

    it('rejects: back to the doctor, declined, the pathologist out of the participants', async () => {
      const caseUid = await requestedCase(w);
      await rejectCaseHandler(w.deps, w.pathologist, { caseUid, reason: 'No capacity this week.' });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PathologistRejected');
      assert.deepEqual(doc.declinedPathologistUids, [w.pathologist.uid]);
      assert.equal(doc.requestedPathologistUid, '');
      assert.ok(!(doc.participantUids as string[]).includes(w.pathologist.uid));
      const log = await w.deps.db.collection('cases').doc(caseUid).collection('log').doc('0003').get();
      assert.equal(log.get('actionType'), 'Reject');
      assert.equal(log.get('actionReason'), 'No capacity this week.');
      assert.equal(log.get('patientVisible'), false);
      const row = await docData(w, noteId('pathologistRequested', `${caseUid}-r2`, w.pathologist.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Declined');
      assert.ok(await docData(w, noteId('pathologistRejected', `${caseUid}-r3`, w.doctor.uid)));
    });

    it('a repeated reject is ok, a stranger’s is refused, and a reason is needed', async () => {
      const caseUid = await requestedCase(w);
      await refusedWith(rejectCaseHandler(w.deps, w.pathologist, { caseUid, reason: '' }), 'invalidReason');
      await refusedWith(rejectCaseHandler(w.deps, w.otherPathologist, { caseUid, reason: 'x' }), 'notRequested');
      await rejectCaseHandler(w.deps, w.pathologist, { caseUid, reason: 'No.' });
      assert.deepEqual(await rejectCaseHandler(w.deps, w.pathologist, { caseUid, reason: 'No.' }), { status: 'ok' });
      await refusedWith(rejectCaseHandler(w.deps, w.otherPathologist, { caseUid, reason: 'x' }), 'notRequested');
    });

    it('requests another pathologist, never a declined one, and a repeat is ok', async () => {
      const caseUid = await requestedCase(w);
      await rejectCaseHandler(w.deps, w.pathologist, { caseUid, reason: 'No.' });
      await refusedWith(
        requestPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.pathologist.uid }),
        'pathologistDeclined',
      );
      await refusedWith(
        requestPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.colleague.uid }),
        'invalidPathologist',
      );
      await requestPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      const seq = (await caseDoc(w, caseUid)).stageSeq;
      await requestPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      assert.equal((await caseDoc(w, caseUid)).stageSeq, seq);
      await refusedWith(requestPathologistHandler(w.deps, w.colleague, { caseUid, pathologistUid: w.pathologist.uid }), 'notOnCase');
    });

    it('reassigns: the old pathologist is out of the participants and the worklist', async () => {
      const caseUid = await acceptedCase(w);
      await refusedWith(
        reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.pathologist.uid }),
        'samePathologist',
      );
      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PathologistRequested');
      assert.equal(doc.pathologistUid, '');
      assert.equal(doc.requestedPathologistUid, w.otherPathologist.uid);
      const people = doc.participantUids as string[];
      assert.ok(!people.includes(w.pathologist.uid));
      assert.ok(people.includes(w.otherPathologist.uid));
      const worklist = await docData(w, `worklist/${caseUid}`);
      assert.equal(worklist?.status, 'Closed');
      assert.equal(worklist?.pathologistUid, '');
      assert.ok(await docData(w, noteId('caseWithdrawn', `${caseUid}-r${doc.stageSeq as number}`, w.pathologist.uid)));
      assert.ok(await docData(w, noteId('pathologistRequested', `${caseUid}-r${doc.stageSeq as number}`, w.otherPathologist.uid)));
      const seq = doc.stageSeq;
      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      assert.equal((await caseDoc(w, caseUid)).stageSeq, seq);
    });

    it('reassigns a pending request and cancels the first pathologist’s row', async () => {
      const caseUid = await requestedCase(w);
      await reassignPathologistHandler(w.deps, w.doctor, { caseUid, pathologistUid: w.otherPathologist.uid });
      const doc = await caseDoc(w, caseUid);
      assert.ok(!(doc.participantUids as string[]).includes(w.pathologist.uid));
      const row = await docData(w, noteId('pathologistRequested', `${caseUid}-r2`, w.pathologist.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Cancelled');
    });
  });

  describe('recordSampleReceived', () => {
    it('records the accession once and accepts the same number again', async () => {
      const caseUid = await acceptedCase(w);
      await refusedWith(recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'bad number!' }), 'invalidAccession');
      await refusedWith(recordSampleReceivedHandler(w.deps, w.otherPathologist, { caseUid, labAccessionNo: 'A1' }), 'notOnCase');
      await recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'LAB/26-1' });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'SampleReceived');
      assert.equal(doc.labAccessionNo, 'LAB/26-1');
      assert.equal(doc.sampleReceivedAt, '2026-10-27T09:00:00.000Z');
      assert.deepEqual(await recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'LAB/26-1' }), { status: 'ok' });
      await refusedWith(recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'OTHER' }), 'alreadyReceived');
    });

    it('is refused before acceptance', async () => {
      const caseUid = await requestedCase(w);
      await refusedWith(recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'A1' }), 'notOnCase');
    });
  });

  describe('slides', () => {
    it('reserves up to 20, and returns what it holds when full', async () => {
      const caseUid = await requestedCase(w);
      await refusedWith(reserveSlideUploadsHandler(w.deps, w.doctor, { caseUid, count: 0 }), 'invalidCount');
      await refusedWith(reserveSlideUploadsHandler(w.deps, w.doctor, { caseUid, count: 21 }), 'invalidCount');
      await refusedWith(reserveSlideUploadsHandler(w.deps, w.pathologist, { caseUid, count: 1 }), 'notOnCase');
      const first = await reserveSlideUploadsHandler(w.deps, w.doctor, { caseUid, count: 20 });
      assert.equal(first.imageUids.length, 20);
      assert.equal(first.full, false);
      const full = await reserveSlideUploadsHandler(w.deps, w.doctor, { caseUid, count: 1 });
      assert.deepEqual(full, { imageUids: first.imageUids, full: true });
    });

    it('registers a slide once: reserved, uploaded and of the type it says', async () => {
      const caseUid = await requestedCase(w);
      const { imageUids } = await reserveSlideUploadsHandler(w.deps, w.doctor, { caseUid, count: 1 });
      const image = { imageUid: imageUids[0], contentType: 'image/jpeg', micronsPerPixel: 0.25 };
      await refusedWith(registerSlidesHandler(w.deps, w.doctor, { caseUid, images: [image] }), 'slideNotUploaded');
      await putSlide(caseUid, image.imageUid, 'image/png');
      await refusedWith(registerSlidesHandler(w.deps, w.doctor, { caseUid, images: [image] }), 'invalidSlides');
      await putSlide(caseUid, image.imageUid);
      const stranger = randomUUID();
      await putSlide(caseUid, stranger);
      await refusedWith(
        registerSlidesHandler(w.deps, w.doctor, { caseUid, images: [{ ...image, imageUid: stranger }] }),
        'slideNotReserved',
      );
      await registerSlidesHandler(w.deps, w.doctor, { caseUid, images: [image] });
      await registerSlidesHandler(w.deps, w.doctor, { caseUid, images: [image] });
      const doc = await caseDoc(w, caseUid);
      assert.deepEqual(doc.slideUploadUids, []);
      const slides = doc.slideImages as { imageUid: string; path: string; uploadedByUid: string }[];
      assert.equal(slides.length, 1);
      assert.equal(slides[0].path, `slides/${caseUid}/${image.imageUid}.jpg`);
      assert.equal(slides[0].uploadedByUid, w.doctor.uid);
      assert.equal(doc.currentStage, 'PathologistRequested');
    });

    it('the pathologist’s slides move the case to SlidesUploaded', async () => {
      const caseUid = await receivedCase(w);
      const { imageUids } = await reserveSlideUploadsHandler(w.deps, w.pathologist, { caseUid, count: 1 });
      await putSlide(caseUid, imageUids[0]);
      await registerSlidesHandler(w.deps, w.pathologist, {
        caseUid,
        images: [{ imageUid: imageUids[0], contentType: 'image/jpeg', micronsPerPixel: 0.5 }],
      });
      assert.equal((await caseDoc(w, caseUid)).currentStage, 'SlidesUploaded');
      const more = await reserveSlideUploadsHandler(w.deps, w.pathologist, { caseUid, count: 1 });
      await putSlide(caseUid, more.imageUids[0]);
      await registerSlidesHandler(w.deps, w.pathologist, {
        caseUid,
        images: [{ imageUid: more.imageUids[0], contentType: 'image/jpeg', micronsPerPixel: 0.5 }],
      });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'SlidesUploaded');
      assert.equal((doc.slideImages as unknown[]).length, 2);
    });
  });

  describe('slides by stage', () => {
    it('refuses a reservation or a registration once the pre-read is queued', async () => {
      const { caseUid, deps } = await prereadQueuedCase(w);
      await refusedWith(reserveSlideUploadsHandler(deps, w.pathologist, { caseUid, count: 1 }), 'invalidStage');
      const imageUid = randomUUID();
      await putSlide(caseUid, imageUid);
      await refusedWith(
        registerSlidesHandler(deps, w.pathologist, {
          caseUid,
          images: [{ imageUid, contentType: 'image/jpeg', micronsPerPixel: 0.25 }],
        }),
        'invalidStage',
      );
    });
  });

  describe('cancelOrder', () => {
    it('takes the four reasons the app offers, and no other', async () => {
      for (const reasonCode of ['SlotTaken', 'PathologistUnavailable', 'Expired', 'Patient']) {
        const caseUid = await requestedCase(w);
        await refusedWith(cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode }), 'invalidReason');
      }
      for (const reasonCode of ['OrderedInError', 'Duplicate', 'PatientDeclined', 'Other']) {
        const caseUid = await requestedCase(w);
        await cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode });
        assert.equal((await caseDoc(w, caseUid)).cancelReason, reasonCode);
      }
    });

    it('moves the stamp of every row it closes to the time it closed them', async () => {
      const caseUid = await acceptedCase(w);
      const shareUid = randomUUID();
      await createShareCodeHandler(w.deps, w.doctor, { shareUid, caseUid, recipientUid: w.colleague.uid });
      const hourOn = later(w.deps, HOUR);
      await recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'LAB/26-9' });
      const { imageUids } = await reserveSlideUploadsHandler(hourOn, w.pathologist, { caseUid, count: 1 });
      await putSlide(caseUid, imageUids[0]);
      await registerSlidesHandler(hourOn, w.pathologist, {
        caseUid,
        images: [{ imageUid: imageUids[0], contentType: 'image/jpeg', micronsPerPixel: 0.25 }],
      });
      assert.equal((await docData(w, `worklist/${caseUid}`))?.lastUpdatedAt, '2026-10-27T10:00:00.000Z');
      await cancelOrderHandler(later(w.deps, 2 * HOUR), w.doctor, { caseUid, reasonCode: 'Other' });
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.lastUpdatedAt, '2026-10-27T11:00:00.000Z');
      assert.equal((await docData(w, `worklist/${caseUid}`))?.lastUpdatedAt, '2026-10-27T11:00:00.000Z');
    });

    it('closes two pending shares in one transaction, with the counter and the rows', async () => {
      const caseUid = await acceptedCase(w);
      const shares = [randomUUID(), randomUUID()];
      await createShareCodeHandler(w.deps, w.doctor, { shareUid: shares[0], caseUid, recipientUid: w.colleague.uid });
      await createShareCodeHandler(w.deps, w.doctor, { shareUid: shares[1], caseUid, recipientUid: w.otherPathologist.uid });
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 2);

      await cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode: 'OrderedInError' });
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'Cancelled');
      assert.equal(doc.cancelReason, 'OrderedInError');
      for (const uid of shares) {
        assert.equal((await docData(w, `shareCodes/${uid}`))?.status, 'Revoked');
        assert.equal(await docData(w, `shareSecrets/${uid}`), undefined);
      }
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 0);
      const row = await docData(w, noteId('caseShared', shares[0], w.colleague.uid));
      assert.equal((row?.metadata as { actionStatus: string; shareCode: string }).actionStatus, 'Cancelled');
      assert.equal((row?.metadata as { shareCode: string }).shareCode, '');
      assert.equal((await docData(w, `worklist/${caseUid}`))?.status, 'Closed');
      const key = `${caseUid}-r${doc.stageSeq as number}`;
      assert.ok(await docData(w, noteId('orderCancelled', key, w.patient.uid)));
      assert.ok(await docData(w, noteId('orderCancelled', key, w.pathologist.uid)));
    });

    it('closes the open request row and the draft, and is ok a second time', async () => {
      const caseUid = await requestedCase(w);
      await cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode: 'Duplicate' });
      const row = await docData(w, noteId('pathologistRequested', `${caseUid}-r2`, w.pathologist.uid));
      assert.equal((row?.metadata as { actionStatus: string }).actionStatus, 'Cancelled');
      const seq = (await caseDoc(w, caseUid)).stageSeq;
      assert.deepEqual(await cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode: 'Duplicate' }), { status: 'ok' });
      assert.equal((await caseDoc(w, caseUid)).stageSeq, seq);
    });

    it('needs a patient-visible reason and the ordering doctor', async () => {
      const caseUid = await requestedCase(w);
      await refusedWith(cancelOrderHandler(w.deps, w.doctor, { caseUid, reasonCode: 'because' }), 'invalidReason');
      await refusedWith(cancelOrderHandler(w.deps, w.colleague, { caseUid, reasonCode: 'Other' }), 'notOnCase');
      await refusedWith(cancelOrderHandler(w.deps, w.pathologist, { caseUid, reasonCode: 'Other' }), 'doctorsOnly');
    });
  });

  describe('completeCase', () => {
    it('only follows a released result', async () => {
      const caseUid = await acceptedCase(w);
      await refusedWith(completeCaseHandler(w.deps, w.doctor, { caseUid }), 'invalidStage');
      await refusedWith(completeCaseHandler(w.deps, w.colleague, { caseUid }), 'notOnCase');
    });
  });

  describe('onCaseWritten', () => {
    function fakeAi(
      calls: CaseAiRequest[],
      reply: Partial<Awaited<ReturnType<AiClient['assessCase']>>> | Error,
    ): AiClient {
      return {
        assessCase(request) {
          calls.push(request);
          if (reply instanceof Error) return Promise.reject(reply);
          return Promise.resolve({
            inputLanguage: 'en',
            suggestedLabTestIds: [],
            advisoryKey: '',
            translation: { language: 'sw', text: 'Uvimbe kwenye titi la kushoto.' },
            models: { risk: 'fixture-1' },
            ...reply,
          });
        },
      };
    }

    async function written(deps = w.deps, notes = 'Lump in the left breast. Amina Otieno, 0712 345 678.') {
      const input = orderInput(w, { clinicalNotes: notes });
      await createOrderHandler(deps, w.doctor, input);
      const caseUid = input.caseUid as string;
      await onCaseWrittenHandler(deps, caseUid, undefined, await caseDoc(w, caseUid));
      return caseUid;
    }

    it('counts ordersCreated once, on the edge', async () => {
      const caseUid = await written();
      await onCaseWrittenHandler(w.deps, caseUid, undefined, await caseDoc(w, caseUid));
      assert.equal((await docData(w, `doctors/${w.doctor.uid}`))?.ordersCreated, 1);
      assert.ok(await docData(w, `counterMarks/ordersCreated:${caseUid}`));
    });

    it('fails closed: a switch that is off or unreadable calls no model and records Failed', async () => {
      for (const config of [undefined, { enabled: () => false }, { enabled: () => { throw new Error('unreadable'); } }]) {
        await resetEmulators();
        w = await seedWorld();
        const calls: CaseAiRequest[] = [];
        const caseUid = await written({ ...w.deps, config, ai: fakeAi(calls, {}) });
        assert.equal(calls.length, 0);
        const risk = await docData(w, `cases/${caseUid}/riskCheck/current`);
        const translation = await docData(w, `cases/${caseUid}/notesTranslation/current`);
        assert.equal(risk?.status, 'Failed');
        assert.equal(risk?.failureReason, 'Disabled');
        assert.equal(translation?.status, 'Failed');
      }
    });

    it('records Failed with the reason when the service errors, and never throws', async () => {
      const calls: CaseAiRequest[] = [];
      const deps = {
        ...w.deps,
        config: { enabled: (key: string) => key === 'risk_check_enabled' },
        ai: fakeAi(calls, new AiError('Timeout')),
      };
      const caseUid = await written(deps);
      assert.equal(calls.length, 1);
      const risk = await docData(w, `cases/${caseUid}/riskCheck/current`);
      assert.equal(risk?.status, 'Failed');
      assert.equal(risk?.failureReason, 'Timeout');
      assert.equal((await docData(w, `cases/${caseUid}/notesTranslation/current`))?.status, 'Failed');
      assert.equal((await docData(w, 'modelSignals/20261027'))?.riskCheckFailed, 1);

      const crashing = { ...deps, ai: fakeAi([], new Error('socket hang up')) };
      const second = await written(crashing);
      assert.equal((await docData(w, `cases/${second}/riskCheck/current`))?.failureReason, 'ServiceError');
    });

    it('sends the model de-identified notes only, and writes Ready from its checked output', async () => {
      const calls: CaseAiRequest[] = [];
      const ai = fakeAi(calls, {
        suggestedLabTestIds: ['unknown-test', HISTOLOGY, '9f7bb988-7068-4bc4-a7c5-08c690da9482'],
        advisoryKey: 'VhfProtocol',
      });
      const deps = { ...w.deps, config: { enabled: (key: string) => key === 'risk_check_enabled' }, ai };
      const caseUid = await written(deps);
      const orderNumber = String((await caseDoc(w, caseUid)).orderNumber);

      assert.equal(calls.length, 1);
      const sent = JSON.stringify(calls[0]);
      for (const secret of ['Amina', 'Otieno', '0712 345 678', orderNumber, w.patientId, w.patient.uid]) {
        assert.ok(!sent.includes(secret), `the request leaked ${secret === orderNumber ? 'the order number' : secret}`);
      }
      assert.equal(calls[0].ageBand, '25-44');
      assert.deepEqual(calls[0].labTestIds, [HISTOLOGY]);

      const risk = await docData(w, `cases/${caseUid}/riskCheck/current`);
      assert.equal(risk?.status, 'Ready');
      assert.deepEqual(risk?.suggestedLabTestIds, ['9f7bb988-7068-4bc4-a7c5-08c690da9482']);
      assert.equal(risk?.advisoryKey, 'VhfProtocol');
      assert.ok(String(risk?.advisoryEn).length > 0);
      assert.ok(String(risk?.advisorySw).length > 0);
      const translation = await docData(w, `cases/${caseUid}/notesTranslation/current`);
      assert.equal(translation?.status, 'Ready');
      assert.equal(translation?.language, 'sw');
      assert.equal((await caseDoc(w, caseUid)).notesLanguage, 'en');
    });

    it('takes an advisory key it does not know as no advisory, and bad output as Failed', async () => {
      const config = { enabled: (key: string) => key === 'risk_check_enabled' };
      const odd = await written({ ...w.deps, config, ai: fakeAi([], { advisoryKey: 'Free text from a model' }) });
      assert.equal((await docData(w, `cases/${odd}/riskCheck/current`))?.advisoryKey, '');
      const bad = await written({
        ...w.deps,
        config,
        ai: fakeAi([], { translation: { language: 'fr' as 'en', text: 'x' } }),
      });
      const risk = await docData(w, `cases/${bad}/riskCheck/current`);
      assert.equal(risk?.status, 'Failed');
      assert.equal(risk?.failureReason, 'OffSchema');
    });

    it('does not call the model again for notes it already translated', async () => {
      const calls: CaseAiRequest[] = [];
      const deps = { ...w.deps, config: { enabled: () => true }, ai: fakeAi(calls, {}) };
      const caseUid = await written(deps);
      const doc = await caseDoc(w, caseUid);
      await onCaseWrittenHandler(deps, caseUid, undefined, doc);
      await onCaseWrittenHandler(deps, caseUid, doc, doc);
      assert.equal(calls.length, 1);
    });

    it('runs again when the notes change while the order is editable', async () => {
      const calls: CaseAiRequest[] = [];
      const deps = { ...w.deps, config: { enabled: () => true }, ai: fakeAi(calls, {}) };
      const caseUid = await written(deps);
      const before = await caseDoc(w, caseUid);
      await w.deps.db.collection('cases').doc(caseUid).update({ clinicalNotes: 'A second lump.' });
      await onCaseWrittenHandler(deps, caseUid, before, await caseDoc(w, caseUid));
      assert.equal(calls.length, 2);
      assert.equal(calls[1].notes, 'A second lump.');
    });

    it('syncs readers on an update, as a backstop', async () => {
      const caseUid = await written();
      const doc = await caseDoc(w, caseUid);
      await onCaseWrittenHandler(w.deps, caseUid, doc, doc);
      assert.equal((await w.deps.db.collection('cases').doc(caseUid).collection('reports').get()).size, 0);
    });

    it('puts the readers of a signed version right when they have drifted', async () => {
      const signed = await signedCase(w);
      const report = w.deps.db.doc(`cases/${signed.caseUid}/reports/${signed.reportUid}`);
      await report.update({ readerUids: [w.pathologist.uid, 'someone-removed'] });
      const doc = await caseDoc(w, signed.caseUid);
      await onCaseWrittenHandler(w.deps, signed.caseUid, doc, doc);
      assert.deepEqual((await report.get()).get('readerUids'), [w.pathologist.uid]);
    });

    describe('what reaches the model', () => {
      const on = (calls: CaseAiRequest[]) => ({ ...w.deps, config: { enabled: () => true }, ai: fakeAi(calls, {}) });

      async function rewritten(notes: string, deps: Deps): Promise<string> {
        const caseUid = await written(deps);
        const before = await caseDoc(w, caseUid);
        await w.deps.db.collection('cases').doc(caseUid).update({ clinicalNotes: notes });
        await onCaseWrittenHandler(deps, caseUid, before, await caseDoc(w, caseUid));
        return caseUid;
      }

      it('masks the order number, record ids, uids, the facility and the contact in edited notes', async () => {
        const calls: CaseAiRequest[] = [];
        const first = orderInput(w);
        await createOrderHandler(w.deps, w.doctor, first);
        const orderNumber = String((await caseDoc(w, first.caseUid as string)).orderNumber);
        const notes = [
          `Lump, left breast. Order ${orderNumber.toLowerCase()}.`,
          `Record ${w.patientId}, patient ${w.patient.uid}, doctor ${w.doctor.uid}.`,
          `Seen at Test Hospital by Amina Otieno on 0712 345 678.`,
        ].join(' ');
        const deps = on(calls);
        const before = await caseDoc(w, first.caseUid as string);
        await w.deps.db.collection('cases').doc(first.caseUid as string).update({ clinicalNotes: notes });
        await onCaseWrittenHandler(deps, first.caseUid as string, before, await caseDoc(w, first.caseUid as string));

        assert.equal(calls.length, 1);
        const sent = calls[0].notes.toLowerCase();
        for (const secret of [orderNumber, w.patientId, w.patient.uid, w.doctor.uid, 'Test Hospital', 'Amina', 'Otieno', '0712']) {
          assert.ok(!sent.includes(secret.toLowerCase()), `the request leaked ${secret}`);
        }
        assert.ok(sent.includes('lump, left breast'));
      });

      it('cleans notes before masking them, so zero-width characters hide nothing', async () => {
        const calls: CaseAiRequest[] = [];
        await rewritten('Call 0712\u200b345\u200b678 about Amina\u200b Otieno\u202e.', on(calls));
        const sent = calls[1].notes;
        assert.ok(!/[\u200b\u202e]/.test(sent));
        for (const secret of ['0712', '345', 'Amina', 'Otieno']) assert.ok(!sent.includes(secret), `leaked ${secret}`);
      });

      it('sends no age band for a patient without a date of birth', async () => {
        await w.deps.db.collection('patients').doc(w.patientId).update({ dateOfBirth: '' });
        const calls: CaseAiRequest[] = [];
        await written(on(calls));
        assert.equal(calls[0].ageBand, '');
      });

      it('fails notes the cleaner cannot make short enough, without calling the model', async () => {
        const calls: CaseAiRequest[] = [];
        const caseUid = await rewritten('x'.repeat(2500), on(calls));
        assert.equal(calls.length, 1, 'only the first, valid, run reached the model');
        assert.equal((await docData(w, `cases/${caseUid}/notesTranslation/current`))?.failureReason, 'OffSchema');
      });
    });

    describe('a model that is slow, absent or late', () => {
      async function until(condition: () => boolean): Promise<void> {
        for (let i = 0; i < 500 && !condition(); i++) await new Promise((resolve) => setTimeout(resolve, 10));
        assert.ok(condition(), 'timed out waiting');
      }

      it('a late result of an older run never overwrites a newer one', async () => {
        const input = orderInput(w);
        await createOrderHandler(w.deps, w.doctor, input);
        const caseUid = input.caseUid as string;
        const waiting: { settle: (text: string, advisoryKey: string) => void }[] = [];
        const ai: AiClient = {
          assessCase: () =>
            new Promise((resolve) => {
              waiting.push({
                settle: (text, advisoryKey) =>
                  resolve({ inputLanguage: 'en', suggestedLabTestIds: [], advisoryKey, translation: { language: 'sw', text }, models: {} }),
              });
            }),
        };
        const deps = { ...w.deps, config: { enabled: () => true }, ai };
        const first = await caseDoc(w, caseUid);
        const olderRun = onCaseWrittenHandler(deps, caseUid, undefined, first);
        await until(() => waiting.length === 1);
        await w.deps.db.collection('cases').doc(caseUid).update({ clinicalNotes: 'A second lump.' });
        const newerRun = onCaseWrittenHandler(deps, caseUid, first, await caseDoc(w, caseUid));
        await until(() => waiting.length === 2);

        waiting[1].settle('Uvimbe wa pili.', '');
        await newerRun;
        waiting[0].settle('Uvimbe wa kwanza.', 'VhfProtocol');
        await olderRun;

        const translation = await docData(w, `cases/${caseUid}/notesTranslation/current`);
        assert.equal(translation?.text, 'Uvimbe wa pili.');
        assert.equal(translation?.sourceSha256, createHash('sha256').update('A second lump.').digest('hex'));
        assert.equal((await docData(w, `cases/${caseUid}/riskCheck/current`))?.advisoryKey, '');
      });

      it('a model that never answers is Failed with Timeout, and a redelivery does not ask again', async () => {
        const calls: CaseAiRequest[] = [];
        const ai: AiClient = {
          assessCase(request) {
            calls.push(request);
            return new Promise(() => undefined);
          },
        };
        const deps = { ...w.deps, config: { enabled: () => true }, ai, aiTimeoutMs: 20 };
        const caseUid = await written(deps);
        assert.equal((await docData(w, `cases/${caseUid}/notesTranslation/current`))?.failureReason, 'Timeout');
        assert.equal((await docData(w, `cases/${caseUid}/riskCheck/current`))?.failureReason, 'Timeout');
        await onCaseWrittenHandler(deps, caseUid, undefined, await caseDoc(w, caseUid));
        assert.equal(calls.length, 1);
      });

      it('a run left Running is not called again, and is failed as Stale once it is old', async () => {
        const calls: CaseAiRequest[] = [];
        const deps = { ...w.deps, config: { enabled: () => true }, ai: fakeAi(calls, {}) };
        const input = orderInput(w);
        await createOrderHandler(w.deps, w.doctor, input);
        const caseUid = input.caseUid as string;
        const record = w.deps.db.doc(`cases/${caseUid}/notesTranslation/current`);
        await record.set({
          uid: 'current',
          caseUid,
          status: 'Running',
          sourceSha256: createHash('sha256').update(String(input.clinicalNotes)).digest('hex'),
          requestedAt: '2026-10-27T09:00:00.000Z',
          lastUpdatedAt: '2026-10-27T09:00:00.000Z',
        });
        const doc = await caseDoc(w, caseUid);
        await onCaseWrittenHandler(deps, caseUid, undefined, doc);
        assert.equal((await record.get()).get('status'), 'Running');
        await onCaseWrittenHandler(later(deps, 3 * 60 * 1000), caseUid, undefined, doc);
        assert.equal((await record.get()).get('status'), 'Failed');
        assert.equal((await record.get()).get('failureReason'), 'Stale');
        assert.equal(calls.length, 0);
      });
    });
  });

  describe('sweepCases', () => {
    it('expires a request past its window, once', async () => {
      const stale = await requestedCase(w);
      const fresh = await requestedCase({ ...w, deps: later(w.deps, 2 * HOUR) });
      // `fresh` was ordered two hours after `stale`, so only `stale` is past 24 hours now.
      const deps = later(w.deps, REQUEST_WINDOW_MS + 1);
      const result = await sweepCasesHandler(deps);
      assert.equal(result.expiredRequests, 1);
      assert.equal((await caseDoc(w, stale)).currentStage, 'PathologistRejected');
      assert.equal((await caseDoc(w, fresh)).currentStage, 'PathologistRequested');
      assert.ok(await docData(w, noteId('pathologistRequestExpired', `${stale}-r3`, w.doctor.uid)));
      const again = await sweepCasesHandler(deps);
      assert.equal(again.expiredRequests, 0);
    });

    it('steps past an item that fails, and says so, so the ones behind it are still reached', async () => {
      const caseUid = await acceptedCase(w);
      const shares = [randomUUID(), randomUUID()];
      await createShareCodeHandler(w.deps, w.doctor, { shareUid: shares[0], caseUid, recipientUid: w.colleague.uid });
      await createShareCodeHandler(w.deps, w.doctor, { shareUid: shares[1], caseUid, recipientUid: w.otherPathologist.uid });
      let broke = false;
      const flaky = new Proxy(w.deps.db, {
        get(target, key) {
          const value: unknown = Reflect.get(target, key, target);
          if (key === 'runTransaction') {
            return (...args: unknown[]) => {
              if (!broke) {
                broke = true;
                return Promise.reject(new Error('transaction failed'));
              }
              return (value as (...a: unknown[]) => unknown).apply(target, args);
            };
          }
          return typeof value === 'function' ? (value as (...a: unknown[]) => unknown).bind(target) : value;
        },
      });
      const expired = later({ ...w.deps, db: flaky }, DAY_MS + 1);
      await assert.rejects(sweepCasesHandler(expired, 1), /1 item\(s\) failed/);
      const statuses = async () =>
        Promise.all(shares.map(async (uid) => (await docData(w, `shareCodes/${uid}`))?.status));
      assert.deepEqual((await statuses()).sort(), ['Expired', 'Pending']);
      assert.equal((await sweepCasesHandler(later(w.deps, DAY_MS + 1), 1)).expiredShares, 1);
      assert.deepEqual(await statuses(), ['Expired', 'Expired']);
    });

    it('fails an AI job that has sat Queued or Running for half an hour, and only that', async () => {
      const job = (path: string, status: string, requestedAt: string) =>
        w.deps.db.doc(path).set({ status, requestedAt, failureReason: '', lastUpdatedAt: requestedAt });
      const old = '2026-10-27T08:00:00.000Z';
      await job('cases/c1/preread/a', 'Queued', old);
      await job('cases/c1/preread/b', 'Running', old);
      await job('cases/c1/reportTexts/a', 'Queued', old);
      await job('cases/c1/reportTexts/b', 'Running', old);
      await job('cases/c1/preread/fresh', 'Queued', '2026-10-27T09:20:00.000Z');
      await job('cases/c1/preread/done', 'Ready', old);

      const result = await sweepCasesHandler(later(w.deps, 31 * 60 * 1000));
      assert.equal(result.staleJobs, 4);
      for (const path of ['preread/a', 'preread/b', 'reportTexts/a', 'reportTexts/b']) {
        const row = await docData(w, `cases/c1/${path}`);
        assert.equal(row?.status, 'Failed');
        assert.equal(row?.failureReason, 'Stale');
        assert.equal(row?.lastUpdatedAt, '2026-10-27T09:31:00.000Z');
      }
      assert.equal((await docData(w, 'cases/c1/preread/fresh'))?.status, 'Queued');
      assert.equal((await docData(w, 'cases/c1/preread/done'))?.status, 'Ready');
      assert.equal((await sweepCasesHandler(later(w.deps, 31 * 60 * 1000))).staleJobs, 0);
    });

    describe('a critical report nobody has opened', () => {
      const rows = (caseUid: string, day: number) => [
        noteId('criticalReportUnopened', `${caseUid}_v1-d${day}`, w.doctor.uid),
        noteId('criticalReportUnopenedSigner', `${caseUid}_v1-d${day}`, w.pathologist.uid),
      ];

      it('reminds the doctor and the signer each day, once per day, until it is opened', async () => {
        const signed = await signedCase(w, w.deps, { isCritical: true });
        const ordinary = await signedCase(w);
        assert.equal((await sweepCasesHandler(later(w.deps, 23 * HOUR))).criticalReminders, 0);

        const dayOne = later(w.deps, 25 * HOUR);
        assert.equal((await sweepCasesHandler(dayOne)).criticalReminders, 1);
        assert.equal((await docData(w, rows(signed.caseUid, 1)[0]))?.priority, 'High');
        assert.ok(await docData(w, rows(signed.caseUid, 1)[1]));
        assert.equal((await sweepCasesHandler(dayOne)).criticalReminders, 0, 'the same day is not repeated');

        assert.equal((await sweepCasesHandler(later(w.deps, 49 * HOUR))).criticalReminders, 1);
        assert.ok(await docData(w, rows(signed.caseUid, 2)[0]));
        assert.equal(await docData(w, noteId('criticalReportUnopened', `${ordinary.caseUid}_v1-d1`, w.doctor.uid)), undefined);

        await redeemShareCodeHandler(w.deps, w.doctor, {
          shareUid: `unlock_${signed.caseUid}_v1`,
          code: await unlockCodeOf(w, signed),
        });
        assert.equal((await sweepCasesHandler(later(w.deps, 73 * HOUR))).criticalReminders, 0);
        assert.equal(await docData(w, rows(signed.caseUid, 3)[0]), undefined);
      });

      it('stops when the case is cancelled', async () => {
        const signed = await signedCase(w, w.deps, { isCritical: true });
        await w.deps.db.collection('cases').doc(signed.caseUid).update({ currentStage: 'Cancelled' });
        assert.equal((await sweepCasesHandler(later(w.deps, 25 * HOUR))).criticalReminders, 0);
      });
    });

    it('closes an expired pending share as Expired', async () => {
      const caseUid = await acceptedCase(w);
      const shareUid = randomUUID();
      await createShareCodeHandler(w.deps, w.doctor, { shareUid, caseUid, recipientUid: w.colleague.uid });
      assert.equal((await sweepCasesHandler(w.deps)).expiredShares, 0);
      const result = await sweepCasesHandler(later(w.deps, DAY_MS + 1));
      assert.equal(result.expiredShares, 1);
      assert.equal((await docData(w, `shareCodes/${shareUid}`))?.status, 'Expired');
      assert.equal(await docData(w, `shareSecrets/${shareUid}`), undefined);
      assert.equal((await docData(w, `rateCounters/pendingShares:${caseUid}`))?.count, 0);
    });
  });
});
