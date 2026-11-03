/**
 * Pictures and numbers for the demo cases (`seed-cases.ts`). The histology slides are committed
 * mosaics of CC0 PatchCamelyon patches; the malaria field is composed from single-cell crops
 * fetched when the seed runs, because their data set page states no licence. Measurement,
 * drafts and the heatmap live in `preread-measure.ts` so the live worker reuses them (S-6).
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { crc32, inflateRawSync } from 'node:zlib';

import {
  blank,
  decodePng,
  encodePng,
  unitInterval,
  type Raster,
  type Tile,
} from './preread-measure';

export type {
  GridSpec,
  PrereadDraft,
  Raster,
  Tile,
  Urgency,
} from './preread-measure';
export {
  confidenceOf,
  cropTilePng,
  decodePng,
  draftNumbersMatch,
  encodePng,
  heatmapPng,
  histologyDraft,
  histologyMeasurements,
  malariaDraft,
  malariaMeasurements,
  sha256Hex,
} from './preread-measure';

export interface SlideSpec {
  file: string;
  rows: number;
  cols: number;
  tilePx: number;
  tiles: { row: number; col: number; label: string; source: string }[];
}

export interface CellSpec {
  row: number;
  col: number;
  label: string;
  entry: string;
  offset: number;
  compressedSize: number;
  size: number;
  method: number;
  crc32: number;
}

export interface MalariaSpec {
  rows: number;
  cols: number;
  cellPx: number;
  micronsPerPixel: number;
  source: { archive: string };
  cells: CellSpec[];
}

export interface Manifest {
  histology: { source: { micronsPerPixel: number }; slides: Record<string, SlideSpec> };
  malaria: MalariaSpec;
}

export const SLIDES_DIR = join(__dirname, '..', 'data', 'demo_slides');

export function loadManifest(): Manifest {
  return JSON.parse(readFileSync(join(SLIDES_DIR, 'slides.json'), 'utf8')) as Manifest;
}

export function slideBytes(spec: SlideSpec): Buffer {
  return readFileSync(join(SLIDES_DIR, spec.file));
}

export const PROVENANCE = 'Stored demo example, not a live model run';

export type Certainty = 'clear' | 'uncertain';

/** Each tile's probability is that of its own label; `uncertain` keeps it near a coin toss. */
export function histologyTiles(
  slide: SlideSpec,
  imageUid: string,
  seed: string,
  certainty: Certainty,
): Tile[] {
  const [low, high] = certainty === 'clear' ? [0.88, 0.99] : [0.52, 0.74];
  return slide.tiles.map((t) => {
    const id = `tile-${t.row}-${t.col}`;
    return {
      id,
      imageUid,
      label: t.label,
      probability: Math.round((low + (high - low) * unitInterval(`${seed}:${id}`)) * 1000) / 1000,
      row: t.row,
      col: t.col,
      source: t.source,
    };
  });
}

export function malariaTiles(spec: MalariaSpec, imageUid: string, seed: string): Tile[] {
  return spec.cells.map((c) => {
    const id = `cell-${c.row}-${c.col}`;
    return {
      id,
      imageUid,
      label: c.label,
      probability: Math.round((0.9 + 0.09 * unitInterval(`${seed}:${id}`)) * 1000) / 1000,
      row: c.row,
      col: c.col,
      source: c.entry,
    };
  });
}

/** `src` scaled to fit a square of `size` pixels, centred on black. */
function fitSquare(src: Raster, size: number): Raster {
  const out = blank(size, size, 3);
  const scale = Math.min(size / src.width, size / src.height);
  const w = Math.max(1, Math.round(src.width * scale));
  const h = Math.max(1, Math.round(src.height * scale));
  const left = Math.floor((size - w) / 2);
  const top = Math.floor((size - h) / 2);
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const fx = Math.min(src.width - 1, ((x + 0.5) / w) * src.width - 0.5);
      const fy = Math.min(src.height - 1, ((y + 0.5) / h) * src.height - 0.5);
      const x0 = Math.max(0, Math.floor(fx));
      const y0 = Math.max(0, Math.floor(fy));
      const x1 = Math.min(src.width - 1, x0 + 1);
      const y1 = Math.min(src.height - 1, y0 + 1);
      const wx = fx - x0;
      const wy = fy - y0;
      for (let ch = 0; ch < 3; ch++) {
        const at = (px: number, py: number): number => src.data[(py * src.width + px) * 3 + ch];
        const top2 = at(x0, y0) * (1 - wx) + at(x1, y0) * wx;
        const bottom = at(x0, y1) * (1 - wx) + at(x1, y1) * wx;
        out.data[((top + y) * size + left + x) * 3 + ch] = Math.round(top2 * (1 - wy) + bottom * wy);
      }
    }
  }
  return out;
}

export function composeCells(spec: MalariaSpec, cells: Raster[]): Buffer {
  const { cellPx } = spec;
  const field = blank(spec.cols * cellPx, spec.rows * cellPx, 3);
  spec.cells.forEach((cell, i) => {
    const tile = fitSquare(cells[i], cellPx);
    for (let y = 0; y < cellPx; y++) {
      tile.data.copy(
        field.data,
        ((cell.row * cellPx + y) * field.width + cell.col * cellPx) * 3,
        y * cellPx * 3,
        (y + 1) * cellPx * 3,
      );
    }
  });
  return encodePng(field);
}

/** A drawn signature on a transparent 400 x 100 canvas: what `signReport` stores beside the report. */
export function signaturePng(): Buffer {
  const sig = blank(400, 100, 4);
  const stamp = (cx: number, cy: number): void => {
    for (let y = -2; y <= 2; y++) {
      for (let x = -2; x <= 2; x++) {
        if (x * x + y * y > 5) continue;
        const px = Math.round(cx) + x;
        const py = Math.round(cy) + y;
        if (px >= 0 && px < 400 && py >= 0 && py < 100) sig.data.set([22, 40, 110, 255], (py * 400 + px) * 4);
      }
    }
  };
  for (let x = 24; x < 370; x += 0.5) {
    stamp(x, 52 + 24 * Math.sin(x / 17) * Math.cos(x / 53) - 8 * Math.sin(x / 5.5));
    if (x < 300) stamp(x, 84 - (x - 24) * 0.03);
  }
  return encodePng(sig);
}

// --- The malaria field, fetched when the seed runs --------------------------------------------

const ARCHIVE_HOST = 'data.lhncbc.nlm.nih.gov';

/** One archive entry by byte range, checked against the CRC the manifest recorded. */
async function fetchCell(archive: string, cell: CellSpec): Promise<Raster> {
  const url = new URL(archive);
  if (url.protocol !== 'https:' || url.hostname !== ARCHIVE_HOST) throw new Error('unexpected archive host');
  const span = 30 + cell.entry.length + 1024 + cell.compressedSize;
  const res = await fetch(url, { headers: { Range: `bytes=${cell.offset}-${cell.offset + span - 1}` } });
  if (res.status !== 206) throw new Error(`cell fetch failed (${res.status})`);
  const bytes = Buffer.from(await res.arrayBuffer());
  if (bytes.readUInt32LE(0) !== 0x04034b50) throw new Error('cell entry header');
  const start = 30 + bytes.readUInt16LE(26) + bytes.readUInt16LE(28);
  const packed = bytes.subarray(start, start + cell.compressedSize);
  const png = cell.method === 8 ? inflateRawSync(packed, { maxOutputLength: cell.size }) : packed;
  if (png.length !== cell.size || crc32(png) !== cell.crc32) throw new Error('cell changed upstream');
  return decodePng(png);
}

export async function fetchCells(spec: MalariaSpec): Promise<Raster[]> {
  const out: Raster[] = [];
  for (const cell of spec.cells) out.push(await fetchCell(spec.source.archive, cell));
  return out;
}
