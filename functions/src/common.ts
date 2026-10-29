import { HttpsError, FunctionsErrorCode, CallableRequest } from 'firebase-functions/v2/https';

export const PATIENTS = 'patients';
export const DOCTORS = 'doctors';
export const PRACTITIONERS = 'practitioners';

export type Role = 'patient' | 'doctor' | 'pathologist';
export type VerificationStatus = 'Pending' | 'Verified' | 'Rejected';

/** The signed-in caller as the handlers see it, taken from the verified ID token. */
export interface Caller {
  uid: string;
  email: string;
  /** Firebase sets it once the address is confirmed; Google accounts arrive confirmed. */
  emailVerified: boolean;
  role: string;
  isAdmin: boolean;
}

export function callerOf(request: CallableRequest): Caller | null {
  if (!request.auth) return null;
  const token = request.auth.token;
  return {
    uid: request.auth.uid,
    email: typeof token.email === 'string' ? token.email.toLowerCase() : '',
    emailVerified: token.email_verified === true,
    role: typeof token.role === 'string' ? token.role : '',
    isAdmin: token.admin === true,
  };
}

/** The part of the Admin Auth SDK the handlers use, narrowed so a test can see every call. */
export interface AuthLike {
  setCustomUserClaims(uid: string, claims: Record<string, unknown> | null): Promise<void>;
  getUser(uid: string): Promise<{ uid: string; email?: string; customClaims?: Record<string, unknown> }>;
  getUserByEmail(email: string): Promise<{ uid: string; email?: string; customClaims?: Record<string, unknown> }>;
}

/**
 * The message is a stable reason key, never prose: the app maps it to a translated `AppError`,
 * so it must not change once a client ships.
 */
export function refuse(code: FunctionsErrorCode, reason: string): HttpsError {
  return new HttpsError(code, reason);
}

export function requireCaller(caller: Caller | null): Caller {
  if (!caller || !caller.uid) throw refuse('unauthenticated', 'unauthenticated');
  if (!caller.email) throw refuse('failed-precondition', 'emailRequired');
  return caller;
}

/** Self sign-up only: a profile is never created for an address nobody has confirmed. */
export function requireVerifiedEmail(caller: Caller): Caller {
  if (!caller.emailVerified) throw refuse('failed-precondition', 'emailNotVerified');
  return caller;
}

export function input(data: unknown): Record<string, unknown> {
  return data !== null && typeof data === 'object' ? (data as Record<string, unknown>) : {};
}

export function boundedText(raw: unknown, min: number, max: number, reason: string): string {
  if (raw === undefined && min === 0) return '';
  if (typeof raw !== 'string') throw refuse('invalid-argument', reason);
  const text = raw.trim().replace(/\s+/g, ' ');
  if (text.length < min || text.length > max) throw refuse('invalid-argument', reason);
  return text;
}

/** Kenyan numbers in any common spelling (07…, 01…, 2547…, +2547…) to E.164. */
export function normalizeKenyanPhone(raw: unknown): string {
  if (typeof raw !== 'string') throw refuse('invalid-argument', 'invalidPhone');
  const digits = raw.replace(/[\s\-().]/g, '');
  const match = /^(?:\+?254|0)([17]\d{8})$/.exec(digits);
  if (!match) throw refuse('invalid-argument', 'invalidPhone');
  return `+254${match[1]}`;
}

export function optionalEmail(raw: unknown): string {
  if (raw === undefined || raw === '') return '';
  if (typeof raw !== 'string') throw refuse('invalid-argument', 'invalidEmail');
  const email = raw.trim().toLowerCase();
  if (email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw refuse('invalid-argument', 'invalidEmail');
  }
  return email;
}

export const SEXES = ['Male', 'Female'] as const;
export const LANGUAGES = ['en', 'sw'] as const;

export function oneOf<T extends string>(raw: unknown, allowed: readonly T[], reason: string): T {
  if (typeof raw !== 'string' || !(allowed as readonly string[]).includes(raw)) {
    throw refuse('invalid-argument', reason);
  }
  return raw as T;
}

/** A calendar date, `YYYY-MM-DD`, not in the future and at most 130 years ago. */
export function dateOfBirth(raw: unknown, now: Date): string {
  if (typeof raw !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
    throw refuse('invalid-argument', 'invalidDateOfBirth');
  }
  const date = new Date(`${raw}T00:00:00.000Z`);
  if (Number.isNaN(date.getTime()) || date.toISOString().slice(0, 10) !== raw) {
    throw refuse('invalid-argument', 'invalidDateOfBirth');
  }
  const oldest = new Date(now);
  oldest.setUTCFullYear(now.getUTCFullYear() - 130);
  if (date > now || date < oldest) throw refuse('invalid-argument', 'invalidDateOfBirth');
  return raw;
}

/** The single timestamp format: ISO-8601 UTC, which sorts as a string (architecture §6). */
export function timestamp(now: Date): string {
  return now.toISOString();
}

/**
 * A download URL for an object under `<folder>/<owner>/` in this project's bucket. The URL's
 * token is what grants reading, so a client must not be able to point a profile at someone
 * else's file or at another host.
 */
export function storageUrl(
  raw: unknown,
  bucket: string,
  folder: string,
  owner: string,
  reason: string,
  { allowEmpty }: { allowEmpty: boolean },
): string {
  if ((raw === undefined || raw === '') && allowEmpty) return '';
  if (typeof raw !== 'string' || raw.length > 2048) throw refuse('invalid-argument', reason);
  let url: URL;
  try {
    url = new URL(raw);
  } catch {
    throw refuse('invalid-argument', reason);
  }
  const hosted = url.protocol === 'https:' && url.hostname === 'firebasestorage.googleapis.com';
  const emulated =
    process.env.FUNCTIONS_EMULATOR === 'true' &&
    url.protocol === 'http:' &&
    ['127.0.0.1', 'localhost'].includes(url.hostname);
  const prefix = `/v0/b/${bucket}/o/${folder}%2F${owner}%2F`;
  if (!(hosted || emulated) || !url.pathname.startsWith(prefix) || url.pathname.length === prefix.length) {
    throw refuse('invalid-argument', reason);
  }
  return raw;
}
