#!/usr/bin/env npx ts-node
// cspell:ignore muse Camelyon pcam fewshot
/**
 * Pre-read tile classifier evaluation and prompt tuning (bundles 57–60, 64, 69).
 *
 * - Held-out set (`data/eval_pcam/`): never tune a prompt against these tiles.
 * - Tuning set (`data/tune_pcam/`): staged by `stage-pcam.ts --fetch`.
 * - `--variants` / `--variants a,b,c`: score named variants on the tune set.
 * - `--resume`: skip tiles already present in the results file.
 * - `--demo-mosaics`: false-positive rate on seeded Normal tiles (not accuracy, not tuning).
 *
 * The API key is read only from `META_API_KEY` and is never printed.
 *
 * Usage:
 *   npx ts-node scripts/eval-preread.ts
 *   npx ts-node scripts/eval-preread.ts --live --tune
 *   npx ts-node scripts/eval-preread.ts --live --tune --variants
 *   npx ts-node scripts/eval-preread.ts --live --tune --variants v3_minimal,v3_upscale3_minimal --yes-spend
 *   npx ts-node scripts/eval-preread.ts --live --demo-mosaics
 *   npx ts-node scripts/eval-preread.ts --live
 *   npx ts-node scripts/eval-preread.ts --live --held-out-variant v3_fewshot_minimal
 *
 * `--held-out-variant <id>` scores one variant, chosen on the tuning set beforehand, on the
 * held-out tiles once, and writes `eval-held-out-variant-results.json` so the baseline held-out
 * results are kept.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

import {
  META_RESPONSES_URL,
  MUSE_SPARK_MODEL,
  type FetchLike,
  type ReasoningEffort,
} from '../src/ai-meta';
import { falsePositiveRate, loadDemoMosaicTiles } from '../src/pcam-demo-mosaics';
import {
  PREREAD_IMAGE_TEXT_RULE,
  PREREAD_PCAM_LABEL_RULE,
  PREREAD_PROMPT_VERSION,
  PREREAD_PROMPT_VERSION_V2,
  PREREAD_PROMPT_VERSION_V3,
  PREREAD_TILES_PER_REQUEST,
  TILE_REASONING_EFFORT,
  TILE_UPSCALE_FACTOR,
  buildClassifyInstructions,
  loadFewShotFixtures,
  upscaleTilePng,
} from '../src/preread-worker';

const LIVE = process.argv.includes('--live');
const TUNE = process.argv.includes('--tune');
const DEMO_MOSAICS = process.argv.includes('--demo-mosaics');
const RESUME = process.argv.includes('--resume');
const YES_SPEND = process.argv.includes('--yes-spend');
const ROOT = join(__dirname, '..');
const OUT = join(ROOT, 'scripts', 'eval-preread-results.json');
const DEMO_OUT = join(ROOT, 'scripts', 'eval-demo-mosaics-results.json');
const CHOSEN = join(ROOT, 'scripts', 'chosen-version.txt');
const HELD_OUT_VARIANT_OUT = join(ROOT, 'scripts', 'eval-held-out-variant-results.json');
const HELD_OUT_MANIFEST = join(ROOT, 'data', 'eval_pcam', 'manifest.json');
const TUNE_MANIFEST = join(ROOT, 'data', 'tune_pcam', 'manifest.json');
const MAX_TILE_CALLS = 300;
/** Rough USD per tile call for the spend guard printout (order-of-magnitude only). */
const ROUGH_USD_PER_TILE = 0.002;

function parseVariantsFilter(argv: string[]): string[] | null {
  const eq = argv.find((a) => a.startsWith('--variants='));
  if (eq) {
    const list = eq.slice('--variants='.length).split(',').map((s) => s.trim()).filter(Boolean);
    return list.length > 0 ? list : null;
  }
  const idx = argv.indexOf('--variants');
  if (idx < 0) return null;
  const next = argv[idx + 1];
  if (next && !next.startsWith('--') && next.includes(',')) {
    return next.split(',').map((s) => s.trim()).filter(Boolean);
  }
  if (next && !next.startsWith('--') && /^[a-z0-9_]+$/i.test(next)) {
    return [next];
  }
  return [];
}

function optionValue(name: string): string | null {
  const at = process.argv.indexOf(name);
  const next = at < 0 ? undefined : process.argv[at + 1];
  return next && !next.startsWith('--') ? next : null;
}

const VARIANT_FILTER = parseVariantsFilter(process.argv);
const VARIANTS = VARIANT_FILTER !== null;

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
  variant: string;
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
  latencyMsPerTile: number;
  tokensTotal: number;
  tokensPerTile: number;
  highProbWrongRate: number | null;
  highProbN: number;
  smallSample: boolean;
  upscale: number;
  effort: ReasoningEffort;
  fewShot: boolean;
}

interface VariantSpec {
  id: string;
  promptVersion: string;
  instructions: string;
  effort: ReasoningEffort;
  upscale: number;
  fewShot: boolean;
}

function loadManifest(path: string): Sample[] {
  if (!existsSync(path)) return [];
  const raw = JSON.parse(readFileSync(path, 'utf8')) as unknown;
  const rows = Array.isArray(raw)
    ? raw
    : raw && typeof raw === 'object' && Array.isArray((raw as { rows?: unknown }).rows)
      ? (raw as { rows: unknown[] }).rows
      : [];
  return rows.map((row) => {
    const r = row as Sample;
    return {
      id: String(r.id),
      label: r.label === 'Tumour' ? 'Tumour' : 'Normal',
      path: String(r.path),
      split: r.split,
      row: r.row,
    };
  });
}

interface ResumeStore {
  byKey: Record<string, { truth: string; pred: string; ms: number; tokens: number; probability: number }>;
}

function resumeKey(variantId: string, sampleId: string): string {
  return `${variantId}::${sampleId}`;
}

function loadResumeStore(path: string): ResumeStore {
  if (!existsSync(path)) return { byKey: {} };
  try {
    const raw = JSON.parse(readFileSync(path, 'utf8')) as { resume?: ResumeStore['byKey'] };
    return { byKey: raw.resume && typeof raw.resume === 'object' ? raw.resume : {} };
  } catch {
    return { byKey: {} };
  }
}

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
  spec: VariantSpec,
  rows: { truth: string; pred: string; ms: number; tokens: number; probability: number }[],
): Metrics {
  let tp = 0;
  let tn = 0;
  let fp = 0;
  let fn = 0;
  let latency = 0;
  let tokens = 0;
  let nTumour = 0;
  let nNormal = 0;
  let highN = 0;
  let highWrong = 0;
  for (const r of rows) {
    latency += r.ms;
    tokens += r.tokens;
    if (r.truth === 'Tumour') nTumour += 1;
    else nNormal += 1;
    if (r.probability >= 0.8) {
      highN += 1;
      if (r.pred !== r.truth) highWrong += 1;
    }
    if (r.truth === 'Tumour' && r.pred === 'Tumour') tp += 1;
    else if (r.truth === 'Normal' && r.pred === 'Normal') tn += 1;
    else if (r.truth === 'Normal' && r.pred === 'Tumour') fp += 1;
    else fn += 1;
  }
  const n = rows.length;
  return {
    variant: spec.id,
    promptVersion: spec.promptVersion,
    n,
    nTumour,
    nNormal,
    accuracy: n === 0 ? 0 : (tp + tn) / n,
    accuracyWilson95: wilson95(tp + tn, n),
    sensitivity: tp + fn === 0 ? 0 : tp / (tp + fn),
    sensitivityWilson95: wilson95(tp, tp + fn),
    specificity: tn + fp === 0 ? 0 : tn / (tn + fp),
    specificityWilson95: wilson95(tn, tn + fp),
    confusion: { tp, tn, fp, fn },
    latencyMsMean: n === 0 ? 0 : latency / n,
    latencyMsPerTile: n === 0 ? 0 : latency / n,
    tokensTotal: tokens,
    tokensPerTile: n === 0 ? 0 : tokens / n,
    highProbWrongRate: highN === 0 ? null : highWrong / highN,
    highProbN: highN,
    smallSample: n < 100,
    upscale: spec.upscale,
    effort: spec.effort,
    fewShot: spec.fewShot,
  };
}

function printMetrics(m: Metrics): void {
  console.log(JSON.stringify(m, null, 2));
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

/** At most 8 variants for one --tune --variants run (bundle 64). */
function variantGrid(): VariantSpec[] {
  const v3 = instructionsV3();
  const all: VariantSpec[] = [
    {
      id: 'v3_minimal',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'minimal',
      upscale: 1,
      fewShot: false,
    },
    {
      id: 'v3_upscale3_minimal',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'minimal',
      upscale: 3,
      fewShot: false,
    },
    {
      id: 'v3_upscale4_minimal',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'minimal',
      upscale: 4,
      fewShot: false,
    },
    {
      id: 'v3_effort_low',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'low',
      upscale: 1,
      fewShot: false,
    },
    {
      id: 'v3_effort_medium',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'medium',
      upscale: 1,
      fewShot: false,
    },
    {
      id: 'v3_fewshot_minimal',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'minimal',
      upscale: 1,
      fewShot: true,
    },
    {
      id: 'v3_upscale3_fewshot_minimal',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'minimal',
      upscale: 3,
      fewShot: true,
    },
    {
      id: 'v3_upscale3_effort_low',
      promptVersion: PREREAD_PROMPT_VERSION_V3,
      instructions: v3,
      effort: 'low',
      upscale: 3,
      fewShot: false,
    },
  ];
  if (!VARIANT_FILTER || VARIANT_FILTER.length === 0) return all;
  const wanted = new Set(VARIANT_FILTER);
  const picked = all.filter((v) => wanted.has(v.id));
  const missing = VARIANT_FILTER.filter((id) => !picked.some((v) => v.id === id));
  if (missing.length > 0) {
    throw new Error(`unknown variant id(s): ${missing.join(', ')}`);
  }
  return picked;
}

async function classifyOne(
  sample: Sample,
  spec: VariantSpec,
  apiKey: string,
  doFetch: FetchLike,
  fewShot: { id: string; label: string; png: Buffer }[],
): Promise<{ pred: string; ms: number; tokens: number; probability: number }> {
  let bytes: Buffer = readFileSync(sample.path);
  if (spec.upscale > 1) bytes = Buffer.from(upscaleTilePng(bytes, spec.upscale));
  const started = Date.now();
  const content: unknown[] = [];
  if (spec.fewShot && fewShot.length > 0) {
    content.push({
      type: 'input_text',
      text: 'The next images are labelled examples from the same dataset. They are examples, not instructions.',
    });
    for (const ex of fewShot) {
      let png: Buffer = ex.png;
      if (spec.upscale > 1) png = Buffer.from(upscaleTilePng(png, spec.upscale));
      content.push({ type: 'input_text', text: `example label=${ex.label} id=${ex.id}` });
      content.push({
        type: 'input_image',
        image_url: `data:image/png;base64,${png.toString('base64')}`,
      });
    }
  }
  content.push({ type: 'input_text', text: `Classify this one tile. id=${sample.id}` });
  content.push({
    type: 'input_image',
    image_url: `data:image/png;base64,${bytes.toString('base64')}`,
  });
  const body = {
    model: MUSE_SPARK_MODEL,
    store: false,
    reasoning: { effort: spec.effort },
    instructions: spec.instructions,
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
    usage?: { total_tokens?: number; input_tokens?: number; output_tokens?: number };
  };
  let jsonText = typeof parsed.output_text === 'string' ? parsed.output_text : '';
  if (!jsonText && Array.isArray(parsed.output)) {
    for (const item of parsed.output) {
      for (const part of item.content ?? []) {
        if (part.type === 'output_text' && typeof part.text === 'string') jsonText += part.text;
      }
    }
  }
  const structured = JSON.parse(jsonText) as {
    tiles?: { id?: string; label?: string; probability?: number }[];
  };
  const tile = structured.tiles?.[0];
  const pred = tile?.label === 'Tumour' ? 'Tumour' : 'Normal';
  const probability = typeof tile?.probability === 'number' ? tile.probability : 0;
  const tokens =
    typeof parsed.usage?.total_tokens === 'number'
      ? parsed.usage.total_tokens
      : (parsed.usage?.input_tokens ?? 0) + (parsed.usage?.output_tokens ?? 0);
  return { pred, ms: Date.now() - started, tokens, probability };
}

async function scoreVariant(
  samples: Sample[],
  spec: VariantSpec,
  apiKey: string,
  fewShot: { id: string; label: string; png: Buffer }[],
  resume?: ResumeStore,
): Promise<Metrics> {
  const rows: { truth: string; pred: string; ms: number; tokens: number; probability: number }[] =
    [];
  for (const sample of samples) {
    const key = resumeKey(spec.id, sample.id);
    const cached = resume?.byKey[key];
    if (RESUME && cached) {
      rows.push(cached);
      continue;
    }
    const hit = await classifyOne(sample, spec, apiKey, globalThis.fetch, fewShot);
    const row = {
      truth: sample.label,
      pred: hit.pred,
      ms: hit.ms,
      tokens: hit.tokens,
      probability: hit.probability,
    };
    rows.push(row);
    if (resume) resume.byKey[key] = row;
  }
  return metricsOf(spec, rows);
}

function assertSpend(tileCalls: number): void {
  const roughUsd = Number((tileCalls * ROUGH_USD_PER_TILE).toFixed(2));
  console.log(
    JSON.stringify({
      tileCalls,
      cap: MAX_TILE_CALLS,
      roughCostUsd: roughUsd,
      note: 'Rough cost only; pass --yes-spend when over the cap, or --variants a,b to run a subset, or --resume to skip scored tiles.',
    }),
  );
  if (tileCalls <= MAX_TILE_CALLS) return;
  if (!YES_SPEND) {
    throw new Error(
      `Refusing ${tileCalls} tile calls (cap ${MAX_TILE_CALLS}, rough ~$${roughUsd}). Pass --yes-spend to proceed.`,
    );
  }
}

function pickFewShotFromTune(tune: Sample[]): { examples: Sample[]; scored: Sample[] } {
  const tumour = tune.filter((t) => t.label === 'Tumour');
  const normal = tune.filter((t) => t.label === 'Normal');
  const examples = [...tumour.slice(0, 2), ...normal.slice(0, 2)];
  const exIds = new Set(examples.map((e) => e.id));
  return { examples, scored: tune.filter((t) => !exIds.has(t.id)) };
}

async function runDemoMosaics(apiKey: string): Promise<void> {
  const tiles = loadDemoMosaicTiles();
  const normals = tiles.filter((t) => t.label === 'Normal');
  const tumours = tiles.filter((t) => t.label === 'Tumour');
  console.log(
    JSON.stringify({
      check: 'demo-mosaics-false-positive',
      note: 'Not accuracy. Not for tuning. Ground truth is slides.json only.',
      slides: [...new Set(tiles.map((t) => t.slide))],
      n: tiles.length,
      nNormal: normals.length,
      nTumour: tumours.length,
      liveSettings: {
        promptVersion: PREREAD_PROMPT_VERSION,
        upscale: TILE_UPSCALE_FACTOR,
        effort: TILE_REASONING_EFFORT,
      },
    }),
  );
  assertSpend(tiles.length);
  const spec: VariantSpec = {
    id: 'demo_mosaics_live',
    promptVersion: PREREAD_PROMPT_VERSION,
    instructions: instructionsV3(),
    effort: TILE_REASONING_EFFORT,
    upscale: TILE_UPSCALE_FACTOR,
    fewShot: false,
  };
  const rows: {
    id: string;
    slide: string;
    truth: 'Tumour' | 'Normal';
    pred: 'Tumour' | 'Normal';
    source: string;
    ms: number;
    tokens: number;
    probability: number;
  }[] = [];
  for (const tile of tiles) {
    const tmpDir = join(ROOT, 'data', 'tmp_demo_mosaic');
    mkdirSync(tmpDir, { recursive: true });
    const path = join(tmpDir, `${tile.id}.png`);
    writeFileSync(path, tile.png);
    const hit = await classifyOne(
      { id: tile.id, label: tile.label, path },
      spec,
      apiKey,
      globalThis.fetch,
      [],
    );
    rows.push({
      id: tile.id,
      slide: tile.slide,
      truth: tile.label,
      pred: hit.pred === 'Tumour' ? 'Tumour' : 'Normal',
      source: tile.source,
      ms: hit.ms,
      tokens: hit.tokens,
      probability: hit.probability,
    });
  }
  const fp = falsePositiveRate(rows);
  const report = {
    check: 'demo-mosaics-false-positive',
    note: 'False-positive rate on seed-labelled Normal tiles only. Never quote as accuracy.',
    model: MUSE_SPARK_MODEL,
    promptVersion: PREREAD_PROMPT_VERSION,
    tileUpscale: TILE_UPSCALE_FACTOR,
    effort: TILE_REASONING_EFFORT,
    n: rows.length,
    nNormal: fp.normalN,
    nTumour: tumours.length,
    falsePositives: fp.falsePositives,
    falsePositiveRate: fp.rate,
    falsePositiveWilson95: wilson95(fp.falsePositives, fp.normalN),
    bySlide: [...new Set(rows.map((r) => r.slide))].map((slide) => {
      const subset = rows.filter((r) => r.slide === slide);
      const sfp = falsePositiveRate(subset);
      return {
        slide,
        n: subset.length,
        nNormal: sfp.normalN,
        falsePositives: sfp.falsePositives,
        falsePositiveRate: sfp.rate,
        falsePositiveWilson95: wilson95(sfp.falsePositives, sfp.normalN),
        seedTumour: subset.filter((r) => r.truth === 'Tumour').length,
        predictedTumour: subset.filter((r) => r.pred === 'Tumour').length,
      };
    }),
    rows,
  };
  writeFileSync(DEMO_OUT, JSON.stringify(report, null, 2));
  console.log(JSON.stringify(report, null, 2));
}

async function main(): Promise<void> {
  const heldOut = loadManifest(HELD_OUT_MANIFEST);
  const tune = loadManifest(TUNE_MANIFEST);
  const hasKey = Boolean(process.env.META_API_KEY);
  const chosen = existsSync(CHOSEN) ? readFileSync(CHOSEN, 'utf8').trim() : '';
  const fixtures = loadFewShotFixtures();

  if (TUNE && heldOut.length > 0 && tune.length === 0) {
    console.log('Refusing --tune: tuning uses data/tune_pcam only, never eval_pcam.');
    process.exitCode = 1;
    return;
  }

  console.log(
    JSON.stringify(
      {
        plan: DEMO_MOSAICS
          ? 'Demo-mosaic false-positive check (seed labels only; not accuracy; not tuning)'
          : TUNE
            ? VARIANTS
              ? 'Tuning-set variants (upscale / effort / few-shot); never held-out'
              : 'Tuning set: compare prompt versions (never held-out)'
            : 'Held-out classify via Muse Spark 1.3 vision',
        smallSampleNote:
          'With fewer than 100 tiles per set these are small-sample estimates (Wilson 95% intervals).',
        promptVersionLive: PREREAD_PROMPT_VERSION,
        tileUpscaleLive: TILE_UPSCALE_FACTOR,
        tileEffortLive: TILE_REASONING_EFFORT,
        pcamRule: PREREAD_PCAM_LABEL_RULE.slice(0, 80) + '…',
        tilesPerRequest: PREREAD_TILES_PER_REQUEST,
        heldOutCount: heldOut.length,
        tuneManifestCount: tune.length,
        fewShotFixtures: fixtures.length,
        variantIds: VARIANTS ? variantGrid().map((v) => v.id) : null,
        variantFilter: VARIANT_FILTER,
        resume: RESUME,
        demoMosaics: DEMO_MOSAICS,
        chosenVersionFile: chosen || null,
        stageHint:
          !DEMO_MOSAICS && (tune.length === 0 || heldOut.length === 0)
            ? 'Run: npx ts-node scripts/stage-pcam.ts --fetch'
            : null,
        live: LIVE,
        tune: TUNE,
        variants: VARIANTS,
        hasKey,
        maxTileCalls: MAX_TILE_CALLS,
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

  if (DEMO_MOSAICS) {
    await runDemoMosaics(apiKey);
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

    if (VARIANTS) {
      const grid = variantGrid();
      const { examples, scored } = pickFewShotFromTune(tune);
      const fewShotBuffers = examples.map((e) => ({
        id: e.id,
        label: e.label,
        png: readFileSync(e.path),
      }));
      // Prefer committed fixtures when present (stable across runs).
      const fewShot =
        fixtures.length >= 4
          ? fixtures.map((f) => ({ id: f.id, label: f.label, png: f.png }))
          : fewShotBuffers;
      const scoredTiles = fixtures.length >= 4 ? tune : scored;
      const resume = loadResumeStore(OUT);
      const pending = grid.reduce((n, spec) => {
        if (!RESUME) return n + scoredTiles.length;
        return (
          n +
          scoredTiles.filter((s) => !resume.byKey[resumeKey(spec.id, s.id)]).length
        );
      }, 0);
      assertSpend(pending);
      const results: Metrics[] = [];
      for (const spec of grid) {
        const m = await scoreVariant(
          scoredTiles,
          spec,
          apiKey,
          spec.fewShot ? fewShot : [],
          resume,
        );
        printMetrics(m);
        results.push(m);
      }
      results.sort((a, b) => b.accuracy - a.accuracy || a.latencyMsPerTile - b.latencyMsPerTile);
      const winner = results[0];
      writeFileSync(CHOSEN, `${winner.variant}\n`);
      const report = {
        set: 'tune-variants',
        note: 'Quoted only from this run. Held-out tiles were not used for tuning.',
        model: MUSE_SPARK_MODEL,
        chosenVariant: winner.variant,
        byVariant: results,
        resume: resume.byKey,
      };
      writeFileSync(OUT, JSON.stringify(report, null, 2));
      console.log(JSON.stringify(report, null, 2));
      return;
    }

    // Legacy two-way: v2 vs live v4 instructions (no upscale in this path — use --variants).
    assertSpend(tune.length * 2);
    const v2Spec: VariantSpec = {
      id: 'v2_minimal',
      promptVersion: PREREAD_PROMPT_VERSION_V2,
      instructions: instructionsV2(),
      effort: 'minimal',
      upscale: 1,
      fewShot: false,
    };
    const liveSpec: VariantSpec = {
      id: 'live_v4_upscale3_minimal',
      promptVersion: PREREAD_PROMPT_VERSION,
      instructions: instructionsV3(),
      effort: TILE_REASONING_EFFORT,
      upscale: TILE_UPSCALE_FACTOR,
      fewShot: false,
    };
    const v2 = await scoreVariant(tune, v2Spec, apiKey, []);
    const live = await scoreVariant(tune, liveSpec, apiKey, []);
    printMetrics(v2);
    printMetrics(live);
    const winner = v2.accuracy > live.accuracy ? v2 : live;
    writeFileSync(CHOSEN, `${winner.variant}\n`);
    const report = {
      set: 'tune',
      note: 'Quoted only from this run. Held-out tiles were not used for tuning.',
      model: MUSE_SPARK_MODEL,
      chosenVariant: winner.variant,
      byPromptVersion: [v2, live],
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

  if (chosen && chosen !== PREREAD_PROMPT_VERSION && !chosen.startsWith('v3_') && !chosen.startsWith('live_')) {
    console.log(
      JSON.stringify({
        refused: true,
        reason: 'held-out is only printed after --tune records chosen-version.txt',
        chosen,
        livePrompt: PREREAD_PROMPT_VERSION,
      }),
    );
    process.exitCode = 1;
    return;
  }

  assertSpend(heldOut.length);
  const variantId = optionValue('--held-out-variant');
  if (variantId) {
    const spec = variantGrid().find((v) => v.id === variantId);
    if (!spec) {
      console.log(JSON.stringify({ refused: true, reason: 'unknown variant', variantId }));
      process.exitCode = 1;
      return;
    }
    assertSpend(heldOut.length);
    const scored = await scoreVariant(heldOut, spec, apiKey, spec.fewShot ? loadFewShotFixtures() : []);
    printMetrics(scored);
    const variantReport = {
      set: 'held-out',
      note: 'One variant, chosen on the tuning set beforehand, scored once here. The held-out tiles were also scored for the live configuration; they are not used to choose between variants.',
      model: MUSE_SPARK_MODEL,
      byVariant: [scored],
    };
    writeFileSync(HELD_OUT_VARIANT_OUT, JSON.stringify(variantReport, null, 2));
    console.log(JSON.stringify(variantReport, null, 2));
    return;
  }

  const heldSpec: VariantSpec = {
    id: 'held_live',
    promptVersion: PREREAD_PROMPT_VERSION,
    instructions: instructionsV3(),
    effort: TILE_REASONING_EFFORT,
    upscale: TILE_UPSCALE_FACTOR,
    fewShot: false,
  };
  const current = await scoreVariant(heldOut, heldSpec, apiKey, []);
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
