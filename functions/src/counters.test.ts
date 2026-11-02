import assert from 'node:assert/strict';

import { applyCounts, loadMarks } from './counters';
import { emulatorDeps, resetEmulators } from './emulator.test-support';

describe('counters', () => {
  beforeEach(async () => {
    await resetEmulators();
  });

  it('counts both v1 facts once; redelivery counts nothing', async () => {
    const deps = emulatorDeps();
    const pathologist = deps.db.collection('doctors').doc('path-1');
    const patient = deps.db.collection('patients').doc('pat-1');
    await pathologist.set({ uid: 'path-1', reportsSigned: 0 });
    await patient.set({ uid: 'pat-1', casesReported: 0 });

    const run = async () => {
      await deps.db.runTransaction(async (tx) => {
        const loaded = await loadMarks(tx, deps.db, [
          { counter: 'reportsSigned', resourceUid: 'case-1' },
          { counter: 'casesReported', resourceUid: 'case-1' },
        ]);
        applyCounts(
          tx,
          loaded,
          [
            {
              counter: 'reportsSigned',
              resourceUid: 'case-1',
              targetRef: pathologist,
              field: 'reportsSigned',
            },
            {
              counter: 'casesReported',
              resourceUid: 'case-1',
              targetRef: patient,
              field: 'casesReported',
            },
          ],
          deps.now!(),
        );
      });
    };

    await run();
    assert.equal((await pathologist.get()).data()?.reportsSigned, 1);
    assert.equal((await patient.get()).data()?.casesReported, 1);
    await run();
    assert.equal((await pathologist.get()).data()?.reportsSigned, 1);
    assert.equal((await patient.get()).data()?.casesReported, 1);
    const mark = await deps.db.collection('counterMarks').doc('reportsSigned:case-1').get();
    assert.ok(mark.data()?.expireAt);
    assert.ok(mark.data()?.lastUpdatedAt);
  });
});
