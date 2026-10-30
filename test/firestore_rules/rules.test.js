'use strict';

// Firestore and Storage rules against the emulators (make rules-test). Each test names the
// threat it covers (threat model §4.2) where it covers one. RT-n ids are listed in CRQ-0016.

const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  arrayRemove,
  arrayUnion,
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');
const { getMetadata, ref, uploadBytes } = require('firebase/storage');

const PROJECT_ID = 'demo-tabibu';
const BUCKET = `${PROJECT_ID}.appspot.com`;
const ROOT = join(__dirname, '..', '..');

const url = (folder, owner, file = 'f.jpg') =>
  `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${folder}%2F${owner}%2F${file}?alt=media&token=t`;

function patient(overrides = {}) {
  return {
    patientId: 'amina',
    uid: 'amina',
    isRegistered: true,
    createdByUid: 'amina',
    firstName: 'Amina',
    middleName: '',
    lastName: 'Otieno',
    sex: 'Female',
    dateOfBirth: '1990-05-14',
    phoneNumber: '+254712345678',
    email: 'amina@example.com',
    profilePictureUrl: '',
    county: 'Nairobi',
    subCounty: 'Westlands',
    geohash: 'kzf0tjf11',
    doctorUids: ['drOdhiambo'],
    fcmTokens: [],
    language: 'sw',
    receiveNotifications: true,
    casesReported: 0,
    appointmentsBooked: 0,
    createdAt: '2026-10-27T09:00:00.000Z',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

function doctorProfile(overrides = {}) {
  return {
    uid: 'drWanjiru',
    title: 'Dr.',
    firstName: 'Wanjiru',
    lastName: 'Kamau',
    email: 'wanjiru@example.com',
    phoneNumber: '+254722000111',
    profilePictureUrl: url('profilePictures', 'drWanjiru'),
    isPathologist: true,
    specialties: ['Histopathology', 'Cytology'],
    bio: '',
    kmpdcNumber: 'A1234',
    licenseUrls: [url('licenses', 'drWanjiru', 'l.pdf')],
    verificationStatus: 'Pending',
    facilityId: 'f1',
    facilityMflCode: '13043',
    facilityName: '7KR MRS Health Centre',
    county: 'Nairobi',
    subCounty: 'Langata',
    geohash: 'kzf0mj8cj',
    isAvailable: true,
    fcmTokens: [],
    language: 'en',
    receiveNotifications: true,
    appointmentsHandled: 0,
    ordersCreated: 0,
    reportsSigned: 0,
    termsAcceptedAt: '2026-10-27T09:00:00.000Z',
    createdAt: '2026-10-27T09:00:00.000Z',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

const at = { lastUpdatedAt: '2026-10-28T09:00:00.000Z' };

let env;

async function seed(path, data) {
  await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
}

const as = (uid, claims = {}) => env.authenticatedContext(uid, claims);
const db = (uid, claims) => as(uid, claims).firestore();
const PATIENT = { role: 'patient' };
const DOCTOR = { role: 'doctor' };
const PATHOLOGIST = { role: 'pathologist' };

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync(join(ROOT, 'firestore.rules'), 'utf8') },
    storage: { rules: readFileSync(join(ROOT, 'storage.rules'), 'utf8') },
  });
});

after(async () => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
});

describe('patients', () => {
  beforeEach(async () => seed('patients/amina', patient()));

  it('RT-1 the patient reads their own record', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'patients/amina')));
  });

  it('RT-2 another patient cannot read it (T-1)', async () => {
    await assertFails(getDoc(doc(db('juma', PATIENT), 'patients/amina')));
  });

  it('RT-3 a doctor on the care team reads it; one outside cannot', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'patients/amina')));
    await assertFails(getDoc(doc(db('drStranger', DOCTOR), 'patients/amina')));
  });

  it('RT-4 a care-team uid without a practitioner role reads nothing', async () => {
    await assertFails(getDoc(doc(db('drOdhiambo', {}), 'patients/amina')));
  });

  it('RT-5 lists work only with the scoping filter', async () => {
    const mine = db('amina', PATIENT);
    await assertSucceeds(getDocs(query(collection(mine, 'patients'), where('uid', '==', 'amina'))));
    const doctor = db('drOdhiambo', DOCTOR);
    await assertSucceeds(
      getDocs(query(collection(doctor, 'patients'), where('doctorUids', 'array-contains', 'drOdhiambo'))),
    );
    await assertFails(getDocs(collection(doctor, 'patients')));
  });

  it('RT-6 no client creates or deletes a record', async () => {
    await assertFails(setDoc(doc(db('juma', {}), 'patients/juma'), patient({ patientId: 'juma', uid: 'juma' })));
    await assertFails(setDoc(doc(db('drOdhiambo', DOCTOR), 'patients/new'), patient({ patientId: 'new', uid: '' })));
  });

  it('RT-7 the patient edits their name, phone and preferences', async () => {
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'patients/amina'), {
        firstName: 'Aminah',
        phoneNumber: '+254111222333',
        language: 'en',
        fcmTokens: ['token-1'],
        profilePictureUrl: url('profilePictures', 'amina'),
        ...at,
      }),
    );
  });

  it('RT-8 the patient cannot write a geohash or a coordinate (T-9)', async () => {
    const mine = doc(db('amina', PATIENT), 'patients/amina');
    await assertFails(updateDoc(mine, { geohash: 'kzf0mj8cj', ...at }));
    await assertFails(updateDoc(mine, { latitude: -1.3, ...at }));
    await assertFails(updateDoc(mine, { subCounty: 'Kibra', ...at }));
  });

  it('RT-9 the patient cannot change sex, birth date, email or counters', async () => {
    const mine = doc(db('amina', PATIENT), 'patients/amina');
    await assertFails(updateDoc(mine, { sex: 'Male', ...at }));
    await assertFails(updateDoc(mine, { dateOfBirth: '1991-01-01', ...at }));
    await assertFails(updateDoc(mine, { email: 'new@example.com', ...at }));
    await assertFails(updateDoc(mine, { casesReported: 9, ...at }));
    await assertFails(updateDoc(mine, { isRegistered: false, ...at }));
  });

  it('RT-10 the patient may remove a doctor but not add one (T-16)', async () => {
    const mine = doc(db('amina', PATIENT), 'patients/amina');
    await assertFails(updateDoc(mine, { doctorUids: arrayUnion('drNew'), ...at }));
    await assertSucceeds(updateDoc(mine, { doctorUids: arrayRemove('drOdhiambo'), ...at }));
  });

  it('RT-11 a doctor cannot add themselves to a care team (T-16)', async () => {
    await assertFails(
      updateDoc(doc(db('drStranger', DOCTOR), 'patients/amina'), { doctorUids: arrayUnion('drStranger'), ...at }),
    );
  });

  it("RT-12 a picture URL must point into the record's own folder", async () => {
    await assertFails(
      updateDoc(doc(db('amina', PATIENT), 'patients/amina'), {
        profilePictureUrl: url('profilePictures', 'juma'),
        ...at,
      }),
    );
    await assertFails(
      updateDoc(doc(db('amina', PATIENT), 'patients/amina'), {
        profilePictureUrl: 'https://example.com/a.jpg',
        ...at,
      }),
    );
  });

  it('RT-44 a patient update without a new stamp is refused', async () => {
    await assertFails(updateDoc(doc(db('amina', PATIENT), 'patients/amina'), { language: 'sw' }));
    await assertSucceeds(updateDoc(doc(db('amina', PATIENT), 'patients/amina'), { language: 'sw', ...at }));
  });

  it('RT-13 the care team corrects an unregistered record, and stops once registered', async () => {
    await seed('patients/p1', patient({ patientId: 'p1', uid: '', isRegistered: false, createdByUid: 'drOdhiambo' }));
    const record = doc(db('drOdhiambo', DOCTOR), 'patients/p1');
    await assertSucceeds(
      updateDoc(record, { email: 'amina@example.com', profilePictureUrl: url('profilePictures', 'p1'), ...at }),
    );
    await assertFails(updateDoc(record, { dateOfBirth: '1991-01-01', ...at }));
    await assertFails(updateDoc(doc(db('drOdhiambo', DOCTOR), 'patients/amina'), { firstName: 'X', ...at }));
  });

  it('RT-14 a pathologist on the care team cannot edit an unregistered record', async () => {
    await seed('patients/p2', patient({ patientId: 'p2', uid: '', isRegistered: false, doctorUids: ['drPath'] }));
    await assertFails(updateDoc(doc(db('drPath', PATHOLOGIST), 'patients/p2'), { firstName: 'X', ...at }));
  });

  it('RT-15 a linked record is owned through its uid, not its id', async () => {
    await seed('patients/p3', patient({ patientId: 'p3', uid: 'linkedUser' }));
    await assertSucceeds(getDoc(doc(db('linkedUser', PATIENT), 'patients/p3')));
    await assertSucceeds(updateDoc(doc(db('linkedUser', PATIENT), 'patients/p3'), { language: 'en', ...at }));
  });
});

describe('doctors', () => {
  beforeEach(async () => seed('doctors/drWanjiru', doctorProfile()));
  const mine = () => doc(db('drWanjiru', {}), 'doctors/drWanjiru');

  it('RT-16 only the owner and an admin read the profile', async () => {
    await assertSucceeds(getDoc(mine()));
    await assertSucceeds(getDoc(doc(db('admin', { admin: true }), 'doctors/drWanjiru')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'doctors/drWanjiru')));
    await assertFails(getDoc(doc(db('drOther', DOCTOR), 'doctors/drWanjiru')));
  });

  it('RT-17 no client creates a profile', async () => {
    await assertFails(setDoc(doc(db('drNew', {}), 'doctors/drNew'), doctorProfile({ uid: 'drNew' })));
  });

  it('RT-18 a pending owner edits bio, availability, KMPDC number and license', async () => {
    await assertSucceeds(
      updateDoc(mine(), {
        bio: 'Histopathology.',
        isAvailable: false,
        kmpdcNumber: 'A1235',
        licenseUrls: [url('licenses', 'drWanjiru', 'new.pdf'), url('licenses', 'drWanjiru', 'cert.pdf')],
        ...at,
      }),
    );
  });

  it('RT-19 the owner cannot verify themselves or change their role (T-14)', async () => {
    await assertFails(updateDoc(mine(), { verificationStatus: 'Verified', ...at }));
    await assertFails(updateDoc(mine(), { isPathologist: false, ...at }));
  });

  it('RT-20 email and facility never change from the client', async () => {
    await assertFails(updateDoc(mine(), { email: 'x@example.com', ...at }));
    await assertFails(updateDoc(mine(), { facilityId: 'f2', facilityName: 'Elsewhere', ...at }));
    await assertFails(updateDoc(mine(), { geohash: 'kzf0tjf11', ...at }));
  });

  it('RT-21 KMPDC number and license are final once verified (T-14)', async () => {
    await seed('doctors/drWanjiru', doctorProfile({ verificationStatus: 'Verified' }));
    await assertFails(updateDoc(mine(), { kmpdcNumber: 'A1235', ...at }));
    await assertFails(updateDoc(mine(), { licenseUrls: [url('licenses', 'drWanjiru', 'new.pdf')], ...at }));
    await assertSucceeds(updateDoc(mine(), { bio: 'Still editable.', ...at }));
  });

  it('RT-22 a rejected practitioner may resubmit, and only to Pending', async () => {
    await seed('doctors/drWanjiru', doctorProfile({ verificationStatus: 'Rejected' }));
    await assertFails(updateDoc(mine(), { verificationStatus: 'Verified', ...at }));
    await assertSucceeds(updateDoc(mine(), { verificationStatus: 'Pending', kmpdcNumber: 'A1299', ...at }));
  });

  it('RT-23 counters are server-only', async () => {
    await assertFails(updateDoc(mine(), { reportsSigned: 50, ...at }));
  });

  it("RT-32 specialties: one to five, from the role's own list", async () => {
    await assertSucceeds(updateDoc(mine(), { specialties: ['Cytology'], ...at }));
    await assertFails(updateDoc(mine(), { specialties: [], ...at }));
    await assertFails(updateDoc(mine(), { specialties: ['Oncology'], ...at }));
    await assertFails(updateDoc(mine(), { specialties: ['Cytology', 'Cytology'], ...at }));
    await seed('doctors/drOkello', doctorProfile({
      uid: 'drOkello',
      isPathologist: false,
      specialties: ['General surgery'],
      profilePictureUrl: url('profilePictures', 'drOkello'),
      licenseUrls: [url('licenses', 'drOkello', 'l.pdf')],
    }));
    const doctor = doc(db('drOkello', {}), 'doctors/drOkello');
    await assertSucceeds(updateDoc(doctor, { specialties: ['General surgery', 'Breast surgery'], ...at }));
    await assertFails(updateDoc(doctor, { specialties: ['Histopathology'], ...at }));
  });

  it('RT-33 one or two licence files, each in the owner folder', async () => {
    const file = (n) => url('licenses', 'drWanjiru', n);
    await assertFails(updateDoc(mine(), { licenseUrls: [], ...at }));
    await assertFails(updateDoc(mine(), { licenseUrls: [file('a.pdf'), file('b.pdf'), file('c.pdf')], ...at }));
    await assertFails(updateDoc(mine(), { licenseUrls: [file('a.pdf'), url('licenses', 'other', 'b.pdf')], ...at }));
  });

  it('RT-34 a practitioner photo can be changed but not removed', async () => {
    await assertSucceeds(updateDoc(mine(), { profilePictureUrl: url('profilePictures', 'drWanjiru', 'new.jpg'), ...at }));
    await assertFails(updateDoc(mine(), { profilePictureUrl: '', ...at }));
  });

  it('RT-38 the name is final once verified, as the KMPDC number is (T-14)', async () => {
    await assertSucceeds(updateDoc(mine(), { firstName: 'Njeri', ...at }));
    await seed('doctors/drWanjiru', doctorProfile({ verificationStatus: 'Verified' }));
    await assertFails(updateDoc(mine(), { firstName: 'Someone', ...at }));
    await assertFails(updateDoc(mine(), { lastName: 'Else', ...at }));
    await assertFails(updateDoc(mine(), { title: 'Prof.', ...at }));
  });

  it("RT-39 a file URL must be in this project's bucket (T-14)", async () => {
    const elsewhere = (folder, file) =>
      `https://firebasestorage.googleapis.com/v0/b/someone-else.appspot.com/o/${folder}%2FdrWanjiru%2F${file}?alt=media&token=t`;
    await assertFails(updateDoc(mine(), { licenseUrls: [elsewhere('licenses', 'a.pdf')], ...at }));
    await assertFails(updateDoc(mine(), { profilePictureUrl: elsewhere('profilePictures', 'photo.jpg'), ...at }));
  });

  it('RT-40 every update carries a new stamp, so delta sync sees it', async () => {
    await assertFails(updateDoc(mine(), { bio: 'No stamp.' }));
    await assertSucceeds(updateDoc(mine(), { bio: 'Stamped.', ...at }));
  });
});

describe('practitioners', () => {
  beforeEach(async () => seed('practitioners/drWanjiru', { uid: 'drWanjiru', firstName: 'Wanjiru' }));

  it('RT-24 any signed-in user reads the directory; nobody writes it', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'practitioners/drWanjiru')));
    await assertSucceeds(getDoc(doc(db('pending', {}), 'practitioners/drWanjiru')));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'practitioners/drWanjiru')));
    await assertFails(
      setDoc(doc(db('drWanjiru', PATHOLOGIST), 'practitioners/drWanjiru'), { uid: 'drWanjiru', firstName: 'W' }),
    );
  });
});

describe('everything else', () => {
  it('RT-25 an unknown collection is closed', async () => {
    await assertFails(setDoc(doc(db('amina', PATIENT), 'users/amina'), { role: 'pathologist' }));
    await assertFails(getDoc(doc(db('admin', { admin: true }), 'users/amina')));
  });
});

describe('storage', () => {
  const image = new Uint8Array([0xff, 0xd8, 0xff]);
  const big = new Uint8Array(3 * 1024 * 1024 + 1);
  // An upload under the caller's own uid needs a confirmed email.
  const CONFIRMED = { email_verified: true };
  const put = (uid, claims, path, data = image, contentType = 'image/jpeg') =>
    uploadBytes(ref(as(uid, claims).storage(), path), data, { contentType });

  it('RT-26 the owner uploads an image under 3 MB, and nothing else', async () => {
    await assertSucceeds(put('drWanjiru', CONFIRMED, 'profilePictures/drWanjiru/photo.jpg'));
    await assertSucceeds(put('drWanjiru', CONFIRMED, 'profilePictures/drWanjiru/photo.png', image, 'image/png'));
    await assertFails(put('drWanjiru', CONFIRMED, 'profilePictures/drWanjiru/photo.jpg', big));
    await assertFails(put('drWanjiru', CONFIRMED, 'profilePictures/drWanjiru/photo.pdf', image, 'application/pdf'));
    await assertFails(put('drWanjiru', CONFIRMED, 'profilePictures/amina/photo.jpg'));
  });

  it("RT-27 a linked patient uploads to their record's folder", async () => {
    await seed('patients/p3', patient({ patientId: 'p3', uid: 'linkedUser' }));
    await assertSucceeds(put('linkedUser', PATIENT, 'profilePictures/p3/photo.jpg'));
  });

  it("RT-28 the care team uploads an unregistered patient's picture, until they register", async () => {
    await seed('patients/p1', patient({ patientId: 'p1', uid: '', isRegistered: false }));
    await assertSucceeds(put('drOdhiambo', DOCTOR, 'profilePictures/p1/photo.jpg'));
    await assertFails(put('drStranger', DOCTOR, 'profilePictures/p1/photo.jpg'));
    await seed('patients/p1', patient({ patientId: 'p1', uid: 'amina2', isRegistered: true }));
    await assertFails(put('drOdhiambo', DOCTOR, 'profilePictures/p1/photo.jpg'));
  });

  it('RT-35 a licence file may be up to 10 MB', async () => {
    const nine = new Uint8Array(9 * 1024 * 1024);
    const eleven = new Uint8Array(11 * 1024 * 1024);
    await assertSucceeds(put('drNew', CONFIRMED, 'licenses/drNew/license_1.pdf', nine, 'application/pdf'));
    await assertFails(put('drNew', CONFIRMED, 'licenses/drNew/license_2.pdf', eleven, 'application/pdf'));
  });

  it('RT-29 a license is uploaded before sign-up and frozen once verified (T-14)', async () => {
    await assertSucceeds(put('drNew', CONFIRMED, 'licenses/drNew/license_1.pdf', image, 'application/pdf'));
    await assertSucceeds(put('drNew', CONFIRMED, 'licenses/drNew/license_2.png', image, 'image/png'));
    await assertFails(put('drNew', CONFIRMED, 'licenses/drNew/license_2.pdf', image, 'text/plain'));
    await seed('doctors/drNew', doctorProfile({ uid: 'drNew', verificationStatus: 'Verified' }));
    await assertFails(put('drNew', CONFIRMED, 'licenses/drNew/license_2.pdf', image, 'application/pdf'));
  });

  it('RT-36 only the fixed names, each with its own type, are taken', async () => {
    // Any other name would let one account keep files without bound.
    await assertFails(put('drWanjiru', CONFIRMED, 'profilePictures/drWanjiru/me.jpg'));
    await assertFails(put('drNew', CONFIRMED, 'licenses/drNew/license_3.pdf', image, 'application/pdf'));
    await assertFails(put('drNew', CONFIRMED, 'licenses/drNew/scan.pdf', image, 'application/pdf'));
    // The extension and the type agree, and only the app's types pass: no SVG, no HTML.
    await assertFails(put('drWanjiru', CONFIRMED, 'profilePictures/drWanjiru/photo.png', image, 'image/jpeg'));
    await assertFails(put('drWanjiru', CONFIRMED, 'profilePictures/drWanjiru/photo.jpg', image, 'image/svg+xml'));
    await assertFails(put('drNew', CONFIRMED, 'licenses/drNew/license_1.jpg', image, 'text/html'));
  });

  it('RT-37 an account with an unconfirmed email uploads nothing under its uid', async () => {
    await assertFails(put('drWanjiru', {}, 'profilePictures/drWanjiru/photo.jpg'));
    await assertFails(put('drNew', {}, 'licenses/drNew/license_1.pdf', image, 'application/pdf'));
  });

  it('RT-30 a license is read by its owner and an admin only', async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      uploadBytes(ref(ctx.storage(), 'licenses/drNew/license_1.pdf'), image, { contentType: 'application/pdf' }),
    );
    const meta = (uid, claims) => getMetadata(ref(as(uid, claims).storage(), 'licenses/drNew/license_1.pdf'));
    await assertSucceeds(meta('drNew', {}));
    await assertSucceeds(meta('admin', { admin: true }));
    await assertFails(meta('amina', PATIENT));
  });

  it("RT-41 a patient's picture is read by the patient and their care team only", async () => {
    await seed('patients/p5', patient({ patientId: 'p5', uid: 'amina', doctorUids: ['drOdhiambo'] }));
    await env.withSecurityRulesDisabled((ctx) =>
      uploadBytes(ref(ctx.storage(), 'profilePictures/p5/photo.jpg'), image, { contentType: 'image/jpeg' }),
    );
    const meta = (uid, claims) => getMetadata(ref(as(uid, claims).storage(), 'profilePictures/p5/photo.jpg'));
    await assertSucceeds(meta('amina', PATIENT));
    await assertSucceeds(meta('drOdhiambo', DOCTOR));
    await assertFails(meta('drStranger', DOCTOR));
    await assertFails(meta('nobody', {}));
  });

  it("RT-42 a practitioner's picture is read by any signed-in user", async () => {
    await env.withSecurityRulesDisabled((ctx) =>
      uploadBytes(ref(ctx.storage(), 'profilePictures/drWanjiru/photo.jpg'), image, { contentType: 'image/jpeg' }),
    );
    await assertSucceeds(getMetadata(ref(as('amina', PATIENT).storage(), 'profilePictures/drWanjiru/photo.jpg')));
  });

  it('RT-43 only a role-less account uploads licence files', async () => {
    await assertFails(put('amina', { ...CONFIRMED, ...PATIENT }, 'licenses/amina/license_1.pdf', image, 'application/pdf'));
    await assertFails(put('drOk', { ...CONFIRMED, ...DOCTOR }, 'licenses/drOk/license_1.pdf', image, 'application/pdf'));
    await assertSucceeds(put('drNew', CONFIRMED, 'licenses/drNew/license_1.pdf', image, 'application/pdf'));
  });

  it('RT-31 any other path is closed', async () => {
    await assertFails(put('amina', PATIENT, 'slides/case1/tile.jpg'));
  });
});
