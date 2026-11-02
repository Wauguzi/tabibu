/**
 * Helpers the case, share and report handlers share. None is a callable. Every helper that reads
 * does so before the caller writes; the ones that do both say so.
 */
import { createHash, randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import {
  Timestamp,
  type DocumentData,
  type DocumentReference,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

import type { ReportVersionAccess } from './access';
import type { AiClient } from './ai';
import {
  nairobiDate,
  nairobiDayKey,
  refuse,
  requireCaller,
  timestamp,
  type AuthLike,
  type Caller,
  type Role,
} from './common';
import type { ConfigReader } from './config';
import { prereadProfileOf } from './lab-tests';
import {
  NotificationTx,
  type LoadedNotification,
  type NotifyLanguage,
} from './notifications';
import { CaseState, transition, type RequestedPathologist } from './orchestrator';
import { DATA_DIR } from './reference-data';

export interface Deps {
  db: Firestore;
  auth?: AuthLike;
  bucket: string;
  now?: () => Date;
  ai?: AiClient;
  config?: ConfigReader;
  shareCodeKey?: string;
  /** True on the demo project: notifiable events are synthetic, so only demo accounts are alerted. */
  synthetic?: boolean;
  /** Test seams: the AI call's time limit, and the share-code generator. */
  aiTimeoutMs?: number;
  generateShareCode?: () => string;
}

export function nowOf(deps: Deps): Date {
  return (deps.now ?? (() => new Date()))();
}

export const REQUEST_WINDOW_MS = 24 * 60 * 60 * 1000;
export const DAY_MS = 24 * 60 * 60 * 1000;
export const PREREAD_STALE_MS = 30 * 60 * 1000;
/** A notes run `Running` this long has lost its worker; it is failed, never called again. */
export const AI_RUNNING_STALE_MS = 2 * 60 * 1000;
export const MAX_SLIDES = 20;
export const MAX_VIEWERS = 10;
export const DAILY_ORDER_LIMIT = 50;
const COUNTER_TTL_MS = 30 * DAY_MS;

export function str(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

export function num(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

export function strings(value: unknown): string[] {
  return Array.isArray(value) ? value.filter((x): x is string => typeof x === 'string') : [];
}

export function records(value: unknown): DocumentData[] {
  return Array.isArray(value)
    ? value.filter((x): x is DocumentData => x !== null && typeof x === 'object')
    : [];
}

const UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const ID = /^[A-Za-z0-9_.:-]{1,128}$/;

export function uuidOf(raw: unknown, reason: string): string {
  if (typeof raw !== 'string' || !UUID_V4.test(raw)) throw refuse('invalid-argument', reason);
  return raw.toLowerCase();
}

/** An id that becomes a document path segment, so no slash and no surprises. */
export function idOf(raw: unknown, reason: string): string {
  if (typeof raw !== 'string' || !ID.test(raw)) throw refuse('invalid-argument', reason);
  return raw;
}

export function newUid(): string {
  return randomUUID();
}

export function sha256(text: string | Buffer): string {
  return createHash('sha256').update(text).digest('hex');
}

/** `title firstName lastName`, however much of it the profile has. */
export function displayName(data: DocumentData | undefined): string {
  return [data?.title, data?.firstName, data?.lastName]
    .filter((p): p is string => typeof p === 'string' && p.trim() !== '')
    .join(' ');
}

export function requireRole(caller: Caller | null, role: Role): Caller {
  const c = requireCaller(caller);
  if (c.role !== role) throw refuse('permission-denied', `${role}sOnly`);
  return c;
}

/** For callables two roles may use; a caller with no role, or another one, is refused. */
export function requireRoleIn(caller: Caller | null, roles: readonly Role[]): Caller {
  // `Caller.role` is the raw claim, so a role-less or unknown claim fails the membership test.
  const c = requireCaller(caller);
  if (!(roles as readonly string[]).includes(c.role)) throw refuse('permission-denied', 'roleNotAllowed');
  return c;
}

export const OK = { status: 'ok' } as const;

export function languageIn(data: DocumentData | undefined): NotifyLanguage {
  return data?.language === 'sw' ? 'sw' : 'en';
}

/** Whole years on Nairobi's calendar; -1 when there is no usable date of birth. */
export function ageYears(dateOfBirth: string, now: Date): number {
  if (!/^\d{4}-\d{2}-\d{2}/.test(dateOfBirth)) return -1;
  const today = nairobiDate(now);
  let years = Number(today.slice(0, 4)) - Number(dateOfBirth.slice(0, 4));
  if (today.slice(5) < dateOfBirth.slice(5)) years -= 1;
  return Math.max(0, years);
}

/** The surveillance-style bands; a banded age is all a model sees. No age gives no band. */
export function ageBand(years: number): string {
  if (years < 0) return '';
  if (years < 5) return '0-4';
  if (years < 15) return '5-14';
  if (years < 25) return '15-24';
  if (years < 45) return '25-44';
  if (years < 65) return '45-64';
  return '65+';
}

export function ttl(now: Date): Timestamp {
  return Timestamp.fromMillis(now.getTime() + COUNTER_TTL_MS);
}

// --- Loading ---------------------------------------------------------------------------------

export interface LoadedCase {
  ref: DocumentReference;
  s: CaseState;
}

export async function loadCase(tx: Transaction, db: Firestore, caseUid: string): Promise<LoadedCase> {
  const ref = db.collection('cases').doc(caseUid);
  const snap = await tx.get(ref);
  if (!snap.exists) throw refuse('not-found', 'invalidCase');
  return { ref, s: CaseState.from(snap) };
}

/** Who a notification is for, by the language on their own profile. */
export async function languageOf(
  tx: Transaction,
  db: Firestore,
  collection: 'doctors' | 'patients',
  id: string,
): Promise<NotifyLanguage> {
  if (!id) return 'en';
  return languageIn((await tx.get(db.collection(collection).doc(id))).data());
}

export interface LoadedVersion {
  uid: string;
  version: number;
  data: DocumentData;
  access: ReportVersionAccess;
}

/** Every signed version of a case, oldest first, in the shape `access.ts` takes. */
export async function loadVersions(tx: Transaction, caseRef: DocumentReference): Promise<LoadedVersion[]> {
  const snap = await tx.get(caseRef.collection('reports'));
  return snap.docs
    .map((d) => {
      const data = d.data();
      return {
        uid: d.id,
        version: num(data.version),
        data,
        access: {
          uid: d.id,
          pathologistUid: str(data.pathologistUid),
          readerUids: strings(data.readerUids),
          releasedToPatient: data.releasedToPatient === true,
          doctorOpenedAt: str(data.doctorOpenedAt),
          ref: d.ref,
        },
      };
    })
    .sort((a, b) => a.version - b.version);
}

// --- Case state ------------------------------------------------------------------------------

export function declinedOf(s: CaseState): string[] {
  return strings(s.fields.declinedPathologistUids);
}

export function testsOf(s: CaseState): DocumentData[] {
  return records(s.fields.tests);
}

export function testIdsOf(s: CaseState): string[] {
  return testsOf(s).map((t) => str(t.labTestId));
}

export function slidesOf(s: CaseState): DocumentData[] {
  return records(s.fields.slideImages);
}

export function requestFor(uid: string, name: string, now: Date): RequestedPathologist {
  return {
    uid,
    name,
    requestedAt: timestamp(now),
    expiresAt: timestamp(new Date(now.getTime() + REQUEST_WINDOW_MS)),
  };
}

/**
 * A request that ran out of time returns to the doctor. The pathologist who let it lapse joins
 * the declined list, so the picker hides them.
 */
export function expirePathologistRequest(s: CaseState, opts: { actorUid?: string } = {}): CaseState {
  const declined = [...new Set([...declinedOf(s), s.requestedPathologistUid].filter((x) => x !== ''))];
  return transition(s, 'PathologistRejected', {
    actorUid: opts.actorUid ?? '',
    actorRole: 'System',
    action: 'Expire',
  }).with({ declinedPathologistUids: declined });
}

/** Who leaves a case's conversations; the load and apply halves are in `conversations.ts`. */
export type Departing = { uid: string } | 'all';

// --- Notifications ---------------------------------------------------------------------------

export interface NoteSpec {
  template: string;
  resourceKey: string;
  caseUid: string;
  recipientUid: string;
  recipientRole: 'doctor' | 'patient' | 'pathologist';
  language: NotifyLanguage;
  resourceUid?: string;
  expiresAt?: string;
  deepLink?: string;
  templateArgs?: Record<string, string>;
  /** Raise only when the template is `raisable` (a critical report). */
  priority?: 'Normal' | 'High';
}

export interface PlannedNote {
  loaded: LoadedNotification;
  spec: NoteSpec;
}

/** Read half: load every row this step will create. Null specs (no such recipient) are skipped. */
export async function planNotes(
  tx: Transaction,
  db: Firestore,
  specs: (NoteSpec | null)[],
): Promise<PlannedNote[]> {
  const out: PlannedNote[] = [];
  for (const spec of specs) {
    if (!spec || !spec.recipientUid) continue;
    out.push({
      loaded: await NotificationTx.load(tx, db, spec.template, spec.resourceKey, spec.recipientUid),
      spec,
    });
  }
  return out;
}

export function sendNotes(tx: Transaction, notes: PlannedNote[], now: Date): void {
  for (const { loaded, spec } of notes) {
    NotificationTx.create(
      tx,
      loaded,
      {
        template: spec.template,
        resourceKey: spec.resourceKey,
        resourceUid: spec.resourceUid ?? spec.caseUid,
        threadUid: spec.caseUid,
        recipientUid: spec.recipientUid,
        recipientRole: spec.recipientRole,
        language: spec.language,
        expiresAt: spec.expiresAt,
        deepLink: spec.deepLink ?? `/cases/${spec.caseUid}`,
        templateArgs: spec.templateArgs,
        priority: spec.priority,
      },
      now,
    );
  }
}

/**
 * The inbox row that asked the current requested pathologist to accept: the log's latest entry
 * into `PathologistRequested` names its sequence. Null when nobody is requested.
 */
export async function loadRequestRow(
  tx: Transaction,
  db: Firestore,
  caseRef: DocumentReference,
  s: CaseState,
): Promise<LoadedNotification | null> {
  if (!s.requestedPathologistUid) return null;
  const rows = await tx.get(caseRef.collection('log'));
  let seq = 0;
  for (const row of rows.docs) {
    if (row.get('toStage') === 'PathologistRequested') seq = Math.max(seq, num(row.get('seq')));
  }
  if (seq === 0) return null;
  return NotificationTx.load(tx, db, 'pathologistRequested', `${s.uid}-r${seq}`, s.requestedPathologistUid);
}

// --- Order numbers ---------------------------------------------------------------------------

function letter(name: string): string {
  const plain = name.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  const match = /[A-Za-z]/.exec(plain);
  return match ? match[0].toUpperCase() : 'X';
}

export interface NameParts {
  firstName: string;
  middleName?: string;
  lastName: string;
}

/**
 * `ODR-{doctor initials}-{patient initials}-{DDMMYYYY}-{00N}` from the doctor's daily counter
 * (Nairobi date), skipping a number another pair already holds. It reads, then writes: call it
 * after every other read of the transaction. The number never goes into a log line, a push, a
 * prompt or an event.
 */
export async function mintOrderNumber(
  tx: Transaction,
  db: Firestore,
  doctor: NameParts & { uid: string },
  patient: NameParts,
  now: Date,
): Promise<string> {
  const doctorPart = `${letter(doctor.firstName)}${letter(doctor.lastName)}`;
  const patientPart = [patient.firstName, patient.middleName ?? '', patient.lastName]
    .filter((p) => p.trim() !== '')
    .map(letter)
    .join('');
  const [year, month, day] = nairobiDate(now).split('-');
  const counterRef = db.collection('orderCounters').doc(`${doctor.uid}_${nairobiDayKey(now)}`);
  const count = num((await tx.get(counterRef)).get('count'));
  if (count >= DAILY_ORDER_LIMIT) throw refuse('resource-exhausted', 'dailyOrderLimit');

  let number = '';
  let seq = count;
  for (let attempt = 1; attempt <= 5 && number === ''; attempt++) {
    seq = count + attempt;
    const candidate = `ODR-${doctorPart}-${patientPart}-${day}${month}${year}-${String(seq).padStart(3, '0')}`;
    if (!(await tx.get(db.collection('orderNumbers').doc(candidate))).exists) number = candidate;
  }
  if (number === '') throw refuse('aborted', 'orderNumberBusy');

  const at = timestamp(now);
  tx.set(counterRef, {
    doctorUid: doctor.uid,
    date: nairobiDate(now),
    count: seq,
    expireAt: ttl(now),
    lastUpdatedAt: at,
  });
  tx.create(db.collection('orderNumbers').doc(number), {
    doctorUid: doctor.uid,
    expireAt: ttl(now),
    createdAt: at,
    lastUpdatedAt: at,
  });
  return number;
}

// --- Reference data --------------------------------------------------------------------------

export interface Insurer {
  insurerId: string;
  name: string;
  type: string;
}

const insurers = new Map<string, Insurer>(
  (JSON.parse(readFileSync(join(DATA_DIR, 'insurers.json'), 'utf8')) as Insurer[]).map((i) => [
    i.insurerId,
    i,
  ]),
);

export function insurerById(id: string): Insurer | undefined {
  return insurers.get(id);
}

interface TemplateFile {
  templateKey: string;
  testTypeIds: string[];
  sections: { sectionKey: string; order: number; questions: { questionKey: string; required: boolean }[] }[];
}

const templates = JSON.parse(readFileSync(join(DATA_DIR, 'report_templates.json'), 'utf8')) as TemplateFile[];

/** Cancer beats Malaria beats General, so a mixed order reads the more specific template. */
export function reportTemplateFor(testTypeIds: readonly string[]): string {
  const keys = new Set(
    templates.filter((t) => t.testTypeIds.some((id) => testTypeIds.includes(id))).map((t) => t.templateKey),
  );
  if (keys.has('Cancer')) return 'Cancer';
  if (keys.has('Malaria')) return 'Malaria';
  return 'General';
}

export function requiredQuestions(templateKey: string): string[] {
  const template = templates.find((t) => t.templateKey === templateKey);
  return (template?.sections ?? []).flatMap((s) => s.questions.filter((q) => q.required).map((q) => q.questionKey));
}

// --- Pre-read --------------------------------------------------------------------------------

/**
 * Creates a `Queued` run and moves the case to `PrereadQueued`, only when the switch is on and
 * the order has image-bearing tests with slides. Returns the case unchanged otherwise. The AI
 * service picks the run up; this never calls it.
 */
export function queuePreread(
  tx: Transaction,
  caseRef: DocumentReference,
  s: CaseState,
  now: Date,
  enabled: boolean,
): CaseState {
  const slides = slidesOf(s);
  const profile = prereadProfileOf(testIdsOf(s));
  if (!enabled || !s.requiresSlides || slides.length === 0 || profile === 'None') return s;
  const runUid = newUid();
  const at = timestamp(now);
  tx.create(caseRef.collection('preread').doc(runUid), {
    uid: runUid,
    caseUid: s.uid,
    profile,
    status: 'Queued',
    imagePaths: slides.map((i) => str(i.path)),
    micronsPerPixel: num(slides[0].micronsPerPixel),
    segmentationPath: '',
    labelsPath: '',
    labelCounts: {},
    measurements: {},
    draft: {
      findings: [],
      impression: '',
      confidence: 0,
      confidenceBand: '',
      urgency: '',
      nextSteps: [],
    },
    models: {},
    inputLanguage: '',
    failureReason: '',
    requestedAt: at,
    startedAt: '',
    readyAt: '',
    lastUpdatedAt: at,
  });
  return transition(s.with({ prereadRunUid: runUid }), 'PrereadQueued', {
    actorUid: s.pathologistUid,
    actorRole: 'Pathologist',
  });
}

// --- Worklist --------------------------------------------------------------------------------

const URGENCY_RANK: Record<string, number> = { Routine: 100, Priority: 200, Urgent: 300 };

export function maxUrgency(a: string, b: string): string {
  return (URGENCY_RANK[a] ?? 100) >= (URGENCY_RANK[b] ?? 100) ? a || 'Routine' : b;
}

/** S-6: the desk's rank is code. The device adds the time waiting. */
export function rankCase(input: {
  urgency: string;
  confidenceBand: string;
  prereadStatus: string;
  riskFlag: boolean;
}): { basePriority: number; severity: string } {
  let basePriority = URGENCY_RANK[input.urgency] ?? 100;
  if (input.prereadStatus === 'Ready') {
    if (input.confidenceBand === 'Low') basePriority += 50;
    else if (input.confidenceBand === 'Moderate') basePriority += 20;
  }
  if (input.prereadStatus === 'Failed') basePriority += 50;
  if (input.riskFlag) basePriority += 100;
  const severity = basePriority >= 300 ? 'Urgent' : basePriority >= 200 ? 'Priority' : 'Routine';
  return { basePriority, severity };
}

export interface LoadedWorklist {
  ref: DocumentReference;
  data: DocumentData | undefined;
}

export async function loadWorklist(tx: Transaction, db: Firestore, caseUid: string): Promise<LoadedWorklist> {
  const ref = db.collection('worklist').doc(caseUid);
  return { ref, data: (await tx.get(ref)).data() };
}

export interface WorklistPatch {
  status?: 'Open' | 'InProgress' | 'Signed';
  prereadStatus?: string;
  /** The pre-read's own urgency; the entry keeps the higher of it and the order's priority. */
  urgency?: string;
  confidenceBand?: string;
  confidence?: number;
  riskFlag?: boolean;
}

/**
 * Writes the desk entry for the case's current pathologist. A missing or `Closed` entry is only
 * (re)written when `reopen` is set, which `acceptCase` alone does (F-14). Returns whether it wrote.
 */
export function upsertWorklist(
  tx: Transaction,
  loaded: LoadedWorklist,
  s: CaseState,
  patch: WorklistPatch,
  now: Date,
  opts: { reopen?: boolean } = {},
): boolean {
  const reopen = opts.reopen === true;
  if (!s.pathologistUid) return false;
  if (!reopen && (!loaded.data || loaded.data.status === 'Closed')) return false;
  const prev: DocumentData = reopen ? {} : (loaded.data ?? {});
  const at = timestamp(now);
  const prereadStatus = patch.prereadStatus ?? str(prev.prereadStatus);
  const urgency = maxUrgency(str(s.fields.priority) || 'Routine', patch.urgency ?? '');
  const confidenceBand = patch.confidenceBand ?? (str(prev.confidenceBand) || 'Low');
  const riskFlag = patch.riskFlag ?? prev.riskFlag === true;
  const { basePriority, severity } = rankCase({ urgency, confidenceBand, prereadStatus, riskFlag });
  tx.set(loaded.ref, {
    uid: s.uid,
    caseUid: s.uid,
    pathologistUid: s.pathologistUid,
    orderNumber: str(s.fields.orderNumber),
    testName: testsOf(s).map((t) => str(t.name)).join(', '),
    profile: prereadProfileOf(testIdsOf(s)),
    status: patch.status ?? (str(prev.status) || 'Open'),
    prereadStatus,
    urgency,
    confidenceBand,
    confidence: patch.confidence ?? num(prev.confidence),
    riskFlag,
    severity,
    basePriority,
    waitingSince: str(s.fields.pathologistAcceptedAt),
    assignedAt: str(prev.assignedAt) || at,
    lastUpdatedAt: at,
  });
  return true;
}

/** Closes the entry and clears the pathologist and every AI field, so the former reader sees nothing (F-14). */
export function closeWorklist(tx: Transaction, loaded: LoadedWorklist, now: Date): void {
  if (!loaded.data || loaded.data.status === 'Closed') return;
  tx.update(loaded.ref, {
    status: 'Closed',
    pathologistUid: '',
    prereadStatus: '',
    urgency: 'Routine',
    confidenceBand: 'Low',
    confidence: 0,
    riskFlag: false,
    severity: 'Routine',
    basePriority: 0,
    lastUpdatedAt: timestamp(now),
  });
}

// --- Storage ---------------------------------------------------------------------------------

export async function objectContentType(bucket: string, path: string): Promise<string | null> {
  const file = getStorage().bucket(bucket).file(path);
  const [exists] = await file.exists();
  if (!exists) return null;
  const [meta] = await file.getMetadata();
  return typeof meta.contentType === 'string' ? meta.contentType : '';
}

export async function saveObject(bucket: string, path: string, bytes: Buffer, contentType: string): Promise<void> {
  await getStorage().bucket(bucket).file(path).save(bytes, { contentType, resumable: false });
}

export async function readObject(bucket: string, path: string): Promise<Buffer | null> {
  const file = getStorage().bucket(bucket).file(path);
  const [exists] = await file.exists();
  if (!exists) return null;
  const [bytes] = await file.download();
  return bytes;
}
