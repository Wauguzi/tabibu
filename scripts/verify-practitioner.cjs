#!/usr/bin/env node
/**
 * Verifies one practitioner as the verifyPractitioner callable does, until the
 * app has an approval screen: verificationStatus Verified, then the role claim,
 * keeping every other claim. A dry run unless --confirm names the project.
 *
 * Usage: node scripts/verify-practitioner.cjs <projectId> <uid> [--confirm <projectId>]
 */
'use strict';

const path = require('node:path');

const ROOT = path.join(__dirname, '..');
const lib = (name) => require(path.join(ROOT, 'functions/node_modules', name));

async function main() {
  const [project, uid, flag, confirm] = process.argv.slice(2);
  if (!project || !uid) {
    throw new Error('usage: node scripts/verify-practitioner.cjs <projectId> <uid> [--confirm <projectId>]');
  }
  const live = flag === '--confirm' && confirm === project;

  const { initializeApp, applicationDefault } = lib('firebase-admin/app');
  const { getAuth } = lib('firebase-admin/auth');
  const { getFirestore } = lib('firebase-admin/firestore');
  initializeApp({ credential: applicationDefault(), projectId: project });
  const db = getFirestore();
  const auth = getAuth();

  const ref = db.collection('doctors').doc(uid);
  const doc = await ref.get();
  if (!doc.exists) throw new Error(`doctors/${uid} does not exist`);
  const kmpdc = doc.get('kmpdcNumber');
  const holders = await db.collection('doctors').where('kmpdcNumber', '==', kmpdc).limit(2).get();
  if (holders.docs.some((d) => d.id !== uid)) {
    throw new Error(`KMPDC number ${kmpdc} is held by another account`);
  }

  const role = doc.get('isPathologist') === true ? 'pathologist' : 'doctor';
  const user = await auth.getUser(uid);
  const claims = { ...(user.customClaims ?? {}), role };
  console.log(`${uid}: ${doc.get('verificationStatus')} -> Verified, role ${role}`);
  if (!live) {
    console.log(`Dry run. Add CONFIRM=${project} to apply.`);
    return;
  }
  await ref.update({ verificationStatus: 'Verified', lastUpdatedAt: new Date().toISOString() });
  await auth.setCustomUserClaims(uid, claims);
  console.log('Verified. The practitioner reopens the app to pick up the role.');
}

main().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
