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

const PROJECT = 'tabibu-86ea2';
const EMULATOR_HOSTS = ['FIRESTORE_EMULATOR_HOST', 'FIREBASE_AUTH_EMULATOR_HOST', 'FIREBASE_STORAGE_EMULATOR_HOST'];

const KENYATTA_NATIONAL_HOSPITAL = '779bc5ec-701d-408f-84d5-b846b2edc45e';
const MBAGATHI_DISTRICT_HOSPITAL = '88a63b52-4cc1-4db2-a73d-a88c2a9bb816';

function config() {
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

async function user(email: string, password: string, displayName: string): Promise<string> {
  const auth = getAuth();
  try {
    return (await auth.getUserByEmail(email)).uid;
  } catch {
    return (await auth.createUser({ email, password, displayName, emailVerified: true })).uid;
  }
}

function caller(uid: string, email: string, role = '', isAdmin = false): Caller {
  return { uid, email, role, isAdmin };
}

/** A placeholder license, stored where the rules expect one, with its download URL. */
async function license(uid: string, bucketName: string): Promise<string> {
  const token = randomUUID();
  const path = `licenses/${uid}/license.pdf`;
  await getStorage()
    .bucket(bucketName)
    .file(path)
    .save(Buffer.from('%PDF-1.4\n% Tabibu demo license placeholder\n'), {
      contentType: 'application/pdf',
      metadata: { metadata: { firebaseStorageDownloadTokens: token } },
    });
  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

async function practitioner(
  deps: Deps,
  admin: Caller,
  input: { email: string; password: string; isPathologist: boolean; facilityId: string; fields: object },
): Promise<string> {
  const uid = await user(input.email, input.password, input.email);
  await completePractitionerSignUpHandler(deps, caller(uid, input.email), {
    ...input.fields,
    isPathologist: input.isPathologist,
    facilityId: input.facilityId,
    licenseUrl: await license(uid, deps.bucket),
    termsAccepted: true,
  });
  await verifyPractitionerHandler(deps, admin, { uid, decision: 'Verified' });
  // The trigger does this when deployed; the seed may run without the functions emulator.
  const doctor = (await deps.db.collection('doctors').doc(uid).get()).data();
  await syncPractitionerHandler(deps.db, uid, doctor);
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
  await getAuth().setCustomUserClaims(adminUid, { ...existing, admin: true });
  const admin = caller(adminUid, adminEmail, '', true);

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
      specialization: 'Family medicine',
      bio: 'General practice and outpatient care.',
      kmpdcNumber: 'DEMO-D-0001',
    },
  });
  // The approver permission sits on one doctor (spec, Wed 28 Oct).
  const doctorClaims = (await getAuth().getUser(doctorUid)).customClaims ?? {};
  await getAuth().setCustomUserClaims(doctorUid, { ...doctorClaims, alertApprover: true });

  await practitioner(deps, admin, {
    email: email('pathologist'),
    password,
    isPathologist: true,
    facilityId: KENYATTA_NATIONAL_HOSPITAL,
    fields: {
      title: 'Dr.',
      firstName: 'Wanjiru',
      lastName: 'Kamau',
      phoneNumber: '+254700000102',
      specialization: 'Anatomical pathology',
      bio: 'Histopathology and cytology.',
      kmpdcNumber: 'DEMO-P-0001',
    },
  });

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

main().catch((e: Error) => {
  console.error(`Seed failed: ${e.message}`);
  process.exit(1);
});
