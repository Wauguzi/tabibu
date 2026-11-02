// cspell:ignore unmanual
/**
 * The detector (07 §3.2, plan §3.5): every notifiable-event write runs one transaction that
 * counts its edges once (marks), re-evaluates Rules A/B/M, and reconciles the signal and
 * the alert. Edges come from the stored event plus the marks, never the payload, so arrival
 * order does not matter; retries find every mark taken. Ineligible diseases are counted,
 * never broadcast.
 */
import {
  FieldValue,
  type DocumentData,
  type DocumentSnapshot,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';

import {
  DETECTOR_CONFIG,
  baselineStats,
  detect,
  diseaseMetaById,
  epiWeeksBack,
  weekStartOf,
} from './alert-data';
import type { AlertDeps } from './alert-deps';
import { str } from './case-support';
import { timestamp } from './common';
import { loadMarks } from './counters';
import { diseaseById } from './disease-data';
import { NotificationTx, type LoadedNotification } from './notifications';
import { buildQuery, queryById } from './queries';
import { countyById } from './reference-data';
import { planNotes, sendNotes, type NoteSpec } from './runtime-deps';

export type DetectorOutcome =
  | 'deleted'
  | 'ignored'
  | 'counted'
  | 'created'
  | 'updated'
  | 'unchanged'
  | 'revived'
  | 'withdrawn';

export interface DetectorEvent {
  before: DocumentData | undefined;
  after: DocumentData | undefined;
}

function epiKey(diseaseId: string, countyId: number, week: string): string {
  return `${diseaseId}_${countyId}_${week}`;
}

/** The dedupe key: one disease, county and week produce one signal and one alert. */
export function signalUidFor(diseaseId: string, countyId: number, week: string): string {
  return `${diseaseId}_${countyId}_${week}`;
}

/** Every approver in the registry, with their push language. */
export async function readAlertApprovers(
  tx: Transaction,
  db: Firestore,
): Promise<{ uid: string; language: 'en' | 'sw' }[]> {
  const snap = await tx.get(buildQuery(db, queryById('alertApprovers.all'), []));
  return snap.docs.map((d) => ({
    uid: d.id,
    language: d.get('language') === 'sw' ? 'sw' : 'en',
  }));
}

/**
 * Read half of settling the alert's open `alertDrafted` rows: call it before the first
 * write, then [settleLoadedRows] in the write phase.
 */
export async function loadAlertDraftRows(
  tx: Transaction,
  db: Firestore,
  alertUid: string,
): Promise<LoadedNotification[]> {
  const snap = await tx.get(buildQuery(db, queryById('notifications.byResourceUid'), [alertUid]));
  const out: LoadedNotification[] = [];
  for (const doc of snap.docs) {
    if (str(doc.data().templateKey) !== 'alertDrafted') continue;
    out.push({ id: doc.id, ref: doc.ref, snap: doc as DocumentSnapshot, exists: doc.exists });
  }
  return out;
}

/** Write half: settles rows [loadAlertDraftRows] read. Synchronous, no reads. */
export function settleLoadedRows(
  tx: Transaction,
  rows: LoadedNotification[],
  actionStatus: string,
  byUid: string,
  now: Date,
): void {
  for (const row of rows) NotificationTx.settle(tx, row, actionStatus, byUid, now);
}

function num(value: unknown): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

export async function onNotifiableEventWrittenHandler(
  deps: AlertDeps,
  eventUid: string,
  event: DetectorEvent,
): Promise<DetectorOutcome> {
  const { db } = deps;
  if (!event.after) return 'deleted';

  const now = deps.now ?? new Date();
  const at = timestamp(now);

  return db.runTransaction(async (tx) => {
    // --- Reads, phase 1. ---
    const stored = (await tx.get(db.collection('notifiableEvents').doc(eventUid))).data();
    if (!stored) return 'deleted' as const;
    const diseaseId = str(stored.diseaseId);
    const countyId = stored.countyId;
    const week = str(stored.epiWeek);
    if (diseaseId === '' || typeof countyId !== 'number' || !Number.isInteger(countyId) || week === '') {
      return 'ignored' as const;
    }
    const disease = diseaseById(diseaseId);
    if (!disease || disease.reportingCategory === 'NotListed') return 'ignored' as const;
    const countyName = countyById(countyId)?.name ?? '';
    if (countyName === '') return 'ignored' as const;

    const signalUid = signalUidFor(diseaseId, countyId, week);
    const linkSnap = await tx.get(
      buildQuery(db, queryById('notifiableEventLinks.byEventUid'), [eventUid]).limit(1),
    );
    // No early return on a missing link: a late trigger for a replaced event still
    // settles its count. The link write below only fires when it still points at `e`.
    const linkDoc = linkSnap.empty ? undefined : linkSnap.docs[0];

    const marks = await loadMarks(tx, db, [
      { counter: 'epi', resourceUid: `${eventUid}:count` },
      { counter: 'epi', resourceUid: `${eventUid}:uncount` },
      { counter: 'epi', resourceUid: `${eventUid}:manual` },
      { counter: 'epi', resourceUid: `${eventUid}:unmanual` },
    ]);
    const taken = (suffix: string): boolean =>
      marks.some((m) => m.resourceUid === `${eventUid}:${suffix}` && m.exists);

    const category = disease.reportingCategory;
    const baselineWeeks = category === 'Weekly' ? epiWeeksBack(week, DETECTOR_CONFIG.windowWeeks + 1).slice(1) : [];
    const epiDocs = new Map<string, DocumentData | undefined>();
    epiDocs.set(week, (await tx.get(db.collection('epiCounts').doc(epiKey(diseaseId, countyId, week)))).data());
    for (const w of baselineWeeks) {
      epiDocs.set(w, (await tx.get(db.collection('epiCounts').doc(epiKey(diseaseId, countyId, w)))).data());
    }

    const signalRef = db.collection('alertSignals').doc(signalUid);
    const signal = (await tx.get(signalRef)).data();
    const alertRef = db.collection('alerts').doc(signalUid);
    const alert = (await tx.get(alertRef)).data();

    // --- Edges, from the stored event plus the marks. The count step always runs before
    // the uncount step, so a retraction seen before its creation still nets to zero. ---
    const retracted = str(stored.status) === 'Retracted';
    const countEdge = !taken('count');
    const uncountEdge = retracted && !taken('uncount');
    const manualEdge = stored.alertRequested === true && !taken('manual');
    const unmanualEdge = retracted && (taken('manual') || manualEdge) && !taken('unmanual');

    const weekCount =
      num(epiDocs.get(week)?.count) + (countEdge ? 1 : 0) - (uncountEdge ? 1 : 0);
    const baseline = baselineWeeks.map((w) => num(epiDocs.get(w)?.count));
    const priorEvidence = (signal?.evidence ?? {}) as DocumentData;
    const manualRequests =
      num(priorEvidence.manualRequests) + (manualEdge ? 1 : 0) - (unmanualEdge ? 1 : 0);
    const ageBandCounts: Record<string, number> = {
      ...((priorEvidence.ageBandCounts ?? {}) as Record<string, number>),
    };
    const band = str(stored.ageBand);
    if ((countEdge || uncountEdge) && band !== '') {
      ageBandCounts[band] = Math.max(0, num(ageBandCounts[band]) + (countEdge ? 1 : 0) - (uncountEdge ? 1 : 0));
    }

    const eligible = disease.publicAlertEligible === true;
    const rule = eligible
      ? detect({
        category,
        count: weekCount,
        baseline,
        manualRequests,
        allowManualAlert: disease.allowManualAlert === true,
      })
      : null;

    const stats = baselineStats(baseline);
    const meta = diseaseMetaById(diseaseId);
    const evidence = {
      confirmedCount: weekCount,
      baselineMean: stats.mean,
      baselineSd: stats.sd,
      threshold: stats.threshold,
      floor: DETECTOR_CONFIG.floor,
      windowWeeks: DETECTOR_CONFIG.windowWeeks,
      multiplier: DETECTOR_CONFIG.k,
      ageBandCounts,
      manualRequests,
      categoryVerified: meta.categoryVerified,
      mappingVerified: meta.mappingVerified,
      categorySourceId: meta.categorySourceId,
      weekStart: weekStartOf(week),
    };

    const signalStatus = str(signal?.status);
    const alertStatus = str(alert?.status);
    const noSignal = !signal || signalStatus === '';
    const withdrawing = !noSignal && signalStatus !== 'Withdrawn' && weekCount <= 0 && !rule;
    const overtaken =
      str(signal?.rule) === 'Manual' && rule === 'Baseline' ? 'Baseline' : str(signal?.rule) || rule || '';
    // A redelivery that changed nothing rewrites nothing: no evidence write, no revision
    // bump, no notice — so an approver's tap is never refused spuriously (P2-1).
    const evidenceChanged =
      !evidenceEqual(priorEvidence as DocumentData, evidence) || overtaken !== str(signal?.rule);
    const notifying =
      alert && (alertStatus === 'Drafting' || alertStatus === 'Draft' ||
        alertStatus === 'Approved' || alertStatus === 'Delivered');
    const settling =
      withdrawing && alert && (alertStatus === 'Drafting' || alertStatus === 'Draft');

    // --- Reads, phase 2: everything the notifying branch may touch. ---
    const approvers = withdrawing && notifying ? await readAlertApprovers(tx, db) : [];
    const requestCount = alert ? num(alert.requestCount) : 0;
    const newRevision = (alert ? num(alert.evidenceRevision) : 0) + 1;
    const specs: NoteSpec[] = [];
    if (withdrawing && notifying) {
      // Withdrawals stay per round (one per round at most); the retraction notice keys
      // on the revision it reports, so it never collides with a redraft's rows.
      const template = alertStatus === 'Drafting' || alertStatus === 'Draft' ? 'alertWithdrawn' : 'alertEvidenceChanged';
      const resourceKey = template === 'alertWithdrawn' ? `${signalUid}-r${requestCount}` : `${signalUid}-e${newRevision}`;
      for (const approver of approvers) {
        specs.push({
          template,
          resourceKey,
          threadUid: signalUid,
          resourceUid: signalUid,
          recipientUid: approver.uid,
          recipientRole: 'admin',
          language: approver.language,
          deepLink: `/alerts/${signalUid}/review`,
        });
      }
    }
    // 07 §3.2's "fires, signal exists" row updates the evidence only: a count rise or
    // a partial retraction behind an approved alert notifies nobody. Only the
    // retraction to zero above pages the approvers, keyed on its own revision.
    const notes = await planNotes(tx, db, specs);
    const settlingRows = settling ? await loadAlertDraftRows(tx, db, signalUid) : [];

    // --- Writes: marks and counts first. The epi marks carry no `expireAt`: they are
    // part of the surveillance record, and a missing mark recounts the case (P2-2).
    for (const [edge, suffix] of [
      [countEdge, 'count'],
      [uncountEdge, 'uncount'],
      [manualEdge, 'manual'],
      [unmanualEdge, 'unmanual'],
    ] as const) {
      if (!edge) continue;
      tx.create(db.collection('counterMarks').doc(`epi:${eventUid}:${suffix}`), {
        counter: 'epi',
        resourceUid: `${eventUid}:${suffix}`,
        at,
        lastUpdatedAt: at,
      });
    }
    if (countEdge || uncountEdge) {
      tx.set(
        epiRefOf(db, diseaseId, countyId, week),
        {
          diseaseId,
          countyId,
          epiWeek: week,
          count: FieldValue.increment((countEdge ? 1 : 0) - (uncountEdge ? 1 : 0)),
          lastUpdatedAt: at,
        },
        { merge: true },
      );
    }
    if (
      linkDoc &&
      str(linkDoc.get('eventUid')) === eventUid &&
      str(linkDoc.get('signalUid')) !== signalUid
    ) {
      tx.update(linkDoc.ref, { signalUid, lastUpdatedAt: at });
    }

    if (!eligible) return 'counted' as const;

    // --- The branches. ---
    if (noSignal) {
      if (!rule) return 'counted' as const;
      tx.create(signalRef, {
        uid: signalUid,
        diseaseId,
        countyId,
        countyName,
        epiWeek: week,
        category,
        rule,
        status: 'Raised',
        evidence,
        config: { ...DETECTOR_CONFIG },
        alertUid: signalUid,
        synthetic: stored.synthetic === true,
        raisedAt: at,
        lastUpdatedAt: at,
      });
      tx.create(alertRef, newAlert(signalUid, diseaseId, countyId, countyName, week, category, rule, evidence, stored.synthetic === true, at));
      return 'created' as const;
    }

    if (signalStatus === 'Withdrawn') {
      if (!rule) return 'counted' as const;
      tx.update(signalRef, { status: 'Raised', rule, evidence, lastUpdatedAt: at });
      if (!alert) {
        tx.create(alertRef, newAlert(signalUid, diseaseId, countyId, countyName, week, category, rule, evidence, stored.synthetic === true, at));
      } else if (alertStatus === 'Withdrawn') {
        tx.update(alertRef, {
          status: 'Drafting',
          rule,
          evidence,
          evidenceRetracted: false,
          evidenceRevision: num(alert.evidenceRevision) + 1,
          requestCount: requestCount + 1,
          requestedAt: at,
          lastUpdatedAt: at,
        });
      } else if (alert) {
        tx.update(alertRef, {
          rule: rule ?? str(alert.rule),
          evidence,
          evidenceRetracted: false,
          evidenceRevision: num(alert.evidenceRevision) + 1,
          lastUpdatedAt: at,
        });
      }
      sendNotes(tx, notes, now);
      return 'revived' as const;
    }

    if (withdrawing) {
      tx.update(signalRef, { status: 'Withdrawn', evidence, lastUpdatedAt: at });
      if (alert && (alertStatus === 'Drafting' || alertStatus === 'Draft')) {
        tx.update(alertRef, {
          status: 'Withdrawn',
          evidence,
          evidenceRevision: num(alert.evidenceRevision) + 1,
          lastUpdatedAt: at,
        });
        settleLoadedRows(tx, settlingRows, 'Cancelled', '', now);
      } else if (alert && (alertStatus === 'Approved' || alertStatus === 'Delivered')) {
        tx.update(alertRef, {
          evidence,
          evidenceRevision: num(alert.evidenceRevision) + 1,
          evidenceRetracted: true,
          lastUpdatedAt: at,
        });
      }
      sendNotes(tx, notes, now);
      return 'withdrawn' as const;
    }

    if (!alert) {
      tx.create(alertRef, newAlert(signalUid, diseaseId, countyId, countyName, week, category, overtaken, evidence, stored.synthetic === true, at));
      return 'updated' as const;
    }
    if (!evidenceChanged) return 'unchanged' as const;
    tx.update(signalRef, { evidence, rule: overtaken, lastUpdatedAt: at });
    tx.update(alertRef, {
      evidence,
      rule: overtaken || str(alert.rule),
      evidenceRevision: num(alert.evidenceRevision) + 1,
      lastUpdatedAt: at,
    });
    sendNotes(tx, notes, now);
    return 'updated' as const;
  });
}

function epiRefOf(db: Firestore, diseaseId: string, countyId: number, week: string) {
  return db.collection('epiCounts').doc(epiKey(diseaseId, countyId, week));
}

/** Order-insensitive equality over the plain JSON the evidence holds. */
function evidenceEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true;
  if (typeof a !== 'object' || typeof b !== 'object' || a === null || b === null) return false;
  if (Array.isArray(a) || Array.isArray(b)) return false;
  const ra = a as Record<string, unknown>;
  const rb = b as Record<string, unknown>;
  const ka = Object.keys(ra);
  const kb = Object.keys(rb);
  if (ka.length !== kb.length) return false;
  return ka.every((k) => Object.hasOwn(rb, k) && evidenceEqual(ra[k], rb[k]));
}

/** A working alert in `Drafting`, exactly the AlertModel's defaults (07 §2.5, F-7). */
export function newAlert(
  signalUid: string,
  diseaseId: string,
  countyId: number,
  countyName: string,
  week: string,
  category: string,
  rule: string,
  evidence: DocumentData,
  synthetic: boolean,
  at: string,
): DocumentData {
  return {
    uid: signalUid,
    signalUid,
    diseaseId,
    countyId,
    countyName,
    epiWeek: week,
    category,
    rule,
    status: 'Drafting',
    draftRevision: 0,
    requestCount: 0,
    draftSource: 'Template',
    machineText: {},
    models: {},
    failureReason: '',
    evidence,
    evidenceRevision: 0,
    audience: 'CliniciansThenPatients',
    decision: '',
    decidedByUid: '',
    decidedByName: '',
    decidedAt: '',
    rejectReason: '',
    approvedText: {},
    approvedEvidence: {},
    acceptedUnchanged: false,
    editedKeys: [],
    editDistance: 0,
    evidenceRetracted: false,
    deliveredTo: '',
    deliveredAt: '',
    requestedAt: at,
    draftedAt: '',
    expiresAt: '',
    reminderSentAt: '',
    synthetic,
    createdAt: at,
    lastUpdatedAt: at,
  };
}
