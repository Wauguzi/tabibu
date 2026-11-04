import assert from 'node:assert/strict';

import {
  combineHistologyMeasurements,
  combineMalariaMeasurements,
  histologyDraft,
  histologyMeasurements,
  type ImageGrid,
  type Tile,
} from './preread-measure';

function tile(id: number, label: string): Tile {
  return {
    id: `tile-${id}`,
    imageUid: 'img',
    label,
    probability: label === 'Unknown' ? 0 : 0.9,
    row: Math.floor(id / 10),
    col: id % 10,
    source: 's',
  };
}

function tilesOf(labels: string[]): Tile[] {
  return labels.map((label, i) => tile(i, label));
}

const GRID = { rows: 10, cols: 10, tilePx: 96 };

describe('preread-measure unknown tiles', () => {
  it('all-Normal stays "No tumour suspected" with Routine urgency', () => {
    const tiles = tilesOf(Array<string>(10).fill('Normal'));
    const m = histologyMeasurements(tiles, GRID, 0.25);
    assert.equal(m.unknownTiles, 0);
    assert.equal(m.normalTiles, 10);
    const draft = histologyDraft(tiles, m);
    assert.equal(draft.impression, 'No tumour suspected in the section.');
    assert.equal(draft.urgency, 'Routine');
  });

  it('20% Unknown does not clear the section', () => {
    const tiles = tilesOf([...Array<string>(8).fill('Normal'), 'Unknown', 'Unknown']);
    const m = histologyMeasurements(tiles, GRID, 0.25);
    assert.equal(m.unknownTiles, 2);
    assert.equal(m.normalTiles, 8);
    const draft = histologyDraft(tiles, m);
    assert.equal(draft.impression, 'The pre-read could not label enough of the section.');
    assert.equal(draft.urgency, 'Priority');
  });

  it('zero usable labels does not clear the section', () => {
    const tiles = tilesOf(Array<string>(4).fill('Unknown'));
    const m = histologyMeasurements(tiles, GRID, 0.25);
    assert.equal(m.unknownTiles, 4);
    assert.equal(m.normalTiles, 0);
    const draft = histologyDraft(tiles, m);
    assert.equal(draft.impression, 'The pre-read could not label enough of the section.');
    assert.equal(draft.urgency, 'Priority');
  });

  it('exactly 10% Unknown still clears the section', () => {
    const tiles = tilesOf([...Array<string>(9).fill('Normal'), 'Unknown']);
    const m = histologyMeasurements(tiles, GRID, 0.25);
    const draft = histologyDraft(tiles, m);
    assert.equal(draft.impression, 'No tumour suspected in the section.');
    assert.equal(draft.urgency, 'Routine');
  });

  it('a marked tumour still reads as suspected however much went unlabelled', () => {
    const tiles = tilesOf(['Tumour', 'Unknown', 'Unknown', 'Unknown']);
    const m = histologyMeasurements(tiles, GRID, 0.25);
    const draft = histologyDraft(tiles, m);
    assert.match(draft.impression, /^Tumour suspected in the section/);
    assert.notEqual(draft.urgency, 'Routine');
  });

  it('counts add up and no number moves without Unknown tiles', () => {
    const tiles = tilesOf(['Tumour', 'Normal', 'Normal', 'Unknown']);
    const m = histologyMeasurements(tiles, GRID, 0.25);
    assert.equal(m.tumourTiles, 1);
    assert.equal(m.normalTiles, 2);
    assert.equal(m.unknownTiles, 1);
    assert.equal(m.tumourTiles + m.normalTiles + m.unknownTiles, tiles.length);

    const clean = tilesOf(['Tumour', 'Normal', 'Normal']);
    const before = histologyMeasurements(clean, GRID, 0.25);
    assert.deepEqual(before, {
      tumourTiles: 1,
      normalTiles: 2,
      unknownTiles: 0,
      tumourAreaPercent: 33.33,
      largestFocusMm: 0.02,
    });
    const draft = histologyDraft(clean, before);
    assert.match(draft.impression, /^Tumour suspected in the section/);
  });
});

describe('preread-measure per-slide combine', () => {
  function grid(labels: string[], micronsPerPixel: number): ImageGrid {
    const cols = labels.length;
    return {
      tiles: labels.map((label, i) => tile(i, label)),
      rows: 1,
      cols,
      tilePx: 96,
      micronsPerPixel,
    };
  }

  it('counts add and the focus is the largest single-slide focus', () => {
    // Two adjacent tumour tiles on slide one, one lone tile on slide two.
    const m = combineHistologyMeasurements([
      grid(['Tumour', 'Tumour', 'Normal'], 0.25),
      grid(['Tumour', 'Normal'], 0.25),
    ]);
    assert.equal(m.tumourTiles, 3);
    assert.equal(m.normalTiles, 2);
    assert.equal(m.unknownTiles, 0);
    assert.equal(m.tumourAreaPercent, 60);
    // Slide one: two tiles at 0.25 mpp; never joined with slide two's tile.
    assert.equal(m.largestFocusMm, 0.05);
  });

  it('each slide keeps its own scale and the focus is the max, not the last', () => {
    const m = combineHistologyMeasurements([
      grid(['Tumour', 'Tumour', 'Tumour'], 0.25),
      grid(['Tumour'], 0.5),
    ]);
    assert.equal(m.tumourTiles, 4);
    // Three tiles at 0.25 mpp beats one tile at 0.5 mpp.
    assert.equal(m.largestFocusMm, 0.07);
  });

  it('a single slide combines to its own measurements', () => {
    const tiles = tilesOf(['Tumour', 'Normal', 'Normal']);
    const direct = histologyMeasurements(tiles, GRID, 0.25);
    const combined = combineHistologyMeasurements([
      { tiles, rows: 10, cols: 10, tilePx: 96, micronsPerPixel: 0.25 },
    ]);
    assert.deepEqual(combined, direct);
  });

  it('malaria cell counts add and the rate is recomputed', () => {
    const m = combineMalariaMeasurements([
      grid(['Parasitized', 'Parasitized', 'Uninfected'], 0.25),
      grid(['Parasitized', 'Uninfected', 'Uninfected', 'Uninfected'], 0.25),
    ]);
    assert.equal(m.cellsCounted, 7);
    assert.equal(m.parasitizedCells, 3);
    assert.equal(m.parasitaemiaPercent, 42.86);
  });
});
