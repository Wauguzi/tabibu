/**
 * Participant and reader sets, always recomputed from their sources (F-5).
 */
import type {
  DocumentData,
  DocumentReference,
  Transaction,
} from 'firebase-admin/firestore';

import { refuse, timestamp } from './common';
import type { CaseState } from './orchestrator';

function dedupe(uids: string[]): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const uid of uids) {
    if (!uid || seen.has(uid)) continue;
    seen.add(uid);
    out.push(uid);
  }
  return out;
}

/** Every person who may read the case document. */
export function participants(s: CaseState): string[] {
  return dedupe([
    s.doctorUid,
    s.patientUid,
    s.requestedPathologistUid,
    s.pathologistUid,
    ...s.viewerUids,
  ]);
}

export interface ReportVersionAccess {
  uid: string;
  pathologistUid: string;
  readerUids: string[];
  releasedToPatient: boolean;
  doctorOpenedAt?: string;
  ref: DocumentReference;
}

/** Who may read one signed report version. */
export function readersFor(s: CaseState, v: ReportVersionAccess): string[] {
  const set = new Set<string>();
  if (v.pathologistUid) set.add(v.pathologistUid);
  if (s.doctorUid && v.readerUids.includes(s.doctorUid)) set.add(s.doctorUid);
  if (v.releasedToPatient) {
    if (s.patientUid) set.add(s.patientUid);
    for (const uid of s.viewerUids) if (uid) set.add(uid);
  }
  return [...set];
}

function sameSet(a: string[], b: string[]): boolean {
  const left = new Set(a);
  const right = new Set(b);
  if (left.size !== right.size) return false;
  for (const x of left) if (!right.has(x)) return false;
  return true;
}

/** Rewrite readerUids on every version whose set changed. */
export function syncCaseReaders(
  tx: Transaction,
  s: CaseState,
  versions: ReportVersionAccess[],
  now: Date,
): void {
  const at = timestamp(now);
  for (const v of versions) {
    const next = readersFor(s, v);
    if (sameSet(next, v.readerUids)) continue;
    tx.update(v.ref, { readerUids: next, lastUpdatedAt: at } satisfies DocumentData);
  }
}

/**
 * Unlock every version for the ordering doctor. Stamps doctorOpenedAt once.
 */
export function unlockReport(
  tx: Transaction,
  s: CaseState,
  versions: ReportVersionAccess[],
  doctorUid: string,
  now: Date,
): void {
  if (doctorUid !== s.doctorUid) throw refuse('permission-denied', 'notDoctor');
  const at = timestamp(now);
  for (const v of versions) {
    const withDoctor: ReportVersionAccess = {
      ...v,
      readerUids: [...new Set([...v.readerUids, doctorUid])],
    };
    const next = readersFor(s, withDoctor);
    const stampOpen = !v.doctorOpenedAt;
    if (sameSet(next, v.readerUids) && !stampOpen) continue;
    const patch: DocumentData = { readerUids: next, lastUpdatedAt: at };
    if (stampOpen) patch.doctorOpenedAt = at;
    tx.update(v.ref, patch);
  }
}
