'use strict';

const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { initializeTestEnvironment } = require('@firebase/rules-unit-testing');
const { doc, setDoc } = require('firebase/firestore');
const { ref, uploadBytes } = require('firebase/storage');

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
    workingDays: [1, 2, 3, 4, 5],
    dayStartMinute: 480,
    dayEndMinute: 1020,
    busySlots: [],
    termsAcceptedAt: '2026-10-27T09:00:00.000Z',
    createdAt: '2026-10-27T09:00:00.000Z',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

function caseDoc(overrides = {}) {
  return {
    uid: 'case1',
    doctorUid: 'drOdhiambo',
    patientUid: 'amina',
    patientId: 'amina',
    pathologistUid: 'drWanjiru',
    requestedPathologistUid: '',
    participantUids: ['drOdhiambo', 'amina', 'drWanjiru'],
    currentStage: 'PathologistAccepted',
    // Bare uids, matching what reserveSlideUploads stores (C-20).
    slideUploadUids: ['slide1', 'slide2'],
    clinicalNotes: 'Notes',
    sampleNotes: '',
    sampleCollectedAt: '2026-10-20T08:00:00.000Z',
    releasedToPatient: false,
    resultState: 'Pending',
    currentReportUid: '',
    priority: 'Routine',
    labAccessionNo: '',
    discussionAppointmentUid: '',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

function draft(overrides = {}) {
  return {
    uid: 'drWanjiru',
    caseUid: 'case1',
    pathologistUid: 'drWanjiru',
    kind: 'Initial',
    status: 'Editing',
    baseReportUid: '',
    targetReportUid: 'v1',
    prereadRunUid: '',
    templateKey: 'General',
    title: '',
    diagnosisType: 'Final',
    diagnosis: '',
    comments: '',
    responses: [],
    labelOverrides: {},
    labelOverrideCount: 0,
    isCritical: false,
    addendumText: '',
    amendmentReason: '',
    diagnosisStartedAt: '',
    startedFromPreread: false,
    startedAt: '2026-10-27T09:00:00.000Z',
    signedReportUid: '',
    notifiableFindings: [],
    hintShownDiseaseIds: [],
    confirmatoryRequests: [],
    createdByUid: 'drWanjiru',
    language: 'en',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

function report(overrides = {}) {
  return {
    uid: 'v1',
    caseUid: 'case1',
    version: 1,
    stage: 'Initial',
    status: 'Signed',
    readerUids: ['drWanjiru', 'drOdhiambo'],
    releasedToPatient: false,
    pathologistUid: 'drWanjiru',
    doctorUid: 'drOdhiambo',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

function conversation(overrides = {}) {
  return {
    uid: 'conv1',
    type: 'Direct',
    status: 'Open',
    createdByUid: 'drOdhiambo',
    participantUids: ['drOdhiambo', 'amina'],
    members: {},
    lastMessageAt: '',
    createdAt: '2026-10-27T09:00:00.000Z',
    closedAt: '',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

// Lowercase UUID v4 mids (H-1). Keep stable so Storage paths and seeds match.
const MSG_TEXT = 'a0000000-0000-4000-8000-000000000001';
const MSG_IMAGE = 'a0000000-0000-4000-8000-000000000002';
const MSG_VOICE = 'a0000000-0000-4000-8000-000000000003';
const MSG_VOICE_PATIENT = 'a0000000-0000-4000-8000-000000000004';
const MSG_OTHER = 'a0000000-0000-4000-8000-000000000099';

function message(overrides = {}) {
  return {
    uid: MSG_TEXT,
    conversationUid: 'conv1',
    senderUid: 'drOdhiambo',
    kind: 'Text',
    text: 'Hello',
    attachmentPath: '',
    attachmentType: '',
    attachmentSize: 0,
    voiceDurationMs: 0,
    voicePeaks: [],
    transcriptShared: false,
    transcriptLanguage: '',
    transcriptStatus: 'None',
    identifierFlagged: false,
    inputMode: 'Typed',
    status: 'Sent',
    withheldReason: '',
    sentAt: '2026-10-28T09:00:00.000Z',
    deliveredAt: '',
    lastUpdatedAt: '2026-10-28T09:00:00.000Z',
    ...overrides,
  };
}

const at = { lastUpdatedAt: '2026-10-28T09:00:00.000Z' };
const PATIENT = { role: 'patient' };
const DOCTOR = { role: 'doctor' };
const PATHOLOGIST = { role: 'pathologist' };
const APPROVER = { admin: true, alertApprover: true };

let env;
let envUsers = 0;

async function setupEnv() {
  if (!env) {
    env = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: { rules: readFileSync(join(ROOT, 'firestore.rules'), 'utf8') },
      storage: { rules: readFileSync(join(ROOT, 'storage.rules'), 'utf8') },
    });
  }
  envUsers += 1;
  return env;
}

async function cleanupEnv() {
  envUsers -= 1;
  if (envUsers <= 0 && env) {
    await env.cleanup();
    env = undefined;
    envUsers = 0;
  }
}

async function clearAll() {
  await env.clearFirestore();
  await env.clearStorage();
}

async function seed(path, data) {
  await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
}

async function seedBytes(path, data, contentType) {
  await env.withSecurityRulesDisabled((ctx) =>
    uploadBytes(ref(ctx.storage(), path), data, { contentType }),
  );
}

const as = (uid, claims = {}) => env.authenticatedContext(uid, claims);
const db = (uid, claims) => as(uid, claims).firestore();
const storage = (uid, claims) => as(uid, claims).storage();

module.exports = {
  PROJECT_ID,
  BUCKET,
  url,
  patient,
  doctorProfile,
  caseDoc,
  draft,
  report,
  conversation,
  message,
  MSG_TEXT,
  MSG_IMAGE,
  MSG_VOICE,
  MSG_VOICE_PATIENT,
  MSG_OTHER,
  at,
  PATIENT,
  DOCTOR,
  PATHOLOGIST,
  APPROVER,
  setupEnv,
  cleanupEnv,
  clearAll,
  seed,
  seedBytes,
  as,
  db,
  storage,
  getEnv: () => env,
};
