#!/usr/bin/env npx ts-node
/**
 * Repair a seeded pre-read that the live worker left Failed while the stored draft is still
 * on the document (`models.provenance` = stored demo). Dry by default; `--live` needs the
 * same confirm guard as the other seed scripts.
 *
 * Usage:
 *   npx ts-node scripts/repair-preread.ts <caseUid>
 *   npx ts-node scripts/repair-preread.ts <caseUid> --live   # needs SEED_CONFIRM=tabibu-86ea2
 */
import { getApp, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

import { PROJECT } from '../src/seed';
import { PROVENANCE } from '../src/seed-cases-media';

const LIVE = process.argv.includes('--live');
const caseUid = process.argv.slice(2).find((a) => a !== '--live');

async function main(): Promise<void> {
  if (!caseUid) {
    console.log('Usage: npx ts-node scripts/repair-preread.ts <caseUid> [--live]');
    process.exitCode = 1;
    return;
  }

  if (LIVE && process.env.SEED_CONFIRM !== PROJECT) {
    throw new Error(`Repairing the live project needs SEED_CONFIRM=${PROJECT}.`);
  }

  const plan = {
    caseUid,
    live: LIVE,
    project: LIVE ? PROJECT : 'emulators',
    action: 'Failed → Ready when models.provenance is the stored demo line',
  };
  console.log(JSON.stringify(plan, null, 2));

  if (!LIVE) {
    console.log('Dry run only. Pass --live with SEED_CONFIRM set to apply.');
    return;
  }

  try {
    getApp();
  } catch {
    initializeApp({ projectId: PROJECT });
  }
  const db = getFirestore();
  const runs = await db.collection('cases').doc(caseUid).collection('preread').get();
  let repaired = 0;
  let skipped = 0;
  for (const doc of runs.docs) {
    const data = doc.data();
    const provenance =
      data.models && typeof data.models === 'object'
        ? (data.models as { provenance?: unknown }).provenance
        : undefined;
    if (data.status !== 'Failed' || provenance !== PROVENANCE) {
      skipped += 1;
      continue;
    }
    await doc.ref.update({
      status: 'Ready',
      failureReason: '',
      lastUpdatedAt: new Date().toISOString(),
    });
    repaired += 1;
    console.log(JSON.stringify({ runUid: doc.id, status: 'Ready', repaired: true }));
  }
  console.log(JSON.stringify({ repaired, skipped, total: runs.size }));
}

main().catch((error) => {
  console.error(String(error));
  process.exitCode = 1;
});
