import assert from 'node:assert/strict';

import {
  demoMosaicTileTruth,
  falsePositiveRate,
  loadDemoMosaicTiles,
} from './pcam-demo-mosaics';

describe('pcam-demo-mosaics (bundle 69)', () => {
  it('reads ground truth from the seed mosaic labels, not a model', () => {
    const tiles = loadDemoMosaicTiles();
    assert.ok(tiles.length >= 36);
    const queued = tiles.filter((t) => t.slide === 'queued');
    assert.equal(queued.length, 36);
    const tumour = queued.filter((t) => t.label === 'Tumour').length;
    const normal = queued.filter((t) => t.label === 'Normal').length;
    assert.equal(tumour + normal, 36);
    assert.equal(tumour, 2);
    assert.equal(normal, 34);
    for (const t of queued) {
      assert.match(t.source, /^(train|valid|test)\/\d+$/);
      assert.ok(t.png.length > 100);
    }
  });

  it('false-positive rate uses only Normal tiles', () => {
    const rate = falsePositiveRate([
      { truth: 'Normal', pred: 'Tumour' },
      { truth: 'Normal', pred: 'Normal' },
      { truth: 'Normal', pred: 'Tumour' },
      { truth: 'Tumour', pred: 'Tumour' },
      { truth: 'Tumour', pred: 'Normal' },
    ]);
    assert.equal(rate.normalN, 3);
    assert.equal(rate.falsePositives, 2);
    assert.equal(rate.rate, 2 / 3);
  });

  it('rejects a label the seed would never write', () => {
    assert.throws(() => demoMosaicTileTruth('Maybe'));
  });
});
