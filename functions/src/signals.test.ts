import assert from 'node:assert/strict';

import { nairobiDayKey } from './common';
import { emulatorDeps, resetEmulators } from './emulator.test-support';
import { bumpModelSignal } from './signals';

describe('signals', () => {
  beforeEach(async () => {
    await resetEmulators();
  });

  it('writes the allow-listed field on the Nairobi day doc', async () => {
    const deps = emulatorDeps();
    const now = deps.now!();
    await deps.db.runTransaction(async (tx) => {
      bumpModelSignal(tx, deps.db, 'prereadReadyCount', now, 2);
    });
    const day = nairobiDayKey(now);
    const data = (await deps.db.collection('modelSignals').doc(day).get()).data()!;
    assert.equal(data.day, day);
    assert.equal(data.prereadReadyCount, 2);
    assert.ok(data.lastUpdatedAt);
  });

  it('refuses an unknown field', async () => {
    const deps = emulatorDeps();
    await assert.rejects(
      deps.db.runTransaction(async (tx) => {
        bumpModelSignal(tx, deps.db, 'patientUid', deps.now!(), 1);
      }),
      (e: Error) => e.message === 'invalidSignalField',
    );
  });
});
