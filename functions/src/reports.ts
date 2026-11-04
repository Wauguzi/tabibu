// cspell:ignore IHDR
/**
 * Report handlers (plan §3.4, reports) and the report triggers (§3.5). A report is signed by the
 * pathologist who owns it and released to the patient only by the ordering doctor's
 * `markDiscussed`: no other function sets `releasedToPatient` (S-3). Numbers are computed in
 * code, never read back from a model (S-6). Reads precede writes in every transaction (R-3).
 */
import type { DocumentData, DocumentReference, Transaction } from 'firebase-admin/firestore';

import { syncCaseReaders } from './access';
import { otherLanguage, withTimeout } from './ai';
import { linkUidFor, validateFindings, writeNotifiableEvents, type LinkInput } from './alerts';
import {
  DAY_MS,
  OK,
  PREREAD_STALE_MS,
  displayName,
  languageIn,
  languageOf,
  loadCase,
  loadVersions,
  loadWorklist,
  newUid,
  nowOf,
  num,
  planNotes,
  readObject,
  records,
  requiredQuestions,
  reportTemplateFor,
  requireRole,
  requireRoleIn,
  saveObject,
  sendNotes,
  sha256,
  str,
  strings,
  testsOf,
  upsertWorklist,
  uuidOf,
  type Deps,
} from './case-support';
import {
  DOCTORS,
  PATIENTS,
  input,
  oneOf,
  refuse,
  timestamp,
  type Caller,
} from './common';
import { isEnabled } from './config';
import { applyCounts, loadMarks } from './counters';
import { diseaseById } from './disease-data';
import { prereadProfileOf } from './lab-tests';
import { NotificationTx, type NotifyLanguage } from './notifications';
import { CaseState, commitCase, transition, type CaseStage } from './orchestrator';
import { processQueuedPreread } from './preread-worker';
import { processQueuedReportText } from './report-text-worker';
import { sanitize } from './sanitize';
import { closeShare, loadShareClose, mintShareCode } from './shares';
import { bumpModelSignal } from './signals';

const KINDS = ['Initial', 'Addendum', 'Amendment'] as const;
const TEXT_KINDS = ['Translation', 'Explanation'] as const;
type TextKind = (typeof TEXT_KINDS)[number];

const INITIAL_STAGES = new Set<CaseStage>([
  'SampleReceived',
  'SlidesUploaded',
  'PrereadQueued',
  'PrereadReady',
  'PrereadFailed',
  'ReportInProgress',
]);
const REVISION_STAGES = new Set<CaseStage>([
  'ReportSigned',
  'DiscussionRequested',
  'DiscussionBooked',
  'ResultReleased',
  'Completed',
]);
const DISCUSSABLE_STAGES = new Set<CaseStage>(['ReportSigned', 'DiscussionRequested', 'DiscussionBooked']);

const UNLOCK_TTL_MS = 7 * DAY_MS;
const MAX_SIGNATURE_BYTES = 256 * 1024;
const MAX_TEXT_REQUESTS = 3;
const DIAGNOSIS_TYPES = ['Final', 'Provisional', 'Inconclusive'] as const;

function textId(reportUid: string, kind: TextKind, language: string): string {
  return `${reportUid}_${kind}_${language}`;
}

function ownReport(c: Caller, s: CaseState): void {
  if (s.pathologistUid !== c.uid) throw refuse('permission-denied', 'notOnCase');
}

function clean(raw: unknown, max: number, reason: string): string {
  if (raw === undefined || raw === null) return '';
  if (typeof raw !== 'string') throw refuse('invalid-argument', reason);
  try {
    return sanitize(raw, max);
  } catch {
    throw refuse('invalid-argument', reason);
  }
}

// --- Text comparison, in code (S-6) ----------------------------------------------------------

function levenshtein(a: string, b: string): number {
  if (a === b) return 0;
  let previous = Array.from({ length: b.length + 1 }, (_, i) => i);
  for (let i = 1; i <= a.length; i++) {
    const row = [i];
    for (let j = 1; j <= b.length; j++) {
      row.push(
        Math.min(previous[j] + 1, row[j - 1] + 1, previous[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1)),
      );
    }
    previous = row;
  }
  return previous[b.length];
}

function similarity(a: string, b: string): number {
  const longest = Math.max(a.length, b.length);
  return longest === 0 ? 1 : 1 - levenshtein(a, b) / longest;
}

/** Total edit distance over total length, so a long field weighs more than a short one. */
function editRate(pairs: [string, string][]): number {
  const length = pairs.reduce((sum, [a, b]) => sum + Math.max(a.length, b.length), 0);
  if (length === 0) return 0;
  return pairs.reduce((sum, [a, b]) => sum + levenshtein(a, b), 0) / length;
}

function numbersIn(text: string): string[] {
  return (text.match(/\d+(?:[.,]\d+)?/g) ?? []).sort();
}

// --- startReport -----------------------------------------------------------------------------

export async function startReportHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'started' | 'exists'; lastUpdatedAt: string }> {
  const c = requireRole(caller, 'pathologist');
  const raw = input(data);
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const kind = oneOf(raw.kind ?? 'Initial', KINDS, 'invalidKind');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const loaded = await loadCase(tx, db, caseUid);
    ownReport(c, loaded.s);
    let s = loaded.s;
    const ref = loaded.ref;
    const draftRef = ref.collection('reportDrafts').doc(c.uid);
    const draft = (await tx.get(draftRef)).data();
    const currentUid = str(s.fields.currentReportUid);
    const base = currentUid ? (await tx.get(ref.collection('reports').doc(currentUid))).data() : undefined;
    const provenance = currentUid
      ? (await tx.get(ref.collection('reportProvenance').doc(currentUid))).data()
      : undefined;
    const runUid = str(s.fields.prereadRunUid);
    const runRef = runUid ? ref.collection('preread').doc(runUid) : null;
    const run = runRef ? (await tx.get(runRef)).data() : undefined;
    const worklist = await loadWorklist(tx, db, caseUid);
    const language = await languageOf(tx, db, DOCTORS, c.uid);

    if (kind === 'Initial') {
      if (currentUid !== '') throw refuse('failed-precondition', 'alreadySigned');
      if (!s.labAccessionNo) throw refuse('failed-precondition', 'sampleNotReceived');
      if (!INITIAL_STAGES.has(s.currentStage)) throw refuse('failed-precondition', 'caseNotActive');
    } else {
      if (currentUid === '' || !base || !REVISION_STAGES.has(s.currentStage)) {
        throw refuse('failed-precondition', 'caseNotActive');
      }
      if (str(base.pathologistUid) !== c.uid) throw refuse('permission-denied', 'notSigner');
    }

    const target = kind === 'Initial' ? '' : currentUid;
    if (draft && draft.status === 'Editing') {
      if (draft.kind === kind && str(draft.targetReportUid) === target) {
        return { status: 'exists' as const, lastUpdatedAt: str(draft.lastUpdatedAt) };
      }
      throw refuse('failed-precondition', 'draftInProgress');
    }

    if (kind === 'Initial' && s.currentStage === 'PrereadQueued') {
      const status = str(run?.status);
      const requested = Date.parse(str(run?.requestedAt));
      const stale = !run || (['Queued', 'Running'].includes(status) && now.getTime() - requested >= PREREAD_STALE_MS);
      if (!stale) throw refuse('failed-precondition', 'prereadPending');
      if (runRef && run) {
        tx.update(runRef, { status: 'Failed', failureReason: 'Stale', readyAt: at, lastUpdatedAt: at });
      }
      s = transition(s, 'PrereadFailed', { actorUid: '', actorRole: 'System' });
    }

    const copy = (key: string, fallback: unknown): unknown => base?.[key] ?? fallback;
    const templateKey =
      kind === 'Initial'
        ? reportTemplateFor(testsOf(s).map((t) => str(t.testTypeId)))
        : str(base?.templateKey) || 'General';
    tx.set(draftRef, {
      uid: c.uid,
      caseUid,
      pathologistUid: c.uid,
      kind,
      status: 'Editing',
      baseReportUid: currentUid,
      targetReportUid: target,
      // Only a Ready run binds the draft to a scored pre-read; a Failed/Stale run
      // must not block the manual report (rules require a score whenever prereadRunUid is set).
      prereadRunUid: kind === 'Initial' && run?.status === 'Ready' ? runUid : '',
      templateKey,
      title: copy('title', ''),
      diagnosisType: copy('diagnosisType', 'Final'),
      diagnosis: copy('diagnosis', ''),
      comments: copy('comments', ''),
      responses: copy('responses', []),
      labelOverrides: {},
      labelOverrideCount: 0,
      isCritical: copy('isCritical', false),
      addendumText: '',
      amendmentReason: '',
      diagnosisStartedAt: '',
      startedFromPreread: false,
      startedAt: at,
      createdAt: at,
      signedReportUid: '',
      notifiableFindings: copy('notifiableFindings', []),
      hintShownDiseaseIds: strings(provenance?.hintShownDiseaseIds),
      confirmatoryRequests: copy('confirmatoryRequests', []),
      createdByUid: c.uid,
      language,
      lastUpdatedAt: at,
    });

    if (kind === 'Initial') {
      if (s.currentStage !== 'ReportInProgress') {
        s = transition(s, 'ReportInProgress', { actorUid: c.uid, actorRole: 'Pathologist' });
      }
      commitCase(tx, ref, s, now);
      upsertWorklist(tx, worklist, s, { status: 'InProgress' }, now);
    }
    return { status: 'started' as const, lastUpdatedAt: at };
  });
}

// --- discardDraft ----------------------------------------------------------------------------

function stampOf(raw: unknown): string {
  if (typeof raw !== 'string' || raw === '' || raw.length > 64) throw refuse('invalid-argument', 'invalidDraft');
  return raw;
}

export async function discardDraftHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'pathologist');
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const stamp = stampOf(raw.draftLastUpdatedAt);
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    ownReport(c, s);
    const draftRef = ref.collection('reportDrafts').doc(c.uid);
    const draft = (await tx.get(draftRef)).data();
    if (!draft) throw refuse('not-found', 'noDraft');
    if (draft.status === 'Closed') return OK;
    // An Initial report is never discarded: the case is mid-report, and cancelling is the doctor's.
    if (draft.kind === 'Initial') throw refuse('failed-precondition', 'initialDraft');
    if (draft.status !== 'Editing') throw refuse('failed-precondition', 'draftNotEditing');
    if (str(draft.lastUpdatedAt) !== stamp) throw refuse('aborted', 'draftChanged');
    tx.update(draftRef, { status: 'Closed', lastUpdatedAt: timestamp(now) });
    return OK;
  });
}

// --- scorePreread ----------------------------------------------------------------------------

const SCORE_VERDICTS = ['Agree', 'PartlyAgree', 'Disagree'] as const;
const MEASUREMENT_VERDICTS = ['Accepted', 'Corrected', 'NotApplicable'] as const;
const SEGMENTATION_VERDICTS = ['Good', 'Acceptable', 'Poor', 'NotApplicable'] as const;

export async function scorePrereadHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'scored' | 'alreadyScored' }> {
  const c = requireRole(caller, 'pathologist');
  const raw = input(data);
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const runUid = uuidOf(raw.runUid, 'invalidScore');
  const findingsVerdict = oneOf(raw.findingsVerdict, SCORE_VERDICTS, 'invalidScore');
  const impressionVerdict = oneOf(raw.impressionVerdict, SCORE_VERDICTS, 'invalidScore');
  const urgencyVerdict = oneOf(raw.urgencyVerdict, SCORE_VERDICTS, 'invalidScore');
  const measurementsVerdict = oneOf(raw.measurementsVerdict, MEASUREMENT_VERDICTS, 'invalidScore');
  const segmentationVerdict = oneOf(raw.segmentationVerdict, SEGMENTATION_VERDICTS, 'invalidScore');
  const overall = raw.overall;
  if (typeof overall !== 'number' || !Number.isInteger(overall) || overall < 1 || overall > 5) {
    throw refuse('invalid-argument', 'invalidScore');
  }
  const comment = clean(raw.comment, 1000, 'invalidScore');
  const shownAt = typeof raw.prereadShownAt === 'string' ? Date.parse(raw.prereadShownAt) : Number.NaN;
  if (!Number.isFinite(shownAt) || shownAt > now.getTime()) throw refuse('invalid-argument', 'invalidScore');
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    ownReport(c, s);
    const run = (await tx.get(ref.collection('preread').doc(runUid))).data();
    if (!run) throw refuse('not-found', 'invalidScore');
    const scoreRef = ref.collection('prereadScores').doc(runUid);
    if ((await tx.get(scoreRef)).exists) return { status: 'alreadyScored' as const };
    if (run.status !== 'Ready') throw refuse('failed-precondition', 'notReady');

    const draft = (run.draft ?? {}) as DocumentData;
    const acceptedUnchanged =
      findingsVerdict === 'Agree' &&
      impressionVerdict === 'Agree' &&
      urgencyVerdict === 'Agree' &&
      measurementsVerdict !== 'Corrected' &&
      (segmentationVerdict === 'Good' || segmentationVerdict === 'NotApplicable');
    tx.create(scoreRef, {
      uid: runUid,
      caseUid,
      runUid,
      pathologistUid: c.uid,
      profile: str(run.profile) || 'None',
      confidenceBand: str(draft.confidenceBand) || 'Low',
      urgency: str(draft.urgency) || 'Routine',
      overall,
      findingsVerdict,
      impressionVerdict,
      measurementsVerdict,
      segmentationVerdict,
      urgencyVerdict,
      comment,
      prereadShownAt: new Date(shownAt).toISOString(),
      acceptedUnchanged,
      scoredAt: at,
      createdByUid: c.uid,
      lastUpdatedAt: at,
    });
    bumpModelSignal(tx, db, 'prereadScored', now);
    if (acceptedUnchanged) bumpModelSignal(tx, db, 'prereadAcceptedUnchanged', now);
    return { status: 'scored' as const };
  });
}

// --- signReport ------------------------------------------------------------------------------

/** The case's links for [diseaseIds], read before any write: the event write itself only writes. */
async function loadEventLinks(
  tx: Transaction,
  db: Deps['db'],
  caseUid: string,
  diseaseIds: string[],
): Promise<LinkInput[]> {
  const snaps = await Promise.all(
    diseaseIds.map((id) => tx.get(db.collection('notifiableEventLinks').doc(linkUidFor(caseUid, id)))),
  );
  return snaps
    .filter((snap) => snap.exists)
    .map((snap) => ({
      diseaseId: str(snap.get('diseaseId')),
      eventUid: str(snap.get('eventUid')),
      status: str(snap.get('status')),
      alertRequested: snap.get('alertRequested') === true,
      createdAt: str(snap.get('createdAt')),
    }));
}

const PNG_MAGIC = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

function checkedSignature(raw: unknown): Buffer {
  if (typeof raw !== 'string' || raw.length === 0 || raw.length > MAX_SIGNATURE_BYTES * 2) {
    throw refuse('invalid-argument', 'invalidSignature');
  }
  const bytes = Buffer.from(raw, 'base64');
  if (bytes.length < 33 || bytes.length > MAX_SIGNATURE_BYTES) throw refuse('invalid-argument', 'invalidSignature');
  if (!bytes.subarray(0, 8).equals(PNG_MAGIC) || bytes.subarray(12, 16).toString('latin1') !== 'IHDR') {
    throw refuse('invalid-argument', 'invalidSignature');
  }
  const width = bytes.readUInt32BE(16);
  const height = bytes.readUInt32BE(20);
  if (width < 300 || width > 2000 || height < 1 || height > 2000) throw refuse('invalid-argument', 'invalidSignature');
  return bytes;
}

interface Response {
  section: string;
  question: string;
  answer: string;
  order: number;
}

function cleanResponses(raw: unknown): Response[] {
  return records(raw)
    .map((r) => ({
      section: str(r.section),
      question: str(r.question),
      answer: clean(r.answer, 4000, 'invalidText'),
      order: Math.trunc(num(r.order)),
    }))
    .sort((a, b) => a.order - b.order);
}

/** Tile labels the pathologist changed must name a tile and a label the pre-read itself used. */
async function checkedLabels(deps: Deps, run: DocumentData | undefined, overrides: Record<string, unknown>): Promise<Record<string, string>> {
  const entries = Object.entries(overrides);
  if (entries.length === 0) return {};
  const path = str(run?.labelsPath);
  const bytes = path ? await readObject(deps.bucket, path) : null;
  if (!bytes) throw refuse('failed-precondition', 'invalidLabels');
  let parsed: unknown;
  try {
    parsed = JSON.parse(bytes.toString('utf8'));
  } catch {
    throw refuse('failed-precondition', 'invalidLabels');
  }
  const tiles = records(Array.isArray(parsed) ? parsed : (parsed as DocumentData)?.labels);
  const known = new Set(tiles.map((t) => str(t.id)));
  const allowed = new Set(tiles.map((t) => str(t.label)));
  const out: Record<string, string> = {};
  for (const [id, label] of entries) {
    if (typeof label !== 'string' || !known.has(id) || !allowed.has(label)) {
      throw refuse('invalid-argument', 'invalidLabels');
    }
    out[id] = label;
  }
  return out;
}

function measurementList(map: DocumentData | undefined): DocumentData[] {
  return Object.keys(map ?? {})
    .sort()
    .map((key) => ({ key, unit: '', value: num(map?.[key]), precision: 2 }));
}

function stableContent(report: DocumentData): string {
  // Every content field, the lab fields and the signer snapshot, in a fixed order.
  const keys = [
    'caseUid',
    'version',
    'stage',
    'orderNumber',
    'testName',
    'sampleCollectedAt',
    'sampleReceivedAt',
    'labAccessionNo',
    'profile',
    'templateKey',
    'title',
    'diagnosisType',
    'diagnosis',
    'comments',
    'responses',
    'isCritical',
    'measurements',
    'addenda',
    'amendmentReason',
    'notifiableFindings',
    'confirmatoryRequests',
    'signedByTitle',
    'signedByName',
    'signedByKmpdcNumber',
    'signedByFacilityName',
    'signatureSha256',
  ];
  return JSON.stringify(keys.map((k) => report[k] ?? null));
}

const MAX_FINDINGS = 5;

interface Finding {
  diseaseId: string;
  alertRequested: boolean;
}

/** Fixed keys only: whatever else a client wrote into a finding is dropped, not signed. */
function canonicalFindings(raw: unknown): Finding[] {
  return records(raw)
    .map((f) => ({ diseaseId: str(f.diseaseId), alertRequested: f.alertRequested === true }))
    .sort((a, b) => a.diseaseId.localeCompare(b.diseaseId));
}

function sameList(a: unknown, b: unknown): boolean {
  return JSON.stringify(a) === JSON.stringify(b);
}

/**
 * A finding is a positive the case's own tests confirm: a bundle disease that is listed, with a
 * `Confirms` test among the case's tests (plan §1.4). An alert may only be requested where the
 * bundle allows one.
 */
function checkedFindings(raw: unknown, caseTestIds: string[]): Finding[] {
  if (!Array.isArray(raw) || raw.length > MAX_FINDINGS) throw refuse('invalid-argument', 'invalidNotifiable');
  const findings = canonicalFindings(raw);
  if (findings.length !== raw.length || new Set(findings.map((f) => f.diseaseId)).size !== findings.length) {
    throw refuse('invalid-argument', 'invalidNotifiable');
  }
  for (const finding of findings) {
    const disease = diseaseById(finding.diseaseId);
    const confirmed = disease?.labTests.some((t) => t.strength === 'Confirms' && caseTestIds.includes(t.labTestId));
    if (!disease || disease.reportingCategory === 'NotListed' || !confirmed) {
      throw refuse('invalid-argument', 'invalidNotifiable');
    }
    if (finding.alertRequested) {
      const allowed = disease.publicAlertEligible && (disease.reportingCategory !== 'Weekly' || disease.allowManualAlert);
      if (!allowed) throw refuse('invalid-argument', 'invalidNotifiable');
    }
  }
  return findings;
}

/** A confirmatory request is for a disease the case only presumes: a `Presumptive` test and no `Confirms` one. */
function checkedConfirmatory(raw: unknown, caseTestIds: string[]): string[] {
  if (!Array.isArray(raw) || raw.length > MAX_FINDINGS || raw.some((x) => typeof x !== 'string')) {
    throw refuse('invalid-argument', 'invalidConfirmatory');
  }
  const ids = raw as string[];
  if (new Set(ids).size !== ids.length) throw refuse('invalid-argument', 'invalidConfirmatory');
  for (const id of ids) {
    const disease = diseaseById(id);
    const has = (strength: string): boolean =>
      disease?.labTests.some((t) => t.strength === strength && caseTestIds.includes(t.labTestId)) === true;
    if (!disease || disease.reportingCategory === 'NotListed' || !has('Presumptive') || has('Confirms')) {
      throw refuse('invalid-argument', 'invalidConfirmatory');
    }
  }
  return ids;
}

// --- Measurement preview (S-2, S-6) ---------------------------------------------------------

/** What the pathologist saw: the same run and the same relabelled tiles, in a fixed order. */
function measurementInputHash(runUid: string, overrides: Record<string, string>): string {
  return sha256(JSON.stringify({ runUid, labels: Object.entries(overrides).sort(([a], [b]) => a.localeCompare(b)) }));
}

function numberMap(raw: unknown): Record<string, number> {
  const out: Record<string, number> = {};
  for (const [key, value] of Object.entries((raw ?? {}) as Record<string, unknown>)) out[key] = num(value);
  return out;
}

/** Signing signs only the numbers the draft already showed: same inputs, same result. */
function assertPreviewMatches(draft: DocumentData, inputHash: string, computed: Record<string, number>): void {
  const preview = (draft.measurementsPreview ?? {}) as DocumentData;
  const shown = preview.status === 'Ready' && preview.inputHash === inputHash;
  if (!shown || !sameList(Object.entries(numberMap(preview.measurements)).sort(), Object.entries(computed).sort())) {
    throw refuse('failed-precondition', 'measurementsChanged');
  }
}

function draftInputHash(draft: DocumentData): string {
  const overrides = Object.entries((draft.labelOverrides ?? {}) as Record<string, unknown>).filter(
    ([, v]) => typeof v === 'string',
  );
  return measurementInputHash(str(draft.prereadRunUid), Object.fromEntries(overrides) as Record<string, string>);
}

/** The preview a draft trigger writes, or null when the draft needs none (or already has it). */
async function measurementPreview(deps: Deps, draft: DocumentData): Promise<DocumentData | null> {
  const overrides = (draft.labelOverrides ?? {}) as Record<string, unknown>;
  if (Object.keys(overrides).length === 0) return null;
  const runUid = str(draft.prereadRunUid);
  const inputHash = draftInputHash(draft);
  const prior = (draft.measurementsPreview ?? {}) as DocumentData;
  if (prior.inputHash === inputHash) return null;
  const at = timestamp(nowOf(deps));
  const failed = (failureReason: string): DocumentData => ({
    status: 'Failed',
    inputHash,
    measurements: {},
    failureReason,
    computedAt: at,
  });
  const run = runUid
    ? (await deps.db.collection('cases').doc(str(draft.caseUid)).collection('preread').doc(runUid).get()).data()
    : undefined;
  let checked: Record<string, string>;
  try {
    checked = await checkedLabels(deps, run, overrides);
  } catch {
    return failed('invalidLabels');
  }
  if (!deps.ai?.measure) return failed('ServiceError');
  try {
    const { measurements } = await withTimeout(deps.ai.measure({ runUid, labelOverrides: checked }), deps.aiTimeoutMs);
    return { status: 'Ready', inputHash, measurements: numberMap(measurements), failureReason: '', computedAt: at };
  } catch {
    return failed('ServiceError');
  }
}

export async function signReportHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'signed' | 'exists'; reportUid: string; version: number }> {
  const c = requireRole(caller, 'pathologist');
  const raw = input(data);
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const stamp = stampOf(raw.draftLastUpdatedAt);
  const { db } = deps;
  const caseRef = db.collection('cases').doc(caseUid);
  const draftRef = caseRef.collection('reportDrafts').doc(c.uid);

  // A replay returns before any upload or check (F-7).
  const earlier = (await draftRef.get()).data();
  if (earlier?.status === 'Signed' && str(earlier.signedReportUid) !== '') {
    const reportUid = str(earlier.signedReportUid);
    return { status: 'exists', reportUid, version: Number(reportUid.slice(1)) };
  }
  if (!deps.shareCodeKey) throw refuse('failed-precondition', 'shareKeyMissing');
  const key = deps.shareCodeKey;

  const caseSnap = await caseRef.get();
  if (!caseSnap.exists) throw refuse('not-found', 'invalidCase');
  const planned = CaseState.from(caseSnap);
  ownReport(c, planned);
  const signer = (await db.collection(DOCTORS).doc(c.uid).get()).data();
  if (!signer || signer.verificationStatus !== 'Verified') throw refuse('permission-denied', 'notVerified');
  if (!earlier || earlier.status !== 'Editing') throw refuse('failed-precondition', 'draftNotEditing');
  if (str(earlier.lastUpdatedAt) !== stamp) throw refuse('aborted', 'draftChanged');

  const kind = oneOf(earlier.kind, KINDS, 'draftNotEditing');
  if (kind === 'Initial' ? planned.currentStage !== 'ReportInProgress' : !REVISION_STAGES.has(planned.currentStage)) {
    throw refuse('failed-precondition', 'caseNotActive');
  }
  const runUid = str(earlier.prereadRunUid);
  const run = runUid ? (await caseRef.collection('preread').doc(runUid).get()).data() : undefined;
  if (kind === 'Initial' && run?.status === 'Ready' && !(await caseRef.collection('prereadScores').doc(runUid).get()).exists) {
    throw refuse('failed-precondition', 'prereadNotScored');
  }

  const diagnosisType = oneOf(earlier.diagnosisType ?? 'Final', DIAGNOSIS_TYPES, 'incomplete');
  const title = clean(earlier.title, 200, 'invalidText');
  const diagnosis = clean(earlier.diagnosis, 4000, 'invalidText');
  const comments = clean(earlier.comments, 4000, 'invalidText');
  const addendumText = clean(earlier.addendumText, 4000, 'invalidText');
  const amendmentReason = clean(earlier.amendmentReason, 1000, 'invalidText');
  const responses = cleanResponses(earlier.responses);
  const templateKey = str(earlier.templateKey) || 'General';
  if (kind !== 'Addendum') {
    const answered = new Set(responses.filter((r) => r.answer.trim() !== '').map((r) => r.question));
    if (diagnosis === '' || requiredQuestions(templateKey).some((q) => !answered.has(q))) {
      throw refuse('failed-precondition', 'incomplete');
    }
  }
  if ((kind === 'Addendum' && addendumText === '') || (kind === 'Amendment' && amendmentReason === '')) {
    throw refuse('failed-precondition', 'reasonRequired');
  }
  const caseTestIds = testsOf(planned).map((t) => str(t.labTestId));
  // Checked before anything is uploaded or written. An Addendum carries its base's findings, so
  // it is compared against them in the transaction instead.
  const findings = kind === 'Addendum' ? [] : checkedFindings(earlier.notifiableFindings ?? [], caseTestIds);
  const confirmatory = kind === 'Addendum' ? [] : checkedConfirmatory(earlier.confirmatoryRequests ?? [], caseTestIds);
  if (findings.length > 0) {
    // The event needs the patient's county and an age band; refuse here, before the upload.
    const patient = (await db.collection(PATIENTS).doc(str(planned.fields.patientId)).get()).data();
    validateFindings({
      caseUid,
      reportUid: '',
      kind,
      signedAt: timestamp(now),
      pathologistUid: c.uid,
      countyName: str(patient?.county),
      ageYears: num(planned.fields.patientAgeYears),
      caseLabTestIds: caseTestIds,
      findings,
      previousFindings: [],
      links: [],
      synthetic: deps.synthetic === true,
      now,
    });
  }
  const png = checkedSignature(raw.signaturePng);
  const overrides = await checkedLabels(deps, run, (earlier.labelOverrides ?? {}) as Record<string, unknown>);
  let measurements: DocumentData | undefined = run?.measurements as DocumentData | undefined;
  const inputHash = measurementInputHash(runUid, overrides);
  if (Object.keys(overrides).length > 0) {
    // Counts follow the labels, so the service recomputes them. They are signed only if they
    // equal the preview the pathologist saw on the draft (S-2); the check repeats in the Tx.
    if (!deps.ai?.measure) throw refuse('failed-precondition', 'measurementFailed');
    try {
      measurements = numberMap(
        (await withTimeout(deps.ai.measure({ runUid, labelOverrides: overrides }), deps.aiTimeoutMs)).measurements,
      );
    } catch {
      throw refuse('failed-precondition', 'measurementFailed');
    }
    assertPreviewMatches(earlier, inputHash, measurements as Record<string, number>);
  }

  const existingReports = (await caseRef.collection('reports').get()).docs;
  const version = existingReports.reduce((max, d) => Math.max(max, num(d.get('version'))), 0) + 1;
  const reportUid = `v${version}`;
  const signatureSha256 = sha256(png);
  const signaturePath = `reports/${caseUid}/${reportUid}/signature-${signatureSha256}.png`;
  // Content-addressed: a failed transaction leaves an unreferenced object, and a retry reuses it.
  await saveObject(deps.bucket, signaturePath, png, 'image/png');

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    ownReport(c, s);
    const draftSnap = (await tx.get(draftRef)).data();
    if (draftSnap?.status === 'Signed' && str(draftSnap.signedReportUid) !== '') {
      const done = str(draftSnap.signedReportUid);
      return { status: 'exists' as const, reportUid: done, version: Number(done.slice(1)) };
    }
    if (!draftSnap || draftSnap.status !== 'Editing') throw refuse('failed-precondition', 'draftNotEditing');
    if (str(draftSnap.lastUpdatedAt) !== stamp) throw refuse('aborted', 'draftChanged');
    if (Object.keys(overrides).length > 0) {
      assertPreviewMatches(draftSnap, inputHash, measurements as Record<string, number>);
    }
    if (kind === 'Initial' ? s.currentStage !== 'ReportInProgress' : !REVISION_STAGES.has(s.currentStage)) {
      throw refuse('failed-precondition', 'caseNotActive');
    }

    const versions = await loadVersions(tx, ref);
    const latest = versions.at(-1);
    if ((latest?.version ?? 0) + 1 !== version) throw refuse('aborted', 'draftChanged');
    if (kind === 'Addendum') {
      if (!sameList(canonicalFindings(draftSnap.notifiableFindings), canonicalFindings(latest?.data.notifiableFindings))) {
        throw refuse('invalid-argument', 'invalidNotifiable');
      }
      if (!sameList([...strings(draftSnap.confirmatoryRequests)].sort(), [...strings(latest?.data.confirmatoryRequests)].sort())) {
        throw refuse('invalid-argument', 'invalidConfirmatory');
      }
    }
    const previousShare = latest ? await loadShareClose(tx, db, `unlock_${caseUid}_${latest.uid}`) : null;
    const signerDoc = (await tx.get(db.collection(DOCTORS).doc(c.uid))).data();
    if (!signerDoc || signerDoc.verificationStatus !== 'Verified') throw refuse('permission-denied', 'notVerified');
    const runDoc = runUid ? (await tx.get(ref.collection('preread').doc(runUid))).data() : undefined;
    const scoreDoc = runUid ? (await tx.get(ref.collection('prereadScores').doc(runUid))).data() : undefined;
    const worklist = await loadWorklist(tx, db, caseUid);
    const unlockUid = `unlock_${caseUid}_${reportUid}`;
    const priorUnlock = await tx.get(db.collection('shareCodes').doc(unlockUid));
    const doctorLanguage = await languageOf(tx, db, DOCTORS, s.doctorUid);
    const patientDoc = (await tx.get(db.collection(PATIENTS).doc(str(s.fields.patientId)))).data();
    const patientLanguage = languageIn(patientDoc);
    const previousFindings = canonicalFindings(latest?.data.notifiableFindings);
    const signedFindings = kind === 'Addendum' ? previousFindings : findings;
    const notifiableIds = [...new Set([...signedFindings, ...previousFindings].map((f) => f.diseaseId))];
    const eventLinks = await loadEventLinks(tx, db, caseUid, notifiableIds);
    const template = version === 1 ? 'reportSigned' : 'reportUpdated';
    const unlockNote = await NotificationTx.load(tx, db, template, `${caseUid}_${reportUid}`, s.doctorUid);
    const releasedBefore = s.fields.releasedToPatient === true;

    const revised = REVISION_STAGES.has(s.currentStage);
    const next = (
      kind === 'Initial'
        ? transition(s, 'ReportSigned', { actorUid: c.uid, actorRole: 'Pathologist' })
        : ['ResultReleased', 'Completed'].includes(s.currentStage)
          ? transition(s, 'ReportSigned', { actorUid: c.uid, actorRole: 'Pathologist', action: 'Revise' })
          : transition(s, s.currentStage, { actorUid: c.uid, actorRole: 'Pathologist', action: 'Revise' })
    ).with({
      currentReportUid: reportUid,
      resultState: revised && releasedBefore ? 'UpdateWithDoctor' : 'WithDoctor',
    });
    const resultKey = `${caseUid}-r${next.stageSeq}`;
    const notes = await planNotes(tx, db, [
      version === 1 || releasedBefore
        ? {
            template: version === 1 ? 'resultsWithDoctor' : 'resultUpdateWithDoctor',
            resourceKey: resultKey,
            caseUid,
            recipientUid: s.patientUid,
            recipientRole: 'patient',
            language: patientLanguage,
            deepLink: `/cases/${caseUid}/book-discussion`,
          }
        : null,
    ]);

    // Addenda and amendments keep the signed text they extend; only an Initial or Amendment edits it.
    const base = kind === 'Addendum' && latest ? latest.data : null;
    const addenda = records(base?.addenda ?? latest?.data.addenda);
    const report: DocumentData = {
      uid: reportUid,
      caseUid,
      version,
      stage: kind,
      status: 'Signed',
      orderNumber: str(s.fields.orderNumber),
      testName: testsOf(s).map((t) => str(t.name)).join(', '),
      sampleCollectedAt: str(s.fields.sampleCollectedAt),
      sampleReceivedAt: str(s.fields.sampleReceivedAt),
      labAccessionNo: s.labAccessionNo,
      profile: prereadProfileOf(testsOf(s).map((t) => str(t.labTestId))),
      templateKey: base ? str(base.templateKey) : templateKey,
      title: base ? str(base.title) : title,
      diagnosisType: base ? str(base.diagnosisType) : diagnosisType,
      diagnosis: base ? str(base.diagnosis) : diagnosis,
      comments: base ? str(base.comments) : comments,
      responses: base ? records(base.responses) : responses,
      isCritical: base ? base.isCritical === true : earlier.isCritical === true,
      measurements: kind === 'Initial' || kind === 'Amendment' ? measurementList(measurements) : records(latest?.data.measurements),
      addenda:
        kind === 'Addendum'
          ? [
              ...addenda,
              {
                uid: newUid(),
                text: addendumText,
                reportVersion: version,
                signedByUid: c.uid,
                signedByName: displayName(signerDoc),
                signedAt: at,
              },
            ]
          : addenda,
      amendmentReason: kind === 'Amendment' ? amendmentReason : '',
      prereadRunUid: runDoc ? runUid : '',
      doctorUid: s.doctorUid,
      pathologistUid: c.uid,
      readerUids: [c.uid],
      signedByTitle: str(signerDoc?.title),
      signedByName: [signerDoc?.firstName, signerDoc?.lastName].filter((p) => typeof p === 'string' && p !== '').join(' '),
      signedByKmpdcNumber: str(signerDoc?.kmpdcNumber),
      signedByFacilityName: str(signerDoc?.facilityName),
      signaturePath,
      signatureSha256,
      contentSha256: '',
      startedAt: str(draftSnap.startedAt),
      scoredAt: str(scoreDoc?.scoredAt),
      signedAt: at,
      doctorOpenedAt: '',
      releasedToPatient: false,
      releasedAt: '',
      releasedByUid: '',
      supersededAt: '',
      supersededByUid: '',
      notifiableFindings: kind === 'Addendum' ? records(latest?.data.notifiableFindings) : findings,
      confirmatoryRequests: kind === 'Addendum' ? strings(latest?.data.confirmatoryRequests) : confirmatory,
      createdByUid: c.uid,
      language: str(draftSnap.language) === 'sw' ? 'sw' : 'en',
      lastUpdatedAt: at,
    };
    report.contentSha256 = sha256(stableContent(report));

    // The pre-read's draft against what was signed; for a revision, the version it revised.
    const aiDraft = (runDoc?.draft ?? {}) as DocumentData;
    const aiPairs: Record<string, string> =
      kind === 'Initial' && runDoc?.status === 'Ready'
        ? {
            diagnosis: str(aiDraft.impression),
            comments: records(aiDraft.findings).map((f) => str(f.text)).join('\n'),
          }
        : kind === 'Amendment' && latest
          ? { diagnosis: str(latest.data.diagnosis), comments: str(latest.data.comments) }
          : {};
    const finalValues: Record<string, string> = { diagnosis: str(report.diagnosis), comments: str(report.comments) };
    const fields = Object.keys(aiPairs);
    const rate = editRate(fields.map((f) => [aiPairs[f], finalValues[f]]));
    const hasDiff = fields.length > 0;

    tx.create(ref.collection('reports').doc(reportUid), report);
    tx.create(ref.collection('reportProvenance').doc(reportUid), {
      uid: reportUid,
      caseUid,
      reportUid,
      pathologistUid: c.uid,
      prereadRunUid: report.prereadRunUid,
      diffBase: kind === 'Initial' ? (hasDiff ? 'PrereadDraft' : 'None') : kind === 'Amendment' ? 'BaseVersion' : 'None',
      aiDraft: kind === 'Initial' && runDoc?.status === 'Ready' ? aiDraft : {},
      aiModels: kind === 'Initial' ? (runDoc?.models ?? {}) : {},
      aiMeasurements: kind === 'Initial' ? measurementList(runDoc?.measurements as DocumentData | undefined) : [],
      finalMeasurements: report.measurements,
      labelOverrideCount: Object.keys(overrides).length,
      diff: fields.map((f) => ({
        field: f,
        change: aiPairs[f] === finalValues[f] ? 'Unchanged' : aiPairs[f] === '' ? 'Added' : finalValues[f] === '' ? 'Removed' : 'Edited',
        baseValue: aiPairs[f],
        finalValue: finalValues[f],
        similarity: similarity(aiPairs[f], finalValues[f]),
      })),
      editRate: rate,
      acceptedUnchanged: hasDiff && rate === 0,
      hintShownDiseaseIds: [...new Set(strings(draftSnap.hintShownDiseaseIds))]
        .filter((id) => diseaseById(id) !== undefined)
        .slice(0, MAX_FINDINGS),
      createdAt: at,
      lastUpdatedAt: at,
    });
    if (latest) {
      tx.update(latest.access.ref, {
        status: 'Superseded',
        supersededAt: at,
        supersededByUid: reportUid,
        lastUpdatedAt: at,
      });
    }
    // The previous version's code is moot: the new version carries its own (F-23).
    if (previousShare?.share?.status === 'Pending') closeShare(tx, db, previousShare, 'Revoked', now);
    tx.update(draftRef, { status: 'Signed', signedReportUid: reportUid, lastUpdatedAt: at });
    commitCase(tx, ref, next, now);
    upsertWorklist(tx, worklist, next, { status: 'Signed' }, now);
    mintShareCode(
      tx,
      db,
      {
        shareUid: unlockUid,
        caseUid,
        reportUid,
        purpose: 'ReportUnlock',
        createdByUid: c.uid,
        createdByRole: 'pathologist',
        recipientUid: s.doctorUid,
        expiresAt: timestamp(new Date(now.getTime() + UNLOCK_TTL_MS)),
        template,
        resourceKey: `${caseUid}_${reportUid}`,
        language: doctorLanguage,
        deepLink: `/cases/${caseUid}/reports/${reportUid}`,
        critical: report.isCritical === true,
      },
      unlockNote,
      key,
      now,
      priorUnlock,
      deps.generateShareCode,
    );
    sendNotes(tx, notes, now);
    if (notifiableIds.length > 0) {
      writeNotifiableEvents(tx, db, {
        caseUid,
        reportUid,
        kind,
        // Server clock, never the client draft stamp: a skewed device must not move the epi-week.
        signedAt: at,
        pathologistUid: c.uid,
        countyName: str(patientDoc?.county),
        ageYears: num(s.fields.patientAgeYears),
        caseLabTestIds: testsOf(s).map((t) => str(t.labTestId)),
        findings: signedFindings,
        previousFindings,
        links: eventLinks,
        synthetic: deps.synthetic === true,
        now,
      });
    }
    return { status: 'signed' as const, reportUid, version };
  });
}

// --- markDiscussed ---------------------------------------------------------------------------

export async function markDiscussedHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireRole(caller, 'doctor');
  const raw = input(data);
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const reportUid = typeof raw.reportUid === 'string' && /^v\d{1,4}$/.test(raw.reportUid) ? raw.reportUid : '';
  if (reportUid === '') throw refuse('invalid-argument', 'invalidReport');
  const { db } = deps;
  const explanations = isEnabled(deps.config, 'patient_explanations_enabled');

  return db.runTransaction(async (tx) => {
    const { ref, s } = await loadCase(tx, db, caseUid);
    if (s.doctorUid !== c.uid) throw refuse('permission-denied', 'notOrderingDoctor');
    const versions = await loadVersions(tx, ref);
    const version = versions.find((v) => v.uid === reportUid);
    if (!version) throw refuse('not-found', 'notCurrent');
    if (version.access.releasedToPatient) return OK;
    if (str(s.fields.currentReportUid) !== reportUid) throw refuse('failed-precondition', 'notCurrent');
    if (!version.access.readerUids.includes(c.uid)) throw refuse('failed-precondition', 'notUnlocked');
    if (!DISCUSSABLE_STAGES.has(s.currentStage)) throw refuse('failed-precondition', 'invalidStage');

    const languages = ['en', 'sw'] as const;
    const existing = explanations
      ? await Promise.all(languages.map((l) => tx.get(ref.collection('reportTexts').doc(textId(reportUid, 'Explanation', l)))))
      : [];
    const patientLanguage = languageIn((await tx.get(db.collection(PATIENTS).doc(str(s.fields.patientId)))).data());
    const next = transition(
      s.with({
        releasedToPatient: true,
        discussedAt: at,
        releasedAt: str(s.fields.releasedAt) || at,
        resultState: 'Released',
        discussionAppointmentUid: '',
      }),
      'ResultReleased',
      { actorUid: c.uid, actorRole: 'Doctor' },
    );
    const notes = await planNotes(tx, db, [
      {
        template: 'resultReleased',
        resourceKey: `${caseUid}_${reportUid}`,
        caseUid,
        recipientUid: s.patientUid,
        recipientRole: 'patient',
        language: patientLanguage,
        resourceUid: reportUid,
        deepLink: `/cases/${caseUid}/reports/${reportUid}`,
      },
    ]);

    tx.update(version.access.ref, {
      releasedToPatient: true,
      releasedAt: at,
      releasedByUid: c.uid,
      lastUpdatedAt: at,
    });
    commitCase(tx, ref, next, now);
    syncCaseReaders(
      tx,
      next,
      versions.map((v) => (v.uid === reportUid ? { ...v.access, releasedToPatient: true } : v.access)),
      now,
    );
    languages.forEach((language, i) => {
      if (!explanations || existing[i].exists) return;
      const id = textId(reportUid, 'Explanation', language);
      tx.create(ref.collection('reportTexts').doc(id), newText({
        id,
        caseUid,
        reportUid,
        reportVersion: version.version,
        kind: 'Explanation',
        language,
        sourceLanguage: str(version.data.language) === 'sw' ? 'sw' : 'en',
        sourceSha256: str(version.data.contentSha256),
        approverUid: s.doctorUid,
        at,
      }));
    });
    sendNotes(tx, notes, now);
    return OK;
  });
}

function newText(f: {
  id: string;
  caseUid: string;
  reportUid: string;
  reportVersion: number;
  kind: TextKind;
  language: 'en' | 'sw';
  sourceLanguage: 'en' | 'sw';
  sourceSha256: string;
  approverUid: string;
  at: string;
}): DocumentData {
  return {
    uid: f.id,
    caseUid: f.caseUid,
    reportUid: f.reportUid,
    reportVersion: f.reportVersion,
    kind: f.kind,
    language: f.language,
    sourceLanguage: f.sourceLanguage,
    detectedSourceLanguage: '',
    languageMismatch: false,
    sourceSha256: f.sourceSha256,
    status: 'Queued',
    machineText: {},
    models: {},
    approverUid: f.approverUid,
    requestCount: 0,
    acceptedUnchanged: false,
    editedSegmentKeys: [],
    editDistance: 0,
    failureReason: '',
    requestedAt: f.at,
    readyAt: '',
    approvedAt: '',
    lastUpdatedAt: f.at,
  };
}

// --- Report texts ----------------------------------------------------------------------------

function textRef(deps: Deps, caseUid: string, id: string): DocumentReference {
  return deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(id);
}

function textIdOf(raw: unknown): string {
  if (typeof raw !== 'string' || !/^v\d{1,4}_(Translation|Explanation)_(en|sw)$/.test(raw)) {
    throw refuse('invalid-argument', 'invalidText');
  }
  return raw;
}

/** An explanation is the ordering doctor's to approve, a translation the signing pathologist's. */
function textApprover(caller: Caller | null, kind: string): Caller {
  const c = requireRoleIn(caller, ['doctor', 'pathologist']);
  if (c.role !== (kind === 'Explanation' ? 'doctor' : 'pathologist')) {
    throw refuse('permission-denied', 'roleNotAllowed');
  }
  return c;
}

/** A claim can outlive de-verification by up to an hour, so the profile is read in the transaction. */
async function requireVerified(tx: Transaction, deps: Deps, uid: string): Promise<DocumentData> {
  const profile = (await tx.get(deps.db.collection(DOCTORS).doc(uid))).data();
  if (!profile || profile.verificationStatus !== 'Verified') throw refuse('permission-denied', 'notVerified');
  return profile;
}

export async function approveReportTextHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const raw = input(data);
  const now = nowOf(deps);
  const at = timestamp(now);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const id = textIdOf(raw.textUid);
  const c = textApprover(caller, id.split('_')[1]);
  const decision = oneOf(raw.decision, ['Approve', 'ApproveEdited', 'Reject'] as const, 'invalidDecision');
  const { db } = deps;
  const ref = textRef(deps, caseUid, id);

  return db.runTransaction(async (tx) => {
    const text = (await tx.get(ref)).data();
    if (!text) throw refuse('not-found', 'invalidText');
    if (text.approverUid !== c.uid) throw refuse('permission-denied', 'notApprover');
    const approver = await requireVerified(tx, deps, c.uid);
    const currentReportUid = str((await tx.get(db.collection('cases').doc(caseUid))).get('currentReportUid'));
    if (text.status === 'Approved' || text.status === 'Rejected') return OK;
    if (text.status !== 'Ready') throw refuse('failed-precondition', 'notReady');
    // The patient still reads a released older version, so an explanation of it must not be approved.
    if (text.kind === 'Explanation' && str(text.reportUid) !== currentReportUid) {
      throw refuse('failed-precondition', 'notCurrent');
    }
    const approvedRef = ref.parent.parent?.collection('reportTextsApproved').doc(id);
    if (!approvedRef) throw refuse('internal', 'invalidText');

    if (decision === 'Reject') {
      tx.update(ref, { status: 'Rejected', lastUpdatedAt: at });
      return OK;
    }
    const machine = (text.machineText ?? {}) as Record<string, string>;
    let approved: Record<string, string> = { ...machine };
    let edited: string[] = [];
    let distance = 0;
    if (decision === 'ApproveEdited') {
      const given = input(raw.approvedText);
      const keys = Object.keys(machine);
      if (Object.keys(given).length !== keys.length || keys.some((k) => typeof given[k] !== 'string')) {
        throw refuse('invalid-argument', 'invalidSegments');
      }
      approved = {};
      for (const k of keys) {
        const segment = clean(given[k], 8000, 'invalidSegments');
        if (segment === '') throw refuse('invalid-argument', 'invalidSegments');
        if (numbersIn(segment).join('|') !== numbersIn(machine[k]).join('|')) {
          throw refuse('failed-precondition', 'numbersChanged');
        }
        approved[k] = segment;
      }
      edited = keys.filter((k) => approved[k] !== machine[k]);
      distance = editRate(keys.map((k) => [machine[k], approved[k]]));
    }
    const unchanged = decision === 'Approve' || edited.length === 0;
    tx.create(approvedRef, {
      uid: id,
      caseUid,
      reportUid: str(text.reportUid),
      reportVersion: num(text.reportVersion),
      kind: str(text.kind),
      language: str(text.language),
      sourceLanguage: str(text.sourceLanguage),
      sourceSha256: str(text.sourceSha256),
      approvedText: approved,
      approverUid: c.uid,
      approverName: displayName(approver),
      approvedAt: at,
      acceptedUnchanged: unchanged,
      lastUpdatedAt: at,
    });
    tx.update(ref, {
      status: 'Approved',
      approvedAt: at,
      acceptedUnchanged: unchanged,
      editedSegmentKeys: edited,
      editDistance: distance,
      lastUpdatedAt: at,
    });
    if (unchanged) {
      bumpModelSignal(tx, db, text.kind === 'Explanation' ? 'explanationAcceptedUnchanged' : 'translationAcceptedUnchanged', now);
    }
    return OK;
  });
}

export async function requestReportTextHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const raw = input(data);
  const now = nowOf(deps);
  const caseUid = uuidOf(raw.caseUid, 'invalidCase');
  const reportUid = typeof raw.reportUid === 'string' && /^v\d{1,4}$/.test(raw.reportUid) ? raw.reportUid : '';
  if (reportUid === '') throw refuse('invalid-argument', 'invalidReport');
  const kind = oneOf(raw.kind, TEXT_KINDS, 'invalidText');
  const c = textApprover(caller, kind);
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    await requireVerified(tx, deps, c.uid);
    const reportSnap = (await tx.get(db.collection('cases').doc(caseUid).collection('reports').doc(reportUid))).data();
    if (!reportSnap) throw refuse('not-found', 'invalidReport');
    const sourceLanguage = str(reportSnap.language) === 'sw' ? 'sw' : 'en';
    // `language` is not in the plan's input list. An Explanation has two rows (en and sw), so the
    // caller names the one to retry; a Translation has one, so it may be left out.
    const language = raw.language === undefined && kind === 'Translation'
      ? otherLanguage(sourceLanguage)
      : oneOf(raw.language, ['en', 'sw'] as const, 'invalidText');
    const ref = textRef(deps, caseUid, textId(reportUid, kind, language));
    const text = (await tx.get(ref)).data();
    if (!text) throw refuse('not-found', 'invalidText');
    if (text.approverUid !== c.uid) throw refuse('permission-denied', 'notApprover');
    if (text.status === 'Queued' || text.status === 'Running') return OK;
    if (text.status !== 'Failed' && text.status !== 'Rejected') throw refuse('failed-precondition', 'notRetryable');
    if (num(text.requestCount) >= MAX_TEXT_REQUESTS) throw refuse('resource-exhausted', 'requestLimit');
    const at = timestamp(now);
    tx.update(ref, {
      status: 'Queued',
      requestCount: num(text.requestCount) + 1,
      machineText: {},
      failureReason: '',
      requestedAt: at,
      readyAt: '',
      lastUpdatedAt: at,
    });
    return OK;
  });
}

// --- Triggers --------------------------------------------------------------------------------

/**
 * `Ready` and `Failed` move the case only for the current run while it is `PrereadQueued`; a
 * redelivery finds the stage moved on and does nothing. A `Queued` run belongs to the AI service.
 */
export async function onPrereadWrittenHandler(deps: Deps, caseUid: string, runUid: string): Promise<void> {
  const { db } = deps;
  const now = nowOf(deps);

  // Live worker (bundle 57): process a Queued run to Ready/Failed, then the stage move below.
  const before = (
    await db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
  ).data();
  if (before && str(before.status) === 'Queued') {
    await processQueuedPreread(deps, caseUid, runUid);
  }

  await db.runTransaction(async (tx) => {
    const caseSnap = await tx.get(db.collection('cases').doc(caseUid));
    if (!caseSnap.exists) return;
    const s = CaseState.from(caseSnap);
    const run = (await tx.get(caseSnap.ref.collection('preread').doc(runUid))).data();
    if (!run || (run.status !== 'Ready' && run.status !== 'Failed')) return;
    const worklist = await loadWorklist(tx, db, caseUid);
    const language = await languageOf(tx, db, DOCTORS, s.pathologistUid);
    const current = str(s.fields.prereadRunUid) === runUid;
    const moving = current && s.currentStage === 'PrereadQueued';
    const ready = run.status === 'Ready';
    const next = moving
      ? transition(s, ready ? 'PrereadReady' : 'PrereadFailed', { actorUid: '', actorRole: 'System' })
      : s;
    const notes = await planNotes(tx, db, [
      moving
        ? {
            template: ready ? 'prereadReady' : 'prereadFailed',
            resourceKey: `${caseUid}-r${next.stageSeq}`,
            caseUid,
            recipientUid: s.pathologistUid,
            recipientRole: 'pathologist',
            language,
          }
        : null,
    ]);

    if (moving) {
      commitCase(tx, caseSnap.ref, next, now);
      bumpModelSignal(tx, db, ready ? 'prereadReadyCount' : 'prereadFailedCount', now);
      sendNotes(tx, notes, now);
    }
    if (current) {
      const draft = (run.draft ?? {}) as DocumentData;
      upsertWorklist(
        tx,
        worklist,
        next,
        ready
          ? {
              prereadStatus: 'Ready',
              urgency: str(draft.urgency),
              confidenceBand: str(draft.confidenceBand) || 'Low',
              confidence: num(draft.confidence),
            }
          : { prereadStatus: 'Failed' },
        now,
      );
    }
  });
}

export async function onReportCreatedHandler(deps: Deps, caseUid: string, reportUid: string): Promise<void> {
  const { db } = deps;
  const now = nowOf(deps);
  const at = timestamp(now);
  const translate = isEnabled(deps.config, 'report_translation_enabled');

  await db.runTransaction(async (tx) => {
    const caseRef = db.collection('cases').doc(caseUid);
    const report = (await tx.get(caseRef.collection('reports').doc(reportUid))).data();
    if (!report) return;
    const caseDoc = (await tx.get(caseRef)).data();
    const resourceUid = `${caseUid}_${reportUid}`;
    const first = num(report.version) === 1;
    const marks = first
      ? await loadMarks(tx, db, [
          { counter: 'reportsSigned', resourceUid },
          { counter: 'casesReported', resourceUid },
        ])
      : [];
    const source = str(report.language) === 'sw' ? 'sw' : 'en';
    const target = otherLanguage(source);
    const id = textId(reportUid, 'Translation', target);
    const existing = translate ? await tx.get(caseRef.collection('reportTexts').doc(id)) : null;

    if (first) {
      applyCounts(
        tx,
        marks,
        [
          {
            counter: 'reportsSigned',
            resourceUid,
            targetRef: db.collection(DOCTORS).doc(str(report.pathologistUid)),
            field: 'reportsSigned',
          },
          {
            counter: 'casesReported',
            resourceUid,
            targetRef: db.collection(PATIENTS).doc(str(caseDoc?.patientId)),
            field: 'casesReported',
          },
        ],
        now,
      );
    }
    if (translate && existing && !existing.exists) {
      tx.create(
        caseRef.collection('reportTexts').doc(id),
        newText({
          id,
          caseUid,
          reportUid,
          reportVersion: num(report.version),
          kind: 'Translation',
          language: target,
          sourceLanguage: source,
          sourceSha256: str(report.contentSha256),
          approverUid: str(report.pathologistUid),
          at,
        }),
      );
    }
  });
}

/**
 * The measurement preview (S-2, S-6). A draft's tile relabels change the counts, and the client
 * writes the draft directly, so this trigger recomputes the numbers in code and writes them onto
 * the draft with a hash of the inputs. It leaves `lastUpdatedAt` alone: the pathologist's stamp is
 * theirs. Any failure is recorded on the preview, never thrown, so nothing retries a model call.
 */
export async function onReportDraftWrittenHandler(
  deps: Deps,
  caseUid: string,
  pathologistUid: string,
  after: DocumentData | undefined,
): Promise<void> {
  if (!after || after.status !== 'Editing') return;
  const preview = await measurementPreview(deps, { ...after, caseUid });
  if (!preview) return;
  const ref = deps.db.collection('cases').doc(caseUid).collection('reportDrafts').doc(pathologistUid);
  await deps.db.runTransaction(async (tx) => {
    const fresh = (await tx.get(ref)).data();
    // The draft moved on while the service worked; the write it triggers computes the new one.
    if (!fresh || fresh.status !== 'Editing' || draftInputHash(fresh) !== preview.inputHash) return;
    tx.update(ref, { measurementsPreview: preview });
  });
}

export async function onReportTextWrittenHandler(deps: Deps, caseUid: string, id: string): Promise<void> {
  const { db } = deps;
  const now = nowOf(deps);

  // Live worker (bundle 61): Queued → Ready/Failed; Ready notifies the approver below.
  const before = (await textRef(deps, caseUid, id).get()).data();
  if (before && str(before.status) === 'Queued') {
    await processQueuedReportText(deps, caseUid, id);
  }

  await db.runTransaction(async (tx) => {
    const text = (await tx.get(textRef(deps, caseUid, id))).data();
    if (!text || text.status !== 'Ready') return;
    const language: NotifyLanguage = await languageOf(tx, db, DOCTORS, str(text.approverUid));
    const explanation = text.kind === 'Explanation';
    const notes = await planNotes(tx, db, [
      {
        template: explanation ? 'explanationReady' : 'translationReady',
        resourceKey: `${caseUid}_${id}-r${num(text.requestCount)}`,
        caseUid,
        recipientUid: str(text.approverUid),
        recipientRole: explanation ? 'doctor' : 'pathologist',
        language,
        resourceUid: str(text.reportUid),
        deepLink: `/cases/${caseUid}/texts/${id}`,
      },
    ]);
    sendNotes(tx, notes, now);
  });
}
