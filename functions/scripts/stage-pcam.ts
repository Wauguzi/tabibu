#!/usr/bin/env npx ts-node
// cspell:ignore muse Camelyon pcam aurent
/**
 * Stage PatchCamelyon tiles for eval / tune (bundles 60, 69). Dry by default; `--fetch` writes.
 *
 * Source: Hugging Face datasets-server paged `/rows` (offset + length=100) at 20 fixed offsets
 * per split. Primary dataset is `1aurent/PatchCamelyon` (CC0, same as the seed). When that
 * dataset's viewer is down (`/rows` 5xx), fall back to `KE9037/PatchCamelyon` (same split
 * names and label order on the rows we checked). Labels come from the dataset `label` field.
 * Seed mosaic sources in `data/demo_slides/slides.json` are excluded. Tuning uses train+valid;
 * held-out uses test only. Target: >= 100 balanced tiles per set.
 *
 * Usage:
 *   npx ts-node scripts/stage-pcam.ts
 *   npx ts-node scripts/stage-pcam.ts --fetch
 */
import { createHash } from 'node:crypto';
import { mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

import { decodeImage, encodePng } from '../src/preread-measure';
import {
  PCAM_MIN_BALANCED,
  PCAM_MIN_LABEL_AGREEMENT,
  PCAM_PAGE_COUNT,
  PCAM_PAGE_LENGTH,
  PCAM_SPLIT_SIZES,
  assertDisjointSets,
  assertNoDuplicateHashes,
  countByLabel,
  labelAgreement,
  labelOf,
  pageOffsets,
  requireBalancedMinimum,
  spreadOrder,
  sourceKey,
  type PcamCandidate,
  type PcamSplit,
  type StagedManifestRow,
} from '../src/pcam-stage';

const FETCH = process.argv.includes('--fetch');
const ROOT = join(__dirname, '..');
const SLIDES = join(ROOT, 'data', 'demo_slides', 'slides.json');
const TUNE_DIR = join(ROOT, 'data', 'tune_pcam');
const EVAL_DIR = join(ROOT, 'data', 'eval_pcam');

/** Prefer the seed's dataset; fall back when `/rows` is refused (viewer off / 5xx). */
const DATASETS = ['1aurent/PatchCamelyon', 'KE9037/PatchCamelyon'] as const;

const SPLITS: PcamSplit[] = ['train', 'valid', 'test'];

interface HfRow {
  row_idx: number;
  row: {
    label: unknown;
    image: { src: string };
  };
}

interface RowsBody {
  rows?: HfRow[];
  error?: string;
  partial?: boolean;
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

function rowsUrl(dataset: string, split: PcamSplit, offset: number): string {
  const q = new URLSearchParams({
    dataset,
    config: 'default',
    split,
    offset: String(offset),
    length: String(PCAM_PAGE_LENGTH),
  });
  return `https://datasets-server.huggingface.co/rows?${q.toString()}`;
}

const MAX_RETRIES = 7;

/** Worth asking again: a dropped connection, rate limiting, or a server-side error. */
function isTransient(status: number): boolean {
  return status === 0 || status === 429 || status >= 500;
}

/** Asks again while the answer is transient, waiting longer each time; the same page every time. */
async function fetchRowsPageRetrying(
  dataset: string,
  split: PcamSplit,
  offset: number,
  retries: number,
): ReturnType<typeof fetchRowsPage> {
  let attempt = 0;
  let page = await fetchRowsPage(dataset, split, offset);
  while (isTransient(page.status) && attempt < retries) {
    attempt += 1;
    await sleep(Math.min(1500 * 2 ** attempt, 30_000));
    page = await fetchRowsPage(dataset, split, offset);
  }
  return page;
}

async function sleep(ms: number): Promise<void> {
  await new Promise((r) => setTimeout(r, ms));
}

async function fetchRowsPage(
  dataset: string,
  split: PcamSplit,
  offset: number,
): Promise<{ rows: HfRow[]; status: number; error?: string }> {
  let response: Response;
  try {
    response = await fetch(rowsUrl(dataset, split, offset));
  } catch {
    // A dropped connection is as transient as a 502.
    return { rows: [], status: 0, error: `rows ${split}@${offset}: network error` };
  }
  const status = response.status;
  let body: RowsBody = {};
  try {
    body = (await response.json()) as RowsBody;
  } catch {
    body = {};
  }
  if (!response.ok) {
    return {
      rows: [],
      status,
      error:
        typeof body.error === 'string'
          ? body.error
          : `rows ${split}@${offset} failed statusClass=${status >= 500 ? '5xx' : '4xx'}`,
    };
  }
  if (body.error) return { rows: [], status, error: body.error };
  return { rows: body.rows ?? [], status };
}

/**
 * A fallback is trusted only if it carries the same labels as the seed's own dataset on the same
 * rows. `first-rows` still serves the primary's first 100 train rows even with its viewer off.
 */
async function requireAgreesWithSeedDataset(fallbackRows: HfRow[]): Promise<void> {
  const url = `https://datasets-server.huggingface.co/first-rows?dataset=${encodeURIComponent(
    DATASETS[0],
  )}&config=default&split=train`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error('cannot check the fallback dataset against the seed dataset; refusing it');
  }
  const body = (await response.json()) as { rows?: HfRow[] };
  const toRows = (rows: HfRow[]): { row: number; label: 'Tumour' | 'Normal' }[] =>
    rows.map((r) => ({ row: r.row_idx, label: labelOf(r.row.label) }));
  const agreement = labelAgreement(toRows(body.rows ?? []), toRows(fallbackRows));
  console.log(JSON.stringify({ fallbackLabelAgreement: agreement }));
  if (agreement === null || agreement < PCAM_MIN_LABEL_AGREEMENT) {
    throw new Error(
      `the fallback dataset's labels do not match the seed dataset's (agreement ${String(agreement)}); refusing it`,
    );
  }
}

/** Probe `/rows` on each candidate dataset; return the first that answers on train@0. */
async function pickDataset(): Promise<{ dataset: string; revision: string }> {
  for (const dataset of DATASETS) {
    // The seed's own dataset is known to refuse (viewer off): two tries; the fallback gets more.
    const probe = await fetchRowsPageRetrying(dataset, 'train', 0, dataset === DATASETS[0] ? 2 : 5);
    if (probe.rows.length > 0 && dataset !== DATASETS[0]) {
      await requireAgreesWithSeedDataset(probe.rows);
    }
    if (probe.rows.length > 0) {
      // Hub API revision (best-effort; staging still records whatever we get).
      let revision = '';
      try {
        const info = await fetch(`https://huggingface.co/api/datasets/${dataset}`);
        if (info.ok) {
          const body = (await info.json()) as { sha?: string };
          revision = typeof body.sha === 'string' ? body.sha : '';
        }
      } catch {
        revision = '';
      }
      return { dataset, revision };
    }
    console.log(
      JSON.stringify({
        dataset,
        refused: true,
        status: probe.status,
        error: probe.error ?? 'empty rows',
      }),
    );
  }
  throw new Error(
    'every /rows probe refused; not writing a short or duplicated set. Last errors are above.',
  );
}

async function downloadPng(url: string, dest: string): Promise<void> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`image fetch failed statusClass=${response.status >= 500 ? '5xx' : '4xx'}`);
  }
  const bytes = Buffer.from(await response.arrayBuffer());
  const png = encodePng(decodeImage(bytes));
  writeFileSync(dest, png);
}

async function pageSplit(
  dataset: string,
  split: PcamSplit,
  used: Set<string>,
): Promise<{ candidates: PcamCandidate[]; offsets: number[] }> {
  const offsets = pageOffsets(PCAM_SPLIT_SIZES[split]);
  const candidates: PcamCandidate[] = [];
  const seen = new Set<number>();
  for (const offset of offsets) {
    // The dataset server answers 502 and 503 now and then: wait and ask again, then give up.
    const page = await fetchRowsPageRetrying(dataset, split, offset, MAX_RETRIES);
    if (page.error || page.rows.length === 0) {
      throw new Error(
        `rows refused for ${dataset} ${split}@${offset}: ${page.error ?? 'empty'} (status=${page.status})`,
      );
    }
    for (const item of page.rows) {
      const row = item.row_idx;
      if (seen.has(row)) continue;
      seen.add(row);
      const key = sourceKey(split, row);
      if (used.has(key)) continue;
      const src = item.row?.image?.src;
      if (typeof src !== 'string' || src.length === 0) continue;
      candidates.push({
        split,
        row,
        label: labelOf(item.row.label),
        imageSrc: src,
      });
    }
    await sleep(200);
  }
  return { candidates, offsets };
}

/** Tiles per class in a staged set: 100 of each, so 200 a set. */
const TARGET_PER_CLASS = 100;

async function stageSet(
  rows: PcamCandidate[],
  dir: string,
  name: 'tune' | 'eval',
  offsets: number[],
  dataset: string,
  revision: string,
  seen: Set<string>,
): Promise<StagedManifestRow[]> {
  // A set is staged from nothing: leftovers from an earlier run are not part of it.
  rmSync(dir, { recursive: true, force: true });
  mkdirSync(dir, { recursive: true });
  const out: StagedManifestRow[] = [];
  const hashes: string[] = [];
  let skipped = 0;
  for (const label of ['Tumour', 'Normal'] as const) {
    const pool = rows.filter((r) => r.label === label);
    let got = 0;
    for (const row of spreadOrder(pool, TARGET_PER_CLASS)) {
      if (got >= TARGET_PER_CLASS) break;
      const id = `${row.split}-${row.row}`;
      const dest = join(dir, `${id}.png`);
      await downloadPng(row.imageSrc, dest);
      await sleep(50);
      const hash = createHash('sha256').update(readFileSync(dest)).digest('hex');
      if (seen.has(hash)) {
        rmSync(dest, { force: true });
        skipped += 1;
        continue;
      }
      seen.add(hash);
      hashes.push(hash);
      got += 1;
      out.push({
        id,
        label: row.label,
        path: dest,
        split: row.split,
        row: row.row,
        dataset,
        datasetRevision: revision,
        offsets,
      });
    }
    if (got < TARGET_PER_CLASS) {
      throw new Error(
        `refused: only ${got} distinct ${label} tiles for the ${name} set (need ${TARGET_PER_CLASS}); not padding`,
      );
    }
  }
  assertNoDuplicateHashes(hashes);
  const manifestPath = join(dir, 'manifest.json');
  writeFileSync(
    manifestPath,
    JSON.stringify(
      {
        dataset,
        datasetRevision: revision,
        offsets,
        pageLength: PCAM_PAGE_LENGTH,
        pageCount: PCAM_PAGE_COUNT,
        rows: out,
      },
      null,
      2,
    ),
  );
  console.log(
    JSON.stringify(
      {
        set: name,
        eligibleBeforeBalance: countByLabel(rows),
        afterBalance: countByLabel(out),
        repeatedImagesSkipped: skipped,
        manifest: manifestPath,
        dataset,
        datasetRevision: revision || null,
      },
      null,
      2,
    ),
  );
  return out;
}

async function main(): Promise<void> {
  const used = seedSources();
  const offsetPlan = Object.fromEntries(
    SPLITS.map((s) => [s, pageOffsets(PCAM_SPLIT_SIZES[s])]),
  );
  const plan = {
    primaryDataset: DATASETS[0],
    fallbackDataset: DATASETS[1],
    splits: SPLITS,
    pageLength: PCAM_PAGE_LENGTH,
    pageCount: PCAM_PAGE_COUNT,
    offsets: offsetPlan,
    seedExcluded: used.size,
    minBalancedPerSet: PCAM_MIN_BALANCED,
    tuneFrom: ['train', 'valid'],
    heldOutFrom: ['test'],
    fetch: FETCH,
    note: 'Paged /rows at fixed offsets; labels from the dataset; never pad with duplicates.',
    tuneDir: TUNE_DIR,
    evalDir: EVAL_DIR,
  };
  console.log(JSON.stringify(plan, null, 2));

  if (!FETCH) {
    console.log('Dry run only. Pass --fetch to page /rows, download PNGs and write manifests.');
    return;
  }

  const { dataset, revision } = await pickDataset();
  console.log(JSON.stringify({ usingDataset: dataset, datasetRevision: revision || null }, null, 2));

  const train = await pageSplit(dataset, 'train', used);
  const valid = await pageSplit(dataset, 'valid', used);
  const test = await pageSplit(dataset, 'test', used);

  const tuneRaw = [...train.candidates, ...valid.candidates];
  const evalRaw = test.candidates;

  // Each class needs enough candidates before anything is downloaded.
  try {
    requireBalancedMinimum(tuneRaw);
    requireBalancedMinimum(evalRaw);
  } catch (e) {
    console.error(e instanceof Error ? e.message : 'balance refused');
    process.exitCode = 1;
    return;
  }

  // A tile whose bytes were already staged (in this set or the other) is skipped for the next one;
  // the dataset repeats blank background patches, which is the source's doing, not padding.
  const seenHashes = new Set<string>();
  let tuneStaged: StagedManifestRow[];
  let evalStaged: StagedManifestRow[];
  try {
    tuneStaged = await stageSet(tuneRaw, TUNE_DIR, 'tune', [...train.offsets, ...valid.offsets], dataset, revision, seenHashes);
    evalStaged = await stageSet(evalRaw, EVAL_DIR, 'eval', test.offsets, dataset, revision, seenHashes);
  } catch (e) {
    console.error(e instanceof Error ? e.message : 'staging refused');
    process.exitCode = 1;
    return;
  }
  assertDisjointSets(tuneStaged, evalStaged);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : 'stage-pcam failed');
  process.exitCode = 1;
});
