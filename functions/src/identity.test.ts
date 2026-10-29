import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { DOCTORS, PATIENTS, PRACTITIONERS } from './common';
import {
  account,
  claimsOf,
  downloadUrl,
  emulatorDeps,
  refusedWith,
  resetEmulators,
} from './emulator.test-support';
import {
  Deps,
  addPatientHandler,
  completePatientSignUpHandler,
  completePractitionerSignUpHandler,
  linkPatientAccountHandler,
  syncPractitionerHandler,
  verifyPractitionerHandler,
} from './identity';
import { DATA_DIR, facilityById } from './reference-data';

const facilities = JSON.parse(readFileSync(join(DATA_DIR, 'facilities_nairobi.json'), 'utf8')) as {
  facilityId: string;
  isOperational: boolean;
}[];
const OPEN = facilities.find((f) => f.isOperational)!;
const CLOSED = facilities.find((f) => !f.isOperational)!;

const WESTLANDS = 30;

function patientInput(overrides: Record<string, unknown> = {}) {
  return {
    firstName: ' Amina ',
    middleName: '',
    lastName: 'Otieno',
    sex: 'Female',
    dateOfBirth: '1990-05-14',
    phoneNumber: '0712 345 678',
    countyId: 47,
    subCountyId: WESTLANDS,
    language: 'sw',
    ...overrides,
  };
}

function practitionerInput(uid: string, overrides: Record<string, unknown> = {}) {
  return {
    title: 'Dr.',
    firstName: 'Wanjiru',
    lastName: 'Kamau',
    phoneNumber: '+254722000111',
    isPathologist: true,
    bio: 'Twelve years in histopathology.',
    kmpdcNumber: 'a1234',
    licenseUrls: [downloadUrl('licenses', uid, 'license.pdf'), downloadUrl('licenses', uid, 'cert.pdf')],
    profilePictureUrl: downloadUrl('profilePictures', uid, 'me.jpg'),
    specialties: ['Cytology', 'Histopathology'],
    facilityId: OPEN.facilityId,
    termsAccepted: true,
    ...overrides,
  };
}

describe('identity', () => {
  let deps: Deps;

  beforeEach(async () => {
    deps = emulatorDeps();
    await resetEmulators();
  });

  describe('completePatientSignUp', () => {
    it('creates a complete record keyed by the uid and sets the patient claim', async () => {
      const me = await account(deps, 'amina@example.com');
      const result = await completePatientSignUpHandler(deps, me, patientInput());
      assert.deepEqual(result, { status: 'registered', patientId: me.uid });

      const doc = (await deps.db.collection(PATIENTS).doc(me.uid).get()).data()!;
      assert.equal(doc.uid, me.uid);
      assert.equal(doc.isRegistered, true);
      assert.equal(doc.createdByUid, me.uid);
      assert.equal(doc.firstName, 'Amina');
      assert.equal(doc.phoneNumber, '+254712345678');
      assert.equal(doc.email, 'amina@example.com');
      assert.equal(doc.subCounty, 'Westlands');
      assert.equal(doc.geohash.length, 9);
      assert.deepEqual(doc.doctorUids, []);
      assert.equal(doc.createdAt, '2026-10-27T09:00:00.000Z');
      assert.ok(!Object.values(doc).includes(null));
      assert.equal((await claimsOf(me.uid)).role, 'patient');
    });

    it('is safe to retry', async () => {
      const me = await account(deps, 'amina@example.com');
      await completePatientSignUpHandler(deps, me, patientInput());
      const again = await completePatientSignUpHandler(deps, { ...me, role: 'patient' }, patientInput());
      assert.deepEqual(again, { status: 'registered', patientId: me.uid });
    });

    it('stores no area or geohash outside Nairobi', async () => {
      const me = await account(deps, 'juma@example.com');
      await completePatientSignUpHandler(deps, me, patientInput({ countyId: 1, subCountyId: undefined }));
      const doc = (await deps.db.collection(PATIENTS).doc(me.uid).get()).data()!;
      assert.equal(doc.county, 'Mombasa');
      assert.equal(doc.subCounty, '');
      assert.equal(doc.geohash, '');
    });

    it('requires a Nairobi sub-county in Nairobi', async () => {
      const me = await account(deps, 'amina@example.com');
      await refusedWith(
        completePatientSignUpHandler(deps, me, patientInput({ subCountyId: 9999 })),
        'invalidSubCounty',
      );
    });

    it('never merges into a doctor-added record with the same phone and birth date (T-15)', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      await addPatientHandler(deps, doctor, patientInput());
      const impostor = await account(deps, 'someone@example.com');

      const result = await completePatientSignUpHandler(deps, impostor, patientInput());
      assert.deepEqual(result, { status: 'clinicRecordExists' });
      assert.equal((await deps.db.collection(PATIENTS).doc(impostor.uid).get()).exists, false);
      assert.equal((await claimsOf(impostor.uid)).role, undefined);
    });

    it('refuses a second account for a registered patient', async () => {
      const first = await account(deps, 'amina@example.com');
      await completePatientSignUpHandler(deps, first, patientInput());
      const second = await account(deps, 'amina2@example.com');
      await refusedWith(completePatientSignUpHandler(deps, second, patientInput()), 'patientAlreadyRegistered');
    });

    it('refuses an address nobody has confirmed', async () => {
      const me = await account(deps, 'amina@example.com', {}, { emailVerified: false });
      await refusedWith(completePatientSignUpHandler(deps, me, patientInput()), 'emailNotVerified');
      assert.equal((await deps.db.collection(PATIENTS).doc(me.uid).get()).exists, false);
    });

    it('refuses a caller who already has another role', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      await refusedWith(completePatientSignUpHandler(deps, doctor, patientInput()), 'roleAlreadySet');
    });

    it('refuses an unauthenticated caller, a future birth date and a foreign phone', async () => {
      await refusedWith(completePatientSignUpHandler(deps, null, patientInput()), 'unauthenticated');
      const me = await account(deps, 'amina@example.com');
      await refusedWith(
        completePatientSignUpHandler(deps, me, patientInput({ dateOfBirth: '2030-01-01' })),
        'invalidDateOfBirth',
      );
      await refusedWith(
        completePatientSignUpHandler(deps, me, patientInput({ phoneNumber: '+14155550100' })),
        'invalidPhone',
      );
    });
  });

  describe('addPatient', () => {
    it('creates an unregistered record with the doctor on the care team', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const { status, patientId } = await addPatientHandler(deps, doctor, patientInput({ email: '' }));
      assert.equal(status, 'created');
      const doc = (await deps.db.collection(PATIENTS).doc(patientId).get()).data()!;
      assert.equal(doc.patientId, patientId);
      assert.equal(doc.uid, '');
      assert.equal(doc.isRegistered, false);
      assert.equal(doc.createdByUid, doctor.uid);
      assert.deepEqual(doc.doctorUids, [doctor.uid]);
    });

    it('returns the same record when the same doctor retries', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const first = await addPatientHandler(deps, doctor, patientInput());
      const again = await addPatientHandler(deps, doctor, patientInput());
      assert.deepEqual(again, { status: 'alreadyInCare', patientId: first.patientId });
    });

    it("does not let a doctor join another doctor's patient (T-16)", async () => {
      const first = await account(deps, 'doc1@example.com', { role: 'doctor' });
      await addPatientHandler(deps, first, patientInput());
      const second = await account(deps, 'doc2@example.com', { role: 'doctor' });
      await refusedWith(addPatientHandler(deps, second, patientInput()), 'patientExists');
    });

    it('is for doctors only', async () => {
      const pathologist = await account(deps, 'path@example.com', { role: 'pathologist' });
      await refusedWith(addPatientHandler(deps, pathologist, patientInput()), 'doctorsOnly');
    });
  });

  describe('completePatientSignUp after a link', () => {
    it('a linked account gets its linked record, and no second one', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const { patientId } = await addPatientHandler(deps, doctor, patientInput());
      const patient = await account(deps, 'amina@example.com');
      await linkPatientAccountHandler(deps, doctor, { patientId, email: 'amina@example.com' });
      const signedIn = { ...patient, role: 'patient' };

      const result = await completePatientSignUpHandler(deps, signedIn, {
        ...patientInput(),
        phoneNumber: '0799000111',
        dateOfBirth: '1991-01-01',
      });
      assert.deepEqual(result, { status: 'registered', patientId });
      const own = await deps.db.collection(PATIENTS).where('uid', '==', patient.uid).get();
      assert.equal(own.size, 1);
    });
  });

  describe('linkPatientAccount', () => {
    it("attaches a role-less account to the doctor's record", async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const { patientId } = await addPatientHandler(deps, doctor, patientInput());
      const patient = await account(deps, 'amina@example.com');

      await linkPatientAccountHandler(deps, doctor, { patientId, email: 'Amina@Example.com' });
      const doc = (await deps.db.collection(PATIENTS).doc(patientId).get()).data()!;
      assert.equal(doc.uid, patient.uid);
      assert.equal(doc.isRegistered, true);
      assert.equal(doc.email, 'amina@example.com');
      assert.equal((await claimsOf(patient.uid)).role, 'patient');
    });

    it('is refused to a doctor outside the care team', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const { patientId } = await addPatientHandler(deps, doctor, patientInput());
      await account(deps, 'amina@example.com');
      const stranger = await account(deps, 'other@example.com', { role: 'doctor' });
      await refusedWith(
        linkPatientAccountHandler(deps, stranger, { patientId, email: 'amina@example.com' }),
        'invalidPatient',
      );
    });

    it('refuses an account whose address nobody confirmed (T-15)', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const { patientId } = await addPatientHandler(deps, doctor, patientInput());
      const squatter = await account(deps, 'amina@example.com', {}, { emailVerified: false });
      await refusedWith(
        linkPatientAccountHandler(deps, doctor, { patientId, email: 'amina@example.com' }),
        'emailNotVerified',
      );
      const doc = (await deps.db.collection(PATIENTS).doc(patientId).get()).data()!;
      assert.equal(doc.isRegistered, false);
      assert.equal((await claimsOf(squatter.uid)).role, undefined);
    });

    it('a retry after the role failed to set finishes the link', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const { patientId } = await addPatientHandler(deps, doctor, patientInput());
      const patient = await account(deps, 'amina@example.com');
      // The record was linked, then setting the role failed.
      await deps.db.collection(PATIENTS).doc(patientId).update({ uid: patient.uid, isRegistered: true });

      const result = await linkPatientAccountHandler(deps, doctor, { patientId, email: 'amina@example.com' });
      assert.deepEqual(result, { status: 'linked', patientId });
      assert.equal((await claimsOf(patient.uid)).role, 'patient');
    });

    it('refuses an account that already has a role', async () => {
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      const { patientId } = await addPatientHandler(deps, doctor, patientInput());
      await account(deps, 'busy@example.com', { role: 'pathologist' });
      await refusedWith(
        linkPatientAccountHandler(deps, doctor, { patientId, email: 'busy@example.com' }),
        'accountAlreadyHasRole',
      );
    });
  });

  describe('completePractitionerSignUp', () => {
    it('creates a pending profile with no role claim (T-14)', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      const result = await completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid));
      assert.deepEqual(result, { status: 'Pending' });

      const doc = (await deps.db.collection(DOCTORS).doc(me.uid).get()).data()!;
      const facility = facilityById(OPEN.facilityId)!;
      assert.equal(doc.verificationStatus, 'Pending');
      assert.equal(doc.kmpdcNumber, 'A1234');
      assert.equal(doc.email, 'wanjiru@example.com');
      assert.equal(doc.facilityName, facility.name);
      assert.equal(doc.geohash, facility.geohash);
      assert.equal(doc.reportsSigned, 0);
      assert.equal((await claimsOf(me.uid)).role, undefined);
    });

    it('refuses an address nobody has confirmed', async () => {
      const me = await account(deps, 'wanjiru@example.com', {}, { emailVerified: false });
      await refusedWith(
        completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid)),
        'emailNotVerified',
      );
      assert.equal((await deps.db.collection(DOCTORS).doc(me.uid).get()).exists, false);
    });

    it('refuses a closed or unknown facility', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await refusedWith(
        completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid, { facilityId: CLOSED.facilityId })),
        'facilityNotOperational',
      );
      await refusedWith(
        completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid, { facilityId: 'nope' })),
        'invalidFacility',
      );
    });

    it('refuses a KMPDC number another account holds', async () => {
      const first = await account(deps, 'one@example.com');
      await completePractitionerSignUpHandler(deps, first, practitionerInput(first.uid));
      const second = await account(deps, 'two@example.com');
      await refusedWith(
        completePractitionerSignUpHandler(deps, second, practitionerInput(second.uid, { kmpdcNumber: 'A1234' })),
        'kmpdcNumberInUse',
      );
    });

    it("refuses a license stored under someone else's folder", async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await refusedWith(
        completePractitionerSignUpHandler(
          deps,
          me,
          practitionerInput(me.uid, { licenseUrls: [downloadUrl('licenses', 'someone-else', 'l.pdf')] }),
        ),
        'invalidLicense',
      );
    });

    it('takes one or two licence files, never none or three', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      const file = (n: string) => downloadUrl('licenses', me.uid, n);
      await refusedWith(
        completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid, { licenseUrls: [] })),
        'invalidLicense',
      );
      await refusedWith(
        completePractitionerSignUpHandler(
          deps,
          me,
          practitionerInput(me.uid, { licenseUrls: [file('a.pdf'), file('b.pdf'), file('c.pdf')] }),
        ),
        'invalidLicense',
      );
      await completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid, { licenseUrls: [file('a.pdf')] }));
      const doc = (await deps.db.collection(DOCTORS).doc(me.uid).get()).data()!;
      assert.deepEqual(doc.licenseUrls, [file('a.pdf')]);
    });

    it('requires a profile photo', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await refusedWith(
        completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid, { profilePictureUrl: '' })),
        'invalidPicture',
      );
    });

    it("stores specialties in the list's order", async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid));
      const doc = (await deps.db.collection(DOCTORS).doc(me.uid).get()).data()!;
      assert.deepEqual(doc.specialties, ['Histopathology', 'Cytology']);
    });

    it("takes one to five specialties from the role's own list", async () => {
      const path = await account(deps, 'path@example.com');
      for (const specialties of [[], ['Astrology'], ['Oncology'], ['Cytology', 'Cytology']]) {
        await refusedWith(
          completePractitionerSignUpHandler(deps, path, practitionerInput(path.uid, { specialties })),
          'invalidSpecialties',
        );
      }
      const doc = await account(deps, 'doc@example.com');
      await refusedWith(
        completePractitionerSignUpHandler(
          deps,
          doc,
          practitionerInput(doc.uid, { isPathologist: false, specialties: ['Histopathology'] }),
        ),
        'invalidSpecialties',
      );
      await completePractitionerSignUpHandler(
        deps,
        doc,
        practitionerInput(doc.uid, { isPathologist: false, kmpdcNumber: 'D777', specialties: ['General surgery', 'Breast surgery'] }),
      );
      const saved = (await deps.db.collection(DOCTORS).doc(doc.uid).get()).data()!;
      assert.deepEqual(saved.specialties, ['General surgery', 'Breast surgery']);
    });

    it('takes availability from the sign-up switch', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid, { isAvailable: false }));
      const doc = (await deps.db.collection(DOCTORS).doc(me.uid).get()).data()!;
      assert.equal(doc.isAvailable, false);
    });

    it('requires the terms to be accepted', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await refusedWith(
        completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid, { termsAccepted: false })),
        'termsRequired',
      );
    });
  });

  describe('verifyPractitioner', () => {
    it('is admin only', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid));
      const doctor = await account(deps, 'doc@example.com', { role: 'doctor' });
      await refusedWith(verifyPractitionerHandler(deps, doctor, { uid: me.uid, decision: 'Verified' }), 'adminOnly');
    });

    it('verifying sets the role; rejecting removes it and keeps other claims', async () => {
      const me = await account(deps, 'wanjiru@example.com', { admin: true });
      await completePractitionerSignUpHandler(deps, { ...me, role: '' }, practitionerInput(me.uid));

      await verifyPractitionerHandler(deps, me, { uid: me.uid, decision: 'Verified' });
      assert.deepEqual(await claimsOf(me.uid), { admin: true, role: 'pathologist' });

      await verifyPractitionerHandler(deps, me, { uid: me.uid, decision: 'Rejected' });
      assert.deepEqual(await claimsOf(me.uid), { admin: true });
      const doc = (await deps.db.collection(DOCTORS).doc(me.uid).get()).data()!;
      assert.equal(doc.verificationStatus, 'Rejected');
    });

    it('refuses to verify a KMPDC number another practitioner changed to meanwhile', async () => {
      const admin = await account(deps, 'admin@example.com', { admin: true });
      const first = await account(deps, 'one@example.com');
      await completePractitionerSignUpHandler(deps, first, practitionerInput(first.uid));
      const second = await account(deps, 'two@example.com');
      await completePractitionerSignUpHandler(deps, second, practitionerInput(second.uid, { kmpdcNumber: 'B999' }));
      // While pending the number is the owner's to edit (rules), so it can collide.
      await deps.db.collection(DOCTORS).doc(second.uid).update({ kmpdcNumber: 'A1234' });
      await refusedWith(
        verifyPractitionerHandler(deps, admin, { uid: second.uid, decision: 'Verified' }),
        'kmpdcNumberInUse',
      );
    });
  });

  describe('syncPractitioner', () => {
    it('publishes only the public fields of a verified practitioner', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid));
      const doctor = (await deps.db.collection(DOCTORS).doc(me.uid).get()).data()!;

      const profile = deps.db.collection(DOCTORS).doc(me.uid);
      assert.equal(doctor.verificationStatus, 'Pending');
      assert.equal(await syncPractitionerHandler(deps.db, me.uid), 'removed');
      await profile.update({ verificationStatus: 'Verified' });
      assert.equal(await syncPractitionerHandler(deps.db, me.uid), 'written');
      const entry = (await deps.db.collection(PRACTITIONERS).doc(me.uid).get()).data()!;
      for (const hidden of ['email', 'phoneNumber', 'kmpdcNumber', 'licenseUrls', 'fcmTokens']) {
        assert.equal(hidden in entry, false, hidden);
      }
      assert.equal(entry.facilityName, facilityById(OPEN.facilityId)!.name);
      assert.equal(entry.bio, 'Twelve years in histopathology.');
      assert.deepEqual(entry.specialties, ['Histopathology', 'Cytology']);
      assert.equal('licenseUrls' in entry, false);

      await profile.delete();
      assert.equal(await syncPractitionerHandler(deps.db, me.uid), 'removed');
      assert.equal((await deps.db.collection(PRACTITIONERS).doc(me.uid).get()).exists, false);
    });

    it('a late Verified event never republishes a practitioner since rejected', async () => {
      const me = await account(deps, 'wanjiru@example.com');
      await completePractitionerSignUpHandler(deps, me, practitionerInput(me.uid));
      const profile = deps.db.collection(DOCTORS).doc(me.uid);
      await profile.update({ verificationStatus: 'Verified' });
      assert.equal(await syncPractitionerHandler(deps.db, me.uid), 'written');

      // Rejected, then the earlier Verified event is delivered last.
      await profile.update({ verificationStatus: 'Rejected' });
      assert.equal(await syncPractitionerHandler(deps.db, me.uid), 'removed');
      assert.equal(await syncPractitionerHandler(deps.db, me.uid), 'removed');
      assert.equal((await deps.db.collection(PRACTITIONERS).doc(me.uid).get()).exists, false);
    });
  });
});
