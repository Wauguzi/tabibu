'use strict';

const {
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  collection,
  collectionGroup,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  updateDoc,
  where,
  deleteDoc,
} = require('firebase/firestore');
const {
  caseDoc,
  draft,
  report,
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

describe('cases', () => {
  beforeEach(async () => seed('cases/case1', caseDoc()));

  it('RT-45 a participant with a role gets the case', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'cases/case1')));
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1')));
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1')));
  });

  it('RT-46 a non-participant is denied', async () => {
    await assertFails(getDoc(doc(db('stranger', DOCTOR), 'cases/case1')));
  });

  it('RT-47 a list without array-contains is denied', async () => {
    const mine = db('amina', PATIENT);
    await assertSucceeds(
      getDocs(query(collection(mine, 'cases'), where('participantUids', 'array-contains', 'amina'))),
    );
    await assertFails(getDocs(collection(mine, 'cases')));
  });

  it('RT-48 a role-less former participant is denied (F-6)', async () => {
    await assertFails(getDoc(doc(db('amina', {}), 'cases/case1')));
  });

  it('RT-49 create and delete are denied', async () => {
    await assertFails(setDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case2'), caseDoc({ uid: 'case2' })));
    await assertFails(deleteDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1')));
  });

  it('RT-50 the doctor edits notes and sampleCollectedAt before acceptance', async () => {
    await seed('cases/case1', caseDoc({
      currentStage: 'OrderCreated',
      pathologistUid: '',
      participantUids: ['drOdhiambo', 'amina'],
    }));
    await assertSucceeds(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1'), {
        clinicalNotes: 'Updated',
        sampleCollectedAt: '2026-10-21T08:00:00.000Z',
        ...at,
      }),
    );
  });

  it('RT-51 the same after acceptance is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1'), {
        clinicalNotes: 'Too late',
        ...at,
      }),
    );
  });

  it('RT-52 a pathologist notes edit is denied', async () => {
    await seed('cases/case1', caseDoc({ currentStage: 'OrderCreated', pathologistUid: '' }));
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1'), {
        clinicalNotes: 'No',
        ...at,
      }),
    );
  });

  it('RT-53 client writes of gated case fields are denied', async () => {
    await seed('cases/case1', caseDoc({ currentStage: 'OrderCreated', pathologistUid: '' }));
    const ref = doc(db('drOdhiambo', DOCTOR), 'cases/case1');
    for (const patch of [
      { currentStage: 'PathologistAccepted' },
      { releasedToPatient: true },
      { resultState: 'Released' },
      { participantUids: ['drOdhiambo'] },
      { pathologistUid: 'drWanjiru' },
      { currentReportUid: 'v1' },
      { priority: 'Urgent' },
      { slideUploadUids: ['x'] },
      { labAccessionNo: 'L1' },
      { discussionAppointmentUid: 'a1' },
    ]) {
      await assertFails(updateDoc(ref, { ...patch, ...at }));
    }
  });
});

describe('log', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/log/0001', {
      seq: '0001',
      patientVisible: true,
      actionType: 'Create',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/log/0002', {
      seq: '0002',
      patientVisible: false,
      actionType: 'Note',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-54 doctor and pathologist read all log rows', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/log/0002')));
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/log/0002')));
  });

  it('RT-55 a patient query without patientVisible is denied', async () => {
    await assertFails(getDocs(collection(db('amina', PATIENT), 'cases/case1/log')));
  });

  it('RT-56 a patient query with patientVisible is allowed', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'cases/case1/log'),
        where('patientVisible', '==', true),
      )),
    );
  });

  it('RT-57 a declined pathologist is denied', async () => {
    await seed('cases/case1', caseDoc({
      pathologistUid: 'drOther',
      participantUids: ['drOdhiambo', 'amina', 'drOther'],
    }));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/log/0001')));
  });

  it('RT-58 an expired requested pathologist is denied (F-18)', async () => {
    await seed('cases/case1', caseDoc({
      pathologistUid: '',
      requestedPathologistUid: '',
      participantUids: ['drOdhiambo', 'amina'],
    }));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/log/0001')));
  });

  it('RT-59 a role-less account is denied the log', async () => {
    await assertFails(getDoc(doc(db('drOdhiambo', {}), 'cases/case1/log/0001')));
  });

  it('RT-60 log writes are denied', async () => {
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/log/0003'), { patientVisible: true }),
    );
  });
});

describe('private/payment', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/private/payment', { method: 'Cash', lastUpdatedAt: '2026-10-27T09:00:00.000Z' });
  });

  it('RT-61 doctor and patient read payment', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/private/payment')));
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'cases/case1/private/payment')));
  });

  it('RT-62 pathologist and viewer are denied payment', async () => {
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/private/payment')));
    await seed('cases/case1', caseDoc({ participantUids: ['drOdhiambo', 'amina', 'drWanjiru', 'viewer1'] }));
    await assertFails(getDoc(doc(db('viewer1', DOCTOR), 'cases/case1/private/payment')));
  });

  it('RT-63 payment write is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/private/payment'), { method: 'Mpesa' }),
    );
  });
});

describe('riskCheck and notesTranslation', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc({
      participantUids: ['drOdhiambo', 'amina', 'drWanjiru', 'viewer1'],
    }));
    await seed('cases/case1/riskCheck/current', { status: 'Ready', doctorUid: 'drOdhiambo' });
    await seed('cases/case1/notesTranslation/current', { status: 'Ready' });
  });

  it('RT-64 the doctor reads the risk check', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/riskCheck/current')));
  });

  it('RT-65 patient, pathologist and viewer are denied the risk check', async () => {
    await assertFails(getDoc(doc(db('amina', PATIENT), 'cases/case1/riskCheck/current')));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/riskCheck/current')));
    await assertFails(getDoc(doc(db('viewer1', DOCTOR), 'cases/case1/riskCheck/current')));
  });

  it('RT-66 doctor and pathologist read the notes translation', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/notesTranslation/current')));
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/notesTranslation/current')));
  });

  it('RT-67 patient and viewer are denied the notes translation', async () => {
    await assertFails(getDoc(doc(db('amina', PATIENT), 'cases/case1/notesTranslation/current')));
    await assertFails(getDoc(doc(db('viewer1', DOCTOR), 'cases/case1/notesTranslation/current')));
  });

  it('RT-68 writes to riskCheck and notesTranslation are denied', async () => {
    await assertFails(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/riskCheck/current'), { status: 'Failed' }),
    );
    await assertFails(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/notesTranslation/current'), { status: 'Failed' }),
    );
  });
});

describe('shareCodes and closed collections', () => {
  beforeEach(async () => {
    await seed('shareCodes/s1', {
      createdByUid: 'drOdhiambo',
      recipientUid: 'drOther',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-69 a recipient list query is allowed', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOther', DOCTOR), 'shareCodes'),
        where('recipientUid', '==', 'drOther'),
      )),
    );
  });

  it('RT-70 a creator list query is allowed (F-26.14)', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'shareCodes'),
        where('createdByUid', '==', 'drOdhiambo'),
      )),
    );
  });

  it('RT-71 a third party is denied', async () => {
    await assertFails(getDoc(doc(db('amina', PATIENT), 'shareCodes/s1')));
  });

  it('RT-72 shareCode write is denied', async () => {
    await assertFails(updateDoc(doc(db('drOdhiambo', DOCTOR), 'shareCodes/s1'), { status: 'Closed' }));
  });

  it('RT-73 shareSecrets is closed', async () => {
    await seed('shareSecrets/s1', { codeHmac: 'x' });
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'shareSecrets/s1')));
    await assertFails(getDoc(doc(db('admin', { admin: true }), 'shareSecrets/s1')));
  });

  it('RT-74 rateCounters is closed', async () => {
    await seed('rateCounters/k1', { count: 1 });
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'rateCounters/k1')));
  });

  it('RT-75 orderCounters is closed', async () => {
    await seed('orderCounters/k1', { count: 1 });
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'orderCounters/k1')));
  });

  it('RT-76 orderNumbers is closed', async () => {
    await seed('orderNumbers/1', { used: true });
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'orderNumbers/1')));
  });

  it('RT-77 linkJobs is closed', async () => {
    await seed('linkJobs/p1', { status: 'Running' });
    await assertFails(getDoc(doc(db('amina', PATIENT), 'linkJobs/p1')));
  });

  it('RT-78 transcriptions is closed', async () => {
    await seed('transcriptions/t1', { text: 'secret' });
    await assertFails(getDoc(doc(db('amina', PATIENT), 'transcriptions/t1')));
  });
});

describe('preread', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc({
      participantUids: ['drOdhiambo', 'amina', 'drWanjiru', 'viewer1'],
    }));
    await seed('cases/case1/preread/run1', { status: 'Ready', pathologistUid: 'drWanjiru' });
  });

  it('RT-79 the case pathologist reads the preread', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/preread/run1')));
  });

  it('RT-80 doctor, patient, viewer and requested pathologist are denied (S-1)', async () => {
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/preread/run1')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'cases/case1/preread/run1')));
    await assertFails(getDoc(doc(db('viewer1', DOCTOR), 'cases/case1/preread/run1')));
    await seed('cases/case1', caseDoc({
      pathologistUid: '',
      requestedPathologistUid: 'drRequested',
      participantUids: ['drOdhiambo', 'amina', 'drRequested'],
    }));
    await assertFails(getDoc(doc(db('drRequested', PATHOLOGIST), 'cases/case1/preread/run1')));
  });

  it('RT-81 preread write is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/preread/run1'), { status: 'Failed' }),
    );
  });
});

describe('reports', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/reports/v1', report());
  });

  it('RT-82 an unlocked doctor reads the report', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reports/v1')));
  });

  it('RT-83 a doctor before unlock is denied', async () => {
    await seed('cases/case1/reports/v1', report({ readerUids: ['drWanjiru'] }));
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reports/v1')));
  });

  it('RT-84 a patient in readerUids but unreleased is denied (S-3)', async () => {
    await seed('cases/case1/reports/v1', report({
      readerUids: ['drWanjiru', 'drOdhiambo', 'amina'],
      releasedToPatient: false,
    }));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'cases/case1/reports/v1')));
  });

  it('RT-85 a patient list without the release filter is denied', async () => {
    await seed('cases/case1/reports/v1', report({
      readerUids: ['amina'],
      releasedToPatient: true,
    }));
    await assertFails(
      getDocs(query(
        collection(db('amina', PATIENT), 'cases/case1/reports'),
        where('readerUids', 'array-contains', 'amina'),
      )),
    );
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'cases/case1/reports'),
        where('readerUids', 'array-contains', 'amina'),
        where('releasedToPatient', '==', true),
      )),
    );
  });

  it('RT-86 a released patient reads the report', async () => {
    await seed('cases/case1/reports/v1', report({
      readerUids: ['amina'],
      releasedToPatient: true,
    }));
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'cases/case1/reports/v1')));
  });

  it('RT-87 a role-less former reader is denied', async () => {
    await assertFails(getDoc(doc(db('drOdhiambo', {}), 'cases/case1/reports/v1')));
  });

  it('RT-88 client writes to reports are denied (S-2)', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reports/v1'), { diagnosis: 'x' }),
    );
  });

  it('RT-89 a collection-group query by a non-reader is denied', async () => {
    await assertFails(
      getDocs(query(
        collectionGroup(db('stranger', DOCTOR), 'reports'),
        where('readerUids', 'array-contains', 'drOdhiambo'),
      )),
    );
    await assertSucceeds(
      getDocs(query(
        collectionGroup(db('drOdhiambo', DOCTOR), 'reports'),
        where('readerUids', 'array-contains', 'drOdhiambo'),
      )),
    );
  });
});
