/**
 * Pre-read numbers and the heatmap: computed in code from tile labels (S-6). Shared by the
 * live worker and the demo seed so both never invent a count the labels do not support.
 */
import { createHash } from 'node:crypto';
import { crc32, deflateSync, inflateSync } from 'node:zlib';

export interface Tile {
  id: string;
  imageUid: string;
  label: string;
  probability: number;
  row: number;
  col: number;
  source: string;
}

export interface GridSpec {
  rows: number;
  cols: number;
  tilePx: number;
}

export type Urgency = 'Routine' | 'Priority' | 'Urgent';

export interface PrereadDraft {
  findings: { text: string; evidenceIds: string[] }[];
  impression: string;
  confidence: number;
  confidenceBand: string;
  urgency: Urgency;
  nextSteps: string[];
}

export interface Raster {
  width: number;
  height: number;
  channels: 3 | 4;
  data: Buffer;
}

const round2 = (x: number): number => Math.round(x * 100) / 100;

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
        for (const [dy, dx] of [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
        ]) {
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
  slide: GridSpec,
  micronsPerPixel: number,
): Record<string, number> {
  const tumour = tiles.filter((t) => t.label === 'Tumour').length;
  return {
    tumourTiles: tumour,
    normalTiles: tiles.length - tumour,
    tumourAreaPercent: round2((100 * tumour) / Math.max(1, tiles.length)),
    largestFocusMm: round2(
      (largestFocusTiles(tiles, slide.rows, slide.cols) * slide.tilePx * micronsPerPixel) / 1000,
    ),
  };
}

export function malariaMeasurements(tiles: Tile[]): Record<string, number> {
  const parasitised = tiles.filter((t) => t.label === 'Parasitized').length;
  return {
    cellsCounted: tiles.length,
    parasitizedCells: parasitised,
    parasitaemiaPercent: round2((100 * parasitised) / Math.max(1, tiles.length)),
  };
}

export function confidenceOf(
  tiles: Tile[],
): { confidence: number; confidenceBand: 'High' | 'Moderate' | 'Low' } {
  if (tiles.length === 0) return { confidence: 0, confidenceBand: 'Low' };
  const confidence = round2(tiles.reduce((sum, t) => sum + t.probability, 0) / tiles.length);
  return {
    confidence,
    confidenceBand: confidence >= 0.85 ? 'High' : confidence >= 0.7 ? 'Moderate' : 'Low',
  };
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

/**
 * Every number written into the draft must equal a measurement (or the tile count). A draft that
 * invents a figure is rejected before Ready (S-6 / rule 2).
 */
export function draftNumbersMatch(
  draft: PrereadDraft,
  measurements: Record<string, number>,
  tileCount: number,
): boolean {
  const allowed = new Set<string>([String(tileCount)]);
  for (const value of Object.values(measurements)) {
    allowed.add(String(value));
    allowed.add(String(round2(value)));
  }
  const text = [
    draft.impression,
    ...draft.findings.map((f) => f.text),
    ...draft.nextSteps,
  ].join('\n');
  const nums = text.match(/\d+(?:\.\d+)?/g) ?? [];
  return nums.every((n) => allowed.has(n));
}

// --- PNG (8-bit RGB in, RGB or RGBA out) ------------------------------------------------------

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const MAX_SIDE = 4096;

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
  return Buffer.concat([
    PNG_SIGNATURE,
    chunk('IHDR', header),
    chunk('IDAT', deflateSync(raw)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function blank(width: number, height: number, channels: 3 | 4): Raster {
  return { width, height, channels, data: Buffer.alloc(width * height * channels) };
}

/** A translucent red wash over every tile whose label is `positive`, stronger where the model is surer. */
export function heatmapPng(
  tiles: Tile[],
  width: number,
  height: number,
  tilePx: number,
  positive: string,
): Buffer {
  const map = blank(width, height, 4);
  for (const t of tiles) {
    if (t.label !== positive) continue;
    const alpha = Math.round(70 + 130 * t.probability);
    for (let y = t.row * tilePx; y < (t.row + 1) * tilePx; y++) {
      for (let x = t.col * tilePx; x < (t.col + 1) * tilePx; x++) {
        if (y >= height || x >= width) continue;
        map.data.set([220, 38, 38, alpha], (y * width + x) * 4);
      }
    }
  }
  return encodePng(map);
}

/** Crop one tile out of an RGB raster as a PNG. */
export function cropTilePng(src: Raster, row: number, col: number, tilePx: number): Buffer {
  const out = blank(tilePx, tilePx, 3);
  for (let y = 0; y < tilePx; y++) {
    const sy = row * tilePx + y;
    for (let x = 0; x < tilePx; x++) {
      const sx = col * tilePx + x;
      if (sy >= src.height || sx >= src.width) continue;
      const si = (sy * src.width + sx) * 3;
      out.data.set(src.data.subarray(si, si + 3), (y * tilePx + x) * 3);
    }
  }
  return encodePng(out);
}

export function sha256Hex(bytes: Buffer | string): string {
  return createHash('sha256').update(bytes).digest('hex');
}

/** Seed helpers still need a unit hash; kept here so tile builders stay stable. */
export function unitInterval(key: string): number {
  return createHash('sha256').update(key).digest().readUInt32BE(0) / 2 ** 32;
}

export { blank, round2 };
