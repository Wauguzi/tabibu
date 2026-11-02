'use strict';

const {
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { getMetadata, ref, uploadBytes, deleteObject } = require('firebase/storage');
const {
  caseDoc,
  report,
  conversation,
  message,
  MSG_IMAGE,
  MSG_VOICE,
  MSG_OTHER,
  PATIENT,
  DOCTOR,
  PATHOLOGIST,
  setupEnv,
  cleanupEnv,
  clearAll,
  seed,
  seedBytes,
  as,
} = require('./fixtures');

before(async () => setupEnv());
after(async () => cleanupEnv());
beforeEach(async () => clearAll());

const image = new Uint8Array([0xff, 0xd8, 0xff]);
const png = new Uint8Array([0x89, 0x50, 0x4e]);
const audio = new Uint8Array(100);
const bigVoice = new Uint8Array(512 * 1024 + 1);
const over20 = new Uint8Array(20 * 1024 * 1024 + 1);
const over3 = new Uint8Array(3 * 1024 * 1024);

const put = (uid, claims, path, data = image, contentType = 'image/jpeg') =>
  uploadBytes(ref(as(uid, claims).storage(), path), data, { contentType });

const meta = (uid, claims, path) => getMetadata(ref(as(uid, claims).storage(), path));

describe('storage slides preread signatures', () => {
  beforeEach(async () => {
    await seed('cases/case1', caseDoc({
      pathologistUid: '',
      doctorUid: 'drOdhiambo',
      // Bare uids only — the shape reserveSlideUploads writes (C-20).
      slideUploadUids: ['slide1', 'slide2'],
      participantUids: ['drOdhiambo', 'amina', 'viewer1'],
    }));
  });

  it('RT-158 slides: reserved stem by doctor before acceptance and pathologist after', async () => {
    await assertSucceeds(put('drOdhiambo', DOCTOR, 'slides/case1/slide1.jpg'));
    // Either extension of a reserved stem is allowed; content-type still binds.
    await assertSucceeds(put('drOdhiambo', DOCTOR, 'slides/case1/slide1.png', png, 'image/png'));
    await seed('cases/case1', caseDoc({
      pathologistUid: 'drWanjiru',
      slideUploadUids: ['slide1', 'slide2'],
    }));
    await assertSucceeds(put('drWanjiru', PATHOLOGIST, 'slides/case1/slide2.png', png, 'image/png'));
  });

  it('RT-159 an unreserved stem is denied (F-22)', async () => {
    await assertFails(put('drOdhiambo', DOCTOR, 'slides/case1/notReserved.jpg'));
    // A full object name left over from the old reservation shape is also refused.
    await assertFails(put('drOdhiambo', DOCTOR, 'slides/case1/slide1.jpg.jpg'));
  });

  it('RT-160 patient or viewer read, wrong type, or oversize denied', async () => {
    await seedBytes('slides/case1/slide1.jpg', image, 'image/jpeg');
    await assertFails(meta('amina', PATIENT, 'slides/case1/slide1.jpg'));
    await assertFails(meta('viewer1', DOCTOR, 'slides/case1/slide1.jpg'));
    // Reach typedAs() on a fresh reserved name (mismatched content type).
    await assertFails(put('drOdhiambo', DOCTOR, 'slides/case1/slide2.png', image, 'image/jpeg'));
    await assertFails(put('drOdhiambo', DOCTOR, 'slides/case1/slide2.png', over20, 'image/png'));
  });

  it('RT-161 preread files: pathologist reads; writes denied', async () => {
    await seed('cases/case1', caseDoc());
    await seedBytes('preread/case1/run1/labels.json', new Uint8Array([1]), 'application/json');
    await assertSucceeds(meta('drWanjiru', PATHOLOGIST, 'preread/case1/run1/labels.json'));
    await assertFails(meta('drOdhiambo', DOCTOR, 'preread/case1/run1/labels.json'));
    await assertFails(
      put('drWanjiru', PATHOLOGIST, 'preread/case1/run1/labels.json', new Uint8Array([1]), 'application/json'),
    );
  });

  it('RT-162 signature: a reader reads; unreleased patient, stranger and role-less denied', async () => {
    const sha = 'a'.repeat(64);
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/reports/v1', report({
      readerUids: ['drOdhiambo', 'amina'],
      releasedToPatient: false,
    }));
    await seedBytes(`reports/case1/v1/signature-${sha}.png`, png, 'image/png');
    await assertSucceeds(meta('drOdhiambo', DOCTOR, `reports/case1/v1/signature-${sha}.png`));
    await assertFails(meta('amina', PATIENT, `reports/case1/v1/signature-${sha}.png`));
    await assertFails(meta('stranger', DOCTOR, `reports/case1/v1/signature-${sha}.png`));
    await assertFails(meta('drOdhiambo', {}, `reports/case1/v1/signature-${sha}.png`));
    await seed('cases/case1/reports/v1', report({
      readerUids: ['amina'],
      releasedToPatient: true,
    }));
    await assertSucceeds(meta('amina', PATIENT, `reports/case1/v1/signature-${sha}.png`));
  });

  it('RT-163 signature write is denied', async () => {
    const sha = 'b'.repeat(64);
    await seed('cases/case1', caseDoc());
    await seed('cases/case1/reports/v1', report());
    await assertFails(
      put('drWanjiru', PATHOLOGIST, `reports/case1/v1/signature-${sha}.png`, png, 'image/png'),
    );
  });
});

describe('storage conversation media and speech', () => {
  beforeEach(async () => {
    await seed('conversations/conv1', conversation());
  });

  it('RT-164 conversation image before its message', async () => {
    await assertSucceeds(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/image.jpg`),
    );
  });

  it('RT-165 conversation image variants denied', async () => {
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/photo.jpg`),
    );
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/image.gif`, image, 'image/gif'),
    );
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/image.jpg`, over3),
    );
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/image.jpg`, image, 'image/png'),
    );
    await seed(`conversations/conv1/messages/${MSG_IMAGE}`, message({
      uid: MSG_IMAGE,
      kind: 'Image',
    }));
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/image.jpg`),
    );
    await seed('conversations/conv1', conversation({ status: 'Closed' }));
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_OTHER}/image.jpg`),
    );
    await seed('conversations/conv1', conversation());
    await assertFails(
      put('stranger', DOCTOR, `conversations/conv1/images/${MSG_OTHER}/image.jpg`),
    );
    // Non-UUID mid denied (H-1).
    await assertFails(
      put('drOdhiambo', DOCTOR, 'conversations/conv1/images/m1/image.jpg'),
    );
  });

  it('RT-166 conversation non-participant read denied', async () => {
    await seedBytes(`conversations/conv1/images/${MSG_IMAGE}/image.jpg`, image, 'image/jpeg');
    await assertFails(meta('stranger', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/image.jpg`));
  });

  it('RT-167 speechAudio owner write allowed', async () => {
    await assertSucceeds(
      put('amina', PATIENT, 'speechAudio/amina/a1.m4a', audio, 'audio/mp4'),
    );
  });

  it("RT-168 another uid's write, any read, and wrong type or size denied", async () => {
    await assertFails(put('amina', PATIENT, 'speechAudio/juma/a1.m4a', audio, 'audio/mp4'));
    await seedBytes('speechAudio/amina/a1.m4a', audio, 'audio/mp4');
    await assertFails(meta('amina', PATIENT, 'speechAudio/amina/a1.m4a'));
    await assertFails(put('amina', PATIENT, 'speechAudio/amina/a2.m4a', audio, 'text/plain'));
    await assertFails(put('amina', PATIENT, 'speechAudio/amina/a3.m4a', bigVoice, 'audio/mp4'));
  });

  it('RT-169 a voice note uploaded by a participant before its message', async () => {
    await assertSucceeds(
      put('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_VOICE}.m4a`, audio, 'audio/mp4'),
    );
  });

  it('RT-170 voice note after message, non-participant, oversize, wrong type, closed, update/delete denied', async () => {
    await seed(`conversations/conv1/messages/${MSG_VOICE}`, {
      uid: MSG_VOICE,
      conversationUid: 'conv1',
      senderUid: 'drOdhiambo',
      kind: 'Voice',
      status: 'Sent',
    });
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_VOICE}.m4a`, audio, 'audio/mp4'),
    );
    await assertFails(
      put('stranger', DOCTOR, `conversations/conv1/voice/${MSG_OTHER}.m4a`, audio, 'audio/mp4'),
    );
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_OTHER}.m4a`, bigVoice, 'audio/mp4'),
    );
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_OTHER}.m4a`, audio, 'audio/mpeg'),
    );
    await seed('conversations/conv1', conversation({ status: 'Closed' }));
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_OTHER}.m4a`, audio, 'audio/mp4'),
    );
    await seed('conversations/conv1', conversation());
    await seedBytes(`conversations/conv1/voice/${MSG_OTHER}.m4a`, audio, 'audio/mp4');
    await assertSucceeds(meta('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_OTHER}.m4a`));
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_OTHER}.m4a`, audio, 'audio/mp4'),
    );
    await assertFails(
      deleteObject(ref(as('drOdhiambo', DOCTOR).storage(), `conversations/conv1/voice/${MSG_OTHER}.m4a`)),
    );
  });

  it('RT-171 a voice-note read by a non-participant is denied', async () => {
    await seedBytes(`conversations/conv1/voice/${MSG_VOICE}.m4a`, audio, 'audio/mp4');
    await assertFails(meta('stranger', DOCTOR, `conversations/conv1/voice/${MSG_VOICE}.m4a`));
  });

  it('RT-192 a role-less participant is denied conversation images and voice notes (F-19)', async () => {
    await seedBytes(`conversations/conv1/images/${MSG_IMAGE}/image.jpg`, image, 'image/jpeg');
    await seedBytes(`conversations/conv1/voice/${MSG_VOICE}.m4a`, audio, 'audio/mp4');
    await assertFails(meta('amina', {}, `conversations/conv1/images/${MSG_IMAGE}/image.jpg`));
    await assertFails(meta('amina', {}, `conversations/conv1/voice/${MSG_VOICE}.m4a`));
  });

  it('RT-193 an image under voice/, and a voice file under images/, denied', async () => {
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/voice/${MSG_IMAGE}.jpg`, image, 'image/jpeg'),
    );
    await assertFails(
      put('drOdhiambo', DOCTOR, `conversations/conv1/images/${MSG_IMAGE}/image.m4a`, audio, 'audio/mp4'),
    );
  });

  it("RT-195 a doctor's speechAudio write is denied (F-35)", async () => {
    await assertFails(
      put('drOdhiambo', DOCTOR, 'speechAudio/drOdhiambo/a1.m4a', audio, 'audio/mp4'),
    );
  });
});
