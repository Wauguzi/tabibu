/**
 * The facility, county and sub-county lists the app ships (architecture §6.2). `functions/data/`
 * is a byte-identical copy of `assets/data/`, written by `make facilities` and checked by
 * `reference-data.test.ts`, so the server never trusts a facility or location a client sends.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

// `src/` under test and `lib/` when deployed both sit one level below `data/`.
export const DATA_DIR = join(__dirname, '..', 'data');

function load<T>(file: string): T[] {
  return JSON.parse(readFileSync(join(DATA_DIR, file), 'utf8')) as T[];
}

export const NAIROBI_COUNTY_ID = 47;

export interface Facility {
  facilityId: string;
  mflCode: string;
  name: string;
  subCounty: string;
  county: string;
  geohash: string;
  isOperational: boolean;
}

export interface SubCounty {
  id: number;
  name: string;
  geohash: string;
}

export interface County {
  id: number;
  name: string;
}

const facilities = new Map<string, Facility>(
  load<Facility>('facilities_nairobi.json').map((f) => [f.facilityId, f]),
);
const subCounties = new Map<number, SubCounty>(
  load<SubCounty>('sub_counties_nairobi.json').map((s) => [s.id, s]),
);
const counties = new Map<number, County>(load<County>('counties.json').map((c) => [c.id, c]));

export function facilityById(id: string): Facility | undefined {
  return facilities.get(id);
}

export function countyById(id: number): County | undefined {
  return counties.get(id);
}

export function nairobiSubCountyById(id: number): SubCounty | undefined {
  return subCounties.get(id);
}
