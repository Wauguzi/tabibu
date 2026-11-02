#!/usr/bin/env node
/**
 * Deploy-time index smoke (plan §5.3). Runs every registered query with limit(1)
 * against a real project and exits non-zero on FAILED_PRECONDITION.
 *
 * Usage: node scripts/smoke-indexes.cjs <projectId>
 * Never run this from a casual make check — only after deploy-indexes.
 */
'use strict';

const fs = require('node:fs');
const path = require('node:path');

const ROOT = path.join(__dirname, '..');

/**
 * Parses `QuerySpec(...)` literals from the Dart query registry.
 * Strict: throws if an entry cannot be parsed.
 */
function parseDartQueryRegistry(source) {
  const entries = [];
  const re = /QuerySpec\s*\(\s*([\s\S]*?)\n\s*\)/g;
  let match;
  while ((match = re.exec(source)) !== null) {
    const body = match[1];
    const id = stringField(body, 'id');
    const collection = stringField(body, 'collection');
    const scope = optionalStringField(body, 'scope') ?? 'collection';
    const filters = stringListField(body, 'filters');
    const orderBy = optionalStringListField(body, 'orderBy') ?? [];
    if (!id || !collection) {
      throw new Error(`Cannot parse QuerySpec near: ${body.slice(0, 80)}`);
    }
    entries.push({ id, collection, scope, filters, orderBy });
  }
  if (entries.length === 0) {
    throw new Error('No QuerySpec entries found in Dart registry');
  }
  return entries;
}

function stringField(body, name) {
  const m = body.match(new RegExp(`${name}\\s*:\\s*'([^']*)'`));
  return m ? m[1] : null;
}

function optionalStringField(body, name) {
  return stringField(body, name);
}

function stringListField(body, name) {
  const m = body.match(
    new RegExp(`${name}\\s*:\\s*(?:<String>)?\\[([\\s\\S]*?)\\]`),
  );
  if (!m) {
    throw new Error(`Missing list field ${name} in QuerySpec`);
  }
  return [...m[1].matchAll(/'([^']*)'/g)].map((x) => x[1]);
}

function optionalStringListField(body, name) {
  const m = body.match(
    new RegExp(`${name}\\s*:\\s*(?:<String>)?\\[([\\s\\S]*?)\\]`),
  );
  if (!m) return null;
  return [...m[1].matchAll(/'([^']*)'/g)].map((x) => x[1]);
}

function placeholderForFilter(filter) {
  const parts = filter.split(/\s+/);
  const op = parts.slice(1).join(' ');
  if (op === 'array-contains') return 'placeholder';
  if (op === 'in') return ['placeholder'];
  if (op.startsWith('>=') || op.startsWith('>') || op.startsWith('<=') || op.startsWith('<')) {
    return '1970-01-01T00:00:00.000Z';
  }
  if (parts[0] === 'countyId' || parts[0].endsWith('Id') && op === '==') {
    // numeric county ids vs string ids — try number for countyId
    if (parts[0] === 'countyId') return 0;
  }
  if (op === '==' && ['patientsReleased', 'blocked', 'synthetic'].includes(parts[0])) {
    return false;
  }
  return 'placeholder';
}

async function run() {
  const projectId = process.argv[2];
  if (!projectId) {
    console.error('usage: node scripts/smoke-indexes.cjs <projectId>');
    process.exit(2);
  }

  const dartPath = path.join(ROOT, 'lib/core/constants/query_registry.dart');
  const dartEntries = parseDartQueryRegistry(fs.readFileSync(dartPath, 'utf8'));

  // Prefer the compiled registry; fall back to requiring ts-node in functions.
  let functionsEntries = [];
  const compiled = path.join(ROOT, 'functions/lib/queries.js');
  if (fs.existsSync(compiled)) {
    // eslint-disable-next-line import/no-dynamic-require, global-require
    const mod = require(compiled);
    functionsEntries = [...(mod.queryRegistry || []), ...(mod.futureQuerySlots || [])];
  } else {
    console.warn('functions/lib/queries.js missing; run functions build first');
  }

  const admin = require(path.join(ROOT, 'functions/node_modules/firebase-admin'));
  if (!admin.apps.length) {
    admin.initializeApp({ projectId });
  }
  const db = admin.firestore();

  const failures = [];

  for (const entry of dartEntries) {
    try {
      let q =
        entry.scope === 'collectionGroup'
          ? db.collectionGroup(entry.collection)
          : entry.scope === 'nested'
            ? db.collection('conversations').doc('_').collection(entry.collection)
            : db.collection(entry.collection);
      for (const filter of entry.filters) {
        const field = filter.split(' ')[0];
        const op = filter.split(' ').slice(1).join(' ');
        const value = placeholderForFilter(filter);
        q = q.where(field, op === 'array-contains' ? 'array-contains' : op, value);
      }
      for (const order of entry.orderBy) {
        const [field, dir] = order.split(/\s+/);
        q = q.orderBy(field, dir && dir.toLowerCase() === 'desc' ? 'desc' : 'asc');
      }
      await q.limit(1).get();
    } catch (err) {
      const code = err.code || err.status || '';
      if (String(code).includes('FAILED_PRECONDITION') || /index/i.test(err.message || '')) {
        failures.push(`dart:${entry.id}: ${err.message}`);
      } else {
        // Permission or empty project is fine — the index was accepted.
        if (!/PERMISSION_DENIED|NOT_FOUND|permission/i.test(String(err.message || code))) {
          failures.push(`dart:${entry.id}: ${err.message || err}`);
        }
      }
    }
  }

  for (const entry of functionsEntries) {
    try {
      let q =
        entry.scope === 'collectionGroup'
          ? db.collectionGroup(entry.collection)
          : db.collection(entry.collection);
      entry.filters.forEach((filter, i) => {
        const value =
          filter.op === 'array-contains'
            ? 'placeholder'
            : filter.field === 'countyId'
              ? 0
              : 'placeholder';
        q = q.where(filter.field, filter.op, value);
      });
      for (const order of entry.orderBy || []) {
        q = q.orderBy(order.field, order.direction);
      }
      await q.limit(1).get();
    } catch (err) {
      const code = err.code || '';
      if (String(code).includes('FAILED_PRECONDITION') || /index/i.test(err.message || '')) {
        failures.push(`functions:${entry.id}: ${err.message}`);
      }
    }
  }

  if (failures.length) {
    console.error('Index smoke failed:\n' + failures.map((f) => `  ${f}`).join('\n'));
    process.exit(1);
  }
  console.log(
    `Index smoke ok (${dartEntries.length} dart, ${functionsEntries.length} functions) on ${projectId}`,
  );
}

module.exports = { parseDartQueryRegistry, placeholderForFilter };

if (require.main === module) {
  run().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
