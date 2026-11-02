'use strict';

const {
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');
const {
  PATIENT,
  DOCTOR,
  PATHOLOGIST,
  APPROVER,
  setupEnv,
  cleanupEnv,
  clearAll,
  seed,
  db,
  getEnv,
} = require('./fixtures');

before(async () => setupEnv());
after(async () => cleanupEnv());
beforeEach(async () => clearAll());

describe('alerts domain', () => {
  beforeEach(async () => {
    await seed('alerts/a1', { status: 'Draft', lastUpdatedAt: '2026-10-27T09:00:00.000Z' });
    await seed('alertSignals/s1', { rule: 'B', lastUpdatedAt: '2026-10-27T09:00:00.000Z' });
    await seed('publicAlerts/a1', {
      uid: 'a1',
      countyId: 1,
      clinicianCountyIds: [1, 2],
      patientsReleased: false,
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('publicAlerts/a1/doctor/brief', {
      uid: 'brief',
      alertUid: 'a1',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    // Registry row required with the claim (F-6 / RT-201).
    await seed('alertApprovers/approver', { uid: 'approver', fcmTokens: [], language: 'en' });
  });

  it('RT-172 an approver gets and lists alerts and alertSignals', async () => {
    await assertSucceeds(getDoc(doc(db('approver', APPROVER), 'alerts/a1')));
    await assertSucceeds(getDoc(doc(db('approver', APPROVER), 'alertSignals/s1')));
    await assertSucceeds(getDocs(collection(db('approver', APPROVER), 'alerts')));
    await assertSucceeds(getDocs(collection(db('approver', APPROVER), 'alertSignals')));
  });

  it('RT-173 an admin without the claim is denied', async () => {
    await assertFails(getDoc(doc(db('admin', { admin: true }), 'alerts/a1')));
  });

  it('RT-174 the claim without admin is denied', async () => {
    await assertFails(getDoc(doc(db('doc', { alertApprover: true, ...DOCTOR }), 'alerts/a1')));
  });

  it('RT-201 the claim without a registry row is denied (F-6)', async () => {
    await getEnv().withSecurityRulesDisabled((ctx) =>
      deleteDoc(doc(ctx.firestore(), 'alertApprovers/approver')),
    );
    await assertFails(getDoc(doc(db('approver', APPROVER), 'alerts/a1')));
    await assertFails(getDoc(doc(db('approver', APPROVER), 'publicAlerts/a1')));
  });

  it('RT-175 doctor, pathologist, patient and role-less accounts are denied working alerts', async () => {
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'alerts/a1')));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'alertSignals/s1')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'alerts/a1')));
    await assertFails(getDoc(doc(db('nobody', {}), 'alerts/a1')));
  });

  it('RT-176 every client write to alerts is denied, approver included (S-4)', async () => {
    await assertFails(
      updateDoc(doc(db('approver', APPROVER), 'alerts/a1'), { status: 'Approved' }),
    );
    await assertFails(
      updateDoc(doc(db('approver', APPROVER), 'alerts/a1'), { status: 'Delivered' }),
    );
  });

  it('RT-177 events, links, counts, deliveries and approvers are closed to everyone', async () => {
    await seed('notifiableEvents/e1', { status: 'Active' });
    await seed('notifiableEventLinks/l1', { caseUid: 'c1' });
    await seed('epiCounts/c1', { count: 1 });
    await seed('alertDeliveries/a1', { phase: 'Pending' });
    await seed('alertApprovers/u1', { uid: 'u1' });
    for (const path of [
      'notifiableEvents/e1',
      'notifiableEventLinks/l1',
      'epiCounts/c1',
      'alertDeliveries/a1',
      'alertApprovers/u1',
    ]) {
      await assertFails(getDoc(doc(db('approver', APPROVER), path)));
      await assertFails(getDoc(doc(db('admin', { admin: true }), path)));
    }
  });

  it('RT-178 doctor and pathologist list publicAlerts by clinicianCountyIds', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'publicAlerts'),
        where('clinicianCountyIds', 'array-contains', 1),
      )),
    );
    await assertSucceeds(
      getDocs(query(
        collection(db('drWanjiru', PATHOLOGIST), 'publicAlerts'),
        where('clinicianCountyIds', 'array-contains', 1),
      )),
    );
  });

  it('RT-179 a patient reads a released alert and lists with the filter', async () => {
    await seed('publicAlerts/a1', {
      uid: 'a1',
      countyId: 1,
      clinicianCountyIds: [1],
      patientsReleased: true,
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'publicAlerts/a1')));
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'publicAlerts'),
        where('patientsReleased', '==', true),
      )),
    );
  });

  it('RT-180 a patient is denied an unreleased alert and a list without the filter', async () => {
    await assertFails(getDoc(doc(db('amina', PATIENT), 'publicAlerts/a1')));
    await assertFails(getDocs(collection(db('amina', PATIENT), 'publicAlerts')));
  });

  it('RT-181 a role-less account is denied publicAlerts (non-approver)', async () => {
    await assertFails(getDoc(doc(db('nobody', {}), 'publicAlerts/a1')));
  });

  it('RT-182 the brief: doctor and pathologist read; patient denied; another id denied', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'publicAlerts/a1/doctor/brief')));
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'publicAlerts/a1/doctor/brief')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'publicAlerts/a1/doctor/brief')));
    await seed('publicAlerts/a1/doctor/other', { uid: 'other' });
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'publicAlerts/a1/doctor/other')));
  });

  it('RT-183 publicAlerts and brief writes are denied', async () => {
    await assertFails(
      updateDoc(doc(db('approver', APPROVER), 'publicAlerts/a1'), { patientsReleased: true }),
    );
    await assertFails(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'publicAlerts/a1/doctor/brief'), { uid: 'x' }),
    );
  });

  it('RT-186 a role-less approver reads publicAlerts and the brief (F-42)', async () => {
    await assertSucceeds(getDoc(doc(db('approver', APPROVER), 'publicAlerts/a1')));
    await assertSucceeds(getDoc(doc(db('approver', APPROVER), 'publicAlerts/a1/doctor/brief')));
  });

  it('RT-200 synthetic publicAlerts reach demo accounts only (F-12 / L-2)', async () => {
    await seed('publicAlerts/a1', {
      uid: 'a1',
      countyId: 1,
      clinicianCountyIds: [1],
      patientsReleased: true,
      synthetic: true,
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'publicAlerts/a1')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'publicAlerts/a1')));
    await assertSucceeds(getDoc(doc(db('demoDoc', { ...DOCTOR, demo: true }), 'publicAlerts/a1')));
    await assertSucceeds(getDoc(doc(db('approver', APPROVER), 'publicAlerts/a1')));
  });
});
