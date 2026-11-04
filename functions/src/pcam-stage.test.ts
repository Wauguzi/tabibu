import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';

import {
  PCAM_MIN_BALANCED,
  PCAM_PAGE_COUNT,
  PCAM_PAGE_LENGTH,
  PCAM_SPLIT_SIZES,
  assertDisjointSets,
  assertNoDuplicateHashes,
  balanceExact,
  PCAM_MIN_LABEL_AGREEMENT,
  labelAgreement,
  labelOf,
  offsetsAreSpread,
  pageOffsets,
  requireBalancedMinimum,
  spreadOrder,
  sourceKey,
} from './pcam-stage';

describe('pcam-stage (bundle 69)', () => {
  it('page offsets are fixed, length 20, and spread across each split', () => {
    for (const split of ['train', 'valid', 'test'] as const) {
      const offsets = pageOffsets(PCAM_SPLIT_SIZES[split]);
      assert.equal(offsets.length, PCAM_PAGE_COUNT);
      assert.deepEqual(offsets, pageOffsets(PCAM_SPLIT_SIZES[split]));
      assert.ok(offsetsAreSpread(offsets, PCAM_SPLIT_SIZES[split], PCAM_PAGE_LENGTH));
      assert.equal(offsets[0], 0);
      assert.equal(offsets[offsets.length - 1], PCAM_SPLIT_SIZES[split] - PCAM_PAGE_LENGTH);
    }
  });

  it('balanceExact is half Tumour and half Normal', () => {
    const rows = [
      { id: 'a', label: 'Tumour' as const },
      { id: 'b', label: 'Tumour' as const },
      { id: 'c', label: 'Tumour' as const },
      { id: 'd', label: 'Normal' as const },
      { id: 'e', label: 'Normal' as const },
    ];
    const balanced = balanceExact(rows);
    assert.equal(balanced.length, 4);
    assert.equal(balanced.filter((r) => r.label === 'Tumour').length, 2);
    assert.equal(balanced.filter((r) => r.label === 'Normal').length, 2);
  });

  it('refuses a class that cannot fill the minimum', () => {
    const short = Array.from({ length: 40 }, (_, i) => ({
      label: (i % 2 === 0 ? 'Tumour' : 'Normal') as 'Tumour' | 'Normal',
    }));
    assert.throws(() => requireBalancedMinimum(short, PCAM_MIN_BALANCED), /refused/);
    const enough = Array.from({ length: PCAM_MIN_BALANCED }, (_, i) => ({
      label: (i < PCAM_MIN_BALANCED / 2 ? 'Tumour' : 'Normal') as 'Tumour' | 'Normal',
      split: 'train' as const,
      row: i,
    }));
    const ok = requireBalancedMinimum(enough);
    assert.equal(ok.length, PCAM_MIN_BALANCED);
  });

  it('tuning and held-out stay on different splits with no overlapping keys', () => {
    const tune = [
      { split: 'train', row: 1 },
      { split: 'valid', row: 2 },
    ];
    const held = [
      { split: 'test', row: 1 },
      { split: 'test', row: 3 },
    ];
    assert.doesNotThrow(() => assertDisjointSets(tune, held));
    assert.throws(() => assertDisjointSets(tune, [{ split: 'train', row: 1 }]), /overlap/);
    assert.throws(() => assertDisjointSets([{ split: 'test', row: 9 }], held), /test split/);
  });

  it('duplicate content hashes are refused', () => {
    const a = createHash('sha256').update('tile-a').digest('hex');
    const b = createHash('sha256').update('tile-b').digest('hex');
    assert.doesNotThrow(() => assertNoDuplicateHashes([a, b]));
    assert.throws(() => assertNoDuplicateHashes([a, a]), /duplicate/);
  });

  it('labelOf reads the dataset bool/int without guessing', () => {
    assert.equal(labelOf(true), 'Tumour');
    assert.equal(labelOf(false), 'Normal');
    assert.equal(labelOf(1), 'Tumour');
    assert.equal(labelOf(0), 'Normal');
    assert.throws(() => labelOf('maybe'));
  });

  it('sourceKey matches the seed mosaic exclusion format', () => {
    assert.equal(sourceKey('train', 99), 'train/99');
    assert.equal(sourceKey('valid', 58), 'valid/58');
  });

  it('a fallback copy is trusted only when its labels match the seed dataset row for row', () => {
    const rows = (flip: number): { row: number; label: 'Tumour' | 'Normal' }[] =>
      Array.from({ length: 100 }, (_, i) => ({
        row: i,
        label: (i % 2 === 0) !== (i < flip) ? 'Tumour' : 'Normal',
      }));
    const primary = rows(0);
    assert.equal(labelAgreement(primary, rows(0)), 1);
    assert.ok((labelAgreement(primary, rows(0)) as number) >= PCAM_MIN_LABEL_AGREEMENT);
    // Labels inverted on every row: agreement 0, so it is refused.
    const inverted = primary.map((r) => ({
      row: r.row,
      label: r.label === 'Tumour' ? ('Normal' as const) : ('Tumour' as const),
    }));
    assert.equal(labelAgreement(primary, inverted), 0);
    // Shifted by one row: about half agree, so it is refused.
    const shifted = primary.map((r) => ({ row: r.row + 1, label: r.label }));
    assert.ok((labelAgreement(primary, shifted) as number) < PCAM_MIN_LABEL_AGREEMENT);
    // Too little overlap to say.
    assert.equal(labelAgreement(primary.slice(0, 10), inverted.slice(0, 10)), null);
  });

  it('tries candidates spread through the pool first, then the rest, each once', () => {
    const pool = Array.from({ length: 10 }, (_, i) => i);
    const order = spreadOrder(pool, 5);
    assert.deepEqual(order.slice(0, 5), [0, 2, 4, 6, 8]);
    assert.deepEqual([...order].sort((a, b) => a - b), pool);
    assert.deepEqual(spreadOrder(pool, 5), order);
    // A pool no bigger than the want is simply taken in order.
    assert.deepEqual(spreadOrder([7, 8, 9], 5), [7, 8, 9]);
  });
});
