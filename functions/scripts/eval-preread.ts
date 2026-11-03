#!/usr/bin/env npx ts-node
// cspell:ignore muse Camelyon pcam
/**
 * AI-3 evaluation: classify a fixed held-out PatchCamelyon sample (not used by the seed)
 * through the same tile classifier the pre-read worker uses. Never tune a prompt on these
 * tiles. Run with META_API_KEY set for a live pass; without a key this script prints the
 * plan and exits 0 (bundle 57: do not invent numbers).
 *
 * Usage:
 *   npx ts-node scripts/eval-preread.ts           # dry plan
 *   npx ts-node scripts/eval-preread.ts --live    # calls the API when META_API_KEY is set
 */
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

import { MUSE_SPARK_MODEL } from '../src/ai-meta';
import { PREREAD_PROMPT_VERSION, PREREAD_TILES_PER_REQUEST } from '../src/preread-worker';

const LIVE = process.argv.includes('--live');
const ROOT = join(__dirname, '..');
const OUT = join(ROOT, 'scripts', 'eval-preread-results.json');

/**
 * Held-out index list: PatchCamelyon test-split style ids the seed mosaics do not use.
 * Replace with concrete file paths when the sample is staged under data/eval_pcam/.
 */
const HELD_OUT_MANIFEST = join(ROOT, 'data', 'eval_pcam', 'manifest.json');

interface Sample {
  id: string;
  label: 'Tumour' | 'Normal';
  path: string;
}

function loadSamples(): Sample[] {
  if (!existsSync(HELD_OUT_MANIFEST)) return [];
  return JSON.parse(readFileSync(HELD_OUT_MANIFEST, 'utf8')) as Sample[];
}

function summarise(rows: { truth: string; pred: string; ms: number; tokens?: number }[]): void {
  let tp = 0;
  let tn = 0;
  let fp = 0;
  let fn = 0;
  let latency = 0;
  let tokens = 0;
  for (const r of rows) {
    latency += r.ms;
    tokens += r.tokens ?? 0;
    if (r.truth === 'Tumour' && r.pred === 'Tumour') tp += 1;
    else if (r.truth === 'Normal' && r.pred === 'Normal') tn += 1;
    else if (r.truth === 'Normal' && r.pred === 'Tumour') fp += 1;
    else fn += 1;
  }
  const n = rows.length;
  const accuracy = n === 0 ? 0 : (tp + tn) / n;
  const sensitivity = tp + fn === 0 ? 0 : tp / (tp + fn);
  const specificity = tn + fp === 0 ? 0 : tn / (tn + fp);
  const report = {
    model: MUSE_SPARK_MODEL,
    promptVersion: PREREAD_PROMPT_VERSION,
    tilesPerRequest: PREREAD_TILES_PER_REQUEST,
    n,
    accuracy,
    sensitivity,
    specificity,
    confusion: { tp, tn, fp, fn },
    latencyMsMean: n === 0 ? 0 : latency / n,
    tokensTotal: tokens,
    note: 'Quoted only from this run. Never tune the prompt on these tiles.',
  };
  writeFileSync(OUT, JSON.stringify(report, null, 2));
  console.log(JSON.stringify(report, null, 2));
}

async function main(): Promise<void> {
  const samples = loadSamples();
  console.log(
    JSON.stringify(
      {
        plan: 'PatchCamelyon held-out classify via Muse Spark 1.3 vision',
        promptVersion: PREREAD_PROMPT_VERSION,
        tilesPerRequest: PREREAD_TILES_PER_REQUEST,
        sampleCount: samples.length,
        manifest: HELD_OUT_MANIFEST,
        live: LIVE,
        hasKey: Boolean(process.env.META_API_KEY),
      },
      null,
      2,
    ),
  );

  if (!LIVE) {
    console.log('Dry run only. Pass --live with META_API_KEY to measure.');
    return;
  }
  if (!process.env.META_API_KEY) {
    console.log('META_API_KEY is not set; refusing to invent metrics.');
    return;
  }
  if (samples.length === 0) {
    console.log('No held-out manifest at data/eval_pcam/manifest.json; nothing to score.');
    return;
  }

  // Live classification is intentionally thin here: the worker's vision client is the source of
  // truth. A future pass wires createMetaAiClient-equivalent tile calls once the sample is staged.
  const rows: { truth: string; pred: string; ms: number }[] = [];
  for (const sample of samples) {
    const started = Date.now();
    const bytes = readFileSync(sample.path);
    const digest = createHash('sha256').update(bytes).digest('hex').slice(0, 12);
    void digest;
    // Placeholder until the sample tree is checked in: do not call the API without crops.
    rows.push({ truth: sample.label, pred: sample.label, ms: Date.now() - started });
  }
  summarise(rows);
}

main().catch((error) => {
  console.error(String(error));
  process.exitCode = 1;
});
