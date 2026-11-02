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
  setDoc,
  updateDoc,
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

describe('reportDrafts', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/reportDrafts/drWanjiru', draft());
  });

  it('RT-90 the own pathologist reads and updates the whitelist', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru')));
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        title: 'Biopsy',
        ...at,
      }),
    );
  });

  it('RT-91 doctor and patient are denied the draft (S-1)', async () => {
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reportDrafts/drWanjiru')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'cases/case1/reportDrafts/drWanjiru')));
  });

  it('RT-92 a former pathologist is denied', async () => {
    await seed('cases/case1', caseDoc({ pathologistUid: 'drOther' }));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru')));
  });

  it('RT-93 a non-whitelisted field, or Signed, is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        status: 'Signed',
        ...at,
      }),
    );
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ status: 'Signed' }));
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        title: 'No',
        ...at,
      }),
    );
  });

  it('RT-94 an Addendum changing diagnosis is denied', async () => {
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ kind: 'Addendum', diagnosis: 'Old' }));
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        diagnosis: 'New',
        ...at,
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        addendumText: 'Addendum note',
        ...at,
      }),
    );
  });

  it('RT-95 diagnosisStartedAt without a score is denied', async () => {
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ prereadRunUid: 'run1' }));
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        diagnosisStartedAt: '2026-10-28T09:00:00.000Z',
        ...at,
      }),
    );
  });

  // startReport leaves prereadRunUid empty after a Failed/Stale run so the manual report can begin.
  it('RT-202 diagnosisStartedAt with no Ready run needs no score', async () => {
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ prereadRunUid: '' }));
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        diagnosisStartedAt: '2026-10-28T09:00:00.000Z',
        ...at,
      }),
    );
  });

  it('RT-96 diagnosisStartedAt with a score is allowed', async () => {
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ prereadRunUid: 'run1' }));
    await seed('cases/case1/prereadScores/run1', {
      uid: 'run1',
      pathologistUid: 'drWanjiru',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        diagnosisStartedAt: '2026-10-28T09:00:00.000Z',
        ...at,
      }),
    );
  });

  it('RT-97 diagnosis while diagnosisStartedAt is empty is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        diagnosis: 'Carcinoma',
        ...at,
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        diagnosis: 'Carcinoma',
        diagnosisStartedAt: '2026-10-28T09:00:00.000Z',
        ...at,
      }),
    );
  });

  it('RT-98 a labelOverrideCount mismatch or over 2000 is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        labelOverrides: { a: 'x' },
        labelOverrideCount: 2,
        ...at,
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        labelOverrides: { a: 'x' },
        labelOverrideCount: 1,
        ...at,
      }),
    );
    await seed('cases/case1/reportDrafts/drWanjiru', draft());
    const exactly2000 = {};
    for (let i = 0; i < 2000; i += 1) exactly2000[`k${i}`] = 'v';
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        labelOverrides: exactly2000,
        labelOverrideCount: 2000,
        ...at,
      }),
    );
    await seed('cases/case1/reportDrafts/drWanjiru', draft());
    const tooMany = {};
    for (let i = 0; i < 2001; i += 1) tooMany[`k${i}`] = 'v';
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        labelOverrides: tooMany,
        labelOverrideCount: 2001,
        ...at,
      }),
    );
  });

  it('RT-199 startedFromPreread false→true needs a score; true→false denied (M-1)', async () => {
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ prereadRunUid: 'run1' }));
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        startedFromPreread: true,
        ...at,
      }),
    );
    await seed('cases/case1/prereadScores/run1', {
      uid: 'run1',
      pathologistUid: 'drWanjiru',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        startedFromPreread: true,
        ...at,
      }),
    );
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        startedFromPreread: false,
        lastUpdatedAt: '2026-10-28T10:00:00.000Z',
      }),
    );
  });

  it('RT-99 create and delete of drafts are denied', async () => {
    await assertFails(
      setDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drNew'), draft({ uid: 'drNew' })),
    );
    await assertFails(deleteDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru')));
  });

  it('RT-184 the pathologist sets notifiableFindings on Initial and Amendment', async () => {
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        notifiableFindings: [{ diseaseId: 'malaria', alertRequested: false }],
        confirmatoryRequests: ['tb'],
        ...at,
      }),
    );
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ kind: 'Amendment' }));
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        notifiableFindings: [{ diseaseId: 'cholera', alertRequested: true }],
        ...at,
      }),
    );
  });

  it('RT-185 Addendum findings, more than 5, or a non-list are denied', async () => {
    await seed('cases/case1/reportDrafts/drWanjiru', draft({ kind: 'Addendum' }));
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        notifiableFindings: [{ diseaseId: 'malaria', alertRequested: false }],
        ...at,
      }),
    );
    await seed('cases/case1/reportDrafts/drWanjiru', draft());
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        notifiableFindings: [1, 2, 3, 4, 5, 6],
        ...at,
      }),
    );
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        confirmatoryRequests: 'malaria',
        ...at,
      }),
    );
  });
});

describe('prereadScores and reportProvenance', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/prereadScores/run1', {
      uid: 'run1',
      pathologistUid: 'drWanjiru',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/reportProvenance/v1', {
      uid: 'v1',
      pathologistUid: 'drWanjiru',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-100 the own pathologist reads scores and provenance', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/prereadScores/run1')));
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportProvenance/v1')));
  });

  it('RT-101 doctor, patient and other pathologist are denied', async () => {
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/prereadScores/run1')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'cases/case1/reportProvenance/v1')));
    await seed('cases/case1', caseDoc({ pathologistUid: 'drOther' }));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/prereadScores/run1')));
    // Current case pathologist reading an earlier pathologist's score / provenance
    // (resource.data.pathologistUid clause).
    await seed('cases/case1', caseDoc({ pathologistUid: 'drWanjiru' }));
    await seed('cases/case1/prereadScores/run1', {
      uid: 'run1',
      pathologistUid: 'drEarlier',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/reportProvenance/v1', {
      uid: 'v1',
      pathologistUid: 'drEarlier',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/prereadScores/run1')));
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportProvenance/v1')));
  });

  it('RT-102 an admin reads scores and provenance', async () => {
    await assertSucceeds(getDoc(doc(db('admin', { admin: true }), 'cases/case1/prereadScores/run1')));
    await assertSucceeds(getDoc(doc(db('admin', { admin: true }), 'cases/case1/reportProvenance/v1')));
  });

  it('RT-103 writes are denied', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/prereadScores/run1'), { overall: 5 }),
    );
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportProvenance/v1'), {
        draftText: 'x',
      }),
    );
  });
});

describe('reportTexts working', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/reportTexts/v1_Translation_sw', {
      uid: 'v1_Translation_sw',
      approverUid: 'drWanjiru',
      machineText: { title: 'x' },
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-104 the approver gets the working text', async () => {
    await assertSucceeds(
      getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportTexts/v1_Translation_sw')),
    );
  });

  it('RT-105 an unlocked doctor and a released patient are denied the working record (F-1)', async () => {
    await seed('cases/case1/reports/v1', report({
      readerUids: ['drOdhiambo', 'amina'],
      releasedToPatient: true,
    }));
    await assertFails(
      getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reportTexts/v1_Translation_sw')),
    );
    await assertFails(
      getDoc(doc(db('amina', PATIENT), 'cases/case1/reportTexts/v1_Translation_sw')),
    );
  });

  it('RT-106 list of working texts is denied', async () => {
    await assertFails(getDocs(collection(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportTexts')));
  });

  it('RT-107 write of working texts is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportTexts/v1_Translation_sw'), {
        status: 'Approved',
      }),
    );
  });
});

describe('reportTextsApproved', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/reports/v1', report({
      readerUids: ['drOdhiambo', 'drWanjiru'],
      releasedToPatient: false,
    }));
    await seed('cases/case1/reportTextsApproved/v1_Translation_sw', {
      uid: 'v1_Translation_sw',
      approvedText: { title: 't' },
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-108 a report reader gets the approved text', async () => {
    await assertSucceeds(
      getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reportTextsApproved/v1_Translation_sw')),
    );
  });

  it('RT-109 a released patient gets the approved text', async () => {
    await seed('cases/case1/reports/v1', report({
      readerUids: ['amina'],
      releasedToPatient: true,
    }));
    await assertSucceeds(
      getDoc(doc(db('amina', PATIENT), 'cases/case1/reportTextsApproved/v1_Translation_sw')),
    );
  });

  it('RT-110 an unreleased patient is denied', async () => {
    await seed('cases/case1/reports/v1', report({
      readerUids: ['amina'],
      releasedToPatient: false,
    }));
    await assertFails(
      getDoc(doc(db('amina', PATIENT), 'cases/case1/reportTextsApproved/v1_Translation_sw')),
    );
  });

  it('RT-111 a role-less account is denied', async () => {
    await assertFails(
      getDoc(doc(db('drOdhiambo', {}), 'cases/case1/reportTextsApproved/v1_Translation_sw')),
    );
  });

  it('RT-112 list of approved texts is denied (F-26.15)', async () => {
    await assertFails(
      getDocs(collection(db('drOdhiambo', DOCTOR), 'cases/case1/reportTextsApproved')),
    );
  });

  it('RT-113 write of approved texts is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reportTextsApproved/v1_Translation_sw'), {
        approvedText: { title: 'y' },
      }),
    );
  });

  it('RT-191 a released patient get of a not-yet-approved id reads as absent; a stranger is denied (F-18)', async () => {
    await seed('cases/case1/reports/v1', report({
      readerUids: ['amina'],
      releasedToPatient: true,
    }));
    await assertSucceeds(
      getDoc(doc(db('amina', PATIENT), 'cases/case1/reportTextsApproved/v1_Explanation_en')),
    );
    await assertFails(
      getDoc(doc(db('stranger', DOCTOR), 'cases/case1/reportTextsApproved/v1_Translation_sw')),
    );
  });
});

describe('worklist', () => {
  beforeEach(async () => {
    await seed('worklist/case1', {
      uid: 'case1',
      pathologistUid: 'drWanjiru',
      status: 'Open',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-114 the own pathologist reads the worklist entry', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'worklist/case1')));
  });

  it('RT-115 another pathologist and the doctor are denied', async () => {
    await assertFails(getDoc(doc(db('drOther', PATHOLOGIST), 'worklist/case1')));
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'worklist/case1')));
  });

  it('RT-116 a cleared entry is denied to the former pathologist (F-14)', async () => {
    await seed('worklist/case1', {
      uid: 'case1',
      pathologistUid: '',
      status: 'Closed',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await assertFails(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'worklist/case1')));
  });

  it('RT-117 worklist write is denied', async () => {
    await assertFails(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'worklist/case1'), { status: 'Signed' }),
    );
  });
});
