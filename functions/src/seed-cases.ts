/**
 * Demo cases for the three demo accounts (`make seed-cases`). Every step runs through the same
 * handlers the callables use, each on its own clock, so the history is backdated from `SEED_FROM`
 * to now and no document is written around a handler. Two kinds of record are not made by a
 * handler and are stored examples: the AI pre-read runs and the approved explanation drafts (no
 * AI service exists), each marked with a provenance line in `models`, and the background
 * notifiable events other facilities would report, which have no case behind them.
 *
 * Idempotent: ids come from a fixed seed, and a case that exists is skipped whole.
 */
import { createHash, randomBytes } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { getApp, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { type Firestore, getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

import { countyIdByName, nairobiEpiWeek } from './alert-data';
import type { AlertDeps } from './alert-deps';
import { onNotifiableEventWrittenHandler, signalUidFor } from './alert-detector';
import { approveAlertHandler, onAlertWrittenHandler } from './alert-drafts';
import { notifiableEventFor } from './alerts';
import {
  availabilityOf,
  type Availability,
} from './identity';
import {
  cancelAppointmentHandler,
  completeAppointmentHandler,
  onAppointmentWrittenHandler,
  requestAppointmentHandler,
  respondToAppointmentHandler,
} from './appointments';
import { requiredQuestions, saveObject, type Deps } from './case-support';
import {
  acceptCaseHandler,
  cancelOrderHandler,
  completeCaseHandler,
  createOrderHandler,
  onCaseWrittenHandler,
  recordSampleReceivedHandler,
  registerSlidesHandler,
  reserveSlideUploadsHandler,
} from './cases';
import { nairobiDate, type Caller } from './common';
import type { ConfigReader } from './config';
import { buildQuery, queryById } from './queries';
import { DATA_DIR } from './reference-data';
import {
  approveReportTextHandler,
  markDiscussedHandler,
  onPrereadWrittenHandler,
  onReportCreatedHandler,
  onReportTextWrittenHandler,
  scorePrereadHandler,
  signReportHandler,
  startReportHandler,
} from './reports';
import type { RuntimeDeps } from './runtime-deps';
import { PROJECT, target } from './seed';
import {
  PROVENANCE,
  composeCells,
  fetchCells,
  heatmapPng,
  histologyDraft,
  histologyMeasurements,
  histologyTiles,
  loadManifest,
  malariaDraft,
  malariaMeasurements,
  malariaTiles,
  signaturePng,
  slideBytes,
  type Certainty,
  type MalariaSpec,
  type PrereadDraft,
  type Raster,
  type Tile,
} from './seed-cases-media';
import { redeemShareCodeHandler } from './shares-callables';

const MIN = 60_000;
const HOUR = 60 * MIN;
const DAY = 24 * HOUR;
const EAT = 3 * HOUR;
const SLOT = 30 * MIN;

const HISTOLOGY = '9f7bb98a-1df9-4730-88b6-2226ffced0a0';
const SKIN_PUNCH = '9f7bb98c-b3d2-44e2-89f8-afa08e7164f8';
const CYTOPATHOLOGY = '9f7bb988-e47a-4e84-b0ff-6796970913cb';
const PAP_SMEAR = '9f7bb98b-d1ad-4e72-93e7-0030f4ac8700';
const MALARIA_SMEAR = '9f7bb988-7068-4bc4-a7c5-08c690da9482';
const FULL_HAEMOGRAM = '9f7bb989-71bc-40f9-8be1-4ecf4ca01a73';

export interface People {
  doctor: Caller;
  pathologist: Caller;
  patient: Caller;
  patientId: string;
}

export interface SeedCtx {
  db: Firestore;
  bucket: string;
  /** The end of the history; every step is at or before it. */
  now: Date;
  /** The start of the history. */
  from: Date;
  /** Distinguishes a second set of the same cases. */
  tag: string;
  shareCodeKey: string;
  people: People;
  /** The malaria cell crops; the default fetches them from the archive named in the manifest. */
  cells?: (spec: MalariaSpec) => Promise<Raster[]>;
  log?: (line: string) => void;
}

export interface SeedResult {
  cases: Record<string, string>;
  created: string[];
  skipped: string[];
}

/** Ids the handlers accept are UUID v4 in shape, so these are SHA-256 derived rather than RFC 4122 v5. */
export function uidFor(tag: string, key: string): string {
  const h = createHash('sha256').update(`tabibu-demo-seed:${tag}:${key}`).digest();
  h[6] = (h[6] & 0x0f) | 0x40;
  h[8] = (h[8] & 0x3f) | 0x80;
  const x = h.subarray(0, 16).toString('hex');
  return `${x.slice(0, 8)}-${x.slice(8, 12)}-${x.slice(12, 16)}-${x.slice(16, 20)}-${x.slice(20, 32)}`;
}

const iso = (ms: number): string => new Date(ms).toISOString();

/** Nairobi's Monday 00:00 of the week holding `ms`. */
export function weekStartOf(ms: number): number {
  const shifted = new Date(ms + EAT);
  const weekday = shifted.getUTCDay() === 0 ? 7 : shifted.getUTCDay();
  const midnight = Date.UTC(shifted.getUTCFullYear(), shifted.getUTCMonth(), shifted.getUTCDate());
  return midnight - (weekday - 1) * DAY - EAT;
}

function validSlot(ms: number, hours: Availability): boolean {
  const shifted = new Date(ms + EAT);
  const weekday = shifted.getUTCDay() === 0 ? 7 : shifted.getUTCDay();
  const minute = shifted.getUTCHours() * 60 + shifted.getUTCMinutes();
  return hours.workingDays.includes(weekday) && minute >= hours.dayStartMinute && minute + 30 <= hours.dayEndMinute;
}

function allSlots(hours: Availability, taken: Set<number>, first: number, step: number): number {
  let at = step > 0 ? Math.ceil(first / SLOT) * SLOT : Math.floor(first / SLOT) * SLOT;
  for (let i = 0; i < 31 * 48; i++, at += step * SLOT) {
    if (validSlot(at, hours) && !taken.has(at)) {
      taken.add(at);
      return at;
    }
  }
  throw new Error('The doctor has no free slot in the window.');
}

function working(ms: number): boolean {
  const shifted = new Date(ms + EAT);
  const weekday = shifted.getUTCDay() === 0 ? 7 : shifted.getUTCDay();
  const minute = shifted.getUTCHours() * 60 + shifted.getUTCMinutes();
  return weekday <= 5 && minute >= 8 * 60 && minute < 17 * 60;
}

/** The last working moment (Nairobi, Monday to Friday, 08:00 to 17:00) at or before `ms`. */
export function prevWork(ms: number): number {
  if (working(ms)) return ms;
  const rest = ms % SLOT;
  const cell = ms - rest;
  for (let t = cell; t > cell - 8 * DAY; t -= SLOT) if (working(t)) return t + rest;
  return ms;
}

/** The first working moment at or after `ms`, or the last one before `cap` when there is none by then. */
export function nextWork(ms: number, cap: number): number {
  if (working(ms) && ms <= cap) return ms;
  const rest = ms % SLOT;
  const cell = ms - rest;
  for (let t = cell + SLOT; t <= cap && t < cell + 8 * DAY; t += SLOT) if (working(t)) return t + rest;
  return prevWork(Math.min(ms, cap));
}

/** Steps counted back from `final`, each at a working moment: `gaps` runs from the last gap to the first. */
export function backFrom(final: number, gaps: number[]): number[] {
  const out = [prevWork(final)];
  for (const gap of gaps) out.unshift(prevWork(out[0] - gap));
  return out;
}

/** A pathologist's request closes after 24 hours, so an order never sits further back than that from its acceptance. */
function withOpenRequest(times: number[]): number[] {
  return times[1] - times[0] > 22 * HOUR ? [times[1] - 2 * HOUR, ...times.slice(1)] : times;
}

const switches = (...on: string[]): ConfigReader => ({ enabled: (key) => on.includes(key) });

/** A case's own clock: only ever moves forward, never past the end of the history. */
class Run {
  t: number;
  constructor(
    readonly key: string,
    start: number,
    readonly caseUid: string,
    readonly appointmentUid: string,
    private readonly bounds: { from: number; to: number },
  ) {
    this.t = start;
    this.check(start);
  }

  private check(ms: number): void {
    if (ms < this.bounds.from || ms > this.bounds.to) {
      throw new Error(`${this.key}: ${iso(ms)} is outside the seeded history; adjust SEED_FROM or run later.`);
    }
  }

  at(ms: number): Date {
    this.t = Math.max(this.t + 1000, ms);
    this.check(this.t);
    return new Date(this.t);
  }

  get stamp(): string {
    return iso(this.t);
  }
}

interface Report {
  title: string;
  diagnosis: string;
  comments: string;
  answers: Record<string, string>;
  isCritical?: boolean;
}

interface TemplateFile {
  templateKey: string;
  sections: { sectionKey: string; questions: { questionKey: string; required: boolean }[] }[];
}

const TEMPLATES = JSON.parse(readFileSync(join(DATA_DIR, 'report_templates.json'), 'utf8')) as TemplateFile[];

function responsesFor(templateKey: string, answers: Record<string, string>): Record<string, unknown>[] {
  const template = TEMPLATES.find((t) => t.templateKey === templateKey);
  if (!template) throw new Error(`no template ${templateKey}`);
  const out: Record<string, unknown>[] = [];
  for (const section of template.sections) {
    for (const question of section.questions) {
      const answer = answers[question.questionKey];
      if (answer !== undefined) out.push({ section: section.sectionKey, question: question.questionKey, answer, order: out.length });
    }
  }
  const missing = requiredQuestions(templateKey).filter((q) => !out.some((r) => r.question === q));
  if (missing.length > 0) throw new Error(`report answers lack ${missing.join(', ')}`);
  return out;
}

const EXPLANATION = {
  en: {
    summary:
      'The sample from your breast shows a cancer called invasive ductal carcinoma. It started in the milk ducts and has grown into the tissue around them.',
    meaning:
      'The cells look moderately different from normal breast cells, which doctors call grade 2. This is a serious finding, and it can be treated.',
    next: 'Your doctor will go through the treatment choices with you and arrange the tests that decide them.',
  },
  sw: {
    summary:
      'Sampuli kutoka titi lako inaonyesha saratani inayoitwa invasive ductal carcinoma. Ilianzia kwenye mirija ya maziwa na imekua kwenye tishu zinazoizunguka.',
    meaning:
      'Seli zinaonekana tofauti kiasi na seli za kawaida za titi, hali ambayo madaktari huiita daraja la 2. Hili ni jambo zito, na linaweza kutibiwa.',
    next: 'Daktari wako atakueleza chaguo za matibabu na kupanga vipimo vitakavyoamua chaguo hizo.',
  },
} as const;

const noTopics = { send: (): Promise<string> => Promise.resolve('demo-seed') };

export async function seedCases(ctx: SeedCtx): Promise<SeedResult> {
  const { db, bucket, people, tag } = ctx;
  const { doctor, pathologist, patient, patientId } = people;
  const E = ctx.now.getTime();
  const F = ctx.from.getTime();
  const bounds = { from: F, to: E };
  const log = ctx.log ?? ((): void => undefined);
  const manifest = loadManifest();
  const mpp = manifest.histology.source.micronsPerPixel;
  const result: SeedResult = { cases: {}, created: [], skipped: [] };

  const doctorDoc = (await db.collection('doctors').doc(doctor.uid).get()).data() ?? {};
  const hours = availabilityOf(doctorDoc, ctx.now);
  const taken = new Set<number>();
  const slotBefore = (ms: number): number => allSlots(hours, taken, ms, -1);
  const slotAfter = (ms: number): number => allSlots(hours, taken, ms, 1);

  const caseDeps = (r: Run, ...on: string[]): Deps => ({
    db,
    bucket,
    now: () => new Date(r.t),
    config: switches(...on),
    shareCodeKey: ctx.shareCodeKey,
    synthetic: true,
  });
  const runtimeDeps = (r: Run): RuntimeDeps => ({ db, bucket, now: () => new Date(r.t) });
  const alertDeps = (ms: number): AlertDeps => ({
    db,
    now: new Date(ms),
    config: switches('alerts_delivery_enabled'),
    synthetic: true,
    topics: noTopics as AlertDeps['topics'],
  });

  const caseRef = (caseUid: string) => db.collection('cases').doc(caseUid);
  const w = (ms: number): number => nextWork(ms, E - MIN);
  const acceptAfter = (r: Run, gap: number): number => nextWork(r.t + gap, Math.min(E - MIN, r.t + 22 * HOUR));
  // A request answered within 24 hours stays open, so a waiting case is not moved back past that.
  const recent = (ms: number): number => (E - prevWork(ms) > 22 * HOUR ? ms : prevWork(ms));

  // --- Appointments --------------------------------------------------------------------------

  async function viaAppointment<T>(r: Run, uid: string, act: (d: RuntimeDeps) => Promise<T>): Promise<T> {
    const ref = db.collection('appointments').doc(uid);
    const before = (await ref.get()).data();
    const out = await act(runtimeDeps(r));
    await onAppointmentWrittenHandler(runtimeDeps(r), uid, before, (await ref.get()).data());
    return out;
  }

  const request = (r: Run, uid: string, slot: number, symptomText: string): Promise<unknown> =>
    viaAppointment(r, uid, (d) =>
      requestAppointmentHandler(d, patient, {
        appointmentUid: uid,
        type: 'Consultation',
        doctorUid: doctor.uid,
        symptomText,
        scheduledStart: iso(slot),
      }),
    );

  const respond = (r: Run, uid: string): Promise<unknown> =>
    viaAppointment(r, uid, (d) => respondToAppointmentHandler(d, doctor, { appointmentUid: uid, decision: 'Accept' }));

  const finishVisit = (r: Run, uid: string): Promise<unknown> =>
    viaAppointment(r, uid, (d) => completeAppointmentHandler(d, doctor, { appointmentUid: uid, outcome: 'Completed' }));

  // --- A case up to its order ------------------------------------------------------------------

  interface Order {
    key: string;
    tests: string[];
    priority: 'Routine' | 'Priority' | 'Urgent';
    notes: string;
    symptoms: string;
    orderAt: number;
    requestPathologist: boolean;
    payment?: Record<string, unknown>;
    sampleNotes?: string;
  }

  async function open(spec: Order): Promise<Run | null> {
    const caseUid = uidFor(tag, `case:${spec.key}`);
    result.cases[spec.key] = caseUid;
    const existing = (await caseRef(caseUid).get()).data();
    if (existing) {
      log(`${spec.key}: exists at ${String(existing.currentStage)}, skipped`);
      result.skipped.push(spec.key);
      return null;
    }
    let slot = slotBefore(spec.orderAt - 25 * MIN);
    if (slot < F + 4 * HOUR) slot = slotAfter(F + 4 * HOUR);
    const appointmentUid = uidFor(tag, `appointment:${spec.key}`);
    const r = new Run(spec.key, slot - 3 * HOUR, caseUid, appointmentUid, bounds);
    try {
      await request(r, appointmentUid, slot, spec.symptoms);
    } catch (e) {
      if ((e as Error).message !== 'tooManyPending') throw e;
      throw new Error('A visit request from the demo patient is still waiting for the doctor. Let it expire or answer it, then run again.');
    }
    r.at(slot - 3 * HOUR + 45 * MIN);
    await respond(r, appointmentUid);

    const completeAt = slot + 35 * MIN;
    const orderAt = Math.max(spec.orderAt, slot + 25 * MIN);
    const placeOrder = async (): Promise<void> => {
      r.at(orderAt);
      const deps = caseDeps(r);
      await createOrderHandler(deps, doctor, {
        caseUid,
        appointmentUid,
        patientId,
        labTestIds: spec.tests,
        priority: spec.priority,
        sampleCollectedAt: iso(orderAt - 15 * MIN),
        payment: spec.payment ?? { method: 'Cash' },
        clinicalNotes: spec.notes,
        sampleNotes: spec.sampleNotes ?? '',
        ...(spec.requestPathologist ? { pathologistUid: pathologist.uid } : {}),
      });
      await onCaseWrittenHandler(deps, caseUid, undefined, (await caseRef(caseUid).get()).data());
    };
    const complete = async (): Promise<void> => {
      r.at(completeAt);
      await finishVisit(r, appointmentUid);
    };
    if (orderAt >= completeAt) {
      await complete();
      await placeOrder();
    } else {
      await placeOrder();
      await complete();
    }
    result.created.push(spec.key);
    return r;
  }

  // --- Case steps ------------------------------------------------------------------------------

  async function addSlide(r: Run, bytes: Buffer, contentType: 'image/jpeg' | 'image/png', micronsPerPixel: number): Promise<string> {
    const deps = caseDeps(r);
    const { imageUids } = await reserveSlideUploadsHandler(deps, doctor, { caseUid: r.caseUid, count: 1 });
    const imageUid = imageUids[0];
    await saveObject(bucket, `slides/${r.caseUid}/${imageUid}.${contentType === 'image/png' ? 'png' : 'jpg'}`, bytes, contentType);
    await registerSlidesHandler(deps, doctor, { caseUid: r.caseUid, images: [{ imageUid, contentType, micronsPerPixel }] });
    return imageUid;
  }

  const accept = (r: Run, preread: boolean): Promise<unknown> =>
    acceptCaseHandler(caseDeps(r, ...(preread ? ['preread_enabled'] : [])), pathologist, { caseUid: r.caseUid });

  const receive = async (r: Run, accession: string): Promise<void> => {
    await recordSampleReceivedHandler(caseDeps(r), pathologist, { caseUid: r.caseUid, labAccessionNo: accession });
  };

  const put = (path: string, bytes: Buffer, contentType: string): Promise<void> => saveObject(bucket, path, bytes, contentType);

  interface Stored {
    runUid: string;
    tiles: Tile[];
    measurements: Record<string, number>;
    draft: PrereadDraft;
  }

  /**
   * Completes the queued run with a stored example. Transaction wins over the live worker: it
   * accepts Queued or Running and writes Ready with provenance; the worker's guarded write then
   * does nothing (bundle 59).
   */
  async function storePreread(
    r: Run,
    labels: { tiles: Tile[]; width: number; height: number; tilePx: number; positive: string; grid: unknown; measurements: Record<string, number>; draft: PrereadDraft },
  ): Promise<Stored> {
    const runs = await caseRef(r.caseUid).collection('preread').get();
    const runRef = runs.docs[0].ref;
    const runUid = runRef.id;
    const folder = `preread/${r.caseUid}/${runUid}`;
    await put(
      `${folder}/labels.json`,
      Buffer.from(JSON.stringify({ labels: labels.tiles, grid: labels.grid, note: PROVENANCE })),
      'application/json',
    );
    await put(
      `${folder}/heatmap.png`,
      heatmapPng(labels.tiles, labels.width, labels.height, labels.tilePx, labels.positive),
      'image/png',
    );
    const counts: Record<string, number> = {};
    for (const t of labels.tiles) counts[t.label] = (counts[t.label] ?? 0) + 1;
    r.at(r.t + 6 * MIN);
    const readyFields = {
      status: 'Ready',
      segmentationPath: `${folder}/heatmap.png`,
      labelsPath: `${folder}/labels.json`,
      labelCounts: counts,
      measurements: labels.measurements,
      draft: labels.draft,
      models: { provenance: PROVENANCE },
      inputLanguage: 'en',
      failureReason: '',
      startedAt: iso(r.t - 4 * MIN),
      readyAt: r.stamp,
      lastUpdatedAt: r.stamp,
    };
    await runRef.firestore.runTransaction(async (tx) => {
      const snap = await tx.get(runRef);
      if (!snap.exists) return;
      const status = String(snap.get('status') ?? '');
      if (status !== 'Queued' && status !== 'Running') return;
      tx.update(runRef, readyFields);
    });
    await onPrereadWrittenHandler(caseDeps(r), r.caseUid, runUid);
    return { runUid, tiles: labels.tiles, measurements: labels.measurements, draft: labels.draft };
  }

  async function histologyPreread(r: Run, slide: 'hero' | 'uncertain' | 'queued', certainty: Certainty, imageUid: string): Promise<Stored> {
    const spec = manifest.histology.slides[slide];
    const tiles = histologyTiles(spec, imageUid, `${tag}:${r.key}`, certainty);
    const measurements = histologyMeasurements(tiles, spec, mpp);
    return storePreread(r, {
      tiles,
      width: spec.cols * spec.tilePx,
      height: spec.rows * spec.tilePx,
      tilePx: spec.tilePx,
      positive: 'Tumour',
      grid: { rows: spec.rows, cols: spec.cols, tilePx: spec.tilePx, micronsPerPixel: mpp },
      measurements,
      draft: histologyDraft(tiles, measurements),
    });
  }

  async function score(r: Run, runUid: string, overall: number, comment: string): Promise<void> {
    await scorePrereadHandler(caseDeps(r), pathologist, {
      caseUid: r.caseUid,
      runUid,
      findingsVerdict: 'Agree',
      impressionVerdict: 'Agree',
      urgencyVerdict: 'Agree',
      measurementsVerdict: 'Accepted',
      segmentationVerdict: 'Good',
      overall,
      comment,
      prereadShownAt: iso(r.t - 10 * MIN),
    });
  }

  const draftRef = (r: Run) => caseRef(r.caseUid).collection('reportDrafts').doc(pathologist.uid);

  async function startDraft(r: Run): Promise<void> {
    await startReportHandler(caseDeps(r), pathologist, { caseUid: r.caseUid, kind: 'Initial' });
  }

  async function fillDraft(r: Run, templateKey: string, report: Report, extra: Record<string, unknown> = {}): Promise<string> {
    await draftRef(r).update({
      title: report.title,
      diagnosis: report.diagnosis,
      comments: report.comments,
      responses: responsesFor(templateKey, report.answers),
      isCritical: report.isCritical === true,
      diagnosisStartedAt: iso(r.t - 20 * MIN),
      lastUpdatedAt: r.stamp,
      ...extra,
    });
    return r.stamp;
  }

  async function sign(r: Run, stamp: string): Promise<string> {
    const deps = caseDeps(r);
    const out = await signReportHandler(deps, pathologist, {
      caseUid: r.caseUid,
      draftLastUpdatedAt: stamp,
      signaturePng: signaturePng().toString('base64'),
    });
    await onReportCreatedHandler(deps, r.caseUid, out.reportUid);
    return out.reportUid;
  }

  /** The doctor types the code from the inbox row, as the app does. */
  async function unlock(r: Run, reportUid: string): Promise<void> {
    const row = await db.doc(`notifications/reportSigned:${r.caseUid}_${reportUid}:${doctor.uid}`).get();
    const code = (row.data()?.metadata as { shareCode?: string } | undefined)?.shareCode;
    if (!code) throw new Error(`${r.key}: no unlock code in the doctor's inbox`);
    await redeemShareCodeHandler(caseDeps(r), doctor, { shareUid: `unlock_${r.caseUid}_${reportUid}`, code });
  }

  const slideFor = (key: string) => manifest.histology.slides[key];

  // --- The cases, oldest first -----------------------------------------------------------------

  // Case 11: an older case, completed.
  {
    const r = await open({
      key: 'completed',
      tests: [SKIN_PUNCH],
      priority: 'Routine',
      notes: 'Itchy, scaly patch on the left forearm for four months, not settling with a topical steroid.',
      symptoms: 'I have had an itchy, scaly patch on my left forearm for four months and the cream is not helping.',
      orderAt: F + 8 * HOUR,
      requestPathologist: true,
    });
    if (r) {
      r.at(acceptAfter(r, 2 * HOUR));
      await accept(r, false);
      r.at(w(r.t + 20 * HOUR));
      await receive(r, 'NH/26/0101');
      r.at(w(r.t + 3 * HOUR));
      await startDraft(r);
      r.at(w(r.t + 2 * HOUR));
      const stamp = await fillDraft(r, 'General', {
        title: 'Skin punch biopsy, left forearm',
        diagnosis: 'Chronic spongiotic dermatitis. No fungal elements or malignancy seen.',
        comments: 'Clinicopathological correlation advised.',
        answers: {
          findings: 'The epidermis shows spongiosis with a mild superficial perivascular lymphocytic infiltrate. The PAS stain is negative.',
        },
      });
      r.at(w(r.t + 30 * MIN));
      const reportUid = await sign(r, stamp);
      r.at(w(r.t + 3 * HOUR));
      await unlock(r, reportUid);
      r.at(w(r.t + 9 * HOUR));
      await markDiscussedHandler(caseDeps(r), doctor, { caseUid: r.caseUid, reportUid });
      r.at(w(r.t + 6 * HOUR));
      await completeCaseHandler(caseDeps(r), doctor, { caseUid: r.caseUid });
    }
  }

  // Case 1: signed, discussed, the explanation approved.
  {
    const signAt = nextWork(Math.max(F + 34 * HOUR, E - 7 * DAY), E);
    const r = await open({
      key: 'explained',
      tests: [HISTOLOGY],
      priority: 'Priority',
      notes: 'Painless, firm lump in the right breast for about three months, 2.5 cm on examination, no nipple discharge. Core biopsy taken.',
      symptoms: 'I found a hard lump in my right breast about three months ago and it has not gone away.',
      orderAt: prevWork(signAt - 26 * HOUR),
      requestPathologist: true,
      payment: { method: 'Insurance', insurerId: 'sha', policyNumber: 'SHA-2026-1043' },
    });
    if (r) {
      r.at(acceptAfter(r, 2 * HOUR));
      await accept(r, false);
      r.at(w(r.t + 19 * HOUR));
      await receive(r, 'NH/26/0102');
      r.at(w(r.t + 3 * HOUR));
      await startDraft(r);
      r.at(w(r.t + 90 * MIN));
      const stamp = await fillDraft(r, 'Cancer', {
        title: 'Right breast core biopsy',
        diagnosis: 'Invasive ductal carcinoma, grade 2 (Nottingham score 6 of 9).',
        comments: 'Receptor status is requested on this block. Suggest discussion at the breast multidisciplinary meeting.',
        answers: {
          specimenDescription: 'Four cores of tan-white tissue, each 10 to 16 mm long.',
          microscopicDescription:
            'Infiltrating nests and cords of atypical cells with moderate pleomorphism and tubule formation. Ductal carcinoma in situ is not seen.',
          tumourGrade: 'Grade 2',
          margins: 'Not assessable on core biopsy',
          lymphNodes: 'Not sampled',
          immunohistochemistry: 'Requested',
        },
      });
      r.at(w(signAt));
      const reportUid = await sign(r, stamp);
      r.at(w(r.t + 3 * HOUR));
      await unlock(r, reportUid);

      // The patient asks to discuss it; the doctor accepts, meets her, then releases the result.
      const discussion = uidFor(tag, 'appointment:explained-discussion');
      const slot = slotAfter(r.t + 20 * HOUR);
      r.at(w(r.t + 90 * MIN));
      await viaAppointment(r, discussion, (d) =>
        requestAppointmentHandler(d, patient, {
          appointmentUid: discussion,
          type: 'CaseDiscussion',
          caseUid: r.caseUid,
          scheduledStart: iso(slot),
        }),
      );
      r.at(r.t + 40 * MIN);
      await respond(r, discussion);
      r.at(slot + 40 * MIN);
      await finishVisit(r, discussion);
      r.at(r.t + 10 * MIN);
      const deps = caseDeps(r, 'patient_explanations_enabled');
      await markDiscussedHandler(deps, doctor, { caseUid: r.caseUid, reportUid });

      r.at(r.t + 6 * MIN);
      for (const language of ['en', 'sw'] as const) {
        const id = `${reportUid}_Explanation_${language}`;
        await caseRef(r.caseUid).collection('reportTexts').doc(id).update({
          status: 'Ready',
          machineText: EXPLANATION[language],
          models: { provenance: PROVENANCE },
          detectedSourceLanguage: 'en',
          readyAt: r.stamp,
          lastUpdatedAt: r.stamp,
        });
        await onReportTextWrittenHandler(deps, r.caseUid, id);
      }
      r.at(r.t + 25 * MIN);
      for (const language of ['en', 'sw'] as const) {
        await approveReportTextHandler(deps, doctor, {
          caseUid: r.caseUid,
          textUid: `${reportUid}_Explanation_${language}`,
          decision: 'Approve',
        });
      }
    }
  }

  // Case 10: an order cancelled by the doctor.
  {
    const r = await open({
      key: 'cancelled',
      tests: [PAP_SMEAR],
      priority: 'Routine',
      notes: 'Routine screening smear.',
      symptoms: 'I would like my routine cervical screening done.',
      orderAt: prevWork(E - 5 * DAY),
      requestPathologist: true,
    });
    if (r) {
      r.at(w(r.t + 3 * HOUR));
      await cancelOrderHandler(caseDeps(r), doctor, { caseUid: r.caseUid, reasonCode: 'OrderedInError' });
    }
  }

  // Case 2: signed, the doctor holds the unlock code and has not opened the report.
  {
    const [orderAt, acceptAt, receiveAt, startAt, draftAt, signAt] = withOpenRequest(backFrom(E - 50 * HOUR, [
      30 * MIN,
      90 * MIN,
      3 * HOUR,
      19 * HOUR,
      2 * HOUR,
    ]));
    const r = await open({
      key: 'signed',
      tests: [HISTOLOGY],
      priority: 'Priority',
      notes: 'Abnormal Pap smear with high-grade changes. Cervical punch biopsies taken at colposcopy.',
      symptoms: 'My Pap smear result was abnormal and I was told to have a biopsy.',
      orderAt,
      requestPathologist: true,
    });
    if (r) {
      r.at(acceptAt);
      await accept(r, false);
      r.at(receiveAt);
      await receive(r, 'NH/26/0103');
      r.at(startAt);
      await startDraft(r);
      r.at(draftAt);
      const stamp = await fillDraft(r, 'Cancer', {
        title: 'Cervical punch biopsies',
        diagnosis: 'High-grade squamous intraepithelial lesion (CIN 2). No invasive carcinoma seen.',
        comments: 'Margins cannot be assessed on punch biopsies.',
        answers: {
          specimenDescription: 'Two fragments of pale tissue, 3 and 4 mm.',
          microscopicDescription:
            'The surface squamous epithelium shows disordered maturation with atypical cells in the lower two thirds. The stroma is not invaded.',
          tumourGrade: 'Not applicable',
          margins: 'Not assessable',
        },
      });
      r.at(signAt);
      await sign(r, stamp);
    }
  }

  // Case 4: pre-read ready, low confidence.
  {
    const [orderAt, acceptAt, receiveAt] = withOpenRequest(backFrom(E - 30 * HOUR, [5 * HOUR, 3 * HOUR]));
    const r = await open({
      key: 'lowConfidence',
      tests: [HISTOLOGY],
      priority: 'Routine',
      notes: 'Left neck lymph node, 2 cm, firm and painless for six weeks. Excision biopsy. Night sweats reported.',
      symptoms: 'I have a swelling on the left side of my neck for six weeks and I sweat at night.',
      orderAt,
      requestPathologist: true,
    });
    if (r) {
      r.at(r.t + 10 * MIN);
      const imageUid = await addSlide(r, slideBytes(slideFor('uncertain')), 'image/jpeg', mpp);
      r.at(acceptAt);
      await accept(r, true);
      await histologyPreread(r, 'uncertain', 'uncertain', imageUid);
      r.at(receiveAt);
      await receive(r, 'NH/26/0104');
    }
  }

  // Case 9: a test with no slides, the report started.
  {
    const [orderAt, acceptAt, receiveAt, startAt, touchedAt] = withOpenRequest(backFrom(E - 26 * HOUR, [
      40 * MIN,
      HOUR,
      20 * HOUR,
      2 * HOUR,
    ]));
    const r = await open({
      key: 'blood',
      tests: [FULL_HAEMOGRAM],
      priority: 'Routine',
      notes: 'Tiredness and pallor for three weeks with heavy periods. No fever.',
      symptoms: 'I have felt very tired and pale for three weeks and my periods are heavy.',
      orderAt,
      requestPathologist: true,
    });
    if (r) {
      r.at(acceptAt);
      await accept(r, false);
      r.at(receiveAt);
      await receive(r, 'NH/26/0105');
      r.at(startAt);
      await startDraft(r);
      r.at(touchedAt);
      await draftRef(r).update({ title: 'Full haemogram', lastUpdatedAt: r.stamp });
    }
  }

  // Case 3: the hero case, a pre-read waiting for the pathologist.
  {
    const [orderAt, acceptAt, receiveAt] = withOpenRequest(backFrom(E - 2 * HOUR, [3 * HOUR, 2 * HOUR]));
    const r = await open({
      key: 'hero',
      tests: [HISTOLOGY],
      priority: 'Urgent',
      notes: 'Left axillary sentinel lymph node removed during mastectomy for invasive breast cancer.',
      symptoms: 'I am booked for breast surgery and my doctor says a lymph node needs to be checked.',
      orderAt,
      requestPathologist: true,
    });
    if (r) {
      r.at(r.t + 10 * MIN);
      const imageUid = await addSlide(r, slideBytes(slideFor('hero')), 'image/jpeg', mpp);
      r.at(acceptAt);
      await accept(r, true);
      await histologyPreread(r, 'hero', 'clear', imageUid);
      r.at(receiveAt);
      await receive(r, 'NH/26/0106');
    }
  }

  // Case 7: accepted, the sample not yet received.
  {
    const [orderAt, acceptAt] = withOpenRequest(backFrom(E - 4 * HOUR, [3 * HOUR]));
    const r = await open({
      key: 'accepted',
      tests: [CYTOPATHOLOGY],
      priority: 'Routine',
      notes: 'Right thyroid nodule, 2 cm, found on ultrasound. Fine needle aspirate taken, smears fixed.',
      symptoms: 'My doctor found a lump in my neck on a scan and I need a needle test.',
      orderAt,
      requestPathologist: true,
    });
    if (r) {
      r.at(acceptAt);
      await accept(r, false);
    }
  }

  // Case 8: the malaria smear, signed with a confirmed finding; with the week's other reports it tips the detector.
  {
    const week = weekStartOf(E);
    if (E - week < 40 * MIN) throw new Error('Run the seed more than 40 minutes into the Nairobi week.');
    const earliest = Math.min(Math.max(E - 6 * HOUR, week + 30 * MIN), E - 2 * MIN);
    const inHours = prevWork(earliest);
    const signAt = inHours >= week + 10 * MIN ? inHours : earliest;
    const [orderAt, acceptAt, receiveAt, scoreAt, startAt, draftAt] = withOpenRequest(backFrom(signAt - 12 * MIN, [
      10 * MIN,
      58 * MIN,
      20 * HOUR,
      4 * HOUR,
      2 * HOUR,
    ]));
    const r = await open({
      key: 'malaria',
      tests: [MALARIA_SMEAR],
      priority: 'Priority',
      notes: 'Fever and chills for three days with headache and vomiting twice. Visited a farm near Lake Victoria last week. Rapid test positive at the dispensary.',
      symptoms: 'I have had fever and chills for three days, with a headache, and I vomited twice.',
      orderAt,
      requestPathologist: true,
    });
    if (r) {
      const field = manifest.malaria;
      const png = composeCells(field, await (ctx.cells ?? fetchCells)(field));
      r.at(r.t + 15 * MIN);
      const imageUid = await addSlide(r, png, 'image/png', field.micronsPerPixel);
      r.at(acceptAt);
      await accept(r, true);
      const tiles = malariaTiles(field, imageUid, `${tag}:${r.key}`);
      const measurements = malariaMeasurements(tiles);
      const stored = await storePreread(r, {
        tiles,
        width: field.cols * field.cellPx,
        height: field.rows * field.cellPx,
        tilePx: field.cellPx,
        positive: 'Parasitized',
        grid: { rows: field.rows, cols: field.cols, tilePx: field.cellPx, micronsPerPixel: field.micronsPerPixel },
        measurements,
        draft: malariaDraft(tiles, measurements),
      });
      r.at(receiveAt);
      await receive(r, 'NH/26/0107');
      r.at(scoreAt);
      await score(r, stored.runUid, 4, 'The count matches my own review of the field.');
      r.at(startAt);
      await startDraft(r);
      r.at(draftAt);
      const p = measurements.parasitaemiaPercent;
      const stamp = await fillDraft(
        r,
        'Malaria',
        {
          title: 'Thin blood smear for malaria parasites',
          diagnosis: `Plasmodium falciparum malaria, parasitaemia ${p}%.`,
          comments: 'The count was taken from the digitised field and checked against the smear.',
          answers: {
            parasiteSpecies: 'Plasmodium falciparum',
            parasiteDensity: `${p}% of red cells parasitised (${measurements.parasitizedCells} of ${measurements.cellsCounted} cells counted)`,
            parasiteStages: 'Ring forms and trophozoites',
          },
        },
        {
          startedFromPreread: true,
          notifiableFindings: [{ diseaseId: 'malaria', alertRequested: false }],
        },
      );

      // The week's other confirmed malaria in Nairobi, as other facilities would report it: events only.
      const county = countyIdByName('Nairobi') ?? 47;
      const bands = ['5-14', '15-24', '25-44', '45-64'];
      for (let i = 1; i <= bands.length; i++) {
        const eventUid = uidFor(tag, `event:malaria:${i}`);
        const ref = db.collection('notifiableEvents').doc(eventUid);
        if ((await ref.get()).exists) continue;
        const spread = week + Math.round(((signAt - week) * i) / (bands.length + 1));
        const placed = prevWork(spread);
        const at = placed >= week ? placed : spread;
        await ref.set(
          notifiableEventFor({
            uid: eventUid,
            diseaseId: 'malaria',
            countyId: county,
            date: nairobiDate(new Date(at)),
            epiWeek: nairobiEpiWeek(new Date(at)),
            ageBand: bands[i - 1],
            category: 'Weekly',
            alertRequested: false,
            synthetic: true,
            at: iso(at),
          }),
        );
        await onNotifiableEventWrittenHandler(alertDeps(at), eventUid, { before: undefined, after: (await ref.get()).data() });
      }

      r.at(signAt);
      await sign(r, stamp);
      const link = (await db.doc(`notifiableEventLinks/${r.caseUid}_malaria`).get()).data();
      const eventUid = String(link?.eventUid ?? '');
      const event = (await db.collection('notifiableEvents').doc(eventUid).get()).data();
      await onNotifiableEventWrittenHandler(alertDeps(r.t), eventUid, { before: undefined, after: event });
      const alertUid = signalUidFor('malaria', county, String(event?.epiWeek));
      const alert = (await db.collection('alerts').doc(alertUid).get()).data();
      if (alert) await onAlertWrittenHandler(alertDeps(r.t + MIN), alertUid, { before: undefined, after: alert });
    }
  }

  // Case 6: an urgent request waiting for the pathologist to accept.
  {
    await open({
      key: 'requested',
      tests: [HISTOLOGY],
      priority: 'Urgent',
      notes: 'Rectal bleeding for two months and weight loss of 6 kg. Colonoscopy shows an ulcerated mass at 8 cm. Biopsies taken.',
      symptoms: 'I have been bleeding when I pass stool for two months and I am losing weight.',
      orderAt: recent(E - 3 * HOUR),
      requestPathologist: true,
    });
  }

  // Case 5: slides in and the pre-read queued, for as long as the stale-run sweep allows.
  {
    const r = await open({
      key: 'queued',
      tests: [HISTOLOGY],
      priority: 'Routine',
      notes: 'Right inguinal lymph node excised after one month of swelling. No known primary.',
      symptoms: 'I have had a swelling in my right groin for a month.',
      orderAt: recent(E - 4 * HOUR),
      requestPathologist: true,
    });
    if (r) {
      r.at(r.t + 15 * MIN);
      await addSlide(r, slideBytes(slideFor('queued')), 'image/jpeg', mpp);
      r.at(E - 2 * MIN);
      await accept(r, true);
    }
  }

  // Appointments that belong to no case: one upcoming, one waiting for the doctor, one cancelled.
  async function standalone(key: string, requestAt: number, slotFrom: number, symptoms: string, then: 'accept' | 'wait' | 'cancel'): Promise<void> {
    const uid = uidFor(tag, `appointment:${key}`);
    if ((await db.collection('appointments').doc(uid).get()).exists) {
      result.skipped.push(key);
      return;
    }
    const r = new Run(key, requestAt, '', uid, bounds);
    try {
      await request(r, uid, slotAfter(slotFrom), symptoms);
    } catch (e) {
      // The doctor already has an open request from this patient, e.g. from an earlier set.
      if ((e as Error).message !== 'tooManyPending') throw e;
      log(`${key}: skipped, a request is already waiting`);
      result.skipped.push(key);
      return;
    }
    if (then === 'accept') {
      r.at(r.t + HOUR);
      await respond(r, uid);
    }
    if (then === 'cancel') {
      r.at(r.t + 3 * HOUR);
      await viaAppointment(r, uid, (d) => cancelAppointmentHandler(d, patient, { appointmentUid: uid, cancelNote: 'I can no longer make it.' }));
    }
    result.created.push(key);
  }
  await standalone('visit-cancelled', E - 72 * HOUR, E - 60 * HOUR, 'Routine check-up and a blood pressure review.', 'cancel');
  await standalone('visit-upcoming', E - 6 * HOUR, E + 14 * HOUR, 'A follow-up visit to talk about how I am recovering.', 'accept');
  await standalone('visit-pending', E - 2 * HOUR, E + 40 * HOUR, 'A cough that has lasted two weeks, and I would like to be checked.', 'wait');

  // The measles alert, approved and delivered, so the patient has a health notice to read.
  {
    const eventUid = uidFor(tag, 'event:measles');
    const ref = db.collection('notifiableEvents').doc(eventUid);
    if (!(await ref.get()).exists) {
      const county = countyIdByName('Nairobi') ?? 47;
      const at = E - 12 * HOUR;
      await ref.set(
        notifiableEventFor({
          uid: eventUid,
          diseaseId: 'measles',
          countyId: county,
          date: nairobiDate(new Date(at)),
          epiWeek: nairobiEpiWeek(new Date(at)),
          ageBand: '5-14',
          category: 'Immediate',
          alertRequested: false,
          synthetic: true,
          at: iso(at),
        }),
      );
      await onNotifiableEventWrittenHandler(alertDeps(at), eventUid, { before: undefined, after: (await ref.get()).data() });
      const alertUid = signalUidFor('measles', county, nairobiEpiWeek(new Date(at)));
      const alertRef = db.collection('alerts').doc(alertUid);
      await onAlertWrittenHandler(alertDeps(at + MIN), alertUid, { before: undefined, after: (await alertRef.get()).data() });
      const draft = (await alertRef.get()).data();
      if (draft?.status === 'Draft') {
        const decidedAt = at + 30 * MIN;
        await approveAlertHandler(alertDeps(decidedAt), doctor, {
          alertUid,
          decision: 'Approve',
          draftRevision: draft.draftRevision,
          evidenceRevision: draft.evidenceRevision,
        });
        await onAlertWrittenHandler(alertDeps(decidedAt + MIN), alertUid, { before: draft, after: (await alertRef.get()).data() });
      }
      result.created.push('measles-alert');
    }
  }

  return result;
}

// --- Running it ---------------------------------------------------------------------------------

async function shareKeyFromSecretManager(): Promise<string> {
  const token = await getApp().options.credential?.getAccessToken();
  if (!token) throw new Error('No Application Default Credentials: run gcloud auth application-default login.');
  const res = await fetch(`https://secretmanager.googleapis.com/v1/projects/${PROJECT}/secrets/SHARE_CODE_KEY/versions/latest:access`, {
    headers: { Authorization: `Bearer ${token.access_token}` },
  });
  if (!res.ok) {
    throw new Error(`Reading the SHARE_CODE_KEY secret failed (${res.status}); the unlock codes need the key the functions use.`);
  }
  const body = (await res.json()) as { payload?: { data?: string } };
  if (!body.payload?.data) throw new Error('The SHARE_CODE_KEY secret has no value.');
  return Buffer.from(body.payload.data, 'base64').toString('utf8');
}

async function person(email: string, role: string): Promise<Caller> {
  const record = await getAuth()
    .getUserByEmail(email)
    .catch(() => undefined);
  const claims = record?.customClaims ?? {};
  if (!record || claims.seeded !== true || claims.role !== role) {
    throw new Error(`${email} is not the seeded ${role}; run make seed-live first.`);
  }
  return { uid: record.uid, email, emailVerified: true, role, isAdmin: claims.admin === true };
}

export async function findPeople(db: Firestore, email: (role: string) => string): Promise<People> {
  const patient = await person(email('patient'), 'patient');
  const record = await buildQuery(db, queryById('patients.byUid'), [patient.uid]).limit(1).get();
  if (record.empty) throw new Error('The demo patient has no record; run make seed-live first.');
  return {
    doctor: await person(email('doctor'), 'doctor'),
    pathologist: await person(email('pathologist'), 'pathologist'),
    patient,
    patientId: record.docs[0].id,
  };
}

export function seedStart(): Date {
  const text = process.env.SEED_FROM || '2026-10-26';
  if (!/^\d{4}-\d{2}-\d{2}$/.test(text) || Number.isNaN(Date.parse(`${text}T00:00:00+03:00`))) {
    throw new Error('SEED_FROM must be a date such as 2026-10-26.');
  }
  return new Date(`${text}T00:00:00+03:00`);
}

async function main(): Promise<void> {
  const { live, email } = target();
  initializeApp({ projectId: PROJECT, storageBucket: `${PROJECT}.firebasestorage.app` });
  const db = getFirestore();
  const people = await findPeople(db, email);
  const result = await seedCases({
    db,
    bucket: getStorage().bucket().name,
    now: new Date(),
    from: seedStart(),
    tag: process.env.SEED_CASES_TAG ?? '',
    shareCodeKey: live ? await shareKeyFromSecretManager() : randomBytes(32).toString('hex'),
    people,
    log: console.log,
  });
  console.log(
    `Seeded ${live ? PROJECT : 'the emulators'}: ${result.created.length} created, ${result.skipped.length} already there.`,
  );
}

if (require.main === module) {
  main().catch((e: Error) => {
    console.error(`Case seed failed: ${e.message}`);
    process.exit(1);
  });
}
