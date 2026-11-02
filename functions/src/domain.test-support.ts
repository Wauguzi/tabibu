// cspell:ignore Wambui Kiprop mvhd
// Test support, not a test: the appointment, conversation, push and staff suites share a runtime
// deps builder, a second patient, Storage helpers and the fixed slots below.
import { randomUUID } from 'node:crypto';

import { getAuth } from 'firebase-admin/auth';
import { getStorage } from 'firebase-admin/storage';

import { stubDomainAiClient } from './ai-domain';
import { DOCTORS, PATIENTS, type Caller } from './common';
import type { ConfigReader } from './config';
import type { World } from './case.test-support';
import { BUCKET, account, emulatorDeps } from './emulator.test-support';
import type { RuntimeDeps, StaffAuthLike } from './runtime-deps';

/** Wednesday 10:00 and 10:30 Nairobi time, inside the default hours and a day after the suite's clock. */
export const SLOT = '2026-10-28T07:00:00.000Z';
export const SLOT_2 = '2026-10-28T07:30:00.000Z';

export const allOn: ConfigReader = { enabled: () => true };
export const allOff: ConfigReader = { enabled: () => false };

export function runtime(w: World, extra: Partial<RuntimeDeps> = {}): RuntimeDeps {
  return {
    db: w.deps.db,
    auth: getAuth() as StaffAuthLike,
    bucket: BUCKET,
    now: w.deps.now,
    config: allOn,
    ai: stubDomainAiClient,
    storage: getStorage(),
    ...extra,
  };
}

/** The same deps with a clock `ms` ahead. */
export function ahead(deps: RuntimeDeps, ms: number): RuntimeDeps {
  const start = (deps.now ?? (() => new Date()))().getTime();
  return { ...deps, now: () => new Date(start + ms) };
}

/** A clock far enough ahead of the real one for an object just saved to look old. */
export function farAhead(deps: RuntimeDeps, ms: number): RuntimeDeps {
  return { ...deps, now: () => new Date(Date.now() + ms) };
}

export async function secondPatient(
  w: World,
  email = 'patient2@example.com',
  patientId = 'record-2',
): Promise<{ caller: Caller; patientId: string }> {
  const caller = await account(emulatorDeps(), email, { role: 'patient' });
  await w.deps.db.collection(PATIENTS).doc(patientId).set({
    patientId,
    uid: caller.uid,
    isRegistered: true,
    firstName: 'Wambui',
    middleName: '',
    lastName: 'Kiprop',
    sex: 'Female',
    dateOfBirth: '1985-02-03',
    phoneNumber: '+254722000111',
    email,
    county: 'Nairobi',
    doctorUids: [],
    language: 'en',
    appointmentsBooked: 0,
  });
  return { caller, patientId };
}

export function bucket() {
  return getStorage().bucket(BUCKET);
}

export async function putObject(path: string, bytes: Buffer, contentType: string): Promise<void> {
  await bucket().file(path).save(bytes, { contentType, resumable: false });
}

export async function objectExists(path: string): Promise<boolean> {
  const [exists] = await bucket().file(path).exists();
  return exists;
}

/** Just enough of an m4a for `measureM4aMs`: a movie header with a one-second-per-1000 timescale. */
export function m4aOf(seconds: number): Buffer {
  const bytes = Buffer.alloc(40);
  bytes.write('mvhd', 4, 'latin1');
  bytes.writeUInt32BE(1000, 20);
  bytes.writeUInt32BE(Math.round(seconds * 1000), 24);
  return bytes;
}

export async function doctorDoc(w: World, uid: string): Promise<Record<string, unknown>> {
  return (await w.deps.db.collection(DOCTORS).doc(uid).get()).data() ?? {};
}

export const newId = (): string => randomUUID();
