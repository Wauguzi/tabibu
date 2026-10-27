// Test support, not a test: the handler suites run against the Firestore and Auth emulators
// (`make functions-test`), so transactions and queries behave as they do in production.
import { getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

import type { Caller } from './common';
import type { Deps } from './identity';

// A `demo-` project id cannot reach a real project, whatever the environment says.
export const PROJECT_ID = 'demo-tabibu';
export const BUCKET = `${PROJECT_ID}.appspot.com`;

export function emulatorDeps(now = new Date('2026-10-27T09:00:00.000Z')): Deps {
  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
    throw new Error('Run through `make functions-test`, which starts the emulators.');
  }
  if (getApps().length === 0) initializeApp({ projectId: PROJECT_ID });
  return { db: getFirestore(), auth: getAuth(), bucket: BUCKET, now: () => now };
}

export async function resetEmulators(): Promise<void> {
  const firestore = process.env.FIRESTORE_EMULATOR_HOST;
  const auth = process.env.FIREBASE_AUTH_EMULATOR_HOST;
  await fetch(`http://${firestore}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`, {
    method: 'DELETE',
  });
  await fetch(`http://${auth}/emulator/v1/projects/${PROJECT_ID}/accounts`, { method: 'DELETE' });
}

/** An Auth account and the caller its ID token would produce. */
export async function account(
  deps: Deps,
  email: string,
  claims: Record<string, unknown> = {},
): Promise<Caller> {
  const user = await getAuth().createUser({ email, password: 'test-password-2026' });
  if (Object.keys(claims).length > 0) await deps.auth.setCustomUserClaims(user.uid, claims);
  return {
    uid: user.uid,
    email,
    role: typeof claims.role === 'string' ? claims.role : '',
    isAdmin: claims.admin === true,
  };
}

export async function claimsOf(uid: string): Promise<Record<string, unknown>> {
  return (await getAuth().getUser(uid)).customClaims ?? {};
}

export function downloadUrl(folder: string, owner: string, file: string): string {
  return `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${folder}%2F${owner}%2F${file}?alt=media&token=t`;
}

export async function refusedWith(promise: Promise<unknown>, reason: string): Promise<void> {
  try {
    await promise;
  } catch (e) {
    if ((e as Error).message === reason) return;
    throw new Error(`expected refusal "${reason}", got "${(e as Error).message}"`);
  }
  throw new Error(`expected refusal "${reason}", but it succeeded`);
}
