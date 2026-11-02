/**
 * The identity callables that arrived with appointments, alerts and push (plan §3.4 "Identity"):
 * a patient's area, a staff device token, the approver registry, and the one-off availability
 * backfill. Sign-up and linking stay in `identity.ts`.
 */
import { FieldPath, type DocumentData, type Firestore } from 'firebase-admin/firestore';

import { str, strings } from './case-support';
import {
  Caller,
  LANGUAGES,
  boundedText,
  input,
  oneOf,
  refuse,
  requireCaller,
  timestamp,
} from './common';
import { DEFAULT_DAY_END_MINUTE, DEFAULT_DAY_START_MINUTE, DEFAULT_WORKING_DAYS, runLinkJob } from './identity';
import { buildQuery, queryById } from './queries';
import { NAIROBI_COUNTY_ID, countyById, nairobiSubCountyById } from './reference-data';
import { MINUTE_MS, nowOf, type RuntimeDeps } from './runtime-deps';

export const MAX_STAFF_TOKENS = 5;
export const BACKFILL_PAGE = 100;
const LINK_RESUME_AFTER_MS = 5 * MINUTE_MS;
const LINK_RESUME_LIMIT = 100;
const COUNTY_IDS = Array.from({ length: 47 }, (_, i) => i + 1);

type ExtrasDeps = Pick<RuntimeDeps, 'db' | 'now'>;
type AdminDeps = Pick<RuntimeDeps, 'db' | 'now' | 'auth'>;

// --- updatePatientArea -----------------------------------------------------------------------

/**
 * The only way a patient's county changes (T-9). The record is found by `uid`, never by an id the
 * caller sends, so a care team cannot move a clinic record they do not own.
 */
export async function updatePatientAreaHandler(
  deps: ExtrasDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ county: string; subCounty: string }> {
  const c = requireCaller(caller);
  if (c.role !== 'patient') throw refuse('permission-denied', 'patientsOnly');
  const raw = input(data);
  const countyId = raw.countyId;
  const county = typeof countyId === 'number' && Number.isInteger(countyId) ? countyById(countyId) : undefined;
  if (!county) throw refuse('invalid-argument', 'invalidCounty');
  let subCounty = '';
  let geohash = '';
  if (county.id === NAIROBI_COUNTY_ID) {
    const found = typeof raw.subCountyId === 'number' ? nairobiSubCountyById(raw.subCountyId) : undefined;
    if (!found) throw refuse('invalid-argument', 'invalidSubCounty');
    subCounty = found.name;
    geohash = found.geohash;
  }
  const { db } = deps;
  const now = nowOf(deps);
  return db.runTransaction(async (tx) => {
    const found = await tx.get(buildQuery(db, queryById('patients.byUid'), [c.uid]).limit(1));
    if (found.empty) throw refuse('not-found', 'invalidPatient');
    tx.update(found.docs[0].ref, { county: county.name, subCounty, geohash, lastUpdatedAt: timestamp(now) });
    return { county: county.name, subCounty };
  });
}

// --- registerStaffToken ----------------------------------------------------------------------

async function requireApprover(db: Firestore, uid: string): Promise<void> {
  if (!(await db.collection('alertApprovers').doc(uid).get()).exists) throw refuse('permission-denied', 'notApprover');
}

/** A staff device's push token goes on the approver's registry row, which `sendPush` reads. */
export async function registerStaffTokenHandler(
  deps: ExtrasDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'ok' }> {
  const c = requireCaller(caller);
  if (!c.isAdmin) throw refuse('permission-denied', 'notAdmin');
  const raw = input(data);
  const token = boundedText(raw.token, 20, 4096, 'invalidToken');
  const language = raw.language === undefined ? 'en' : oneOf(raw.language, LANGUAGES, 'invalidLanguage');
  const { db } = deps;
  const ref = db.collection('alertApprovers').doc(c.uid);
  const now = nowOf(deps);
  return db.runTransaction(async (tx) => {
    const row = (await tx.get(ref)).data();
    if (!row) throw refuse('permission-denied', 'notApprover');
    const tokens = [...strings(row.fcmTokens).filter((t) => t !== token), token].slice(-MAX_STAFF_TOKENS);
    tx.update(ref, { fcmTokens: tokens, language, lastUpdatedAt: timestamp(now) });
    return { status: 'ok' as const };
  });
}

// --- setAlertApprover ------------------------------------------------------------------------

/**
 * Only a different approver may grant or revoke (F-6). The claim keeps the target's other claims;
 * a revoke removes the registry row first, so the server refuses the person at once, and then
 * ends their sessions so the old claim does not outlive its token.
 */
export async function setAlertApproverHandler(
  deps: AdminDeps,
  caller: Caller | null,
  data: unknown,
): Promise<{ status: 'granted' | 'revoked' }> {
  const c = requireCaller(caller);
  if (!c.isAdmin) throw refuse('permission-denied', 'notAdmin');
  const raw = input(data);
  const target = boundedText(raw.uid, 1, 128, 'invalidUser');
  if (typeof raw.grant !== 'boolean') throw refuse('invalid-argument', 'invalidGrant');
  const grant = raw.grant;
  if (target === c.uid) throw refuse('permission-denied', 'selfGrant');
  const { db, auth } = deps;
  if (!auth) throw refuse('internal', 'unavailable');
  await requireApprover(db, c.uid);

  let user: Awaited<ReturnType<typeof auth.getUser>>;
  try {
    user = await auth.getUser(target);
  } catch {
    throw refuse('not-found', 'invalidUser');
  }
  // Only a grant needs the target to be an admin: a revoke must still work after they lose it.
  if (grant && user.customClaims?.admin !== true) throw refuse('failed-precondition', 'notAdmin');

  const ref = db.collection('alertApprovers').doc(target);
  const now = nowOf(deps);
  const at = timestamp(now);
  const registry = async (): Promise<void> => {
    await db.runTransaction(async (tx) => {
      const [mine, row] = await Promise.all([tx.get(db.collection('alertApprovers').doc(c.uid)), tx.get(ref)]);
      if (!mine.exists) throw refuse('permission-denied', 'notApprover');
      if (!grant) {
        if (row.exists) tx.delete(ref);
      } else if (!row.exists) {
        tx.create(ref, { uid: target, fcmTokens: [], language: 'en', grantedByUid: c.uid, grantedAt: at, lastUpdatedAt: at });
      }
    });
  };
  const setClaim = async (): Promise<void> => {
    const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
    if (grant) claims.alertApprover = true;
    else delete claims.alertApprover;
    await auth.setCustomUserClaims(target, claims);
    const after = (await auth.getUser(target)).customClaims?.alertApprover === true;
    if (after !== grant) throw refuse('aborted', 'claimNotSet');
  };

  if (grant) {
    // The claim without a row is refused at every approver check, so it is safe to go first.
    await setClaim();
    await registry();
  } else {
    await registry();
    await setClaim();
    await auth.revokeRefreshTokens(target);
  }
  return { status: grant ? 'granted' : 'revoked' };
}

// --- backfillAvailability --------------------------------------------------------------------

export interface BackfillResult {
  collection: 'doctors' | 'patients';
  scanned: number;
  updated: number;
  /** Documents whose county name does not resolve: by count and id only (F-20). */
  unknownCounty: { count: number; ids: string[] };
  nextCursor: string;
}

/**
 * Admin only, idempotent, 100 a page by document id. Writes the four availability defaults onto
 * each doctor that lacks them (which re-fires `syncPractitioner`) and audits county names on both
 * collections. A caller walks the pages with `nextCursor` until it comes back empty.
 */
export async function backfillAvailabilityHandler(
  deps: ExtrasDeps,
  caller: Caller | null,
  data: unknown,
): Promise<BackfillResult> {
  const c = requireCaller(caller);
  if (!c.isAdmin) throw refuse('permission-denied', 'notAdmin');
  const raw = input(data);
  const collection = raw.collection === undefined ? 'doctors' : oneOf(raw.collection, ['doctors', 'patients'] as const, 'invalidCollection');
  const cursor = raw.cursor === undefined ? '' : boundedText(raw.cursor, 0, 128, 'invalidCursor');
  const { db } = deps;
  const now = nowOf(deps);
  const names = new Set(COUNTY_IDS.map((id) => countyById(id)?.name).filter((n): n is string => n !== undefined));

  let query = buildQuery(db, queryById(`${collection}.all`), []).orderBy(FieldPath.documentId());
  if (cursor !== '') query = query.startAfter(cursor);
  const page = await query.limit(BACKFILL_PAGE).get();

  const unknown: string[] = [];
  let updated = 0;
  for (const doc of page.docs) {
    const county = str(doc.get('county'));
    if (!names.has(county)) unknown.push(doc.id);
    if (collection === 'doctors' && (await fillAvailability(db, doc.ref.id, now))) updated += 1;
  }
  return {
    collection,
    scanned: page.size,
    updated,
    unknownCounty: { count: unknown.length, ids: unknown },
    nextCursor: page.size < BACKFILL_PAGE ? '' : (page.docs.at(-1)?.id ?? ''),
  };
}

async function fillAvailability(db: Firestore, uid: string, now: Date): Promise<boolean> {
  const ref = db.collection('doctors').doc(uid);
  return db.runTransaction(async (tx) => {
    const doctor = (await tx.get(ref)).data();
    if (!doctor) return false;
    const patch: DocumentData = {};
    if (!Array.isArray(doctor.workingDays)) patch.workingDays = [...DEFAULT_WORKING_DAYS];
    if (typeof doctor.dayStartMinute !== 'number') patch.dayStartMinute = DEFAULT_DAY_START_MINUTE;
    if (typeof doctor.dayEndMinute !== 'number') patch.dayEndMinute = DEFAULT_DAY_END_MINUTE;
    if (!Array.isArray(doctor.busySlots)) patch.busySlots = [];
    if (Object.keys(patch).length === 0) return false;
    tx.update(ref, { ...patch, lastUpdatedAt: timestamp(now) });
    return true;
  });
}

// --- resumeLinkJobs --------------------------------------------------------------------------

/** `sweepCases` does not resume account links, so this schedule does (plan §3.6, F-23). */
export async function resumeLinkJobsHandler(
  deps: Pick<RuntimeDeps, 'db' | 'now' | 'auth' | 'bucket'>,
): Promise<{ resumed: number; failed: number }> {
  const { db, auth } = deps;
  if (!auth) return { resumed: 0, failed: 0 };
  const cutoff = timestamp(new Date(nowOf(deps).getTime() - LINK_RESUME_AFTER_MS));
  const stalled = await buildQuery(db, queryById('linkJobs.stalled'), ['Running', cutoff]).limit(LINK_RESUME_LIMIT).get();
  let resumed = 0;
  let failed = 0;
  for (const job of stalled.docs) {
    // One broken job must not hold up the ones behind it; the id is a patient's, so it is not named.
    try {
      await runLinkJob({ db, auth, bucket: deps.bucket, now: deps.now }, job.id, 5);
      resumed += 1;
    } catch {
      failed += 1;
    }
  }
  return { resumed, failed };
}
