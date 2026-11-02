import assert from 'node:assert/strict';

import { participants } from './access';
import { emulatorDeps, resetEmulators } from './emulator.test-support';
import {
  CaseState,
  PATIENT_VISIBLE_STAGES,
  TABLE_ACTIONS,
  TABLE_STAGES,
  allowedTransition,
  closeDiscussion,
  commitCase,
  transition,
  type CaseAction,
  type CaseStage,
} from './orchestrator';

const requested = {
  uid: 'p-new',
  name: 'Dr New',
  requestedAt: '2026-10-27T09:00:00.000Z',
  expiresAt: '2026-10-28T09:00:00.000Z',
};

describe('orchestrator', () => {
  beforeEach(async () => {
    await resetEmulators();
  });

  it('chains two transitions into log/0001, log/0002 and stageSeq 2', async () => {
    const deps = emulatorDeps();
    const ref = deps.db.collection('cases').doc('case-1');
    let s = CaseState.initial({ uid: 'case-1', doctorUid: 'doc-1', patientUid: 'pat-1' });
    s = transition(s, 'OrderCreated', { actorUid: 'doc-1', actorRole: 'Doctor' });
    s = transition(s, 'PathologistRequested', {
      actorUid: 'doc-1',
      actorRole: 'Doctor',
      requested,
    });
    assert.equal(s.stageSeq, 2);
    await deps.db.runTransaction(async (tx) => {
      commitCase(tx, ref, s, deps.now!());
    });
    assert.equal((await ref.get()).data()?.stageSeq, 2);
    assert.equal((await ref.collection('log').doc('0001').get()).exists, true);
    assert.equal((await ref.collection('log').doc('0002').get()).exists, true);
  });

  it('refuses free text on a patient-visible log', () => {
    const s = transition(CaseState.initial({ uid: 'c', doctorUid: 'd' }), 'OrderCreated', {
      actorUid: 'd',
      actorRole: 'Doctor',
    });
    assert.throws(
      () =>
        transition(s, 'Cancelled', {
          actorUid: 'd',
          actorRole: 'Doctor',
          action: 'Cancel',
          reason: 'changed my mind freely',
        }),
      (e: Error) => e.message === 'invalidReason',
    );
  });

  it('requires a cancel reason code', () => {
    const s = transition(CaseState.initial({ uid: 'c', doctorUid: 'd' }), 'OrderCreated', {
      actorUid: 'd',
      actorRole: 'Doctor',
    });
    assert.throws(
      () =>
        transition(s, 'Cancelled', {
          actorUid: 'd',
          actorRole: 'Doctor',
          action: 'Cancel',
          reason: '',
        }),
      (e: Error) => e.message === 'invalidReason',
    );
  });

  it('rejects, expires and reassigns clear the departing pathologist from participants', () => {
    let s = CaseState.initial({ uid: 'c', doctorUid: 'd', patientUid: 'pat' });
    s = transition(s, 'OrderCreated', { actorUid: 'd', actorRole: 'Doctor' });
    s = transition(s, 'PathologistRequested', {
      actorUid: 'd',
      actorRole: 'Doctor',
      requested: { ...requested, uid: 'oldP', name: 'Old' },
    });
    assert.ok(participants(s).includes('oldP'));

    const rejected = transition(s, 'PathologistRejected', {
      actorUid: 'oldP',
      actorRole: 'Pathologist',
      action: 'Reject',
      reason: 'too busy this week',
    });
    assert.equal(rejected.requestedPathologistUid, '');
    assert.equal(participants(rejected).includes('oldP'), false);

    const expired = transition(s, 'PathologistRejected', {
      actorUid: 'system',
      actorRole: 'System',
      action: 'Expire',
    });
    assert.equal(participants(expired).includes('oldP'), false);

    let accepted = transition(s, 'PathologistAccepted', {
      actorUid: 'oldP',
      actorRole: 'Pathologist',
    });
    accepted = accepted.with({ pathologistUid: 'oldP' });
    assert.ok(participants(accepted).includes('oldP'));
    const reassigned = transition(accepted, 'PathologistRequested', {
      actorUid: 'd',
      actorRole: 'Doctor',
      action: 'Reassign',
      requested: { ...requested, uid: 'newP', name: 'New' },
    });
    assert.equal(reassigned.pathologistUid, '');
    assert.equal(reassigned.requestedPathologistUid, 'newP');
    assert.equal(participants(reassigned).includes('oldP'), false);
    assert.ok(participants(reassigned).includes('newP'));
  });

  it('with() refuses stage keys and FieldValue-like objects', () => {
    const s = CaseState.initial({ uid: 'c', doctorUid: 'd' });
    assert.throws(
      () => s.with({ currentStage: 'ResultReleased' }),
      (e: Error) => e.message === 'invalidPatch',
    );
    assert.throws(
      () => s.with({ viewerUids: { _methodName: 'arrayUnion' } }),
      (e: Error) => e.message === 'invalidPatch',
    );
  });

  it('with() takes lists of plain records for slide keys only, and refuses anything exotic inside', () => {
    const s = CaseState.initial({ uid: 'c', doctorUid: 'd' });
    const slide = { imageUid: 'i', path: 'slides/c/i.jpg', micronsPerPixel: 0.25, tags: ['a'] };
    assert.deepEqual(s.with({ slideImages: [slide] }).fields.slideImages, [slide]);
    assert.throws(() => s.with({ viewerUids: [slide] }), (e: Error) => e.message === 'invalidPatch');
    assert.throws(
      () => s.with({ slideImages: [{ ...slide, uploadedAt: { _methodName: 'serverTimestamp' } }] }),
      (e: Error) => e.message === 'invalidPatch',
    );
    class Sentinel {
      readonly imageUid = 'i';
    }
    assert.throws(() => s.with({ slideImages: [new Sentinel()] }), (e: Error) => e.message === 'invalidPatch');
    assert.throws(() => s.with({ slideImages: [[slide]] }), (e: Error) => e.message === 'invalidPatch');
  });

  it('a self row keeps a pending request, and asks for none', () => {
    let s = CaseState.initial({ uid: 'c', doctorUid: 'd', patientUid: 'pat' });
    s = transition(s, 'OrderCreated', { actorUid: 'd', actorRole: 'Doctor' });
    s = transition(s, 'PathologistRequested', { actorUid: 'd', actorRole: 'Doctor', requested });
    const shared = transition(s.with({ viewerUids: ['v'] }), 'PathologistRequested', {
      actorUid: 'd',
      actorRole: 'Doctor',
      action: 'Share',
    });
    assert.equal(shared.currentStage, 'PathologistRequested');
    assert.equal(shared.requestedPathologistUid, requested.uid);
    assert.equal(shared.pathologistRequestExpiresAt, requested.expiresAt);
    assert.ok(participants(shared).includes(requested.uid));
    assert.equal(shared.queuedLogs.at(-1)?.actionType, 'Share');
  });

  it('patient-visible logs never name a hidden stage', () => {
    let s = CaseState.from({
      id: 'c',
      data: () => ({
        uid: 'c',
        doctorUid: 'd',
        currentStage: 'PrereadFailed',
        currentLocation: 'Pathologist',
        currentStep: 'WriteReport',
        stageSeq: 3,
      }),
    });
    s = transition(s, 'PrereadFailed', {
      actorUid: 'd',
      actorRole: 'Doctor',
      action: 'Share',
    });
    const log = s.queuedLogs[0];
    assert.equal(log.patientVisible, true);
    assert.ok(PATIENT_VISIBLE_STAGES.has(log.fromStage));
    assert.ok(PATIENT_VISIBLE_STAGES.has(log.toStage));
    assert.equal(log.fromStage.includes('Preread'), false);
  });

  it('closeDiscussion after markDiscussed leaves a still-owned discussion alone when uid differs', () => {
    const s = CaseState.from({
      id: 'c',
      data: () => ({
        uid: 'c',
        doctorUid: 'd',
        currentStage: 'DiscussionBooked',
        currentLocation: 'Doctor',
        currentStep: 'MarkDiscussed',
        discussionAppointmentUid: 'appt-2',
        stageSeq: 5,
      }),
    });
    const after = closeDiscussion(s, 'appt-1', {
      actorUid: 'd',
      actorRole: 'Doctor',
      action: 'Cancel',
      reason: 'Other',
    });
    assert.equal(after.currentStage, 'DiscussionBooked');
    assert.equal(after.discussionAppointmentUid, 'appt-2');
    assert.equal(after.queuedLogs.length, 0);
  });

  it('closeDiscussion clears a live discussion', () => {
    let s = CaseState.from({
      id: 'c',
      data: () => ({
        uid: 'c',
        doctorUid: 'd',
        currentStage: 'DiscussionBooked',
        currentLocation: 'Doctor',
        currentStep: 'MarkDiscussed',
        discussionAppointmentUid: 'appt-1',
        stageSeq: 4,
      }),
    });
    s = closeDiscussion(s, 'appt-1', {
      actorUid: 'd',
      actorRole: 'Doctor',
      action: 'Expire',
    });
    assert.equal(s.currentStage, 'ReportSigned');
    assert.equal(s.discussionAppointmentUid, '');
  });

  it('allows AddSlides self-transition from SlidesUploaded', () => {
    assert.equal(allowedTransition('SlidesUploaded', 'SlidesUploaded', 'AddSlides'), true);
  });

  describe('exhaustive transition table', () => {
    const expected = new Set<string>();
    const mark = (from: CaseStage, to: CaseStage, action: CaseAction) => {
      expected.add(`${from}|${to}|${action}`);
    };
    // Seed from allowedTransition against itself would be circular; list the plan rows.
    mark('', 'OrderCreated', '');
    mark('OrderCreated', 'PathologistRequested', '');
    mark('PathologistRejected', 'PathologistRequested', '');
    mark('PathologistRequested', 'PathologistAccepted', '');
    mark('PathologistRequested', 'PathologistRejected', 'Reject');
    mark('PathologistRequested', 'PathologistRejected', 'Expire');
    for (const from of [
      'PathologistRequested',
      'PathologistAccepted',
      'SampleReceived',
      'SlidesUploaded',
      'PrereadQueued',
      'PrereadReady',
      'PrereadFailed',
    ] as CaseStage[]) {
      mark(from, 'PathologistRequested', 'Reassign');
    }
    mark('PathologistAccepted', 'SampleReceived', '');
    for (const from of ['SlidesUploaded', 'PrereadQueued', 'PrereadReady', 'PrereadFailed'] as CaseStage[]) {
      mark(from, from, 'Receive');
    }
    mark('PathologistAccepted', 'SlidesUploaded', '');
    mark('SampleReceived', 'SlidesUploaded', '');
    mark('PrereadReady', 'SlidesUploaded', 'AddSlides');
    mark('PrereadFailed', 'SlidesUploaded', 'AddSlides');
    mark('SlidesUploaded', 'SlidesUploaded', 'AddSlides');
    mark('PathologistAccepted', 'PrereadQueued', '');
    mark('SampleReceived', 'PrereadQueued', '');
    mark('SlidesUploaded', 'PrereadQueued', '');
    mark('PrereadQueued', 'PrereadReady', '');
    mark('PrereadQueued', 'PrereadFailed', '');
    for (const from of ['SampleReceived', 'SlidesUploaded', 'PrereadReady', 'PrereadFailed'] as CaseStage[]) {
      mark(from, 'ReportInProgress', '');
    }
    mark('ReportInProgress', 'ReportSigned', '');
    for (const from of ['ReportSigned', 'DiscussionRequested', 'DiscussionBooked'] as CaseStage[]) {
      mark(from, from, 'Revise');
    }
    mark('ResultReleased', 'ReportSigned', 'Revise');
    mark('Completed', 'ReportSigned', 'Revise');
    mark('ReportSigned', 'DiscussionRequested', '');
    mark('DiscussionRequested', 'DiscussionBooked', '');
    for (const action of ['Reject', 'Expire', 'Cancel'] as CaseAction[]) {
      mark('DiscussionRequested', 'ReportSigned', action);
      mark('DiscussionBooked', 'ReportSigned', action);
    }
    for (const from of ['ReportSigned', 'DiscussionRequested', 'DiscussionBooked'] as CaseStage[]) {
      mark(from, 'ResultReleased', '');
    }
    mark('ResultReleased', 'Completed', '');
    for (const from of [
      'OrderCreated',
      'PathologistRequested',
      'PathologistRejected',
      'PathologistAccepted',
      'SampleReceived',
      'SlidesUploaded',
      'PrereadQueued',
      'PrereadReady',
      'PrereadFailed',
      'ReportInProgress',
    ] as CaseStage[]) {
      mark(from, 'Cancelled', 'Cancel');
    }
    for (const from of TABLE_STAGES) {
      if (!from) continue;
      mark(from, from, 'Share');
      mark(from, from, 'RemoveViewer');
    }

    it('matches every pair against the expected set', () => {
      let checked = 0;
      for (const from of TABLE_STAGES) {
        for (const to of TABLE_STAGES) {
          for (const action of TABLE_ACTIONS) {
            const ok = allowedTransition(from, to, action);
            const key = `${from}|${to}|${action}`;
            assert.equal(ok, expected.has(key), `mismatch for ${key}: got ${ok}`);
            checked += 1;
          }
        }
      }
      assert.ok(checked > 1000);
    });
  });
});
