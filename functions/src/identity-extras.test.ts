import assert from 'node:assert/strict';

import { DOCTORS, PATIENTS } from './common';
import { seedWorld, type World } from './case.test-support';
import { ahead, runtime } from './domain.test-support';
import {
  account,
  claimsOf,
  emulatorDeps,
  refused,
  refusedWith,
  resetEmulators,
  callerWithoutRole,
} from './emulator.test-support';
import {
  DEFAULT_DAY_END_MINUTE,
  DEFAULT_DAY_START_MINUTE,
  DEFAULT_WORKING_DAYS,
} from './identity';
import { LINK_PAGE, linkPatientAccountHandler } from './identity';
import {
  BACKFILL_PAGE,
  backfillAvailabilityHandler,
  registerStaffTokenHandler,
  resumeLinkJobsHandler,
  setAlertApproverHandler,
  updatePatientAreaHandler,
} from './identity-extras';
import { MINUTE_MS, type RuntimeDeps, type StaffAuthLike } from './runtime-deps';

const WESTLANDS = 30;
const KAJIADO = 34;
const TOKEN = 'fcm-token-abcdefghijklmnopqrstuvwxyz';

describe('identity extras', () => {
  let w: World;
  let deps: RuntimeDeps;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
    deps = runtime(w);
  });

  describe('updatePatientArea', () => {
    it('moves the caller’s own record by uid, never by an id they send', async () => {
      const result = await updatePatientAreaHandler(deps, w.patient, {
        countyId: KAJIADO,
        patientId: 'spoofed',
      });
      assert.deepEqual(result, { county: 'Kajiado', subCounty: '' });
      const doc = (await w.deps.db.collection(PATIENTS).doc(w.patientId).get()).data()!;
      assert.equal(doc.county, 'Kajiado');
      assert.equal(doc.subCounty, '');
      assert.equal(doc.geohash, '');
    });

    it('requires a Nairobi sub-county inside Nairobi', async () => {
      await refusedWith(updatePatientAreaHandler(deps, w.patient, { countyId: 47 }), 'invalidSubCounty');
      const result = await updatePatientAreaHandler(deps, w.patient, {
        countyId: 47,
        subCountyId: WESTLANDS,
      });
      assert.deepEqual(result, { county: 'Nairobi', subCounty: 'Westlands' });
      const doc = (await w.deps.db.collection(PATIENTS).doc(w.patientId).get()).data()!;
      assert.equal(doc.geohash.length, 9);
    });

    it('is for patients only', async () => {
      await refusedWith(updatePatientAreaHandler(deps, w.doctor, { countyId: KAJIADO }), 'patientsOnly');
    });
  });

  describe('registerStaffToken', () => {
    it('stores the token and language on the registry row', async () => {
      const admin = await account(emulatorDeps(), 'staff@example.com', { admin: true });
      await w.deps.db.collection('alertApprovers').doc(admin.uid).set({
        uid: admin.uid,
        fcmTokens: [],
        language: 'en',
      });
      const result = await registerStaffTokenHandler(deps, admin, { token: TOKEN, language: 'sw' });
      assert.deepEqual(result, { status: 'ok' });
      const row = (await w.deps.db.collection('alertApprovers').doc(admin.uid).get()).data()!;
      assert.deepEqual(row.fcmTokens, [TOKEN]);
      assert.equal(row.language, 'sw');
    });

    it('keeps the five most recent tokens', async () => {
      const admin = await account(emulatorDeps(), 'staff@example.com', { admin: true });
      await w.deps.db.collection('alertApprovers').doc(admin.uid).set({
        uid: admin.uid,
        fcmTokens: [],
        language: 'en',
      });
      const tokens = Array.from({ length: 6 }, (_, i) => `${TOKEN}-${i}`);
      for (const token of tokens) {
        await registerStaffTokenHandler(deps, admin, { token });
      }
      const row = (await w.deps.db.collection('alertApprovers').doc(admin.uid).get()).data()!;
      assert.deepEqual(row.fcmTokens, tokens.slice(1));
    });

    it('refuses a caller who is not an admin or not on the registry', async () => {
      await refusedWith(registerStaffTokenHandler(deps, w.patient, { token: TOKEN }), 'notAdmin');
      const admin = await account(emulatorDeps(), 'staff@example.com', { admin: true });
      await refusedWith(registerStaffTokenHandler(deps, admin, { token: TOKEN }), 'notApprover');
    });
  });

  describe('setAlertApprover', () => {
    let granter: Awaited<ReturnType<typeof account>>;
    let target: Awaited<ReturnType<typeof account>>;

    beforeEach(async () => {
      granter = await account(emulatorDeps(), 'granter@example.com', { admin: true, alertApprover: true });
      target = await account(emulatorDeps(), 'target@example.com', { admin: true });
      await w.deps.db.collection('alertApprovers').doc(granter.uid).set({
        uid: granter.uid,
        fcmTokens: [],
        language: 'en',
      });
    });

    it('grants another admin and refuses a self-grant (F-6)', async () => {
      const result = await setAlertApproverHandler(deps, granter, { uid: target.uid, grant: true });
      assert.deepEqual(result, { status: 'granted' });
      assert.equal((await claimsOf(target.uid)).alertApprover, true);
      assert.equal((await w.deps.db.collection('alertApprovers').doc(target.uid).get()).exists, true);
      await refusedWith(
        setAlertApproverHandler(deps, granter, { uid: granter.uid, grant: true }),
        'selfGrant',
      );
    });

    it('revokes the registry first, then the claim, and ends their sessions', async () => {
      await setAlertApproverHandler(deps, granter, { uid: target.uid, grant: true });
      let revoked = false;
      const auth = deps.auth as StaffAuthLike;
      const watching: RuntimeDeps = {
        ...deps,
        auth: {
          getUser: (uid) => auth.getUser(uid),
          getUserByEmail: (email) => auth.getUserByEmail(email),
          setCustomUserClaims: (uid, claims) => auth.setCustomUserClaims(uid, claims),
          async revokeRefreshTokens(uid: string) {
            revoked = true;
            assert.equal(uid, target.uid);
            // Registry and claim are already gone; this call only ends lingering sessions.
            assert.equal((await w.deps.db.collection('alertApprovers').doc(target.uid).get()).exists, false);
            assert.equal((await claimsOf(target.uid)).alertApprover, undefined);
            return auth.revokeRefreshTokens(uid);
          },
        },
      };
      const result = await setAlertApproverHandler(watching, granter, { uid: target.uid, grant: false });
      assert.deepEqual(result, { status: 'revoked' });
      assert.equal(revoked, true);
      assert.equal((await claimsOf(target.uid)).alertApprover, undefined);
    });

    it('revokes someone who is no longer an admin, and refuses to grant to one', async () => {
      const lapsed = await account(emulatorDeps(), 'lapsed@example.com', { alertApprover: true });
      await w.deps.db.collection('alertApprovers').doc(lapsed.uid).set({ uid: lapsed.uid, fcmTokens: [], language: 'en' });
      await refusedWith(setAlertApproverHandler(deps, granter, { uid: lapsed.uid, grant: true }), 'notAdmin');
      assert.deepEqual(await setAlertApproverHandler(deps, granter, { uid: lapsed.uid, grant: false }), { status: 'revoked' });
      assert.equal((await claimsOf(lapsed.uid)).alertApprover, undefined);
      assert.equal((await w.deps.db.collection('alertApprovers').doc(lapsed.uid).get()).exists, false);
    });

    it('refuses a granter who left the registry', async () => {
      await w.deps.db.collection('alertApprovers').doc(granter.uid).delete();
      await refusedWith(
        setAlertApproverHandler(deps, granter, { uid: target.uid, grant: true }),
        'notApprover',
      );
    });
  });

  describe('backfillAvailability', () => {
    it('writes the four defaults onto doctors that lack them, and audits counties', async () => {
      const admin = await account(emulatorDeps(), 'admin@example.com', { admin: true });
      await w.deps.db.collection(DOCTORS).doc(w.doctor.uid).update({
        workingDays: null,
        dayStartMinute: null,
        dayEndMinute: null,
        busySlots: null,
        county: 'Atlantis',
      });
      const result = await backfillAvailabilityHandler(deps, admin, { collection: 'doctors' });
      assert.ok(result.updated >= 1);
      assert.equal(result.unknownCounty.ids.includes(w.doctor.uid), true);
      const doc = (await w.deps.db.collection(DOCTORS).doc(w.doctor.uid).get()).data()!;
      assert.deepEqual(doc.workingDays, DEFAULT_WORKING_DAYS);
      assert.equal(doc.dayStartMinute, DEFAULT_DAY_START_MINUTE);
      assert.equal(doc.dayEndMinute, DEFAULT_DAY_END_MINUTE);
      assert.deepEqual(doc.busySlots, []);

      const again = await backfillAvailabilityHandler(deps, admin, { collection: 'doctors' });
      assert.equal(again.updated, 0);
    });

    it('is admin only and pages by cursor', async () => {
      await refusedWith(backfillAvailabilityHandler(deps, w.doctor, {}), 'notAdmin');
      const admin = await account(emulatorDeps(), 'admin@example.com', { admin: true });
      const first = await backfillAvailabilityHandler(deps, admin, { collection: 'patients' });
      assert.equal(first.collection, 'patients');
      assert.ok(first.scanned <= BACKFILL_PAGE);
    });
  });

  describe('resumeLinkJobs', () => {
    it('resumes a stalled Running link and leaves a fresh one alone', async () => {
      const now = (deps.now ?? (() => new Date()))();
      const patientId = 'record-stalled';
      const uid = w.patient.uid;
      await w.deps.db.collection(PATIENTS).doc(patientId).set({
        patientId,
        uid,
        isRegistered: true,
        doctorUids: [w.doctor.uid],
      });
      await w.deps.db.collection('cases').doc('old-case').set({
        patientId,
        patientUid: '',
        doctorUid: w.doctor.uid,
        status: 'Requested',
      });
      const stale = new Date(now.getTime() - 10 * MINUTE_MS).toISOString();
      await w.deps.db.collection('linkJobs').doc(patientId).set({
        patientId,
        uid,
        status: 'Running',
        cursor: '',
        casesLinked: 0,
        createdAt: stale,
        lastUpdatedAt: stale,
      });
      const freshId = 'record-fresh';
      const freshAt = now.toISOString();
      await w.deps.db.collection('linkJobs').doc(freshId).set({
        patientId: freshId,
        uid,
        status: 'Running',
        cursor: '',
        casesLinked: 0,
        createdAt: freshAt,
        lastUpdatedAt: freshAt,
      });

      const result = await resumeLinkJobsHandler(deps);
      assert.equal(result.resumed, 1);
      assert.equal((await w.deps.db.collection('cases').doc('old-case').get()).get('patientUid'), uid);
      assert.equal((await w.deps.db.collection('linkJobs').doc(patientId).get()).get('status'), 'Done');
      assert.equal((await w.deps.db.collection('linkJobs').doc(freshId).get()).get('status'), 'Running');
    });

    async function stalledJob(patientId: string, cursor: string, caseCount: number): Promise<void> {
      const uid = w.patient.uid;
      await w.deps.db.collection(PATIENTS).doc(patientId).set({ patientId, uid, isRegistered: true, doctorUids: [w.doctor.uid] });
      for (let i = 0; i < caseCount; i += 400) {
        const batch = w.deps.db.batch();
        for (let j = i; j < Math.min(i + 400, caseCount); j++) {
          batch.set(w.deps.db.collection('cases').doc(`${patientId}-case-${String(j).padStart(4, '0')}`), {
            patientId,
            patientUid: '',
            doctorUid: w.doctor.uid,
            status: 'Requested',
          });
        }
        await batch.commit();
      }
      const stale = new Date((deps.now ?? (() => new Date()))().getTime() - 10 * MINUTE_MS).toISOString();
      await w.deps.db.collection('linkJobs').doc(patientId).set({
        patientId,
        uid,
        status: 'Running',
        cursor,
        casesLinked: 0,
        createdAt: stale,
        lastUpdatedAt: stale,
      });
    }

    const job = async (patientId: string) => (await w.deps.db.collection('linkJobs').doc(patientId).get()).data()!;

    it('goes on with the next job when one fails, and counts the failure without naming it', async () => {
      await stalledJob('record-broken', 'bad/cursor', 1);
      await stalledJob('record-fine', '', 3);
      const result = await resumeLinkJobsHandler(deps);
      assert.deepEqual(result, { resumed: 1, failed: 1 });
      assert.equal((await job('record-fine')).status, 'Done');
      assert.equal((await job('record-fine')).casesLinked, 3);
      assert.equal((await job('record-broken')).status, 'Running');
    });

    it('finishes a history longer than one run over several runs', async () => {
      const total = 6 * LINK_PAGE;
      await stalledJob('record-long', '', total);
      assert.deepEqual(await resumeLinkJobsHandler(deps), { resumed: 1, failed: 0 });
      assert.equal((await job('record-long')).status, 'Running');
      assert.equal((await job('record-long')).casesLinked, 5 * LINK_PAGE);

      // Not yet stalled again: the job moved a moment ago.
      assert.deepEqual(await resumeLinkJobsHandler(deps), { resumed: 0, failed: 0 });
      assert.deepEqual(await resumeLinkJobsHandler(ahead(deps, 10 * MINUTE_MS)), { resumed: 1, failed: 0 });
      assert.equal((await job('record-long')).status, 'Done');
      assert.equal((await job('record-long')).casesLinked, total);
      const unlinked = await w.deps.db.collection('cases').where('patientUid', '==', '').get();
      assert.equal(unlinked.size, 0);
    });

    it('is picked up from linkPatientAccount, which answers casesPending for a long history', async () => {
      const patientId = 'record-link';
      await w.deps.db.collection(PATIENTS).doc(patientId).set({
        patientId,
        uid: '',
        isRegistered: false,
        doctorUids: [w.doctor.uid],
        email: '',
      });
      const total = 6 * LINK_PAGE;
      for (let i = 0; i < total; i += 400) {
        const batch = w.deps.db.batch();
        for (let j = i; j < Math.min(i + 400, total); j++) {
          batch.set(w.deps.db.collection('cases').doc(`${patientId}-${String(j).padStart(4, '0')}`), {
            patientId,
            patientUid: '',
            doctorUid: w.doctor.uid,
            status: 'Requested',
          });
        }
        await batch.commit();
      }
      const owner = await account(emulatorDeps(), 'linked@example.com');
      const result = await linkPatientAccountHandler(emulatorDeps(), w.doctor, { patientId, email: 'linked@example.com' });
      assert.deepEqual(result, { status: 'linked', patientId, casesPending: true });
      assert.equal((await job(patientId)).status, 'Running');

      await resumeLinkJobsHandler(ahead(deps, 10 * MINUTE_MS));
      assert.equal((await job(patientId)).status, 'Done');
      assert.equal((await job(patientId)).casesLinked, total);
      const linked = await w.deps.db.collection('cases').where('patientUid', '==', owner.uid).get();
      assert.equal(linked.size, total);
    });
  });

  it('refuses a caller with no role in every callable', async () => {
    const nobody = callerWithoutRole();
    const calls: (() => Promise<unknown>)[] = [
      () => updatePatientAreaHandler(deps, nobody, { countyId: KAJIADO }),
      () => registerStaffTokenHandler(deps, nobody, { token: TOKEN }),
      () => setAlertApproverHandler(deps, nobody, { uid: w.doctor.uid, grant: true }),
      () => backfillAvailabilityHandler(deps, nobody, {}),
    ];
    for (const call of calls) await refused(Promise.resolve().then(call));
  });
});
