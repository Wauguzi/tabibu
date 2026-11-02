import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';

import { futureQuerySlots, queryRegistry, QueryEntry } from './queries';

const ROOT = join(__dirname, '..', '..');
const INDEXES_PATH = join(ROOT, 'firestore.indexes.json');
const SRC_DIR = join(__dirname);

interface IndexField {
  fieldPath: string;
  order?: string;
  arrayConfig?: string;
}

interface CompositeIndex {
  collectionGroup: string;
  queryScope: string;
  fields: IndexField[];
}

interface FieldOverride {
  collectionGroup: string;
  fieldPath: string;
  indexes: { order?: string; arrayConfig?: string; queryScope: string }[];
}

interface IndexesFile {
  indexes: CompositeIndex[];
  fieldOverrides: FieldOverride[];
}

function loadIndexes(): IndexesFile {
  return JSON.parse(readFileSync(INDEXES_PATH, 'utf8')) as IndexesFile;
}

function needsCompositeOrGroupIndex(entry: QueryEntry): boolean {
  if (entry.scope === 'collectionGroup') return true;
  if (entry.filters.length >= 2) return true;
  if (entry.filters.length >= 1 && entry.orderBy.length >= 1) {
    const filterFields = new Set(entry.filters.map((f) => f.field));
    return entry.orderBy.some((o) => !filterFields.has(o.field));
  }
  return false;
}

function entryMatchesIndex(entry: QueryEntry, index: CompositeIndex): boolean {
  const expectedScope =
    entry.scope === 'collectionGroup' ? 'COLLECTION_GROUP' : 'COLLECTION';
  if (index.collectionGroup !== entry.collection) return false;
  if (index.queryScope !== expectedScope) return false;

  // Index fields = filters (in order) then orderBy fields not already covered. Two filters on one
  // field (a lower and an upper bound) are one index field.
  const wanted: { field: string; op?: string; direction?: string }[] = [
    ...entry.filters
      .filter((f, i) => entry.filters.findIndex((g) => g.field === f.field) === i)
      .map((f) => ({ field: f.field, op: f.op })),
    ...entry.orderBy
      .filter((o) => !entry.filters.some((f) => f.field === o.field))
      .map((o) => ({ field: o.field, direction: o.direction })),
  ];
  if (wanted.length === 0) return false;
  if (index.fields.length < wanted.length) return false;

  for (let i = 0; i < wanted.length; i++) {
    const w = wanted[i];
    const f = index.fields[i];
    if (f.fieldPath !== w.field) return false;
    if (w.op === 'array-contains') {
      if (f.arrayConfig !== 'CONTAINS') return false;
    } else if (w.direction) {
      const order = w.direction === 'desc' ? 'DESCENDING' : 'ASCENDING';
      if (f.order !== order) return false;
    } else if (!f.order && !f.arrayConfig) {
      return false;
    }
  }
  return true;
}

describe('query registry', () => {
  const indexes = loadIndexes();
  const allEntries = [...queryRegistry, ...futureQuerySlots];

  it('every entry that needs a composite or collection-group index has one', () => {
    for (const entry of allEntries) {
      if (!needsCompositeOrGroupIndex(entry)) continue;
      const match =
        indexes.indexes.find((idx) => entryMatchesIndex(entry, idx)) ??
        (overrideServes(entry) ? true : undefined);
      assert.ok(
        match,
        `No composite index for query ${entry.id} ` +
          `(${entry.collection}, ${entry.filters.map((f) => `${f.field} ${f.op}`).join(', ')})`,
      );
    }
  });

  // A collection-group read ordered by one field rides that field's single-field
  // override, not a composite.
  function overrideServes(entry: QueryEntry): boolean {
    if (entry.scope !== 'collectionGroup') return false;
    if (entry.filters.length !== 0 || entry.orderBy.length !== 1) return false;
    const order = entry.orderBy[0];
    const want = order.direction === 'desc' ? 'DESCENDING' : 'ASCENDING';
    return indexes.fieldOverrides.some(
      (o) =>
        o.collectionGroup === entry.collection &&
        o.fieldPath === order.field &&
        o.indexes.some((i) => i.order === want && i.queryScope === 'COLLECTION_GROUP'),
    );
  }

  it('queries.ts is the only functions/src file that calls .where(', () => {
    const files = readdirSync(SRC_DIR).filter(
      (name) =>
        name.endsWith('.ts') &&
        !name.endsWith('.test.ts') &&
        !name.endsWith('.test-support.ts'),
    );
    const offenders: string[] = [];
    for (const name of files) {
      if (name === 'queries.ts') continue;
      const text = readFileSync(join(SRC_DIR, name), 'utf8');
      if (/\.where\s*\(/.test(text)) offenders.push(name);
    }
    assert.deepEqual(
      offenders,
      [],
      `Only queries.ts may call .where(; found in: ${offenders.join(', ')}`,
    );
  });

  it('registry ids are unique', () => {
    const ids = allEntries.map((e) => e.id);
    assert.equal(ids.length, new Set(ids).size);
  });
});
