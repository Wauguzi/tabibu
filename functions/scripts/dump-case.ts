#!/usr/bin/env npx ts-node
/**
 * Print cases and their sub-collections as JSON, read-only, so runs can be inspected offline.
 * With no arguments it dumps the demo doctor's cases, newest first (at most --limit, default 10),
 * each with its pre-read, log and report documents. Long strings and arrays are summarised;
 * pass --full to keep them.
 *
 * Usage:
 *   npx ts-node scripts/dump-case.ts > dump.txt                 # the demo doctor's cases
 *   npx ts-node scripts/dump-case.ts --latest > dump.txt        # only the newest one
 *   npx ts-node scripts/dump-case.ts --doctor <uid> --limit 5   # another doctor
 *   npx ts-node scripts/dump-case.ts <caseUid|orderNumber>      # one named case
 *
 * Uses the application default credentials already on this machine; nothing is read from or
 * written to the environment, and no document is changed.
 */
import { getApp, initializeApp } from 'firebase-admin/app';
import { DocumentData, DocumentReference, getFirestore } from 'firebase-admin/firestore';

import { PROJECT } from '../src/seed';

const DEMO_DOCTOR_UID = 'maNgumFQqhOT83uRI1lWYchHWaW2';

const FULL = process.argv.includes('--full');
const LATEST = process.argv.includes('--latest');

function option(name: string): string | undefined {
  const at = process.argv.indexOf(name);
  return at < 0 ? undefined : process.argv[at + 1];
}

const doctorUid = option('--doctor') ?? DEMO_DOCTOR_UID;
const limit = LATEST ? 1 : Math.max(1, Number(option('--limit') ?? 10));
const named = process.argv
  .slice(2)
  .filter((a, i, all) => !a.startsWith('--') && !['--doctor', '--limit'].includes(all[i - 1]))[0];

const SUBCOLLECTIONS = [
  'preread',
  'prereadScores',
  'log',
  'reportDrafts',
  'reportProvenance',
  'reportTexts',
  'reports',
];

function summarise(value: unknown): unknown {
  if (FULL) return value;
  if (typeof value === 'string') return value.length > 300 ? `<${value.length} chars>` : value;
  if (Array.isArray(value)) {
    if (value.length > 12) return `<${value.length} items; first: ${JSON.stringify(summarise(value[0]))}>`;
    return value.map(summarise);
  }
  if (value && typeof value === 'object') {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value)) out[k] = summarise(v);
    return out;
  }
  return value;
}

function plain(data: DocumentData): unknown {
  return summarise(JSON.parse(JSON.stringify(data)));
}

async function withSubcollections(ref: DocumentReference, data: DocumentData): Promise<unknown> {
  const out: Record<string, unknown> = { caseUid: ref.id, case: plain(data) };
  for (const name of SUBCOLLECTIONS) {
    const docs = await ref.collection(name).get();
    if (docs.empty) continue;
    out[name] = Object.fromEntries(docs.docs.map((d) => [d.id, plain(d.data())]));
  }
  return out;
}

async function main(): Promise<void> {
  try {
    getApp();
  } catch {
    initializeApp({ projectId: PROJECT });
  }
  const db = getFirestore();

  if (named) {
    let snap = await db.collection('cases').doc(named).get();
    if (!snap.exists) {
      const byNumber = await db.collection('cases').where('orderNumber', '==', named).limit(1).get();
      if (byNumber.empty) throw new Error(`No case with uid or order number "${named}".`);
      snap = byNumber.docs[0];
    }
    console.log(JSON.stringify(await withSubcollections(snap.ref, snap.data() ?? {}), null, 2));
    return;
  }

  // One equality filter needs no composite index; newest first is sorted here.
  const mine = await db.collection('cases').where('doctorUid', '==', doctorUid).get();
  const cases = mine.docs
    .sort((a, b) => String(b.data().createdAt ?? '').localeCompare(String(a.data().createdAt ?? '')))
    .slice(0, limit);
  const overview = cases.map((d) => {
    const c = d.data();
    return {
      caseUid: d.id,
      orderNumber: c.orderNumber,
      createdAt: c.createdAt,
      stage: c.currentStage,
      pathologistUid: c.pathologistUid,
      requestedPathologistUid: c.requestedPathologistUid,
      slides: Array.isArray(c.slideImages) ? c.slideImages.length : 0,
      prereadRunUid: c.prereadRunUid,
    };
  });
  const details = [];
  for (const d of cases) details.push(await withSubcollections(d.ref, d.data()));
  console.log(
    JSON.stringify({ doctorUid, found: mine.size, shown: cases.length, overview, cases: details }, null, 2),
  );
}

main().catch((e: unknown) => {
  console.error(e instanceof Error ? e.message : e);
  process.exitCode = 1;
});
