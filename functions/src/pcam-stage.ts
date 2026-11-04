/**
 * Pure helpers for staging PatchCamelyon tune/eval sets (bundle 69). Scripts call these;
 * tests assert offsets, balance and the refuse-when-short rule without hitting the network.
 */
export const PCAM_PAGE_LENGTH = 100;
/** Fixed number of pages per split; evenly spaced so a re-run stages the same tiles. */
export const PCAM_PAGE_COUNT = 20;
export const PCAM_MIN_BALANCED = 100;

export const PCAM_SPLIT_SIZES = {
  train: 262_144,
  valid: 32_768,
  test: 32_768,
} as const;

export type PcamSplit = keyof typeof PCAM_SPLIT_SIZES;

export interface PcamCandidate {
  split: PcamSplit;
  row: number;
  label: 'Tumour' | 'Normal';
  imageSrc: string;
}

export interface StagedManifestRow {
  id: string;
  label: 'Tumour' | 'Normal';
  path: string;
  split: PcamSplit;
  row: number;
  dataset: string;
  datasetRevision: string;
  offsets: number[];
}

/** Evenly spaced page starts in `[0, numRows - pageLength]`, length `pageCount`, fixed for a re-run. */
export function pageOffsets(
  numRows: number,
  pageLength = PCAM_PAGE_LENGTH,
  pageCount = PCAM_PAGE_COUNT,
): number[] {
  if (numRows < pageLength) {
    throw new Error(`split too small for a page of ${pageLength} (numRows=${numRows})`);
  }
  if (pageCount < 1) throw new Error('pageCount must be >= 1');
  const maxStart = numRows - pageLength;
  if (pageCount === 1) return [0];
  const out: number[] = [];
  for (let i = 0; i < pageCount; i++) {
    out.push(Math.floor((i * maxStart) / (pageCount - 1)));
  }
  return out;
}

export function offsetsAreSpread(offsets: number[], numRows: number, pageLength = PCAM_PAGE_LENGTH): boolean {
  if (offsets.length < 2) return offsets.length === 1;
  const maxStart = numRows - pageLength;
  if (offsets[0] !== 0) return false;
  if (offsets[offsets.length - 1] !== maxStart) return false;
  for (let i = 1; i < offsets.length; i++) {
    if (offsets[i] <= offsets[i - 1]) return false;
  }
  return true;
}

export function labelOf(raw: unknown): 'Tumour' | 'Normal' {
  if (raw === true || raw === 1 || raw === '1' || raw === 'true') return 'Tumour';
  if (raw === false || raw === 0 || raw === '0' || raw === 'false') return 'Normal';
  throw new Error('unrecognised PatchCamelyon label');
}

/** Cap each class to the minority count so the set stays balanced. */
export function balanceExact<T extends { label: 'Tumour' | 'Normal' }>(rows: T[]): T[] {
  const tumour = rows.filter((r) => r.label === 'Tumour');
  const normal = rows.filter((r) => r.label === 'Normal');
  const cap = Math.min(tumour.length, normal.length);
  return [...tumour.slice(0, cap), ...normal.slice(0, cap)].sort((a, b) => {
    const as = 'split' in a ? String((a as { split?: string }).split ?? '') : '';
    const bs = 'split' in b ? String((b as { split?: string }).split ?? '') : '';
    const ar = 'row' in a ? Number((a as { row?: number }).row ?? 0) : 0;
    const br = 'row' in b ? Number((b as { row?: number }).row ?? 0) : 0;
    return as.localeCompare(bs) || ar - br;
  });
}

export function countByLabel(rows: { label: 'Tumour' | 'Normal' }[]): {
  Tumour: number;
  Normal: number;
  n: number;
} {
  let tumour = 0;
  let normal = 0;
  for (const r of rows) {
    if (r.label === 'Tumour') tumour += 1;
    else normal += 1;
  }
  return { Tumour: tumour, Normal: normal, n: rows.length };
}

/**
 * Refuse when a balanced set would be shorter than `minTotal` (half Tumour, half Normal).
 * Never pad with duplicates.
 */
export function requireBalancedMinimum<T extends { label: 'Tumour' | 'Normal' }>(
  rows: T[],
  minTotal = PCAM_MIN_BALANCED,
): T[] {
  const balanced = balanceExact(rows);
  const counts = countByLabel(balanced);
  if (counts.n < minTotal || counts.Tumour !== counts.Normal) {
    throw new Error(
      `refused: need >= ${minTotal} balanced tiles (half each class); got Tumour=${counts.Tumour} Normal=${counts.Normal} n=${counts.n}`,
    );
  }
  return balanced;
}

export function sourceKey(split: string, row: number): string {
  return `${split}/${row}`;
}

/** Held-out must not share a (split,row) with tuning. */
export function assertDisjointSets(
  tune: { split: string; row: number }[],
  heldOut: { split: string; row: number }[],
): void {
  const keys = new Set(tune.map((r) => sourceKey(r.split, r.row)));
  for (const r of heldOut) {
    const key = sourceKey(r.split, r.row);
    if (keys.has(key)) throw new Error(`tune/held-out overlap at ${key}`);
  }
  for (const r of tune) {
    if (r.split === 'test') throw new Error('tuning must not use the test split');
  }
  for (const r of heldOut) {
    if (r.split !== 'test') throw new Error('held-out must come only from the test split');
  }
}

/** Content-hash disjointness for staged PNG bytes (bundle 69 test). */
export function assertNoDuplicateHashes(hashes: string[]): void {
  const seen = new Set<string>();
  for (const h of hashes) {
    if (seen.has(h)) throw new Error(`duplicate tile hash ${h.slice(0, 12)}`);
    seen.add(h);
  }
}

/** A fallback copy must agree with the seed's own dataset on at least this share of rows. */
export const PCAM_MIN_LABEL_AGREEMENT = 0.98;

/**
 * Share of rows, matched by row index, on which two copies of the dataset carry the same label.
 * A mirror with inverted or shifted rows would silently ruin an evaluation, so a fallback is used
 * only when this is high on the rows both copies serve. Returns null when too few rows overlap
 * to say.
 */
export function labelAgreement(
  primary: { row: number; label: 'Tumour' | 'Normal' }[],
  fallback: { row: number; label: 'Tumour' | 'Normal' }[],
  minOverlap = 50,
): number | null {
  const byRow = new Map(primary.map((r) => [r.row, r.label]));
  let overlap = 0;
  let same = 0;
  for (const r of fallback) {
    const other = byRow.get(r.row);
    if (other === undefined) continue;
    overlap += 1;
    if (other === r.label) same += 1;
  }
  return overlap < minOverlap ? null : same / overlap;
}

/** Candidates in the order to try them: evenly spaced through the pool first, then the rest. */
export function spreadOrder<T>(pool: T[], want: number): T[] {
  const step = pool.length / want;
  const first = new Set<number>();
  for (let i = 0; i < want && step >= 1; i++) first.add(Math.floor(i * step));
  const order = [...first].sort((a, b) => a - b);
  for (let i = 0; i < pool.length; i++) if (!first.has(i)) order.push(i);
  return order.map((i) => pool[i]);
}
