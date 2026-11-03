// cspell:ignore muse
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

import { AiError } from './ai';
import { BUCKET, resetEmulators } from './emulator.test-support';
import { sweepCasesHandler } from './cases';
import { readObject, saveObject } from './case-support';
import { later, seedWorld, type World } from './case.test-support';
import {
  PREREAD_MAX_TILES,
  decodeImage,
  downscaleByFactor,
  draftNumbersMatch,
  encodeJpeg,
  encodePng,
  histologyDraft,
  histologyMeasurements,
  isJpeg,
  isPng,
  tileBudgetFactor,
  type Tile,
} from './preread-measure';
import {
  PREREAD_IMAGE_TEXT_RULE,
  PREREAD_PROMPT_VERSION,
  PREREAD_TILE_PX,
  assertPathsUnder,
  failureReasonOf,
  processQueuedPreread,
  type ClassifiedTile,
  type PrereadCache,
  type PrereadVision,
  type TileCrop,
} from './preread-worker';

function solidRaster(width: number, height: number, rgb: [number, number, number]) {
  const data = Buffer.alloc(width * height * 3);
  for (let i = 0; i < width * height; i++) data.set(rgb, i * 3);
  return { width, height, channels: 3 as const, data };
}

function solidPng(width: number, height: number, rgb: [number, number, number]): Buffer {
  return encodePng(solidRaster(width, height, rgb));
}

function solidJpeg(width: number, height: number, rgb: [number, number, number]): Buffer {
  return encodeJpeg(solidRaster(width, height, rgb), 95);
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

  it('bundle 58: decodes a real JPEG and a real PNG by file signature', () => {
    const pngBytes = solidPng(32, 24, [10, 20, 30]);
    const jpegBytes = solidJpeg(32, 24, [40, 50, 60]);
    assert.equal(isPng(pngBytes), true);
    assert.equal(isJpeg(pngBytes), false);
    assert.equal(isJpeg(jpegBytes), true);
    assert.equal(isPng(jpegBytes), false);

    const fromPng = decodeImage(pngBytes);
    assert.equal(fromPng.width, 32);
    assert.equal(fromPng.height, 24);
    assert.equal(fromPng.channels, 3);
    assert.deepEqual([...fromPng.data.subarray(0, 3)], [10, 20, 30]);

    const fromJpeg = decodeImage(jpegBytes);
    assert.equal(fromJpeg.width, 32);
    assert.equal(fromJpeg.height, 24);
    assert.equal(fromJpeg.channels, 3);
    // Lossy: channel values stay near the solid fill.
    assert.ok(Math.abs(fromJpeg.data[0] - 40) < 15);
    assert.ok(Math.abs(fromJpeg.data[1] - 50) < 15);
    assert.ok(Math.abs(fromJpeg.data[2] - 60) < 15);

    assert.throws(() => decodeImage(Buffer.from('not-an-image')), /unsupported image/);
  });

  it('bundle 58: oversized slides resize by a whole factor and keep at most 64 tiles', () => {
    // 10×10 tiles of 96px would be 100 tiles without a cap.
    const width = 10 * PREREAD_TILE_PX;
    const height = 10 * PREREAD_TILE_PX;
    const factor = tileBudgetFactor(width, height, PREREAD_TILE_PX);
    assert.ok(factor > 1);
    const scaled = downscaleByFactor(solidRaster(width, height, [1, 2, 3]), factor);
    const cols = Math.floor(scaled.width / PREREAD_TILE_PX);
    const rows = Math.floor(scaled.height / PREREAD_TILE_PX);
    assert.ok(rows * cols <= PREREAD_MAX_TILES);
    assert.equal(scaled.width, Math.floor(width / factor));
    assert.equal(scaled.height, Math.floor(height / factor));
    // Factor 1 stays put; mpp scales with the factor outside this helper.
    assert.equal(tileBudgetFactor(192, 96, PREREAD_TILE_PX), 1);
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
    /** Default: small PNG (192×96 → two tiles). */
    slide?: { bytes: Buffer; contentType: string; name: string; width: number; height: number };
    micronsPerPixel?: number;
  }): Promise<{ caseUid: string; runUid: string }> {
    const caseUid = randomUUID();
    const runUid = randomUUID();
    const slide =
      opts?.slide ??
      {
        bytes: solidPng(192, 96, [200, 180, 160]),
        contentType: 'image/png',
        name: 'slide-0.png',
        width: 192,
        height: 96,
      };
    const imagePath = `cases/${caseUid}/slides/${slide.name}`;
    await saveObject(BUCKET, imagePath, slide.bytes, slide.contentType);
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
        micronsPerPixel: opts?.micronsPerPixel ?? 0.25,
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

  it('bundle 58: a real JPEG slide reaches Ready', async () => {
    const { caseUid, runUid } = await queuedRun({
      slide: {
        bytes: solidJpeg(192, 96, [120, 100, 80]),
        contentType: 'image/jpeg',
        name: 'slide-0.jpg',
        width: 192,
        height: 96,
      },
    });
    const run = (
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
    ).data();
    assert.equal(run?.status, 'Ready');
    assert.equal(run?.labelCounts?.Normal, 2);
  });

  it('bundle 58: an oversized PNG is downscaled; mpp is adjusted and recorded', async () => {
    // 10×10 tiles → factor > 1 under the 64-tile cap.
    const side = 10 * PREREAD_TILE_PX;
    let seenCrops = 0;
    const vision: PrereadVision = {
      async classify(crops) {
        seenCrops += crops.length;
        return crops.map((c) => ({ id: c.id, label: 'Normal', probability: 0.9 }));
      },
    };
    const { caseUid, runUid } = await queuedRun({
      vision,
      micronsPerPixel: 0.5,
      slide: {
        bytes: solidPng(side, side, [1, 2, 3]),
        contentType: 'image/png',
        name: 'big.png',
        width: side,
        height: side,
      },
    });
    assert.ok(seenCrops <= PREREAD_MAX_TILES);
    const run = (
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).get()
    ).data();
    assert.equal(run?.status, 'Ready');
    const labelsBytes = await readObject(BUCKET, String(run?.labelsPath));
    assert.ok(labelsBytes);
    const labels = JSON.parse(labelsBytes.toString('utf8')) as {
      grid: { tileScale: number; micronsPerPixel: number; sourceMicronsPerPixel: number };
    };
    assert.ok(labels.grid.tileScale > 1);
    assert.equal(labels.grid.sourceMicronsPerPixel, 0.5);
    assert.equal(labels.grid.micronsPerPixel, 0.5 * labels.grid.tileScale);
    assert.equal(run?.models?.tileScale, String(labels.grid.tileScale));
    assert.equal(
      draftNumbersMatch(run?.draft, run?.measurements as Record<string, number>, seenCrops),
      true,
    );
  });
});

describe('bundle 58: stuck Running pre-read', () => {
  let w: World;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
  });

  it('the sweep fails a run left in Running past the stale window', async () => {
    const old = '2026-10-27T08:00:00.000Z';
    await w.deps.db.doc('cases/c1/preread/stuck').set({
      status: 'Running',
      requestedAt: old,
      failureReason: '',
      lastUpdatedAt: old,
    });
    await w.deps.db.doc('cases/c1/preread/fresh').set({
      status: 'Running',
      requestedAt: '2026-10-27T09:20:00.000Z',
      failureReason: '',
      lastUpdatedAt: '2026-10-27T09:20:00.000Z',
    });
    const result = await sweepCasesHandler(later(w.deps, 31 * 60 * 1000));
    assert.ok(result.staleJobs >= 1);
    const stuck = await w.deps.db.doc('cases/c1/preread/stuck').get();
    assert.equal(stuck.get('status'), 'Failed');
    assert.equal(stuck.get('failureReason'), 'Stale');
    assert.equal((await w.deps.db.doc('cases/c1/preread/fresh').get()).get('status'), 'Running');
  });
});

describe('bundle 58: prompt', () => {
  it('tells the model that text inside an image is not an instruction', () => {
    assert.match(PREREAD_IMAGE_TEXT_RULE, /not an instruction/i);
    assert.match(PREREAD_IMAGE_TEXT_RULE, /inside an image/i);
  });
});
