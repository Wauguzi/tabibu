// cspell:ignore requestable
/**
 * Case handlers (plan §3.4, cases) and the case triggers (§3.5). Every handler is pure over
 * `deps`: it reads, checks, then writes inside one transaction, never the other way round (R-3).
 * Stages, participants and readers change only through `transition`, `commitCase` and
 * `syncCaseReaders`. No order number reaches a log line, a push, a prompt or an event.
 */
import {
  FieldValue,
  type DocumentData,
  type DocumentReference,
  type Query,
  type QueryDocumentSnapshot,
  type Transaction,
} from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';

import { syncCaseReaders } from './access';
import { AiError, ADVISORIES, withTimeout, type CaseAiRequest, type CaseAiResult, type NotesLanguage } from './ai';
import {
  AI_RUNNING_STALE_MS,
  DAY_MS,
  MAX_SLIDES,
  PREREAD_STALE_MS,
  OK,
  ageBand,
  ageYears,
  closeWorklist,
  declinedOf,
  displayName,
  expirePathologistRequest,
  idOf,
  insurerById,
  languageIn,
  languageOf,
  loadCase,
  loadRequestRow,
  loadVersions,
  loadWorklist,
  mintOrderNumber,
  newUid,
  nowOf,
  objectContentType,
  planNotes,
  queuePreread,
  requestFor,
  requireRole,
  requireRoleIn,
  sendNotes,
  sha256,
  slidesOf,
  strings,
  str,
  testIdsOf,
  upsertWorklist,
  uuidOf,
  type Deps,
} from './case-support';
import {
  DOCTORS,
  PATIENTS,
  PRACTITIONERS,
  boundedText,
  input,
  oneOf,
  refuse,
  timestamp,
  type Caller,
} from './common';
import { isEnabled } from './config';
import { closeCaseConversations, loadCaseConversations } from './conversations';
import { applyCounts, loadMarks } from './counters';
import { deidentify, type DeidentifySubject } from './deidentify';
import { labTestById, requiresSlides } from './lab-tests';
import { NotificationTx, type NotifyLanguage } from './notifications';
import {
  CaseState,
  ORDER_CANCEL_REASONS,
  commitCase,
  transition,
  type CaseStage,
} from './orchestrator';
import { buildQuery, queryById } from './queries';
import { sanitize } from './sanitize';
import { closeShare, loadShareClose, type LoadedShareClose } from './shares';
import { bumpModelSignal } from './signals';

const PRIORITIES = ['Routine', 'Priority', 'Urgent'] as const;
const MAX_TESTS = 10;
const EDITABLE_STAGES = new Set<CaseStage>(['OrderCreated', 'PathologistRequested', 'PathologistRejected']);
const SLIDE_STAGES = new Set<CaseStage>([
  'OrderCreated',
  'PathologistRequested',
  'PathologistRejected',
  'PathologistAccepted',
  'SampleReceived',
  'SlidesUploaded',
  'PrereadReady',
  'PrereadFailed',
]);

// --- Input -----------------------------------------------------------------------------------

function orderedTests(raw: unknown): { tests: DocumentData[]; total: number; estimate: boolean } {
  if (!Array.isArray(raw) || raw.length < 1 || raw.length > MAX_TESTS) {
    throw refuse('invalid-argument', 'invalidTest');
  }
  const ids = raw.map((x) => (typeof x === 'string' ? x : ''));
  if (new Set(ids).size !== ids.length) throw refuse('invalid-argument', 'invalidTest');
  const tests = ids.map((id) => {
    const test = labTestById(id);
    if (!test || !test.isActive) throw refuse('invalid-argument', 'invalidTest');
    return {
      labTestId: test.labTestId,
      testTypeId: test.testTypeId,
      testTypeName: test.testTypeName,
      name: test.name,
      priceKes: Math.round(test.testPriceKes),
      isPriceEstimate: test.isPriceEstimate,
    };
  });
  return {
    tests,
    total: tests.reduce((sum, t) => sum + t.priceKes, 0),
    estimate: tests.some((t) => t.isPriceEstimate),
  };
}

function paymentOf(raw: unknown, caseUid: string, uid: string, at: string): DocumentData {
  const p = input(raw);
  const method = oneOf(p.method ?? 'Cash', ['Cash', 'Insurance'] as const, 'invalidPayment');
  const row: DocumentData = {
    caseUid,
    method,
    insurerId: '',
    insurerName: '',
    policyNumber: '',
    createdByUid: uid,
    createdAt: at,
    lastUpdatedAt: at,
  };
  if (method === 'Cash') return row;
  const insurer = typeof p.insurerId === 'string' ? insurerById(p.insurerId) : undefined;
  if (!insurer) throw refuse('invalid-argument', 'invalidPayment');
  const policy = typeof p.policyNumber === 'string' ? p.policyNumber.trim() : '';
  if (!/^[A-Za-z0-9/ -]{3,30}$/.test(policy)) throw refuse('invalid-argument', 'invalidPayment');
  row.insurerId = insurer.insurerId;
  row.policyNumber = policy;
  row.insurerName =
    insurer.insurerId === 'other' ? boundedText(p.insurerName, 2, 80, 'invalidPayment') : insurer.name;
  return row;
}

function notesOf(raw: unknown, max: number): string {
  if (raw === undefined || raw === null || raw === '') return '';
  if (typeof raw !== 'string') throw refuse('invalid-argument', 'invalidNotes');
  try {
    return sanitize(raw, max);
  } catch {
    throw refuse('invalid-argument', 'invalidNotes');
  }
}

function collectedAt(raw: unknown, now: Date): string {
  const ms = typeof raw === 'string' ? Date.parse(raw) : Number.NaN;
  if (!Number.isFinite(ms) || ms > now.getTime() || ms < now.getTime() - 7 * DAY_MS) {
    throw refuse('invalid-argument', 'invalidCollectedAt');
  }
  return new Date(ms).toISOString();
}

function optionalId(raw: unknown, reason: string): string {
  return raw === undefined || raw === '' ? '' : idOf(raw, reason);
}

/** A pathologist the doctor may ask: verified and listed, accepting cases, not the caller. */
async function requestablePathologist(
  tx: Transaction,
  deps: Deps,
  uid: string,
  doctorUid: string,
  declined: string[],
): Promise<{ name: string; language: NotifyLanguage }> {
  if (declined.includes(uid)) throw refuse('failed-precondition', 'pathologistDeclined');
  const listed = (await tx.get(deps.db.collection(PRACTITIONERS).doc(uid))).data();
  if (!listed || listed.isPathologist !== true || listed.isAvailable === false || uid === doctorUid) {
    throw refuse('failed-precondition', 'invalidPathologist');
  }
  return { name: displayName(listed), language: await languageOf(tx, deps.db, DOCTORS, uid) };
}

// --- createOrder -----------------------------------------------------------------------------

export async function createOrderHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'created' | 'exists'; caseUid: string }> {
  const c = requireRole(caller, 'doctor');
  const raw = input(data);
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const appointmentUid = idOf(raw.appointmentUid, 'invalidAppointment');
  const patientId = idOf(raw.patientId, 'notInCare');
  const ordered = orderedTests(raw.labTestIds);
  const priority = oneOf(raw.priority ?? 'Routine', PRIORITIES, 'invalidPriority');
  const sampleCollectedAt = collectedAt(raw.sampleCollectedAt, now);
  const clinicalNotes = notesOf(raw.clinicalNotes, 2000);
  const sampleNotes = notesOf(raw.sampleNotes, 1000);
  const pathologistUid = optionalId(raw.pathologistUid, 'invalidPathologist');
  const payment = paymentOf(raw.payment, caseUid, c.uid, at);
  const testIds = ordered.tests.map((t) => str(t.labTestId));
  const { db } = deps;
  const caseRef = db.collection('cases').doc(caseUid);

  return db.runTransaction(async (tx) => {
    const existing = await tx.get(caseRef);
    if (existing.exists) {
      if (existing.get('doctorUid') === c.uid) return { status: 'exists' as const, caseUid };
      throw refuse('already-exists', 'caseExists');
    }
    const doctor = (await tx.get(db.collection(DOCTORS).doc(c.uid))).data();
    if (!doctor || doctor.verificationStatus !== 'Verified') throw refuse('permission-denied', 'notVerified');
    const patient = (await tx.get(db.collection(PATIENTS).doc(patientId))).data();
    if (!patient || !strings(patient.doctorUids).includes(c.uid)) {
      throw refuse('failed-precondition', 'notInCare');
    }
    const appointment = (await tx.get(db.collection('appointments').doc(appointmentUid))).data();
    if (
      !appointment ||
      appointment.doctorUid !== c.uid ||
      appointment.patientId !== patientId ||
      !['Accepted', 'Completed'].includes(str(appointment.status))
    ) {
      throw refuse('failed-precondition', 'invalidAppointment');
    }
    const requested = pathologistUid
      ? await requestablePathologist(tx, deps, pathologistUid, c.uid, [])
      : null;

    const patientUid = str(patient.uid);
    const patientName = [patient.firstName, patient.middleName, patient.lastName]
      .filter((p): p is string => typeof p === 'string' && p.trim() !== '')
      .join(' ');
    let s = CaseState.initial({
      uid: caseUid,
      orderNumber: '',
      appointmentUid,
      createdByUid: c.uid,
      doctorUid: c.uid,
      doctorName: displayName(doctor),
      doctorFacilityName: str(doctor.facilityName),
      patientId,
      patientUid,
      patientName,
      patientSex: str(patient.sex),
      patientAgeYears: ageYears(str(patient.dateOfBirth), now),
      declinedPathologistUids: [],
      viewerUids: [],
      participantUids: [],
      tests: ordered.tests,
      totalPriceKes: ordered.total,
      isPriceEstimate: ordered.estimate,
      priority,
      clinicalNotes,
      sampleNotes,
      notesLanguage: '',
      sampleCollectedAt,
      sampleReceivedAt: '',
      labAccessionNo: '',
      requiresSlides: requiresSlides(testIds),
      slideUploadUids: [],
      slideImages: [],
      prereadRunUid: '',
      currentReportUid: '',
      resultState: 'Pending',
      discussionAppointmentUid: '',
      releasedToPatient: false,
      discussedAt: '',
      releasedAt: '',
      cancelReason: '',
      createdAt: at,
    });
    s = transition(s, 'OrderCreated', { actorUid: c.uid, actorRole: 'Doctor' });
    const orderSeq = s.stageSeq;
    if (requested) {
      s = transition(s, 'PathologistRequested', {
        actorUid: c.uid,
        actorRole: 'Doctor',
        requested: requestFor(pathologistUid, requested.name, now),
      });
    }

    // The order number is minted last: it reads, then writes.
    const notes = await planNotes(tx, db, [
      {
        template: 'orderCreated',
        resourceKey: `${caseUid}-r${orderSeq}`,
        caseUid,
        recipientUid: patientUid,
        recipientRole: 'patient',
        language: languageIn(patient),
      },
      requested
        ? {
            template: 'pathologistRequested',
            resourceKey: `${caseUid}-r${s.stageSeq}`,
            caseUid,
            recipientUid: pathologistUid,
            recipientRole: 'pathologist',
            language: requested.language,
            expiresAt: s.pathologistRequestExpiresAt,
          }
        : null,
    ]);
    const orderNumber = await mintOrderNumber(
      tx,
      db,
      { uid: c.uid, firstName: str(doctor.firstName), lastName: str(doctor.lastName) },
      {
        firstName: str(patient.firstName),
        middleName: str(patient.middleName),
        lastName: str(patient.lastName),
      },
      now,
    );
    s = s.with({ orderNumber });

    commitCase(tx, caseRef, s, now);
    tx.create(caseRef.collection('private').doc('payment'), payment);
    tx.update(db.collection('appointments').doc(appointmentUid), {
      caseUids: FieldValue.arrayUnion(caseUid),
      lastUpdatedAt: at,
    });
    sendNotes(tx, notes, now);
    return { status: 'created' as const, caseUid };
  });
}

// --- Pathologist assignment ------------------------------------------------------------------

function ownCase(c: Caller, s: CaseState): void {
  if (s.doctorUid !== c.uid) throw refuse('permission-denied', 'notOnCase');
}

export async function requestPathologistHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'doctor');
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const pathologistUid = idOf(raw.pathologistUid, 'invalidPathologist');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    ownCase(c, s);
    if (s.currentStage === 'PathologistRequested' && s.requestedPathologistUid === pathologistUid) return OK;
    const requested = await requestablePathologist(tx, deps, pathologistUid, c.uid, declinedOf(s));
    const next = transition(s, 'PathologistRequested', {
      actorUid: c.uid,
      actorRole: 'Doctor',
      requested: requestFor(pathologistUid, requested.name, now),
    });
    const notes = await planNotes(tx, db, [
      {
        template: 'pathologistRequested',
        resourceKey: `${caseUid}-r${next.stageSeq}`,
        caseUid,
        recipientUid: pathologistUid,
        recipientRole: 'pathologist',
        language: requested.language,
        expiresAt: next.pathologistRequestExpiresAt,
      },
    ]);
    commitCase(tx, ref, next, now);
    sendNotes(tx, notes, now);
    return OK;
  });
}

export async function acceptCaseHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'pathologist');
  const caseUid = uuidOf(input(data).caseUid, 'invalidCase');
  const now = nowOf(deps);
  const at = timestamp(now);
  const { db } = deps;
  const prereadOn = isEnabled(deps.config, 'preread_enabled');

  const closed = await db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    if (s.pathologistUid === c.uid) return false;
    if (s.requestedPathologistUid !== c.uid) throw refuse('permission-denied', 'notRequested');
    if (s.currentStage !== 'PathologistRequested') throw refuse('failed-precondition', 'invalidStage');

    const row = await loadRequestRow(tx, db, ref, s);
    const worklist = await loadWorklist(tx, db, caseUid);
    const risk = (await tx.get(ref.collection('riskCheck').doc('current'))).data();
    const pathologist = (await tx.get(db.collection(DOCTORS).doc(c.uid))).data();
    const doctorLanguage = await languageOf(tx, db, DOCTORS, s.doctorUid);
    const patientLanguage = languageIn((await tx.get(db.collection(PATIENTS).doc(str(s.fields.patientId)))).data());

    if (s.pathologistRequestExpiresAt <= at) {
      const expired = expirePathologistRequest(s);
      const notes = await planNotes(tx, db, [
        {
          template: 'pathologistRequestExpired',
          resourceKey: `${caseUid}-r${expired.stageSeq}`,
          caseUid,
          recipientUid: s.doctorUid,
          recipientRole: 'doctor',
          language: doctorLanguage,
        },
      ]);
      commitCase(tx, ref, expired, now);
      if (row) NotificationTx.settle(tx, row, 'Expired', '', now);
      sendNotes(tx, notes, now);
      return true;
    }

    const accepted = transition(s, 'PathologistAccepted', { actorUid: c.uid, actorRole: 'Pathologist' }).with({
      pathologistUid: c.uid,
      pathologistName: displayName(pathologist),
      pathologistAcceptedAt: at,
    });
    const acceptedSeq = accepted.stageSeq;
    const notes = await planNotes(tx, db, [
      {
        template: 'pathologistAccepted',
        resourceKey: `${caseUid}-r${acceptedSeq}`,
        caseUid,
        recipientUid: s.doctorUid,
        recipientRole: 'doctor',
        language: doctorLanguage,
      },
      {
        template: 'pathologistAcceptedPatient',
        resourceKey: `${caseUid}-r${acceptedSeq}`,
        caseUid,
        recipientUid: s.patientUid,
        recipientRole: 'patient',
        language: patientLanguage,
      },
    ]);

    const next = queuePreread(tx, ref, accepted, now, prereadOn);
    commitCase(tx, ref, next, now);
    upsertWorklist(
      tx,
      worklist,
      next,
      {
        status: 'Open',
        prereadStatus: next.currentStage === 'PrereadQueued' ? 'Queued' : '',
        riskFlag: risk?.status === 'Ready' && str(risk.advisoryKey) !== '',
      },
      now,
      { reopen: true },
    );
    if (row) NotificationTx.settle(tx, row, 'Accepted', c.uid, now);
    sendNotes(tx, notes, now);
    return false;
  });

  // The window had closed: the case went back to the doctor, and this caller is told so.
  if (closed) throw refuse('failed-precondition', 'requestClosed');
  return OK;
}

export async function rejectCaseHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'pathologist');
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const reason = notesOf(boundedText(raw.reason, 1, 500, 'invalidReason'), 500);
  if (reason === '') throw refuse('invalid-argument', 'invalidReason');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    if (s.requestedPathologistUid !== c.uid || s.currentStage !== 'PathologistRequested') {
      // The stage has moved on. Only someone who already declined hears "ok".
      if (declinedOf(s).includes(c.uid)) return OK;
      throw refuse('permission-denied', 'notRequested');
    }
    const row = await loadRequestRow(tx, db, ref, s);
    const doctorLanguage = await languageOf(tx, db, DOCTORS, s.doctorUid);
    const next = transition(s, 'PathologistRejected', {
      actorUid: c.uid,
      actorRole: 'Pathologist',
      action: 'Reject',
      reason,
    }).with({ declinedPathologistUids: [...new Set([...declinedOf(s), c.uid])] });
    const notes = await planNotes(tx, db, [
      {
        template: 'pathologistRejected',
        resourceKey: `${caseUid}-r${next.stageSeq}`,
        caseUid,
        recipientUid: s.doctorUid,
        recipientRole: 'doctor',
        language: doctorLanguage,
      },
    ]);
    commitCase(tx, ref, next, now);
    if (row) NotificationTx.settle(tx, row, 'Declined', c.uid, now);
    sendNotes(tx, notes, now);
    return OK;
  });
}

export async function reassignPathologistHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'doctor');
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const pathologistUid = idOf(raw.pathologistUid, 'invalidPathologist');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    ownCase(c, s);
    if (s.currentStage === 'PathologistRequested' && s.requestedPathologistUid === pathologistUid) return OK;
    const old = s.pathologistUid || s.requestedPathologistUid;
    if (old === pathologistUid) throw refuse('invalid-argument', 'samePathologist');
    const requested = await requestablePathologist(tx, deps, pathologistUid, c.uid, declinedOf(s));
    const row = await loadRequestRow(tx, db, ref, s);
    const worklist = await loadWorklist(tx, db, caseUid);
    const oldLanguage = await languageOf(tx, db, DOCTORS, old);
    const threads = await loadCaseConversations(tx, db, caseUid, { uid: old });

    const next = transition(s, 'PathologistRequested', {
      actorUid: c.uid,
      actorRole: 'Doctor',
      action: 'Reassign',
      requested: requestFor(pathologistUid, requested.name, now),
    }).with({ prereadRunUid: '' });
    const notes = await planNotes(tx, db, [
      {
        template: 'caseWithdrawn',
        resourceKey: `${caseUid}-r${next.stageSeq}`,
        caseUid,
        recipientUid: old,
        recipientRole: 'pathologist',
        language: oldLanguage,
      },
      {
        template: 'pathologistRequested',
        resourceKey: `${caseUid}-r${next.stageSeq}`,
        caseUid,
        recipientUid: pathologistUid,
        recipientRole: 'pathologist',
        language: requested.language,
        expiresAt: next.pathologistRequestExpiresAt,
      },
    ]);
    commitCase(tx, ref, next, now);
    if (row) NotificationTx.settle(tx, row, 'Cancelled', c.uid, now);
    closeWorklist(tx, worklist, now);
    closeCaseConversations(tx, threads, now);
    sendNotes(tx, notes, now);
    return OK;
  });
}

// --- Sample and slides -----------------------------------------------------------------------

export async function recordSampleReceivedHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'pathologist');
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const accession = typeof raw.labAccessionNo === 'string' ? raw.labAccessionNo.trim() : '';
  if (!/^[A-Za-z0-9/-]{1,30}$/.test(accession)) throw refuse('invalid-argument', 'invalidAccession');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    if (s.pathologistUid !== c.uid) throw refuse('permission-denied', 'notOnCase');
    if (s.currentStage === 'PathologistAccepted') {
      // A reassign lands the new pathologist here with the old accession still on
      // the case: the same number or a new one both receive the sample, and the
      // stage moves so a report can start.
      const next = transition(s, 'SampleReceived', {
        actorUid: c.uid,
        actorRole: 'Pathologist',
      }).with({ sampleReceivedAt: timestamp(now), labAccessionNo: accession });
      commitCase(tx, ref, next, now);
      return OK;
    }
    if (s.labAccessionNo === accession) return OK;
    if (s.labAccessionNo !== '') throw refuse('failed-precondition', 'alreadyReceived');
    const next = transition(s, s.currentStage, {
      actorUid: c.uid,
      actorRole: 'Pathologist',
      action: 'Receive',
    }).with({ sampleReceivedAt: timestamp(now), labAccessionNo: accession });
    commitCase(tx, ref, next, now);
    return OK;
  });
}

/** Before acceptance the ordering doctor handles slides; after it, the accepted pathologist does. */
function slideHandler(c: Caller, s: CaseState): 'doctor' | 'pathologist' {
  if (c.role === 'doctor' && s.doctorUid === c.uid && s.pathologistUid === '') return 'doctor';
  if (c.role === 'pathologist' && s.pathologistUid === c.uid) return 'pathologist';
  throw refuse('permission-denied', 'notOnCase');
}

function slideGuard(s: CaseState): void {
  if (!s.requiresSlides) throw refuse('failed-precondition', 'slidesNotRequired');
  if (!SLIDE_STAGES.has(s.currentStage)) throw refuse('failed-precondition', 'invalidStage');
}

export async function reserveSlideUploadsHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ imageUids: string[]; full: boolean }> {
  const c = requireRoleIn(caller, ['doctor', 'pathologist']);
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const count = raw.count;
  if (typeof count !== 'number' || !Number.isInteger(count) || count < 1 || count > MAX_SLIDES) {
    throw refuse('invalid-argument', 'invalidCount');
  }
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    slideHandler(c, s);
    slideGuard(s);
    const reserved = strings(s.fields.slideUploadUids);
    if (reserved.length + slidesOf(s).length + count > MAX_SLIDES) {
      return { imageUids: reserved, full: true };
    }
    const fresh = Array.from({ length: count }, () => newUid());
    tx.update(ref, { slideUploadUids: [...reserved, ...fresh], lastUpdatedAt: timestamp(now) });
    return { imageUids: fresh, full: false };
  });
}

interface SlideInput {
  imageUid: string;
  contentType: 'image/jpeg' | 'image/png';
  micronsPerPixel: number;
}

function slideInputs(raw: unknown): SlideInput[] {
  if (!Array.isArray(raw) || raw.length < 1 || raw.length > MAX_SLIDES) {
    throw refuse('invalid-argument', 'invalidSlides');
  }
  const seen = new Set<string>();
  return raw.map((entry) => {
    const e = input(entry);
    const imageUid = uuidOf(e.imageUid, 'invalidSlides');
    const contentType = oneOf(e.contentType, ['image/jpeg', 'image/png'] as const, 'invalidSlides');
    const microns = e.micronsPerPixel;
    if (typeof microns !== 'number' || !Number.isFinite(microns) || microns <= 0 || microns > 100) {
      throw refuse('invalid-argument', 'invalidSlides');
    }
    if (seen.has(imageUid)) throw refuse('invalid-argument', 'invalidSlides');
    seen.add(imageUid);
    return { imageUid, contentType, micronsPerPixel: microns };
  });
}

function slidePath(caseUid: string, slide: SlideInput): string {
  return `slides/${caseUid}/${slide.imageUid}.${slide.contentType === 'image/png' ? 'png' : 'jpg'}`;
}

export async function registerSlidesHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRoleIn(caller, ['doctor', 'pathologist']);
  const raw = input(data);
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const slides = slideInputs(raw.images);
  const { db } = deps;

  // Storage is not transactional, so the objects are checked first; reservation is checked inside.
  for (const slide of slides) {
    const type = await objectContentType(deps.bucket, slidePath(caseUid, slide));
    if (type === null) throw refuse('failed-precondition', 'slideNotUploaded');
    if (type !== slide.contentType) throw refuse('invalid-argument', 'invalidSlides');
  }

  return db.runTransaction(async (tx) => {
    const loaded = await loadCase(tx, db, caseUid);
    const who = slideHandler(c, loaded.s);
    slideGuard(loaded.s);
    const worklist = await loadWorklist(tx, db, caseUid);
    const reserved = strings(loaded.s.fields.slideUploadUids);
    const registered = slidesOf(loaded.s);
    const known = new Set(registered.map((i) => str(i.imageUid)));
    const fresh = slides.filter((slide) => !known.has(slide.imageUid));
    if (fresh.length === 0) return OK;
    if (fresh.some((slide) => !reserved.includes(slide.imageUid))) {
      throw refuse('failed-precondition', 'slideNotReserved');
    }
    if (registered.length + fresh.length > MAX_SLIDES) throw refuse('failed-precondition', 'tooManySlides');

    const taken = new Set(fresh.map((slide) => slide.imageUid));
    let s = loaded.s.with({
      slideUploadUids: reserved.filter((uid) => !taken.has(uid)),
      slideImages: [
        ...registered,
        ...fresh.map((slide) => ({
          imageUid: slide.imageUid,
          path: slidePath(caseUid, slide),
          contentType: slide.contentType,
          micronsPerPixel: slide.micronsPerPixel,
          uploadedByUid: c.uid,
          uploadedAt: at,
        })),
      ],
    });

    if (who === 'pathologist') {
      const actor = { actorUid: c.uid, actorRole: 'Pathologist' } as const;
      switch (s.currentStage) {
        case 'PathologistAccepted':
        case 'SampleReceived':
          s = transition(s, 'SlidesUploaded', actor);
          break;
        case 'SlidesUploaded':
          s = transition(s, 'SlidesUploaded', { ...actor, action: 'AddSlides' });
          break;
        case 'PrereadReady':
        case 'PrereadFailed':
          s = transition(s, 'SlidesUploaded', { ...actor, action: 'AddSlides' });
          break;
        default:
          throw refuse('failed-precondition', 'invalidStage');
      }
      s = queuePreread(tx, loaded.ref, s, now, isEnabled(deps.config, 'preread_enabled'));
      upsertWorklist(
        tx,
        worklist,
        s,
        s.currentStage === 'PrereadQueued' ? { prereadStatus: 'Queued' } : {},
        now,
      );
    }
    commitCase(tx, loaded.ref, s, now);
    return OK;
  });
}

// --- Cancel, complete, viewers ---------------------------------------------------------------

export async function cancelOrderHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'doctor');
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const reasonCode = oneOf(raw.reasonCode, [...ORDER_CANCEL_REASONS], 'invalidReason');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    ownCase(c, s);
    if (s.currentStage === 'Cancelled') return OK;

    const shares = await tx.get(buildQuery(db, queryById('shareCodes.byCase'), [caseUid]));
    const open: LoadedShareClose[] = [];
    for (const share of shares.docs) {
      if (share.get('status') === 'Pending') open.push(await loadShareClose(tx, db, share.id));
    }
    const row = await loadRequestRow(tx, db, ref, s);
    const worklist = await loadWorklist(tx, db, caseUid);
    const draftRef = s.pathologistUid
      ? ref.collection('reportDrafts').doc(s.pathologistUid)
      : null;
    const draft = draftRef ? await tx.get(draftRef) : null;
    const pathologistUid = s.pathologistUid || s.requestedPathologistUid;
    const pathologistLanguage = await languageOf(tx, db, DOCTORS, pathologistUid);
    const patientLanguage = languageIn((await tx.get(db.collection(PATIENTS).doc(str(s.fields.patientId)))).data());
    const threads = await loadCaseConversations(tx, db, caseUid, 'all');

    const next = transition(s, 'Cancelled', {
      actorUid: c.uid,
      actorRole: 'Doctor',
      action: 'Cancel',
      reason: reasonCode,
    }).with({ cancelReason: reasonCode });
    const key = `${caseUid}-r${next.stageSeq}`;
    const notes = await planNotes(tx, db, [
      {
        template: 'orderCancelled',
        resourceKey: key,
        caseUid,
        recipientUid: s.patientUid,
        recipientRole: 'patient',
        language: patientLanguage,
      },
      {
        template: 'orderCancelled',
        resourceKey: key,
        caseUid,
        recipientUid: pathologistUid,
        recipientRole: 'pathologist',
        language: pathologistLanguage,
      },
    ]);

    commitCase(tx, ref, next, now);
    for (const loaded of open) closeShare(tx, db, loaded, 'Revoked', now);
    if (draftRef && draft?.exists && draft.get('status') === 'Editing') {
      tx.update(draftRef, { status: 'Closed', lastUpdatedAt: timestamp(now) });
    }
    closeWorklist(tx, worklist, now);
    if (row) NotificationTx.settle(tx, row, 'Cancelled', c.uid, now);
    closeCaseConversations(tx, threads, now);
    sendNotes(tx, notes, now);
    return OK;
  });
}

export async function completeCaseHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'doctor');
  const now = nowOf(deps);
  const caseUid = uuidOf(input(data).caseUid, 'invalidCase');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    ownCase(c, s);
    if (s.currentStage === 'Completed') return OK;
    commitCase(tx, ref, transition(s, 'Completed', { actorUid: c.uid, actorRole: 'Doctor' }), now);
    return OK;
  });
}

export async function removeCaseViewerHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRoleIn(caller, ['doctor', 'patient']);
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const viewerUid = idOf(raw.viewerUid, 'invalidViewer');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    const asPatient = c.role === 'patient' && s.patientUid === c.uid;
    const asDoctor = c.role === 'doctor' && s.doctorUid === c.uid;
    if (!asPatient && !asDoctor) throw refuse('permission-denied', 'notOnCase');
    if (!s.viewerUids.includes(viewerUid)) return OK;
    const versions = await loadVersions(tx, ref);
    const next = transition(s.with({ viewerUids: s.viewerUids.filter((uid) => uid !== viewerUid) }), s.currentStage, {
      actorUid: c.uid,
      actorRole: asPatient ? 'Patient' : 'Doctor',
      action: 'RemoveViewer',
    });
    // Someone who is still the doctor or pathologist keeps their place in the threads.
    const stays = next.doctorUid === viewerUid || next.pathologistUid === viewerUid;
    const threads = await loadCaseConversations(tx, db, caseUid, stays ? { uid: '' } : { uid: viewerUid });
    commitCase(tx, ref, next, now);
    syncCaseReaders(tx, next, versions.map((v) => v.access), now);
    closeCaseConversations(tx, threads, now);
    return OK;
  });
}

// --- onCaseWritten ---------------------------------------------------------------------------

const AI_REASONS = new Set(['Disabled', 'Timeout', 'ServiceError', 'OffSchema', 'Stale']);

function writeAiFailure(
  tx: Transaction,
  deps: Deps,
  caseRef: DocumentReference,
  caseUid: string,
  sha: string,
  reason: string,
  now: Date,
  signal: boolean,
): void {
  const at = timestamp(now);
  // readyAt is the completion stamp: the daily aggregator queries by it for failures too.
  tx.set(caseRef.collection('riskCheck').doc('current'), {
    uid: 'current',
    caseUid,
    status: 'Failed',
    inputLanguage: '',
    suggestedLabTestIds: [],
    advisoryKey: '',
    advisoryEn: '',
    advisorySw: '',
    models: {},
    failureReason: reason,
    requestedAt: at,
    readyAt: at,
    lastUpdatedAt: at,
  });
  tx.set(caseRef.collection('notesTranslation').doc('current'), {
    uid: 'current',
    caseUid,
    status: 'Failed',
    sourceLanguage: '',
    language: '',
    sourceSha256: sha,
    text: '',
    models: {},
    failureReason: reason,
    requestedAt: at,
    readyAt: at,
    lastUpdatedAt: at,
  });
  if (signal) {
    bumpModelSignal(tx, deps.db, 'riskCheckFailed', now);
    bumpModelSignal(tx, deps.db, 'notesTranslationFailed', now);
  }
}

interface AiClaim {
  request: CaseAiRequest;
  sha: string;
  requestedAt: string;
}

/** What the model may see of a case: de-identified notes, banded age, county, test ids (S-5). */
function aiRequest(s: CaseState, patient: DocumentData | undefined, now: Date): CaseAiRequest {
  const subject: DeidentifySubject = {
    firstName: str(patient?.firstName),
    middleName: str(patient?.middleName),
    lastName: str(patient?.lastName),
    phoneNumber: str(patient?.phoneNumber),
    email: str(patient?.email),
    dateOfBirth: str(patient?.dateOfBirth),
    county: str(patient?.county),
    subCounty: str(patient?.subCounty),
    facilityName: str(s.fields.doctorFacilityName),
    orderNumber: str(s.fields.orderNumber),
    labAccessionNo: str(s.fields.labAccessionNo),
    ids: [s.uid, s.patientUid, s.doctorUid, str(s.fields.patientId), str(s.fields.appointmentUid)],
  };
  return {
    labTestIds: testIdsOf(s),
    sex: str(patient?.sex),
    ageBand: ageBand(ageYears(str(patient?.dateOfBirth), now)),
    county: str(patient?.county),
    // A client may have rewritten the notes since createOrder cleaned them (R-6).
    notes: deidentify(sanitize(str(s.fields.clinicalNotes), 2000), subject),
  };
}

/**
 * Checks the model's output against the code's own tables: unknown tests drop, an advisory is a
 * key into the template table and never free text (S-7), and the translation is cleaned.
 */
function checkAiResult(result: CaseAiResult, ordered: string[]): CaseAiResult & { advisoryEn: string; advisorySw: string } {
  const languages = ['en', 'sw', 'mixed', ''] as const;
  const inputLanguage = languages.includes(result.inputLanguage) ? result.inputLanguage : null;
  const t = result.translation as { language?: unknown; text?: unknown } | undefined;
  if (
    inputLanguage === null ||
    !Array.isArray(result.suggestedLabTestIds) ||
    typeof result.advisoryKey !== 'string' ||
    !t ||
    (t.language !== 'en' && t.language !== 'sw') ||
    typeof t.text !== 'string'
  ) {
    throw new AiError('OffSchema');
  }
  let text: string;
  try {
    text = sanitize(t.text, 4000);
  } catch {
    throw new AiError('OffSchema');
  }
  const advisory = ADVISORIES[result.advisoryKey];
  const suggested = [...new Set(result.suggestedLabTestIds)].filter(
    (id) => typeof id === 'string' && labTestById(id) !== undefined && !ordered.includes(id),
  );
  const models: Record<string, string> = {};
  for (const [key, value] of Object.entries(result.models ?? {})) {
    if (typeof value === 'string') models[key] = value.slice(0, 80);
  }
  return {
    inputLanguage,
    suggestedLabTestIds: suggested,
    advisoryKey: advisory ? result.advisoryKey : '',
    translation: { language: t.language, text },
    models,
    advisoryEn: advisory?.en ?? '',
    advisorySw: advisory?.sw ?? '',
  };
}

async function runCaseAi(deps: Deps, caseUid: string): Promise<void> {
  const { db } = deps;
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseRef = db.collection('cases').doc(caseUid);
  const switchOn = isEnabled(deps.config, 'risk_check_enabled');
  const ai = deps.ai;

  const claim = await db.runTransaction(async (tx): Promise<AiClaim | null> => {
    const snap = await tx.get(caseRef);
    if (!snap.exists) return null;
    const s = CaseState.from(snap);
    const patient = (await tx.get(db.collection(PATIENTS).doc(str(s.fields.patientId)))).data();
    const translation = await tx.get(caseRef.collection('notesTranslation').doc('current'));
    const sha = sha256(str(s.fields.clinicalNotes));
    const status = str(translation.get('status'));
    const sameNotes = translation.get('sourceSha256') === sha;
    if (sameNotes && (status === 'Ready' || status === 'Failed')) return null;
    // A redelivery never calls the service again (R-5): a run in flight is left to finish, and
    // one that has been `Running` too long is failed for the people waiting on it.
    if (sameNotes && status === 'Running') {
      const started = Date.parse(str(translation.get('requestedAt')));
      if (!Number.isFinite(started) || now.getTime() - started >= AI_RUNNING_STALE_MS) {
        writeAiFailure(tx, deps, caseRef, caseUid, sha, 'Stale', now, true);
      }
      return null;
    }

    // R-8: a switch that is off, or cannot be read, starts no job.
    if (!switchOn || !ai) {
      writeAiFailure(tx, deps, caseRef, caseUid, sha, switchOn ? 'ServiceError' : 'Disabled', now, false);
      return null;
    }
    const base = { caseUid, requestedAt: at, lastUpdatedAt: at, uid: 'current' };
    tx.set(caseRef.collection('riskCheck').doc('current'), {
      ...base,
      status: 'Running',
      inputLanguage: '',
      suggestedLabTestIds: [],
      advisoryKey: '',
      advisoryEn: '',
      advisorySw: '',
      models: {},
      failureReason: '',
      readyAt: '',
    });
    tx.set(caseRef.collection('notesTranslation').doc('current'), {
      ...base,
      status: 'Running',
      sourceLanguage: '',
      language: '',
      sourceSha256: sha,
      text: '',
      models: {},
      failureReason: '',
      readyAt: '',
    });
    let request: CaseAiRequest;
    try {
      request = aiRequest(s, patient, now);
    } catch {
      writeAiFailure(tx, deps, caseRef, caseUid, sha, 'OffSchema', now, true);
      return null;
    }
    return { request, sha, requestedAt: at };
  });
  if (!claim || !ai) return;

  // The call is outside any transaction. Any error is a Failed record, never a retry (F-10).
  let checked: ReturnType<typeof checkAiResult> | null = null;
  let failure = '';
  try {
    checked = checkAiResult(
      await withTimeout(ai.assessCase(claim.request), deps.aiTimeoutMs),
      claim.request.labTestIds,
    );
  } catch (e) {
    failure = e instanceof AiError && AI_REASONS.has(e.reason) ? e.reason : 'ServiceError';
  }

  await db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    const worklist = await loadWorklist(tx, db, caseUid);
    // A result is kept only while it is still the run the record is waiting for, on the notes the
    // case still holds; an older run finishing late must not overwrite a newer one.
    const record = await tx.get(ref.collection('notesTranslation').doc('current'));
    const current =
      record.get('status') === 'Running' &&
      record.get('sourceSha256') === claim.sha &&
      record.get('requestedAt') === claim.requestedAt &&
      sha256(str(s.fields.clinicalNotes)) === claim.sha;
    if (!current) return;
    const ready = checked;
    if (!ready) {
      writeAiFailure(tx, deps, ref, caseUid, claim.sha, failure, now, true);
      return;
    }
    const done = timestamp(now);
    tx.set(ref.collection('riskCheck').doc('current'), {
      uid: 'current',
      caseUid,
      status: 'Ready',
      inputLanguage: ready.inputLanguage,
      suggestedLabTestIds: ready.suggestedLabTestIds,
      advisoryKey: ready.advisoryKey,
      advisoryEn: ready.advisoryEn,
      advisorySw: ready.advisorySw,
      models: ready.models,
      failureReason: '',
      requestedAt: claim.requestedAt,
      readyAt: done,
      lastUpdatedAt: done,
    });
    tx.set(ref.collection('notesTranslation').doc('current'), {
      uid: 'current',
      caseUid,
      status: 'Ready',
      sourceLanguage: ready.inputLanguage,
      language: ready.translation.language,
      sourceSha256: claim.sha,
      text: ready.translation.text,
      models: ready.models,
      failureReason: '',
      requestedAt: claim.requestedAt,
      readyAt: done,
      lastUpdatedAt: done,
    });
    if (str(s.fields.notesLanguage) !== ready.inputLanguage) {
      commitCase(tx, ref, s.with({ notesLanguage: ready.inputLanguage satisfies NotesLanguage }), now);
    }
    upsertWorklist(tx, worklist, s, { riskFlag: ready.advisoryKey !== '' }, now);
  });
}

/**
 * The one case trigger. The counter and the readers backstop are idempotent on a redelivery; the
 * AI run is guarded by the notes hash. Only a Firestore error propagates, so only it retries.
 */
export async function onCaseWrittenHandler(
  deps: Deps,
  caseUid: string,
  before: DocumentData | undefined,
  after: DocumentData | undefined,
): Promise<void> {
  if (!after) return;
  const { db } = deps;
  const now = nowOf(deps);

  if (!before) {
    await db.runTransaction(async (tx) => {
      const marks = await loadMarks(tx, db, [{ counter: 'ordersCreated', resourceUid: caseUid }]);
      applyCounts(
        tx,
        marks,
        [
          {
            counter: 'ordersCreated',
            resourceUid: caseUid,
            targetRef: db.collection(DOCTORS).doc(str(after.doctorUid)),
            field: 'ordersCreated',
          },
        ],
        now,
      );
    });
  }

  const notesChanged = before !== undefined && str(before.clinicalNotes) !== str(after.clinicalNotes);
  if (!before || (notesChanged && EDITABLE_STAGES.has(str(after.currentStage) as CaseStage))) {
    await runCaseAi(deps, caseUid);
  }

  if (before) {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(db.collection('cases').doc(caseUid));
      if (!snap.exists) return;
      const versions = await loadVersions(tx, snap.ref);
      syncCaseReaders(tx, CaseState.from(snap), versions.map((v) => v.access), now);
    });
  }
}

// --- sweepCases ------------------------------------------------------------------------------

export interface SweepResult {
  expiredRequests: number;
  expiredShares: number;
  staleJobs: number;
  criticalReminders: number;
}

export const SWEEP_LIMIT = 100;
const SWEEP_PAGES = 5;

/**
 * Runs `handle` over a query one page at a time, each item in its own transaction. A failing item
 * is counted and stepped past, so it can never keep the items behind it from being reached.
 */
async function sweepKind(
  query: Query,
  pageSize: number,
  handle: (doc: QueryDocumentSnapshot) => Promise<boolean>,
): Promise<{ done: number; failed: number }> {
  let done = 0;
  let failed = 0;
  let cursor: QueryDocumentSnapshot | undefined;
  for (let page = 0; page < SWEEP_PAGES; page++) {
    const snap = await (cursor ? query.startAfter(cursor) : query).limit(pageSize).get();
    for (const doc of snap.docs) {
      try {
        if (await handle(doc)) done += 1;
      } catch {
        failed += 1;
      }
    }
    if (snap.size < pageSize) break;
    cursor = snap.docs[snap.size - 1];
  }
  return { done, failed };
}

/** A stuck AI job is failed so the person waiting can retry; nothing here calls the service. */
async function failStaleJob(deps: Deps, doc: QueryDocumentSnapshot, cutoff: string, now: Date): Promise<boolean> {
  return deps.db.runTransaction(async (tx) => {
    const fresh = await tx.get(doc.ref);
    const status = str(fresh.get('status'));
    if ((status !== 'Queued' && status !== 'Running') || str(fresh.get('requestedAt')) > cutoff) return false;
    const at = timestamp(now);
    tx.update(doc.ref, { status: 'Failed', failureReason: 'Stale', readyAt: at, lastUpdatedAt: at });
    return true;
  });
}

/**
 * A critical report nobody has opened reminds the doctor and the signer once a day, the day
 * number in the key making each reminder idempotent. It stops when the doctor opens it, the
 * version is superseded, or the case is cancelled.
 */
async function remindCritical(deps: Deps, doc: QueryDocumentSnapshot, now: Date): Promise<boolean> {
  const { db } = deps;
  const caseRef = doc.ref.parent.parent;
  if (!caseRef) return false;
  return db.runTransaction(async (tx) => {
    const report = (await tx.get(doc.ref)).data();
    const caseData = (await tx.get(caseRef)).data();
    if (!report || !caseData) return false;
    const signedAt = Date.parse(str(report.signedAt));
    const day = Math.floor((now.getTime() - signedAt) / DAY_MS);
    if (
      report.isCritical !== true ||
      str(report.doctorOpenedAt) !== '' ||
      report.status !== 'Signed' ||
      str(caseData.currentReportUid) !== doc.id ||
      str(caseData.currentStage) === 'Cancelled' ||
      !Number.isFinite(signedAt) ||
      day < 1
    ) {
      return false;
    }
    const doctorUid = str(report.doctorUid);
    const signerUid = str(report.pathologistUid);
    const key = `${caseRef.id}_${doc.id}-d${day}`;
    const notes = await planNotes(tx, db, [
      {
        template: 'criticalReportUnopened',
        resourceKey: key,
        caseUid: caseRef.id,
        recipientUid: doctorUid,
        recipientRole: 'doctor',
        language: await languageOf(tx, db, DOCTORS, doctorUid),
        resourceUid: doc.id,
        deepLink: `/cases/${caseRef.id}/reports/${doc.id}`,
      },
      {
        template: 'criticalReportUnopenedSigner',
        resourceKey: key,
        caseUid: caseRef.id,
        recipientUid: signerUid,
        recipientRole: 'pathologist',
        language: await languageOf(tx, db, DOCTORS, signerUid),
        resourceUid: doc.id,
        deepLink: `/cases/${caseRef.id}/reports/${doc.id}`,
      },
    ]);
    if (notes.every((n) => n.loaded.exists)) return false;
    sendNotes(tx, notes, now);
    return true;
  });
}

/** One transaction per item, each re-checking its own condition. A failure is counted, not hidden. */
export async function sweepCasesHandler(deps: Deps, pageSize: number = SWEEP_LIMIT): Promise<SweepResult> {
  const { db } = deps;
  const now = nowOf(deps);
  const at = timestamp(now);
  const result: SweepResult = { expiredRequests: 0, expiredShares: 0, staleJobs: 0, criticalReminders: 0 };
  let failures = 0;
  const tally = (r: { done: number; failed: number }): number => {
    failures += r.failed;
    return r.done;
  };

  result.expiredRequests = tally(
    await sweepKind(buildQuery(db, queryById('cases.requestExpired'), ['PathologistRequested', at]), pageSize, (doc) =>
      db.runTransaction(async (tx) => {
        const { ref, s } = await loadCase(tx, db, doc.id);
        if (
          s.currentStage !== 'PathologistRequested' ||
          s.pathologistRequestExpiresAt === '' ||
          s.pathologistRequestExpiresAt > at
        ) {
          return false;
        }
        const row = await loadRequestRow(tx, db, ref, s);
        const language = await languageOf(tx, db, DOCTORS, s.doctorUid);
        const next = expirePathologistRequest(s);
        const notes = await planNotes(tx, db, [
          {
            template: 'pathologistRequestExpired',
            resourceKey: `${s.uid}-r${next.stageSeq}`,
            caseUid: s.uid,
            recipientUid: s.doctorUid,
            recipientRole: 'doctor',
            language,
          },
        ]);
        commitCase(tx, ref, next, now);
        if (row) NotificationTx.settle(tx, row, 'Expired', '', now);
        sendNotes(tx, notes, now);
        return true;
      }),
    ),
  );

  result.expiredShares = tally(
    await sweepKind(buildQuery(db, queryById('shareCodes.pendingExpired'), ['Pending', at]), pageSize, (doc) =>
      db.runTransaction(async (tx) => {
        const loaded = await loadShareClose(tx, db, doc.id);
        if (!loaded.share || loaded.share.status !== 'Pending' || loaded.share.expiresAt > at) return false;
        closeShare(tx, db, loaded, 'Expired', now);
        return true;
      }),
    ),
  );

  const cutoff = timestamp(new Date(now.getTime() - PREREAD_STALE_MS));
  for (const id of ['preread.stale', 'reportTexts.stale']) {
    for (const status of ['Queued', 'Running']) {
      result.staleJobs += tally(
        await sweepKind(buildQuery(db, queryById(id), [status, cutoff]), pageSize, (doc) =>
          failStaleJob(deps, doc, cutoff, now),
        ),
      );
    }
  }

  const dayAgo = timestamp(new Date(now.getTime() - DAY_MS));
  result.criticalReminders = tally(
    await sweepKind(
      buildQuery(db, queryById('reports.criticalUnopened'), [true, 'Signed', '', dayAgo]),
      pageSize,
      (doc) => remindCritical(deps, doc, now),
    ),
  );

  if (failures > 0) {
    logger.error('sweepCases: items failed', { failures });
    throw new Error(`sweepCases: ${failures} item(s) failed`);
  }
  return result;
}
