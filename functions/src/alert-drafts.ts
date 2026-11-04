// cspell:ignore coun hatari haina madhara imeshadhibitiwa udhibiti hakuna hofu wasiwasi kuwa kujali
/**
 * Alert drafting and decisions (07 §4-§5, plan §3.4-§3.5). The Drafting edge renders a
 * machine draft — or a template fallback when the model is off, fails, or writes
 * off-schema — and pages every approver; `approveAlert` decides it one-tap as is, edited,
 * or rejected; `requestAlertDraft` redrafts it. Humans see machine text beside the
 * guidance it came from; pushes and topics only ever render fixed templates.
 */
import type { DocumentData, Firestore, Transaction } from 'firebase-admin/firestore';

import { withTimeout } from './ai-domain';
import { alertGuidanceById, type AlertGuidance } from './alert-data';
import {
  REDRAFT_LIMIT,
  type AlertDeps,
  type AlertDraftInput,
} from './alert-deps';
import { loadAlertDraftRows, readAlertApprovers, settleLoadedRows } from './alert-detector';
import { deliverAlert } from './alert-delivery';
import { str } from './case-support';
import {
  DOCTORS,
  boundedText,
  input,
  oneOf,
  refuse,
  requireCaller,
  requireVerifiedEmail,
  timestamp,
  type Caller,
} from './common';
import { isEnabled } from './config';
import { ALERT_TEMPLATE_SW, BANNED_SW } from './copy/alerts.sw';
import { diseaseById } from './disease-data';
import { buildQuery, queryById } from './queries';
import { countyById } from './reference-data';
import { editDistance, planNotes, sendNotes, type NoteSpec } from './runtime-deps';
import { sanitize } from './sanitize';
import { bumpModelSignal } from './signals';

/** The four draft segments, keyed as the approver screen reads them. */
export type DraftKey = 'patient_en' | 'patient_sw' | 'clinician_en' | 'clinician_sw';

export interface DraftSegment {
  headline: string;
  body: string;
}

export type MachineText = Record<DraftKey, DraftSegment>;

const DRAFT_KEYS: DraftKey[] = ['patient_en', 'patient_sw', 'clinician_en', 'clinician_sw'];

/** The style rules the prompt carries (T-5 red-teams this text, not the code around it). */
export const ALERT_DRAFT_STYLE_RULES = [
  'Write a public-health alert headline and body for each audience and language.',
  'Name only the disease and the county, through the {disease} and {county} placeholders.',
  'Never write digits, counts, dates, ages, names, places, links, or case details.',
  'Never diagnose, reassure, or predict: no "you have", no "there is no risk", no "will spread".',
  'Keep every guidance claim inside the bullets; add nothing.',
].join(' ');

/** The AlertTextModel bounds, applied to model output before it is stored. */
const HEADLINE_MAX = 90;
const BODY_MAX = 600;

/** Phrases that diagnose, reassure or predict (07 §4 gives examples only). */
const BANNED_EN = [
  'you have',
  'you do not have',
  "you don't have",
  'there is no risk',
  'no risk',
  'you are safe',
  'you will recover',
  'will spread',
  'will not spread',
  'do not worry',
  "don't worry",
  'not dangerous',
  'harmless',
  'under control',
  'no cause for alarm',
  'nothing to worry',
];

/**
 * Swahili partners of the reassurance phrases above. They sit here, not in
 * `copy/alerts.sw.ts` beside `BANNED_SW`, only because that file is owned by
 * another slice; move them there on the merge.
 */
const BANNED_SW_REASSURANCE = [
  'si hatari',
  'sio hatari',
  'haina madhara',
  'imeshadhibitiwa',
  'iko chini ya udhibiti',
  'hakuna sababu ya hofu',
  'hakuna sababu ya wasiwasi',
  'hakuna cha kuwa na wasiwasi',
  'hakuna cha kujali',
];

const PATIENT_PLACEHOLDERS = ['disease', 'county'];
const CLINICIAN_PLACEHOLDERS = ['disease', 'county', 'count', 'weekStart'];

function placeholdersOf(text: string): string[] {
  return [...text.matchAll(/\{([a-zA-Z]+)\}/g)].map((m) => m[1]);
}

function hasUrl(headline: string, body: string): boolean {
  return /https?:\/\/|www\./i.test(headline) || /https?:\/\/|www\./i.test(body);
}

/**
 * Shape-guards four draft segments and sanitises them (R-6), so the checks below run on
 * exactly what would be stored: zero-width smuggling (`https\u200B://`, `{coun\u200Bt}`)
 * cannot pass the checks and land as a URL or a count. Over-long text is refused by
 * `sanitize` (`invalidText`), never cut. Returns undefined unless all four keys hold
 * strings that are still non-empty once cleaned.
 */
export function sanitizedDraftOutput(raw: unknown): MachineText | undefined {
  if (raw === null || typeof raw !== 'object') return undefined;
  const t = raw as Record<string, unknown>;
  const out = {} as MachineText;
  for (const key of DRAFT_KEYS) {
    const segment = t[key] as { headline?: unknown; body?: unknown } | undefined;
    if (!segment || typeof segment.headline !== 'string' || typeof segment.body !== 'string') {
      return undefined;
    }
    const headline = sanitize(segment.headline, HEADLINE_MAX);
    const body = sanitize(segment.body, BODY_MAX);
    if (headline === '' || body === '') return undefined;
    out[key] = { headline, body };
  }
  return out;
}

/**
 * The output checks (07 §4, step 4) on sanitised segments: no digit, the placeholder
 * allow-list (and every required placeholder present), no URL, no banned phrase, and sw
 * text that is not the en text. Returns the `FailureReason`, or '' when the output is usable.
 */
export function checkDraftOutput(texts: MachineText): string {
  for (const key of DRAFT_KEYS) {
    const segment = texts[key];
    if (/\d/.test(segment.headline) || /\d/.test(segment.body)) return 'NumberCheck';
    const allowed = key.startsWith('patient_') ? PATIENT_PLACEHOLDERS : CLINICIAN_PLACEHOLDERS;
    const used = [...placeholdersOf(segment.headline), ...placeholdersOf(segment.body)];
    if (used.some((p) => !allowed.includes(p))) return 'OffSchema';
    if (allowed.some((p) => !used.includes(p))) return 'OffSchema';
    if (hasUrl(segment.headline, segment.body)) return 'OffSchema';
  }
  const lower = (s: string): string => s.toLowerCase();
  const en = (['patient_en', 'clinician_en'] as const)
    .map((k) => lower(texts[k].headline) + '\n' + lower(texts[k].body))
    .join('\n');
  const sw = (['patient_sw', 'clinician_sw'] as const)
    .map((k) => lower(texts[k].headline) + '\n' + lower(texts[k].body))
    .join('\n');
  if (
    BANNED_EN.some((p) => en.includes(p)) ||
    BANNED_SW.some((p) => sw.includes(p)) ||
    BANNED_SW_REASSURANCE.some((p) => sw.includes(p))
  )
    return 'Banned';
  for (const [swKey, enKey] of [['patient_sw', 'patient_en'], ['clinician_sw', 'clinician_en']] as const) {
    if (texts[swKey].headline === texts[enKey].headline && texts[swKey].body === texts[enKey].body) {
      return 'OffSchema';
    }
  }
  return '';
}

/** Collapse whitespace for an exact guidance-bullet comparison. */
function normalizeClaim(text: string): string {
  return text.replace(/\s+/g, ' ').trim().toLowerCase();
}

/** The template headlines, normalised: the only full-line headlines a draft may carry. */
const FRAMING_HEADLINES = new Set([
  'health alert: {disease} in {county} county',
  'tahadhari ya afya: {disease} katika kaunti ya {county}',
]);

/** Words a headline may use besides `{placeholders}`: the template framing vocabulary. */
const HEADLINE_FRAMING_WORDS = new Set([
  'health',
  'alert',
  'in',
  'county',
  'tahadhari',
  'ya',
  'afya',
  'katika',
  'kaunti',
]);

/** Lower-cased words with placeholders and punctuation stripped. */
function contentWords(text: string): string[] {
  return text
    .replace(/\{[a-zA-Z]+\}/g, ' ')
    .toLowerCase()
    .replace(/[^a-z\s]/g, ' ')
    .split(/\s+/)
    .filter((w) => w.length > 0);
}

/**
 * A headline is grounded when it is one of the framing lines or holds nothing
 * but placeholders and framing words; an invented claim falls back.
 */
function isGroundedHeadline(headline: string): boolean {
  if (FRAMING_HEADLINES.has(normalizeClaim(headline))) return true;
  const words = contentWords(headline);
  return words.length === 0 || words.every((w) => HEADLINE_FRAMING_WORDS.has(w));
}

/**
 * The sentences a draft may carry besides an exact guidance bullet: the template's own, with their
 * placeholders. A sentence that merely mentions the guidance is not framing: it could carry a
 * claim of its own in the same breath, so only the template's sentences pass (bundle 77).
 */
function templateSentences(): Set<string> {
  const out = new Set<string>();
  const template = templateDraft(false);
  for (const key of DRAFT_KEYS) {
    for (const sentence of template[key].body.split(/(?<=[.!?])\s+/)) {
      out.add(normalizeClaim(sentence));
    }
  }
  return out;
}

/**
 * Grounds every segment's headline and body against the guidance bundle. A headline
 * passes only as a framing line or placeholders plus framing words. A body sentence
 * passes only as an exact bullet for its audience and language or as one of the
 * template's own sentences (placeholders intact); a sentence that merely mentions the
 * guidance, or that adds a claim around a placeholder, is invented or rewritten and
 * falls back to the template.
 */
export function checkGuidanceGrounding(
  texts: MachineText,
  guidance: AlertDraftInput['guidance'],
): string {
  const bulletsFor = (audience: 'Patient' | 'Clinician', lang: 'en' | 'sw'): Set<string> => {
    const set = new Set<string>();
    for (const b of guidance) {
      if (b.audience !== audience) continue;
      set.add(normalizeClaim(lang === 'en' ? b.textEn : b.textSw));
    }
    return set;
  };
  const framing = templateSentences();
  for (const key of DRAFT_KEYS) {
    const audience = key.startsWith('patient_') ? 'Patient' : 'Clinician';
    const lang = key.endsWith('_sw') ? 'sw' : 'en';
    const allowed = bulletsFor(audience, lang);
    if (!isGroundedHeadline(texts[key].headline)) return 'OffSchema';
    const sentences = texts[key].body
      .split(/(?<=[.!?])\s+/)
      .map((s) => s.trim())
      .filter((s) => s.length > 0);
    for (const sentence of sentences) {
      const remainder = sentence.replace(/\{[a-zA-Z]+\}/g, ' ');
      if (contentWords(remainder).length === 0) continue;
      const claim = normalizeClaim(sentence);
      if (allowed.has(claim) || framing.has(claim)) continue;
      return 'OffSchema';
    }
  }
  return '';
}

/** Cleans model output and checks it; anything unusable falls back to the template. */
function cleanedModelOutput(
  raw: unknown,
  guidance?: AlertDraftInput['guidance'],
): { clean?: MachineText; reason: string } {
  try {
    const clean = sanitizedDraftOutput(raw);
    if (!clean) return { reason: 'OffSchema' };
    const shape = checkDraftOutput(clean);
    if (shape !== '') return { reason: shape };
    if (guidance) {
      const grounded = checkGuidanceGrounding(clean, guidance);
      if (grounded !== '') return { reason: grounded };
    }
    return { clean, reason: '' };
  } catch {
    return { reason: 'OffSchema' };
  }
}

/** The §4.1 template draft, used whenever the model cannot be. Demo alerts prefix every line. */
export function templateDraft(synthetic: boolean): MachineText {
  const demoEn = synthetic ? 'Demo: ' : '';
  const demoSw = synthetic ? 'Majaribio: ' : '';
  return {
    patient_en: {
      headline: `${demoEn}Health alert: {disease} in {county} County`,
      body: `${demoEn}Cases of {disease} have been confirmed in {county} County. Follow the Ministry of Health guidance below, and visit a health facility if you feel unwell.`,
    },
    patient_sw: {
      headline: `${demoSw}${ALERT_TEMPLATE_SW.headline}`,
      body: `${demoSw}${ALERT_TEMPLATE_SW.patientBody}`,
    },
    clinician_en: {
      headline: `${demoEn}Health alert: {disease} in {county} County`,
      body: `${demoEn}Confirmed {disease} results in {county} County, week of {weekStart}: {count}. Watch for suspected cases and follow the Ministry of Health guidance below.`,
    },
    clinician_sw: {
      headline: `${demoSw}${ALERT_TEMPLATE_SW.headline}`,
      body: `${demoSw}${ALERT_TEMPLATE_SW.clinicianBody}`,
    },
  };
}

export type AlertWrittenOutcome =
  | 'drafted'
  | 'template'
  | 'dropped'
  | 'delivered'
  | 'deleted'
  | 'ignored';

export interface AlertWrittenEvent {
  before: DocumentData | undefined;
  after: DocumentData | undefined;
}

function draftInputFor(
  diseaseId: string,
  countyId: number,
  category: string,
  rule: string,
  guidance: AlertGuidance | undefined,
): AlertDraftInput | undefined {
  const disease = diseaseById(diseaseId);
  const countyName = countyById(countyId)?.name ?? '';
  if (!disease || !guidance || countyName === '') return undefined;
  return {
    diseaseId,
    diseaseNameEn: disease.nameEn,
    diseaseNameSw: disease.nameSw,
    countyName,
    category,
    rule,
    audienceKeys: [...DRAFT_KEYS],
    guidance: guidance.bullets.map((b) => ({
      bulletId: b.bulletId,
      audience: b.audience,
      textEn: b.textEn,
      textSw: b.textSw,
    })),
    placeholders: { patient: [...PATIENT_PLACEHOLDERS], clinician: [...CLINICIAN_PLACEHOLDERS] },
    styleRules: ALERT_DRAFT_STYLE_RULES,
  };
}

function expiryHours(category: string): number {
  return category === 'Immediate' ? 24 : 72;
}

export interface DraftWrite {
  /** Undefined renders the (synthetic-aware) template inside the transaction. */
  texts?: MachineText;
  models: Record<string, string>;
  draftSource: string;
  failureReason: string;
}

/**
 * Step 6's transaction, shared by the trigger and the sweep: still `Drafting` with the
 * same `requestCount` writes `Draft` and pages every approver; anything else — a late
 * answer, a terminal alert — is dropped, never half-written. `staleAfter` additionally
 * requires `requestedAt` at or before it (the sweep's re-check).
 */
export async function writeDraftTx(
  tx: Transaction,
  db: Firestore,
  alertUid: string,
  requestCount: number,
  draft: DraftWrite,
  now: Date,
  staleAfter?: Date,
): Promise<'drafted' | 'template' | 'dropped'> {
  const ref = db.collection('alerts').doc(alertUid);
  const current = (await tx.get(ref)).data();
  if (
    !current || str(current.status) !== 'Drafting' ||
    (typeof current.requestCount === 'number' ? current.requestCount : 0) !== requestCount
  ) {
    return 'dropped';
  }
  if (staleAfter !== undefined) {
    const requestedAt = Date.parse(str(current.requestedAt));
    if (!Number.isFinite(requestedAt) || requestedAt > staleAfter.getTime()) return 'dropped';
  }
  const synthetic = current.synthetic === true;
  const texts = draft.texts ?? templateDraft(synthetic);
  const approvers = await readAlertApprovers(tx, db);
  const at = timestamp(now);
  const expiresAt = timestamp(
    new Date(now.getTime() + expiryHours(str(current.category)) * 60 * 60 * 1000),
  );
  const specs: NoteSpec[] = approvers.map((approver): NoteSpec => ({
    template: 'alertDrafted',
    resourceKey: `${alertUid}-r${requestCount}`,
    threadUid: alertUid,
    resourceUid: alertUid,
    recipientUid: approver.uid,
    recipientRole: 'admin',
    language: approver.language,
    expiresAt,
    deepLink: `/alerts/${alertUid}/review`,
  }));
  const notes = await planNotes(tx, db, specs);
  const draftRevision = (typeof current.draftRevision === 'number' ? current.draftRevision : 0) + 1;
  tx.update(ref, {
    status: 'Draft',
    machineText: texts,
    models: draft.models,
    draftSource: draft.draftSource,
    failureReason: draft.failureReason,
    draftedAt: at,
    expiresAt,
    draftRevision,
    lastUpdatedAt: at,
  });
  sendNotes(tx, notes, now);
  bumpModelSignal(tx, db, 'alertDraftReady', now);
  if (draft.draftSource === 'Template') bumpModelSignal(tx, db, 'alertDraftTemplateFallback', now);
  return draft.draftSource === 'Model' ? 'drafted' : 'template';
}

/**
 * Drafting on the `Drafting` edge (created, or `requestCount` moved), delivery on the
 * `Approved` edge. Drafting runs outside the transaction; the write re-checks the edge
 * first, so a late answer after `Withdrawn` is dropped.
 */
export async function onAlertWrittenHandler(
  deps: AlertDeps,
  alertUid: string,
  event: AlertWrittenEvent,
): Promise<AlertWrittenOutcome> {
  const { db } = deps;
  const after = event.after;
  if (!after) return 'deleted';
  const before = event.before;

  const num = (value: unknown): number => (typeof value === 'number' ? value : 0);
  const draftingEdge =
    str(after.status) === 'Drafting' &&
    (before === undefined || num(after.requestCount) !== num(before.requestCount));
  const approvedEdge =
    str(after.status) === 'Approved' &&
    (before === undefined || str(before.status) !== 'Approved');
  if (!draftingEdge && !approvedEdge) return 'ignored';

  if (approvedEdge) {
    await deliverAlert(deps, alertUid);
    return 'delivered';
  }

  const now = deps.now ?? new Date();
  const synthetic = after.synthetic === true;
  const diseaseId = str(after.diseaseId);
  const draftCountyId = typeof after.countyId === 'number' ? after.countyId : 0;
  const draftInput = draftInputFor(
    diseaseId,
    draftCountyId,
    str(after.category),
    str(after.rule),
    alertGuidanceById(diseaseId),
  );
  let texts: MachineText | undefined;
  const models: Record<string, string> = {};
  let draftSource = 'Model';
  let failureReason = '';
  if (synthetic) {
    draftSource = 'Template';
  } else if (!isEnabled(deps.config, 'alert_drafting_enabled')) {
    draftSource = 'Template';
    failureReason = 'Disabled';
  } else if (!draftInput) {
    draftSource = 'Template';
    failureReason = 'ServiceError';
  } else if (typeof deps.ai?.generateAlertDraft !== 'function') {
    draftSource = 'Template';
    failureReason = 'ServiceError';
  } else {
    try {
      const output = await withTimeout(deps.ai.generateAlertDraft(draftInput));
      const checked = cleanedModelOutput(output?.texts, draftInput.guidance);
      if (checked.reason === '' && checked.clean) {
        texts = checked.clean;
        Object.assign(models, (output.models ?? {}) as Record<string, string>);
      } else {
        draftSource = 'Template';
        failureReason = checked.reason;
      }
    } catch (e) {
      draftSource = 'Template';
      failureReason = (e as Error).message === 'timeout' ? 'Timeout' : 'ServiceError';
    }
  }

  const requestCount = num(after.requestCount);
  return db.runTransaction((tx) =>
    writeDraftTx(tx, db, alertUid, requestCount, { texts, models, draftSource, failureReason }, now),
  );
}

// --- approveAlert -------------------------------------------------------------

export type ApproveDecision = 'Approve' | 'ApproveEdited' | 'Reject';

export interface ApproveAlertData {
  alertUid: string;
  decision: ApproveDecision;
  draftRevision: number;
  evidenceRevision: number;
  audience?: string;
  editedText?: unknown;
  reason?: string;
}

function editedKeysOf(machine: DocumentData, edited: MachineText): { keys: string[]; distance: number } {
  const keys: string[] = [];
  let distance = 0;
  for (const key of DRAFT_KEYS) {
    const m = (machine[key] ?? {}) as { headline?: unknown; body?: unknown };
    const e = edited[key];
    if (str(m.headline) !== e.headline || str(m.body) !== e.body) {
      keys.push(key);
      distance += editDistance(str(m.headline), e.headline) + editDistance(str(m.body), e.body);
    }
  }
  return { keys, distance: Math.round(distance * 10000) / 10000 };
}

/**
 * Human edits: sanitised first (R-6), then all four keys, bounds and the placeholder
 * allow-list — a human may type digits — and URL-checked on the cleaned text. Anything
 * else is refused, never stored.
 */
function validatedEdits(raw: unknown): MachineText {
  let clean: MachineText | undefined;
  try {
    clean = sanitizedDraftOutput(raw);
  } catch {
    throw refuse('invalid-argument', 'invalidEdits');
  }
  if (!clean) throw refuse('invalid-argument', 'invalidEdits');
  for (const key of DRAFT_KEYS) {
    const segment = clean[key];
    const allowed = key.startsWith('patient_') ? PATIENT_PLACEHOLDERS : CLINICIAN_PLACEHOLDERS;
    const used = [...placeholdersOf(segment.headline), ...placeholdersOf(segment.body)];
    if (used.some((p) => !allowed.includes(p))) throw refuse('invalid-argument', 'invalidPlaceholder');
    if (hasUrl(segment.headline, segment.body)) throw refuse('invalid-argument', 'invalidEdits');
  }
  return clean;
}

/**
 * One approver decides a Draft: Approve takes the machine text, ApproveEdited takes edited
 * text (keys and distance recorded), Reject needs a reason. The same approver re-deciding
 * the same way is a no-op; anyone else finds `alreadyDecided`. Approval only commits the
 * decision and the delivery job; the Approved-edge trigger runs the delivery.
 */
export async function approveAlertHandler(
  deps: AlertDeps,
  caller: Caller | null,
  raw: unknown,
): Promise<{ status: string; alertUid: string; decision: string }> {
  const c = requireCaller(caller);
  requireVerifiedEmail(c);
  if (!c.isAdmin) throw refuse('permission-denied', 'notApprover');
  const data = input(raw) as Partial<ApproveAlertData>;
  const alertUid = boundedText(data.alertUid, 1, 128, 'invalidAlert');
  const decision = oneOf(data.decision, ['Approve', 'ApproveEdited', 'Reject'] as const, 'invalidDecision');
  if (typeof data.draftRevision !== 'number' || typeof data.evidenceRevision !== 'number') {
    throw refuse('invalid-argument', 'invalidRevision');
  }
  const draftRevision = data.draftRevision;
  const evidenceRevision = data.evidenceRevision;
  const audience = oneOf(
    data.audience ?? 'CliniciansThenPatients',
    ['CliniciansThenPatients', 'CliniciansOnly'] as const,
    'invalidAudience',
  );
  const edited = decision === 'ApproveEdited' ? validatedEdits(data.editedText) : undefined;
  const reason = decision === 'Reject' ? boundedText(data.reason, 1, 500, 'reasonRequired') : '';

  const { db } = deps;
  const now = deps.now ?? new Date();
  const at = timestamp(now);

  const result = await db.runTransaction(async (tx) => {
    const ref = db.collection('alerts').doc(alertUid);
    const alert = (await tx.get(ref)).data();
    if (!alert) throw refuse('not-found', 'unknownAlert');
    const approver = await tx.get(db.collection('alertApprovers').doc(c.uid));
    if (!approver.exists) throw refuse('permission-denied', 'notApprover');
    const status = str(alert.status);
    if (status === 'Approved' || status === 'Delivered' || status === 'Rejected') {
      const same = str(alert.decidedByUid) === c.uid &&
        ((decision === 'Reject' && str(alert.decision) === 'Reject') ||
          (decision !== 'Reject' && str(alert.decision) !== 'Reject' && str(alert.decision) !== ''));
      if (!same) throw refuse('failed-precondition', 'alreadyDecided');
      return { status: 'ok', alertUid, decision: str(alert.decision), expired: false };
    }
    if (status === 'Withdrawn') throw refuse('failed-precondition', 'alertWithdrawn');
    if (status === 'Expired') throw refuse('failed-precondition', 'alertExpired');
    if (status !== 'Draft') throw refuse('failed-precondition', 'notReady');
    // Q-23's "never broadcast" is a refusal on every path, not a forced audience: the
    // detector never creates such an alert, so reaching here means corrupt state.
    const disease = diseaseById(str(alert.diseaseId));
    if (!disease || disease.publicAlertEligible !== true) {
      throw refuse('failed-precondition', 'notEligible');
    }

    if (str(alert.expiresAt) !== '' && Date.parse(str(alert.expiresAt)) <= now.getTime()) {
      const rows = await loadAlertDraftRows(tx, db, alertUid);
      const approvers = await readAlertApprovers(tx, db);
      const specs: NoteSpec[] = approvers.map((approver): NoteSpec => ({
        template: 'alertExpired',
        resourceKey: `${alertUid}-r${num(alert.requestCount)}`,
        threadUid: alertUid,
        resourceUid: alertUid,
        recipientUid: approver.uid,
        recipientRole: 'admin',
        language: approver.language,
        deepLink: `/alerts/${alertUid}/review`,
      }));
      const notes = await planNotes(tx, db, specs);
      tx.update(ref, { status: 'Expired', lastUpdatedAt: at });
      settleLoadedRows(tx, rows, 'Expired', '', now);
      sendNotes(tx, notes, now);
      return { status: 'ok', alertUid, decision: '', expired: true };
    }

    const rows = await loadAlertDraftRows(tx, db, alertUid);
    const hit = await tx.get(
      buildQuery(db, queryById('notifiableEventLinks.bySignalPathologist'), [alertUid, c.uid]).limit(1),
    );
    const profile = (await tx.get(db.collection(DOCTORS).doc(c.uid))).data();

    if (num(alert.draftRevision) !== draftRevision) throw refuse('failed-precondition', 'draftChanged');
    if (num(alert.evidenceRevision) !== evidenceRevision) {
      throw refuse('failed-precondition', 'evidenceChanged');
    }
    // A redraft from Withdrawn at zero evidence must never reach patients — or clinicians
    // with a false "confirmed" brief. Neither 07 nor the plan names this check; refusing
    // is the fail-closed choice (P2-4).
    const evidence = (alert.evidence ?? {}) as DocumentData;
    if (num(evidence.confirmedCount) < 1 || alert.evidenceRetracted === true) {
      throw refuse('failed-precondition', 'noEvidence');
    }
    if (!hit.empty) throw refuse('permission-denied', 'selfApproval');

    const decidedByName = `${str(profile?.firstName)} ${str(profile?.lastName)}`.trim() || c.uid;

    if (decision === 'Reject') {
      tx.update(ref, {
        status: 'Rejected',
        decision: 'Reject',
        rejectReason: sanitize(reason, 500),
        decidedByUid: c.uid,
        decidedByName,
        decidedAt: at,
        lastUpdatedAt: at,
      });
      settleLoadedRows(tx, rows, 'Declined', c.uid, now);
      return { status: 'ok', alertUid, decision: 'Reject', expired: false };
    }

    const machine = (alert.machineText ?? {}) as DocumentData;
    const approved = decision === 'ApproveEdited' && edited ? edited : (machine as MachineText);
    const { keys, distance } = decision === 'ApproveEdited' && edited
      ? editedKeysOf(machine, edited)
      : { keys: [] as string[], distance: 0 };
    tx.update(ref, {
      status: 'Approved',
      decision: decision === 'ApproveEdited' ? 'ApproveEdited' : 'Approve',
      audience,
      approvedText: approved,
      approvedEvidence: (alert.evidence ?? {}) as DocumentData,
      acceptedUnchanged: decision === 'Approve',
      editedKeys: keys,
      editDistance: distance,
      decidedByUid: c.uid,
      decidedByName,
      decidedAt: at,
      lastUpdatedAt: at,
    });
    tx.create(db.collection('alertDeliveries').doc(alertUid), {
      alertUid,
      phase: 'Pending',
      heldReason: '',
      leaseOwner: '',
      leaseUntil: '',
      clinicianCursor: '',
      cliniciansNotified: 0,
      patientsNotBefore: '',
      topicClaims: { en: '', sw: '' },
      topicSentAt: { en: '', sw: '' },
      messageIds: { en: '', sw: '' },
      createdAt: at,
      lastUpdatedAt: at,
    });
    settleLoadedRows(tx, rows, 'Accepted', c.uid, now);
    if (decision === 'Approve') bumpModelSignal(tx, db, 'alertAcceptedUnchanged', now);
    return { status: 'ok', alertUid, decision: str(decision), expired: false };
  });

  // The acceptCase pattern: the expiry commits, then the refusal goes out.
  // Delivery is left to the Approved-edge trigger and the sweep: the callable must not
  // page a whole county inline after its approval has committed.
  if (result.expired) throw refuse('failed-precondition', 'alertExpired');
  return { status: result.status, alertUid: result.alertUid, decision: result.decision };
}

function num(value: unknown): number {
  return typeof value === 'number' ? value : 0;
}

// --- requestAlertDraft -------------------------------------------------------

export interface RequestAlertDraftData {
  alertUid?: string;
}

/**
 * Redrafts a Draft, Rejected, Expired or Withdrawn alert (up to three rounds): back to
 * `Drafting` with the decision cleared and the open rows cancelled. A Rejected alert
 * stays rejected for its week unless an approver redrafts it.
 */
export async function requestAlertDraftHandler(
  deps: AlertDeps,
  caller: Caller | null,
  raw: unknown,
): Promise<{ status: string; alertUid: string }> {
  const c = requireCaller(caller);
  requireVerifiedEmail(c);
  if (!c.isAdmin) throw refuse('permission-denied', 'notApprover');
  const data = input(raw) as Partial<RequestAlertDraftData>;
  const alertUid = boundedText(data.alertUid, 1, 128, 'invalidAlert');

  const { db } = deps;
  const now = deps.now ?? new Date();
  const at = timestamp(now);

  return db.runTransaction(async (tx) => {
    const ref = db.collection('alerts').doc(alertUid);
    const alert = (await tx.get(ref)).data();
    if (!alert) throw refuse('not-found', 'unknownAlert');
    const approver = await tx.get(db.collection('alertApprovers').doc(c.uid));
    if (!approver.exists) throw refuse('permission-denied', 'notApprover');
    const status = str(alert.status);
    if (status !== 'Draft' && status !== 'Rejected' && status !== 'Expired' && status !== 'Withdrawn') {
      throw refuse('failed-precondition', 'invalidState');
    }
    const requestCount = num(alert.requestCount);
    if (requestCount >= REDRAFT_LIMIT) throw refuse('failed-precondition', 'redraftLimit');
    const rows = await loadAlertDraftRows(tx, db, alertUid);
    tx.update(ref, {
      status: 'Drafting',
      requestCount: requestCount + 1,
      requestedAt: at,
      reminderSentAt: '',
      decision: '',
      decidedByUid: '',
      decidedByName: '',
      decidedAt: '',
      rejectReason: '',
      approvedText: {},
      approvedEvidence: {},
      acceptedUnchanged: false,
      editedKeys: [],
      editDistance: 0,
      lastUpdatedAt: at,
    });
    settleLoadedRows(tx, rows, 'Cancelled', c.uid, now);
    return { status: 'redrafting', alertUid };
  });
}
