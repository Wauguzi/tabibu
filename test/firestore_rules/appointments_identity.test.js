'use strict';

const {
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  updateDoc,
  where,
} = require('firebase/firestore');
const {
  doctorProfile,
  at,
  PATIENT,
  DOCTOR,
  PATHOLOGIST,
  setupEnv,
  cleanupEnv,
  clearAll,
  seed,
  db,
} = require('./fixtures');

before(async () => setupEnv());
after(async () => cleanupEnv());
beforeEach(async () => clearAll());

describe('appointments', () => {
  beforeEach(async () => {
    await seed('appointments/a1', {
      uid: 'a1',
      patientUid: 'amina',
      doctorUid: 'drOdhiambo',
      status: 'Requested',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-118 the patient reads their own appointment', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'appointments/a1')));
  });

  it('RT-119 another patient is denied', async () => {
    await assertFails(getDoc(doc(db('juma', PATIENT), 'appointments/a1')));
  });

  it('RT-120 the doctor reads their own appointment', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'appointments/a1')));
  });

  it('RT-121 another doctor and a pathologist are denied', async () => {
    await assertFails(getDoc(doc(db('drOther', DOCTOR), 'appointments/a1')));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'appointments/a1')));
  });

  it('RT-122 an unscoped list is denied', async () => {
    await assertFails(getDocs(collection(db('amina', PATIENT), 'appointments')));
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'appointments'),
        where('patientUid', '==', 'amina'),
      )),
    );
  });

  it('RT-123 client writes are denied', async () => {
    await assertFails(
      updateDoc(doc(db('amina', PATIENT), 'appointments/a1'), { status: 'Cancelled' }),
    );
  });
});

describe('intake', () => {
  beforeEach(async () => {
    await seed('appointments/a1', {
      uid: 'a1',
      patientUid: 'amina',
      doctorUid: 'drOdhiambo',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('appointments/a1/intake/summary', {
      doctorUid: 'drOdhiambo',
      status: 'Ready',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-124 the doctor reads the intake', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'appointments/a1/intake/summary')));
  });

  it('RT-125 patient and another doctor are denied', async () => {
    await assertFails(getDoc(doc(db('amina', PATIENT), 'appointments/a1/intake/summary')));
    await assertFails(getDoc(doc(db('drOther', DOCTOR), 'appointments/a1/intake/summary')));
  });

  it('RT-126 intake write is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'appointments/a1/intake/summary'), { status: 'Failed' }),
    );
  });
});

describe('doctors hours and closed or admin collections', () => {
  const mine = () => doc(db('drWanjiru', {}), 'doctors/drWanjiru');

  beforeEach(async () => seed('doctors/drWanjiru', doctorProfile()));

  it('RT-127 valid working hours are allowed', async () => {
    await assertSucceeds(
      updateDoc(mine(), {
        workingDays: [1, 2, 3],
        dayStartMinute: 540,
        dayEndMinute: 960,
        ...at,
      }),
    );
  });

  it('RT-128 invalid days are denied', async () => {
    await assertFails(
      updateDoc(mine(), { workingDays: [0, 1], dayStartMinute: 480, dayEndMinute: 1020, ...at }),
    );
    await assertFails(
      updateDoc(mine(), { workingDays: [1, 1], dayStartMinute: 480, dayEndMinute: 1020, ...at }),
    );
    await assertFails(
      updateDoc(mine(), { workingDays: ['1'], dayStartMinute: 480, dayEndMinute: 1020, ...at }),
    );
  });

  it('RT-129 unaligned minutes or end ≤ start are denied', async () => {
    await assertFails(
      updateDoc(mine(), { workingDays: [1], dayStartMinute: 481, dayEndMinute: 1020, ...at }),
    );
    await assertFails(
      updateDoc(mine(), { workingDays: [1], dayStartMinute: 480, dayEndMinute: 480, ...at }),
    );
  });

  it('RT-130 busySlots write is denied', async () => {
    await assertFails(
      updateDoc(mine(), { busySlots: ['2026-10-28T08:00:00.000Z'], ...at }),
    );
  });

  it('RT-131 an older document without hour fields updates fcmTokens (F-11)', async () => {
    const { workingDays, dayStartMinute, dayEndMinute, busySlots, ...legacy } = doctorProfile();
    void workingDays;
    void dayStartMinute;
    void dayEndMinute;
    void busySlots;
    await seed('doctors/drWanjiru', legacy);
    await assertSucceeds(updateDoc(mine(), { fcmTokens: ['t1'], ...at }));
  });

  it('RT-132 practitioners busySlots is readable, not writable', async () => {
    await seed('practitioners/drWanjiru', {
      uid: 'drWanjiru',
      busySlots: ['2026-10-28T08:00:00.000Z'],
      firstName: 'Wanjiru',
    });
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'practitioners/drWanjiru')));
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'practitioners/drWanjiru'), { busySlots: [] }),
    );
  });

  it('RT-133 counterMarks is closed', async () => {
    await seed('counterMarks/k1', { done: true });
    await assertFails(getDoc(doc(db('admin', { admin: true }), 'counterMarks/k1')));
  });

  it('RT-134 modelSignals: admin reads; others and writes denied', async () => {
    await seed('modelSignals/2026-10-27', { count: 1 });
    await assertSucceeds(getDoc(doc(db('admin', { admin: true }), 'modelSignals/2026-10-27')));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'modelSignals/2026-10-27')));
    await assertFails(
      updateDoc(doc(db('admin', { admin: true }), 'modelSignals/2026-10-27'), { count: 2 }),
    );
  });

  it('RT-194 demoAccounts is closed', async () => {
    await seed('demoAccounts/u1', { uid: 'u1', role: 'patient', county: 'Nairobi' });
    await assertFails(getDoc(doc(db('admin', { admin: true }), 'demoAccounts/u1')));
  });
});
