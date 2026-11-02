// Parser and indexes-file shape checks for the deploy-time index smoke.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const ROOT = path.join(__dirname, '..');
const { parseDartQueryRegistry, placeholderForFilter } = require('./smoke-indexes.cjs');

test('parses every QuerySpec from the Dart registry', () => {
  const source = fs.readFileSync(
    path.join(ROOT, 'lib/core/constants/query_registry.dart'),
    'utf8',
  );
  const entries = parseDartQueryRegistry(source);
  assert.ok(entries.length >= 8, `expected app queries, got ${entries.length}`);
  const ids = entries.map((e) => e.id);
  assert.equal(ids.length, new Set(ids).size);
  for (const entry of entries) {
    assert.ok(entry.id, 'id required');
    assert.ok(entry.collection, 'collection required');
    assert.ok(Array.isArray(entry.filters), 'filters required');
    assert.ok(Array.isArray(entry.orderBy), 'orderBy required');
  }
});

test('firestore.indexes.json has the required keys on every entry', () => {
  const doc = JSON.parse(
    fs.readFileSync(path.join(ROOT, 'firestore.indexes.json'), 'utf8'),
  );
  assert.ok(Array.isArray(doc.indexes));
  assert.ok(Array.isArray(doc.fieldOverrides));
  assert.equal(
    doc.indexes.length,
    45,
    'I-1..I-40 plus patients phone+dob plus publicAlerts/messages synthetic shapes',
  );
  for (const idx of doc.indexes) {
    assert.equal(typeof idx.collectionGroup, 'string');
    assert.ok(['COLLECTION', 'COLLECTION_GROUP'].includes(idx.queryScope));
    assert.ok(Array.isArray(idx.fields) && idx.fields.length >= 2);
    for (const field of idx.fields) {
      assert.equal(typeof field.fieldPath, 'string');
      const hasOrder = Object.prototype.hasOwnProperty.call(field, 'order');
      const hasArray = Object.prototype.hasOwnProperty.call(field, 'arrayConfig');
      assert.equal(hasOrder, !hasArray, 'field has order xor arrayConfig');
    }
  }
  for (const fo of doc.fieldOverrides) {
    assert.equal(typeof fo.collectionGroup, 'string');
    assert.equal(typeof fo.fieldPath, 'string');
    assert.ok(Array.isArray(fo.indexes));
    if (Object.prototype.hasOwnProperty.call(fo, 'ttl')) {
      assert.equal(fo.ttl, true);
      assert.equal(fo.fieldPath, 'expireAt');
    }
  }
});

test('rejects a QuerySpec the parser cannot read', () => {
  assert.throws(
    () => parseDartQueryRegistry("const queryRegistry = <QuerySpec>[QuerySpec(\n  id: missing,\n)];"),
    /Cannot parse|Missing list|No QuerySpec/,
  );
});

test('placeholders fit their operator: an array for in, a boolean for flags', () => {
  assert.deepEqual(placeholderForFilter('status in'), ['placeholder']);
  assert.equal(placeholderForFilter('synthetic =='), false);
  assert.equal(placeholderForFilter('countyId =='), 0);
});
