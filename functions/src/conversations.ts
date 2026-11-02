// cspell:ignore mvhd mdts
/**
 * Conversations (plan §3.4 "Conversations", §3.5 `onMessageCreated` and `sweepConversations`).
 * Direct threads between two people on a resource, MDT groups of practitioners around a case,
 * and the messages inside them. A client writes a message and its read cursor under rules;
 * everything else is a callable or a trigger.
 *
 * A voice note's transcript is a second document: the machine text beside the sender and the
 * clinicians who also hear the audio, and a copy the sender chooses to share for everyone else.
 * The message itself never carries transcript text.
 */
import {
  type DocumentData,
  type DocumentReference,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';

import { withTimeout } from './ai-domain';
import {
  ageYears,
  idOf,
  languageIn,
  num,
  records,
  str,
  strings,
  uuidOf,
  type Departing,
} from './case-support';
import {
  Caller,
  DOCTORS,
  PATIENTS,
  input,
  nairobiDayKey,
  oneOf,
  refuse,
  requireCaller,
  timestamp,
} from './common';
import { isEnabled } from './config';
import { deidentify } from './deidentify';
import { CLINICAL_SPECIALTIES, PATHOLOGY_SPECIALTIES } from './identity';
import { NotificationTx, type LoadedNotification } from './notifications';
import { CaseState } from './orchestrator';
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

export type ConversationsDeps = RuntimeDeps;

export const MAX_MEMBERS = 10;
export const MDTS_PER_DAY = 10;
export const INVITE_TTL_MS = 7 * DAY_MS;
export const WITHDRAW_WINDOW_MS = 15 * MINUTE_MS;
export const BLOCK_MS = 15 * MINUTE_MS;
export const TEXT_PER_MINUTE = 30;
export const TEXT_PER_DAY = 600;
export const VOICE_PER_HOUR = 20;
export const VOICE_MS_PER_DAY = 30 * MINUTE_MS;
export const VOICE_MAX_MS = 120_000;
/** The measured length may run a little past the 2 minutes the app records. */
export const VOICE_MEASURED_MAX_MS = 120_500;
export const VOICE_MAX_BYTES = 512 * 1024;
export const TRANSCRIPT_STALE_MS = 10 * MINUTE_MS;
export const ORPHAN_MEDIA_MS = DAY_MS;
/** Objects one sweep run looks at; the next run carries on from a stored page token. */
export const MEDIA_PAGE = 500;
const FUTURE_SENT_MS = 2 * MINUTE_MS;
const SWEEP_LIMIT = 100;
const AUDIO_TYPES = ['audio/mp4', 'audio/aac'];

const CONVERSATIONS = 'conversations';

type Role = 'patient' | 'doctor' | 'pathologist';

function clinical(caller: Caller | null): Caller & { role: Role } {
  const c = requireCaller(caller);
  if (c.role !== 'patient' && c.role !== 'doctor' && c.role !== 'pathologist') {
    throw refuse('permission-denied', 'notParticipant');
  }
  return c as Caller & { role: Role };
}

function practitioner(caller: Caller | null): Caller & { role: 'doctor' | 'pathologist' } {
  const c = requireCaller(caller);
  if (c.role !== 'doctor' && c.role !== 'pathologist') throw refuse('permission-denied', 'notParticipant');
  return c as Caller & { role: 'doctor' | 'pathologist' };
}

/** The case's current doctor or pathologist, on a case that is not cancelled: who may run an MDT. */
function stillPrimary(s: CaseState, uid: string, role: string): boolean {
  if (s.currentStage === 'Cancelled') return false;
  return (role === 'doctor' && s.doctorUid === uid) || (role === 'pathologist' && s.pathologistUid === uid);
}

// --- Members ---------------------------------------------------------------------------------

type Members = Record<string, DocumentData>;

function memberOf(
  uid: string,
  actorRole: Role,
  memberRole: 'Owner' | 'Member',
  status: string,
  profile: DocumentData | undefined,
  extra: DocumentData = {},
): DocumentData {
  const specialties = strings(profile?.specialties);
  return {
    uid,
    actorRole,
    memberRole,
    status,
    title: actorRole === 'patient' ? '' : str(profile?.title),
    firstName: str(profile?.firstName),
    lastName: str(profile?.lastName),
    specialty: specialties[0] ?? '',
    profilePictureUrl: actorRole === 'patient' ? '' : str(profile?.profilePictureUrl),
    invitedByUid: '',
    invitedAt: '',
    inviteExpiresAt: '',
    inviteRound: 0,
    respondedAt: '',
    ...extra,
  };
}

function acceptedUids(members: Members): string[] {
  return Object.values(members)
    .filter((m) => m.status === 'Accepted')
    .map((m) => str(m.uid));
}

function liveCount(members: Members): number {
  return Object.values(members).filter((m) => m.status === 'Invited' || m.status === 'Accepted').length;
}

/** The earliest open invite, or '' when there is none: it drives the sweep. */
function nextInvite(members: Members): string {
  const open = Object.values(members)
    .filter((m) => m.status === 'Invited' && str(m.inviteExpiresAt) !== '')
    .map((m) => str(m.inviteExpiresAt))
    .sort();
  return open[0] ?? '';
}

function emptyMessage(): DocumentData {
  return { uid: '', senderUid: '', text: '', hasAttachment: false, sentAt: '' };
}

export function emptyCaseSummary(): DocumentData {
  return {
    caseRef: '',
    ageBand: '',
    sex: '',
    testTypeNames: [],
    testNames: [],
    reportStatus: 'Pending',
    signedDiagnosisExcerpt: '',
    signedAt: '',
    signedByName: '',
    reportLanguage: '',
    builtAt: '',
  };
}

function conversationDoc(
  uid: string,
  fields: {
    type: 'Direct' | 'GroupConsult';
    createdByUid: string;
    linkedResourceType: 'Appointment' | 'Order';
    linkedResourceUid: string;
    specialty?: string;
    description?: string;
    members: Members;
    caseSummary?: DocumentData;
  },
  now: Date,
): DocumentData {
  const at = timestamp(now);
  return {
    uid,
    type: fields.type,
    status: 'Open',
    createdByUid: fields.createdByUid,
    linkedResourceType: fields.linkedResourceType,
    linkedResourceUid: fields.linkedResourceUid,
    specialty: fields.specialty ?? '',
    description: fields.description ?? '',
    participantUids: acceptedUids(fields.members),
    members: fields.members,
    lastMessage: emptyMessage(),
    lastMessageAt: '',
    caseSummary: fields.caseSummary ?? emptyCaseSummary(),
    createdAt: at,
    closedAt: '',
    lastUpdatedAt: at,
    nextInviteExpiresAt: nextInvite(fields.members),
  };
}

function conversationNote(
  template: string,
  conversationUid: string,
  resourceKey: string,
  recipientUid: string,
  recipientRole: string,
  language: 'en' | 'sw',
  extra: Partial<NoteSpec> = {},
): NoteSpec {
  return {
    template,
    resourceKey,
    threadUid: conversationUid,
    resourceUid: conversationUid,
    recipientUid,
    recipientRole,
    language,
    deepLink: `/conversations/${conversationUid}`,
    ...extra,
  };
}

async function languageFor(tx: Transaction, db: Firestore, role: string, uid: string): Promise<'en' | 'sw'> {
  if (role === 'patient') {
    const found = await tx.get(buildQuery(db, queryById('patients.byUid'), [uid]).limit(1));
    return languageIn(found.docs[0]?.data());
  }
  return languageIn((await tx.get(db.collection(DOCTORS).doc(uid))).data());
}

// --- The MDT's de-identified case summary ----------------------------------------------------

export function mdtAgeBand(years: number): string {
  if (years < 1) return '<1';
  if (years >= 90) return '90+';
  const low = years < 10 ? 1 : Math.floor(years / 10) * 10;
  return `${low}-${low === 1 ? 9 : low + 9}`;
}

/**
 * An allow-list: age band, sex, catalogue test names, and only a *signed* report's excerpt, scrubbed
 * of the patient's own names, phone and birth date (S-1: no pre-read and no draft is ever read).
 */
export function mdtCaseSummary(
  conversationUid: string,
  s: CaseState,
  patient: DocumentData | undefined,
  report: DocumentData | undefined,
  now: Date,
): DocumentData {
  const tests = records(s.fields.tests);
  const dob = str(patient?.dateOfBirth);
  const subject = {
    firstName: str(patient?.firstName),
    middleName: str(patient?.middleName),
    lastName: str(patient?.lastName),
    phoneNumber: str(patient?.phoneNumber),
    email: str(patient?.email),
    dateOfBirth: dob,
  };
  const signed = report !== undefined && str(report.status) === 'Signed';
  return {
    caseRef: `MDT-${conversationUid.slice(0, 6).toUpperCase()}`,
    ageBand: dob ? mdtAgeBand(ageYears(dob, now)) : '',
    sex: str(patient?.sex),
    testTypeNames: [...new Set(tests.map((t) => str(t.testTypeName)).filter((n) => n !== ''))],
    testNames: tests.map((t) => str(t.name)).filter((n) => n !== ''),
    reportStatus: !signed ? 'Pending' : num(report.version) > 1 ? 'Amended' : 'Signed',
    signedDiagnosisExcerpt: signed
      ? [...deidentify(str(report.diagnosis), subject)].slice(0, 500).join('')
      : '',
    signedAt: signed ? str(report.signedAt) : '',
    signedByName: signed ? [str(report.signedByTitle), str(report.signedByName)].filter((p) => p !== '').join(' ') : '',
    reportLanguage: signed ? (str(report.language) === 'sw' ? 'sw' : 'en') : '',
    builtAt: timestamp(now),
  };
}

// --- openDirectConversation ------------------------------------------------------------------

export async function openDirectConversationHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ conversationUid: string }> {
  const c = clinical(caller);
  const raw = input(data);
  const now = nowOf(deps);
  const resourceType = oneOf(raw.resourceType, ['Appointment', 'Order'] as const, 'conversationUnavailable');
  const resourceUid = idOf(raw.resourceUid, 'conversationUnavailable');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    let conversationUid: string;
    let pair: { uid: string; role: Role }[];
    let patientId = '';
    if (resourceType === 'Appointment') {
      conversationUid = `appt_${resourceUid}`;
      const appt = (await tx.get(db.collection('appointments').doc(resourceUid))).data();
      if (!appt) throw refuse('not-found', 'conversationUnavailable');
      pair = [
        { uid: str(appt.patientUid), role: 'patient' },
        { uid: str(appt.doctorUid), role: 'doctor' },
      ];
      patientId = str(appt.patientId);
      if (!['Accepted', 'Completed'].includes(str(appt.status))) throw refuse('failed-precondition', 'conversationUnavailable');
    } else {
      const caseSnap = await tx.get(db.collection('cases').doc(resourceUid));
      if (!caseSnap.exists) throw refuse('not-found', 'conversationUnavailable');
      const s = CaseState.from(caseSnap);
      // The id is rebuilt from the case's own pathologist, never taken from the caller.
      if (typeof raw.pathologistUid === 'string' && raw.pathologistUid !== s.pathologistUid) {
        throw refuse('failed-precondition', 'conversationUnavailable');
      }
      if (s.pathologistUid === '' || s.currentStage === 'Cancelled') {
        throw refuse('failed-precondition', 'conversationUnavailable');
      }
      conversationUid = `case_${resourceUid}_${s.pathologistUid}`;
      pair = [
        { uid: s.doctorUid, role: 'doctor' },
        { uid: s.pathologistUid, role: 'pathologist' },
      ];
    }
    if (!pair.some((p) => p.uid === c.uid && p.role === c.role)) throw refuse('permission-denied', 'notParticipant');
    if (pair.some((p) => p.uid === '')) throw refuse('failed-precondition', 'conversationUnavailable');

    const ref = db.collection(CONVERSATIONS).doc(conversationUid);
    const existing = (await tx.get(ref)).data();
    if (existing) {
      if (existing.status !== 'Closed') return { conversationUid };
      // A pathologist who was taken off the case and is now its pathologist again picks the thread
      // up where it was left; the history stays. A thread closed any other way stays closed.
      const members = { ...((existing.members ?? {}) as Members) };
      const returning =
        resourceType === 'Order' && c.role === 'pathologist' && members[c.uid]?.status === 'Removed';
      if (!returning) throw refuse('failed-precondition', 'conversationClosed');
      const profile = (await tx.get(db.collection(DOCTORS).doc(c.uid))).data();
      members[c.uid] = memberOf(c.uid, 'pathologist', 'Member', 'Accepted', profile);
      tx.update(ref, {
        status: 'Open',
        closedAt: '',
        members,
        participantUids: acceptedUids(members),
        nextInviteExpiresAt: nextInvite(members),
        lastUpdatedAt: timestamp(now),
      });
      return { conversationUid };
    }
    const profiles: DocumentData[] = [];
    for (const person of pair) {
      if (person.role === 'patient') {
        profiles.push((await tx.get(db.collection(PATIENTS).doc(patientId))).data() ?? {});
      } else {
        profiles.push((await tx.get(db.collection(DOCTORS).doc(person.uid))).data() ?? {});
      }
    }
    const members: Members = {};
    pair.forEach((person, i) => {
      members[person.uid] = memberOf(person.uid, person.role, 'Member', 'Accepted', profiles[i]);
    });
    tx.create(
      ref,
      conversationDoc(
        conversationUid,
        {
          type: 'Direct',
          createdByUid: c.uid,
          linkedResourceType: resourceType,
          linkedResourceUid: resourceUid,
          members,
        },
        now,
      ),
    );
    return { conversationUid };
  });
}

// --- openMdt / inviteToMdt -------------------------------------------------------------------

const SPECIALTIES: readonly string[] = [...CLINICAL_SPECIALTIES, ...PATHOLOGY_SPECIALTIES];

function inviteeList(raw: unknown, caller: string, max: number): string[] {
  if (raw === undefined) return [];
  if (!Array.isArray(raw) || raw.length > max) throw refuse('invalid-argument', 'invalidInvitee');
  const uids = raw.map((u) => idOf(u, 'invalidInvitee'));
  if (new Set(uids).size !== uids.length || uids.includes(caller)) throw refuse('invalid-argument', 'invalidInvitee');
  return uids;
}

interface Invitee {
  uid: string;
  role: 'doctor' | 'pathologist';
  profile: DocumentData;
  language: 'en' | 'sw';
}

/** Read half: every invitee must be a verified practitioner (`practitioners/{uid}` exists). */
async function loadInvitees(tx: Transaction, db: Firestore, uids: string[]): Promise<Invitee[]> {
  const out: Invitee[] = [];
  for (const uid of uids) {
    const profile = (await tx.get(db.collection('practitioners').doc(uid))).data();
    if (!profile) throw refuse('invalid-argument', 'invalidInvitee');
    const doctor = (await tx.get(db.collection(DOCTORS).doc(uid))).data();
    out.push({
      uid,
      role: profile.isPathologist === true ? 'pathologist' : 'doctor',
      profile,
      language: languageIn(doctor),
    });
  }
  return out;
}

function inviteNotes(
  conversationUid: string,
  invitees: { invitee: Invitee; round: number; expiresAt: string; inviterUid: string; inviterRole: string }[],
): NoteSpec[] {
  return invitees.map(({ invitee, round, expiresAt, inviterUid, inviterRole }) =>
    conversationNote('mdtInvited', conversationUid, `${conversationUid}-r${round}`, invitee.uid, invitee.role, invitee.language, {
      expiresAt,
      initiatorUid: inviterUid,
      initiatorRole: inviterRole,
    }),
  );
}

export async function openMdtHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ conversationUid: string }> {
  const c = practitioner(caller);
  const raw = input(data);
  const now = nowOf(deps);
  const conversationUid = uuidOf(raw.conversationUid, 'invalidConversation');
  const caseUid = idOf(raw.caseUid, 'invalidConversation');
  const specialty = oneOf(raw.specialty, SPECIALTIES, 'invalidSpecialty');
  if (typeof raw.description !== 'string') throw refuse('invalid-argument', 'invalidDescription');
  const description = sanitize(raw.description, 1000);
  if (description === '' || /<[a-z/!][^>]*>/i.test(description)) throw refuse('invalid-argument', 'invalidDescription');
  const inviteeUids = inviteeList(raw.inviteeUids, c.uid, MAX_MEMBERS - 1);
  const { db } = deps;
  const ref = db.collection(CONVERSATIONS).doc(conversationUid);

  return db.runTransaction(async (tx) => {
    const existing = (await tx.get(ref)).data();
    const caseSnap = await tx.get(db.collection('cases').doc(caseUid));
    if (!caseSnap.exists) throw refuse('not-found', 'invalidConversation');
    const s = CaseState.from(caseSnap);
    const primary = (c.role === 'doctor' && s.doctorUid === c.uid) || (c.role === 'pathologist' && s.pathologistUid === c.uid);
    if (!primary) throw refuse('permission-denied', 'notPrimaryViewer');
    if (existing) {
      if (existing.createdByUid === c.uid && existing.linkedResourceUid === caseUid) return { conversationUid };
      throw refuse('already-exists', 'alreadyExists');
    }
    if (s.pathologistUid === '' || s.currentStage === 'Cancelled') {
      throw refuse('failed-precondition', 'conversationUnavailable');
    }

    const window = await loadRate(tx, db, `mdts:${c.uid}:${nairobiDayKey(now)}`);
    if (window.count >= MDTS_PER_DAY) throw refuse('resource-exhausted', 'rateLimited');
    const owner = (await tx.get(db.collection(DOCTORS).doc(c.uid))).data();
    const invitees = await loadInvitees(tx, db, inviteeUids);
    const patient = (await tx.get(db.collection(PATIENTS).doc(str(s.fields.patientId)))).data();
    const reportUid = str(s.fields.currentReportUid);
    const report = reportUid ? (await tx.get(db.collection('cases').doc(caseUid).collection('reports').doc(reportUid))).data() : undefined;

    const at = timestamp(now);
    const expiresAt = timestamp(new Date(now.getTime() + INVITE_TTL_MS));
    const members: Members = { [c.uid]: memberOf(c.uid, c.role, 'Owner', 'Accepted', owner) };
    for (const invitee of invitees) {
      members[invitee.uid] = memberOf(invitee.uid, invitee.role, 'Member', 'Invited', invitee.profile, {
        invitedByUid: c.uid,
        invitedAt: at,
        inviteExpiresAt: expiresAt,
        inviteRound: 1,
      });
    }
    const notes = await planNotes(
      tx,
      db,
      inviteNotes(
        conversationUid,
        invitees.map((invitee) => ({ invitee, round: 1, expiresAt, inviterUid: c.uid, inviterRole: c.role })),
      ),
    );

    tx.create(
      ref,
      conversationDoc(
        conversationUid,
        {
          type: 'GroupConsult',
          createdByUid: c.uid,
          linkedResourceType: 'Order',
          linkedResourceUid: caseUid,
          specialty,
          description,
          members,
          caseSummary: mdtCaseSummary(conversationUid, s, patient, report, now),
        },
        now,
      ),
    );
    writeRate(tx, window, now);
    sendNotes(tx, notes, now);
    return { conversationUid };
  });
}

export async function inviteToMdtHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ conversationUid: string }> {
  const c = practitioner(caller);
  const raw = input(data);
  const now = nowOf(deps);
  const conversationUid = uuidOf(raw.conversationUid, 'invalidConversation');
  const inviteeUids = inviteeList(raw.inviteeUids, c.uid, MAX_MEMBERS - 1);
  if (inviteeUids.length === 0) throw refuse('invalid-argument', 'invalidInvitee');
  const { db } = deps;
  const ref = db.collection(CONVERSATIONS).doc(conversationUid);

  return db.runTransaction(async (tx) => {
    const conv = (await tx.get(ref)).data();
    if (!conv || conv.type !== 'GroupConsult') throw refuse('not-found', 'conversationUnavailable');
    if (conv.createdByUid !== c.uid) throw refuse('permission-denied', 'notParticipant');
    if (conv.status !== 'Open') throw refuse('failed-precondition', 'conversationClosed');
    // Backstop: an owner whose place on the case has ended cannot bring anyone to its summary.
    const caseSnap = await tx.get(db.collection('cases').doc(str(conv.linkedResourceUid)));
    if (!caseSnap.exists || !stillPrimary(CaseState.from(caseSnap), c.uid, c.role)) {
      throw refuse('permission-denied', 'notParticipant');
    }
    const members = { ...(conv.members as Members) };
    if (inviteeUids.some((u) => members[u]?.status === 'Invited' || members[u]?.status === 'Accepted')) {
      throw refuse('failed-precondition', 'invalidInvitee');
    }
    if (liveCount(members) + inviteeUids.length > MAX_MEMBERS) throw refuse('failed-precondition', 'tooManyMembers');
    const invitees = await loadInvitees(tx, db, inviteeUids);
    const at = timestamp(now);
    const expiresAt = timestamp(new Date(now.getTime() + INVITE_TTL_MS));
    const rounds = invitees.map((invitee) => ({
      invitee,
      round: num(members[invitee.uid]?.inviteRound) + 1,
      expiresAt,
      inviterUid: c.uid,
      inviterRole: c.role,
    }));
    // A new round replaces the last one, whose row must not stay a pending approval.
    const replaced: LoadedNotification[] = [];
    for (const { invitee, round } of rounds) {
      if (round > 1) {
        replaced.push(await loadRow(tx, db, 'mdtInvited', `${conversationUid}-r${round - 1}`, invitee.uid));
      }
    }
    const notes = await planNotes(tx, db, inviteNotes(conversationUid, rounds));
    for (const { invitee, round } of rounds) {
      members[invitee.uid] = memberOf(invitee.uid, invitee.role, 'Member', 'Invited', invitee.profile, {
        invitedByUid: c.uid,
        invitedAt: at,
        inviteExpiresAt: expiresAt,
        inviteRound: round,
      });
    }
    tx.update(ref, { members, nextInviteExpiresAt: nextInvite(members), lastUpdatedAt: at });
    for (const row of replaced) NotificationTx.settle(tx, row, 'Cancelled', c.uid, now);
    sendNotes(tx, notes, now);
    return { conversationUid };
  });
}

// --- respondToMdtInvite / leaveMdt / removeFromMdt / closeConversation -----------------------

export async function respondToMdtInviteHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = practitioner(caller);
  const raw = input(data);
  const now = nowOf(deps);
  const conversationUid = uuidOf(raw.conversationUid, 'invalidConversation');
  if (typeof raw.accept !== 'boolean') throw refuse('invalid-argument', 'invalidDecision');
  const accept = raw.accept;
  const { db } = deps;
  const ref = db.collection(CONVERSATIONS).doc(conversationUid);

  return db.runTransaction(async (tx) => {
    const conv = (await tx.get(ref)).data();
    const mine = conv?.members?.[c.uid] as DocumentData | undefined;
    if (!conv || !mine) throw refuse('not-found', 'inviteClosed');
    if (mine.status !== 'Invited') {
      if (mine.status === (accept ? 'Accepted' : 'Declined')) return { status: str(mine.status) };
      throw refuse('failed-precondition', 'inviteClosed');
    }
    if (conv.status !== 'Open' || Date.parse(str(mine.inviteExpiresAt)) <= now.getTime()) {
      throw refuse('failed-precondition', 'inviteClosed');
    }
    const ownerUid = str(conv.createdByUid);
    const ownerRole = str((conv.members as Members)[ownerUid]?.actorRole);
    // Backstop: nobody joins a group whose owner has left the case.
    const caseSnap = await tx.get(db.collection('cases').doc(str(conv.linkedResourceUid)));
    if (!caseSnap.exists || !stillPrimary(CaseState.from(caseSnap), ownerUid, ownerRole)) {
      throw refuse('failed-precondition', 'inviteClosed');
    }
    const round = num(mine.inviteRound);
    const row = await loadRow(tx, db, 'mdtInvited', `${conversationUid}-r${round}`, c.uid);
    const notes = await planNotes(tx, db, [
      conversationNote(
        accept ? 'mdtInviteAccepted' : 'mdtInviteDeclined',
        conversationUid,
        `${conversationUid}-r${round}`,
        ownerUid,
        ownerRole,
        await languageFor(tx, db, ownerRole, ownerUid),
        { initiatorUid: c.uid, initiatorRole: c.role },
      ),
    ]);

    const at = timestamp(now);
    const members = { ...(conv.members as Members) };
    members[c.uid] = { ...mine, status: accept ? 'Accepted' : 'Declined', respondedAt: at, inviteExpiresAt: '' };
    tx.update(ref, {
      members,
      participantUids: acceptedUids(members),
      nextInviteExpiresAt: nextInvite(members),
      lastUpdatedAt: at,
    });
    NotificationTx.settle(tx, row, accept ? 'Accepted' : 'Declined', c.uid, now);
    sendNotes(tx, notes, now);
    return { status: accept ? 'Accepted' : 'Declined' };
  });
}

async function changeMembership(
  deps: ConversationsDeps,
  conversationUid: string,
  actor: Caller,
  target: string,
  to: 'Left' | 'Removed',
): Promise<{ status: string }> {
  const now = nowOf(deps);
  const { db } = deps;
  const ref = db.collection(CONVERSATIONS).doc(conversationUid);
  return db.runTransaction(async (tx) => {
    const conv = (await tx.get(ref)).data();
    if (!conv || conv.type !== 'GroupConsult') throw refuse('not-found', 'conversationUnavailable');
    const members = { ...(conv.members as Members) };
    const person = members[target];
    if (to === 'Left') {
      if (!person) throw refuse('permission-denied', 'notParticipant');
    } else if (conv.createdByUid !== actor.uid) {
      throw refuse('permission-denied', 'notParticipant');
    } else if (!person) {
      throw refuse('not-found', 'invalidMember');
    }
    if (target === conv.createdByUid) throw refuse('failed-precondition', 'invalidMember');
    if (person.status === to) return { status: to };
    if (person.status !== 'Accepted' && !(to === 'Removed' && person.status === 'Invited')) {
      throw refuse('failed-precondition', 'invalidMember');
    }
    const invite =
      person.status === 'Invited'
        ? await loadRow(tx, db, 'mdtInvited', `${conversationUid}-r${num(person.inviteRound)}`, target)
        : null;
    const at = timestamp(now);
    members[target] = { ...person, status: to, respondedAt: at, inviteExpiresAt: '' };
    tx.update(ref, {
      members,
      participantUids: acceptedUids(members),
      nextInviteExpiresAt: nextInvite(members),
      lastUpdatedAt: at,
    });
    if (invite) NotificationTx.settle(tx, invite, 'Cancelled', actor.uid, now);
    return { status: to };
  });
}

export async function leaveMdtHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = practitioner(caller);
  const conversationUid = uuidOf(input(data).conversationUid, 'invalidConversation');
  return changeMembership(deps, conversationUid, c, c.uid, 'Left');
}

export async function removeFromMdtHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = practitioner(caller);
  const raw = input(data);
  const conversationUid = uuidOf(raw.conversationUid, 'invalidConversation');
  return changeMembership(deps, conversationUid, c, idOf(raw.memberUid, 'invalidMember'), 'Removed');
}

export async function closeConversationHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = practitioner(caller);
  const now = nowOf(deps);
  const conversationUid = idOf(input(data).conversationUid, 'invalidConversation');
  const { db } = deps;
  const ref = db.collection(CONVERSATIONS).doc(conversationUid);
  return db.runTransaction(async (tx) => {
    const conv = (await tx.get(ref)).data();
    if (!conv) throw refuse('not-found', 'conversationUnavailable');
    const mine = (conv.members as Members)[c.uid];
    const allowed =
      conv.type === 'GroupConsult'
        ? conv.createdByUid === c.uid
        : mine?.status === 'Accepted' && mine.actorRole === 'doctor' && c.role === 'doctor';
    if (!allowed) throw refuse('permission-denied', 'notParticipant');
    if (conv.status === 'Closed') return { status: 'Closed' };
    const at = timestamp(now);
    tx.update(ref, { status: 'Closed', closedAt: at, lastUpdatedAt: at });
    return { status: 'Closed' };
  });
}

// --- When someone's place on a case ends (F-18) ----------------------------------------------

interface Departure {
  close: boolean;
  /** Members to mark `Removed`: the departing person, and every open invite when the thread closes. */
  remove: string[];
}

/**
 * What a departure does to one thread. A pathologist closes their direct thread; an MDT's owner
 * closes the MDT (it is not handed on); any other member is removed. A person who leaves is out
 * of `participantUids` even in a thread that stays closed, so they read nothing more.
 */
function departureOf(conv: DocumentData, departing: Departing): Departure | null {
  const members = (conv.members ?? {}) as Members;
  const pending = Object.values(members)
    .filter((m) => m.status === 'Invited')
    .map((m) => str(m.uid));
  const open = conv.status === 'Open';
  if (departing === 'all') return open ? { close: true, remove: pending } : null;
  const person = members[departing.uid];
  if (!person || (person.status !== 'Accepted' && person.status !== 'Invited')) return null;
  const close = open && (conv.type === 'Direct' || conv.createdByUid === departing.uid);
  return { close, remove: [...new Set([departing.uid, ...(close ? pending : [])])] };
}

interface CaseThread {
  ref: DocumentReference;
  data: DocumentData;
  departure: Departure;
  /** The `mdtInvited` row of each removed member whose invite was still open. */
  invites: LoadedNotification[];
}

export interface CaseThreads {
  threads: CaseThread[];
}

/**
 * Read half. Every thread linked to the case, plus the departing pathologist's direct thread by
 * id, and the open-invite rows that closing or removing would settle. Call it before the first
 * write of the transaction.
 */
export async function loadCaseConversations(
  tx: Transaction,
  db: Firestore,
  caseUid: string,
  departing: Departing,
): Promise<CaseThreads> {
  if (departing !== 'all' && departing.uid === '') return { threads: [] };
  const found = await tx.get(buildQuery(db, queryById('conversations.byCase'), [caseUid]));
  const all = new Map<string, DocumentData & { ref: DocumentReference }>();
  for (const doc of found.docs) all.set(doc.id, { ...doc.data(), ref: doc.ref });
  if (departing !== 'all') {
    const direct = db.collection(CONVERSATIONS).doc(`case_${caseUid}_${departing.uid}`);
    if (!all.has(direct.id)) {
      const snap = await tx.get(direct);
      if (snap.exists) all.set(direct.id, { ...snap.data(), ref: direct });
    }
  }

  const threads: CaseThread[] = [];
  for (const { ref, ...data } of all.values()) {
    const departure = departureOf(data, departing);
    if (!departure) continue;
    const members = (data.members ?? {}) as Members;
    const invites: LoadedNotification[] = [];
    for (const uid of departure.remove) {
      if (members[uid]?.status !== 'Invited') continue;
      invites.push(await loadRow(tx, db, 'mdtInvited', `${ref.id}-r${num(members[uid].inviteRound)}`, uid));
    }
    threads.push({ ref, data, departure, invites });
  }
  return { threads };
}

/**
 * Write half. Status, members and `participantUids` change together through the same helpers the
 * member callables use, and the invites left open are settled `Cancelled`.
 */
export function closeCaseConversations(tx: Transaction, loaded: CaseThreads, now: Date): void {
  const at = timestamp(now);
  for (const { ref, data, departure, invites } of loaded.threads) {
    const members = { ...(data.members as Members) };
    for (const uid of departure.remove) {
      members[uid] = { ...members[uid], status: 'Removed', respondedAt: at, inviteExpiresAt: '' };
    }
    tx.update(ref, {
      members,
      participantUids: acceptedUids(members),
      nextInviteExpiresAt: nextInvite(members),
      ...(departure.close ? { status: 'Closed', closedAt: at } : {}),
      lastUpdatedAt: at,
    });
    for (const row of invites) NotificationTx.settle(tx, row, 'Cancelled', '', now);
  }
}

// --- Voice notes -----------------------------------------------------------------------------

/** The m4a's movie header (`mvhd`) holds its timescale and duration; null when it is not there. */
export function measureM4aMs(bytes: Buffer): number | null {
  const at = bytes.indexOf('mvhd', 0, 'latin1');
  if (at < 0) return null;
  const v = at + 4;
  try {
    const version = bytes[v];
    const timescale = version === 1 ? bytes.readUInt32BE(v + 20) : bytes.readUInt32BE(v + 12);
    const duration = version === 1 ? Number(bytes.readBigUInt64BE(v + 24)) : bytes.readUInt32BE(v + 16);
    if (timescale === 0) return null;
    return Math.round((duration / timescale) * 1000);
  } catch {
    return null;
  }
}

type VoiceCheck =
  | { ok: true; durationMs: number; bytes: Buffer; contentType: string }
  | { ok: false; reason: 'missingAudio' | 'voiceTooLong' };

async function inspectVoice(
  deps: ConversationsDeps,
  conversationUid: string,
  messageUid: string,
  message: DocumentData,
): Promise<VoiceCheck> {
  const file = storageOf(deps)
    .bucket(deps.bucket)
    .file(`${CONVERSATIONS}/${conversationUid}/voice/${messageUid}.m4a`);
  const [exists] = await file.exists();
  if (!exists) return { ok: false, reason: 'missingAudio' };
  const [meta] = await file.getMetadata();
  const contentType = str(meta.contentType);
  if (!AUDIO_TYPES.includes(contentType) || Number(meta.size) > VOICE_MAX_BYTES) {
    return { ok: false, reason: 'voiceTooLong' };
  }
  const [bytes] = await file.download();
  const measured = measureM4aMs(bytes);
  if (measured !== null) {
    if (measured > VOICE_MEASURED_MAX_MS) return { ok: false, reason: 'voiceTooLong' };
    return { ok: true, durationMs: Math.max(1, measured), bytes, contentType };
  }
  // Nothing to measure: the claim stands, within its bound.
  const claimed = num(message.voiceDurationMs);
  if (claimed <= 0 || claimed > VOICE_MAX_MS) return { ok: false, reason: 'voiceTooLong' };
  return { ok: true, durationMs: claimed, bytes, contentType };
}

// --- onMessageCreated ------------------------------------------------------------------------

interface Delivery {
  delivered: boolean;
  voice: VoiceCheck | null;
}

export async function onMessageCreatedHandler(
  deps: ConversationsDeps,
  conversationUid: string,
  messageUid: string,
): Promise<void> {
  const { db } = deps;
  const messageRef = db.collection(CONVERSATIONS).doc(conversationUid).collection('messages').doc(messageUid);
  const first = (await messageRef.get()).data();
  if (!first) return;
  if (first.status === 'Delivered') {
    // A retry after phase 1 committed: only a voice note still waiting for its transcript has
    // work left, and the claim in phase 2 keeps two runs from both transcribing it.
    if (first.kind !== 'Voice' || first.transcriptStatus !== 'Queued') return;
    const again = await inspectVoice(deps, conversationUid, messageUid, first);
    if (again.ok) await transcribeVoiceNote(deps, conversationUid, messageUid, again);
    return;
  }
  if (first.status !== 'Sent') return;

  const voice = first.kind === 'Voice' ? await inspectVoice(deps, conversationUid, messageUid, first) : null;
  const delivery = await deliver(deps, conversationUid, messageUid, voice);
  if (delivery.delivered && delivery.voice?.ok) {
    await transcribeVoiceNote(deps, conversationUid, messageUid, delivery.voice);
  }
}

interface Window {
  start: number;
  count: number;
}

function slide(startRaw: unknown, countRaw: unknown, now: Date, spanMs: number, by: number): Window {
  const start = Date.parse(str(startRaw));
  const live = !Number.isNaN(start) && now.getTime() - start < spanMs;
  return live ? { start, count: num(countRaw) + by } : { start: now.getTime(), count: by };
}

/** Phase 1, one transaction: quotas, then the delivery fan-out or the withholding. */
async function deliver(
  deps: ConversationsDeps,
  conversationUid: string,
  messageUid: string,
  voice: VoiceCheck | null,
): Promise<Delivery> {
  const { db } = deps;
  const now = nowOf(deps);
  const at = timestamp(now);
  const convRef = db.collection(CONVERSATIONS).doc(conversationUid);
  const messageRef = convRef.collection('messages').doc(messageUid);

  return db.runTransaction(async (tx): Promise<Delivery> => {
    const message = (await tx.get(messageRef)).data();
    if (!message || message.status !== 'Sent') return { delivered: false, voice: null };
    const conv = (await tx.get(convRef)).data();
    const senderUid = str(message.senderUid);
    const quotaRef = db.collection('messageQuotas').doc(senderUid);
    const quota = (await tx.get(quotaRef)).data() ?? {};
    const members = (conv?.members ?? {}) as Members;
    const recipients = strings(conv?.participantUids).filter((u) => u !== senderUid);
    const template = conv?.type === 'GroupConsult' ? 'mdtMessageReceived' : 'messageReceived';
    const rows = [];
    for (const uid of recipients) {
      rows.push({
        uid,
        role: str(members[uid]?.actorRole),
        loaded: await loadRow(tx, db, template, conversationUid, uid),
        language: await languageFor(tx, db, str(members[uid]?.actorRole), uid),
      });
    }

    // The text window counts every message; the voice window only voice notes.
    const dayKey = nairobiDayKey(now);
    const minute = slide(quota.textMinuteStart, quota.textMinuteCount, now, MINUTE_MS, 1);
    const sameDay = quota.textDay === dayKey;
    const textDay = (sameDay ? num(quota.textDayCount) : 0) + 1;
    const textOver = minute.count > TEXT_PER_MINUTE || textDay > TEXT_PER_DAY;
    const patch: DocumentData = {
      uid: senderUid,
      textMinuteStart: new Date(minute.start).toISOString(),
      textMinuteCount: minute.count,
      textDay: dayKey,
      textDayCount: textDay,
      lastUpdatedAt: at,
    };
    let voiceOver = false;
    if (message.kind === 'Voice' && voice?.ok) {
      const hour = slide(quota.voiceHourStart, quota.voiceHourCount, now, HOUR_MS, 1);
      const voiceDayMs = (quota.voiceDay === dayKey ? num(quota.voiceDayMs) : 0) + voice.durationMs;
      voiceOver = hour.count > VOICE_PER_HOUR || voiceDayMs > VOICE_MS_PER_DAY;
      Object.assign(patch, {
        voiceHourStart: new Date(hour.start).toISOString(),
        voiceHourCount: hour.count,
        voiceDay: dayKey,
        voiceDayMs,
      });
    }

    let withheld = '';
    if (voice && !voice.ok) withheld = voice.reason;
    else if (Date.parse(str(message.sentAt)) > now.getTime() + FUTURE_SENT_MS || textOver || voiceOver) {
      withheld = 'rateLimited';
    }
    if (textOver) Object.assign(patch, { blocked: true, blockedUntil: new Date(now.getTime() + BLOCK_MS).toISOString() });
    if (voiceOver) {
      Object.assign(patch, { voiceBlocked: true, voiceBlockedUntil: new Date(now.getTime() + BLOCK_MS).toISOString() });
    }

    tx.set(quotaRef, patch, { merge: true });
    if (withheld !== '') {
      tx.update(messageRef, { status: 'Withheld', withheldReason: withheld, lastUpdatedAt: at });
      return { delivered: false, voice: null };
    }

    const sentAt = str(message.sentAt);
    tx.update(messageRef, {
      status: 'Delivered',
      deliveredAt: at,
      lastUpdatedAt: at,
      ...(voice?.ok ? { voiceDurationMs: voice.durationMs } : {}),
    });
    if (conv) {
      const newest = sentAt > str(conv.lastMessageAt);
      tx.update(convRef, {
        ...(newest
          ? {
              lastMessage: {
                uid: messageUid,
                senderUid,
                text: message.kind === 'Text' ? [...str(message.text)].slice(0, 120).join('') : '',
                hasAttachment: message.kind !== 'Text',
                sentAt,
              },
              lastMessageAt: sentAt,
            }
          : {}),
        lastUpdatedAt: at,
      });
    }
    for (const row of rows) {
      NotificationTx.upsertCollapsed(
        tx,
        row.loaded,
        {
          template,
          resourceKey: conversationUid,
          resourceUid: conversationUid,
          threadUid: conversationUid,
          recipientUid: row.uid,
          recipientRole: row.role,
          language: row.language,
          deepLink: `/conversations/${conversationUid}`,
        },
        now,
      );
    }
    return { delivered: true, voice };
  });
}

function languageOf(raw: string): string {
  return ['en', 'sw', 'mixed'].includes(raw) ? raw : '';
}

/** Phase 2: one claim, one model call on the audio alone, one write that re-checks the message. */
async function transcribeVoiceNote(
  deps: ConversationsDeps,
  conversationUid: string,
  messageUid: string,
  voice: Extract<VoiceCheck, { ok: true }>,
): Promise<void> {
  const { db } = deps;
  const now = nowOf(deps);
  const convRef = db.collection(CONVERSATIONS).doc(conversationUid);
  const messageRef = convRef.collection('messages').doc(messageUid);

  const claimed = await db.runTransaction(async (tx) => {
    const message = (await tx.get(messageRef)).data();
    if (!message || message.status !== 'Delivered' || message.transcriptStatus !== 'Queued') return false;
    const at = timestamp(now);
    if (!isEnabled(deps.config, 'voice_input_enabled')) {
      tx.update(messageRef, { transcriptStatus: 'None', lastUpdatedAt: at });
      return false;
    }
    tx.update(messageRef, { transcriptStatus: 'Running', lastUpdatedAt: at });
    return true;
  });
  if (!claimed) return;

  let transcript = '';
  let language = '';
  let models: Record<string, string> = {};
  let failed = false;
  try {
    if (!deps.ai?.transcribeAudio) throw new Error('unavailable');
    const result = await withTimeout(deps.ai.transcribeAudio({ bytes: voice.bytes, contentType: voice.contentType }));
    transcript = sanitize(result.transcript, 2000);
    language = languageOf(result.language);
    models = result.models;
    failed = transcript === '';
  } catch {
    failed = true;
  }

  await db.runTransaction(async (tx) => {
    const message = (await tx.get(messageRef)).data();
    // A withdrawn message stays withdrawn: its transcript must not come back.
    if (!message || message.status !== 'Delivered' || message.transcriptStatus !== 'Running') return;
    const conv = (await tx.get(convRef)).data();
    let flagged = false;
    if (!failed && conv?.type === 'GroupConsult') {
      const caseSnap = await tx.get(db.collection('cases').doc(str(conv.linkedResourceUid)));
      const patient = caseSnap.exists
        ? (await tx.get(db.collection(PATIENTS).doc(str(caseSnap.get('patientId'))))).data()
        : undefined;
      flagged =
        deidentify(transcript, {
          firstName: str(patient?.firstName),
          middleName: str(patient?.middleName),
          lastName: str(patient?.lastName),
          phoneNumber: str(patient?.phoneNumber),
          email: str(patient?.email),
        }) !== transcript;
    }
    const at = timestamp(now);
    if (failed) {
      tx.update(messageRef, { transcriptStatus: 'Failed', lastUpdatedAt: at });
    } else {
      tx.set(messageRef.collection('transcript').doc('machine'), {
        uid: 'machine',
        conversationUid,
        messageUid,
        senderUid: str(message.senderUid),
        text: transcript,
        language,
        acceptedUnchanged: false,
        editDistance: 0,
        models,
        sharedAt: '',
        lastUpdatedAt: at,
      });
      tx.update(messageRef, {
        transcriptStatus: 'Ready',
        transcriptLanguage: language,
        identifierFlagged: flagged,
        lastUpdatedAt: at,
      });
    }
    bumpModelSignal(tx, db, failed ? 'voiceTranscriptFailed' : 'voiceTranscriptReady', now);
  });
}

// --- withdrawMessage / shareTranscript -------------------------------------------------------

export async function withdrawMessageHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = clinical(caller);
  const raw = input(data);
  const now = nowOf(deps);
  const conversationUid = idOf(raw.conversationUid, 'invalidConversation');
  const messageUid = uuidOf(raw.messageUid, 'invalidMessage');
  const { db } = deps;
  const convRef = db.collection(CONVERSATIONS).doc(conversationUid);
  const messageRef = convRef.collection('messages').doc(messageUid);

  const message = (await messageRef.get()).data();
  if (!message || message.senderUid !== c.uid) throw refuse('not-found', 'invalidMessage');
  if (message.status === 'Withheld' && message.withheldReason === 'withdrawn') return { status: 'Withdrawn' };
  checkWithdrawable(message, now);

  // 1. The object first: not-found counts as done, any other failure stops the withdraw (F-15).
  const path = str(message.attachmentPath);
  if (path !== '') {
    await storageOf(deps).bucket(deps.bucket).file(path).delete({ ignoreNotFound: true });
  }

  // 2 and 3. One transaction clears the text and the transcripts and stamps both documents.
  return db.runTransaction(async (tx) => {
    const current = (await tx.get(messageRef)).data();
    if (!current) throw refuse('not-found', 'invalidMessage');
    if (current.status === 'Withheld' && current.withheldReason === 'withdrawn') return { status: 'Withdrawn' };
    checkWithdrawable(current, now);
    const conv = (await tx.get(convRef)).data();
    const at = timestamp(now);
    tx.update(messageRef, {
      status: 'Withheld',
      withheldReason: 'withdrawn',
      text: '',
      transcriptShared: false,
      identifierFlagged: false,
      lastUpdatedAt: at,
    });
    tx.delete(messageRef.collection('transcript').doc('machine'));
    tx.delete(messageRef.collection('transcript').doc('shared'));
    const last = conv?.lastMessage as DocumentData | undefined;
    tx.update(convRef, {
      ...(last?.uid === messageUid ? { lastMessage: emptyMessage() } : {}),
      lastUpdatedAt: at,
    });
    return { status: 'Withdrawn' };
  });
}

function checkWithdrawable(message: DocumentData, now: Date): void {
  if (message.status !== 'Delivered') throw refuse('failed-precondition', 'notDelivered');
  if (now.getTime() - Date.parse(str(message.deliveredAt)) > WITHDRAW_WINDOW_MS) {
    throw refuse('failed-precondition', 'withdrawWindowClosed');
  }
}

export async function shareTranscriptHandler(
  deps: ConversationsDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: string }> {
  const c = practitioner(caller);
  const raw = input(data);
  const now = nowOf(deps);
  const conversationUid = idOf(raw.conversationUid, 'invalidConversation');
  const messageUid = uuidOf(raw.messageUid, 'invalidMessage');
  const decision = oneOf(raw.decision, ['Approve', 'ApproveEdited'] as const, 'invalidDecision');
  const edited = decision === 'ApproveEdited' ? (typeof raw.text === 'string' ? sanitize(raw.text, 2000) : '') : '';
  if (decision === 'ApproveEdited' && edited === '') throw refuse('invalid-argument', 'invalidText');
  const { db } = deps;
  const convRef = db.collection(CONVERSATIONS).doc(conversationUid);
  const messageRef = convRef.collection('messages').doc(messageUid);

  return db.runTransaction(async (tx) => {
    const message = (await tx.get(messageRef)).data();
    if (!message || message.senderUid !== c.uid || message.kind !== 'Voice') throw refuse('not-found', 'invalidMessage');
    const sharedRef = messageRef.collection('transcript').doc('shared');
    const shared = await tx.get(sharedRef);
    if (shared.exists) return { status: 'Shared' };
    const machine = (await tx.get(messageRef.collection('transcript').doc('machine'))).data();
    if (message.status !== 'Delivered' || message.transcriptStatus !== 'Ready' || !machine) {
      throw refuse('failed-precondition', 'transcriptNotReady');
    }
    const at = timestamp(now);
    const machineText = str(machine.text);
    const unchanged = decision === 'Approve';
    tx.create(sharedRef, {
      uid: 'shared',
      conversationUid,
      messageUid,
      senderUid: c.uid,
      text: unchanged ? machineText : edited,
      language: str(machine.language),
      acceptedUnchanged: unchanged,
      editDistance: unchanged ? 0 : editDistance(machineText, edited),
      models: {},
      sharedAt: at,
      lastUpdatedAt: at,
    });
    tx.update(messageRef, { transcriptShared: true, lastUpdatedAt: at });
    bumpModelSignal(tx, db, 'voiceTranscriptShared', now);
    if (unchanged) bumpModelSignal(tx, db, 'voiceTranscriptSharedUnchanged', now);
    return { status: 'Shared' };
  });
}

// --- sweepConversations ----------------------------------------------------------------------

export interface SweepResult {
  invitesExpired: number;
  quotasUnblocked: number;
  transcriptsFailed: number;
  mediaDeleted: number;
}

export async function sweepConversationsHandler(deps: ConversationsDeps): Promise<SweepResult> {
  const { db } = deps;
  const now = nowOf(deps);
  const iso = timestamp(now);
  const result: SweepResult = { invitesExpired: 0, quotasUnblocked: 0, transcriptsFailed: 0, mediaDeleted: 0 };

  const invites = await buildQuery(db, queryById('conversations.inviteExpiring'), ['GroupConsult', '', iso])
    .limit(SWEEP_LIMIT)
    .get();
  for (const doc of invites.docs) {
    try {
      if (await expireInvites(db, doc.ref, now)) result.invitesExpired += 1;
    } catch {
      // One poisoned invite must not starve the rest of the sweep.
    }
  }

  for (const [id, flag, until] of [
    ['messageQuotas.textBlocked', 'blocked', 'blockedUntil'],
    ['messageQuotas.voiceBlocked', 'voiceBlocked', 'voiceBlockedUntil'],
  ] as const) {
    const blocked = await buildQuery(db, queryById(id), [true, iso]).limit(SWEEP_LIMIT).get();
    for (const doc of blocked.docs) {
      try {
        if (await unblock(db, doc.ref, flag, until, now)) result.quotasUnblocked += 1;
      } catch {
        // One poisoned quota must not starve the rest of the sweep.
      }
    }
  }

  const stale = await buildQuery(db, queryById('messages.transcriptStale'), [
    'Running',
    timestamp(new Date(now.getTime() - TRANSCRIPT_STALE_MS)),
  ])
    .limit(SWEEP_LIMIT)
    .get();
  for (const doc of stale.docs) {
    try {
      if (await failStaleTranscript(db, doc.ref, now)) result.transcriptsFailed += 1;
    } catch {
      // One poisoned transcript must not starve the rest of the sweep.
    }
  }

  result.mediaDeleted = await deleteOrphanMedia(deps, now);
  return result;
}

async function expireInvites(db: Firestore, ref: DocumentReference, now: Date): Promise<boolean> {
  return db.runTransaction(async (tx) => {
    const conv = (await tx.get(ref)).data();
    if (!conv) return false;
    const members = { ...(conv.members as Members) };
    const due = Object.values(members).filter(
      (m) => m.status === 'Invited' && Date.parse(str(m.inviteExpiresAt)) <= now.getTime(),
    );
    if (due.length === 0) return false;
    const rows = [];
    for (const m of due) {
      rows.push(await loadRow(tx, db, 'mdtInvited', `${ref.id}-r${num(m.inviteRound)}`, str(m.uid)));
    }
    const at = timestamp(now);
    for (const m of due) {
      members[str(m.uid)] = { ...m, status: 'Expired', respondedAt: at, inviteExpiresAt: '' };
    }
    tx.update(ref, {
      members,
      participantUids: acceptedUids(members),
      nextInviteExpiresAt: nextInvite(members),
      lastUpdatedAt: at,
    });
    for (const row of rows) NotificationTx.settle(tx, row, 'Expired', '', now);
    return true;
  });
}

async function unblock(
  db: Firestore,
  ref: DocumentReference,
  flag: string,
  until: string,
  now: Date,
): Promise<boolean> {
  return db.runTransaction(async (tx) => {
    const quota = (await tx.get(ref)).data();
    if (!quota || quota[flag] !== true || str(quota[until]) > timestamp(now)) return false;
    tx.update(ref, { [flag]: false, [until]: '', lastUpdatedAt: timestamp(now) });
    return true;
  });
}

async function failStaleTranscript(db: Firestore, ref: DocumentReference, now: Date): Promise<boolean> {
  return db.runTransaction(async (tx) => {
    const message = (await tx.get(ref)).data();
    if (
      !message ||
      message.transcriptStatus !== 'Running' ||
      Date.parse(str(message.lastUpdatedAt)) > now.getTime() - TRANSCRIPT_STALE_MS
    ) {
      return false;
    }
    tx.update(ref, { transcriptStatus: 'Failed', lastUpdatedAt: timestamp(now) });
    bumpModelSignal(tx, db, 'voiceTranscriptFailed', now);
    return true;
  });
}

const MEDIA_PATH =
  /^conversations\/([^/]+)\/(?:images\/([^/]+)\/image\.(?:jpg|png)|voice\/([^/]+)\.m4a)$/;

/**
 * An upload whose message never arrived is deleted after a day (M-5, F-22), and so is the media
 * of a message that was withheld. One page of {@link MEDIA_PAGE} objects a run: the page token
 * is kept between runs and the walk starts again at the end of the bucket. Firestore is read
 * only for objects old enough to be orphans.
 */
async function deleteOrphanMedia(deps: ConversationsDeps, now: Date): Promise<number> {
  const cursor = deps.db.collection('rateCounters').doc('sweep:conversationMedia');
  let deleted = 0;
  try {
    const bucket = storageOf(deps).bucket(deps.bucket);
    const pageToken = str((await cursor.get()).get('pageToken'));
    const [files, next] = await bucket.getFiles({
      prefix: 'conversations/',
      autoPaginate: false,
      maxResults: MEDIA_PAGE,
      ...(pageToken === '' ? {} : { pageToken }),
    });

    const candidates = files.flatMap((file) => {
      const match = MEDIA_PATH.exec(file.name);
      const created = Date.parse(str(file.metadata.timeCreated));
      if (!match || Number.isNaN(created) || now.getTime() - created <= ORPHAN_MEDIA_MS) return [];
      const ref = deps.db
        .collection(CONVERSATIONS)
        .doc(match[1])
        .collection('messages')
        .doc(match[2] ?? match[3]);
      return [{ file, ref }];
    });
    const messages = candidates.length === 0 ? [] : await deps.db.getAll(...candidates.map((c) => c.ref));
    for (const [i, { file }] of candidates.entries()) {
      const message = messages[i];
      if (message.exists && message.get('status') !== 'Withheld') continue;
      await file.delete({ ignoreNotFound: true });
      deleted += 1;
    }

    const token = (next as { pageToken?: string } | null)?.pageToken ?? '';
    await cursor.set({ pageToken: token, expireAt: ttlAt(now), lastUpdatedAt: timestamp(now) });
  } catch (error) {
    // Storage is not reachable from this run; the next one tries again from the same page.
    logger.error('deleteOrphanMedia failed', { deleted, reason: String(error) });
  }
  return deleted;
}
