#!/usr/bin/env npx ts-node
/**
 * Read-only check that the demo seed's cases match the staged expectations (bundle 67).
 * Lists each case with stage, pathologist, slide count, accession and pre-read status, then
 * prints PASS or the first mismatch. Never writes.
 *
 * Usage:
 *   npx ts-node scripts/check-demo.ts
 *   SEED_CASES_TAG=… npx ts-node scripts/check-demo.ts
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npx ts-node scripts/check-demo.ts
 */
import { getApp, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

import { pushEn } from '../src/copy/notifications.en';
import { pushSw } from '../src/copy/notifications.sw';
import { PROJECT } from '../src/seed';
import { uidFor } from '../src/seed-cases';
import { DEMO_CASE_EXPECTATIONS } from '../src/seed-cases-demo';

function str(v: unknown): string {
  return typeof v === 'string' ? v : '';
}

function numSlides(data: Record<string, unknown> | undefined): number {
  const images = data?.slideImages;
  return Array.isArray(images) ? images.length : 0;
}

async function main(): Promise<void> {
  try {
    getApp();
  } catch {
    initializeApp({ projectId: PROJECT, storageBucket: `${PROJECT}.firebasestorage.app` });
  }
  const db = getFirestore();
  const tag = process.env.SEED_CASES_TAG ?? '';

  // The "New case waiting" row must exist in both languages for the pathologist walk.
  if (pushEn.pathologistRequested.title !== 'New case waiting') {
    fail('en pathologistRequested title drifted from "New case waiting"');
  }
  if (pushSw.pathologistRequested.title !== 'Kesi mpya inasubiri') {
    fail('sw pathologistRequested title drifted from "Kesi mpya inasubiri"');
  }

  const rows: {
    key: string;
    caseUid: string;
    stage: string;
    pathologistUid: string;
    slides: number;
    accession: string;
    preread: string;
  }[] = [];

  for (const exp of DEMO_CASE_EXPECTATIONS) {
    const caseUid = uidFor(tag, `case:${exp.key}`);
    const snap = await db.collection('cases').doc(caseUid).get();
    if (!snap.exists) {
      fail(`missing case ${exp.key} (${caseUid}); run make seed-cases with SEED_CASES_TAG=${JSON.stringify(tag)}`);
    }
    const data = snap.data() as Record<string, unknown>;
    const stage = str(data.currentStage);
    const accession = str(data.labAccessionNo);
    const slides = numSlides(data);
    const pathologistUid = str(data.pathologistUid) || str(data.requestedPathologistUid);
    const prereadDocs = await snap.ref.collection('preread').get();
    let preread = 'none';
    if (!prereadDocs.empty) {
      const statuses = prereadDocs.docs.map((d) => str(d.get('status')));
      preread = statuses.includes('Ready')
        ? 'Ready'
        : statuses.includes('Queued') || statuses.includes('Running')
          ? 'Queued'
          : statuses[0] || 'present';
    }

    rows.push({ key: exp.key, caseUid, stage, pathologistUid, slides, accession, preread });

    if (stage !== exp.stage) {
      fail(`${exp.key}: stage ${stage} (expected ${exp.stage})`);
    }
    if (slides < exp.minSlides) {
      fail(`${exp.key}: slides ${slides} (expected >= ${exp.minSlides})`);
    }
    if (exp.accession === 'empty' && accession !== '') {
      fail(`${exp.key}: accession ${JSON.stringify(accession)} (expected empty)`);
    }
    if (exp.accession === 'set' && accession === '') {
      fail(`${exp.key}: accession empty (expected set)`);
    }
    if (exp.preread === 'Ready' && preread !== 'Ready') {
      fail(`${exp.key}: preread ${preread} (expected Ready)`);
    }
    if (exp.preread === 'Queued' && preread !== 'Queued') {
      fail(`${exp.key}: preread ${preread} (expected Queued)`);
    }
    if (exp.preread === 'none' && preread !== 'none') {
      fail(`${exp.key}: preread ${preread} (expected none)`);
    }
  }

  // requestWithSlide must still have the waiting notification for the demo pathologist.
  const requestUid = uidFor(tag, 'case:requestWithSlide');
  const notes = await db.collection('notifications').where('resourceUid', '==', requestUid).get();
  if (!notes.docs.some((d) => d.get('templateKey') === 'pathologistRequested')) {
    fail(`requestWithSlide: no pathologistRequested notification (resourceUid=${requestUid})`);
  }

  const rejectUid = uidFor(tag, 'case:rejected');
  const rejectLog = await db.collection('cases').doc(rejectUid).collection('log').orderBy('seq').get();
  const rejectEntry = rejectLog.docs.find(
    (d) => d.get('toStage') === 'PathologistRejected' || d.get('actionType') === 'Reject',
  );
  if (!rejectEntry || str(rejectEntry.get('actionReason')) === '') {
    fail('rejected: log has no Reject reason');
  }

  console.log(
    JSON.stringify(
      {
        project: PROJECT,
        tag,
        cases: rows,
      },
      null,
      2,
    ),
  );
  console.log('PASS');
}

function fail(message: string): never {
  console.error(`FAIL: ${message}`);
  process.exit(1);
}

main().catch((e: Error) => {
  console.error(`check-demo failed: ${e.message}`);
  process.exit(1);
});
