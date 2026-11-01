/**
 * Bundled notifiable-disease names for public-alert push (S-3).
 * Tests inject via [setDiseasesForTest]; production loads
 * `functions/data/notifiable_diseases.json` when the other agent has shipped it.
 */
import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import { DATA_DIR } from './reference-data';

export interface DiseaseNames {
  diseaseId: string;
  nameEn: string;
  nameSw: string;
}

let byId = new Map<string, DiseaseNames>();

function ingest(rows: DiseaseNames[]): void {
  byId = new Map(rows.map((r) => [r.diseaseId, r]));
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

export function diseaseById(id: string): DiseaseNames | undefined {
  return byId.get(id);
}

export function diseaseDisplayName(id: string, language: 'en' | 'sw'): string | undefined {
  const row = byId.get(id);
  if (!row) return undefined;
  const name = language === 'sw' ? row.nameSw : row.nameEn;
  return name.trim() === '' ? undefined : name;
}
