/**
 * Two-phase delivery (07 §6.1, plan §3.5): rows for the county's clinicians, then — after
 * the patient delay — one topic push per language plus the `publicAlerts` read model for
 * patients. A lease serialises runners, keyed rows and topic claims make every send
 * at-most-once, and the kill switch halts between pages. Runs from the `Approved` edge
 * and from the sweep.
 */
import { randomUUID } from 'node:crypto';

import {
  FieldPath,
  Timestamp,
  type DocumentData,
  type DocumentReference,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';

import { alertGuidanceById } from './alert-data';
import {
  DELIVERY_LEASE_MIN,
  DELIVERY_PAGE_SIZE,
  DELIVERY_TTL_DAYS,
  TOPIC_CLAIM_MIN,
  patientDelayMin,
  resumeMaxMs,
  type AlertDeps,
  type TopicMessage,
} from './alert-deps';
import { readAlertApprovers } from './alert-detector';
import { languageOf, str } from './case-support';
import { DOCTORS, timestamp } from './common';
import { isEnabled } from './config';
import { diseaseById } from './disease-data';
import { renderPush } from './notifications';
import { buildQuery, queryById } from './queries';
import { countyById } from './reference-data';
import { planNotes, sendNotes, type NoteSpec } from './runtime-deps';

export type DeliverOutcome =
  | 'missing'
  | 'leased'
  | 'leaseLost'
  | 'held'
  | 'waiting'
  | 'sendFailed'
  | 'ineligible'
  | 'delivered'
  | 'done';

function num(value: unknown): number {
  return typeof value === 'number' ? value : 0;
}

/**
 * The clock, read fresh at every step: a run that pages a large county for minutes must
 * renew its lease from the current time, not the run's start. Tests pin `deps.now`, so
 * every step of a test run still sees the same instant.
 */
function nowOf(deps: AlertDeps): Date {
  return deps.now ?? new Date();
}

function leaseUntilOf(value: unknown): number {
  if (typeof value !== 'string' || value === '') return 0;
  const ms = Date.parse(value);
  return Number.isFinite(ms) ? ms : 0;
}

/** The clinician recipient page: practitioners, or demo accounts for a synthetic alert. */
function recipientQuery(db: Firestore, synthetic: boolean, countyName: string) {
  const entry = queryById(synthetic ? 'demoAccounts.byCounty' : 'practitioners.byCounty');
  return buildQuery(db, entry, [countyName]).orderBy(FieldPath.documentId());
}

function renderSegment(
  segment: { headline?: unknown; body?: unknown },
  args: Record<string, string>,
): { headline: string; body: string } {
  const render = (text: string): string =>
    text.replace(/\{([a-zA-Z]+)\}/g, (_, key: string) => args[key] ?? `{${key}}`);
  return { headline: render(str(segment.headline)), body: render(str(segment.body)) };
}

function renderArgs(
  diseaseId: string,
  countyId: number,
  countyName: string,
  language: 'en' | 'sw',
  evidence: DocumentData,
): Record<string, string> {
  const disease = diseaseById(diseaseId);
  return {
    disease: language === 'sw' ? (disease?.nameSw ?? '') : (disease?.nameEn ?? ''),
    county: countyName,
    count: String(num(evidence.confirmedCount)),
    weekStart: str(evidence.weekStart),
  };
}

function topicFor(countyId: number, language: string, synthetic: boolean): string {
  const base = synthetic ? 'alerts_patient_demo' : 'alerts_patient';
  return `${base}_${countyId}_${language}`;
}

function topicMessage(
  alertUid: string,
  template: string,
  topic: string,
  language: 'en' | 'sw',
  args: Record<string, string>,
): TopicMessage {
  const push = renderPush(template, language, args);
  return {
    topic,
    notification: { body: push.body },
    data: { alertUid, deepLink: `/alerts/${alertUid}`, channel: 'alerts' },
    android: { priority: 'high', notification: { tag: alertUid, channelId: 'alerts' } },
    apns: {
      headers: { 'apns-collapse-id': alertUid },
      payload: { aps: { 'thread-id': alertUid } },
    },
  };
}

/** A topic claim `{id, at}`; anything else (unclaimed, legacy) reads as absent. */
function claimOf(value: unknown): { id: string; at: number } | undefined {
  if (value === null || typeof value !== 'object') return undefined;
  const r = value as Record<string, unknown>;
  if (typeof r.id !== 'string' || r.id === '') return undefined;
  const at = typeof r.at === 'string' ? Date.parse(r.at) : NaN;
  if (!Number.isFinite(at)) return undefined;
  return { id: r.id, at };
}

async function stopNotes(
  tx: Transaction,
  db: Firestore,
  alertUid: string,
  now: Date,
): Promise<void> {
  const approvers = await readAlertApprovers(tx, db);
  const specs: NoteSpec[] = approvers.map((approver): NoteSpec => ({
    template: 'alertDeliveryStopped',
    resourceKey: alertUid,
    threadUid: alertUid,
    resourceUid: alertUid,
    recipientUid: approver.uid,
    recipientRole: 'admin',
    language: approver.language,
    deepLink: `/alerts/${alertUid}/review`,
  }));
  sendNotes(tx, await planNotes(tx, db, specs), now);
}

/**
 * Delivers an approved alert to the end of its current phase, then returns: the trigger
 * runs it on the `Approved` edge and the sweep resumes `Held`, `Waiting` and stalled
 * jobs. Every step re-checks the lease, the switch and the alert before it writes.
 */
export async function deliverAlert(deps: AlertDeps, alertUid: string): Promise<DeliverOutcome> {
  const { db } = deps;
  const mine = randomUUID();

  // A held delivery with the switch still off costs one read and no write, so the
  // held-since stamp survives for the 15-minute page.
  const peek = await db.collection('alertDeliveries').doc(alertUid).get();
  if (peek.exists && str(peek.get('phase')) === 'Held' && !isEnabled(deps.config, 'alerts_delivery_enabled')) {
    return 'held';
  }

  const lease = await db.runTransaction(async (tx) => {
    const now = nowOf(deps);
    const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
    const delivery = (await tx.get(deliveryRef)).data();
    if (!delivery) return 'missing' as const;
    if (str(delivery.phase) === 'Done') return 'done' as const;
    const alert = (await tx.get(db.collection('alerts').doc(alertUid))).data();
    if (!alert) return 'missing' as const;
    if (str(alert.status) === 'Delivered') return 'done' as const;
    if (str(alert.status) !== 'Approved') return 'notApproved' as const;
    const disease = diseaseById(str(alert.diseaseId));
    if (!disease || disease.publicAlertEligible !== true) return 'ineligible' as const;
    if (
      str(delivery.phase) === 'Waiting' &&
      str(delivery.patientsNotBefore) !== '' &&
      Date.parse(str(delivery.patientsNotBefore)) > now.getTime()
    ) {
      return 'waiting' as const;
    }
    if (leaseUntilOf(delivery.leaseUntil) > now.getTime()) return 'leased' as const;
    tx.update(deliveryRef, {
      leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
      leaseOwner: mine,
      lastUpdatedAt: timestamp(now),
    });
    return 'taken' as const;
  });
  if (lease === 'missing' || lease === 'done' || lease === 'ineligible') return lease;
  if (lease === 'notApproved' || lease === 'waiting' || lease === 'leased') {
    return lease === 'notApproved' ? 'missing' : lease;
  }

  for (;;) {
    const step = await deliveryStep(deps, alertUid, mine);
    if (step === 'again') continue;
    return step;
  }
}

async function deliveryStep(
  deps: AlertDeps,
  alertUid: string,
  mine: string,
): Promise<DeliverOutcome | 'again'> {
  const { db } = deps;
  const now = nowOf(deps);

  const snap = await db.collection('alertDeliveries').doc(alertUid).get();
  const delivery = snap.data();
  if (!delivery || str(delivery.phase) === 'Done') return 'done';
  if (str(delivery.leaseOwner) !== mine) return 'leaseLost';

  const alertSnap = await db.collection('alerts').doc(alertUid).get();
  const alert = alertSnap.data();
  if (!alert || str(alert.status) !== 'Approved') return 'missing';

  const phase = str(delivery.phase);
  if (phase === 'Pending') return pendingStep(deps, alertUid, mine);
  if (phase === 'Clinicians') return cliniciansStep(deps, alertUid, mine, alert);
  if (phase === 'Held') {
    if (!isEnabled(deps.config, 'alerts_delivery_enabled')) return 'held';
    return resumeStep(deps, alertUid, mine);
  }
  if (phase === 'Waiting') {
    const patientsNotBefore = Date.parse(str(delivery.patientsNotBefore));
    if (Number.isFinite(patientsNotBefore) && patientsNotBefore > now.getTime()) return 'waiting';
    return patientsGate(deps, alertUid, mine);
  }
  if (phase === 'Patients') return patientsStep(deps, alertUid, mine, alert);
  return 'done';
}

/** `Held`: the switch is back on, so resume where the artifacts say we stopped. */
async function resumeStep(
  deps: AlertDeps,
  alertUid: string,
  mine: string,
): Promise<DeliverOutcome | 'again'> {
  const { db } = deps;
  return db.runTransaction(async (tx) => {
    const now = nowOf(deps);
    const at = timestamp(now);
    const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
    const live = (await tx.get(deliveryRef)).data();
    if (!live || str(live.phase) === 'Done') return 'done' as const;
    if (str(live.phase) !== 'Held') return 'again' as const;
    if (str(live.leaseOwner) !== mine) return 'leaseLost' as const;
    if (!isEnabled(deps.config, 'alerts_delivery_enabled')) return 'held' as const;
    const current = (await tx.get(db.collection('alerts').doc(alertUid))).data();
    if (!current || str(current.status) !== 'Approved') return 'missing' as const;
    const released = (await tx.get(db.collection('publicAlerts').doc(alertUid))).data();
    const phase = !released ? 'Pending' : released.patientsReleased === true ? 'Patients' : 'Clinicians';
    tx.update(deliveryRef, {
      phase,
      heldReason: '',
      leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
      lastUpdatedAt: at,
    });
    return 'again' as const;
  });
}

/** `Pending`: render the approved text and create the read model, then page clinicians. */
async function pendingStep(
  deps: AlertDeps,
  alertUid: string,
  mine: string,
): Promise<DeliverOutcome | 'again'> {
  const { db } = deps;
  return db.runTransaction(async (tx) => {
    const now = nowOf(deps);
    const at = timestamp(now);
    const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
    const delivery = (await tx.get(deliveryRef)).data();
    if (!delivery || str(delivery.phase) === 'Done') return 'done' as const;
    if (str(delivery.phase) !== 'Pending') return 'again' as const;
    if (str(delivery.leaseOwner) !== mine) return 'leaseLost' as const;
    if (!isEnabled(deps.config, 'alerts_delivery_enabled')) {
      tx.update(deliveryRef, { phase: 'Held', heldReason: 'KillSwitch', lastUpdatedAt: at });
      return 'held' as const;
    }
    const live = (await tx.get(db.collection('alerts').doc(alertUid))).data();
    if (!live || str(live.status) !== 'Approved') return 'missing' as const;

    const diseaseId = str(live.diseaseId);
    if (!diseaseById(diseaseId)) throw new Error('alertDiseaseMissing');
    const countyId = num(live.countyId);
    const countyName = countyById(countyId)?.name ?? str(live.countyName);
    const approvedText = (live.approvedText ?? {}) as DocumentData;
    const approvedEvidence = (live.approvedEvidence ?? {}) as DocumentData;
    const patientText = {
      en: renderSegment(
        (approvedText.patient_en ?? {}) as { headline?: unknown; body?: unknown },
        renderArgs(diseaseId, countyId, countyName, 'en', approvedEvidence),
      ),
      sw: renderSegment(
        (approvedText.patient_sw ?? {}) as { headline?: unknown; body?: unknown },
        renderArgs(diseaseId, countyId, countyName, 'sw', approvedEvidence),
      ),
    };
    const clinicianText = {
      en: renderSegment(
        (approvedText.clinician_en ?? {}) as { headline?: unknown; body?: unknown },
        renderArgs(diseaseId, countyId, countyName, 'en', approvedEvidence),
      ),
      sw: renderSegment(
        (approvedText.clinician_sw ?? {}) as { headline?: unknown; body?: unknown },
        renderArgs(diseaseId, countyId, countyName, 'sw', approvedEvidence),
      ),
    };
    const guidance = alertGuidanceById(diseaseId);
    const bullets = guidance?.bullets ?? [];
    const sources = guidance?.sources ?? [];
    const cited = (audience: string): DocumentData[] => {
      const ids = new Set(
        bullets.filter((b) => b.audience === audience).map((b) => b.sourceId),
      );
      return sources.filter((s) => ids.has(s.sourceId));
    };
    const synthetic = live.synthetic === true;
    tx.create(db.collection('publicAlerts').doc(alertUid), {
      uid: alertUid,
      diseaseId,
      diseaseNameEn: diseaseById(diseaseId)?.nameEn ?? '',
      diseaseNameSw: diseaseById(diseaseId)?.nameSw ?? '',
      countyId,
      countyName,
      clinicianCountyIds: [countyId],
      epiWeek: str(live.epiWeek),
      category: str(live.category),
      patientText,
      patientGuidance: bullets.filter((b) => b.audience === 'Patient'),
      sources: cited('Patient'),
      issuedAt: str(live.decidedAt),
      patientsReleased: false,
      patientsReleasedAt: '',
      synthetic,
      createdAt: at,
      lastUpdatedAt: at,
    });
    tx.create(db.collection('publicAlerts').doc(alertUid).collection('doctor').doc('brief'), {
      uid: 'brief',
      alertUid,
      countyId,
      clinicianText,
      clinicianGuidance: bullets.filter((b) => b.audience === 'Clinician'),
      sources: cited('Clinician'),
      confirmedCount: num(approvedEvidence.confirmedCount),
      weekStart: str(approvedEvidence.weekStart),
      rule: str(live.rule),
      categoryVerified: approvedEvidence.categoryVerified === true,
      lastUpdatedAt: at,
    });
    tx.update(deliveryRef, {
      phase: 'Clinicians',
      leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
      lastUpdatedAt: at,
    });
    return 'again' as const;
  });
}

/** `Clinicians`: one page of keyed rows, the cursor advancing in the same transaction. */
async function cliniciansStep(
  deps: AlertDeps,
  alertUid: string,
  mine: string,
  alert: DocumentData,
): Promise<DeliverOutcome | 'again'> {
  const { db } = deps;
  const synthetic = alert.synthetic === true;
  const countyName = str(alert.countyName);
  const template = synthetic ? 'alertDeliveredClinicianDemo' : 'alertDeliveredClinician';

  return db.runTransaction(async (tx) => {
    const now = nowOf(deps);
    const at = timestamp(now);
    const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
    const live = (await tx.get(deliveryRef)).data();
    if (!live || str(live.phase) === 'Done') return 'done' as const;
    if (str(live.phase) !== 'Clinicians') return 'again' as const;
    if (str(live.leaseOwner) !== mine) return 'leaseLost' as const;
    if (!isEnabled(deps.config, 'alerts_delivery_enabled')) {
      tx.update(deliveryRef, { phase: 'Held', heldReason: 'KillSwitch', lastUpdatedAt: at });
      return 'held' as const;
    }
    const cursor = str(live.clinicianCursor);
    let page = recipientQuery(db, synthetic, countyName).limit(DELIVERY_PAGE_SIZE);
    if (cursor !== '') page = page.startAfter(cursor);
    const snap = await tx.get(page);
    if (snap.empty) {
      const current = (await tx.get(db.collection('alerts').doc(alertUid))).data();
      if (!current || str(current.status) !== 'Approved') return 'missing' as const;
      if (str(current.audience) === 'CliniciansOnly' || current.evidenceRetracted === true) {
        const retracted = current.evidenceRetracted === true;
        if (retracted) await stopNotes(tx, db, alertUid, now);
        finishAlert(tx, db, alertUid, 'CliniciansOnly', at);
        finishDelivery(tx, deliveryRef, now, at);
        return 'delivered' as const;
      }
      tx.update(deliveryRef, {
        phase: 'Waiting',
        patientsNotBefore: timestamp(new Date(now.getTime() + patientDelayMin(deps) * 60 * 1000)),
        leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
        lastUpdatedAt: at,
      });
      // The loop re-checks whether the wait is already due (a zero delay proceeds at once).
      return 'again' as const;
    }

    const languages = synthetic
      ? snap.docs.map((d) => (d.get('language') === 'sw' ? 'sw' : 'en') as 'en' | 'sw')
      : await Promise.all(snap.docs.map((d) => languageOf(tx, db, DOCTORS, d.id)));
    const specs: NoteSpec[] = snap.docs.map((doc, i): NoteSpec => ({
      template,
      resourceKey: alertUid,
      threadUid: alertUid,
      resourceUid: alertUid,
      recipientUid: doc.id,
      recipientRole: 'doctor',
      language: languages[i],
      templateArgs: { diseaseId: str(alert.diseaseId), countyId: String(num(alert.countyId)) },
      deepLink: `/alerts/${alertUid}`,
    }));
    const notes = await planNotes(tx, db, specs);
    sendNotes(tx, notes, now);
    tx.update(deliveryRef, {
      clinicianCursor: snap.docs[snap.docs.length - 1].id,
      cliniciansNotified: num(live.cliniciansNotified) + snap.docs.length,
      leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
      lastUpdatedAt: at,
    });
    return 'again' as const;
  });
}

/**
 * The Patients gate (F-8): one transaction re-checks the switch, the retraction, the
 * audience and the resume bound, and only then releases to patients.
 */
async function patientsGate(
  deps: AlertDeps,
  alertUid: string,
  mine: string,
): Promise<DeliverOutcome | 'again'> {
  const { db } = deps;
  return db.runTransaction(async (tx) => {
    const now = nowOf(deps);
    const at = timestamp(now);
    const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
    const live = (await tx.get(deliveryRef)).data();
    if (!live || str(live.phase) === 'Done') return 'done' as const;
    if (str(live.phase) !== 'Waiting') return 'again' as const;
    if (str(live.leaseOwner) !== mine) return 'leaseLost' as const;
    const patientsNotBefore = Date.parse(str(live.patientsNotBefore));
    if (Number.isFinite(patientsNotBefore) && patientsNotBefore > now.getTime()) return 'waiting' as const;
    if (!isEnabled(deps.config, 'alerts_delivery_enabled')) {
      tx.update(deliveryRef, { phase: 'Held', heldReason: 'KillSwitch', lastUpdatedAt: at });
      return 'held' as const;
    }
    const current = (await tx.get(db.collection('alerts').doc(alertUid))).data();
    if (!current || str(current.status) !== 'Approved') return 'missing' as const;
    const decidedAt = Date.parse(str(current.decidedAt));
    const stale = !Number.isFinite(decidedAt) || now.getTime() - decidedAt > resumeMaxMs(deps);
    if (str(current.audience) === 'CliniciansOnly' || current.evidenceRetracted === true || stale) {
      const forced = current.evidenceRetracted === true || stale;
      if (forced) await stopNotes(tx, db, alertUid, now);
      finishAlert(tx, db, alertUid, 'CliniciansOnly', at);
      finishDelivery(tx, deliveryRef, now, at);
      return 'delivered' as const;
    }
    tx.update(db.collection('publicAlerts').doc(alertUid), {
      patientsReleased: true,
      patientsReleasedAt: at,
      lastUpdatedAt: at,
    });
    tx.update(deliveryRef, {
      phase: 'Patients',
      leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
      lastUpdatedAt: at,
    });
    return 'again' as const;
  });
}

/** `Patients`: one claimed topic send per language, then the terminal write. */
async function patientsStep(
  deps: AlertDeps,
  alertUid: string,
  mine: string,
  alert: DocumentData,
): Promise<DeliverOutcome | 'again'> {
  const { db } = deps;
  if (!deps.topics) throw new Error('alertTopicsUnwired');
  const synthetic = alert.synthetic === true;
  const diseaseId = str(alert.diseaseId);
  const countyId = num(alert.countyId);
  for (const language of ['en', 'sw'] as const) {
    const claim = randomUUID();
    const claimed = await db.runTransaction(async (tx) => {
      const now = nowOf(deps);
      const at = timestamp(now);
      const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
      const live = (await tx.get(deliveryRef)).data();
      if (!live || str(live.phase) === 'Done') return 'done' as const;
      if (str(live.phase) !== 'Patients') return 'again' as const;
      if (str(live.leaseOwner) !== mine) return 'leaseLost' as const;
      if (!isEnabled(deps.config, 'alerts_delivery_enabled')) {
        tx.update(deliveryRef, { phase: 'Held', heldReason: 'KillSwitch', lastUpdatedAt: at });
        return 'held' as const;
      }
      const claims = (live.topicClaims ?? {}) as DocumentData;
      const sentAt = (live.topicSentAt ?? {}) as DocumentData;
      if (str(sentAt[language]) !== '') return 'sent' as const;
      const held = claimOf(claims[language]);
      if (held && now.getTime() - held.at < TOPIC_CLAIM_MIN * 60 * 1000) {
        return 'waiting' as const;
      }
      tx.update(deliveryRef, {
        [`topicClaims.${language}`]: { id: claim, at },
        leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
        lastUpdatedAt: at,
      });
      return 'claimed' as const;
    });
    if (claimed !== 'claimed') {
      if (claimed === 'sent') continue;
      return claimed;
    }
    const template = synthetic ? 'alertDeliveredPatientDemo' : 'alertDeliveredPatient';
    const topic = topicFor(countyId, language, synthetic);
    let messageId: string;
    try {
      messageId = await deps.topics.send(
        topicMessage(alertUid, template, topic, language, {
          diseaseId,
          countyId: String(countyId),
        }),
      );
    } catch {
      await db.runTransaction(async (tx) => {
        const now = nowOf(deps);
        const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
        const live = (await tx.get(deliveryRef)).data();
        if (!live) return;
        const claims = (live.topicClaims ?? {}) as DocumentData;
        if (claimOf(claims[language])?.id === claim) {
          tx.update(deliveryRef, { [`topicClaims.${language}`]: '', lastUpdatedAt: timestamp(now) });
        }
      });
      return 'sendFailed';
    }
    await db.runTransaction(async (tx) => {
      const now = nowOf(deps);
      const at = timestamp(now);
      const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
      const live = (await tx.get(deliveryRef)).data();
      if (!live) return;
      tx.update(deliveryRef, {
        [`topicSentAt.${language}`]: at,
        [`messageIds.${language}`]: messageId,
        leaseUntil: timestamp(new Date(now.getTime() + DELIVERY_LEASE_MIN * 60 * 1000)),
        lastUpdatedAt: at,
      });
    });
  }

  return db.runTransaction(async (tx) => {
    const now = nowOf(deps);
    const doneAt = timestamp(now);
    const deliveryRef = db.collection('alertDeliveries').doc(alertUid);
    const live = (await tx.get(deliveryRef)).data();
    if (!live || str(live.phase) === 'Done') return 'done' as const;
    const sentAt = (live.topicSentAt ?? {}) as DocumentData;
    if (str(sentAt.en) === '' || str(sentAt.sw) === '') return 'again' as const;
    const current = (await tx.get(db.collection('alerts').doc(alertUid))).data();
    if (!current || str(current.status) !== 'Approved') return 'missing' as const;
    finishAlert(tx, db, alertUid, 'CliniciansAndPatients', doneAt);
    finishDelivery(tx, deliveryRef, now, doneAt);
    return 'delivered' as const;
  });
}

function finishAlert(
  tx: Transaction,
  db: Firestore,
  alertUid: string,
  deliveredTo: string,
  at: string,
): void {
  tx.update(db.collection('alerts').doc(alertUid), {
    status: 'Delivered',
    deliveredTo,
    deliveredAt: at,
    lastUpdatedAt: at,
  });
}

function finishDelivery(
  tx: Transaction,
  deliveryRef: DocumentReference,
  now: Date,
  at: string,
): void {
  tx.update(deliveryRef, {
    phase: 'Done',
    expireAt: Timestamp.fromMillis(now.getTime() + DELIVERY_TTL_DAYS * 24 * 60 * 60 * 1000),
    lastUpdatedAt: at,
  });
}
