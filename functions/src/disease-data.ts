/**
 * Bundled notifiable-disease names for public-alert push (S-3).
 * Tests inject via [setDiseasesForTest]; production loads
 * `functions/data/notifiable_diseases.json`.
 */
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import { DATA_DIR } from './reference-data';

export type TestStrength = 'Confirms' | 'Presumptive' | 'Supportive' | 'Uncertain';

export interface DiseaseNames {
  diseaseId: string;
  nameEn: string;
  nameSw: string;
  /** Absent in a names-only fixture, which reads as `NotListed`: nothing can be reported on it. */
  reportingCategory?: string;
  publicAlertEligible?: boolean;
  allowManualAlert?: boolean;
  labTests?: { labTestId: string; strength: TestStrength }[];
}

export interface Disease extends DiseaseNames {
  reportingCategory: string;
  publicAlertEligible: boolean;
  allowManualAlert: boolean;
  labTests: { labTestId: string; strength: TestStrength }[];
}

let byId = new Map<string, Disease>();

function ingest(rows: DiseaseNames[]): void {
  byId = new Map(
    rows.map((r) => [
      r.diseaseId,
      {
        ...r,
        reportingCategory: r.reportingCategory ?? 'NotListed',
        publicAlertEligible: r.publicAlertEligible === true,
        allowManualAlert: r.allowManualAlert === true,
        labTests: r.labTests ?? [],
      },
    ]),
  );
}

/** Load from disk if present. Safe to call when the file is not yet shipped. */
export function loadDiseasesFromDisk(): void {
  const path = join(DATA_DIR, 'notifiable_diseases.json');
  if (!existsSync(path)) {
    byId = new Map();
    return;
  }
  const rows = JSON.parse(readFileSync(path, 'utf8')) as DiseaseNames[];
  ingest(rows);
}

loadDiseasesFromDisk();

/** Test-only: replace the catalogue. */
export function setDiseasesForTest(rows: DiseaseNames[]): void {
  ingest(rows);
}

export function diseaseById(id: string): Disease | undefined {
  return byId.get(id);
}

export function diseaseDisplayName(id: string, language: 'en' | 'sw'): string | undefined {
  const row = byId.get(id);
  if (!row) return undefined;
  const name = language === 'sw' ? row.nameSw : row.nameEn;
  return name.trim() === '' ? undefined : name;
}
