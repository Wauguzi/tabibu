'use strict';

/**
 * Matrix 15 · rules tests that replay Dart data-source payloads and queries.
 * Each `it` is named for its Dart method so client/rules drift fails CI.
 */
const {
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  arrayRemove,
  arrayUnion,
  collection,
  collectionGroup,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  setDoc,
  updateDoc,
  where,
} = require('firebase/firestore');
const {
  url,
  patient,
  doctorProfile,
  caseDoc,
  draft,
  report,
  conversation,
  message,
  MSG_TEXT,
  MSG_VOICE,
  MSG_OTHER,
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

const STAMP = '2026-10-28T09:00:00.000Z';
const STAMP_LATER = '2026-10-28T09:01:00.000Z';

/** Exact createTextMessage payload (matrix row 32). */
function createTextMessagePayload({
  conversationUid = 'conv1',
  messageUid = MSG_TEXT,
  senderUid = 'drOdhiambo',
  text = 'Hello',
  sentAt = STAMP,
} = {}) {
  return {
    uid: messageUid,
    conversationUid,
    senderUid,
    kind: 'Text',
    text,
    attachmentPath: '',
    attachmentType: '',
    attachmentSize: 0,
    voiceDurationMs: 0,
    voicePeaks: [],
    transcriptShared: false,
    transcriptLanguage: '',
    transcriptStatus: 'None',
    identifierFlagged: false,
    inputMode: 'Typed',
    status: 'Sent',
    withheldReason: '',
    sentAt,
    deliveredAt: '',
    lastUpdatedAt: sentAt,
  };
}

/** Exact createVoiceMessage payload (matrix row 33). */
function createVoiceMessagePayload({
  conversationUid = 'conv1',
  messageUid = MSG_VOICE,
  senderUid = 'drOdhiambo',
  contentType = 'audio/mp4',
  durationMs = 60000,
  voicePeaks = [10, 20, 30],
  attachmentSize = 100000,
  sentAt = STAMP,
} = {}) {
  return {
    uid: messageUid,
    conversationUid,
    senderUid,
    kind: 'Voice',
    text: '',
    attachmentPath: `conversations/${conversationUid}/voice/${messageUid}.m4a`,
    attachmentType: contentType,
    attachmentSize,
    voiceDurationMs: durationMs,
    voicePeaks,
    transcriptShared: false,
    transcriptLanguage: '',
    transcriptStatus: 'Queued',
    identifierFlagged: false,
    inputMode: 'Voice',
    status: 'Sent',
    withheldReason: '',
    sentAt,
    deliveredAt: '',
    lastUpdatedAt: sentAt,
  };
}

function publicAlert(overrides = {}) {
  return {
    uid: 'a1',
    countyId: 1,
    clinicianCountyIds: [1, 2],
    patientsReleased: true,
    synthetic: false,
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    ...overrides,
  };
}

describe('matrix · AlertFirebase', () => {
  beforeEach(async () => {
    await seed('publicAlerts/a1', publicAlert());
    await seed('publicAlerts/a1-synth', publicAlert({
      uid: 'a1-synth',
      synthetic: true,
      lastUpdatedAt: '2026-10-27T10:00:00.000Z',
    }));
    await seed('publicAlerts/a1/doctor/brief', {
      uid: 'brief',
      alertUid: 'a1',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('fetchPatientPublicAlerts: county + released + non-synthetic + orderBy', async () => {
    // Fixed shape: synthetic == false proves the read rule; the synthetic row is
    // excluded by the filter, not an error (matrix §alerts / D-1).
    const snap = await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'publicAlerts'),
        where('countyId', '==', 1),
        where('patientsReleased', '==', true),
        where('synthetic', '==', false),
        orderBy('lastUpdatedAt'),
      )),
    );
    const ids = snap.docs.map((d) => d.id);
    if (ids.includes('a1-synth')) throw new Error(`synthetic row leaked: ${ids.join(',')}`);
    if (!ids.includes('a1')) throw new Error(`expected a1, got ${ids.join(',')}`);
  });

  it('fetchClinicianPublicAlerts: clinicianCountyIds + non-synthetic + orderBy', async () => {
    const snap = await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'publicAlerts'),
        where('clinicianCountyIds', 'array-contains', 1),
        where('synthetic', '==', false),
        orderBy('lastUpdatedAt'),
      )),
    );
    const ids = snap.docs.map((d) => d.id);
    if (ids.includes('a1-synth')) throw new Error(`synthetic row leaked: ${ids.join(',')}`);
    if (!ids.includes('a1')) throw new Error(`expected a1, got ${ids.join(',')}`);
  });

  it('fetchPublicAlert: single get of a released non-synthetic alert', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'publicAlerts/a1')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'publicAlerts/a1-synth')));
  });

  it('fetchClinicianBrief: doctor/brief get; patient denied', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'publicAlerts/a1/doctor/brief')));
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'publicAlerts/a1/doctor/brief')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'publicAlerts/a1/doctor/brief')));
  });
});

describe('matrix · AppointmentFirebase', () => {
  beforeEach(async () => {
    await seed('appointments/a1', {
      uid: 'a1',
      patientUid: 'amina',
      doctorUid: 'drOdhiambo',
      status: 'Requested',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('fetchPatientDelta: patientUid + orderBy lastUpdatedAt', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'appointments'),
        where('patientUid', '==', 'amina'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchDoctorDelta: doctorUid + orderBy lastUpdatedAt', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'appointments'),
        where('doctorUid', '==', 'drOdhiambo'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });
});

describe('matrix · AuthFirebase', () => {
  beforeEach(async () => {
    await seed('patients/amina', patient());
    await seed('doctors/drOdhiambo', doctorProfile({
      uid: 'drOdhiambo',
      isPathologist: false,
      specialties: ['General practice'],
      profilePictureUrl: url('profilePictures', 'drOdhiambo'),
      licenseUrls: [url('licenses', 'drOdhiambo', 'l.pdf')],
    }));
  });

  it('fetchOwnPatientRecord: uid == caller, limit 1', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'patients'),
        where('uid', '==', 'amina'),
        limit(1),
      )),
    );
  });

  it('addFcmToken: arrayUnion + stamp on patient and doctor', async () => {
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'patients/amina'), {
        fcmTokens: arrayUnion('token-a'),
        lastUpdatedAt: STAMP,
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'doctors/drOdhiambo'), {
        fcmTokens: arrayUnion('token-d'),
        lastUpdatedAt: STAMP,
      }),
    );
  });

  it('removeFcmToken: arrayRemove + stamp', async () => {
    await seed('patients/amina', patient({ fcmTokens: ['token-a'] }));
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'patients/amina'), {
        fcmTokens: arrayRemove('token-a'),
        lastUpdatedAt: STAMP,
      }),
    );
  });

  it('updateProfilePicture: patient storage URL + stamp', async () => {
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'patients/amina'), {
        profilePictureUrl: url('profilePictures', 'amina', 'photo.jpg'),
        lastUpdatedAt: STAMP,
      }),
    );
  });

  it('updateLanguage: en/sw + stamp on patient and doctor', async () => {
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'patients/amina'), {
        language: 'en',
        lastUpdatedAt: STAMP,
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'doctors/drOdhiambo'), {
        language: 'sw',
        lastUpdatedAt: STAMP,
      }),
    );
  });

  it('fetchDoctorProfile: own-doc get', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'doctors/drOdhiambo')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'doctors/drOdhiambo')));
  });
});

describe('matrix · CaseFirebase', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc({ currentStage: 'OrderCreated', pathologistUid: '' }));
    await seed('cases/case1/log/1', {
      seq: 1,
      patientVisible: true,
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/log/2', {
      seq: 2,
      patientVisible: false,
      lastUpdatedAt: '2026-10-27T09:01:00.000Z',
    });
    await seed('cases/case1/private/payment', {
      amount: 1,
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/riskCheck/current', {
      status: 'Ready',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/notesTranslation/current', {
      status: 'Ready',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('fetchParticipantDelta: participantUids array-contains + orderBy', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'cases'),
        where('participantUids', 'array-contains', 'drOdhiambo'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchCase: single get by participant', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'cases/case1')));
  });

  it('fetchPatientLog: patientVisible == true + orderBy seq', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'cases/case1/log'),
        where('patientVisible', '==', true),
        orderBy('seq'),
      )),
    );
  });

  it('fetchClinicianLog: unfiltered orderBy seq for case doctor', async () => {
    await assertSucceeds(
      getDocs(query(collection(db('drOdhiambo', DOCTOR), 'cases/case1/log'), orderBy('seq'))),
    );
  });

  it('fetchPayment: private/payment get', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/private/payment')));
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'cases/case1/private/payment')));
  });

  it('fetchRiskCheck: riskCheck/current get by case doctor', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/riskCheck/current')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'cases/case1/riskCheck/current')));
  });

  it('fetchNotesTranslation: notesTranslation/current get by doctor', async () => {
    await assertSucceeds(
      getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/notesTranslation/current')),
    );
  });

  it('updateDoctorNotes: notes fields + stamp while stage is editable', async () => {
    await assertSucceeds(
      updateDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1'), {
        clinicalNotes: 'Updated clinical notes',
        sampleNotes: 'Updated sample notes',
        lastUpdatedAt: STAMP,
      }),
    );
  });
});

describe('matrix · ShareCodeFirebase', () => {
  beforeEach(async () => {
    await seed('shareCodes/s1', {
      createdByUid: 'drOdhiambo',
      recipientUid: 'drOther',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('fetchCreatorDelta: createdByUid + orderBy', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'shareCodes'),
        where('createdByUid', '==', 'drOdhiambo'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchRecipientDelta: recipientUid + orderBy', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOther', DOCTOR), 'shareCodes'),
        where('recipientUid', '==', 'drOther'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchShareCode: single get by creator or recipient', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'shareCodes/s1')));
    await assertSucceeds(getDoc(doc(db('drOther', DOCTOR), 'shareCodes/s1')));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'shareCodes/s1')));
  });
});

describe('matrix · ConversationFirebase', () => {
  beforeEach(async () => seed('conversations/conv1', conversation({
    lastMessageAt: '2026-10-27T09:00:00.000Z',
    lastUpdatedAt: '2026-10-27T09:00:00.000Z',
  })));

  it('fetchParticipantDelta: participantUids + orderBy lastUpdatedAt', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'conversations'),
        where('participantUids', 'array-contains', 'amina'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchConversation: single get', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'conversations/conv1')));
  });

  it('fetchFirstPage: array-contains + orderBy lastMessageAt DESC', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'conversations'),
        where('participantUids', 'array-contains', 'drOdhiambo'),
        orderBy('lastMessageAt', 'desc'),
        limit(30),
      )),
    );
  });

  it('fetchMessages: readable statuses and own-rows queries; unfiltered fails with peer Withheld', async () => {
    await seed(`conversations/conv1/messages/${MSG_TEXT}`, message());
    await seed(
      `conversations/conv1/messages/${MSG_OTHER}`,
      message({
        uid: MSG_OTHER,
        senderUid: 'amina',
        status: 'Withheld',
        withheldReason: 'rateLimited',
        text: 'hidden',
      }),
    );
    await assertFails(
      getDocs(query(collection(db('drOdhiambo', DOCTOR), 'conversations/conv1/messages'), orderBy('sentAt'))),
    );
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'conversations/conv1/messages'),
        where('status', 'in', ['Sent', 'Delivered', 'Withdrawn']),
        orderBy('sentAt'),
      )),
    );
    await assertSucceeds(
      getDocs(query(
        collection(db('drOdhiambo', DOCTOR), 'conversations/conv1/messages'),
        where('senderUid', '==', 'drOdhiambo'),
        orderBy('sentAt'),
      )),
    );
  });

  it('fetchMessage: single get', async () => {
    await seed(`conversations/conv1/messages/${MSG_TEXT}`, message());
    await assertSucceeds(
      getDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
  });

  it('fetchCursor: single get by participant', async () => {
    await seed('conversations/conv1/cursors/amina', {
      uid: 'amina',
      conversationUid: 'conv1',
      lastReadAt: STAMP,
      lastUpdatedAt: STAMP,
    });
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/amina')));
  });

  it('updateCursor create: lastUpdatedAt must equal lastReadAt', async () => {
    await assertSucceeds(
      setDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/amina'), {
        uid: 'amina',
        conversationUid: 'conv1',
        lastReadAt: STAMP,
        lastUpdatedAt: STAMP,
      }),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), 'conversations/conv1/cursors/drOdhiambo'), {
        uid: 'drOdhiambo',
        conversationUid: 'conv1',
        lastReadAt: STAMP,
        lastUpdatedAt: STAMP_LATER,
      }),
    );
  });

  it('updateCursor update: forward lastReadAt + stamp', async () => {
    await seed('conversations/conv1/cursors/amina', {
      uid: 'amina',
      conversationUid: 'conv1',
      lastReadAt: STAMP,
      lastUpdatedAt: STAMP,
    });
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/amina'), {
        lastReadAt: STAMP_LATER,
        lastUpdatedAt: STAMP_LATER,
      }),
    );
  });

  it('createTextMessage: the fixed Dart payload creates', async () => {
    await assertSucceeds(
      setDoc(
        doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`),
        createTextMessagePayload(),
      ),
    );
  });

  it('createVoiceMessage: the fixed Dart payload creates', async () => {
    await assertSucceeds(
      setDoc(
        doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_VOICE}`),
        createVoiceMessagePayload(),
      ),
    );
  });
});

describe('matrix · NotificationFirebase', () => {
  beforeEach(async () => {
    await seed('notifications/n1', {
      recipientUid: 'amina',
      status: 'Unread',
      readAt: '',
      shareCode: '',
      pushSentAt: '',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('fetchInboxDelta: recipientUid + orderBy lastUpdatedAt', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'notifications'),
        where('recipientUid', '==', 'amina'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('markRead: status Read + readAt + stamp', async () => {
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'notifications/n1'), {
        status: 'Read',
        readAt: STAMP,
        lastUpdatedAt: STAMP,
      }),
    );
  });
});

describe('matrix · ReportFirebase', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/reports/v1', report({
      readerUids: ['drOdhiambo', 'drWanjiru', 'amina'],
      releasedToPatient: true,
    }));
    await seed('cases/case1/reportDrafts/drWanjiru', draft());
    await seed('cases/case1/preread/run1', {
      uid: 'run1',
      status: 'Ready',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/prereadScores/run1', {
      uid: 'run1',
      pathologistUid: 'drWanjiru',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
    await seed('cases/case1/reportTextsApproved/v1_Translation_en', {
      uid: 'v1_Translation_en',
      approvedText: { title: 't' },
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('fetchReaderDelta: collectionGroup reports + readerUids', async () => {
    await assertSucceeds(
      getDocs(query(
        collectionGroup(db('drOdhiambo', DOCTOR), 'reports'),
        where('readerUids', 'array-contains', 'drOdhiambo'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchPatientDelta: readerUids + releasedToPatient', async () => {
    await assertSucceeds(
      getDocs(query(
        collectionGroup(db('amina', PATIENT), 'reports'),
        where('readerUids', 'array-contains', 'amina'),
        where('releasedToPatient', '==', true),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchReport: single get', async () => {
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reports/v1')));
  });

  it('fetchReportForPdf: single get (same rule as fetchReport)', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reports/v1')));
  });

  it('fetchDraft: single get by case pathologist', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru')));
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reportDrafts/drWanjiru')));
  });

  it('updateDraft: editable field + forward stamp', async () => {
    // diagnosis while diagnosisStartedAt is empty is refused (bounded); title is always legal.
    await assertSucceeds(
      updateDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/reportDrafts/drWanjiru'), {
        title: 'Biopsy',
        lastUpdatedAt: STAMP,
      }),
    );
  });

  it('fetchPreread: single get by case pathologist', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/preread/run1')));
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/preread/run1')));
  });

  it('fetchPrereadScore: single get by case pathologist', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'cases/case1/prereadScores/run1')));
  });

  it('fetchApprovedText: single get by deterministic id', async () => {
    await assertSucceeds(
      getDoc(doc(db('drOdhiambo', DOCTOR), 'cases/case1/reportTextsApproved/v1_Translation_en')),
    );
  });
});

describe('matrix · WorklistFirebase', () => {
  beforeEach(async () => {
    await seed('worklist/case1', {
      uid: 'case1',
      pathologistUid: 'drWanjiru',
      status: 'Open',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('fetchPathologistDelta: pathologistUid + orderBy', async () => {
    await assertSucceeds(
      getDocs(query(
        collection(db('drWanjiru', PATHOLOGIST), 'worklist'),
        where('pathologistUid', '==', 'drWanjiru'),
        orderBy('lastUpdatedAt'),
      )),
    );
  });

  it('fetchEntry: single get', async () => {
    await assertSucceeds(getDoc(doc(db('drWanjiru', PATHOLOGIST), 'worklist/case1')));
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'worklist/case1')));
  });
});
