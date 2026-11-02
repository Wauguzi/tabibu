/**
 * Creating people (architecture §6.1, CRQ-0014). Clients never create a `patients`, `doctors` or
 * `practitioners` document; these handlers do, after the checks Firestore rules cannot make (a
 * duplicate search, a facility lookup), and they set the role claim in the same step.
 */
import { FieldPath, type DocumentData, type Firestore } from 'firebase-admin/firestore';

import { syncCaseReaders } from './access';
import { loadVersions, str } from './case-support';
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
  requireVerifiedEmail,
  storageUrl,
  timestamp,
} from './common';
import { CaseState, commitCase } from './orchestrator';
import { buildQuery, queryById } from './queries';
import { NAIROBI_COUNTY_ID, countyById, facilityById, nairobiSubCountyById } from './reference-data';

export interface Deps {
  db: Firestore;
  auth: AuthLike;
  bucket: string;
  now?: () => Date;
}

const NAME_MAX = 50;

/** Monday to Friday, 08:00 to 17:00 Nairobi time, until the doctor chooses their own. */
export const DEFAULT_WORKING_DAYS = [1, 2, 3, 4, 5];
export const DEFAULT_DAY_START_MINUTE = 480;
export const DEFAULT_DAY_END_MINUTE = 1020;

export interface Availability {
  workingDays: number[];
  dayStartMinute: number;
  dayEndMinute: number;
  busySlots: string[];
}

/** What the public projection shows: the hours, with a missing or malformed field replaced by its default. */
export function availabilityOf(doctor: DocumentData, now: Date): Availability {
  const days = Array.isArray(doctor.workingDays)
    ? doctor.workingDays.filter((d): d is number => Number.isInteger(d) && d >= 1 && d <= 7)
    : [];
  const start = doctor.dayStartMinute;
  const end = doctor.dayEndMinute;
  const valid = typeof start === 'number' && typeof end === 'number' && start >= 0 && end <= 1440 && start < end;
  const cutoff = now.getTime();
  const slots = Array.isArray(doctor.busySlots) ? doctor.busySlots : [];
  return {
    workingDays: Array.isArray(doctor.workingDays) ? [...new Set(days)].sort() : [...DEFAULT_WORKING_DAYS],
    dayStartMinute: valid ? start : DEFAULT_DAY_START_MINUTE,
    dayEndMinute: valid ? end : DEFAULT_DAY_END_MINUTE,
    busySlots: slots
      .filter((slot): slot is string => typeof slot === 'string' && Date.parse(slot) > cutoff)
      .sort(),
  };
}

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
  // Re-read immediately before writing so a concurrent claim edit is not overwritten.
  const user = await auth.getUser(uid);
  const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
  if (role === null) delete claims.role;
  else claims.role = role;
  await auth.setCustomUserClaims(uid, claims);
}

function duplicateQuery(db: Firestore, phoneNumber: string, dob: string) {
  return buildQuery(db, queryById('patients.byPhoneAndDob'), [
    phoneNumber,
    dob,
  ]).limit(10);
}

function patientsByUid(db: Firestore, uid: string) {
  return buildQuery(db, queryById('patients.byUid'), [uid]).limit(1);
}

function doctorsByKmpdc(db: Firestore, kmpdcNumber: string, limit: number) {
  return buildQuery(db, queryById('doctors.byKmpdcNumber'), [kmpdcNumber]).limit(
    limit,
  );
}

export type PatientSignUpResult =
  | { status: 'registered'; patientId: string }
  | { status: 'clinicRecordExists' };

export async function completePatientSignUpHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<PatientSignUpResult> {
  const c = requireVerifiedEmail(requireCaller(caller));
  if (c.role !== '' && c.role !== 'patient') throw refuse('failed-precondition', 'roleAlreadySet');
  const now = (deps.now ?? (() => new Date()))();
  const bio = biodata(input(data), now);
  const { db } = deps;
  const ref = db.collection(PATIENTS).doc(c.uid);

  const result = await db.runTransaction(async (tx): Promise<PatientSignUpResult> => {
    // A retry after the claim failed to set finds its own record and finishes the job.
    if ((await tx.get(ref)).exists) return { status: 'registered', patientId: c.uid };
    // A record a doctor linked to this account has its own id: it is theirs already, and a
    // second record under the same uid would make their own record ambiguous.
    const linked = await tx.get(patientsByUid(db, c.uid));
    if (!linked.empty) return { status: 'registered', patientId: linked.docs[0].id };
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
): Promise<{ status: 'linked'; patientId: string; casesPending: boolean }> {
  const c = requireCaller(caller);
  if (c.role !== 'doctor') throw refuse('permission-denied', 'doctorsOnly');
  const raw = input(data);
  const patientId = boundedText(raw.patientId, 1, 128, 'invalidPatient');
  const email = optionalEmail(raw.email);
  if (!email) throw refuse('invalid-argument', 'invalidEmail');

  let account: { uid: string; emailVerified?: boolean; customClaims?: Record<string, unknown> };
  try {
    account = await deps.auth.getUserByEmail(email);
  } catch {
    throw refuse('not-found', 'accountNotFound');
  }
  // Anyone can open an account under a patient's address; only one whose owner confirmed it
  // may take their record (T-15).
  if (account.emailVerified !== true) throw refuse('failed-precondition', 'emailNotVerified');
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
    if (record.get('isRegistered') === true) {
      // Linked to this same account before the role could be set: finish it below.
      if (record.get('uid') === account.uid) return;
      throw refuse('failed-precondition', 'alreadyLinked');
    }
    const [ownRecord, linked, doctor] = await Promise.all([
      tx.get(db.collection(PATIENTS).doc(account.uid)),
      tx.get(patientsByUid(db, account.uid)),
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

  await startLinkJob(deps, patientId, account.uid);
  await setRole(deps.auth, account.uid, 'patient');
  // The record is linked and the role set by now, so a failure here is not the caller's to retry:
  // the job keeps its cursor and `resumeLinkJobs` finishes it.
  let finished = false;
  try {
    finished = await runLinkJob(deps, patientId, INLINE_PAGES);
  } catch {
    finished = false;
  }
  return { status: 'linked', patientId, casesPending: !finished };
}

export const LINK_PAGE = 20;
/** The call links this many pages itself; a longer history is finished by the resume sweep. */
const INLINE_PAGES = 5;

async function startLinkJob(deps: Deps, patientId: string, uid: string): Promise<void> {
  const ref = deps.db.collection('linkJobs').doc(patientId);
  const at = timestamp((deps.now ?? (() => new Date()))());
  await deps.db.runTransaction(async (tx) => {
    if ((await tx.get(ref)).exists) return;
    tx.create(ref, { patientId, uid, status: 'Running', cursor: '', casesLinked: 0, createdAt: at, lastUpdatedAt: at });
  });
}

/** One case per transaction: `patientUid`, the participants and the readers of every released version. */
async function linkCase(deps: Deps, caseUid: string, uid: string): Promise<boolean> {
  const { db } = deps;
  const now = (deps.now ?? (() => new Date()))();
  return db.runTransaction(async (tx) => {
    const ref = db.collection('cases').doc(caseUid);
    const snap = await tx.get(ref);
    if (!snap.exists) return false;
    const s = CaseState.from(snap);
    if (s.patientUid === uid) return false;
    const versions = await loadVersions(tx, ref);
    const next = s.with({ patientUid: uid });
    commitCase(tx, ref, next, now);
    syncCaseReaders(tx, next, versions.map((v) => v.access), now);
    return true;
  });
}

/**
 * Pages of {@link LINK_PAGE} cases by document id after the job's cursor. Resumable: the cursor
 * moves after each page, and linking a case twice changes nothing. True once the job is `Done`.
 */
export async function runLinkJob(deps: Deps, patientId: string, maxPages = Number.POSITIVE_INFINITY): Promise<boolean> {
  const { db } = deps;
  const jobRef = db.collection('linkJobs').doc(patientId);
  for (let page = 0; page < maxPages; page++) {
    const job = (await jobRef.get()).data();
    if (!job) return true;
    if (job.status === 'Done') return true;
    const cursor = str(job.cursor);
    let query = buildQuery(db, queryById('cases.byPatientId'), [patientId]).orderBy(FieldPath.documentId());
    if (cursor !== '') query = query.startAfter(cursor);
    const cases = await query.limit(LINK_PAGE).get();
    let linked = 0;
    for (const doc of cases.docs) {
      if (await linkCase(deps, doc.id, str(job.uid))) linked += 1;
    }
    const done = cases.size < LINK_PAGE;
    await jobRef.update({
      status: done ? 'Done' : 'Running',
      cursor: cases.docs.at(-1)?.id ?? cursor,
      casesLinked: Number(job.casesLinked ?? 0) + linked,
      lastUpdatedAt: timestamp((deps.now ?? (() => new Date()))()),
    });
    if (done) return true;
  }
  return false;
}

const TITLES = ['Dr.', 'Prof.', 'Mr.', 'Mrs.', 'Ms.'] as const;

/** A pathologist's specialties are the areas they report on, which decide the cases on their desk. */
export const PATHOLOGY_SPECIALTIES = [
  'Histopathology',
  'Cytology',
  'Haematology',
  'Microbiology',
  'Immunohistochemistry',
] as const;

/** A doctor's specialties, as patients search for them. */
export const CLINICAL_SPECIALTIES = [
  'General practice',
  'Family medicine',
  'Internal medicine',
  'General surgery',
  'Breast surgery',
  'Obstetrics and gynaecology',
  'Paediatrics',
  'Oncology',
  'Dermatology',
  'Ear, nose and throat',
  'Urology',
  'Gastroenterology',
  'Infectious diseases',
  'Cardiology',
  'Orthopaedics',
] as const;

export const MAX_SPECIALTIES = 5;

/** One or two files: the practising licence, and a certificate if there is one. */
export const MAX_LICENSE_FILES = 2;

function licenseUrls(raw: unknown, bucket: string, uid: string): string[] {
  if (!Array.isArray(raw) || raw.length < 1 || raw.length > MAX_LICENSE_FILES) {
    throw refuse('invalid-argument', 'invalidLicense');
  }
  const urls = raw.map((url) =>
    storageUrl(url, bucket, 'licenses', uid, 'invalidLicense', { allowEmpty: false }),
  );
  if (new Set(urls).size !== urls.length) throw refuse('invalid-argument', 'invalidLicense');
  return urls;
}

/** One to five, from the role's own list, stored in the list's order so a choice always reads the same. */
function specialties(raw: unknown, isPathologist: boolean): string[] {
  const allowed: readonly string[] = isPathologist ? PATHOLOGY_SPECIALTIES : CLINICAL_SPECIALTIES;
  if (!Array.isArray(raw) || raw.length < 1 || raw.length > MAX_SPECIALTIES) {
    throw refuse('invalid-argument', 'invalidSpecialties');
  }
  const chosen = raw.map((s) => oneOf(s, allowed, 'invalidSpecialties'));
  if (new Set(chosen).size !== chosen.length) throw refuse('invalid-argument', 'invalidSpecialties');
  return allowed.filter((s) => chosen.includes(s));
}

export async function completePractitionerSignUpHandler(
  deps: Deps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: VerificationStatus }> {
  const c = requireVerifiedEmail(requireCaller(caller));
  if (c.role !== '') throw refuse('failed-precondition', 'roleAlreadySet');
  const raw = input(data);
  const now = (deps.now ?? (() => new Date()))();

  if (typeof raw.isPathologist !== 'boolean') throw refuse('invalid-argument', 'invalidRole');
  const isPathologist = raw.isPathologist;
  if (raw.isAvailable !== undefined && typeof raw.isAvailable !== 'boolean') {
    throw refuse('invalid-argument', 'invalidAvailability');
  }
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
    // Patients choose a practitioner partly by face, so the photo is required.
    profilePictureUrl: storageUrl(raw.profilePictureUrl, deps.bucket, 'profilePictures', c.uid, 'invalidPicture', {
      allowEmpty: false,
    }),
    isPathologist,
    specialties: specialties(raw.specialties, isPathologist),
    bio: boundedText(raw.bio, 0, 1000, 'invalidBio'),
    kmpdcNumber,
    licenseUrls: licenseUrls(raw.licenseUrls, deps.bucket, c.uid),
    verificationStatus: 'Pending',
    facilityId: facility.facilityId,
    facilityMflCode: facility.mflCode,
    facilityName: facility.name,
    county: facility.county,
    subCounty: facility.subCounty,
    geohash: facility.geohash,
    isAvailable: raw.isAvailable !== false,
    workingDays: [...DEFAULT_WORKING_DAYS],
    dayStartMinute: DEFAULT_DAY_START_MINUTE,
    dayEndMinute: DEFAULT_DAY_END_MINUTE,
    busySlots: [],
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
    // A clinic record linked to this account has its own id, and the token that let this call
    // through may predate the link.
    const [ownRecord, linked] = await Promise.all([
      tx.get(db.collection(PATIENTS).doc(c.uid)),
      tx.get(patientsByUid(db, c.uid)),
    ]);
    if (ownRecord.exists || !linked.empty) throw refuse('failed-precondition', 'roleAlreadySet');
    const taken = await tx.get(doctorsByKmpdc(db, kmpdcNumber, 1));
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
  const c = requireVerifiedEmail(requireCaller(caller));
  if (!c.isAdmin) throw refuse('permission-denied', 'adminOnly');
  const raw = input(data);
  const uid = boundedText(raw.uid, 1, 128, 'invalidPractitioner');
  const decision = oneOf(raw.decision, ['Verified', 'Rejected'] as const, 'invalidDecision');
  const { db } = deps;
  const now = (deps.now ?? (() => new Date()))();

  await db.runTransaction(async (tx) => {
    const ref = db.collection(DOCTORS).doc(uid);
    const doc = await tx.get(ref);
    if (!doc.exists) throw refuse('not-found', 'invalidPractitioner');
    // The number stays editable until verified, so uniqueness is checked again here.
    if (decision === 'Verified') {
      const holders = await tx.get(
        doctorsByKmpdc(db, doc.get('kmpdcNumber') as string, 2),
      );
      if (holders.docs.some((d) => d.id !== uid)) throw refuse('already-exists', 'kmpdcNumberInUse');
    }
    tx.update(ref, { verificationStatus: decision, lastUpdatedAt: timestamp(now) });
  });

  await settleRole(deps, uid);
  return { status: decision };
}

/**
 * Sets the role claim from the stored decision rather than the caller's, and reads it again after
 * each write: a decision committed while another call's claim write was in flight is then always
 * the one the claim ends on, so a rejected practitioner never keeps the role (T-14).
 */
async function settleRole(deps: Deps, uid: string): Promise<void> {
  const ref = deps.db.collection(DOCTORS).doc(uid);
  let written: Role | null | undefined;
  for (let attempt = 0; attempt < 5; attempt++) {
    const doc = await ref.get();
    const role: Role | null =
      doc.get('verificationStatus') === 'Verified' ? (doc.get('isPathologist') === true ? 'pathologist' : 'doctor') : null;
    if (role === written) return;
    await setRole(deps.auth, uid, role);
    written = role;
  }
  throw refuse('aborted', 'decisionsRacing');
}

const PUBLIC_FIELDS = [
  'uid',
  'title',
  'firstName',
  'lastName',
  'profilePictureUrl',
  'isPathologist',
  'specialties',
  'bio',
] as const;

/**
 * Keeps `practitioners/{uid}` the public projection of a verified `doctors/{uid}`, and absent
 * otherwise. Facility fields come from the server's list, not from the document. Triggers arrive
 * late and out of order, so the profile is read as it stands now rather than taken from the
 * event: a stale "Verified" never republishes a practitioner since rejected (T-14).
 */
export async function syncPractitionerHandler(
  db: Firestore,
  uid: string,
  now: Date = new Date(),
): Promise<'written' | 'removed'> {
  const ref = db.collection(PRACTITIONERS).doc(uid);
  return db.runTransaction(async (tx) => {
    const after = (await tx.get(db.collection(DOCTORS).doc(uid))).data();
    if (!after || after.verificationStatus !== 'Verified') {
      tx.delete(ref);
      return 'removed' as const;
    }
    const facility = facilityById(String(after.facilityId ?? ''));
    const entry: DocumentData = {};
    // A profile written before a field existed has no value for it; Firestore refuses undefined.
    for (const key of PUBLIC_FIELDS) entry[key] = after[key] ?? (key === 'specialties' ? [] : '');
    Object.assign(entry, {
      facilityId: facility?.facilityId ?? '',
      facilityMflCode: facility?.mflCode ?? '',
      facilityName: facility?.name ?? '',
      county: facility?.county ?? '',
      subCounty: facility?.subCounty ?? '',
      geohash: facility?.geohash ?? '',
      isAvailable: after.isAvailable === true,
      ...availabilityOf(after, now),
      appointmentsHandled: after.appointmentsHandled ?? 0,
      ordersCreated: after.ordersCreated ?? 0,
      reportsSigned: after.reportsSigned ?? 0,
      lastUpdatedAt: after.lastUpdatedAt ?? '',
    });
    tx.set(ref, entry);
    return 'written' as const;
  });
}
