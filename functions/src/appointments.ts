// cspell:ignore Muhtasari
/**
 * Appointments (plan §3.4 "Appointments", §3.5 `onAppointmentWritten` and `expireAppointments`).
 * A patient books a doctor, or time to discuss a signed result; the doctor answers. Every state
 * change is a callable or a trigger: clients write nothing on `appointments`.
 *
 * Booking has one lock, the doctor's own document. Accepting reads `busySlots` there and writes it
 * in the same transaction, so two accepts of one slot serialise and exactly one succeeds.
 */
import {
  FieldValue,
  type DocumentData,
  type DocumentReference,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';

import { idOf, languageIn, newUid, requireRole, str, uuidOf, displayName } from './case-support';
import { applyCounts, loadMarks, type CountTarget, type MarkSpec } from './counters';
import {
  Caller,
  DOCTORS,
  PATIENTS,
  NAIROBI_OFFSET_MS,
  input,
  nairobiDayKey,
  oneOf,
  refuse,
  timestamp,
} from './common';
import { isEnabled } from './config';
import { availabilityOf } from './identity';
import { deidentify, type DeidentifySubject } from './deidentify';
import { withTimeout } from './ai-domain';
import { NotificationTx, type LoadedNotification } from './notifications';
import {
  CaseState,
  closeDiscussion,
  commitCase,
  transition,
} from './orchestrator';
import { buildQuery, queryById } from './queries';
import {
  DAY_MS,
  HOUR_MS,
  MINUTE_MS,
  editDistance,
  loadRate,
  loadRow,
  nowOf,
  planNotes,
  sendNotes,
  storageOf,
  ttlAt,
  writeRate,
  type NoteSpec,
  type RuntimeDeps,
} from './runtime-deps';
import { sanitize } from './sanitize';
import { bumpModelSignal } from './signals';

export type AppointmentDeps = RuntimeDeps;

export const APPOINTMENTS = 'appointments';
export const SLOT_MINUTES = 30;
export const HORIZON_DAYS = 31;
export const REPLY_WINDOW_MS = 24 * HOUR_MS;
export const MIN_LEAD_MS = 60 * MINUTE_MS;
export const MAX_PENDING = 5;
export const INTAKE_STALE_MS = 30 * MINUTE_MS;
export const SPEECH_AUDIO_MAX_AGE_MS = HOUR_MS;
export const TRANSCRIBE_PER_DAY = 20;
export const SPEECH_MAX_BYTES = 1536 * 1024;
export const SPEECH_PAGE = 500;

const SLOT_MS = SLOT_MINUTES * MINUTE_MS;
const SWEEP_LIMIT = 100;
const SIBLING_LIMIT = 20;
const AUDIO_TYPES = ['audio/wav'];
const APPOINTMENT_TYPES = ['Consultation', 'CaseDiscussion'] as const;
const DECLINE_REASONS = ['SlotUnavailable', 'OutsidePractice', 'ReferredElsewhere', 'Other'] as const;

type AppointmentType = (typeof APPOINTMENT_TYPES)[number];

// --- Slots -----------------------------------------------------------------------------------

/** A slot start on the 30-minute grid: seconds and milliseconds zero, minutes a multiple of 30. */
function slotStart(raw: unknown): Date {
  if (typeof raw !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?Z$/.test(raw)) {
    throw refuse('invalid-argument', 'invalidSlot');
  }
  const start = new Date(raw);
  if (
    Number.isNaN(start.getTime()) ||
    start.getUTCSeconds() !== 0 ||
    start.getUTCMilliseconds() !== 0 ||
    start.getUTCMinutes() % SLOT_MINUTES !== 0
  ) {
    throw refuse('invalid-argument', 'invalidSlot');
  }
  return start;
}

/** Nairobi's ISO weekday (1 Monday … 7 Sunday) and minute of the day. */
function nairobiClock(instant: Date): { weekday: number; minute: number } {
  const shifted = new Date(instant.getTime() + NAIROBI_OFFSET_MS);
  const day = shifted.getUTCDay();
  return { weekday: day === 0 ? 7 : day, minute: shifted.getUTCHours() * 60 + shifted.getUTCMinutes() };
}

/** The same hours the picker shows: `availabilityOf` replaces a malformed field with its default. */
function withinHours(doctor: DocumentData, start: Date, now: Date): boolean {
  const { workingDays, dayStartMinute, dayEndMinute } = availabilityOf(doctor, now);
  const { weekday, minute } = nairobiClock(start);
  return workingDays.includes(weekday) && minute >= dayStartMinute && minute + SLOT_MINUTES <= dayEndMinute;
}

/** `aStart < bEnd && bStart < aEnd`, which on one grid with one length is "the same start". */
function overlaps(busy: string[], start: Date): boolean {
  const end = start.getTime() + SLOT_MS;
  return busy.some((raw) => {
    const other = Date.parse(raw);
    return !Number.isNaN(other) && other < end && start.getTime() < other + SLOT_MS;
  });
}

/** Past slots are invisible to the picker and dropped on every write that touches the list. */
function liveSlots(doctor: DocumentData, now: Date): string[] {
  const list = Array.isArray(doctor.busySlots)
    ? doctor.busySlots.filter((s): s is string => typeof s === 'string')
    : [];
  return list.filter((s) => Date.parse(s) >= now.getTime());
}

function sortedSlots(slots: string[]): string[] {
  return [...new Set(slots)].sort();
}

// --- Shared reads ----------------------------------------------------------------------------

function approvalTemplate(type: string): string {
  return type === 'CaseDiscussion' ? 'caseDiscussionRequested' : 'appointmentRequested';
}

function patientByUid(db: Firestore, uid: string) {
  return buildQuery(db, queryById('patients.byUid'), [uid]).limit(1);
}

interface LoadedCase {
  ref: DocumentReference;
  s: CaseState;
}

/** The case a discussion belongs to, read before any write so `closeDiscussion` can run later. */
async function loadDiscussionCase(
  tx: Transaction,
  db: Firestore,
  appointment: DocumentData,
): Promise<LoadedCase | null> {
  const caseUid = str(appointment.discussedCaseUid);
  if (appointment.type !== 'CaseDiscussion' || caseUid === '') return null;
  const ref = db.collection('cases').doc(caseUid);
  const snap = await tx.get(ref);
  return snap.exists ? { ref, s: CaseState.from(snap) } : null;
}

/** Returns the case to the doctor only when this appointment is the one it is waiting on (F-3). */
function closeDiscussionOf(
  tx: Transaction,
  loaded: LoadedCase | null,
  appointmentUid: string,
  action: 'Reject' | 'Expire' | 'Cancel' | 'Complete' | 'NoShow',
  reason: string,
  actor: { uid: string; role: 'Doctor' | 'Patient' | 'System' },
  now: Date,
): void {
  if (!loaded) return;
  const next = closeDiscussion(loaded.s, appointmentUid, {
    actorUid: actor.uid,
    actorRole: actor.role,
    action,
    reason,
  });
  if (next !== loaded.s) commitCase(tx, loaded.ref, next, now);
}

function conversationRef(db: Firestore, appointmentUid: string): DocumentReference {
  return db.collection('conversations').doc(`appt_${appointmentUid}`);
}

function closeThread(
  tx: Transaction,
  ref: DocumentReference,
  thread: DocumentData | undefined,
  now: Date,
): void {
  if (!thread || thread.status !== 'Open') return;
  const at = timestamp(now);
  tx.update(ref, { status: 'Closed', closedAt: at, lastUpdatedAt: at });
}

function note(
  template: string,
  appointmentUid: string,
  recipientUid: string,
  recipientRole: 'doctor' | 'patient',
  language: 'en' | 'sw',
  extra: Partial<NoteSpec> = {},
): NoteSpec {
  return {
    template,
    resourceKey: appointmentUid,
    threadUid: appointmentUid,
    resourceUid: appointmentUid,
    recipientUid,
    recipientRole,
    language,
    deepLink: `/appointments/${appointmentUid}`,
    ...extra,
  };
}

function emptyDraft(): DocumentData {
  return { chiefComplaint: '', symptoms: [], duration: '', redFlags: [], summary: '', isTranslation: false };
}

function subjectOf(patient: DocumentData | undefined): DeidentifySubject {
  return {
    firstName: str(patient?.firstName),
    middleName: str(patient?.middleName),
    lastName: str(patient?.lastName),
    phoneNumber: str(patient?.phoneNumber),
    email: str(patient?.email),
    dateOfBirth: str(patient?.dateOfBirth),
    county: str(patient?.county),
    subCounty: str(patient?.subCounty),
  };
}

function symptomInput(raw: unknown, type: AppointmentType): string {
  if (raw !== undefined && typeof raw !== 'string') throw refuse('invalid-argument', 'invalidSymptoms');
  const text = sanitize(typeof raw === 'string' ? raw : '', 2000);
  if (type === 'Consultation' && [...text].length < 10) throw refuse('invalid-argument', 'invalidSymptoms');
  return text;
}

// --- requestAppointment ----------------------------------------------------------------------

export async function requestAppointmentHandler(
  deps: AppointmentDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string; appointmentUid: string }> {
  const c = requireRole(caller, 'patient');
  const raw = input(data);
  const now = nowOf(deps);
  const appointmentUid = uuidOf(raw.appointmentUid, 'invalidAppointment');
  const type = oneOf(raw.type, APPOINTMENT_TYPES, 'invalidAppointment');
  const inputMode = raw.inputMode === undefined ? 'Typed' : oneOf(raw.inputMode, ['Typed', 'Voice'] as const, 'invalidInputMode');
  if (inputMode === 'Voice' && type !== 'Consultation') throw refuse('invalid-argument', 'invalidInputMode');
  const transcriptionUid = inputMode === 'Voice' ? uuidOf(raw.transcriptionUid, 'invalidTranscription') : '';
  const symptomText = symptomInput(raw.symptomText, type);
  const start = slotStart(raw.scheduledStart);
  if (
    start.getTime() < now.getTime() + MIN_LEAD_MS ||
    start.getTime() > now.getTime() + HORIZON_DAYS * DAY_MS
  ) {
    throw refuse('invalid-argument', 'invalidSlot');
  }
  const consultationDoctor = type === 'Consultation' ? idOf(raw.doctorUid, 'invalidAppointment') : '';
  const caseUid = type === 'CaseDiscussion' ? idOf(raw.caseUid, 'invalidAppointment') : '';

  const { db } = deps;
  const ref = db.collection(APPOINTMENTS).doc(appointmentUid);
  const intakeOn = type === 'Consultation' && isEnabled(deps.config, 'symptom_intake_enabled');
  const at = timestamp(now);

  return db.runTransaction(async (tx) => {
    const existing = await tx.get(ref);
    if (existing.exists) {
      if (existing.get('patientUid') !== c.uid) throw refuse('already-exists', 'alreadyExists');
      return { status: str(existing.get('status')), appointmentUid };
    }
    const patientSnap = await tx.get(patientByUid(db, c.uid));
    if (patientSnap.empty) throw refuse('failed-precondition', 'noPatientRecord');
    const patient = patientSnap.docs[0].data();
    let discussion: LoadedCase | null = null;
    if (type === 'CaseDiscussion') {
      const caseRef = db.collection('cases').doc(caseUid);
      const caseSnap = await tx.get(caseRef);
      if (!caseSnap.exists) throw refuse('not-found', 'invalidAppointment');
      discussion = { ref: caseRef, s: CaseState.from(caseSnap) };
      if (discussion.s.patientUid !== c.uid) throw refuse('permission-denied', 'invalidAppointment');
      const stage = discussion.s.currentStage;
      if (stage === 'DiscussionRequested' || stage === 'DiscussionBooked') {
        throw refuse('failed-precondition', 'discussionExists');
      }
      const resultState = str(discussion.s.fields.resultState);
      if (stage !== 'ReportSigned' || !['WithDoctor', 'UpdateWithDoctor'].includes(resultState)) {
        throw refuse('failed-precondition', 'resultNotReady');
      }
    }
    const doctorUid = discussion ? discussion.s.doctorUid : consultationDoctor;
    const doctorRef = db.collection(DOCTORS).doc(doctorUid);
    const doctorSnap = await tx.get(doctorRef);
    const doctor = doctorSnap.data();
    if (!doctor || doctor.verificationStatus !== 'Verified' || doctor.isPathologist === true) {
      throw refuse('failed-precondition', 'doctorUnavailable');
    }
    if (type === 'Consultation' && doctor.isAvailable !== true) throw refuse('failed-precondition', 'doctorUnavailable');
    if (!withinHours(doctor, start, now)) throw refuse('failed-precondition', 'outsideWorkingHours');
    if (overlaps(liveSlots(doctor, now), start)) throw refuse('failed-precondition', 'slotTaken');

    const pending = await tx.get(buildQuery(db, queryById('appointments.pendingByPatient'), [c.uid, 'Requested']));
    const sameKind = pending.docs.filter((d) => d.get('type') === type);
    if (
      pending.size >= MAX_PENDING ||
      sameKind.some((d) => d.get('doctorUid') === doctorUid)
    ) {
      throw refuse('resource-exhausted', 'tooManyPending');
    }

    let transcript: DocumentData | undefined;
    const transcriptionRef = db.collection('transcriptions').doc(transcriptionUid || 'none');
    if (inputMode === 'Voice') {
      const snap = await tx.get(transcriptionRef);
      transcript = snap.data();
      if (!transcript || transcript.patientUid !== c.uid) throw refuse('failed-precondition', 'invalidTranscription');
    }
    const startIso = timestamp(start);
    const expiresAt = timestamp(new Date(Math.min(now.getTime() + REPLY_WINDOW_MS, start.getTime())));
    const notes = await planNotes(tx, db, [
      note(approvalTemplate(type), appointmentUid, doctorUid, 'doctor', languageIn(doctor), {
        expiresAt,
        initiatorUid: c.uid,
        initiatorRole: 'patient',
      }),
    ]);

    // Writes.
    const symptomLanguage = transcript ? str(transcript.language) : '';
    const intakeStatus = intakeOn ? 'Queued' : 'None';
    const lastCase = discussion?.s;
    tx.create(ref, {
      uid: appointmentUid,
      type,
      status: 'Requested',
      patientUid: c.uid,
      patientId: str(patient.patientId) || patientSnap.docs[0].id,
      patientName: [patient.firstName, patient.lastName].filter((p) => typeof p === 'string' && p !== '').join(' '),
      doctorUid,
      doctorName: displayName(doctor),
      facilityName: str(doctor.facilityName),
      createdByUid: c.uid,
      scheduledStart: startIso,
      scheduledEnd: timestamp(new Date(start.getTime() + SLOT_MS)),
      symptomText,
      inputMode,
      symptomLanguage,
      intakeStatus,
      discussedCaseUid: caseUid,
      discussedOrderNumber: str(lastCase?.fields.orderNumber),
      caseUids: [],
      expiresAt,
      respondedAt: '',
      acceptedAt: '',
      declineReason: '',
      declineNote: '',
      cancelledAt: '',
      cancelledByUid: '',
      cancelNote: '',
      completedAt: '',
      createdAt: at,
      lastUpdatedAt: at,
    });
    // A consultation always has the row: with the switch off it is `None`, and still carries the
    // transcript fields the voice signals are computed from.
    if (type === 'Consultation') {
      tx.create(ref.collection('intake').doc('summary'), {
        uid: 'summary',
        appointmentUid,
        doctorUid,
        status: intakeStatus,
        inputText: intakeOn ? deidentify(symptomText, subjectOf(patient)) : '',
        inputMode,
        inputLanguage: '',
        transcriptLanguage: symptomLanguage,
        transcriptAcceptedUnchanged: transcript
          ? str(transcript.transcript).trim() === symptomText.trim()
          : false,
        transcriptEditDistance: transcript ? editDistance(str(transcript.transcript), symptomText) : 0,
        drafts: { en: emptyDraft(), sw: emptyDraft() },
        modelVersion: '',
        promptVersion: '',
        failureReason: '',
        requestedAt: at,
        readyAt: '',
        lastUpdatedAt: at,
      });
    }
    if (discussion) {
      const next = transition(discussion.s, 'DiscussionRequested', { actorUid: c.uid, actorRole: 'Patient' }).with({
        discussionAppointmentUid: appointmentUid,
      });
      commitCase(tx, discussion.ref, next, now);
    }
    if (inputMode === 'Voice') tx.delete(transcriptionRef);
    sendNotes(tx, notes, now);
    return { status: 'Requested', appointmentUid };
  });
}

// --- respondToAppointment --------------------------------------------------------------------

interface Sibling {
  ref: DocumentReference;
  data: DocumentData;
  discussion: LoadedCase | null;
  approval: LoadedNotification;
  patientLanguage: 'en' | 'sw';
}

export async function respondToAppointmentHandler(
  deps: AppointmentDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = requireRole(caller, 'doctor');
  const raw = input(data);
  const now = nowOf(deps);
  const appointmentUid = uuidOf(raw.appointmentUid, 'invalidAppointment');
  const decision = oneOf(raw.decision, ['Accept', 'Decline'] as const, 'invalidDecision');
  let declineReason = '';
  let declineNote = '';
  if (decision === 'Decline') {
    declineReason = oneOf(raw.declineReason, DECLINE_REASONS, 'invalidReason');
    if (raw.declineNote !== undefined && typeof raw.declineNote !== 'string') {
      throw refuse('invalid-argument', 'invalidNote');
    }
    declineNote = sanitize(typeof raw.declineNote === 'string' ? raw.declineNote : '', 300);
  }

  const { db } = deps;
  const ref = db.collection(APPOINTMENTS).doc(appointmentUid);
  const at = timestamp(now);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const appt = snap.data();
    if (!appt || appt.doctorUid !== c.uid) throw refuse('not-found', 'invalidAppointment');
    if (appt.status !== 'Requested') return { status: str(appt.status) };

    const type = str(appt.type);
    const doctorRef = db.collection(DOCTORS).doc(c.uid);
    const doctorSnap = await tx.get(doctorRef);
    const doctor = doctorSnap.data() ?? {};
    const patientRef = db.collection(PATIENTS).doc(str(appt.patientId));
    const patientSnap = await tx.get(patientRef);
    const patientLanguage = languageIn(patientSnap.data());
    const discussion = await loadDiscussionCase(tx, db, appt);
    const approval = await loadRow(tx, db, approvalTemplate(type), appointmentUid, c.uid);

    const expired = Date.parse(str(appt.expiresAt)) <= now.getTime();
    const start = new Date(str(appt.scheduledStart));
    const accepting = decision === 'Accept' && !expired;
    const siblings: Sibling[] = [];
    let busy: string[] = [];
    if (accepting) {
      busy = liveSlots(doctor, now);
      if (overlaps(busy, start)) throw refuse('failed-precondition', 'slotTaken');
      const found = await tx.get(
        buildQuery(db, queryById('appointments.siblingsBySlot'), [c.uid, 'Requested', str(appt.scheduledStart)]).limit(
          SIBLING_LIMIT + 1,
        ),
      );
      for (const doc of found.docs) {
        if (doc.id === appointmentUid) continue;
        if (siblings.length === SIBLING_LIMIT) break;
        const sibling = doc.data();
        const siblingPatient = await tx.get(db.collection(PATIENTS).doc(str(sibling.patientId)));
        siblings.push({
          ref: doc.ref,
          data: sibling,
          discussion: await loadDiscussionCase(tx, db, sibling),
          approval: await loadRow(tx, db, approvalTemplate(str(sibling.type)), doc.id, c.uid),
          patientLanguage: languageIn(siblingPatient.data()),
        });
      }
    }
    const outcome = expired ? 'appointmentExpired' : accepting ? 'appointmentAccepted' : 'appointmentDeclined';
    const notes = await planNotes(tx, db, [
      note(outcome, appointmentUid, str(appt.patientUid), 'patient', patientLanguage, { initiatorUid: c.uid, initiatorRole: 'doctor' }),
      ...siblings.map((s) =>
        note('appointmentDeclined', s.ref.id, str(s.data.patientUid), 'patient', s.patientLanguage, {
          initiatorUid: c.uid,
          initiatorRole: 'doctor',
        }),
      ),
    ]);

    // Writes.
    if (expired) {
      tx.update(ref, { status: 'Expired', respondedAt: at, lastUpdatedAt: at });
      NotificationTx.settle(tx, approval, 'Expired', '', now);
      closeDiscussionOf(tx, discussion, appointmentUid, 'Expire', '', { uid: c.uid, role: 'Doctor' }, now);
      sendNotes(tx, notes, now);
      return { status: 'Expired' };
    }
    if (decision === 'Decline') {
      tx.update(ref, { status: 'Declined', respondedAt: at, declineReason, declineNote, lastUpdatedAt: at });
      NotificationTx.settle(tx, approval, 'Declined', c.uid, now);
      closeDiscussionOf(tx, discussion, appointmentUid, 'Reject', declineReason, { uid: c.uid, role: 'Doctor' }, now);
      sendNotes(tx, notes, now);
      return { status: 'Declined' };
    }

    tx.update(ref, { status: 'Accepted', respondedAt: at, acceptedAt: at, lastUpdatedAt: at });
    tx.update(doctorRef, { busySlots: sortedSlots([...busy, timestamp(start)]), lastUpdatedAt: at });
    if (patientSnap.exists) {
      tx.update(patientRef, { doctorUids: FieldValue.arrayUnion(c.uid), lastUpdatedAt: at });
    }
    NotificationTx.settle(tx, approval, 'Accepted', c.uid, now);
    if (discussion && discussion.s.currentStage === 'DiscussionRequested' && discussion.s.discussionAppointmentUid === appointmentUid) {
      commitCase(tx, discussion.ref, transition(discussion.s, 'DiscussionBooked', { actorUid: c.uid, actorRole: 'Doctor' }), now);
    }
    for (const sibling of siblings) {
      tx.update(sibling.ref, {
        status: 'Declined',
        respondedAt: at,
        declineReason: 'SlotTaken',
        lastUpdatedAt: at,
      });
      NotificationTx.settle(tx, sibling.approval, 'Declined', c.uid, now);
      closeDiscussionOf(tx, sibling.discussion, sibling.ref.id, 'Reject', 'SlotTaken', { uid: c.uid, role: 'Doctor' }, now);
    }
    sendNotes(tx, notes, now);
    return { status: 'Accepted' };
  });
}

// --- cancelAppointment -----------------------------------------------------------------------

export async function cancelAppointmentHandler(
  deps: AppointmentDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const raw = input(data);
  const c = (() => {
    if (!caller) throw refuse('unauthenticated', 'unauthenticated');
    if (caller.role !== 'patient' && caller.role !== 'doctor') throw refuse('permission-denied', 'notParticipant');
    return caller;
  })();
  const byDoctor = c.role === 'doctor';
  const now = nowOf(deps);
  const appointmentUid = uuidOf(raw.appointmentUid, 'invalidAppointment');
  if (raw.cancelNote !== undefined && typeof raw.cancelNote !== 'string') {
    throw refuse('invalid-argument', 'invalidNote');
  }
  const cancelNote = sanitize(typeof raw.cancelNote === 'string' ? raw.cancelNote : '', 300);
  if (byDoctor && cancelNote === '') throw refuse('invalid-argument', 'noteRequired');

  const { db } = deps;
  const ref = db.collection(APPOINTMENTS).doc(appointmentUid);
  const at = timestamp(now);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const appt = snap.data();
    const mine = appt && (byDoctor ? appt.doctorUid === c.uid : appt.patientUid === c.uid);
    if (!appt || !mine) throw refuse('not-found', 'invalidAppointment');
    if (appt.status === 'Cancelled') return { status: 'Cancelled' };
    const wasAccepted = appt.status === 'Accepted';
    if (appt.status !== 'Requested' && !wasAccepted) throw refuse('failed-precondition', 'invalidAppointment');
    if (byDoctor && !wasAccepted) throw refuse('failed-precondition', 'invalidAppointment');
    if (Date.parse(str(appt.scheduledStart)) <= now.getTime()) throw refuse('failed-precondition', 'tooLate');

    const doctorRef = db.collection(DOCTORS).doc(str(appt.doctorUid));
    const doctorSnap = await tx.get(doctorRef);
    const patientSnap = await tx.get(db.collection(PATIENTS).doc(str(appt.patientId)));
    const discussion = await loadDiscussionCase(tx, db, appt);
    const approval = await loadRow(tx, db, approvalTemplate(str(appt.type)), appointmentUid, str(appt.doctorUid));
    const threadRef = conversationRef(db, appointmentUid);
    const thread = (await tx.get(threadRef)).data();
    const notes = await planNotes(tx, db, [
      byDoctor
        ? note('appointmentCancelledByDoctor', appointmentUid, str(appt.patientUid), 'patient', languageIn(patientSnap.data()), {
            initiatorUid: c.uid,
            initiatorRole: 'doctor',
          })
        : note('appointmentCancelledByPatient', appointmentUid, str(appt.doctorUid), 'doctor', languageIn(doctorSnap.data()), {
            initiatorUid: c.uid,
            initiatorRole: 'patient',
          }),
    ]);

    tx.update(ref, { status: 'Cancelled', cancelledAt: at, cancelledByUid: c.uid, cancelNote, lastUpdatedAt: at });
    if (wasAccepted && doctorSnap.exists) {
      const kept = liveSlots(doctorSnap.data() ?? {}, now).filter((s) => s !== str(appt.scheduledStart));
      tx.update(doctorRef, { busySlots: sortedSlots(kept), lastUpdatedAt: at });
    }
    NotificationTx.settle(tx, approval, 'Cancelled', c.uid, now);
    closeDiscussionOf(
      tx,
      discussion,
      appointmentUid,
      'Cancel',
      byDoctor ? 'Other' : 'PatientDeclined',
      { uid: c.uid, role: byDoctor ? 'Doctor' : 'Patient' },
      now,
    );
    closeThread(tx, threadRef, thread, now);
    sendNotes(tx, notes, now);
    return { status: 'Cancelled' };
  });
}

// --- completeAppointment ---------------------------------------------------------------------

export async function completeAppointmentHandler(
  deps: AppointmentDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = requireRole(caller, 'doctor');
  const raw = input(data);
  const now = nowOf(deps);
  const appointmentUid = uuidOf(raw.appointmentUid, 'invalidAppointment');
  const outcome = oneOf(raw.outcome, ['Completed', 'NoShow'] as const, 'invalidOutcome');
  const { db } = deps;
  const ref = db.collection(APPOINTMENTS).doc(appointmentUid);

  return db.runTransaction(async (tx) => {
    const appt = (await tx.get(ref)).data();
    if (!appt || appt.doctorUid !== c.uid) throw refuse('not-found', 'invalidAppointment');
    if (appt.status === outcome) return { status: outcome };
    if (appt.status !== 'Accepted') throw refuse('failed-precondition', 'invalidAppointment');
    const from = Date.parse(str(outcome === 'Completed' ? appt.scheduledStart : appt.scheduledEnd));
    if (now.getTime() < from) throw refuse('failed-precondition', 'tooEarly');
    // Close the linked discussion in the same write so a NoShow/Completed case can be rebooked;
    // the report stays signed (closeDiscussion returns to ReportSigned, never releases).
    const discussion = await loadDiscussionCase(tx, db, appt);
    const at = timestamp(now);
    tx.update(ref, { status: outcome, completedAt: at, lastUpdatedAt: at });
    closeDiscussionOf(
      tx,
      discussion,
      appointmentUid,
      outcome === 'Completed' ? 'Complete' : 'NoShow',
      '',
      { uid: c.uid, role: 'Doctor' },
      now,
    );
    return { status: outcome };
  });
}

// --- transcribeSymptoms ----------------------------------------------------------------------

export interface TranscriptionResult {
  transcriptionUid: string;
  transcript: string;
  detectedLanguage: string;
  models: Record<string, string>;
}

/** Sample rates the speech API takes, in Hz. */
const WAV_RATES = [16000, 24000];

/**
 * Parses a symptom recording and rebuilds what the speech API takes: a plain 44-byte
 * RIFF/WAVE header (PCM, mono, 16-bit, 16 or 24 kHz) plus the `data` bytes. Tolerates what a
 * real recorder may add — unknown chunks anywhere, trailing chunks after `data`, placeholder
 * sizes (0 or 0xFFFFFFFF) taken from the file length — and refuses anything else: a `data`
 * size past the bytes present, anything outside mono 16-bit PCM at 16 or 24 kHz, anything
 * outside 1 s to 46 s. Null when refused.
 */
function canonicalSymptomWav(bytes: Buffer): { wav: Buffer; durationMs: number } | null {
  if (bytes.length < 44) return null;
  if (bytes.toString('latin1', 0, 4) !== 'RIFF') return null;
  if (bytes.toString('latin1', 8, 12) !== 'WAVE') return null;
  const riffSize = bytes.readUInt32LE(4);
  if (riffSize !== 0 && riffSize !== 0xffffffff && riffSize !== bytes.length - 8) return null;
  let channels = 0;
  let rate = 0;
  let byteRate = 0;
  let bits = 0;
  let dataStart = -1;
  let dataSize = -1;
  let offset = 12;
  while (offset + 8 <= bytes.length) {
    const id = bytes.toString('latin1', offset, offset + 4);
    const size = bytes.readUInt32LE(offset + 4);
    const payload = offset + 8;
    let consumed = size;
    if (id === 'fmt ') {
      if (size < 16 || payload + size > bytes.length) return null;
      if (bytes.readUInt16LE(payload) !== 1) return null;
      channels = bytes.readUInt16LE(payload + 2);
      rate = bytes.readUInt32LE(payload + 4);
      byteRate = bytes.readUInt32LE(payload + 8);
      bits = bytes.readUInt16LE(payload + 14);
    } else if (id === 'data') {
      if (dataSize !== -1) return null;
      if (size === 0 || size === 0xffffffff) {
        consumed = bytes.length - payload;
      } else if (payload + size > bytes.length) {
        return null;
      }
      dataStart = payload;
      dataSize = consumed;
    } else if (payload + size > bytes.length) {
      return null;
    }
    offset = payload + consumed + (consumed % 2);
  }
  if (channels !== 1 || bits !== 16 || !WAV_RATES.includes(rate)) return null;
  if (byteRate !== (rate * bits * channels) / 8) return null;
  if (dataSize < 0) return null;
  if (dataSize < byteRate || dataSize > byteRate * 46) return null;
  const header = Buffer.alloc(44);
  header.write('RIFF', 0);
  header.writeUInt32LE(36 + dataSize, 4);
  header.write('WAVE', 8);
  header.write('fmt ', 12);
  header.writeUInt32LE(16, 16);
  header.writeUInt16LE(1, 20);
  header.writeUInt16LE(1, 22);
  header.writeUInt32LE(rate, 24);
  header.writeUInt32LE(byteRate, 28);
  header.writeUInt16LE(2, 32);
  header.writeUInt16LE(16, 34);
  header.write('data', 36);
  header.writeUInt32LE(dataSize, 40);
  return {
    wav: Buffer.concat([header, bytes.subarray(dataStart, dataStart + dataSize)]),
    durationMs: Math.floor((dataSize * 1000) / byteRate),
  };
}

/**
 * Symptom dictation is transcribe-and-discard: the audio goes to the speech model and nowhere
 * else, and the object is deleted in `finally` on every path after the id is known, a refusal
 * for the switch or the daily limit included.
 */
export async function transcribeSymptomsHandler(
  deps: AppointmentDeps,
  caller: Caller | null,
  data: unknown,
): Promise<TranscriptionResult> {
  const c = requireRole(caller, 'patient');
  const raw = input(data);
  const audioUid = typeof raw.audioUid === 'string' && /^[A-Za-z0-9_-]{1,128}$/.test(raw.audioUid) ? raw.audioUid : '';
  if (audioUid === '') throw refuse('invalid-argument', 'invalidAudio');
  const now = nowOf(deps);
  const { db } = deps;
  const file = storageOf(deps).bucket(deps.bucket).file(`speechAudio/${c.uid}/${audioUid}.wav`);

  try {
    if (!isEnabled(deps.config, 'voice_input_enabled')) throw refuse('failed-precondition', 'voiceDisabled');
    // Counted before the model is called, so a failing recording still costs the caller an attempt.
    await db.runTransaction(async (tx) => {
      const window = await loadRate(tx, db, `transcribe:${c.uid}:${nairobiDayKey(now)}`);
      if (window.count >= TRANSCRIBE_PER_DAY) throw refuse('resource-exhausted', 'rateLimited');
      writeRate(tx, window, now);
    });

    const [exists] = await file.exists();
    if (!exists) throw refuse('not-found', 'audioMissing');
    const [meta] = await file.getMetadata();
    if (!AUDIO_TYPES.includes(str(meta.contentType))) throw refuse('invalid-argument', 'invalidAudio');
    if (Number(meta.size) > SPEECH_MAX_BYTES) throw refuse('invalid-argument', 'audioTooLarge');
    const [bytes] = await file.download();
    const canonical = canonicalSymptomWav(bytes);
    if (canonical === null) throw refuse('invalid-argument', 'invalidAudio');
    const ai = deps.ai;
    if (!ai?.transcribeAudio) throw refuse('unavailable', 'transcriptionFailed');
    let transcript: string;
    let language: string;
    let models: Record<string, string>;
    try {
      const result = await withTimeout(ai.transcribeAudio({ bytes: canonical.wav, contentType: str(meta.contentType) }));
      transcript = sanitize(result.transcript, 2000);
      language = ['en', 'sw', 'mixed'].includes(result.language) ? result.language : '';
      models = result.models;
      if (transcript === '') throw new Error('empty');
    } catch {
      throw refuse('unavailable', 'transcriptionFailed');
    }
    const transcriptionUid = newUid();
    await db.runTransaction(async (tx) => {
      const at = timestamp(now);
      tx.create(db.collection('transcriptions').doc(transcriptionUid), {
        uid: transcriptionUid,
        patientUid: c.uid,
        transcript,
        language,
        models,
        createdAt: at,
        expireAt: ttlAt(now, DAY_MS),
        lastUpdatedAt: at,
      });
      bumpModelSignal(tx, db, 'transcriptionCount', now);
    });
    return { transcriptionUid, transcript, detectedLanguage: language, models };
  } finally {
    // Never mask the real outcome: `expireAppointments` removes what this could not.
    await file.delete({ ignoreNotFound: true }).catch(() => undefined);
  }
}

// --- onAppointmentWritten --------------------------------------------------------------------

export async function onAppointmentWrittenHandler(
  deps: AppointmentDeps,
  appointmentUid: string,
  before: DocumentData | undefined,
  after: DocumentData | undefined,
): Promise<void> {
  if (!after) return;
  await countAppointment(deps, appointmentUid, before, after);
  if (!before) await summariseIntake(deps, appointmentUid);
}

/** Counts on the edge: a later, unrelated write is not one, and a mark guards a redelivery. */
async function countAppointment(
  deps: AppointmentDeps,
  appointmentUid: string,
  before: DocumentData | undefined,
  after: DocumentData,
): Promise<void> {
  const bookedEdge = str(after.acceptedAt) !== '' && str(before?.acceptedAt) === '';
  const handledEdge = after.status === 'Completed' && before?.status !== 'Completed';
  if (!bookedEdge && !handledEdge) return;
  const { db } = deps;
  const now = nowOf(deps);

  await db.runTransaction(async (tx) => {
    const current = (await tx.get(db.collection(APPOINTMENTS).doc(appointmentUid))).data();
    if (!current) return;
    const specs: MarkSpec[] = [];
    const targets: CountTarget[] = [];
    if (bookedEdge && str(current.acceptedAt) !== '') {
      const mark = { counter: 'appointmentsBooked', resourceUid: appointmentUid };
      specs.push(mark);
      targets.push({
        ...mark,
        targetRef: db.collection(PATIENTS).doc(str(current.patientId)),
        field: 'appointmentsBooked',
      });
    }
    if (handledEdge && current.status === 'Completed') {
      const mark = { counter: 'appointmentsHandled', resourceUid: appointmentUid };
      specs.push(mark);
      targets.push({
        ...mark,
        targetRef: db.collection(DOCTORS).doc(str(current.doctorUid)),
        field: 'appointmentsHandled',
      });
    }
    if (specs.length === 0) return;
    const marks = await loadMarks(tx, db, specs);
    // A counter never invents the profile it counts for.
    const present: CountTarget[] = [];
    for (const target of targets) {
      if ((await tx.get(target.targetRef)).exists) present.push(target);
    }
    applyCounts(tx, marks, present, now);
  });
}

const NUMBER = /\d+/g;

function numbersOk(inputText: string, outputs: string[]): boolean {
  const allowed = new Set(inputText.match(NUMBER) ?? []);
  return outputs.every((o) => (o.match(NUMBER) ?? []).every((n) => allowed.has(n)));
}

type IntakeFailure = 'Timeout' | 'ServiceError' | 'OffSchema' | 'Disabled';

const LANGUAGES_SEEN = ['en', 'sw', 'mixed'];

/**
 * The summary reads the de-identified text and nothing else (S-5). A failure writes `Failed` and
 * ends: the doctor reads the patient's own words, and nothing retries for days.
 */
async function summariseIntake(deps: AppointmentDeps, appointmentUid: string): Promise<void> {
  const { db } = deps;
  const ref = db.collection(APPOINTMENTS).doc(appointmentUid);
  const summaryRef = ref.collection('intake').doc('summary');
  const summary = (await summaryRef.get()).data();
  if (!summary || summary.status !== 'Queued') return;
  const inputText = deidentify(str(summary.inputText));
  const hint = str(summary.transcriptLanguage);

  let ready: { en: string; sw: string; models: Record<string, string>; language: string } | null = null;
  let failure: IntakeFailure = 'ServiceError';
  try {
    // The switch was read when the request was made; a runbook may have turned it off since.
    if (!isEnabled(deps.config, 'symptom_intake_enabled')) throw new Error('disabled');
    if (!deps.ai?.summarizeSymptoms) throw new Error('unavailable');
    const result = await withTimeout(
      deps.ai.summarizeSymptoms(hint ? { inputText, languageHint: hint } : { inputText }),
    );
    const en = sanitize(result.en, 2000);
    const sw = sanitize(result.sw, 2000);
    if ((en === '' && sw === '') || !numbersOk(inputText, [en, sw])) {
      failure = 'OffSchema';
    } else {
      const seen = result.inputLanguage ?? '';
      ready = { en, sw, models: result.models, language: LANGUAGES_SEEN.includes(seen) ? seen : hint };
    }
  } catch (error) {
    const reason = (error as Error).message;
    failure = reason === 'timeout' ? 'Timeout' : reason === 'disabled' ? 'Disabled' : 'ServiceError';
  }

  const now = nowOf(deps);
  const at = timestamp(now);
  await db.runTransaction(async (tx) => {
    const current = (await tx.get(summaryRef)).data();
    if (!current || current.status !== 'Queued') return;
    const appointment = (await tx.get(ref)).data();
    if (ready) {
      const language = ready.language;
      tx.update(summaryRef, {
        status: 'Ready',
        inputLanguage: language,
        drafts: {
          en: { ...emptyDraft(), summary: ready.en, isTranslation: language === 'sw' },
          sw: { ...emptyDraft(), summary: ready.sw, isTranslation: language === 'en' },
        },
        modelVersion: Object.entries(ready.models).map(([k, v]) => `${k}:${v}`).join(','),
        readyAt: at,
        lastUpdatedAt: at,
      });
    } else {
      tx.update(summaryRef, { status: 'Failed', failureReason: failure, readyAt: at, lastUpdatedAt: at });
    }
    // Typed text has no transcript: its language comes from the summary, once, and a patient's
    // transcript language already on the appointment is left alone.
    const symptomLanguage = ready && str(appointment?.symptomLanguage) === '' ? ready.language : '';
    tx.update(ref, {
      intakeStatus: ready ? 'Ready' : 'Failed',
      ...(symptomLanguage === '' ? {} : { symptomLanguage }),
      lastUpdatedAt: at,
    });
    bumpModelSignal(tx, db, ready ? 'intakeReadyCount' : 'intakeFailedCount', now);
  });
}

// --- expireAppointments ----------------------------------------------------------------------

export interface ExpireResult {
  expired: number;
  intakeFailed: number;
  audioDeleted: number;
}

export async function expireAppointmentsHandler(deps: AppointmentDeps): Promise<ExpireResult> {
  const { db } = deps;
  const now = nowOf(deps);
  const result: ExpireResult = { expired: 0, intakeFailed: 0, audioDeleted: 0 };

  const due = await buildQuery(db, queryById('appointments.requestedExpired'), ['Requested', timestamp(now)])
    .limit(SWEEP_LIMIT)
    .get();
  for (const doc of due.docs) {
    try {
      if (await expireOne(deps, doc.id, now)) result.expired += 1;
    } catch {
      // One poisoned appointment must not starve the rest of the sweep.
    }
  }

  const stale = await buildQuery(db, queryById('intake.staleQueued'), [
    'Queued',
    timestamp(new Date(now.getTime() - INTAKE_STALE_MS)),
  ])
    .limit(SWEEP_LIMIT)
    .get();
  for (const doc of stale.docs) {
    try {
      if (await failStaleIntake(deps, doc.ref, now)) result.intakeFailed += 1;
    } catch {
      // One poisoned intake must not starve the rest of the sweep.
    }
  }

  result.audioDeleted = await deleteStaleSpeech(deps, now);
  return result;
}

/** One request in its own transaction, re-checked: one already answered is skipped. */
async function expireOne(deps: AppointmentDeps, appointmentUid: string, now: Date): Promise<boolean> {
  const { db } = deps;
  const ref = db.collection(APPOINTMENTS).doc(appointmentUid);
  const at = timestamp(now);
  return db.runTransaction(async (tx) => {
    const appt = (await tx.get(ref)).data();
    if (!appt || appt.status !== 'Requested' || Date.parse(str(appt.expiresAt)) > now.getTime()) return false;
    const patientSnap = await tx.get(db.collection(PATIENTS).doc(str(appt.patientId)));
    const discussion = await loadDiscussionCase(tx, db, appt);
    const approval = await loadRow(tx, db, approvalTemplate(str(appt.type)), appointmentUid, str(appt.doctorUid));
    const notes = await planNotes(tx, db, [
      note('appointmentExpired', appointmentUid, str(appt.patientUid), 'patient', languageIn(patientSnap.data())),
    ]);
    tx.update(ref, { status: 'Expired', respondedAt: at, lastUpdatedAt: at });
    NotificationTx.settle(tx, approval, 'Expired', '', now);
    closeDiscussionOf(tx, discussion, appointmentUid, 'Expire', '', { uid: '', role: 'System' }, now);
    sendNotes(tx, notes, now);
    return true;
  });
}

async function failStaleIntake(
  deps: AppointmentDeps,
  summaryRef: DocumentReference,
  now: Date,
): Promise<boolean> {
  const { db } = deps;
  const appointmentRef = summaryRef.parent.parent;
  if (!appointmentRef) return false;
  const at = timestamp(now);
  return db.runTransaction(async (tx) => {
    const summary = (await tx.get(summaryRef)).data();
    if (
      !summary ||
      summary.status !== 'Queued' ||
      Date.parse(str(summary.requestedAt)) > now.getTime() - INTAKE_STALE_MS
    ) {
      return false;
    }
    tx.update(summaryRef, { status: 'Failed', failureReason: 'Stale', readyAt: at, lastUpdatedAt: at });
    tx.update(appointmentRef, { intakeStatus: 'Failed', lastUpdatedAt: at });
    bumpModelSignal(tx, db, 'intakeFailedCount', now);
    return true;
  });
}

/** What `transcribeSymptoms` could not delete, every page of it: nothing here outlives an hour. */
async function deleteStaleSpeech(deps: AppointmentDeps, now: Date): Promise<number> {
  let deleted = 0;
  try {
    const bucket = storageOf(deps).bucket(deps.bucket);
    let pageToken: string | undefined;
    do {
      const [files, next] = await bucket.getFiles({
        prefix: 'speechAudio/',
        autoPaginate: false,
        maxResults: SPEECH_PAGE,
        ...(pageToken ? { pageToken } : {}),
      });
      for (const file of files) {
        const created = Date.parse(str(file.metadata.timeCreated));
        if (Number.isNaN(created) || now.getTime() - created <= SPEECH_AUDIO_MAX_AGE_MS) continue;
        await file.delete({ ignoreNotFound: true });
        deleted += 1;
      }
      pageToken = (next as { pageToken?: string } | null)?.pageToken;
    } while (pageToken);
  } catch (error) {
    // Storage is not reachable from this run; the next one tries again. Counts only.
    logger.error('deleteStaleSpeech failed', { deleted, reason: String(error) });
  }
  return deleted;
}
