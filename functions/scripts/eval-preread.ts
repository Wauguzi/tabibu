#!/usr/bin/env npx ts-node
// cspell:ignore muse Camelyon pcam
/**
 * Pre-read tile classifier evaluation and prompt tuning (bundles 57 / 59 / 60).
 *
 * - Held-out set (`data/eval_pcam/`): never tune a prompt against these tiles.
 * - Tuning set (`data/tune_pcam/`): staged by `stage-pcam.ts --fetch` from PatchCamelyon train.
 *
 * The API key is read only from `META_API_KEY` and is never printed.
 *
 * Usage:
 *   npx ts-node scripts/eval-preread.ts                 # dry plan
 *   npx ts-node scripts/eval-preread.ts --live --tune   # v2 vs v3 on tune set; writes chosen-version.txt
 *   npx ts-node scripts/eval-preread.ts --live          # held-out for the live prompt (refuses if chosen on held-out)
 */
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
const YES_SPEND = process.argv.includes('--yes-spend');
const ROOT = join(__dirname, '..');
const OUT = join(ROOT, 'scripts', 'eval-preread-results.json');
const CHOSEN = join(ROOT, 'scripts', 'chosen-version.txt');
const HELD_OUT_MANIFEST = join(ROOT, 'data', 'eval_pcam', 'manifest.json');
const TUNE_MANIFEST = join(ROOT, 'data', 'tune_pcam', 'manifest.json');
/** Hard cap on model tile calls per invocation unless `--yes-spend`. */
const MAX_TILE_CALLS = 300;

interface Sample {
  id: string;
  label: 'Tumour' | 'Normal';
  path: string;
  split?: string;
  row?: number;
}

interface Interval {
  low: number;
  high: number;
}

interface Metrics {
  promptVersion: string;
  n: number;
  nTumour: number;
  nNormal: number;
  accuracy: number;
  accuracyWilson95: Interval;
  sensitivity: number;
  sensitivityWilson95: Interval;
  specificity: number;
  specificityWilson95: Interval;
  confusion: { tp: number; tn: number; fp: number; fn: number };
  latencyMsMean: number;
  smallSample: boolean;
}

function loadManifest(path: string): Sample[] {
  if (!existsSync(path)) return [];
  return JSON.parse(readFileSync(path, 'utf8')) as Sample[];
}

/** Wilson score interval for a binomial proportion (z ≈ 1.96 → 95%). */
export function wilson95(successes: number, n: number): Interval {
  if (n <= 0) return { low: 0, high: 0 };
  const z = 1.96;
  const p = successes / n;
  const z2 = z * z;
  const denom = 1 + z2 / n;
  const centre = p + z2 / (2 * n);
  const margin = z * Math.sqrt((p * (1 - p) + z2 / (4 * n)) / n);
  return {
    low: Math.max(0, (centre - margin) / denom),
    high: Math.min(1, (centre + margin) / denom),
  };
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
  let nTumour = 0;
  let nNormal = 0;
  for (const r of rows) {
    latency += r.ms;
    if (r.truth === 'Tumour') nTumour += 1;
    else nNormal += 1;
    if (r.truth === 'Tumour' && r.pred === 'Tumour') tp += 1;
    else if (r.truth === 'Normal' && r.pred === 'Normal') tn += 1;
    else if (r.truth === 'Normal' && r.pred === 'Tumour') fp += 1;
    else fn += 1;
  }
  const n = rows.length;
  const accuracy = n === 0 ? 0 : (tp + tn) / n;
  const sensitivity = tp + fn === 0 ? 0 : tp / (tp + fn);
  const specificity = tn + fp === 0 ? 0 : tn / (tn + fp);
  return {
    promptVersion,
    n,
    nTumour,
    nNormal,
    accuracy,
    accuracyWilson95: wilson95(tp + tn, n),
    sensitivity,
    sensitivityWilson95: wilson95(tp, tp + fn),
    specificity,
    specificityWilson95: wilson95(tn, tn + fp),
    confusion: { tp, tn, fp, fn },
    latencyMsMean: n === 0 ? 0 : latency / n,
    smallSample: n < 100,
  };
}

function printMetrics(m: Metrics): void {
  console.log(
    JSON.stringify(
      {
        promptVersion: m.promptVersion,
        n: m.n,
        nTumour: m.nTumour,
        nNormal: m.nNormal,
        smallSample: m.smallSample,
        accuracy: m.accuracy,
        accuracyWilson95: m.accuracyWilson95,
        sensitivity: m.sensitivity,
        sensitivityWilson95: m.sensitivityWilson95,
        specificity: m.specificity,
        specificityWilson95: m.specificityWilson95,
        confusion: m.confusion,
        latencyMsMean: m.latencyMsMean,
      },
      null,
      2,
    ),
  );
}

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
  if (!response.ok) {
    throw new Error(`classify failed statusClass=${response.status >= 500 ? '5xx' : '4xx'}`);
  }
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

function assertSpend(tileCalls: number): void {
  if (tileCalls <= MAX_TILE_CALLS) return;
  if (!YES_SPEND) {
    throw new Error(
      `Refusing ${tileCalls} tile calls (cap ${MAX_TILE_CALLS}). Pass --yes-spend to proceed.`,
    );
  }
}

async function main(): Promise<void> {
  const heldOut = loadManifest(HELD_OUT_MANIFEST);
  const tune = loadManifest(TUNE_MANIFEST);
  const hasKey = Boolean(process.env.META_API_KEY);
  const chosen = existsSync(CHOSEN) ? readFileSync(CHOSEN, 'utf8').trim() : '';

  if (TUNE && heldOut.length > 0 && tune.length === 0) {
    // Guard: never treat eval_pcam as a tuning set.
    console.log('Refusing --tune: tuning uses data/tune_pcam only, never eval_pcam.');
    process.exitCode = 1;
    return;
  }

  const header = {
    plan: TUNE
      ? 'PatchCamelyon tuning set: compare preread-classify-v2 vs v3 (never the held-out set)'
      : 'PatchCamelyon held-out classify via Muse Spark 1.3 vision',
    smallSampleNote:
      'With fewer than 100 tiles per set these are small-sample estimates (Wilson 95% intervals).',
    promptVersionLive: PREREAD_PROMPT_VERSION,
    promptVersionsCompared: TUNE
      ? [PREREAD_PROMPT_VERSION_V2, PREREAD_PROMPT_VERSION]
      : [PREREAD_PROMPT_VERSION],
    pcamRuleInV3: PREREAD_PCAM_LABEL_RULE.slice(0, 80) + '…',
    tilesPerRequest: PREREAD_TILES_PER_REQUEST,
    heldOutCount: heldOut.length,
    tuneManifestCount: tune.length,
    chosenVersionFile: chosen || null,
    heldOutManifest: HELD_OUT_MANIFEST,
    tuneManifest: TUNE_MANIFEST,
    stageHint:
      tune.length === 0 || heldOut.length === 0
        ? 'Run: npx ts-node scripts/stage-pcam.ts --fetch'
        : null,
    live: LIVE,
    tune: TUNE,
    hasKey,
    maxTileCalls: MAX_TILE_CALLS,
  };
  console.log(JSON.stringify(header, null, 2));

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
        'No tuning manifest at data/tune_pcam/manifest.json; run: npx ts-node scripts/stage-pcam.ts --fetch',
      );
      process.exitCode = 1;
      return;
    }
    // Two prompt versions × n tiles.
    assertSpend(tune.length * 2);
    const v2 = await scoreSet(tune, PREREAD_PROMPT_VERSION_V2, instructionsV2(), apiKey);
    const v3 = await scoreSet(tune, PREREAD_PROMPT_VERSION, instructionsV3(), apiKey);
    if (v2.smallSample || v3.smallSample) {
      console.log(
        JSON.stringify({
          warning: 'small-sample estimates (n < 100); see Wilson 95% intervals',
          n: tune.length,
        }),
      );
    }
    printMetrics(v2);
    printMetrics(v3);
    // Choose the higher accuracy; ties keep the live (v3) prompt.
    const winner =
      v2.accuracy > v3.accuracy ? PREREAD_PROMPT_VERSION_V2 : PREREAD_PROMPT_VERSION;
    writeFileSync(CHOSEN, `${winner}\n`);
    const report = {
      set: 'tune',
      note: 'Quoted only from this run. Held-out tiles were not used for tuning.',
      model: MUSE_SPARK_MODEL,
      chosenVersion: winner,
      byPromptVersion: [v2, v3],
    };
    writeFileSync(OUT, JSON.stringify(report, null, 2));
    console.log(JSON.stringify(report, null, 2));
    return;
  }

  if (heldOut.length === 0) {
    console.log(
      'No held-out manifest at data/eval_pcam/manifest.json; run: npx ts-node scripts/stage-pcam.ts --fetch',
    );
    process.exitCode = 1;
    return;
  }

  // Refuse held-out numbers for a prompt that was chosen by shopping on held-out:
  // after --tune, only the chosen version may be scored on held-out.
  if (chosen && chosen !== PREREAD_PROMPT_VERSION) {
    console.log(
      JSON.stringify({
        refused: true,
        reason:
          'held-out is only printed for the version in scripts/chosen-version.txt (from --tune)',
        chosen,
        livePrompt: PREREAD_PROMPT_VERSION,
      }),
    );
    process.exitCode = 1;
    return;
  }

  assertSpend(heldOut.length);
  const current = await scoreSet(heldOut, PREREAD_PROMPT_VERSION, instructionsV3(), apiKey);
  if (current.smallSample) {
    console.log(
      JSON.stringify({
        warning: 'small-sample estimates (n < 100); see Wilson 95% intervals',
        n: heldOut.length,
      }),
    );
  }
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
  console.error(error instanceof Error ? error.message : 'eval failed');
  process.exitCode = 1;
});
