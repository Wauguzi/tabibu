/**
 * Demo accounts, one per role, plus doctor-added patients (CRQ-0018). Runs the same handlers as
 * the callables, so a seeded account passes every check a real sign-up does.
 *
 *   make seed-emulator                        Auth, Firestore and Storage emulators
 *   make seed-live CONFIRM=tabibu-86ea2       the live project, through ADC
 *
 * Idempotent: an account that exists is reused, and each handler returns what it made before.
 * The password comes from SEED_PASSWORD (the Keychain, via make) and is never printed.
 */
import { randomUUID } from 'node:crypto';

import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

import type { Caller } from './common';
import {
  Deps,
  addPatientHandler,
  completePatientSignUpHandler,
  completePractitionerSignUpHandler,
  syncPractitionerHandler,
  verifyPractitionerHandler,
} from './identity';

export const PROJECT = 'tabibu-86ea2';
const EMULATOR_HOSTS = ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST', 'FIREBASE_STORAGE_EMULATOR_HOST'];

const KENYATTA_NATIONAL_HOSPITAL = '779bc5ec-701d-408f-84d5-b846b2edc45e';
const MBAGATHI_DISTRICT_HOSPITAL = '88a63b52-4cc1-4db2-a73d-a88c2a9bb816';

export function config() {
  const live = process.argv.includes('--live');
  if (live && process.env.SEED_CONFIRM !== PROJECT) {
    throw new Error(`Seeding the live project needs SEED_CONFIRM=${PROJECT}.`);
  }
  // `make emulators` runs under the real project id, so a missing host would send that service's
  // writes to the live project. All three, or none.
  const missing = EMULATOR_HOSTS.filter((h) => !process.env[h]);
  if (!live && missing.length > 0) throw new Error(`Emulator mode needs ${missing.join(', ')}.`);
  if (live && missing.length < EMULATOR_HOSTS.length) {
    throw new Error('--live with emulator hosts set is ambiguous; unset them.');
  }
  const password = process.env.SEED_PASSWORD ?? '';
  if (password.length < 12) throw new Error('SEED_PASSWORD must be at least 12 characters.');
  // `{role}` is replaced per account, e.g. `tabibu.demo+{role}@gmail.com`: plus addressing sends
  // every account's mail to one inbox, so password reset works.
  const template = process.env.SEED_EMAIL_TEMPLATE || '{role}@tabibu.test';
  if (!template.includes('{role}') || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(template.replace('{role}', 'x'))) {
    throw new Error('SEED_EMAIL_TEMPLATE must be an email address containing {role}.');
  }
  const email = (role: string) => template.replace('{role}', role).toLowerCase();
  return { live, password, email };
}

/**
 * The seeded account for [email]. An account the seed did not create is refused, never adopted:
 * anyone can sign up with a seeded address first, and the seed then grants roles and admin.
 */
export async function user(email: string, password: string, displayName: string): Promise<string> {
  const auth = getAuth();
  let existing: { uid: string; customClaims?: Record<string, unknown> } | undefined;
  try {
    existing = await auth.getUserByEmail(email);
  } catch {
    existing = undefined;
  }
  if (existing) {
    if (existing.customClaims?.seeded !== true) {
      throw new Error(`${email} exists but was not created by the seed; refusing to adopt it.`);
    }
    return existing.uid;
  }
  const { uid } = await auth.createUser({ email, password, displayName, emailVerified: true });
  await auth.setCustomUserClaims(uid, { seeded: true });
  return uid;
}

// The seed creates its accounts confirmed, as the sign-up callables require.
export function caller(uid: string, email: string, role = '', isAdmin = false): Caller {
  return { uid, email, emailVerified: true, role, isAdmin };
}

/** Marks a seeded account as demo content, keeping every claim it already holds. */
export async function markDemo(uid: string): Promise<void> {
  const auth = getAuth();
  const claims = (await auth.getUser(uid)).customClaims ?? {};
  await auth.setCustomUserClaims(uid, { ...claims, demo: true });
}

/**
 * The demo-clinician row synthetic alerts page. County and language mirror the synced
 * profile, so the row pages exactly where the practitioner's own row does.
 */
export async function writeDemoAccount(uid: string, role: 'doctor' | 'pathologist'): Promise<void> {
  const db = getFirestore();
  const practitioner = (await db.collection('practitioners').doc(uid).get()).data();
  const profile = (await db.collection('doctors').doc(uid).get()).data();
  const county = practitioner?.county;
  await db.collection('demoAccounts').doc(uid).set({
    uid,
    role,
    county: typeof county === 'string' ? county : '',
    language: profile?.language === 'sw' ? 'sw' : 'en',
  });
}

/** A placeholder license, stored where the rules expect one, with its download URL. */
export async function license(uid: string, bucketName: string): Promise<string> {
  const token = randomUUID();
  const path = `licenses/${uid}/license_1.pdf`;
  await getStorage()
    .bucket(bucketName)
    .file(path)
    .save(Buffer.from('%PDF-1.4\n% Tabibu demo license placeholder\n'), {
      contentType: 'application/pdf',
      metadata: { metadata: { firebaseStorageDownloadTokens: token } },
    });
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

/** A placeholder photo where the rules expect one; the demo uses the app's own portraits. */
export async function picture(uid: string, bucketName: string): Promise<string> {
  const token = randomUUID();
  const path = `profilePictures/${uid}/photo.png`;
  // A 1x1 PNG: the seed proves the path and the rules, not the picture.
  const png = Buffer.from(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
    'base64',
  );
  await getStorage()
    .bucket(bucketName)
    .file(path)
    .save(png, { contentType: 'image/png', metadata: { metadata: { firebaseStorageDownloadTokens: token } } });
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

export async function practitioner(
  deps: Deps,
  admin: Caller,
  input: { email: string; password: string; isPathologist: boolean; facilityId: string; fields: object },
): Promise<string> {
  const uid = await user(input.email, input.password, input.email);
  await completePractitionerSignUpHandler(deps, caller(uid, input.email), {
    ...input.fields,
    isPathologist: input.isPathologist,
    facilityId: input.facilityId,
    licenseUrls: [await license(uid, deps.bucket)],
    profilePictureUrl: await picture(uid, deps.bucket),
    termsAccepted: true,
  });
  await verifyPractitionerHandler(deps, admin, { uid, decision: 'Verified' });
  // The trigger does this when deployed; the seed may run without the functions emulator.
  await syncPractitionerHandler(deps.db, uid);
  return uid;
}

async function main(): Promise<void> {
  const { live, password, email } = config();
  initializeApp({ projectId: PROJECT, storageBucket: `${PROJECT}.firebasestorage.app` });
  const deps: Deps = {
    db: getFirestore(),
    auth: getAuth(),
    bucket: getStorage().bucket().name,
  };

  const adminEmail = email('admin');
  const adminUid = await user(adminEmail, password, 'Tabibu admin');
  const existing = (await getAuth().getUser(adminUid)).customClaims ?? {};
  await getAuth().setCustomUserClaims(adminUid, { ...existing, admin: true, alertApprover: true });
  const admin = caller(adminUid, adminEmail, '', true);
  const seededAt = new Date().toISOString();
  await getFirestore()
    .collection('alertApprovers')
    .doc(adminUid)
    .set({
      uid: adminUid,
      grantedByUid: adminUid,
      grantedAt: seededAt,
      fcmTokens: [],
      language: 'en',
      lastUpdatedAt: seededAt,
    });
  await markDemo(adminUid);

  const doctorEmail = email('doctor');
  const doctorUid = await practitioner(deps, admin, {
    email: doctorEmail,
    password,
    isPathologist: false,
    facilityId: MBAGATHI_DISTRICT_HOSPITAL,
    fields: {
      title: 'Dr.',
      firstName: 'Achieng',
      lastName: 'Odhiambo',
      phoneNumber: '+254700000101',
      specialties: ['Family medicine', 'General practice'],
      bio: 'General practice and outpatient care.',
      kmpdcNumber: 'DEMO-D-0001',
    },
  });
  // S-2: the demo doctor is the in-app alert approver (admin still approves
  // from the console). Claims merge with whatever practitioner() wrote.
  const doctorClaims = (await getAuth().getUser(doctorUid)).customClaims ?? {};
  await getAuth().setCustomUserClaims(doctorUid, {
    ...doctorClaims,
    admin: true,
    alertApprover: true,
  });
  // Created once: a re-run must not wipe the push tokens the doctor's phone
  // has since registered.
  const doctorApprover = getFirestore().collection('alertApprovers').doc(doctorUid);
  if (!(await doctorApprover.get()).exists) {
    await doctorApprover.set({
      uid: doctorUid,
      grantedByUid: adminUid,
      grantedAt: seededAt,
      fcmTokens: [],
      language: 'en',
      lastUpdatedAt: seededAt,
    });
  }
  await markDemo(doctorUid);
  await writeDemoAccount(doctorUid, 'doctor');

  const pathologistUid = await practitioner(deps, admin, {
    email: email('pathologist'),
    password,
    isPathologist: true,
    facilityId: KENYATTA_NATIONAL_HOSPITAL,
    fields: {
      title: 'Dr.',
      firstName: 'Wanjiru',
      lastName: 'Kamau',
      phoneNumber: '+254700000102',
      specialties: ['Histopathology', 'Cytology'],
      bio: 'Histopathology and cytology.',
      kmpdcNumber: 'DEMO-P-0001',
    },
  });
  await markDemo(pathologistUid);
  await writeDemoAccount(pathologistUid, 'pathologist');

  const patientEmail = email('patient');
  const patientUid = await user(patientEmail, password, 'Amina Otieno');
  await completePatientSignUpHandler(deps, caller(patientUid, patientEmail), {
    firstName: 'Amina',
    middleName: '',
    lastName: 'Otieno',
    sex: 'Female',
    dateOfBirth: '1990-05-14',
    phoneNumber: '+254700000201',
    countyId: 47,
    subCountyId: 30,
    language: 'sw',
  });
  await markDemo(patientUid);

  const doctor = caller(doctorUid, doctorEmail, 'doctor');
  for (const p of [
    { firstName: 'Juma', lastName: 'Mwangi', sex: 'Male', dateOfBirth: '1978-11-02', phone: '+254700000301', sub: 35 },
    { firstName: 'Grace', lastName: 'Njeri', sex: 'Female', dateOfBirth: '2001-03-21', phone: '+254700000302', sub: 174 },
  ]) {
    await addPatientHandler(deps, doctor, {
      firstName: p.firstName,
      middleName: '',
      lastName: p.lastName,
      sex: p.sex,
      dateOfBirth: p.dateOfBirth,
      phoneNumber: p.phone,
      countyId: 47,
      subCountyId: p.sub,
      language: 'sw',
    });
  }

  console.log(`Seeded ${live ? PROJECT : 'the emulators'}: admin, doctor (approver), pathologist, patient as ${email('{role}')}; 2 clinic patients.`);
}

// seed-directory.ts imports the helpers above without running this seed.
if (require.main === module) {
  main().catch((e: Error) => {
    console.error(`Seed failed: ${e.message}`);
    process.exit(1);
  });
}
