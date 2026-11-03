#!/usr/bin/env npx ts-node
// cspell:ignore muse Camelyon pcam aurent
/**
 * Stage PatchCamelyon tiles for eval / tune (bundle 60). Dry by default; `--fetch` writes.
 *
 * Source: Hugging Face datasets-server `first-rows` for `1aurent/PatchCamelyon` (CC0), same as
 * the seed. Only the first 100 rows of each split are reachable that way. Labels come from the
 * dataset (`true` → Tumour, `false` → Normal), never assumed. Seed mosaic sources in
 * `data/demo_slides/slides.json` are excluded.
 *
 * Usage:
 *   npx ts-node scripts/stage-pcam.ts
 *   npx ts-node scripts/stage-pcam.ts --fetch
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

import { decodeImage, encodePng } from '../src/preread-measure';

const FETCH = process.argv.includes('--fetch');
const ROOT = join(__dirname, '..');
const SLIDES = join(ROOT, 'data', 'demo_slides', 'slides.json');
const TUNE_DIR = join(ROOT, 'data', 'tune_pcam');
const EVAL_DIR = join(ROOT, 'data', 'eval_pcam');

const DATASET = '1aurent/PatchCamelyon';
/** HF split ids (seed uses train / valid / test). */
const SPLITS = ['train', 'valid', 'test'] as const;
type Split = (typeof SPLITS)[number];

const FIRST_ROWS = (split: Split): string =>
  `https://datasets-server.huggingface.co/first-rows?dataset=${encodeURIComponent(DATASET)}&config=default&split=${split}`;

interface ManifestRow {
  id: string;
  label: 'Tumour' | 'Normal';
  path: string;
  split: Split;
  row: number;
}

interface HfRow {
  row_idx: number;
  row: {
    label: boolean;
    image: { src: string; height?: number; width?: number };
  };
}

function seedSources(): Set<string> {
  const manifest = JSON.parse(readFileSync(SLIDES, 'utf8')) as {
    histology: { slides: Record<string, { tiles: { source: string }[] }> };
  };
  const used = new Set<string>();
  for (const slide of Object.values(manifest.histology.slides)) {
    for (const tile of slide.tiles) used.add(tile.source);
  }
  return used;
}

function sourceKey(split: Split, row: number): string {
  return `${split}/${row}`;
}

function labelOf(flag: boolean): 'Tumour' | 'Normal' {
  return flag ? 'Tumour' : 'Normal';
}

/** Cap each class to the minority count so the set stays balanced. */
function balance(rows: ManifestRow[]): ManifestRow[] {
  const tumour = rows.filter((r) => r.label === 'Tumour');
  const normal = rows.filter((r) => r.label === 'Normal');
  const cap = Math.min(tumour.length, normal.length);
  return [...tumour.slice(0, cap), ...normal.slice(0, cap)].sort(
    (a, b) => a.row - b.row || a.split.localeCompare(b.split),
  );
}

async function firstRows(split: Split): Promise<HfRow[]> {
  const response = await fetch(FIRST_ROWS(split));
  if (!response.ok) {
    throw new Error(`first-rows ${split} failed statusClass=${response.status >= 500 ? '5xx' : '4xx'}`);
  }
  const body = (await response.json()) as { rows?: HfRow[]; error?: string };
  if (body.error) throw new Error(`first-rows ${split}: ${body.error}`);
  return body.rows ?? [];
}

async function downloadPng(url: string, dest: string): Promise<void> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`image fetch failed statusClass=${response.status >= 500 ? '5xx' : '4xx'}`);
  }
  const bytes = Buffer.from(await response.arrayBuffer());
  // HF serves JPEG; write a real PNG so eval always decodes the same way as the worker.
  const png = encodePng(decodeImage(bytes));
  writeFileSync(dest, png);
}

function countByLabel(rows: ManifestRow[]): { Tumour: number; Normal: number; n: number } {
  let tumour = 0;
  let normal = 0;
  for (const r of rows) {
    if (r.label === 'Tumour') tumour += 1;
    else normal += 1;
  }
  return { Tumour: tumour, Normal: normal, n: rows.length };
}

async function main(): Promise<void> {
  const used = seedSources();
  const plan = {
    dataset: DATASET,
    splits: SPLITS,
    seedExcluded: used.size,
    fetch: FETCH,
    note: 'first-rows returns at most 100 rows per split; labels from the dataset bool field.',
    tuneDir: TUNE_DIR,
    evalDir: EVAL_DIR,
  };
  console.log(JSON.stringify(plan, null, 2));

  if (!FETCH) {
    console.log('Dry run only. Pass --fetch to download PNGs and write manifests.');
    return;
  }

  const bySplit: Record<Split, HfRow[]> = {
    train: [],
    valid: [],
    test: [],
  };
  for (const split of SPLITS) {
    bySplit[split] = await firstRows(split);
    console.log(JSON.stringify({ split, fetched: bySplit[split].length }, null, 2));
  }

  const eligible = (split: Split, destSplit: 'tune' | 'eval'): ManifestRow[] => {
    const out: ManifestRow[] = [];
    for (const item of bySplit[split]) {
      const row = item.row_idx;
      const key = sourceKey(split, row);
      if (used.has(key)) continue;
      const label = labelOf(Boolean(item.row.label));
      const id = `${split}-${row}`;
      const file = `${id}.png`;
      const dir = destSplit === 'tune' ? TUNE_DIR : EVAL_DIR;
      out.push({
        id,
        label,
        path: join(dir, file),
        split,
        row,
      });
    }
    return out;
  };

  const tuneRaw = eligible('train', 'tune');
  const evalRaw = eligible('test', 'eval');
  const tune = balance(tuneRaw);
  const evalSet = balance(evalRaw);

  mkdirSync(TUNE_DIR, { recursive: true });
  mkdirSync(EVAL_DIR, { recursive: true });

  const writeSet = async (rows: ManifestRow[], dir: string, name: string): Promise<void> => {
    for (const row of rows) {
      const hf = bySplit[row.split].find((r) => r.row_idx === row.row);
      if (!hf) throw new Error(`missing row ${row.split}/${row.row}`);
      const dest = join(dir, `${row.id}.png`);
      if (!existsSync(dest)) {
        await downloadPng(hf.row.image.src, dest);
      }
      row.path = dest;
    }
    const manifestPath = join(dir, 'manifest.json');
    writeFileSync(manifestPath, JSON.stringify(rows, null, 2));
    console.log(
      JSON.stringify(
        {
          set: name,
          eligibleBeforeBalance: name === 'tune' ? countByLabel(tuneRaw) : countByLabel(evalRaw),
          afterBalance: countByLabel(rows),
          manifest: manifestPath,
        },
        null,
        2,
      ),
    );
  };

  await writeSet(tune, TUNE_DIR, 'tune');
  await writeSet(evalSet, EVAL_DIR, 'eval');
  // `valid` is fetched so seed `valid/*` keys are checked against the same first-100 window; not written.
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : 'stage-pcam failed');
  process.exitCode = 1;
});
