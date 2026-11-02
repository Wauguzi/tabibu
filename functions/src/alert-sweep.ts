/**
 * The alert sweep (07 §5.3, plan §3.5): the alert kinds `sweepCases` runs — the Immediate
 * reminder, expiry, stuck `Drafting` turned into the template draft, delivery resumes,
 * and the held-too-long page. 100 per kind per run, one transaction each, re-checked
 * inside.
 */
import { logger } from 'firebase-functions';

import {
  DRAFTING_STALE_MIN,
  HELD_NOTIFY_MIN,
  REMINDER_H,
  type AlertDeps,
} from './alert-deps';
import { loadAlertDraftRows, readAlertApprovers, settleLoadedRows } from './alert-detector';
import { deliverAlert } from './alert-delivery';
import { writeDraftTx } from './alert-drafts';
import { str } from './case-support';
import { timestamp } from './common';
import { buildQuery, queryById } from './queries';
import { planNotes, sendNotes, type NoteSpec } from './runtime-deps';

const SWEEP_LIMIT = 100;

export interface AlertSweepCounts {
  reminded: number;
  expired: number;
  drafted: number;
  resumed: number;
  held: number;
  failed: number;
}

function num(value: unknown): number {
  return typeof value === 'number' ? value : 0;
}

function approverSpecs(
  approvers: { uid: string; language: 'en' | 'sw' }[],
  template: string,
  resourceKey: string,
  alertUid: string,
): NoteSpec[] {
  return approvers.map((approver): NoteSpec => ({
    template,
    resourceKey,
    threadUid: alertUid,
    resourceUid: alertUid,
    recipientUid: approver.uid,
    recipientRole: 'admin',
    language: approver.language,
    deepLink: `/alerts/${alertUid}/review`,
  }));
}

/**
 * Runs the alert kinds for `sweepCases` to call. Each candidate re-checks in its own
 * transaction; a candidate that moved on is skipped, never forced.
 */
export async function runAlertSweep(deps: AlertDeps, now: Date): Promise<AlertSweepCounts> {
  const counts: AlertSweepCounts = { reminded: 0, expired: 0, drafted: 0, resumed: 0, held: 0, failed: 0 };
  counts.reminded = await reminderSweep(deps, now);
  counts.expired = await expirySweep(deps, now);
  counts.drafted = await stuckDraftingSweep(deps, now);
  const resumed = await resumeSweep(deps, now);
  counts.resumed = resumed.resumed;
  counts.failed = resumed.failed;
  counts.held = await heldSweep(deps, now);
  return counts;
}

/** An `Immediate` draft un-decided after 1 h pages its approvers once (row 36, High). */
async function reminderSweep(deps: AlertDeps, now: Date): Promise<number> {
  const { db } = deps;
  const at = timestamp(now);
  const bound = timestamp(new Date(now.getTime() - REMINDER_H * 60 * 60 * 1000));
  const snap = await buildQuery(db, queryById('alerts.reminderSweep'), ['Draft', 'Immediate', bound])
    .limit(SWEEP_LIMIT)
    .get();
  let reminded = 0;
  for (const doc of snap.docs) {
    const done = await db.runTransaction(async (tx) => {
      const alert = (await tx.get(doc.ref)).data();
      if (
        !alert || str(alert.status) !== 'Draft' || str(alert.category) !== 'Immediate' ||
        str(alert.reminderSentAt) !== '' || str(alert.draftedAt) === '' || str(alert.draftedAt) > bound
      ) {
        return false;
      }
      const approvers = await readAlertApprovers(tx, db);
      const notes = await planNotes(
        tx,
        db,
        approverSpecs(approvers, 'alertDraftReminder', `${doc.id}-r${num(alert.requestCount)}`, doc.id),
      );
      tx.update(doc.ref, { reminderSentAt: at, lastUpdatedAt: at });
      sendNotes(tx, notes, now);
      return true;
    });
    if (done) reminded++;
  }
  return reminded;
}

/** A draft past `expiresAt` becomes `Expired`, its rows settled, its approvers told. */
async function expirySweep(deps: AlertDeps, now: Date): Promise<number> {
  const { db } = deps;
  const at = timestamp(now);
  const snap = await buildQuery(db, queryById('alerts.expirySweep'), ['Draft', at])
    .limit(SWEEP_LIMIT)
    .get();
  let expired = 0;
  for (const doc of snap.docs) {
    const done = await db.runTransaction(async (tx) => {
      const alert = (await tx.get(doc.ref)).data();
      if (!alert || str(alert.status) !== 'Draft' || str(alert.expiresAt) === '' || str(alert.expiresAt) > at) {
        return false;
      }
      const rows = await loadAlertDraftRows(tx, db, doc.id);
      const approvers = await readAlertApprovers(tx, db);
      const notes = await planNotes(
        tx,
        db,
        approverSpecs(approvers, 'alertExpired', `${doc.id}-r${num(alert.requestCount)}`, doc.id),
      );
      tx.update(doc.ref, { status: 'Expired', lastUpdatedAt: at });
      settleLoadedRows(tx, rows, 'Expired', '', now);
      sendNotes(tx, notes, now);
      return true;
    });
    if (done) expired++;
  }
  return expired;
}

/** `Drafting` older than 5 min gets the template draft through step 6's transaction. */
async function stuckDraftingSweep(deps: AlertDeps, now: Date): Promise<number> {
  const { db } = deps;
  const staleAfter = new Date(now.getTime() - DRAFTING_STALE_MIN * 60 * 1000);
  const snap = await buildQuery(
    db,
    queryById('alerts.stuckDrafting'),
    ['Drafting', timestamp(staleAfter)],
  )
    .limit(SWEEP_LIMIT)
    .get();
  let drafted = 0;
  for (const doc of snap.docs) {
    const outcome = await db.runTransaction((tx) =>
      writeDraftTx(
        tx,
        db,
        doc.id,
        num(doc.get('requestCount')),
        { models: {}, draftSource: 'Template', failureReason: 'Stale' },
        now,
        staleAfter,
      ),
    );
    if (outcome !== 'dropped') drafted++;
  }
  return drafted;
}

/** Resumes `Held`, `Waiting` and stalled deliveries, oldest first per phase. */
async function resumeSweep(deps: AlertDeps, now: Date): Promise<{ resumed: number; failed: number }> {
  const { db } = deps;
  const at = timestamp(now);
  const stalled = timestamp(new Date(now.getTime() - 2 * 60 * 1000));
  const candidates: string[] = [];
  for (const [phase, bound] of [
    ['Held', at],
    ['Waiting', at],
    ['Pending', stalled],
    ['Clinicians', stalled],
    ['Patients', stalled],
  ] as const) {
    if (candidates.length >= SWEEP_LIMIT) break;
    const snap = await buildQuery(db, queryById('alertDeliveries.byPhaseRecency'), [phase, bound])
      .limit(SWEEP_LIMIT - candidates.length)
      .get();
    for (const doc of snap.docs) {
      if (!candidates.includes(doc.id)) candidates.push(doc.id);
    }
  }
  let resumed = 0;
  let failed = 0;
  for (const alertUid of candidates) {
    try {
      await deliverAlert(deps, alertUid);
      resumed++;
    } catch {
      // One poisoned delivery must not starve the rest of the sweep. Counts only: a
      // job id is an alert id, and those never reach the logs.
      failed++;
    }
  }
  if (failed > 0) logger.error('resumeSweep: deliveries failed', { resumed, failed });
  return { resumed, failed };
}

/** `Held` for more than 15 min pages the approvers once (row 43, High). */
async function heldSweep(deps: AlertDeps, now: Date): Promise<number> {
  const { db } = deps;
  const bound = timestamp(new Date(now.getTime() - HELD_NOTIFY_MIN * 60 * 1000));
  const snap = await buildQuery(db, queryById('alertDeliveries.byPhaseRecency'), ['Held', bound])
    .limit(SWEEP_LIMIT)
    .get();
  let held = 0;
  for (const doc of snap.docs) {
    const done = await db.runTransaction(async (tx) => {
      const delivery = (await tx.get(doc.ref)).data();
      if (!delivery || str(delivery.phase) !== 'Held' || str(delivery.lastUpdatedAt) > bound) {
        return false;
      }
      const approvers = await readAlertApprovers(tx, db);
      const notes = await planNotes(tx, db, approverSpecs(approvers, 'alertDeliveryHeld', doc.id, doc.id));
      sendNotes(tx, notes, now);
      return notes.some((n) => !n.loaded.exists);
    });
    if (done) held++;
  }
  return held;
}
