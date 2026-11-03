#!/usr/bin/env npx ts-node
// cspell:ignore muse Camelyon pcam
/**
 * Pre-read tile classifier evaluation and prompt tuning (bundles 57 / 59).
 *
 * - Held-out set (`data/eval_pcam/`): never tune a prompt against these tiles.
 * - Tuning set (`data/tune_pcam/`): 60 balanced PatchCamelyon *train* rows reserved below,
 *   disjoint from the seed mosaics and the held-out set. Stage files before `--live --tune`.
 *
 * The API key is read only from `META_API_KEY` in the environment and is never printed.
 *
 * Usage:
 *   npx ts-node scripts/eval-preread.ts              # dry plan
 *   npx ts-node scripts/eval-preread.ts --live       # held-out metrics (current prompt)
 *   npx ts-node scripts/eval-preread.ts --live --tune  # v2 vs v3 on the tuning set only
 */
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

import { META_RESPONSES_URL, MUSE_SPARK_MODEL, type FetchLike } from '../src/ai-meta';
import {
  PREREAD_IMAGE_TEXT_RULE,
  PREREAD_PCAM_LABEL_RULE,
  PREREAD_PROMPT_VERSION,
  PREREAD_PROMPT_VERSION_V2,
  PREREAD_TILES_PER_REQUEST,
  TILE_REASONING_EFFORT,
  buildClassifyInstructions,
} from '../src/preread-worker';

const LIVE = process.argv.includes('--live');
const TUNE = process.argv.includes('--tune');
const ROOT = join(__dirname, '..');
const OUT = join(ROOT, 'scripts', 'eval-preread-results.json');
const HELD_OUT_MANIFEST = join(ROOT, 'data', 'eval_pcam', 'manifest.json');
const TUNE_MANIFEST = join(ROOT, 'data', 'tune_pcam', 'manifest.json');

/**
 * Reserved PatchCamelyon train-split row indices for prompt tuning (bundle 59).
 * Each row's class is read from the dataset when staged, never assumed here; ids stay outside the demo mosaic sources
 * (`train/0`…`train/99` style names in slides.json) and outside the held-out eval tree.
 * Labels and PNG paths come from `data/tune_pcam/manifest.json` when Theo stages the pull.
 */
export const TUNE_PCAM_TRAIN_ROWS: readonly number[] = [
  // First reservation (30).
  12010, 12011, 12012, 12013, 12014, 12015, 12016, 12017, 12018, 12019, 12020, 12021, 12022,
  12023, 12024, 12025, 12026, 12027, 12028, 12029, 12030, 12031, 12032, 12033, 12034, 12035,
  12036, 12037, 12038, 12039,
  // Second reservation (30).
  22010, 22011, 22012, 22013, 22014, 22015, 22016, 22017, 22018, 22019, 22020, 22021, 22022,
  22023, 22024, 22025, 22026, 22027, 22028, 22029, 22030, 22031, 22032, 22033, 22034, 22035,
  22036, 22037, 22038, 22039,
];

interface Sample {
  id: string;
  label: 'Tumour' | 'Normal';
  path: string;
  row?: number;
}

interface Metrics {
  promptVersion: string;
  n: number;
  accuracy: number;
  sensitivity: number;
  specificity: number;
  confusion: { tp: number; tn: number; fp: number; fn: number };
  latencyMsMean: number;
}

function loadManifest(path: string): Sample[] {
  if (!existsSync(path)) return [];
  return JSON.parse(readFileSync(path, 'utf8')) as Sample[];
}

function metricsOf(
  promptVersion: string,
  rows: { truth: string; pred: string; ms: number }[],
): Metrics {
  let tp = 0;
  let tn = 0;
  let fp = 0;
  let fn = 0;
  let latency = 0;
  for (const r of rows) {
    latency += r.ms;
    if (r.truth === 'Tumour' && r.pred === 'Tumour') tp += 1;
    else if (r.truth === 'Normal' && r.pred === 'Normal') tn += 1;
    else if (r.truth === 'Normal' && r.pred === 'Tumour') fp += 1;
    else fn += 1;
  }
  const n = rows.length;
  return {
    promptVersion,
    n,
    accuracy: n === 0 ? 0 : (tp + tn) / n,
    sensitivity: tp + fn === 0 ? 0 : tp / (tp + fn),
    specificity: tn + fp === 0 ? 0 : tn / (tn + fp),
    confusion: { tp, tn, fp, fn },
    latencyMsMean: n === 0 ? 0 : latency / n,
  };
}

function printMetrics(m: Metrics): void {
  console.log(
    JSON.stringify(
      {
        promptVersion: m.promptVersion,
        n: m.n,
        accuracy: m.accuracy,
        sensitivity: m.sensitivity,
        specificity: m.specificity,
        confusion: m.confusion,
        latencyMsMean: m.latencyMsMean,
      },
      null,
      2,
    ),
  );
}

/** v2 instructions (pre–central-32 rule) for an A/B tune pass only. */
function instructionsV2(): string {
  return [
    'Classify each pathology tile image. Profile: Cancer.',
    'Allowed labels: Tumour, Normal.',
    'Return JSON with a tiles array of {id, label, probability}.',
    'Probability is 0..1 for the chosen label. Never invent other labels.',
    PREREAD_IMAGE_TEXT_RULE,
  ].join(' ');
}

function instructionsV3(): string {
  return buildClassifyInstructions('Cancer');
}

async function classifyOne(
  sample: Sample,
  instructions: string,
  apiKey: string,
  doFetch: FetchLike,
): Promise<{ pred: string; ms: number }> {
  const bytes = readFileSync(sample.path);
  const started = Date.now();
  const body = {
    model: MUSE_SPARK_MODEL,
    store: false,
    reasoning: { effort: TILE_REASONING_EFFORT },
    instructions,
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          { type: 'input_text', text: `Classify this one tile. id=${sample.id}` },
          {
            type: 'input_image',
            image_url: `data:image/png;base64,${bytes.toString('base64')}`,
          },
        ],
      },
    ],
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
  const response = await doFetch(META_RESPONSES_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  if (!response.ok) throw new Error(`classify failed statusClass=${response.status >= 500 ? '5xx' : '4xx'}`);
  const text = await response.text();
  const parsed = JSON.parse(text) as {
    output?: { content?: { type?: string; text?: string }[] }[];
    output_text?: string;
  };
  let jsonText = typeof parsed.output_text === 'string' ? parsed.output_text : '';
  if (!jsonText && Array.isArray(parsed.output)) {
    for (const item of parsed.output) {
      for (const part of item.content ?? []) {
        if (part.type === 'output_text' && typeof part.text === 'string') jsonText += part.text;
      }
    }
  }
  const structured = JSON.parse(jsonText) as { tiles?: { id?: string; label?: string }[] };
  const pred = structured.tiles?.[0]?.label === 'Tumour' ? 'Tumour' : 'Normal';
  void createHash('sha256').update(bytes).digest('hex');
  return { pred, ms: Date.now() - started };
}

async function scoreSet(
  samples: Sample[],
  promptVersion: string,
  instructions: string,
  apiKey: string,
): Promise<Metrics> {
  const rows: { truth: string; pred: string; ms: number }[] = [];
  for (const sample of samples) {
    const { pred, ms } = await classifyOne(sample, instructions, apiKey, globalThis.fetch);
    rows.push({ truth: sample.label, pred, ms });
  }
  return metricsOf(promptVersion, rows);
}

async function main(): Promise<void> {
  const heldOut = loadManifest(HELD_OUT_MANIFEST);
  const tune = loadManifest(TUNE_MANIFEST);
  const hasKey = Boolean(process.env.META_API_KEY);

  console.log(
    JSON.stringify(
      {
        plan: TUNE
          ? 'PatchCamelyon tuning set: compare preread-classify-v2 vs v3 (never the held-out set)'
          : 'PatchCamelyon held-out classify via Muse Spark 1.3 vision',
        promptVersionLive: PREREAD_PROMPT_VERSION,
        promptVersionsCompared: TUNE
          ? [PREREAD_PROMPT_VERSION_V2, PREREAD_PROMPT_VERSION]
          : [PREREAD_PROMPT_VERSION],
        pcamRuleInV3: PREREAD_PCAM_LABEL_RULE.slice(0, 80) + '…',
        tilesPerRequest: PREREAD_TILES_PER_REQUEST,
        heldOutCount: heldOut.length,
        tuneManifestCount: tune.length,
        tuneReservedRows: TUNE_PCAM_TRAIN_ROWS.length,
        tuneReservedRowIds: TUNE_PCAM_TRAIN_ROWS,
        heldOutManifest: HELD_OUT_MANIFEST,
        tuneManifest: TUNE_MANIFEST,
        live: LIVE,
        tune: TUNE,
        hasKey,
      },
      null,
      2,
    ),
  );

  if (!LIVE) {
    console.log('Dry run only. Pass --live with META_API_KEY to measure. Never prints the key.');
    return;
  }

  const apiKey = process.env.META_API_KEY;
  if (!apiKey) {
    console.log('META_API_KEY is not set; refusing to invent metrics.');
    return;
  }

  if (TUNE) {
    if (tune.length === 0) {
      console.log(
        'No tuning manifest at data/tune_pcam/manifest.json; stage the 60 reserved train rows first.',
      );
      return;
    }
    const v2 = await scoreSet(tune, PREREAD_PROMPT_VERSION_V2, instructionsV2(), apiKey);
    const v3 = await scoreSet(tune, PREREAD_PROMPT_VERSION, instructionsV3(), apiKey);
    printMetrics(v2);
    printMetrics(v3);
    const report = {
      set: 'tune',
      note: 'Quoted only from this run. Held-out tiles were not used for tuning.',
      model: MUSE_SPARK_MODEL,
      byPromptVersion: [v2, v3],
    };
    writeFileSync(OUT, JSON.stringify(report, null, 2));
    console.log(JSON.stringify(report, null, 2));
    return;
  }

  if (heldOut.length === 0) {
    console.log('No held-out manifest at data/eval_pcam/manifest.json; nothing to score.');
    return;
  }
  const current = await scoreSet(
    heldOut,
    PREREAD_PROMPT_VERSION,
    instructionsV3(),
    apiKey,
  );
  printMetrics(current);
  const report = {
    set: 'held-out',
    note: 'Quoted only from this run. Never tune the prompt on these tiles.',
    model: MUSE_SPARK_MODEL,
    byPromptVersion: [current],
  };
  writeFileSync(OUT, JSON.stringify(report, null, 2));
  console.log(JSON.stringify(report, null, 2));
}

main().catch((error) => {
  // Never echo the key or response bodies.
  console.error(error instanceof Error ? error.message : 'eval failed');
  process.exitCode = 1;
});
