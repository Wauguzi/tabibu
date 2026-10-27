/**
 * Creating people (architecture §6.1, CRQ-0014). Clients never create a `patients`, `doctors` or
 * `practitioners` document; these handlers do, after the checks Firestore rules cannot make (a
 * duplicate search, a facility lookup), and they set the role claim in the same step.
 */
import type { DocumentData, Firestore } from 'firebase-admin/firestore';

import {
  AuthLike,
  Caller,
  DOCTORS,
  LANGUAGES,
  PATIENTS,
  PRACTITIONERS,
  Role,
  SEXES,
  VerificationStatus,
  boundedText,
  dateOfBirth,
  input,
  normalizeKenyanPhone,
  oneOf,
  optionalEmail,
  refuse,
  requireCaller,
  storageUrl,
  timestamp,
} from './common';
import { NAIROBI_COUNTY_ID, countyById, facilityById, nairobiSubCountyById } from './reference-data';

export interface Deps {
  db: Firestore;
  auth: AuthLike;
  bucket: string;
  now?: () => Date;
}

const NAME_MAX = 50;

interface Biodata {
  firstName: string;
  middleName: string;
  lastName: string;
  sex: string;
  dateOfBirth: string;
  phoneNumber: string;
  county: string;
  subCounty: string;
  geohash: string;
  language: string;
}

function biodata(data: Record<string, unknown>, now: Date): Biodata {
  const countyId = data.countyId;
  if (typeof countyId !== 'number' || !Number.isInteger(countyId)) {
    throw refuse('invalid-argument', 'invalidCounty');
  }
  const county = countyById(countyId);
  if (!county) throw refuse('invalid-argument', 'invalidCounty');

  // Outside Nairobi there is no sub-county list yet, so no area and no geohash (§6.2).
  let subCounty = '';
  let geohash = '';
  if (countyId === NAIROBI_COUNTY_ID) {
    const found =
      typeof data.subCountyId === 'number' ? nairobiSubCountyById(data.subCountyId) : undefined;
    if (!found) throw refuse('invalid-argument', 'invalidSubCounty');
    subCounty = found.name;
    geohash = found.geohash;
  }

  return {
    firstName: boundedText(data.firstName, 1, NAME_MAX, 'invalidName'),
    middleName: boundedText(data.middleName, 0, NAME_MAX, 'invalidName'),
    lastName: boundedText(data.lastName, 1, NAME_MAX, 'invalidName'),
    sex: oneOf(data.sex, SEXES, 'invalidSex'),
    dateOfBirth: dateOfBirth(data.dateOfBirth, now),
    phoneNumber: normalizeKenyanPhone(data.phoneNumber),
    county: county.name,
    subCounty,
    geohash,
    language: data.language === undefined ? 'en' : oneOf(data.language, LANGUAGES, 'invalidLanguage'),
  };
}

function patientRecord(
  fields: {
    patientId: string;
    uid: string;
    createdByUid: string;
    email: string;
    doctorUids: string[];
    at: string;
  },
  bio: Biodata,
): DocumentData {
  // Field order is the Freezed model's (§6.1).
  return {
    patientId: fields.patientId,
    uid: fields.uid,
    isRegistered: fields.uid !== '',
    createdByUid: fields.createdByUid,
    firstName: bio.firstName,
    middleName: bio.middleName,
    lastName: bio.lastName,
    sex: bio.sex,
    dateOfBirth: bio.dateOfBirth,
    phoneNumber: bio.phoneNumber,
    email: fields.email,
    profilePictureUrl: '',
    county: bio.county,
    subCounty: bio.subCounty,
    geohash: bio.geohash,
    doctorUids: fields.doctorUids,
    fcmTokens: [],
    language: bio.language,
    receiveNotifications: true,
    casesReported: 0,
    appointmentsBooked: 0,
    createdAt: fields.at,
    lastUpdatedAt: fields.at,
  };
}

/** Sets `role`, keeping any other claim (an admin who is also a doctor stays an admin). */
async function setRole(auth: AuthLike, uid: string, role: Role | null): Promise<void> {
  const user = await auth.getUser(uid);
  const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
  if (role === null) delete claims.role;
  else claims.role = role;
  await auth.setCustomUserClaims(uid, claims);
}

function duplicateQuery(db: Firestore, phoneNumber: string, dob: string) {
  return db
    .collection(PATIENTS)
    .where('phoneNumber', '==', phoneNumber)
    .where('dateOfBirth', '==', dob)
    .limit(10);
}

export type PatientSignUpResult =
  | { status: 'registered'; patientId: string }
  | { status: 'clinicRecordExists' };

export async function completePatientSignUpHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<PatientSignUpResult> {
  const c = requireCaller(caller);
  if (c.role !== '' && c.role !== 'patient') throw refuse('failed-precondition', 'roleAlreadySet');
  const now = (deps.now ?? (() => new Date()))();
  const bio = biodata(input(data), now);
  const { db } = deps;
  const ref = db.collection(PATIENTS).doc(c.uid);

  const result = await db.runTransaction(async (tx): Promise<PatientSignUpResult> => {
    // A retry after the claim failed to set finds its own record and finishes the job.
    if ((await tx.get(ref)).exists) return { status: 'registered', patientId: c.uid };
    if ((await tx.get(db.collection(DOCTORS).doc(c.uid))).exists) {
      throw refuse('failed-precondition', 'roleAlreadySet');
    }

    const matches = await tx.get(duplicateQuery(db, bio.phoneNumber, bio.dateOfBirth));
    // A phone number and a birth date are not proof of identity, so a match is never merged
    // into: the record's doctor links the account in person (T-15).
    if (matches.docs.some((d) => d.get('isRegistered') === false)) {
      return { status: 'clinicRecordExists' };
    }
    if (!matches.empty) throw refuse('already-exists', 'patientAlreadyRegistered');

    const at = timestamp(now);
    tx.create(
      ref,
      patientRecord(
        { patientId: c.uid, uid: c.uid, createdByUid: c.uid, email: c.email, doctorUids: [], at },
        bio,
      ),
    );
    return { status: 'registered', patientId: c.uid };
  });

  if (result.status === 'registered') await setRole(deps.auth, c.uid, 'patient');
  return result;
}

export async function addPatientHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'created' | 'alreadyInCare'; patientId: string }> {
  const c = requireCaller(caller);
  if (c.role !== 'doctor') throw refuse('permission-denied', 'doctorsOnly');
  const now = (deps.now ?? (() => new Date()))();
  const raw = input(data);
  const bio = biodata(raw, now);
  const email = optionalEmail(raw.email);
  const { db } = deps;

  return db.runTransaction(async (tx) => {
    const matches = await tx.get(duplicateQuery(db, bio.phoneNumber, bio.dateOfBirth));
    const mine = matches.docs.find((d) => (d.get('doctorUids') as string[]).includes(c.uid));
    if (mine) return { status: 'alreadyInCare' as const, patientId: mine.id };
    // Another doctor's patient: joining their care team is the patient's decision (T-16).
    if (!matches.empty) throw refuse('already-exists', 'patientExists');

    const ref = db.collection(PATIENTS).doc();
    tx.create(
      ref,
      patientRecord(
        { patientId: ref.id, uid: '', createdByUid: c.uid, email, doctorUids: [c.uid], at: timestamp(now) },
        bio,
      ),
    );
    return { status: 'created' as const, patientId: ref.id };
  });
}

/**
 * Attaches a registered account to a doctor-added record, with the patient in front of the
 * doctor. The account is one whose own sign-up was answered `clinicRecordExists`, so it has no
 * role and no record of its own.
 */
export async function linkPatientAccountHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'linked'; patientId: string }> {
  const c = requireCaller(caller);
  if (c.role !== 'doctor') throw refuse('permission-denied', 'doctorsOnly');
  const raw = input(data);
  const patientId = boundedText(raw.patientId, 1, 128, 'invalidPatient');
  const email = optionalEmail(raw.email);
  if (!email) throw refuse('invalid-argument', 'invalidEmail');

  let account: { uid: string; customClaims?: Record<string, unknown> };
  try {
    account = await deps.auth.getUserByEmail(email);
  } catch {
    throw refuse('not-found', 'accountNotFound');
  }
  if (typeof account.customClaims?.role === 'string') {
    throw refuse('failed-precondition', 'accountAlreadyHasRole');
  }

  const { db } = deps;
  const now = (deps.now ?? (() => new Date()))();
  await db.runTransaction(async (tx) => {
    const ref = db.collection(PATIENTS).doc(patientId);
    const record = await tx.get(ref);
    if (!record.exists || !(record.get('doctorUids') as string[]).includes(c.uid)) {
      throw refuse('not-found', 'invalidPatient');
    }
    if (record.get('isRegistered') === true) throw refuse('failed-precondition', 'alreadyLinked');
    const [ownRecord, linked, doctor] = await Promise.all([
      tx.get(db.collection(PATIENTS).doc(account.uid)),
      tx.get(db.collection(PATIENTS).where('uid', '==', account.uid).limit(1)),
      tx.get(db.collection(DOCTORS).doc(account.uid)),
    ]);
    if (ownRecord.exists || !linked.empty || doctor.exists) {
      throw refuse('failed-precondition', 'accountAlreadyHasRole');
    }
    tx.update(ref, {
      uid: account.uid,
      isRegistered: true,
      email,
      lastUpdatedAt: timestamp(now),
    });
  });

  await setRole(deps.auth, account.uid, 'patient');
  return { status: 'linked', patientId };
}

const TITLES = ['Dr.', 'Prof.', 'Mr.', 'Mrs.', 'Ms.'] as const;

export async function completePractitionerSignUpHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: VerificationStatus }> {
  const c = requireCaller(caller);
  if (c.role !== '') throw refuse('failed-precondition', 'roleAlreadySet');
  const raw = input(data);
  const now = (deps.now ?? (() => new Date()))();

  if (typeof raw.isPathologist !== 'boolean') throw refuse('invalid-argument', 'invalidRole');
  if (raw.termsAccepted !== true) throw refuse('failed-precondition', 'termsRequired');
  const kmpdcNumber = boundedText(raw.kmpdcNumber, 3, 30, 'invalidKmpdcNumber').toUpperCase();
  if (!/^[A-Z0-9/-]+$/.test(kmpdcNumber)) throw refuse('invalid-argument', 'invalidKmpdcNumber');

  const facilityId = boundedText(raw.facilityId, 1, 64, 'invalidFacility');
  const facility = facilityById(facilityId);
  if (!facility) throw refuse('invalid-argument', 'invalidFacility');
  if (!facility.isOperational) throw refuse('failed-precondition', 'facilityNotOperational');

  const at = timestamp(now);
  // Field order is the Freezed model's (§6.1).
  const record: DocumentData = {
    uid: c.uid,
    title: oneOf(raw.title, TITLES, 'invalidTitle'),
    firstName: boundedText(raw.firstName, 1, NAME_MAX, 'invalidName'),
    lastName: boundedText(raw.lastName, 1, NAME_MAX, 'invalidName'),
    email: c.email,
    phoneNumber: normalizeKenyanPhone(raw.phoneNumber),
    profilePictureUrl: storageUrl(raw.profilePictureUrl, deps.bucket, 'profilePictures', c.uid, 'invalidPicture', {
      allowEmpty: true,
    }),
    isPathologist: raw.isPathologist,
    specialization: boundedText(raw.specialization, 1, 80, 'invalidSpecialization'),
    bio: boundedText(raw.bio, 0, 1000, 'invalidBio'),
    kmpdcNumber,
    licenseUrl: storageUrl(raw.licenseUrl, deps.bucket, 'licenses', c.uid, 'invalidLicense', {
      allowEmpty: false,
    }),
    verificationStatus: 'Pending',
    facilityId: facility.facilityId,
    facilityMflCode: facility.mflCode,
    facilityName: facility.name,
    county: facility.county,
    subCounty: facility.subCounty,
    geohash: facility.geohash,
    isAvailable: true,
    fcmTokens: [],
    language: raw.language === undefined ? 'en' : oneOf(raw.language, LANGUAGES, 'invalidLanguage'),
    receiveNotifications: true,
    appointmentsHandled: 0,
    ordersCreated: 0,
    reportsSigned: 0,
    termsAcceptedAt: at,
    createdAt: at,
    lastUpdatedAt: at,
  };

  const { db } = deps;
  const ref = db.collection(DOCTORS).doc(c.uid);
  return db.runTransaction(async (tx) => {
    const existing = await tx.get(ref);
    if (existing.exists) return { status: existing.get('verificationStatus') as VerificationStatus };
    if ((await tx.get(db.collection(PATIENTS).doc(c.uid))).exists) {
      throw refuse('failed-precondition', 'roleAlreadySet');
    }
    const taken = await tx.get(db.collection(DOCTORS).where('kmpdcNumber', '==', kmpdcNumber).limit(1));
    if (!taken.empty) throw refuse('already-exists', 'kmpdcNumberInUse');
    tx.create(ref, record);
    return { status: 'Pending' as const };
  });
}

/** Admin only. The role claim follows the decision; a rejection removes any claim (T-14). */
export async function verifyPractitionerHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: VerificationStatus }> {
  const c = requireCaller(caller);
  if (!c.isAdmin) throw refuse('permission-denied', 'adminOnly');
  const raw = input(data);
  const uid = boundedText(raw.uid, 1, 128, 'invalidPractitioner');
  const decision = oneOf(raw.decision, ['Verified', 'Rejected'] as const, 'invalidDecision');
  const { db } = deps;
  const now = (deps.now ?? (() => new Date()))();

  const isPathologist = await db.runTransaction(async (tx) => {
    const ref = db.collection(DOCTORS).doc(uid);
    const doc = await tx.get(ref);
    if (!doc.exists) throw refuse('not-found', 'invalidPractitioner');
    // The number stays editable until verified, so uniqueness is checked again here.
    if (decision === 'Verified') {
      const holders = await tx.get(
        db.collection(DOCTORS).where('kmpdcNumber', '==', doc.get('kmpdcNumber')).limit(2),
      );
      if (holders.docs.some((d) => d.id !== uid)) throw refuse('already-exists', 'kmpdcNumberInUse');
    }
    tx.update(ref, { verificationStatus: decision, lastUpdatedAt: timestamp(now) });
    return doc.get('isPathologist') === true;
  });

  await setRole(deps.auth, uid, decision === 'Verified' ? (isPathologist ? 'pathologist' : 'doctor') : null);
  return { status: decision };
}

const PUBLIC_FIELDS = [
  'uid',
  'title',
  'firstName',
  'lastName',
  'profilePictureUrl',
  'isPathologist',
  'specialization',
  'bio',
] as const;

/**
 * Keeps `practitioners/{uid}` the public projection of a verified `doctors/{uid}`, and absent
 * otherwise. Facility fields come from the server's list, not from the document.
 */
export async function syncPractitionerHandler(
  db: Firestore,
  uid: string,
  after: DocumentData | undefined,
): Promise<'written' | 'removed'> {
  const ref = db.collection(PRACTITIONERS).doc(uid);
  if (!after || after.verificationStatus !== 'Verified') {
    await ref.delete();
    return 'removed';
  }
  const facility = facilityById(String(after.facilityId ?? ''));
  const entry: DocumentData = {};
  for (const key of PUBLIC_FIELDS) entry[key] = after[key];
  Object.assign(entry, {
    facilityId: facility?.facilityId ?? '',
    facilityMflCode: facility?.mflCode ?? '',
    facilityName: facility?.name ?? '',
    county: facility?.county ?? '',
    subCounty: facility?.subCounty ?? '',
    geohash: facility?.geohash ?? '',
    isAvailable: after.isAvailable === true,
    appointmentsHandled: after.appointmentsHandled ?? 0,
    ordersCreated: after.ordersCreated ?? 0,
    reportsSigned: after.reportsSigned ?? 0,
    lastUpdatedAt: after.lastUpdatedAt ?? '',
  });
  await ref.set(entry);
  return 'written';
}
