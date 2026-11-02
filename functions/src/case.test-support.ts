// cspell:ignore Wanjiru Kamau Amina Otieno Njeri Mwangi Achieng Odhiambo IHDR
// Test support, not a test: a clinic, its people and a case at any stage, built through the real
// handlers so a suite starts from a state the functions themselves can reach.
import { randomBytes, randomUUID } from 'node:crypto';

import { getStorage } from 'firebase-admin/storage';

import {
  acceptCaseHandler,
  createOrderHandler,
  recordSampleReceivedHandler,
  registerSlidesHandler,
  reserveSlideUploadsHandler,
} from './cases';
import { requiredQuestions, type Deps } from './case-support';
import { DOCTORS, PATIENTS, PRACTITIONERS, type Caller } from './common';
import { BUCKET, account, emulatorDeps } from './emulator.test-support';
import { signReportHandler, startReportHandler } from './reports';

export const HISTOLOGY = '9f7bb98a-1df9-4730-88b6-2226ffced0a0';

export interface World {
  deps: Deps;
  doctor: Caller;
  colleague: Caller;
  pathologist: Caller;
  otherPathologist: Caller;
  patient: Caller;
  patientId: string;
  appointmentUid: string;
}

function profile(uid: string, extra: Record<string, unknown>): Record<string, unknown> {
  return {
    uid,
    title: 'Dr.',
    firstName: 'Wanjiru',
    lastName: 'Kamau',
    kmpdcNumber: `K${uid.slice(0, 6).toUpperCase()}`,
    facilityName: 'Test Hospital',
    verificationStatus: 'Verified',
    isAvailable: true,
    language: 'en',
    ordersCreated: 0,
    reportsSigned: 0,
    ...extra,
  };
}

export async function seedWorld(extra: Partial<Deps> = {}): Promise<World> {
  const deps: Deps = { ...emulatorDeps(), shareCodeKey: randomBytes(32).toString('hex'), ...extra };
  const { db } = deps;
  const base = emulatorDeps();
  const doctor = await account(base, 'doctor@example.com', { role: 'doctor' });
  const colleague = await account(base, 'colleague@example.com', { role: 'doctor' });
  const pathologist = await account(base, 'path@example.com', { role: 'pathologist' });
  const otherPathologist = await account(base, 'path2@example.com', { role: 'pathologist' });
  const patient = await account(base, 'patient@example.com', { role: 'patient' });

  for (const [who, isPathologist, first] of [
    [doctor, false, 'Njeri'],
    [colleague, false, 'Mwangi'],
    [pathologist, true, 'Wanjiru'],
    [otherPathologist, true, 'Achieng'],
  ] as const) {
    await db.collection(DOCTORS).doc(who.uid).set(profile(who.uid, { isPathologist, firstName: first }));
    await db
      .collection(PRACTITIONERS)
      .doc(who.uid)
      .set({ uid: who.uid, isPathologist, isAvailable: true, firstName: first, lastName: 'Kamau', title: 'Dr.' });
  }

  const patientId = 'record-1';
  await db.collection(PATIENTS).doc(patientId).set({
    patientId,
    uid: patient.uid,
    isRegistered: true,
    firstName: 'Amina',
    middleName: '',
    lastName: 'Otieno',
    sex: 'Female',
    dateOfBirth: '1990-05-14',
    phoneNumber: '+254712345678',
    email: 'patient@example.com',
    county: 'Nairobi',
    subCounty: 'Westlands',
    doctorUids: [doctor.uid],
    language: 'sw',
    casesReported: 0,
  });
  const appointmentUid = 'appointment-1';
  await db.collection('appointments').doc(appointmentUid).set({
    uid: appointmentUid,
    doctorUid: doctor.uid,
    patientId,
    status: 'Accepted',
    caseUids: [],
  });
  return { deps, doctor, colleague, pathologist, otherPathologist, patient, patientId, appointmentUid };
}

export function orderInput(w: World, overrides: Record<string, unknown> = {}): Record<string, unknown> {
  return {
    caseUid: randomUUID(),
    appointmentUid: w.appointmentUid,
    patientId: w.patientId,
    labTestIds: [HISTOLOGY],
    priority: 'Routine',
    sampleCollectedAt: '2026-10-27T07:00:00.000Z',
    payment: { method: 'Cash' },
    clinicalNotes: 'Lump in the left breast for three months.',
    sampleNotes: '',
    ...overrides,
  };
}

/** An order naming `pathologist`, so the case waits at `PathologistRequested`. */
export async function requestedCase(w: World, overrides: Record<string, unknown> = {}): Promise<string> {
  const input = orderInput(w, { pathologistUid: w.pathologist.uid, ...overrides });
  await createOrderHandler(w.deps, w.doctor, input);
  return input.caseUid as string;
}

export async function acceptedCase(w: World, overrides: Record<string, unknown> = {}): Promise<string> {
  const caseUid = await requestedCase(w, overrides);
  await acceptCaseHandler(w.deps, w.pathologist, { caseUid });
  return caseUid;
}

export async function receivedCase(w: World, overrides: Record<string, unknown> = {}): Promise<string> {
  const caseUid = await acceptedCase(w, overrides);
  await recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'LAB/2026-001' });
  return caseUid;
}

/** A 33-byte PNG header: signature and a 400 x 100 `IHDR`, all the signature check reads. */
export function signaturePng(): string {
  const header = Buffer.alloc(33);
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]).copy(header, 0);
  header.writeUInt32BE(13, 8);
  header.write('IHDR', 12, 'latin1');
  header.writeUInt32BE(400, 16);
  header.writeUInt32BE(100, 20);
  return header.toString('base64');
}

/** A draft with every required answer, stamped as the client would stamp an edit. */
export async function fillDraft(
  w: World,
  caseUid: string,
  patch: Record<string, unknown> = {},
  stamp = '2026-10-27T08:30:00.000Z',
): Promise<string> {
  const ref = w.deps.db.collection('cases').doc(caseUid).collection('reportDrafts').doc(w.pathologist.uid);
  const template = ((await ref.get()).data()?.templateKey as string | undefined) ?? 'General';
  await ref.update({
    title: 'Breast core biopsy',
    diagnosis: 'Invasive ductal carcinoma, grade 2.',
    comments: 'Correlate clinically.',
    responses: requiredQuestions(template).map((question, order) => ({
      section: 'Findings',
      question,
      answer: 'Present',
      order,
    })),
    lastUpdatedAt: stamp,
    ...patch,
  });
  return stamp;
}

export async function startedReport(w: World, overrides: Record<string, unknown> = {}): Promise<string> {
  const caseUid = await receivedCase(w, overrides);
  await startReportHandler(w.deps, w.pathologist, { caseUid, kind: 'Initial' });
  return caseUid;
}

export async function caseDoc(w: World, caseUid: string): Promise<Record<string, unknown>> {
  return (await w.deps.db.collection('cases').doc(caseUid).get()).data() ?? {};
}

export async function docData(w: World, path: string): Promise<Record<string, unknown> | undefined> {
  return (await w.deps.db.doc(path).get()).data();
}

/** Puts a slide object where `registerSlides` looks for a JPEG; `contentType` can disagree. */
export async function putSlide(caseUid: string, imageUid: string, contentType = 'image/jpeg'): Promise<void> {
  const extension = 'jpg';
  await getStorage()
    .bucket(BUCKET)
    .file(`slides/${caseUid}/${imageUid}.${extension}`)
    .save(Buffer.from('slide'), { contentType, resumable: false });
}

/** A copy of the deps whose clock has moved on. */
export function later(deps: Deps, ms: number): Deps {
  const start = (deps.now ?? (() => new Date()))().getTime();
  return { ...deps, now: () => new Date(start + ms) };
}

export function noteId(template: string, resourceKey: string, recipientUid: string): string {
  return `notifications/${template}:${resourceKey}:${recipientUid}`;
}

export interface SignedCase {
  caseUid: string;
  reportUid: string;
  stamp: string;
}

/** A case with its first report signed: the doctor holds a pending unlock code for it. */
export async function signedCase(
  w: World,
  deps: Deps = w.deps,
  draft: Record<string, unknown> = {},
  order: Record<string, unknown> = {},
): Promise<SignedCase> {
  const caseUid = await startedReport(w, order);
  const stamp = await fillDraft(w, caseUid, draft);
  const result = await signReportHandler(deps, w.pathologist, {
    caseUid,
    draftLastUpdatedAt: stamp,
    signaturePng: signaturePng(),
  });
  return { caseUid, reportUid: result.reportUid, stamp };
}

/** The code is only ever in the recipient's inbox row; tests read it where the app would. */
export async function codeInRow(w: World, rowPath: string): Promise<string> {
  const row = await docData(w, rowPath);
  const code = (row?.metadata as { shareCode?: string } | undefined)?.shareCode;
  if (!code) throw new Error(`no share code in ${rowPath}`);
  return code;
}

export async function unlockCodeOf(w: World, signed: SignedCase): Promise<string> {
  return codeInRow(w, noteId('reportSigned', `${signed.caseUid}_${signed.reportUid}`, w.doctor.uid));
}

export function unlockUidOf(signed: SignedCase): string {
  return `unlock_${signed.caseUid}_${signed.reportUid}`;
}

/** A code that is not the one issued. */
export function wrongCode(right: string): string {
  return right === '0000' ? '1111' : '0000';
}

/** A case accepted with slides in and the pre-read switch on: it waits at `PrereadQueued`. */
export async function prereadQueuedCase(w: World): Promise<{ caseUid: string; runUid: string; deps: Deps }> {
  const deps: Deps = { ...w.deps, config: { enabled: (key: string) => key === 'preread_enabled' } };
  const caseUid = await requestedCase({ ...w, deps });
  const { imageUids } = await reserveSlideUploadsHandler(deps, w.doctor, { caseUid, count: 1 });
  await putSlide(caseUid, imageUids[0]);
  await registerSlidesHandler(deps, w.doctor, {
    caseUid,
    images: [{ imageUid: imageUids[0], contentType: 'image/jpeg', micronsPerPixel: 0.25 }],
  });
  await acceptCaseHandler(deps, w.pathologist, { caseUid });
  const runs = await w.deps.db.collection('cases').doc(caseUid).collection('preread').get();
  return { caseUid, runUid: runs.docs[0].id, deps };
}
