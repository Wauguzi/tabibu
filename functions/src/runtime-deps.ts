/**
 * What the appointment, conversation, push and staff handlers share: their dependencies, a notice
 * planner that is not tied to a case, and the small text helpers. Nothing here is a callable.
 */
import {
  Timestamp,
  type DocumentReference,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';
import type { Storage } from 'firebase-admin/storage';
import { getStorage } from 'firebase-admin/storage';

import type { DomainAiClient } from './ai-domain';
import type { AuthLike } from './common';
import type { ConfigReader } from './config';
import { NotificationTx, type LoadedNotification, type NotifyLanguage } from './notifications';

/** The part of the Admin Auth SDK the staff callables use, narrowed so a test sees every call. */
export interface StaffAuthLike extends AuthLike {
  revokeRefreshTokens(uid: string): Promise<void>;
}

export interface PushMessage {
  tokens: string[];
  notification?: { title?: string; body: string };
  data: Record<string, string>;
  android?: Record<string, unknown>;
  apns?: Record<string, unknown>;
}

export interface PushResult {
  responses: { success: boolean; error?: { code?: string } }[];
}

/** `getMessaging()` satisfies it; a test fakes it. */
export interface MessagingLike {
  sendEachForMulticast(message: PushMessage): Promise<PushResult>;
}

export type StorageLike = Pick<Storage, 'bucket'>;

export interface RuntimeDeps {
  db: Firestore;
  auth?: StaffAuthLike;
  bucket: string;
  now?: () => Date;
  config?: ConfigReader;
  ai?: DomainAiClient;
  messaging?: MessagingLike;
  storage?: StorageLike;
}

export function nowOf(deps: { now?: () => Date }): Date {
  return (deps.now ?? (() => new Date()))();
}

export function storageOf(deps: RuntimeDeps): StorageLike {
  return deps.storage ?? getStorage();
}

export const MINUTE_MS = 60_000;
export const HOUR_MS = 60 * MINUTE_MS;
export const DAY_MS = 24 * HOUR_MS;

/** A TTL timestamp for a server-only bookkeeping document. */
export function ttlAt(now: Date, ms = 30 * DAY_MS): Timestamp {
  return Timestamp.fromMillis(now.getTime() + ms);
}

export interface NoteSpec {
  template: string;
  resourceKey: string;
  threadUid: string;
  resourceUid: string;
  recipientUid: string;
  recipientRole: string;
  language: NotifyLanguage;
  expiresAt?: string;
  deepLink: string;
  initiatorUid?: string;
  initiatorRole?: string;
  templateArgs?: Record<string, string>;
  /** Raise only when the template is `raisable` (a critical report). */
  priority?: 'Normal' | 'High';
}

export interface PlannedNote {
  loaded: LoadedNotification;
  spec: NoteSpec;
}

/** Read half: load every row this step will create or settle. Empty recipients are skipped. */
export async function planNotes(
  tx: Transaction,
  db: Firestore,
  specs: (NoteSpec | null)[],
): Promise<PlannedNote[]> {
  const out: PlannedNote[] = [];
  for (const spec of specs) {
    if (!spec || !spec.recipientUid) continue;
    out.push({
      loaded: await NotificationTx.load(tx, db, spec.template, spec.resourceKey, spec.recipientUid),
      spec,
    });
  }
  return out;
}

export function sendNotes(tx: Transaction, notes: PlannedNote[], now: Date): void {
  for (const { loaded, spec } of notes) {
    NotificationTx.create(
      tx,
      loaded,
      {
        template: spec.template,
        resourceKey: spec.resourceKey,
        resourceUid: spec.resourceUid,
        threadUid: spec.threadUid,
        recipientUid: spec.recipientUid,
        recipientRole: spec.recipientRole,
        initiatorUid: spec.initiatorUid,
        initiatorRole: spec.initiatorRole,
        language: spec.language,
        expiresAt: spec.expiresAt,
        deepLink: spec.deepLink,
        templateArgs: spec.templateArgs,
        priority: spec.priority,
      },
      now,
    );
  }
}

/** Reads one row by its deterministic id so a later step can settle it inside the transaction. */
export function loadRow(
  tx: Transaction,
  db: Firestore,
  template: string,
  resourceKey: string,
  recipientUid: string,
): Promise<LoadedNotification> {
  return NotificationTx.load(tx, db, template, resourceKey, recipientUid);
}

/** Levenshtein distance over code points, as a share of the longer text: 0 = identical. */
export function editDistance(a: string, b: string): number {
  const left = [...a];
  const right = [...b];
  if (left.length === 0 && right.length === 0) return 0;
  let prev = Array.from({ length: right.length + 1 }, (_, i) => i);
  for (let i = 1; i <= left.length; i++) {
    const row = [i];
    for (let j = 1; j <= right.length; j++) {
      const cost = left[i - 1] === right[j - 1] ? 0 : 1;
      row[j] = Math.min(prev[j] + 1, row[j - 1] + 1, prev[j - 1] + cost);
    }
    prev = row;
  }
  return prev[right.length] / Math.max(left.length, right.length);
}

/** A counter document whose count is read now and written later in the same transaction. */
export interface RateWindow {
  ref: DocumentReference;
  count: number;
}

export async function loadRate(tx: Transaction, db: Firestore, key: string): Promise<RateWindow> {
  const ref = db.collection('rateCounters').doc(key);
  const snap = await tx.get(ref);
  const count = snap.get('count');
  return { ref, count: typeof count === 'number' ? count : 0 };
}

export function writeRate(tx: Transaction, window: RateWindow, now: Date): void {
  tx.set(window.ref, {
    count: window.count + 1,
    expireAt: ttlAt(now),
    lastUpdatedAt: now.toISOString(),
  });
}
