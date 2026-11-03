// cspell:ignore muse
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

import { AiError } from './ai';
import { BUCKET, resetEmulators } from './emulator.test-support';
import {
  encodePng,
  histologyDraft,
  histologyMeasurements,
  draftNumbersMatch,
  type Tile,
} from './preread-measure';
import {
  PREREAD_PROMPT_VERSION,
  assertPathsUnder,
  failureReasonOf,
  processQueuedPreread,
  type ClassifiedTile,
  type PrereadCache,
  type PrereadVision,
  type TileCrop,
} from './preread-worker';
import { saveObject } from './case-support';
import { seedWorld, type World } from './case.test-support';

function solidPng(width: number, height: number, rgb: [number, number, number]): Buffer {
  const data = Buffer.alloc(width * height * 3);
  for (let i = 0; i < width * height; i++) data.set(rgb, i * 3);
  return encodePng({ width, height, channels: 3, data });
}

function fakeVision(label = 'Normal'): PrereadVision {
  return {
    async classify(crops: TileCrop[]): Promise<ClassifiedTile[]> {
      return crops.map((c) => ({ id: c.id, label, probability: 0.91 }));
    },
  };
}

describe('preread-measure', () => {
  it('rule 2: draft numbers equal the measurement record', () => {
    const tiles: Tile[] = [
      {
        id: 'tile-0-0',
        imageUid: 'img',
        label: 'Tumour',
        probability: 0.9,
        row: 0,
        col: 0,
        source: 's',
      },
      {
        id: 'tile-0-1',
        imageUid: 'img',
        label: 'Normal',
        probability: 0.9,
        row: 0,
        col: 1,
        source: 's',
      },
    ];
    const measurements = histologyMeasurements(tiles, { rows: 1, cols: 2, tilePx: 96 }, 0.25);
    const draft = histologyDraft(tiles, measurements);
    assert.equal(draftNumbersMatch(draft, measurements, tiles.length), true);
    const forged = {
      ...draft,
      impression: 'Tumour spans 99 mm somehow.',
    };
    assert.equal(draftNumbersMatch(forged, measurements, tiles.length), false);
  });
});

describe('preread-worker helpers', () => {
  it('rule 1: storage paths must stay under preread/{case}/{run}/', () => {
    assert.doesNotThrow(() =>
      assertPathsUnder('c1', 'r1', ['preread/c1/r1/labels.json', 'preread/c1/r1/heatmap.png']),
    );
    assert.throws(() => assertPathsUnder('c1', 'r1', ['cases/c1/secret.json']));
  });

  it('rule 4: maps errors to Failed reasons', () => {
    assert.equal(failureReasonOf(new AiError('Timeout')), 'Timeout');
    assert.equal(failureReasonOf(new AiError('OffSchema')), 'OffSchema');
    assert.equal(failureReasonOf(new Error('boom')), 'ServiceError');
  });
});

describe('processQueuedPreread', () => {
  let w: World;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
  });

  async function queuedRun(opts?: {
    enabled?: boolean;
    vision?: PrereadVision;
    cache?: PrereadCache;
  }): Promise<{ caseUid: string; runUid: string }> {
    const caseUid = randomUUID();
    const runUid = randomUUID();
    const imagePath = `cases/${caseUid}/slides/slide-0.png`;
    // 192×96 → two 96px tiles.
    await saveObject(BUCKET, imagePath, solidPng(192, 96, [200, 180, 160]), 'image/png');
    await w.deps.db.collection('cases').doc(caseUid).set({
      uid: caseUid,
      currentStage: 'PrereadQueued',
      prereadRunUid: runUid,
      pathologistUid: w.pathologist.uid,
      participantUids: [w.pathologist.uid],
    });
    await w.deps.db
      .collection('cases')
      .doc(caseUid)
      .collection('preread')
      .doc(runUid)
      .set({
        uid: runUid,
        caseUid,
        profile: 'Cancer',
        status: 'Queued',
        imagePaths: [imagePath],
        micronsPerPixel: 0.25,
        segmentationPath: '',
        labelsPath: '',
        labelCounts: {},
        measurements: {},
        draft: {
          findings: [],
          impression: '',
          confidence: 0,
          confidenceBand: '',
          urgency: '',
          nextSteps: [],
        },
        models: {},
        inputLanguage: 'en',
        failureReason: '',
        requestedAt: '2026-11-03T00:00:00.000Z',
        startedAt: '',
        readyAt: '',
        lastUpdatedAt: '2026-11-03T00:00:00.000Z',
      });

    await processQueuedPreread(
      { ...w.deps, bucket: BUCKET, config: { enabled: () => opts?.enabled !== false } },
      caseUid,
      runUid,
      {
        enabled: opts?.enabled ?? true,
        vision: opts?.vision ?? fakeVision('Normal'),
        cache: opts?.cache,
      },
    );
    return { caseUid, runUid };
  }

  it('rule 6: preread_enabled off does no work', async () => {
    const { caseUid, runUid } = await queuedRun({ enabled: false });
    const run = (
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
    ).data();
    assert.equal(run?.status, 'Queued');
  });

  it('rule 2+8: Ready draft numbers match labels; models record prompt version', async () => {
    const { caseUid, runUid } = await queuedRun({ vision: fakeVision('Tumour') });
    const run = (
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
    ).data();
    assert.equal(run?.status, 'Ready');
    assert.equal(run?.models?.classify, 'muse-spark-1.3');
    assert.equal(run?.models?.promptVersion, PREREAD_PROMPT_VERSION);
    assert.ok(String(run?.labelsPath).startsWith(`preread/${caseUid}/${runUid}/`));
    assert.ok(String(run?.segmentationPath).startsWith(`preread/${caseUid}/${runUid}/`));
    assert.equal(
      draftNumbersMatch(run?.draft, run?.measurements as Record<string, number>, 2),
      true,
    );
  });

  it('rule 7: a label outside the allowed set becomes Unknown', async () => {
    const vision: PrereadVision = {
      async classify(crops) {
        return crops.map((c) => ({ id: c.id, label: 'Adenocarcinoma', probability: 0.99 }));
      },
    };
    const { caseUid, runUid } = await queuedRun({ vision });
    const run = (
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
    ).data();
    assert.equal(run?.status, 'Ready');
    assert.equal(run?.labelCounts?.Unknown, 2);
    assert.equal(run?.labelCounts?.Tumour, undefined);
  });

  it('rule 3: a second pass of the same image hits the cache (no second classify)', async () => {
    let calls = 0;
    const vision: PrereadVision = {
      async classify(crops) {
        calls += 1;
        return crops.map((c) => ({ id: c.id, label: 'Normal', probability: 0.9 }));
      },
    };
    const store = new Map<string, ClassifiedTile[]>();
    const cache: PrereadCache = {
      get: async (key) => store.get(key),
      set: async (key, labels) => {
        store.set(key, labels);
      },
    };
    const first = await queuedRun({ vision, cache });
    assert.equal(calls, 1);
    // Reset the run to Queued and process again with the same cache.
    await w.deps.db
      .collection('cases')
      .doc(first.caseUid)
      .collection('preread')
      .doc(first.runUid)
      .update({ status: 'Queued', startedAt: '', readyAt: '', failureReason: '' });
    await processQueuedPreread(
      { ...w.deps, bucket: BUCKET },
      first.caseUid,
      first.runUid,
      { enabled: true, vision, cache },
    );
    assert.equal(calls, 1, 'cache must prevent a second model call');
    const run = (
      await w.deps.db
        .collection('cases')
        .doc(first.caseUid)
        .collection('preread')
        .doc(first.runUid)
        .get()
    ).data();
    assert.equal(run?.status, 'Ready');
  });

  it('rule 4: a vision OffSchema failure records Failed, never Ready', async () => {
    const vision: PrereadVision = {
      async classify() {
        throw new AiError('OffSchema');
      },
    };
    const { caseUid, runUid } = await queuedRun({ vision });
    const run = (
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
    ).data();
    assert.equal(run?.status, 'Failed');
    assert.equal(run?.failureReason, 'OffSchema');
  });

  it('rule 5: vision errors do not put image bytes or keys in the message', async () => {
    const vision: PrereadVision = {
      async classify() {
        throw new AiError('ServiceError');
      },
    };
    const { caseUid, runUid } = await queuedRun({ vision });
    const run = (
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
    ).data();
    assert.equal(run?.failureReason, 'ServiceError');
    assert.ok(!JSON.stringify(run).includes('data:image'));
  });
});
