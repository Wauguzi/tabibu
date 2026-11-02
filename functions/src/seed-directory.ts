/**
 * Demo practitioners for the test directory (`make seed-directory`), from
 * `data/demo_directory.json`: fictional people at real Nairobi facilities, so the patient's
 * search and the doctor's pathologist picker have someone to show. Each one signs up and is
 * verified through the same handlers as a real practitioner; only the photo is set afterwards,
 * because sign-up accepts a Storage URL and a demo photo is a freely licensed external one (or
 * none, which shows initials). Idempotent: a re-run updates the photo and nothing else.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

import type { Deps } from './identity';
import { syncPractitionerHandler } from './identity';
import { PROJECT, caller, config, markDemo, practitioner, writeDemoAccount } from './seed';

interface DemoPhoto {
  url: string;
  source: string;
  author: string;
  licence: string;
}

interface DemoPractitioner {
  key: string;
  isPathologist: boolean;
  title: string;
  firstName: string;
  lastName: string;
  facilityId: string;
  specialties: string[];
  bio: string;
  phoneNumber: string;
  kmpdcNumber: string;
  photo: DemoPhoto | null;
}

/** Only https images from the two licences the directory allows. */
function photoUrl(entry: DemoPractitioner): string {
  const photo = entry.photo;
  if (photo === null) return '';
  const host = new URL(photo.url).hostname;
  if (new URL(photo.url).protocol !== 'https:' || !['images.pexels.com', 'images.unsplash.com'].includes(host)) {
    throw new Error(`${entry.key}: photos come from images.pexels.com or images.unsplash.com over https.`);
  }
  if (!photo.source || !photo.author || !photo.licence) {
    throw new Error(`${entry.key}: a photo records its source page, author and licence.`);
  }
  return photo.url;
}

async function main(): Promise<void> {
  const { live, password, email } = config();
  initializeApp({ projectId: PROJECT, storageBucket: `${PROJECT}.firebasestorage.app` });
  const deps: Deps = { db: getFirestore(), auth: getAuth(), bucket: getStorage().bucket().name };
  const file = join(__dirname, '..', 'data', 'demo_directory.json');
  const entries = (JSON.parse(readFileSync(file, 'utf8')) as { practitioners: DemoPractitioner[] }).practitioners;
  // Every photo is checked before anything is written.
  const photos = new Map(entries.map((entry) => [entry.key, photoUrl(entry)]));

  // The seed's admin verifies, as in seed.ts, so `make seed-live` runs first.
  const adminEmail = email('admin');
  const adminRecord = await getAuth()
    .getUserByEmail(adminEmail)
    .catch(() => undefined);
  if (adminRecord?.customClaims?.admin !== true) {
    throw new Error(`${adminEmail} is not the seeded admin; run make seed-live first.`);
  }
  const admin = caller(adminRecord.uid, adminEmail, '', true);

  let doctors = 0;
  let pathologists = 0;
  for (const entry of entries) {
    const uid = await practitioner(deps, admin, {
      email: email(`directory-${entry.key}`),
      password,
      isPathologist: entry.isPathologist,
      facilityId: entry.facilityId,
      fields: {
        title: entry.title,
        firstName: entry.firstName,
        lastName: entry.lastName,
        phoneNumber: entry.phoneNumber,
        specialties: entry.specialties,
        bio: entry.bio,
        kmpdcNumber: entry.kmpdcNumber,
      },
    });
    await deps.db.collection('doctors').doc(uid).update({
      profilePictureUrl: photos.get(entry.key) ?? '',
      lastUpdatedAt: new Date().toISOString(),
    });
    await syncPractitionerHandler(deps.db, uid);
    await markDemo(uid);
    await writeDemoAccount(uid, entry.isPathologist ? 'pathologist' : 'doctor');
    if (entry.isPathologist) pathologists += 1;
    else doctors += 1;
  }

  console.log(
    `Seeded ${live ? PROJECT : 'the emulators'}: ${doctors} directory doctors and ${pathologists} pathologists as ${email('directory-{key}')}.`,
  );
}

main().catch((e: Error) => {
  console.error(`Directory seed failed: ${e.message}`);
  process.exit(1);
});
