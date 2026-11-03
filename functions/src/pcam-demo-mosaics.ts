/**
 * Demo-mosaic false-positive check helpers (bundle 69). Ground truth comes only from the
 * seed's `slides.json` labels — never from a model.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { cropTilePng, decodeImage, type Raster } from './preread-measure';
import { SLIDES_DIR, loadManifest, type SlideSpec } from './seed-cases-media';

export interface DemoMosaicTile {
  id: string;
  slide: string;
  row: number;
  col: number;
  /** Seed label from slides.json — the only ground truth for this check. */
  label: 'Tumour' | 'Normal';
  source: string;
  png: Buffer;
}

export function demoMosaicTileTruth(label: string): 'Tumour' | 'Normal' {
  if (label === 'Tumour' || label === 'Normal') return label;
  throw new Error(`seed mosaic label must be Tumour or Normal, got ${label}`);
}

/** Every tile of every histology mosaic in the seed, cropped from the committed JPEG. */
export function loadDemoMosaicTiles(root = SLIDES_DIR): DemoMosaicTile[] {
  const manifest = loadManifest();
  const out: DemoMosaicTile[] = [];
  for (const [name, slide] of Object.entries(manifest.histology.slides) as [string, SlideSpec][]) {
    const bytes = readFileSync(join(root, slide.file));
    const raster: Raster = decodeImage(bytes);
    for (const tile of slide.tiles) {
      out.push({
        id: `${name}-r${tile.row}c${tile.col}`,
        slide: name,
        row: tile.row,
        col: tile.col,
        label: demoMosaicTileTruth(tile.label),
        source: tile.source,
        png: cropTilePng(raster, tile.row, tile.col, slide.tilePx),
      });
    }
  }
  return out;
}

export function falsePositiveRate(
  rows: { truth: 'Tumour' | 'Normal'; pred: 'Tumour' | 'Normal' }[],
): { normalN: number; falsePositives: number; rate: number } {
  let normalN = 0;
  let falsePositives = 0;
  for (const r of rows) {
    if (r.truth !== 'Normal') continue;
    normalN += 1;
    if (r.pred === 'Tumour') falsePositives += 1;
  }
  return {
    normalN,
    falsePositives,
    rate: normalN === 0 ? 0 : falsePositives / normalN,
  };
}
