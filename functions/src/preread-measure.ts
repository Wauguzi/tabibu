/**
 * Pre-read numbers and the heatmap: computed in code from tile labels (S-6). Shared by the
 * live worker and the demo seed so both never invent a count the labels do not support.
 */
import { createHash } from 'node:crypto';
import { crc32, deflateSync, inflateSync } from 'node:zlib';

import * as jpeg from 'jpeg-js';

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
  const unknown = tiles.filter((t) => t.label === 'Unknown').length;
  return {
    tumourTiles: tumour,
    normalTiles: tiles.length - tumour - unknown,
    unknownTiles: unknown,
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

/**
 * Band from the mean of the model's *stated* tile probabilities. Those scores are not
 * calibrated; the band is a coarse signal for triage, never clinical certainty (bundle 59).
 */
export const CONFIDENCE_CALIBRATION_NOTE =
  'Band from mean stated tile probability; not calibrated. Not clinical certainty.';

export type ConfidenceBand = 'High' | 'Moderate' | 'Low';

export function confidenceOf(
  tiles: Tile[],
): { confidence: number; confidenceBand: ConfidenceBand } {
  if (tiles.length === 0) return { confidence: 0, confidenceBand: 'Low' };
  const confidence = round2(tiles.reduce((sum, t) => sum + t.probability, 0) / tiles.length);
  return {
    confidence,
    // Thresholds on stated probabilities only — see CONFIDENCE_CALIBRATION_NOTE.
    confidenceBand: confidence >= 0.85 ? 'High' : confidence >= 0.7 ? 'Moderate' : 'Low',
  };
}

/**
 * The held-out evaluation showed stated probabilities do not track accuracy, so a model-labelled
 * draft never claims more than Low. Stored demo examples do not call this.
 */
export const MODEL_CONFIDENCE_BAND_CAP: ConfidenceBand = 'Low';
export const MODEL_CONFIDENCE_VALUE_CAP = 0.69;

export function applyModelConfidenceCap(draft: PrereadDraft): PrereadDraft {
  if (draft.confidenceBand === MODEL_CONFIDENCE_BAND_CAP && draft.confidence <= MODEL_CONFIDENCE_VALUE_CAP) return draft;
  return {
    ...draft,
    confidenceBand: MODEL_CONFIDENCE_BAND_CAP,
    confidence: Math.min(draft.confidence, MODEL_CONFIDENCE_VALUE_CAP),
  };
}

/** Nearest-neighbour enlarge by a whole factor (bundle 64: more encoder patches on 96 px tiles). */
export function upscaleNearest(src: Raster, factor: number): Raster {
  if (factor < 1 || !Number.isInteger(factor)) throw new Error('invalid upscale factor');
  if (factor === 1) return src;
  const width = src.width * factor;
  const height = src.height * factor;
  const out = blank(width, height, 3);
  for (let y = 0; y < height; y++) {
    const sy = Math.floor(y / factor);
    for (let x = 0; x < width; x++) {
      const sx = Math.floor(x / factor);
      const si = (sy * src.width + sx) * 3;
      out.data.set(src.data.subarray(si, si + 3), (y * width + x) * 3);
    }
  }
  return out;
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
  const unknown = tiles.filter((t) => t.label === 'Unknown').length;
  // Unknown is not Normal: when nothing usable was labelled, or more than a tenth of
  // the section went unlabelled, the draft says so instead of clearing the section.
  const unlabelled = !any && (tiles.length - unknown === 0 || unknown / tiles.length > 0.1);
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
      : unlabelled
        ? 'The pre-read could not label enough of the section.'
        : 'No tumour suspected in the section.',
    confidence,
    confidenceBand,
    urgency: unlabelled ? 'Priority' : m.largestFocusMm > 0.2 ? 'Urgent' : any ? 'Priority' : 'Routine',
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

// --- Images (8-bit RGB; PNG and JPEG by file signature) ---------------------------------------

const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const MAX_SIDE = 4096;

/** Cap on tiles sent for one slide in a pre-read run (bundle 58). */
export const PREREAD_MAX_TILES = 64;

export function isPng(bytes: Buffer): boolean {
  return bytes.length >= 8 && bytes.subarray(0, 8).equals(PNG_SIGNATURE);
}

/** JPEG SOI (FF D8) followed by a marker byte (FF). */
export function isJpeg(bytes: Buffer): boolean {
  return bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
}

/**
 * Decode by signature, not by path extension. PNG uses the existing inflater; JPEG uses
 * jpeg-js (pure JS, BSD-3-Clause — brief said MIT; package licence is BSD-3-Clause). Anything else is refused.
 */
export function decodeImage(bytes: Buffer): Raster {
  if (isPng(bytes)) return decodePng(bytes);
  if (isJpeg(bytes)) return decodeJpeg(bytes);
  throw new Error('unsupported image');
}

export function decodeJpeg(bytes: Buffer): Raster {
  if (!isJpeg(bytes)) throw new Error('not a JPEG');
  const decoded = jpeg.decode(bytes, { formatAsRGBA: true, maxMemoryUsageInMB: 128 });
  if (decoded.width < 1 || decoded.height < 1 || decoded.width > MAX_SIDE || decoded.height > MAX_SIDE) {
    throw new Error('JPEG size out of range');
  }
  const data = Buffer.alloc(decoded.width * decoded.height * 3);
  const src = Buffer.from(decoded.data);
  for (let i = 0, o = 0; i < decoded.width * decoded.height; i++, o += 3) {
    const s = i * 4;
    data[o] = src[s];
    data[o + 1] = src[s + 1];
    data[o + 2] = src[s + 2];
  }
  return { width: decoded.width, height: decoded.height, channels: 3, data };
}

/** Test helper: write a real JPEG so signature-based decode can be exercised. */
export function encodeJpeg(r: Raster, quality = 90): Buffer {
  const rgba = Buffer.alloc(r.width * r.height * 4);
  for (let i = 0; i < r.width * r.height; i++) {
    const s = i * r.channels;
    const o = i * 4;
    rgba[o] = r.data[s];
    rgba[o + 1] = r.data[s + 1];
    rgba[o + 2] = r.data[s + 2];
    rgba[o + 3] = 255;
  }
  return jpeg.encode({ data: rgba, width: r.width, height: r.height }, quality).data;
}

/**
 * Smallest whole downscale factor so `floor(w/f)/tilePx * floor(h/f)/tilePx` is at most
 * [PREREAD_MAX_TILES]. Factor 1 means no resize. Never silently samples a sparse grid.
 */
export function tileBudgetFactor(
  width: number,
  height: number,
  tilePx: number,
  maxTiles: number = PREREAD_MAX_TILES,
): number {
  let factor = 1;
  for (;;) {
    const w = Math.floor(width / factor);
    const h = Math.floor(height / factor);
    const cols = Math.max(1, Math.floor(w / tilePx));
    const rows = Math.max(1, Math.floor(h / tilePx));
    if (rows * cols <= maxTiles) return factor;
    factor += 1;
    if (factor > Math.max(width, height)) return factor;
  }
}

/**
 * Average each `factor × factor` block into one pixel. Microns-per-pixel for the result is
 * the original mpp times `factor` (each new pixel spans that many source pixels on a side).
 */
function blank(width: number, height: number, channels: 3 | 4): Raster {
  return { width, height, channels, data: Buffer.alloc(width * height * channels) };
}

export function downscaleByFactor(src: Raster, factor: number): Raster {
  if (factor < 1 || !Number.isInteger(factor)) throw new Error('invalid scale factor');
  if (factor === 1) return src;
  const width = Math.floor(src.width / factor);
  const height = Math.floor(src.height / factor);
  if (width < 1 || height < 1) throw new Error('scale too large');
  const out = blank(width, height, 3);
  const block = factor * factor;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      let r = 0;
      let g = 0;
      let b = 0;
      for (let dy = 0; dy < factor; dy++) {
        for (let dx = 0; dx < factor; dx++) {
          const si = ((y * factor + dy) * src.width + (x * factor + dx)) * 3;
          r += src.data[si];
          g += src.data[si + 1];
          b += src.data[si + 2];
        }
      }
      const oi = (y * width + x) * 3;
      out.data[oi] = Math.round(r / block);
      out.data[oi + 1] = Math.round(g / block);
      out.data[oi + 2] = Math.round(b / block);
    }
  }
  return out;
}

export function decodePng(bytes: Buffer): Raster {
  if (bytes.length < 33 || !bytes.subarray(0, 8).equals(PNG_SIGNATURE)) throw new Error('not a PNG');
  let width = 0;
  let height = 0;
  // 0 = grey, 2 = RGB, 6 = RGBA. All become 8-bit RGB for tiling.
  let colorType = 2;
  const parts: Buffer[] = [];
  for (let at = 8; at + 8 <= bytes.length; ) {
    const length = bytes.readUInt32BE(at);
    const type = bytes.toString('latin1', at + 4, at + 8);
    const body = bytes.subarray(at + 8, at + 8 + length);
    if (body.length !== length) throw new Error('truncated PNG');
    if (type === 'IHDR') {
      width = body.readUInt32BE(0);
      height = body.readUInt32BE(4);
      colorType = body[9];
      // 8-bit, non-interlaced; grey / RGB / RGBA only (no palette, no 16-bit).
      if (body[8] !== 8 || ![0, 2, 6].includes(colorType) || body[12] !== 0) {
        throw new Error('unsupported PNG');
      }
    } else if (type === 'IDAT') {
      parts.push(body);
    } else if (type === 'IEND') {
      break;
    }
    at += 12 + length;
  }
  if (width < 1 || height < 1 || width > MAX_SIDE || height > MAX_SIDE) throw new Error('PNG size out of range');
  const bpp = colorType === 0 ? 1 : colorType === 2 ? 3 : 4;
  const raw = inflateSync(Buffer.concat(parts), { maxOutputLength: (width * bpp + 1) * height });
  const srcStride = width * bpp;
  if (raw.length !== (srcStride + 1) * height) throw new Error('PNG data length');
  const filtered = Buffer.alloc(srcStride * height);
  for (let y = 0; y < height; y++) {
    const filter = raw[y * (srcStride + 1)];
    for (let x = 0; x < srcStride; x++) {
      const v = raw[y * (srcStride + 1) + 1 + x];
      const a = x >= bpp ? filtered[y * srcStride + x - bpp] : 0;
      const b = y > 0 ? filtered[(y - 1) * srcStride + x] : 0;
      const c = x >= bpp && y > 0 ? filtered[(y - 1) * srcStride + x - bpp] : 0;
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
      filtered[y * srcStride + x] = (v + add) & 0xff;
    }
  }
  const data = Buffer.alloc(width * height * 3);
  for (let i = 0; i < width * height; i++) {
    if (colorType === 0) {
      const g = filtered[i];
      data.set([g, g, g], i * 3);
    } else if (colorType === 2) {
      data.set(filtered.subarray(i * 3, i * 3 + 3), i * 3);
    } else {
      // RGBA → RGB (drop alpha; slides are opaque scans).
      const s = i * 4;
      data.set([filtered[s], filtered[s + 1], filtered[s + 2]], i * 3);
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
