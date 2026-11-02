/**
 * The outbreak engine's reference data and pure detector helpers (07 §1.1, §3.2). Disease
 * rows come from `disease-data.ts`; this module adds the guidance bundle, the display
 * provenance the evidence snapshots, the county reverse map, and the Rule A/B/M detector.
 * Production loads `functions/data/*.json`; tests inject through the `*ForTest` hooks.
 * Unknown or corrupt rows fail closed (unusable for alerts), never half-loaded.
 */
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import { DATA_DIR } from './reference-data';

export interface AlertGuidanceBullet {
  bulletId: string;
  audience: 'Patient' | 'Clinician';
  textEn: string;
  textSw: string;
  swIsOfficial: boolean;
  sourceId: string;
}

export interface AlertGuidanceSource {
  sourceId: string;
  title: string;
  publisher: string;
  url: string;
}

export interface AlertGuidance {
  diseaseId: string;
  reviewedOn: string;
  bullets: AlertGuidanceBullet[];
  sources: AlertGuidanceSource[];
}

/** Display provenance the evidence snapshots; the detector itself reads `disease-data.ts`. */
export interface DiseaseMeta {
  categoryVerified: boolean;
  categorySourceId: string;
  /** Every `Confirms` test in the bundle row is verified. */
  mappingVerified: boolean;
}

function str(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

function bool(value: unknown): boolean {
  return value === true;
}

function ingestGuidance(rows: unknown): Map<string, AlertGuidance> {
  const out = new Map<string, AlertGuidance>();
  if (!Array.isArray(rows)) return out;
  for (const row of rows) {
    if (row === null || typeof row !== 'object') continue;
    const r = row as Record<string, unknown>;
    const diseaseId = str(r.diseaseId).trim();
    if (diseaseId === '') continue;
    const bullets = Array.isArray(r.bullets) ? r.bullets : [];
    const sources = Array.isArray(r.sources) ? r.sources : [];
    out.set(diseaseId, {
      diseaseId,
      reviewedOn: str(r.reviewedOn),
      bullets: bullets
        .filter((b): b is Record<string, unknown> => b !== null && typeof b === 'object')
        .map((b): AlertGuidanceBullet => ({
          bulletId: str(b.bulletId),
          audience: b.audience === 'Clinician' ? 'Clinician' : 'Patient',
          textEn: str(b.textEn),
          textSw: str(b.textSw),
          swIsOfficial: bool(b.swIsOfficial),
          sourceId: str(b.sourceId),
        }))
        .filter((b) => b.bulletId !== ''),
      sources: sources
        .filter((s): s is Record<string, unknown> => s !== null && typeof s === 'object')
        .map((s) => ({
          sourceId: str(s.sourceId),
          title: str(s.title),
          publisher: str(s.publisher),
          url: str(s.url),
        }))
        .filter((s) => s.sourceId !== ''),
    });
  }
  return out;
}

function ingestMeta(rows: unknown): Map<string, DiseaseMeta> {
  const out = new Map<string, DiseaseMeta>();
  if (!Array.isArray(rows)) return out;
  for (const row of rows) {
    if (row === null || typeof row !== 'object') continue;
    const r = row as Record<string, unknown>;
    const diseaseId = str(r.diseaseId).trim();
    if (diseaseId === '') continue;
    const labTests = Array.isArray(r.labTests) ? r.labTests : [];
    const confirming = labTests.filter(
      (t): t is Record<string, unknown> =>
        t !== null && typeof t === 'object' && str(t.strength) === 'Confirms',
    );
    out.set(diseaseId, {
      categoryVerified: bool(r.categoryVerified),
      categorySourceId: str(r.categorySourceId),
      mappingVerified: confirming.length > 0 && confirming.every((t) => bool(t.mappingVerified)),
    });
  }
  return out;
}

let guidance = new Map<string, AlertGuidance>();
let meta = new Map<string, DiseaseMeta>();

function loadFromDisk(): void {
  const guidancePath = join(DATA_DIR, 'public_health_guidance.json');
  guidance = existsSync(guidancePath)
    ? ingestGuidance(JSON.parse(readFileSync(guidancePath, 'utf8')) as unknown)
    : new Map();
  const diseasePath = join(DATA_DIR, 'notifiable_diseases.json');
  meta = existsSync(diseasePath)
    ? ingestMeta(JSON.parse(readFileSync(diseasePath, 'utf8')) as unknown)
    : new Map();
}

loadFromDisk();

/** Test-only: replace the guidance catalogue. */
export function setAlertGuidanceForTest(rows: AlertGuidance[]): void {
  guidance = new Map(rows.map((g) => [g.diseaseId, g]));
}

/** Test-only: reload the disk catalogues. */
export function resetAlertCatalogForTest(): void {
  loadFromDisk();
}

export function alertGuidanceById(diseaseId: string): AlertGuidance | undefined {
  return guidance.get(diseaseId);
}

export function diseaseMetaById(diseaseId: string): DiseaseMeta {
  return (
    meta.get(diseaseId) ?? { categoryVerified: false, categorySourceId: '', mappingVerified: false }
  );
}

let countyIdsByName: Map<string, number> | undefined;

/** The county id for a profile county name, or undefined when it is not a county. */
export function countyIdByName(name: string): number | undefined {
  if (!countyIdsByName) {
    countyIdsByName = new Map<string, number>();
    const path = join(DATA_DIR, 'counties.json');
    if (existsSync(path)) {
      const rows = JSON.parse(readFileSync(path, 'utf8')) as unknown;
      if (Array.isArray(rows)) {
        for (const row of rows) {
          if (row === null || typeof row !== 'object') continue;
          const r = row as Record<string, unknown>;
          if (typeof r.id === 'number' && typeof r.name === 'string' && r.name !== '') {
            countyIdsByName.set(r.name, r.id);
          }
        }
      }
    }
  }
  return countyIdsByName.get(name);
}

/** The Rule B baseline, recorded on every signal (07 §3.2). */
export const DETECTOR_CONFIG = { windowWeeks: 8, k: 2, floor: 5 } as const;

/** The wire values of 07 §2.1's `AlertRule`: A fires `Immediate`, B `Baseline`, M `Manual`. */
export type AlertRule = 'Immediate' | 'Baseline' | 'Manual';

export interface DetectionInput {
  category: string;
  /** This week's confirmed count. */
  count: number;
  /** The previous eight weeks' counts; a missing week counts as 0. */
  baseline: number[];
  manualRequests: number;
  allowManualAlert: boolean;
}

function meanSd(values: number[]): { mean: number; sd: number } {
  if (values.length === 0) return { mean: 0, sd: 0 };
  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const variance = values.reduce((a, b) => a + (b - mean) * (b - mean), 0) / values.length;
  return { mean, sd: Math.sqrt(variance) };
}

/**
 * The pure detector (07 §3.2): A fires on a single Immediate case, B above
 * `mean + k·sd` and the floor, M on a manual request when B does not fire.
 */
export function detect(input: DetectionInput): AlertRule | null {
  if (input.category === 'Immediate' && input.count >= 1) return 'Immediate';
  if (input.category === 'Weekly') {
    const { mean, sd } = meanSd(input.baseline);
    if (input.count > mean + DETECTOR_CONFIG.k * sd && input.count >= DETECTOR_CONFIG.floor) {
      return 'Baseline';
    }
    if (input.allowManualAlert && input.manualRequests >= 1) return 'Manual';
  }
  return null;
}

/** The Rule B statistics for the evidence snapshot. */
export function baselineStats(baseline: number[]): { mean: number; sd: number; threshold: number } {
  const { mean, sd } = meanSd(baseline);
  return { mean, sd, threshold: mean + DETECTOR_CONFIG.k * sd };
}

/** The ISO week (`YYYY-Www`) of a Nairobi calendar date. */
export function nairobiEpiWeek(now: Date): string {
  const eat = new Date(now.getTime() + 3 * 60 * 60 * 1000);
  const day = new Date(Date.UTC(eat.getUTCFullYear(), eat.getUTCMonth(), eat.getUTCDate()));
  // Thursday decides the ISO year; Monday starts the week.
  const isoDay = ((day.getUTCDay() + 6) % 7) + 1;
  const thursday = new Date(day.getTime() + (4 - isoDay) * 24 * 60 * 60 * 1000);
  const jan4 = new Date(Date.UTC(thursday.getUTCFullYear(), 0, 4));
  const jan4IsoDay = ((jan4.getUTCDay() + 6) % 7) + 1;
  const week1Monday = jan4.getTime() - (jan4IsoDay - 1) * 24 * 60 * 60 * 1000;
  const week = Math.round((thursday.getTime() - week1Monday) / (7 * 24 * 60 * 60 * 1000)) + 1;
  return `${thursday.getUTCFullYear()}-W${String(week).padStart(2, '0')}`;
}

/** The `n` epi weeks ending with `week`, newest first. */
export function epiWeeksBack(week: string, n: number): string[] {
  const match = /^(\d{4})-W(\d{2})$/.exec(week);
  if (!match) return [week];
  const monday = new Date(Date.UTC(Number(match[1]), 0, 4));
  monday.setUTCDate(
    monday.getUTCDate() - ((monday.getUTCDay() + 6) % 7) + (Number(match[2]) - 1) * 7,
  );
  const out: string[] = [];
  for (let i = 0; i < n; i++) {
    // Monday 00:00 UTC is Monday 03:00 in Nairobi: the same Nairobi date.
    out.push(nairobiEpiWeek(new Date(monday.getTime() - i * 7 * 24 * 60 * 60 * 1000)));
  }
  return out;
}

/** Monday (`YYYY-MM-DD`) of an epi week; a week that does not parse reads as ''. */
export function weekStartOf(week: string): string {
  const match = /^(\d{4})-W(\d{2})$/.exec(week);
  if (!match) return '';
  const monday = new Date(Date.UTC(Number(match[1]), 0, 4));
  monday.setUTCDate(monday.getUTCDate() - ((monday.getUTCDay() + 6) % 7) + (Number(match[2]) - 1) * 7);
  return monday.toISOString().slice(0, 10);
}

const AGE_BANDS: { max: number; band: string }[] = [
  { max: 4, band: '0-4' },
  { max: 14, band: '5-14' },
  { max: 24, band: '15-24' },
  { max: 44, band: '25-44' },
  { max: 64, band: '45-64' },
];

/** The event's age band; an unknown or negative age reads as the widest band. */
export function ageBandFor(ageYears: number): string {
  if (!Number.isFinite(ageYears) || ageYears < 0) return '65+';
  return AGE_BANDS.find((b) => ageYears <= b.max)?.band ?? '65+';
}
