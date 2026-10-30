// cspell:ignore pruydqqvj
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { dateOfBirth, normalizeKenyanPhone } from './common';
import { encodeGeohash } from './geohash';
import { CLINICAL_SPECIALTIES, PATHOLOGY_SPECIALTIES } from './identity';
import { DATA_DIR, countyById, facilityById, nairobiSubCountyById } from './reference-data';

describe('reference data', () => {
  it('is byte-identical to the app assets', () => {
    for (const [file, target] of [
      ['facilities_nairobi.json', 'facilities'],
      ['sub_counties_nairobi.json', 'facilities'],
      ['counties.json', 'facilities'],
      ['lab_test_types.json', 'lab-tests'],
      ['lab_tests.json', 'lab-tests'],
    ]) {
      const server = readFileSync(join(DATA_DIR, file));
      const app = readFileSync(join(DATA_DIR, '..', '..', 'assets', 'data', file));
      assert.ok(server.equals(app), `${file} differs; run make ${target}`);
    }
  });

  it('resolves counties, sub-counties and facilities', () => {
    assert.equal(countyById(47)?.name, 'Nairobi');
    assert.equal(nairobiSubCountyById(30)?.name, 'Westlands');
    assert.equal(facilityById('a2ee3d41-fe27-46fe-8e60-633c2fe4e069')?.mflCode, '13043');
  });
});

describe('encodeGeohash', () => {
  it('agrees with the app on the published vectors', () => {
    assert.equal(encodeGeohash(57.64911, 10.40744, 11), 'u4pruydqqvj');
    assert.equal(encodeGeohash(52.2, 0.12, 6), 'u120fw');
    assert.equal(encodeGeohash(42.6, -5.6, 5), 'ezs42');
    assert.equal(encodeGeohash(0, 0), 's00000000');
  });

  it('agrees with every hash in the shipped facility list', () => {
    const rows = JSON.parse(readFileSync(join(DATA_DIR, 'facilities_nairobi.json'), 'utf8')) as {
      latitude: number;
      longitude: number;
      geohash: string;
    }[];
    for (const r of rows) assert.equal(encodeGeohash(r.latitude, r.longitude), r.geohash);
  });

  it('refuses out-of-range input', () => {
    assert.throws(() => encodeGeohash(91, 0), RangeError);
    assert.throws(() => encodeGeohash(0, 0, 13), RangeError);
  });
});

describe('input checks', () => {
  it('normalises Kenyan numbers to E.164', () => {
    for (const raw of ['0712345678', '254712345678', '+254 712 345 678', '(0712) 345-678']) {
      assert.equal(normalizeKenyanPhone(raw), '+254712345678');
    }
    assert.equal(normalizeKenyanPhone('0110000000'), '+254110000000');
    assert.throws(() => normalizeKenyanPhone('0812345678'));
  });

  it('accepts only real past dates', () => {
    const now = new Date('2026-10-27T00:00:00Z');
    assert.equal(dateOfBirth('2000-02-29', now), '2000-02-29');
    assert.throws(() => dateOfBirth('2001-02-29', now));
    assert.throws(() => dateOfBirth('1890-01-01', now));
    assert.throws(() => dateOfBirth('27/10/1990', now));
  });

  it("takes today's date in Nairobi, three hours ahead of UTC", () => {
    // 22:30 UTC on the 29th is 01:30 on the 30th in Nairobi.
    const now = new Date('2026-10-29T22:30:00Z');
    assert.equal(dateOfBirth('2026-10-30', now), '2026-10-30');
    assert.throws(() => dateOfBirth('2026-10-31', now));
  });
});

describe('specialties', () => {
  // Three copies: this function's lists, firestore.rules (which cannot import) and the app's enum.
  const root = join(DATA_DIR, '..', '..');
  const quoted = (s: string) => [...s.matchAll(/'([^']+)'/g)].map((m) => m[1]);

  it('the rules hold the same two lists', () => {
    const rules = readFileSync(join(root, 'firestore.rules'), 'utf8');
    const block = /function specialties\(\) \{([\s\S]*?)return chosen/.exec(rules)?.[1] ?? '';
    const [pathology, clinical] = block.split(':');
    assert.deepEqual(quoted(pathology), [...PATHOLOGY_SPECIALTIES]);
    assert.deepEqual(quoted(clinical), [...CLINICAL_SPECIALTIES]);
  });

  it("the app's Specialty enum holds the same values, pathology first", () => {
    const enums = readFileSync(join(root, 'lib', 'core', 'constants', 'enums.dart'), 'utf8');
    const block = /enum Specialty \{([\s\S]*?);\n/.exec(enums)?.[1] ?? '';
    const values = [...block.matchAll(/\w+\('([^']+)'(, isPathology: true)?\)/g)];
    assert.deepEqual(
      values.filter((v) => v[2]).map((v) => v[1]),
      [...PATHOLOGY_SPECIALTIES],
    );
    assert.deepEqual(
      values.filter((v) => !v[2]).map((v) => v[1]),
      [...CLINICAL_SPECIALTIES],
    );
  });
});
