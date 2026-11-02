/**
 * Edge counters: count a fact once via `counterMarks/{counter}:{resourceUid}`.
 * Load half first; write half is synchronous (R-3).
 */
import {
  FieldValue,
  Timestamp,
  type DocumentReference,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';

import { timestamp } from './common';

const MARK_TTL_MS = 30 * 24 * 60 * 60 * 1000;

export interface MarkSpec {
  counter: string;
  resourceUid: string;
}

export interface LoadedMark {
  counter: string;
  resourceUid: string;
  ref: DocumentReference;
  exists: boolean;
}

export interface CountTarget extends MarkSpec {
  targetRef: DocumentReference;
  field: string;
}

/** Read every mark before any write in the transaction. */
export async function loadMarks(
  tx: Transaction,
  db: Firestore,
  specs: MarkSpec[],
): Promise<LoadedMark[]> {
  const out: LoadedMark[] = [];
  for (const spec of specs) {
    const ref = db.collection('counterMarks').doc(`${spec.counter}:${spec.resourceUid}`);
    const snap = await tx.get(ref);
    out.push({
      counter: spec.counter,
      resourceUid: spec.resourceUid,
      ref,
      exists: snap.exists,
    });
  }
  return out;
}

/**
 * Apply increments for marks that do not yet exist. [loaded] must come from
 * [loadMarks] earlier in the same transaction.
 */
export function applyCounts(
  tx: Transaction,
  loaded: LoadedMark[],
  targets: CountTarget[],
  now: Date,
): void {
  const at = timestamp(now);
  const expireAt = Timestamp.fromMillis(now.getTime() + MARK_TTL_MS);
  for (const target of targets) {
    const mark = loaded.find(
      (m) => m.counter === target.counter && m.resourceUid === target.resourceUid,
    );
    if (!mark) throw new Error(`count mark not loaded: ${target.counter}:${target.resourceUid}`);
    if (mark.exists) continue;
    tx.create(mark.ref, {
      counter: target.counter,
      resourceUid: target.resourceUid,
      at,
      expireAt,
      lastUpdatedAt: at,
    });
    tx.set(
      target.targetRef,
      { [target.field]: FieldValue.increment(1), lastUpdatedAt: at },
      { merge: true },
    );
    mark.exists = true;
  }
}
