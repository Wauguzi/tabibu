// cspell:ignore muse
/**
 * Live pre-read worker: a Queued run becomes Ready (or Failed) after tiles are labelled by
 * Muse Spark vision and every number is computed in code (S-6). SAM segmentation is out of
 * scope: the heatmap is composed from tile labels. Writes only under
 * `cases/{c}/preread/{run}` and `preread/{c}/{run}/` (rule 1).
 */
import type { DocumentData } from 'firebase-admin/firestore';

import { AiError, withTimeout } from './ai';
import { META_RESPONSES_URL, MUSE_SPARK_MODEL, type FetchLike } from './ai-meta';
import { timestamp } from './common';
import { isEnabled } from './config';
import {
  nowOf,
  num,
  readObject,
  saveObject,
  str,
  type Deps,
} from './case-support';
import {
  cropTilePng,
  decodePng,
  draftNumbersMatch,
  heatmapPng,
  histologyDraft,
  histologyMeasurements,
  malariaDraft,
  malariaMeasurements,
  sha256Hex,
  type PrereadDraft,
  type Tile,
} from './preread-measure';

export const PREREAD_PROMPT_VERSION = 'preread-classify-v1';
export const PREREAD_TILE_PX = 96;
/** Many tiles per request; the Model API caps images per call at 50. */
export const PREREAD_TILES_PER_REQUEST = 16;

const CANCER_LABELS = new Set(['Tumour', 'Normal']);
const MALARIA_LABELS = new Set(['Parasitized', 'Uninfected']);

export type PrereadProfile = 'Cancer' | 'Malaria';

export interface TileCrop {
  id: string;
  row: number;
  col: number;
  png: Buffer;
}

export interface ClassifiedTile {
  id: string;
  label: string;
  probability: number;
}

/** Injectable vision seam: production talks to the Responses API; tests fake it. */
export interface PrereadVision {
  classify(crops: TileCrop[], profile: PrereadProfile): Promise<ClassifiedTile[]>;
}

export interface PrereadCache {
  get(key: string): Promise<ClassifiedTile[] | undefined>;
  set(key: string, labels: ClassifiedTile[]): Promise<void>;
}

export interface PrereadWorkerOptions {
  vision?: PrereadVision;
  cache?: PrereadCache;
  fetch?: FetchLike;
  apiKey?: string;
  /** When set, skip the Remote Config read (tests). */
  enabled?: boolean;
}

/**
 * Entry from `onPrereadWritten`: only a Queued run is processed. Ready/Failed fall through to
 * the existing case-stage handler. Kill switch off → no work (rule 6).
 */
export async function processQueuedPreread(
  deps: Deps,
  caseUid: string,
  runUid: string,
  options: PrereadWorkerOptions = {},
): Promise<void> {
  const enabled =
    options.enabled ?? isEnabled(deps.config, 'preread_enabled');
  if (!enabled) return;

  const { db } = deps;
  const runRef = db.collection('cases').doc(caseUid).collection('preread').doc(runUid);
  const now = nowOf(deps);
  const at = timestamp(now);

  const claimed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(runRef);
    if (!snap.exists) return null;
    const run = snap.data() as DocumentData;
    if (str(run.status) !== 'Queued') return null;
    tx.update(runRef, { status: 'Running', startedAt: at, lastUpdatedAt: at, failureReason: '' });
    return run;
  });
  if (!claimed) return;

  try {
    const result = await withTimeout(
      runPreread(deps, caseUid, runUid, claimed, options),
      deps.aiTimeoutMs,
    );
    await runRef.update({
      status: 'Ready',
      segmentationPath: result.segmentationPath,
      labelsPath: result.labelsPath,
      labelCounts: result.labelCounts,
      measurements: result.measurements,
      draft: result.draft,
      models: result.models,
      inputLanguage: str(claimed.inputLanguage) || 'en',
      failureReason: '',
      readyAt: timestamp(nowOf(deps)),
      lastUpdatedAt: timestamp(nowOf(deps)),
    });
  } catch (e) {
    const reason =
      e instanceof AiError && ['Timeout', 'ServiceError', 'OffSchema', 'Stale'].includes(e.reason)
        ? e.reason
        : e instanceof NumberCheckError
          ? 'NumberCheck'
          : 'ServiceError';
    await runRef.update({
      status: 'Failed',
      failureReason: reason,
      readyAt: timestamp(nowOf(deps)),
      lastUpdatedAt: timestamp(nowOf(deps)),
    });
  }
}

class NumberCheckError extends Error {
  constructor() {
    super('NumberCheck');
    this.name = 'NumberCheckError';
  }
}

interface ReadyPayload {
  segmentationPath: string;
  labelsPath: string;
  labelCounts: Record<string, number>;
  measurements: Record<string, number>;
  draft: PrereadDraft;
  models: Record<string, string>;
}

async function runPreread(
  deps: Deps,
  caseUid: string,
  runUid: string,
  run: DocumentData,
  options: PrereadWorkerOptions,
): Promise<ReadyPayload> {
  const profile = str(run.profile) as PrereadProfile;
  if (profile !== 'Cancer' && profile !== 'Malaria') throw new AiError('OffSchema');

  const imagePaths = Array.isArray(run.imagePaths)
    ? run.imagePaths.filter((p): p is string => typeof p === 'string' && p.length > 0)
    : [];
  if (imagePaths.length === 0) throw new AiError('OffSchema');

  const apiKey = options.apiKey ?? process.env.META_API_KEY ?? '';
  const vision =
    options.vision ??
    metaVision({
      apiKey,
      fetch: options.fetch,
    });
  const cache = options.cache ?? memoryCache();

  const allTiles: Tile[] = [];
  let width = 0;
  let height = 0;
  const tilePx = PREREAD_TILE_PX;
  const mpp = num(run.micronsPerPixel);

  for (let i = 0; i < imagePaths.length; i++) {
    const path = imagePaths[i];
    const bytes = await readObject(deps.bucket, path);
    if (!bytes) throw new AiError('ServiceError');
    const raster = decodePng(bytes);
    width = Math.max(width, raster.width);
    height = Math.max(height, raster.height);
    const cols = Math.max(1, Math.floor(raster.width / tilePx));
    const rows = Math.max(1, Math.floor(raster.height / tilePx));
    const crops: TileCrop[] = [];
    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        crops.push({
          id: `img${i}-tile-${row}-${col}`,
          row,
          col,
          png: cropTilePng(raster, row, col, tilePx),
        });
      }
    }

    const imageHash = sha256Hex(bytes);
    const cacheKey = `${MUSE_SPARK_MODEL}|${PREREAD_PROMPT_VERSION}|${imageHash}`;
    let classified = await cache.get(cacheKey);
    if (!classified) {
      classified = await classifyInBatches(vision, crops, profile);
      await cache.set(cacheKey, classified);
    }

    const byId = new Map(classified.map((c) => [c.id, c]));
    const allowed = profile === 'Cancer' ? CANCER_LABELS : MALARIA_LABELS;
    for (const crop of crops) {
      const hit = byId.get(crop.id);
      let label = hit?.label ?? 'Unknown';
      let probability = typeof hit?.probability === 'number' ? hit.probability : 0;
      // Rule 7: a label outside the allowed set is Unknown, never guessed.
      if (!allowed.has(label)) {
        label = 'Unknown';
        probability = 0;
      }
      probability = Math.min(1, Math.max(0, probability));
      allTiles.push({
        id: crop.id,
        imageUid: path,
        label,
        probability,
        row: crop.row,
        col: crop.col,
        source: path,
      });
    }
  }

  const grid = {
    rows: Math.max(1, Math.floor(height / tilePx)),
    cols: Math.max(1, Math.floor(width / tilePx)),
    tilePx,
  };
  const measurements =
    profile === 'Cancer'
      ? histologyMeasurements(allTiles, grid, mpp)
      : malariaMeasurements(allTiles);
  const draft =
    profile === 'Cancer' ? histologyDraft(allTiles, measurements) : malariaDraft(allTiles, measurements);

  if (!draftNumbersMatch(draft, measurements, allTiles.length)) {
    throw new NumberCheckError();
  }

  const folder = `preread/${caseUid}/${runUid}`;
  const labelsPath = `${folder}/labels.json`;
  const segmentationPath = `${folder}/heatmap.png`;
  const positive = profile === 'Cancer' ? 'Tumour' : 'Parasitized';
  const labelCounts: Record<string, number> = {};
  for (const t of allTiles) labelCounts[t.label] = (labelCounts[t.label] ?? 0) + 1;

  await saveObject(
    deps.bucket,
    labelsPath,
    Buffer.from(
      JSON.stringify({
        labels: allTiles,
        grid: { ...grid, micronsPerPixel: mpp },
        promptVersion: PREREAD_PROMPT_VERSION,
      }),
    ),
    'application/json',
  );
  await saveObject(
    deps.bucket,
    segmentationPath,
    heatmapPng(allTiles, width, height, tilePx, positive),
    'image/png',
  );

  // Rule 1: nothing else is written outside the run doc (caller) and this folder.
  assertPathsUnder(caseUid, runUid, [labelsPath, segmentationPath]);

  return {
    segmentationPath,
    labelsPath,
    labelCounts,
    measurements,
    draft,
    models: {
      classify: MUSE_SPARK_MODEL,
      promptVersion: PREREAD_PROMPT_VERSION,
      // SAM is out of scope; heatmap is from tile labels.
      segmentation: 'tile-heatmap',
    },
  };
}

export function assertPathsUnder(caseUid: string, runUid: string, paths: string[]): void {
  const prefix = `preread/${caseUid}/${runUid}/`;
  for (const p of paths) {
    if (!p.startsWith(prefix)) {
      throw new Error('path outside preread folder');
    }
  }
}

async function classifyInBatches(
  vision: PrereadVision,
  crops: TileCrop[],
  profile: PrereadProfile,
): Promise<ClassifiedTile[]> {
  const out: ClassifiedTile[] = [];
  for (let i = 0; i < crops.length; i += PREREAD_TILES_PER_REQUEST) {
    const batch = crops.slice(i, i + PREREAD_TILES_PER_REQUEST);
    const labels = await vision.classify(batch, profile);
    out.push(...labels);
  }
  return out;
}

function memoryCache(): PrereadCache {
  const store = new Map<string, ClassifiedTile[]>();
  return {
    get: async (key) => store.get(key),
    set: async (key, labels) => {
      store.set(key, labels);
    },
  };
}

function metaVision(args: { apiKey: string; fetch?: FetchLike }): PrereadVision {
  const doFetch = args.fetch ?? globalThis.fetch;
  return {
    async classify(crops, profile) {
      if (!args.apiKey) throw new AiError('ServiceError');
      const allowed = profile === 'Cancer' ? [...CANCER_LABELS] : [...MALARIA_LABELS];
      const instructions = [
        `Classify each pathology tile image. Profile: ${profile}.`,
        `Allowed labels: ${allowed.join(', ')}.`,
        'Return JSON with a tiles array of {id, label, probability}.',
        'Probability is 0..1 for the chosen label. Never invent other labels.',
      ].join(' ');
      const content: unknown[] = [
        {
          type: 'input_text',
          text: `Classify these ${crops.length} tiles. ids=${JSON.stringify(crops.map((c) => c.id))}`,
        },
      ];
      for (const crop of crops) {
        content.push({
          type: 'input_text',
          text: `tile id=${crop.id}`,
        });
        content.push({
          type: 'input_image',
          image_url: `data:image/png;base64,${crop.png.toString('base64')}`,
        });
      }
      const body = {
        model: MUSE_SPARK_MODEL,
        store: false,
        instructions,
        input: [{ type: 'message', role: 'user', content }],
        text: {
          format: {
            type: 'json_schema',
            name: 'tile_labels',
            strict: true,
            schema: {
              type: 'object',
              additionalProperties: false,
              required: ['tiles'],
              properties: {
                tiles: {
                  type: 'array',
                  items: {
                    type: 'object',
                    additionalProperties: false,
                    required: ['id', 'label', 'probability'],
                    properties: {
                      id: { type: 'string' },
                      label: { type: 'string' },
                      probability: { type: 'number' },
                    },
                  },
                },
              },
            },
          },
        },
      };
      let response: Response;
      try {
        response = await doFetch(META_RESPONSES_URL, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${args.apiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(body),
        });
      } catch (e) {
        if (e instanceof AiError) throw e;
        throw new AiError('ServiceError');
      }
      if (!response.ok) throw new AiError('ServiceError');
      let text: string;
      try {
        text = await response.text();
      } catch {
        throw new AiError('ServiceError');
      }
      if (!text.trim()) throw new AiError('OffSchema');
      let parsed: unknown;
      try {
        parsed = JSON.parse(text) as unknown;
      } catch {
        throw new AiError('OffSchema');
      }
      const structured = extractJson(parsed);
      if (!structured || typeof structured !== 'object') throw new AiError('OffSchema');
      const tiles = (structured as { tiles?: unknown }).tiles;
      if (!Array.isArray(tiles)) throw new AiError('OffSchema');
      return tiles.map((t) => {
        const row = t as { id?: unknown; label?: unknown; probability?: unknown };
        if (typeof row.id !== 'string' || typeof row.label !== 'string') throw new AiError('OffSchema');
        return {
          id: row.id,
          label: row.label,
          probability: typeof row.probability === 'number' ? row.probability : 0,
        };
      });
    },
  };
}

function extractJson(body: unknown): unknown {
  if (!body || typeof body !== 'object') throw new AiError('OffSchema');
  const root = body as Record<string, unknown>;
  const text =
    typeof root.output_text === 'string'
      ? root.output_text
      : (() => {
          const chunks: string[] = [];
          if (!Array.isArray(root.output)) return '';
          for (const item of root.output) {
            if (!item || typeof item !== 'object') continue;
            const content = (item as { content?: unknown }).content;
            if (!Array.isArray(content)) continue;
            for (const part of content) {
              if (!part || typeof part !== 'object') continue;
              const p = part as { type?: unknown; text?: unknown };
              if (p.type === 'output_text' && typeof p.text === 'string') chunks.push(p.text);
            }
          }
          return chunks.join('');
        })();
  if (!text.trim()) throw new AiError('OffSchema');
  try {
    return JSON.parse(text) as unknown;
  } catch {
    throw new AiError('OffSchema');
  }
}

/** Normalise an off-schema / timed-out / service failure into a Failed reason string. */
export function failureReasonOf(error: unknown): string {
  if (error instanceof NumberCheckError) return 'NumberCheck';
  if (error instanceof AiError) return error.reason;
  return 'ServiceError';
}
