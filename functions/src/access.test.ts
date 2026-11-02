import assert from 'node:assert/strict';

import { participants, readersFor, syncCaseReaders, unlockReport } from './access';
import { emulatorDeps, resetEmulators } from './emulator.test-support';
import { CaseState } from './orchestrator';

describe('access', () => {
  beforeEach(async () => {
    await resetEmulators();
  });

  it('participants dedupe and drop empties', () => {
    const s = CaseState.from({
      id: 'c',
      data: () => ({
        doctorUid: 'd',
        patientUid: 'p',
        requestedPathologistUid: 'r',
        pathologistUid: 'r',
        viewerUids: ['v', 'r', ''],
      }),
    });
    assert.deepEqual(participants(s), ['d', 'p', 'r', 'v']);
  });

  it('removing a viewer who is also the pathologist keeps them in participants and readers', async () => {
    const deps = emulatorDeps();
    const before = CaseState.from({
      id: 'c',
      data: () => ({
        doctorUid: 'd',
        patientUid: 'p',
        pathologistUid: 'path',
        viewerUids: ['path', 'v-gone'],
      }),
    });
    assert.ok(participants(before).includes('path'));
    assert.ok(participants(before).includes('v-gone'));

    const after = CaseState.from({
      id: 'c',
      data: () => ({
        doctorUid: 'd',
        patientUid: 'p',
        pathologistUid: 'path',
        viewerUids: [],
      }),
    });
    assert.ok(participants(after).includes('path'));
    assert.equal(participants(after).includes('v-gone'), false);

    const reportRef = deps.db.collection('cases').doc('c').collection('reports').doc('v1');
    await reportRef.set({
      uid: 'v1',
      pathologistUid: 'path',
      readerUids: ['path', 'd', 'p', 'v-gone'],
      releasedToPatient: true,
      doctorOpenedAt: 't',
    });
    const version = {
      uid: 'v1',
      pathologistUid: 'path',
      readerUids: ['path', 'd', 'p', 'v-gone'],
      releasedToPatient: true,
      doctorOpenedAt: 't',
      ref: reportRef,
    };
    assert.ok(readersFor(after, version).includes('path'));
    assert.equal(readersFor(after, version).includes('v-gone'), false);
    await deps.db.runTransaction(async (tx) => {
      syncCaseReaders(tx, after, [version], deps.now!());
    });
    const stored = (await reportRef.get()).data()!;
    assert.ok(stored.readerUids.includes('path'));
    assert.equal(stored.readerUids.includes('v-gone'), false);
  });

  it('unlockReport adds only the case doctor and stamps doctorOpenedAt', async () => {
    const deps = emulatorDeps();
    const s = CaseState.from({
      id: 'c',
      data: () => ({ doctorUid: 'd', pathologistUid: 'path' }),
    });
    const reportRef = deps.db.collection('cases').doc('c').collection('reports').doc('v1');
    await reportRef.set({
      uid: 'v1',
      pathologistUid: 'path',
      readerUids: ['path'],
      releasedToPatient: false,
      doctorOpenedAt: '',
    });
    await deps.db.runTransaction(async (tx) => {
      unlockReport(
        tx,
        s,
        [
          {
            uid: 'v1',
            pathologistUid: 'path',
            readerUids: ['path'],
            releasedToPatient: false,
            doctorOpenedAt: '',
            ref: reportRef,
          },
        ],
        'd',
        deps.now!(),
      );
    });
    const after = (await reportRef.get()).data()!;
    assert.ok(after.readerUids.includes('d'));
    assert.ok(after.readerUids.includes('path'));
    assert.ok(after.doctorOpenedAt);
  });
});
