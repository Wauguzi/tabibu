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
  setDoc,
  updateDoc,
  deleteDoc,
  where,
} = require('firebase/firestore');
const {
  conversation,
  message,
  MSG_TEXT,
  MSG_IMAGE,
  MSG_VOICE,
  MSG_VOICE_PATIENT,
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

describe('conversations', () => {
  beforeEach(async () => seed('conversations/conv1', conversation()));

  it('RT-135 a participant reads the conversation', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'conversations/conv1')));
    await assertSucceeds(getDoc(doc(db('drOdhiambo', DOCTOR), 'conversations/conv1')));
  });

  it('RT-136 non-participant, Invited, Declined and Left are denied', async () => {
    await assertFails(getDoc(doc(db('stranger', DOCTOR), 'conversations/conv1')));
    await seed('conversations/conv1', conversation({ participantUids: ['drOdhiambo'] }));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'conversations/conv1')));
    await seed('conversations/conv1', conversation({
      status: 'Open',
      participantUids: ['drOdhiambo'],
      members: { amina: { status: 'Invited' } },
    }));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'conversations/conv1')));
    await seed('conversations/conv1', conversation({
      participantUids: ['drOdhiambo'],
      members: { amina: { status: 'Declined' } },
    }));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'conversations/conv1')));
    await seed('conversations/conv1', conversation({
      participantUids: ['drOdhiambo'],
      members: { amina: { status: 'Left' } },
    }));
    await assertFails(getDoc(doc(db('amina', PATIENT), 'conversations/conv1')));
  });

  it('RT-137 a list without the filter is denied', async () => {
    await assertFails(getDocs(collection(db('amina', PATIENT), 'conversations')));
    await assertSucceeds(
      getDocs(query(
        collection(db('amina', PATIENT), 'conversations'),
        where('participantUids', 'array-contains', 'amina'),
      )),
    );
  });

  it('RT-138 every client write on the conversation is denied', async () => {
    await assertFails(
      updateDoc(doc(db('amina', PATIENT), 'conversations/conv1'), { status: 'Closed', ...at }),
    );
    await assertFails(
      setDoc(doc(db('amina', PATIENT), 'conversations/conv2'), conversation({ uid: 'conv2' })),
    );
    await assertFails(deleteDoc(doc(db('amina', PATIENT), 'conversations/conv1')));
  });
});

describe('cursors', () => {
  beforeEach(async () => seed('conversations/conv1', conversation()));

  it('RT-139 a member creates and moves their own cursor forward', async () => {
    await assertSucceeds(
      setDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/amina'), {
        uid: 'amina',
        conversationUid: 'conv1',
        lastReadAt: '2026-10-28T09:00:00.000Z',
        lastUpdatedAt: '2026-10-28T09:00:00.000Z',
      }),
    );
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/amina'), {
        lastReadAt: '2026-10-28T10:00:00.000Z',
        lastUpdatedAt: '2026-10-28T10:00:00.000Z',
      }),
    );
  });

  it("RT-140 another member's cursor is denied", async () => {
    await seed('conversations/conv1/cursors/drOdhiambo', {
      uid: 'drOdhiambo',
      conversationUid: 'conv1',
      lastReadAt: '2026-10-28T09:00:00.000Z',
      lastUpdatedAt: '2026-10-28T09:00:00.000Z',
    });
    await assertFails(
      updateDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/drOdhiambo'), {
        lastReadAt: '2026-10-28T11:00:00.000Z',
        ...at,
      }),
    );
    await assertFails(
      setDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/drOdhiambo'), {
        uid: 'drOdhiambo',
        conversationUid: 'conv1',
        lastReadAt: '2026-10-28T09:00:00.000Z',
        lastUpdatedAt: '2026-10-28T09:00:00.000Z',
      }),
    );
  });

  it('RT-141 a backwards move is denied', async () => {
    await seed('conversations/conv1/cursors/amina', {
      uid: 'amina',
      conversationUid: 'conv1',
      lastReadAt: '2026-10-28T10:00:00.000Z',
      lastUpdatedAt: '2026-10-28T10:00:00.000Z',
    });
    await assertFails(
      updateDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/amina'), {
        lastReadAt: '2026-10-28T09:00:00.000Z',
        lastUpdatedAt: '2026-10-28T11:00:00.000Z',
      }),
    );
  });

  it('RT-142 a non-participant read is denied', async () => {
    await seed('conversations/conv1/cursors/amina', {
      uid: 'amina',
      conversationUid: 'conv1',
      lastReadAt: '2026-10-28T09:00:00.000Z',
      lastUpdatedAt: '2026-10-28T09:00:00.000Z',
    });
    await assertFails(getDoc(doc(db('stranger', DOCTOR), 'conversations/conv1/cursors/amina')));
  });

  it('RT-143 cursor delete is denied', async () => {
    await seed('conversations/conv1/cursors/amina', {
      uid: 'amina',
      conversationUid: 'conv1',
      lastReadAt: '2026-10-28T09:00:00.000Z',
      lastUpdatedAt: '2026-10-28T09:00:00.000Z',
    });
    await assertFails(deleteDoc(doc(db('amina', PATIENT), 'conversations/conv1/cursors/amina')));
  });
});

function textMsg(overrides = {}) {
  return message(overrides);
}

function imageMsg(overrides = {}) {
  return message({
    uid: MSG_IMAGE,
    kind: 'Image',
    text: '',
    attachmentPath: `conversations/conv1/images/${MSG_IMAGE}/image.jpg`,
    attachmentType: 'image/jpeg',
    attachmentSize: 1000,
    ...overrides,
  });
}

function voiceMsg(overrides = {}) {
  return message({
    uid: MSG_VOICE,
    kind: 'Voice',
    text: '',
    attachmentPath: `conversations/conv1/voice/${MSG_VOICE}.m4a`,
    attachmentType: 'audio/mp4',
    attachmentSize: 100000,
    voiceDurationMs: 60000,
    voicePeaks: [10, 20, 30],
    inputMode: 'Voice',
    transcriptStatus: 'Queued',
    ...overrides,
  });
}

describe('messages', () => {
  beforeEach(async () => seed('conversations/conv1', conversation()));

  it('RT-144 valid create: text, image and voice', async () => {
    await assertSucceeds(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), textMsg()),
    );
    await assertSucceeds(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_IMAGE}`), imageMsg()),
    );
    await assertSucceeds(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_VOICE}`), voiceMsg()),
    );
  });

  it('RT-145 sender ≠ auth is denied', async () => {
    await assertFails(
      setDoc(
        doc(db('amina', PATIENT), `conversations/conv1/messages/${MSG_TEXT}`),
        textMsg({ senderUid: 'drOdhiambo' }),
      ),
    );
  });

  it('RT-146 a closed thread is denied', async () => {
    await seed('conversations/conv1', conversation({ status: 'Closed' }));
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), textMsg()),
    );
  });

  it('RT-147 a blocked sender is denied', async () => {
    await seed('messageQuotas/drOdhiambo', { blocked: true, blockedUntil: '2099-01-01T00:00:00.000Z' });
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), textMsg()),
    );
  });

  it('RT-148 bounds, extra key, Delivered, client transcript, long duration, peaks, voice-blocked denied', async () => {
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), {
        ...textMsg(),
        text: 'x'.repeat(2001),
      }),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), {
        ...textMsg(),
        extra: true,
      }),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), {
        ...textMsg(),
        status: 'Delivered',
      }),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_VOICE}`), {
        ...voiceMsg(),
        transcript: 'secret',
      }),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_VOICE}`), {
        ...voiceMsg(),
        voiceDurationMs: 120001,
      }),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_VOICE}`), {
        ...voiceMsg(),
        voicePeaks: new Array(65).fill(1),
      }),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_VOICE}`), {
        ...voiceMsg(),
        voicePeaks: ['x'],
      }),
    );
    await seed('messageQuotas/drOdhiambo', {
      blocked: false,
      voiceBlockedUntil: '2099-01-01T00:00:00.000Z',
    });
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_VOICE}`), voiceMsg()),
    );
  });

  it('RT-149 attachment variants and H-1 regex injection are denied', async () => {
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_IMAGE}`), imageMsg({
        attachmentPath: `conversations/conv1/voice/${MSG_IMAGE}.m4a`,
        attachmentType: 'audio/mp4',
      })),
    );
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_IMAGE}`), imageMsg({
        attachmentPath: `conversations/conv1/images/${MSG_IMAGE}/image.gif`,
        attachmentType: 'image/gif',
      })),
    );
    // H-1: mid with regex metacharacters is not a UUID v4.
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), 'conversations/conv1/messages/x|.*'), {
        ...imageMsg({ uid: 'x|.*' }),
        attachmentPath: 'conversations/VICTIM/images/M/image.jpg',
      }),
    );
    // H-1: valid UUID mid, path for another conversation.
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_IMAGE}`), imageMsg({
        attachmentPath: `conversations/VICTIM/images/${MSG_IMAGE}/image.jpg`,
      })),
    );
    // H-1: valid UUID mid, path for another mid.
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_IMAGE}`), imageMsg({
        attachmentPath: `conversations/conv1/images/${MSG_OTHER}/image.jpg`,
      })),
    );
  });

  it('RT-150 identical replay allowed; Delivered replay denied', async () => {
    const payload = textMsg();
    await seed(`conversations/conv1/messages/${MSG_TEXT}`, payload);
    await assertSucceeds(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), payload),
    );
    await seed(`conversations/conv1/messages/${MSG_TEXT}`, textMsg({
      status: 'Delivered',
      deliveredAt: '2026-10-28T09:00:01.000Z',
    }));
    await assertFails(
      setDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`), payload),
    );
  });

  it('RT-151 a real update or delete is denied', async () => {
    await seed(`conversations/conv1/messages/${MSG_TEXT}`, textMsg());
    await assertFails(
      updateDoc(
        doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`),
        { text: 'edited' },
      ),
    );
    await assertFails(
      deleteDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
  });

  it('RT-196 message reads: participant allowed; non-participant and role-less denied (M-1)', async () => {
    await seed(`conversations/conv1/messages/${MSG_TEXT}`, textMsg());
    await assertSucceeds(
      getDoc(doc(db('amina', PATIENT), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
    await assertSucceeds(
      getDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
    await assertFails(
      getDoc(doc(db('stranger', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
    await assertFails(
      getDoc(doc(db('amina', {}), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
  });

  it('RT-197 withheld messages are readable only by their sender (L-1)', async () => {
    await seed(`conversations/conv1/messages/${MSG_TEXT}`, textMsg({
      status: 'rateLimited',
      withheldReason: 'rateLimited',
      senderUid: 'drOdhiambo',
    }));
    await assertSucceeds(
      getDoc(doc(db('drOdhiambo', DOCTOR), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
    await assertFails(
      getDoc(doc(db('amina', PATIENT), `conversations/conv1/messages/${MSG_TEXT}`)),
    );
  });
});

describe('messageQuotas', () => {
  it('RT-152 messageQuotas is closed', async () => {
    await seed('messageQuotas/drOdhiambo', { blocked: false });
    await assertFails(getDoc(doc(db('drOdhiambo', DOCTOR), 'messageQuotas/drOdhiambo')));
  });
});

describe('notifications', () => {
  beforeEach(async () => {
    await seed('notifications/n1', {
      recipientUid: 'amina',
      status: 'Unread',
      readAt: '',
      metadata: { deepLink: '/x' },
      shareCode: '',
      pushSentAt: '',
      lastUpdatedAt: '2026-10-27T09:00:00.000Z',
    });
  });

  it('RT-153 the recipient reads the notification', async () => {
    await assertSucceeds(getDoc(doc(db('amina', PATIENT), 'notifications/n1')));
  });

  it('RT-154 another user is denied', async () => {
    await assertFails(getDoc(doc(db('juma', PATIENT), 'notifications/n1')));
  });

  it('RT-155 a read-state update is allowed', async () => {
    await assertSucceeds(
      updateDoc(doc(db('amina', PATIENT), 'notifications/n1'), {
        status: 'Read',
        readAt: '2026-10-28T09:00:00.000Z',
        ...at,
      }),
    );
  });

  it('RT-156 metadata, shareCode, pushSentAt or a bogus status are denied', async () => {
    const ref = doc(db('amina', PATIENT), 'notifications/n1');
    await assertFails(updateDoc(ref, { metadata: { deepLink: '/y' }, ...at }));
    await assertFails(updateDoc(ref, { shareCode: 'ABC', ...at }));
    await assertFails(updateDoc(ref, { pushSentAt: 't', ...at }));
    await assertFails(updateDoc(ref, { status: 'Gone', readAt: 't', ...at }));
  });

  it('RT-157 create and delete are denied (T-3)', async () => {
    await assertFails(
      setDoc(doc(db('amina', PATIENT), 'notifications/n2'), {
        recipientUid: 'amina',
        status: 'Unread',
        lastUpdatedAt: 't',
      }),
    );
    await assertFails(deleteDoc(doc(db('amina', PATIENT), 'notifications/n1')));
  });
});

describe('transcripts', () => {
  beforeEach(async () => {
    await seed('conversations/conv1', conversation({
      participantUids: ['drOdhiambo', 'amina', 'drWanjiru'],
    }));
    await seed(`conversations/conv1/messages/${MSG_VOICE}`, voiceMsg({ senderUid: 'drOdhiambo' }));
    await seed(`conversations/conv1/messages/${MSG_VOICE}/transcript/machine`, {
      uid: 'machine',
      text: 'clinician note',
      senderUid: 'drOdhiambo',
    });
    await seed(`conversations/conv1/messages/${MSG_VOICE}/transcript/shared`, {
      uid: 'shared',
      text: 'shared note',
      senderUid: 'drOdhiambo',
    });
    await seed(`conversations/conv1/messages/${MSG_VOICE_PATIENT}`, voiceMsg({
      uid: MSG_VOICE_PATIENT,
      senderUid: 'amina',
      attachmentPath: `conversations/conv1/voice/${MSG_VOICE_PATIENT}.m4a`,
    }));
    await seed(`conversations/conv1/messages/${MSG_VOICE_PATIENT}/transcript/machine`, {
      uid: 'machine',
      text: 'patient note',
      senderUid: 'amina',
    });
  });

  it('RT-187 a patient is denied transcript/machine on a clinician voice note (F-1)', async () => {
    await assertFails(
      getDoc(doc(
        db('amina', PATIENT),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/machine`,
      )),
    );
  });

  it('RT-188 the patient reads transcript/shared; a missing one reads as absent', async () => {
    await assertSucceeds(
      getDoc(doc(
        db('amina', PATIENT),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/shared`,
      )),
    );
    await assertSucceeds(
      getDoc(doc(
        db('amina', PATIENT),
        `conversations/conv1/messages/${MSG_OTHER}/transcript/shared`,
      )),
    );
  });

  it('RT-189 the sender and a clinician read transcript/machine', async () => {
    await assertSucceeds(
      getDoc(doc(
        db('drOdhiambo', DOCTOR),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/machine`,
      )),
    );
    await assertSucceeds(
      getDoc(doc(
        db('drWanjiru', PATHOLOGIST),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/machine`,
      )),
    );
  });

  it('RT-190 every client write to transcript/* is denied', async () => {
    await assertFails(
      updateDoc(
        doc(
          db('drOdhiambo', DOCTOR),
          `conversations/conv1/messages/${MSG_VOICE}/transcript/machine`,
        ),
        { text: 'edited' },
      ),
    );
  });

  it('RT-198 H-2 / S-8: doctor reads patient machine; patient denied clinician machine; shared ok; stranger denied', async () => {
    await assertSucceeds(
      getDoc(doc(
        db('drOdhiambo', DOCTOR),
        `conversations/conv1/messages/${MSG_VOICE_PATIENT}/transcript/machine`,
      )),
    );
    await assertFails(
      getDoc(doc(
        db('amina', PATIENT),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/machine`,
      )),
    );
    await assertSucceeds(
      getDoc(doc(
        db('amina', PATIENT),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/shared`,
      )),
    );
    await assertFails(
      getDoc(doc(
        db('stranger', DOCTOR),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/machine`,
      )),
    );
    await assertFails(
      getDoc(doc(
        db('stranger', DOCTOR),
        `conversations/conv1/messages/${MSG_VOICE}/transcript/shared`,
      )),
    );
  });
});
