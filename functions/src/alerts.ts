/**
 * The notifiable-event write (07 §3.1, plan §3.4). `signReport` calls
 * [writeNotifiableEvents] inside its own transaction once the report is signed; everything
 * the helper needs is passed in, because a transaction cannot read after it has written.
 * New findings create events and links, kept findings move their link to the new version,
 * dropped findings retract both. The event carries the S-5 allow-list and nothing else.
 */
import { randomUUID } from 'node:crypto';

import type { DocumentData, Firestore, Transaction } from 'firebase-admin/firestore';

import { boundedText, nairobiDate, refuse, timestamp } from './common';
import { diseaseById } from './disease-data';
import { ageBandFor, countyIdByName, nairobiEpiWeek } from './alert-data';

export const MAX_FINDINGS_PER_VERSION = 5;

export interface FindingInput {
  diseaseId: string;
  alertRequested: boolean;
}

/**
 * A link as the caller read it; absent when the case never marked the disease.
 * `alertRequested` is stored on the link, so the caller reads links, never events.
 */
export interface LinkInput {
  diseaseId: string;
  eventUid: string;
  status: string;
  alertRequested: boolean;
  createdAt: string;
}

/**
 * Everything the event write needs, read by the caller in the transaction's read phase:
 * the patient's county name and the case's age, tests and links, plus the version's
 * findings and the previous version's. County and age are mapped here, server-side.
 */
export interface EventWriteInput {
  caseUid: string;
  reportUid: string;
  kind: string;
  /** The signing stamp (the draft's client-stamped `lastUpdatedAt`, D-7). */
  signedAt: string;
  pathologistUid: string;
  countyName: string;
  ageYears: number;
  caseLabTestIds: string[];
  findings: FindingInput[];
  previousFindings: FindingInput[];
  links: LinkInput[];
  synthetic: boolean;
  now: Date;
}

export interface EventWriteResult {
  written: string[];
  retracted: string[];
  kept: string[];
}

/** `notifiableEventLinks/{caseUid}_{diseaseId}`: one link per case and disease, across versions. */
export function linkUidFor(caseUid: string, diseaseId: string): string {
  return `${caseUid}_${diseaseId}`;
}

function confirmingLabTestIds(diseaseId: string): string[] {
  const disease = diseaseById(diseaseId);
  if (!disease) return [];
  return disease.labTests
    .filter((t) => t.strength === 'Confirms' && t.labTestId !== '')
    .map((t) => t.labTestId);
}

export interface EventBuilderInput {
  uid: string;
  diseaseId: string;
  countyId: number;
  date: string;
  epiWeek: string;
  ageBand: string;
  category: string;
  alertRequested: boolean;
  synthetic: boolean;
  at: string;
}

/**
 * The pure event builder. Its output keys are exactly the S-5 allow-list — `diseaseId`,
 * `countyId`, `date`, `epiWeek`, `ageBand`, `category`, `alertRequested`, `status`,
 * `synthetic`, plus `uid` and the two stamps — so identifying fields a caller holds never
 * reach the event. Anything off-shape is refused, never half-built.
 */
export function notifiableEventFor(input: EventBuilderInput): DocumentData {
  const uid = input.uid.trim();
  const diseaseId = input.diseaseId.trim();
  if (uid === '' || diseaseId === '') throw refuse('invalid-argument', 'invalidNotifiable');
  if (!Number.isInteger(input.countyId) || input.countyId <= 0) {
    throw refuse('invalid-argument', 'invalidNotifiable');
  }
  if (input.date === '' || input.epiWeek === '' || input.ageBand === '' || input.at === '') {
    throw refuse('invalid-argument', 'invalidNotifiable');
  }
  if (input.category !== 'Immediate' && input.category !== 'Weekly' && input.category !== 'Monthly') {
    throw refuse('invalid-argument', 'invalidNotifiable');
  }
  return {
    uid,
    diseaseId,
    countyId: input.countyId,
    date: input.date,
    epiWeek: input.epiWeek,
    ageBand: input.ageBand,
    category: input.category,
    alertRequested: input.alertRequested === true,
    status: 'Active',
    synthetic: input.synthetic === true,
    createdAt: input.at,
    lastUpdatedAt: input.at,
  };
}

export interface ValidatedFindings {
  findings: FindingInput[];
  countyId: number;
  ageBand: string;
}

/**
 * The findings validator, exported so `signReport` refuses before its transaction (and
 * before the signature upload): at most five distinct findings, each on a listed disease
 * the case's tests confirm, `alertRequested` only where the bundle allows it, and an
 * addendum that changes nothing. Reads the bundle only — no transaction needed.
 */
export function validateFindings(input: EventWriteInput): ValidatedFindings {
  const findings = input.findings.filter((f) => f.diseaseId.trim() !== '');
  if (findings.length > MAX_FINDINGS_PER_VERSION) {
    throw refuse('invalid-argument', 'invalidNotifiable');
  }
  const ids = findings.map((f) => f.diseaseId);
  if (new Set(ids).size !== ids.length) throw refuse('invalid-argument', 'invalidNotifiable');
  for (const finding of findings) {
    const disease = diseaseById(finding.diseaseId);
    if (!disease || disease.reportingCategory === 'NotListed') {
      throw refuse('invalid-argument', 'invalidNotifiable');
    }
    // Only a `Confirms` test on the case allows the finding (Q-24); a disease with no
    // confirming test in the bundle cannot be marked until research lists one.
    const confirming = confirmingLabTestIds(finding.diseaseId);
    if (!input.caseLabTestIds.some((id) => confirming.includes(id))) {
      throw refuse('invalid-argument', 'invalidNotifiable');
    }
    // The manual request is offered only for an eligible disease, and for a Weekly one
    // only when the bundle allows it (plan §3.4; malaria is Rule B only).
    if (
      finding.alertRequested === true &&
      (disease.publicAlertEligible !== true ||
        (disease.reportingCategory === 'Weekly' && disease.allowManualAlert !== true))
    ) {
      throw refuse('invalid-argument', 'invalidNotifiable');
    }
  }
  if (input.kind === 'Addendum') {
    const shape = (f: FindingInput): string => `${f.diseaseId}:${f.alertRequested === true}`;
    const current = findings.map(shape).sort().join(',');
    const base = input.previousFindings.map(shape).sort().join(',');
    if (current !== base) throw refuse('invalid-argument', 'invalidNotifiable');
  }
  const countyId = countyIdByName(input.countyName);
  if (countyId === undefined) throw refuse('invalid-argument', 'unknownCounty');
  if (!Number.isFinite(input.ageYears) || input.ageYears < 0) {
    throw refuse('invalid-argument', 'invalidAge');
  }
  return { findings, countyId, ageBand: ageBandFor(input.ageYears) };
}

/**
 * Writes the version's events and links. A positive with no `Active` link — new, or
 * re-added after a retraction — creates a fresh event (a UUID, so the detector counts it
 * again) and sets the link; a kept finding moves its link to the new version, and its
 * event only changes when `alertRequested` goes false to true; a dropped finding
 * retracts both. Writes only: the caller did the reads.
 */
export function writeNotifiableEvents(
  tx: Transaction,
  db: Firestore,
  input: EventWriteInput,
): EventWriteResult {
  const { findings, countyId, ageBand } = validateFindings(input);
  const at = timestamp(input.now);
  const signedAt = boundedText(input.signedAt, 1, 64, 'invalidSignedAt');
  const signedDate = new Date(signedAt);
  if (Number.isNaN(signedDate.getTime())) throw refuse('invalid-argument', 'invalidSignedAt');
  const date = nairobiDate(signedDate);
  const epiWeek = nairobiEpiWeek(signedDate);
  const linksByDisease = new Map(input.links.map((l) => [l.diseaseId, l]));
  const previous = new Set(input.previousFindings.map((f) => f.diseaseId));
  const current = new Set(findings.map((f) => f.diseaseId));

  const result: EventWriteResult = { written: [], retracted: [], kept: [] };

  for (const finding of findings) {
    const disease = diseaseById(finding.diseaseId);
    if (!disease) throw refuse('invalid-argument', 'invalidNotifiable');
    const linkUid = linkUidFor(input.caseUid, finding.diseaseId);
    const link = linksByDisease.get(finding.diseaseId);
    if (!link || link.status !== 'Active') {
      const eventUid = randomUUID();
      tx.set(
        db.collection('notifiableEvents').doc(eventUid),
        notifiableEventFor({
          uid: eventUid,
          diseaseId: finding.diseaseId,
          countyId,
          date,
          epiWeek,
          ageBand,
          category: disease.reportingCategory,
          alertRequested: finding.alertRequested,
          synthetic: input.synthetic,
          at,
        }),
      );
      tx.set(db.collection('notifiableEventLinks').doc(linkUid), {
        caseUid: input.caseUid,
        diseaseId: finding.diseaseId,
        reportUid: input.reportUid,
        pathologistUid: input.pathologistUid,
        eventUid,
        signalUid: '',
        alertRequested: finding.alertRequested === true,
        status: 'Active',
        createdAt: link && link.createdAt !== '' ? link.createdAt : at,
        lastUpdatedAt: at,
      });
      result.written.push(eventUid);
    } else {
      tx.update(db.collection('notifiableEventLinks').doc(linkUid), {
        reportUid: input.reportUid,
        alertRequested: finding.alertRequested === true,
        lastUpdatedAt: at,
      });
      if (!link.alertRequested && finding.alertRequested) {
        tx.update(db.collection('notifiableEvents').doc(link.eventUid), {
          alertRequested: true,
          lastUpdatedAt: at,
        });
      }
      result.kept.push(link.eventUid);
    }
  }

  for (const diseaseId of previous) {
    if (current.has(diseaseId)) continue;
    const link = linksByDisease.get(diseaseId);
    if (!link || link.status !== 'Active' || link.eventUid === '') continue;
    tx.update(db.collection('notifiableEvents').doc(link.eventUid), {
      status: 'Retracted',
      lastUpdatedAt: at,
    });
    tx.update(db.collection('notifiableEventLinks').doc(linkUidFor(input.caseUid, diseaseId)), {
      status: 'Retracted',
      lastUpdatedAt: at,
    });
    result.retracted.push(link.eventUid);
  }

  return result;
}
