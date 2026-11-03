/**
 * Pictures and numbers for the demo cases (`seed-cases.ts`). The histology slides are committed
 * mosaics of CC0 PatchCamelyon patches; the malaria field is composed from single-cell crops
 * fetched when the seed runs, because their data set page states no licence. Every number a
 * pre-read reports is computed here from the tile labels, never typed (S-6).
 */
import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { crc32, deflateSync, inflateRawSync, inflateSync } from 'node:zlib';

export interface Tile {
  id: string;
  imageUid: string;
  label: string;
  probability: number;
  row: number;
  col: number;
  source: string;
}

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

const round2 = (x: number): number => Math.round(x * 100) / 100;

// --- Labels and the numbers computed from them -----------------------------------------------

/** A repeatable unit-interval value for `key`, so a re-run writes the same probabilities. */
function unit(key: string): number {
  return createHash('sha256').update(key).digest().readUInt32BE(0) / 2 ** 32;
}

export type Certainty = 'clear' | 'uncertain';

/** Each tile's probability is that of its own label; `uncertain` keeps it near a coin toss. */
export function histologyTiles(slide: SlideSpec, imageUid: string, seed: string, certainty: Certainty): Tile[] {
  const [low, high] = certainty === 'clear' ? [0.88, 0.99] : [0.52, 0.74];
  return slide.tiles.map((t) => {
    const id = `tile-${t.row}-${t.col}`;
    return {
      id,
      imageUid,
      label: t.label,
      probability: Math.round((low + (high - low) * unit(`${seed}:${id}`)) * 1000) / 1000,
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
      probability: Math.round((0.9 + 0.09 * unit(`${seed}:${id}`)) * 1000) / 1000,
      row: c.row,
      col: c.col,
      source: c.entry,
    };
  });
}

/** Longest side, in tiles, of the largest 4-connected group of `Tumour` tiles; 0 when there are none. */
function largestFocusTiles(tiles: Tile[], rows: number, cols: number): number {
  const grid = Array.from({ length: rows }, () => Array<boolean>(cols).fill(false));
  for (const t of tiles) if (t.label === 'Tumour') grid[t.row][t.col] = true;
  const seen = grid.map((r) => r.map(() => false));
  let best = { size: 0, extent: 0 };
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (!grid[r][c] || seen[r][c]) continue;
      const stack: [number, number][] = [[r, c]];
      seen[r][c] = true;
      let size = 0;
      const box = { r0: r, r1: r, c0: c, c1: c };
      while (stack.length > 0) {
        const [y, x] = stack.pop() as [number, number];
        size += 1;
        box.r0 = Math.min(box.r0, y);
        box.r1 = Math.max(box.r1, y);
        box.c0 = Math.min(box.c0, x);
        box.c1 = Math.max(box.c1, x);
        for (const [dy, dx] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          const ny = y + dy;
          const nx = x + dx;
          if (ny >= 0 && ny < rows && nx >= 0 && nx < cols && grid[ny][nx] && !seen[ny][nx]) {
            seen[ny][nx] = true;
            stack.push([ny, nx]);
          }
        }
      }
      const extent = Math.max(box.r1 - box.r0 + 1, box.c1 - box.c0 + 1);
      if (size > best.size) best = { size, extent };
    }
  }
  return best.extent;
}

export function histologyMeasurements(
  tiles: Tile[],
  slide: Pick<SlideSpec, 'rows' | 'cols' | 'tilePx'>,
  micronsPerPixel: number,
): Record<string, number> {
  const tumour = tiles.filter((t) => t.label === 'Tumour').length;
  return {
    tumourTiles: tumour,
    normalTiles: tiles.length - tumour,
    tumourAreaPercent: round2((100 * tumour) / tiles.length),
    largestFocusMm: round2((largestFocusTiles(tiles, slide.rows, slide.cols) * slide.tilePx * micronsPerPixel) / 1000),
  };
}

export function malariaMeasurements(tiles: Tile[]): Record<string, number> {
  const parasitised = tiles.filter((t) => t.label === 'Parasitized').length;
  return {
    cellsCounted: tiles.length,
    parasitizedCells: parasitised,
    parasitaemiaPercent: round2((100 * parasitised) / tiles.length),
  };
}

export function confidenceOf(tiles: Tile[]): { confidence: number; confidenceBand: 'High' | 'Moderate' | 'Low' } {
  const confidence = round2(tiles.reduce((sum, t) => sum + t.probability, 0) / tiles.length);
  return { confidence, confidenceBand: confidence >= 0.85 ? 'High' : confidence >= 0.7 ? 'Moderate' : 'Low' };
}

type Urgency = 'Routine' | 'Priority' | 'Urgent';

export interface PrereadDraft {
  findings: { text: string; evidenceIds: string[] }[];
  impression: string;
  confidence: number;
  confidenceBand: string;
  urgency: Urgency;
  nextSteps: string[];
}

/** Lymph node staging classes by size of the largest focus (0.2 mm and 2 mm). */
function focusClass(mm: number): string {
  if (mm > 2) return 'macro-metastasis';
  if (mm > 0.2) return 'micro-metastasis';
  return 'isolated tumour cells';
}

export function histologyDraft(tiles: Tile[], m: Record<string, number>): PrereadDraft {
  const evidence = tiles.filter((t) => t.label === 'Tumour').map((t) => t.id);
  const { confidence, confidenceBand } = confidenceOf(tiles);
  const any = m.tumourTiles > 0;
  return {
    findings: any
      ? [
          {
            text: `${m.tumourTiles} of ${tiles.length} tiles (${m.tumourAreaPercent}%) are marked as tumour.`,
            evidenceIds: evidence,
          },
          { text: `The largest focus spans about ${m.largestFocusMm} mm.`, evidenceIds: evidence },
        ]
      : [{ text: 'No tile is marked as tumour.', evidenceIds: [] }],
    impression: any
      ? `Tumour suspected in the section, in the size range of ${focusClass(m.largestFocusMm)}.`
      : 'No tumour suspected in the section.',
    confidence,
    confidenceBand,
    urgency: m.largestFocusMm > 0.2 ? 'Urgent' : any ? 'Priority' : 'Routine',
    nextSteps: ['Review the marked tiles at full size.', 'Correlate with the clinical notes before reporting.'],
  };
}

export function malariaDraft(tiles: Tile[], m: Record<string, number>): PrereadDraft {
  const evidence = tiles.filter((t) => t.label === 'Parasitized').map((t) => t.id);
  const { confidence, confidenceBand } = confidenceOf(tiles);
  return {
    findings: [
      {
        text: `${m.parasitizedCells} of ${m.cellsCounted} cells (${m.parasitaemiaPercent}%) are marked as parasitised.`,
        evidenceIds: evidence,
      },
    ],
    impression: `Malaria parasites suspected on the thin smear, with parasitaemia of ${m.parasitaemiaPercent}%.`,
    confidence,
    confidenceBand,
    urgency: m.parasitaemiaPercent >= 10 ? 'Urgent' : m.parasitaemiaPercent >= 2 ? 'Priority' : 'Routine',
    nextSteps: ['Confirm the species on the smear.', 'Record the parasite density in the report.'],
  };
}

// --- PNG, enough for 8-bit RGB crops in and RGB or RGBA out ---------------------------------

export interface Raster {
  width: number;
  height: number;
  channels: 3 | 4;
  data: Buffer;
}

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const MAX_SIDE = 1024;

export function decodePng(bytes: Buffer): Raster {
  if (bytes.length < 33 || !bytes.subarray(0, 8).equals(PNG_SIGNATURE)) throw new Error('not a PNG');
  let width = 0;
  let height = 0;
  const parts: Buffer[] = [];
  for (let at = 8; at + 8 <= bytes.length; ) {
    const length = bytes.readUInt32BE(at);
    const type = bytes.toString('latin1', at + 4, at + 8);
    const body = bytes.subarray(at + 8, at + 8 + length);
    if (body.length !== length) throw new Error('truncated PNG');
    if (type === 'IHDR') {
      width = body.readUInt32BE(0);
      height = body.readUInt32BE(4);
      if (body[8] !== 8 || body[9] !== 2 || body[12] !== 0) throw new Error('unsupported PNG');
    } else if (type === 'IDAT') {
      parts.push(body);
    } else if (type === 'IEND') {
      break;
    }
    at += 12 + length;
  }
  if (width < 1 || height < 1 || width > MAX_SIDE || height > MAX_SIDE) throw new Error('PNG size out of range');
  const raw = inflateSync(Buffer.concat(parts), { maxOutputLength: (width * 3 + 1) * height });
  const stride = width * 3;
  if (raw.length !== (stride + 1) * height) throw new Error('PNG data length');
  const data = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y++) {
    const filter = raw[y * (stride + 1)];
    for (let x = 0; x < stride; x++) {
      const v = raw[y * (stride + 1) + 1 + x];
      const a = x >= 3 ? data[y * stride + x - 3] : 0;
      const b = y > 0 ? data[(y - 1) * stride + x] : 0;
      const c = x >= 3 && y > 0 ? data[(y - 1) * stride + x - 3] : 0;
      let add: number;
      switch (filter) {
        case 0:
          add = 0;
          break;
        case 1:
          add = a;
          break;
        case 2:
          add = b;
          break;
        case 3:
          add = (a + b) >> 1;
          break;
        case 4: {
          const p = a + b - c;
          const pa = Math.abs(p - a);
          const pb = Math.abs(p - b);
          const pc = Math.abs(p - c);
          add = pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
          break;
        }
        default:
          throw new Error('PNG filter');
      }
      data[y * stride + x] = (v + add) & 0xff;
    }
  }
  return { width, height, channels: 3, data };
}

function chunk(type: string, body: Buffer): Buffer {
  const head = Buffer.alloc(8);
  head.writeUInt32BE(body.length, 0);
  head.write(type, 4, 'latin1');
  const tail = Buffer.alloc(4);
  tail.writeUInt32BE(crc32(Buffer.concat([head.subarray(4), body])), 0);
  return Buffer.concat([head, body, tail]);
}

export function encodePng(r: Raster): Buffer {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(r.width, 0);
  header.writeUInt32BE(r.height, 4);
  header[8] = 8;
  header[9] = r.channels === 4 ? 6 : 2;
  const stride = r.width * r.channels;
  const raw = Buffer.alloc((stride + 1) * r.height);
  for (let y = 0; y < r.height; y++) r.data.copy(raw, y * (stride + 1) + 1, y * stride, (y + 1) * stride);
  return Buffer.concat([PNG_SIGNATURE, chunk('IHDR', header), chunk('IDAT', deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

function blank(width: number, height: number, channels: 3 | 4): Raster {
  return { width, height, channels, data: Buffer.alloc(width * height * channels) };
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

/** A translucent red wash over every tile whose label is `positive`, stronger where the model is surer. */
export function heatmapPng(tiles: Tile[], width: number, height: number, tilePx: number, positive: string): Buffer {
  const map = blank(width, height, 4);
  for (const t of tiles) {
    if (t.label !== positive) continue;
    const alpha = Math.round(70 + 130 * t.probability);
    for (let y = t.row * tilePx; y < (t.row + 1) * tilePx; y++) {
      for (let x = t.col * tilePx; x < (t.col + 1) * tilePx; x++) {
        map.data.set([220, 38, 38, alpha], (y * width + x) * 4);
      }
    }
  }
  return encodePng(map);
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
