/**
 * Server-side prices and test facts. A client sends test ids only; each ordered test stores its
 * id, name and price as ordered (S-6: totals are summed in code).
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { DATA_DIR } from './reference-data';

export interface LabTest {
  labTestId: string;
  testTypeId: string;
  testTypeName: string;
  name: string;
  isActive: boolean;
  testPriceKes: number;
  isPriceEstimate: boolean;
}

const tests = new Map<string, LabTest>(
  (JSON.parse(readFileSync(join(DATA_DIR, 'lab_tests.json'), 'utf8')) as LabTest[]).map((t) => [
    t.labTestId,
    t,
  ]),
);

export function labTestById(id: string): LabTest | undefined {
  return tests.get(id);
}

export type PrereadProfile = 'Cancer' | 'Malaria' | 'None';

// Histopathology examination, IHC, the IHC cancer panel; the malaria blood smear (Q-11).
const PROFILE_BY_TEST = new Map<string, PrereadProfile>([
  ['9f7bb98a-1df9-4730-88b6-2226ffced0a0', 'Cancer'],
  ['9f7bb98a-7d8c-4d92-93b0-9b451e0b0b64', 'Cancer'],
  ['9f7bb988-3a72-42f5-8f8c-2991403db489', 'Cancer'],
  ['9f7bb988-7068-4bc4-a7c5-08c690da9482', 'Malaria'],
]);

/** The AI profile an order selects; it is never stored on the case. */
export function prereadProfileOf(testIds: readonly string[]): PrereadProfile {
  const profiles = testIds.map((id) => PROFILE_BY_TEST.get(id)).filter((p) => p !== undefined);
  if (profiles.includes('Cancer')) return 'Cancer';
  if (profiles.includes('Malaria')) return 'Malaria';
  return 'None';
}

export function requiresSlides(testIds: readonly string[]): boolean {
  return prereadProfileOf(testIds) !== 'None';
}
