/**
 * The daily model-performance aggregate (plan §3.5, §3.9): reads the previous Nairobi
 * day's AI records — pre-reads and scores, translations and explanations, intake and
 * speech, voice notes, the risk check and notes translation, alert drafts and the
 * notifiable hint — and writes counts, rates and latency percentiles to
 * `modelSignals/{day}`. No uid, no text. Overwritten by day; the live bumped counters
 * keep their own fields.
 */
import type { DocumentData, Firestore, QueryDocumentSnapshot } from 'firebase-admin/firestore';

import { str } from './case-support';
import { nairobiDayKey, timestamp } from './common';
import { buildQuery, queryById } from './queries';

export interface ModelSignalsDeps {
  db: Firestore;
  now?: Date;
}

type DayDoc = QueryDocumentSnapshot;

function num(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function msBetween(from: unknown, to: unknown): number | undefined {
  const a = Date.parse(str(from));
  const b = Date.parse(str(to));
  if (!Number.isFinite(a) || !Number.isFinite(b) || b < a) return undefined;
  return b - a;
}

function rate(part: number, whole: number): number {
  if (whole <= 0) return 0;
  return Math.round((part / whole) * 10000) / 10000;
}

function percentiles(values: number[]): { count: number; p50Ms: number; p95Ms: number } {
  if (values.length === 0) return { count: 0, p50Ms: 0, p95Ms: 0 };
  const sorted = [...values].sort((a, b) => a - b);
  const at = (p: number): number => sorted[Math.min(sorted.length - 1, Math.ceil(p * sorted.length) - 1)];
  return { count: sorted.length, p50Ms: at(0.5), p95Ms: at(0.95) };
}

function mix(): Record<string, number> {
  return {};
}

function bump(map: Record<string, number>, key: string): void {
  map[key] = (map[key] ?? 0) + 1;
}

/** The UTC window of a Nairobi `YYYYMMDD` day, as ISO strings. */
export function nairobiDayWindow(day: string): { start: string; end: string } {
  const startMs = Date.parse(`${day.slice(0, 4)}-${day.slice(4, 6)}-${day.slice(6, 8)}T00:00:00+03:00`);
  return {
    start: new Date(startMs).toISOString(),
    end: new Date(startMs + 24 * 60 * 60 * 1000).toISOString(),
  };
}

async function dayDocs(
  db: Firestore,
  queryId: string,
  start: string,
  end: string,
): Promise<DayDoc[]> {
  const snap = await buildQuery(db, queryById(queryId), []).startAt(start).endBefore(end).get();
  return snap.docs as DayDoc[];
}

/**
 * Aggregates the previous Nairobi day (`day` overrides it for tests) and merges the
 * sections into `modelSignals/{day}`. Each section is recomputed whole, so a rerun
 * overwrites itself; fields other bundles bumped are left alone.
 */
export async function aggregateModelSignals(
  deps: ModelSignalsDeps,
  day?: string,
): Promise<{ day: string }> {
  const { db } = deps;
  const now = deps.now ?? new Date();
  const target = day ?? nairobiDayKey(new Date(now.getTime() - 24 * 60 * 60 * 1000));
  if (!/^\d{8}$/.test(target)) throw new Error('invalidSignalsDay');
  const { start, end } = nairobiDayWindow(target);

  const preread = await dayDocs(db, 'preread.byReadyAt', start, end);
  const scores = await dayDocs(db, 'prereadScores.byScoredAt', start, end);
  const provenances = await dayDocs(db, 'reportProvenance.byCreatedAt', start, end);
  const drafts = await dayDocs(db, 'reportDrafts.byCreatedAt', start, end);
  const textsReady = await dayDocs(db, 'reportTexts.byReadyAt', start, end);
  const textsApproved = await dayDocs(db, 'reportTexts.byApprovedAt', start, end);
  const intakes = await dayDocs(db, 'intake.byReadyAt', start, end);
  const messages = await dayDocs(db, 'messages.byDeliveredAt', start, end);
  const risks = await dayDocs(db, 'riskCheck.byReadyAt', start, end);
  const notes = await dayDocs(db, 'notesTranslation.byReadyAt', start, end);
  const alertsDrafted = await dayDocs(db, 'alerts.byDraftedAt', start, end);
  const alertsDecided = await dayDocs(db, 'alerts.byDecidedAt', start, end);
  // Expired alerts carry no decidedAt (the decision fields stay empty on Expired), so a
  // last-updated read finds them and the status narrows in code.
  const alertsExpired = (await dayDocs(db, 'alerts.byUpdatedAt', start, end)).filter(
    (doc) => str(doc.data().status) === 'Expired',
  );

  const doc: DocumentData = {
    day: target,
    computedAt: timestamp(now),
    lastUpdatedAt: timestamp(now),
    preread: prereadSection(preread, scores, provenances, drafts),
    translation: textSection(textsReady, textsApproved, 'Translation'),
    explanation: textSection(textsReady, textsApproved, 'Explanation'),
    intake: intakeSection(intakes),
    speech: speechSection(intakes),
    voice: await voiceSection(messages),
    risk: riskSection(risks),
    notesTranslation: notesSection(notes),
    alerts: alertsSection(alertsDrafted, alertsDecided, alertsExpired),
    hint: await hintSection(provenances),
  };
  // Each section is replaced whole on rerun (a stale mix key disappears); fields other
  // bundles bumped are left alone.
  await db.collection('modelSignals').doc(target).set(doc, {
    mergeFields: [
      'day',
      'computedAt',
      'lastUpdatedAt',
      'preread',
      'translation',
      'explanation',
      'intake',
      'speech',
      'voice',
      'risk',
      'notesTranslation',
      'alerts',
      'hint',
    ],
  });
  return { day: target };
}

function prereadSection(
  runs: DayDoc[],
  scores: DayDoc[],
  provenances: DayDoc[],
  drafts: DayDoc[],
): DocumentData {
  const failedByReason = mix();
  const latencies: number[] = [];
  let ready = 0;
  let failed = 0;
  for (const doc of runs) {
    const d = doc.data();
    if (str(d.status) === 'Ready') {
      ready++;
      const ms = msBetween(d.requestedAt, d.readyAt);
      if (ms !== undefined) latencies.push(ms);
    } else if (str(d.status) === 'Failed') {
      failed++;
      bump(failedByReason, str(d.failureReason) || 'unknown');
    }
  }
  const overallMix = mix();
  const verdictMix = mix();
  const bandMix = mix();
  let scored = 0;
  let agreed = 0;
  for (const doc of scores) {
    const d = doc.data();
    scored++;
    if (d.acceptedUnchanged === true) agreed++;
    // overall is stored as 1..5 (number); str() would collapse every score to "unknown".
    bump(overallMix, typeof d.overall === 'number' ? String(d.overall) : 'unknown');
    bump(bandMix, str(d.confidenceBand) || 'unknown');
    for (const key of ['findingsVerdict', 'impressionVerdict', 'measurementsVerdict', 'segmentationVerdict']) {
      if (str(d[key]) !== '') bump(verdictMix, `${key}:${str(d[key])}`);
    }
  }
  let editSum = 0;
  let editN = 0;
  let provenanceUnchanged = 0;
  for (const doc of provenances) {
    const d = doc.data();
    if (typeof d.editRate === 'number') {
      editSum += d.editRate;
      editN++;
    }
    if (d.acceptedUnchanged === true) provenanceUnchanged++;
  }
  const started = drafts.filter((doc) => doc.data().startedFromPreread === true).length;
  return {
    ready,
    failed,
    failedByReason,
    latency: percentiles(latencies),
    scored,
    agreeRate: rate(agreed, scored),
    overallMix,
    verdictMix,
    bandMix,
    meanEditRate: editN === 0 ? 0 : Math.round((editSum / editN) * 10000) / 10000,
    provenanceUnchangedRate: rate(provenanceUnchanged, provenances.length),
    startedFromPrereadRate: rate(started, drafts.length),
  };
}

function textSection(ready: DayDoc[], approved: DayDoc[], kind: string): DocumentData {
  const failedByReason = mix();
  const latencies: number[] = [];
  let readyCount = 0;
  let failedCount = 0;
  let numberCheckFailures = 0;
  for (const doc of ready) {
    const d = doc.data();
    if (str(d.kind) !== kind) continue;
    if (str(d.status) === 'Ready' || str(d.status) === 'Approved') {
      readyCount++;
      const ms = msBetween(d.requestedAt, d.readyAt);
      if (ms !== undefined) latencies.push(ms);
    } else if (str(d.status) === 'Failed') {
      failedCount++;
      bump(failedByReason, str(d.failureReason) || 'unknown');
      if (str(d.failureReason) === 'NumberCheck') numberCheckFailures++;
    }
  }
  const distances: number[] = [];
  let approvedCount = 0;
  let unchanged = 0;
  let editedSegments = 0;
  let mismatched = 0;
  for (const doc of approved) {
    const d = doc.data();
    if (str(d.kind) !== kind) continue;
    approvedCount++;
    if (d.acceptedUnchanged === true) unchanged++;
    if (typeof d.editDistance === 'number') distances.push(d.editDistance);
    if (Array.isArray(d.editedSegmentKeys)) editedSegments += d.editedSegmentKeys.length;
    if (d.languageMismatch === true) mismatched++;
  }
  return {
    ready: readyCount,
    failed: failedCount,
    failedByReason,
    numberCheckFailures,
    latency: percentiles(latencies),
    approved: approvedCount,
    acceptedUnchangedRate: rate(unchanged, approvedCount),
    meanEditDistance:
      distances.length === 0 ? 0 : Math.round((distances.reduce((a, b) => a + b, 0) / distances.length) * 10000) / 10000,
    editedSegments,
    languageMismatchRate: rate(mismatched, approvedCount),
  };
}

function intakeSection(intakes: DayDoc[]): DocumentData {
  const languageMix = mix();
  const latencies: number[] = [];
  let ready = 0;
  let failed = 0;
  const failedByReason = mix();
  for (const doc of intakes) {
    const d = doc.data();
    bump(languageMix, str(d.inputLanguage) || 'unknown');
    if (str(d.status) === 'Ready') {
      ready++;
      const ms = msBetween(d.requestedAt, d.readyAt);
      if (ms !== undefined) latencies.push(ms);
    } else if (str(d.status) === 'Failed') {
      failed++;
      bump(failedByReason, str(d.failureReason) || 'unknown');
    }
  }
  return { ready, failed, failedByReason, languageMix, latency: percentiles(latencies) };
}

function speechSection(intakes: DayDoc[]): DocumentData {
  const voices = intakes.filter((doc) => str(doc.data().inputMode) === 'Voice');
  const languageMix = mix();
  const distances: number[] = [];
  let unchanged = 0;
  let failed = 0;
  for (const doc of voices) {
    const d = doc.data();
    bump(languageMix, str(d.transcriptLanguage) || 'unknown');
    if (d.transcriptAcceptedUnchanged === true) unchanged++;
    if (typeof d.transcriptEditDistance === 'number') distances.push(d.transcriptEditDistance);
    if (str(d.status) === 'Failed') failed++;
  }
  return {
    requests: voices.length,
    failed,
    acceptedUnchangedRate: rate(unchanged, voices.length),
    meanEditDistance:
      distances.length === 0 ? 0 : Math.round((distances.reduce((a, b) => a + b, 0) / distances.length) * 10000) / 10000,
    languageMix,
  };
}

async function voiceSection(messages: DayDoc[]): Promise<DocumentData> {
  const voices = messages.filter((doc) => str(doc.data().kind) === 'Voice');
  const statusMix = mix();
  const languageMix = mix();
  const durationMix = mix();
  const modeMix = mix();
  const latencies: number[] = [];
  let flagged = 0;
  let shared = 0;
  let sharedUnchanged = 0;
  for (const doc of voices) {
    const d = doc.data();
    bump(statusMix, str(d.transcriptStatus) || 'unknown');
    bump(languageMix, str(d.transcriptLanguage) || 'unknown');
    bump(modeMix, str(d.inputMode) || 'unknown');
    const durationMs = num(d.voiceDurationMs);
    bump(durationMix, durationMs <= 30000 ? 'short' : durationMs <= 60000 ? 'medium' : 'long');
    if (d.identifierFlagged === true) flagged++;
    const machine = await doc.ref.collection('transcript').doc('machine').get();
    if (machine.exists) {
      const ms = msBetween(d.deliveredAt, machine.get('lastUpdatedAt'));
      if (ms !== undefined) latencies.push(ms);
    }
    const approved = await doc.ref.collection('transcript').doc('shared').get();
    if (approved.exists) {
      shared++;
      if (approved.get('acceptedUnchanged') === true) sharedUnchanged++;
    }
  }
  return {
    notes: voices.length,
    statusMix,
    languageMix,
    durationMix,
    modeMix,
    latency: percentiles(latencies),
    identifierFlagRate: rate(flagged, voices.length),
    shareRate: rate(shared, voices.length),
    sharedUnchangedRate: rate(sharedUnchanged, shared),
  };
}

function riskSection(risks: DayDoc[]): DocumentData {
  const languageMix = mix();
  const latencies: number[] = [];
  const failedByReason = mix();
  let ready = 0;
  let failed = 0;
  let advisory = 0;
  let suggested = 0;
  for (const doc of risks) {
    const d = doc.data();
    bump(languageMix, str(d.inputLanguage) || 'unknown');
    if (str(d.status) === 'Ready') {
      ready++;
      const ms = msBetween(d.requestedAt, d.readyAt);
      if (ms !== undefined) latencies.push(ms);
      if (str(d.advisoryKey) !== '') advisory++;
      if (Array.isArray(d.suggestedLabTestIds)) suggested += d.suggestedLabTestIds.length;
    } else if (str(d.status) === 'Failed') {
      failed++;
      bump(failedByReason, str(d.failureReason) || 'unknown');
    }
  }
  return {
    ready,
    failed,
    failedByReason,
    advisoryRate: rate(advisory, ready),
    suggestedTests: suggested,
    languageMix,
    latency: percentiles(latencies),
  };
}

function notesSection(notes: DayDoc[]): DocumentData {
  const pairMix = mix();
  const latencies: number[] = [];
  const failedByReason = mix();
  let ready = 0;
  let failed = 0;
  for (const doc of notes) {
    const d = doc.data();
    if (str(d.status) === 'Ready') {
      ready++;
      const ms = msBetween(d.requestedAt, d.readyAt);
      if (ms !== undefined) latencies.push(ms);
      bump(pairMix, `${str(d.sourceLanguage) || '?'}->${str(d.language) || '?'}`);
    } else if (str(d.status) === 'Failed') {
      failed++;
      bump(failedByReason, str(d.failureReason) || 'unknown');
    }
  }
  return { ready, failed, failedByReason, pairMix, latency: percentiles(latencies) };
}

function alertsSection(drafted: DayDoc[], decided: DayDoc[], expired: DayDoc[]): DocumentData {
  const sourceMix = mix();
  const fallbackByReason = mix();
  const draftLatencies: number[] = [];
  for (const doc of drafted) {
    const d = doc.data();
    bump(sourceMix, str(d.draftSource) || 'unknown');
    if (str(d.draftSource) === 'Template') bump(fallbackByReason, str(d.failureReason) || 'none');
    const ms = msBetween(d.requestedAt, d.draftedAt);
    if (ms !== undefined) draftLatencies.push(ms);
  }
  const decisionMix = mix();
  const decisionLatencies: number[] = [];
  const distances: number[] = [];
  let approvals = 0;
  let unchanged = 0;
  for (const doc of decided) {
    const d = doc.data();
    bump(decisionMix, str(d.decision) || str(d.status) || 'unknown');
    const ms = msBetween(d.draftedAt, d.decidedAt);
    if (ms !== undefined) decisionLatencies.push(ms);
    if (str(d.decision) === 'Approve' || str(d.decision) === 'ApproveEdited') {
      approvals++;
      if (d.acceptedUnchanged === true) unchanged++;
      if (typeof d.editDistance === 'number') distances.push(d.editDistance);
    }
  }
  return {
    drafted: drafted.length,
    sourceMix,
    fallbackRate: rate(
      drafted.filter((doc) => str(doc.data().draftSource) === 'Template').length,
      drafted.length,
    ),
    fallbackByReason,
    draftLatency: percentiles(draftLatencies),
    decided: decided.length,
    decisionMix,
    acceptedUnchangedRate: rate(unchanged, approvals),
    meanEditDistance:
      distances.length === 0 ? 0 : Math.round((distances.reduce((a, b) => a + b, 0) / distances.length) * 10000) / 10000,
    decisionLatency: percentiles(decisionLatencies),
    expired: expired.length,
    expiryRate: rate(expired.length, decided.length + expired.length),
  };
}

async function hintSection(provenances: DayDoc[]): Promise<DocumentData> {
  let shown = 0;
  let marked = 0;
  for (const doc of provenances) {
    const d = doc.data();
    const hinted = Array.isArray(d.hintShownDiseaseIds)
      ? d.hintShownDiseaseIds.filter((id: unknown) => typeof id === 'string' && id !== '')
      : [];
    if (hinted.length === 0) continue;
    shown++;
    const report = await doc.ref.parent.parent?.collection('reports').doc(doc.id).get();
    const findings = report?.data()?.notifiableFindings;
    const markedIds = new Set(
      Array.isArray(findings)
        ? findings.map((f: unknown) => (f as { diseaseId?: unknown }).diseaseId)
        : [],
    );
    if (hinted.some((id: string) => markedIds.has(id))) marked++;
  }
  return { shown, marked, markedRate: rate(marked, shown) };
}
