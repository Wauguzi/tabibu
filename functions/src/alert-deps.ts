/**
 * The outbreak engine's dependencies and constants: Firestore, the topic sender, the
 * alert-drafting AI seam, the clock, the kill switches, and the delivery parameters.
 * Every field but `db` is optional so tests inject fakes; production wiring lives in
 * `index.ts`.
 */
import type { Firestore } from 'firebase-admin/firestore';

import type { DomainAiClient } from './ai-domain';
import type { ConfigReader } from './config';

/** The model sees disease and county names plus guidance bullets: no uid, no count, no date. */
export interface AlertDraftInput {
  diseaseId: string;
  diseaseNameEn: string;
  diseaseNameSw: string;
  countyName: string;
  category: string;
  rule: string;
  audienceKeys: string[];
  guidance: {
    bulletId: string;
    audience: string;
    textEn: string;
    textSw: string;
  }[];
  placeholders: { patient: string[]; clinician: string[] };
  styleRules: string;
}

export interface AlertDraftOutput {
  texts: Record<string, { headline: string; body: string }>;
  models: Record<string, string>;
}

/** The AI client, extended with alert drafting; production gains the method with the model. */
export interface AlertAiClient extends DomainAiClient {
  generateAlertDraft?(input: AlertDraftInput): Promise<AlertDraftOutput>;
}

/** An FCM topic push, shaped like the Admin SDK's message. */
export interface TopicMessage {
  topic: string;
  notification: { title?: string; body: string };
  data: Record<string, string>;
  android: {
    priority: 'high';
    notification: { tag: string; channelId: string };
  };
  apns: {
    headers: Record<string, string>;
    payload: { aps: Record<string, unknown> };
  };
}

/** The slice of FCM topics the engine needs; resolves to the message id. */
export interface TopicMessaging {
  send(message: TopicMessage): Promise<string>;
}

export interface AlertDeps {
  db: Firestore;
  topics?: TopicMessaging;
  ai?: AlertAiClient;
  now?: Date;
  config?: ConfigReader;
  /** True on the demo project: test topics, no patient delay, synthetic flags. */
  synthetic?: boolean;
  /** Minutes between the clinician decision and the patient leg (0 now, Q-A3). */
  patientDelayMin?: number;
  /** Deliveries older than this are left for operators instead of resumed (24). */
  resumeMaxH?: number;
}

/** Clinician rows per delivery page (07 §6.1). */
export const DELIVERY_PAGE_SIZE = 200;
/** A delivery lease lasts 2 min; a runner that loses it stops at the next page. */
export const DELIVERY_LEASE_MIN = 2;
/** A topic claim older than 10 min with no send is stale and may be retaken. */
export const TOPIC_CLAIM_MIN = 10;
/** `Drafting` older than 5 min gets the template draft from the sweep (F-11). */
export const DRAFTING_STALE_MIN = 5;
/** `Held` longer than 15 min pages the approvers once (row 43). */
export const HELD_NOTIFY_MIN = 15;
/** An `Immediate` draft reminds its approvers after 1 h. */
export const REMINDER_H = 1;
/** Redrafts per alert (07 §5.2). */
export const REDRAFT_LIMIT = 3;
/** Delivery jobs live 90 d, then the TTL deletes them. */
export const DELIVERY_TTL_DAYS = 90;

export function alertNow(deps: AlertDeps): Date {
  return deps.now ?? new Date();
}

export function isSynthetic(deps: AlertDeps): boolean {
  return deps.synthetic === true;
}

export function patientDelayMin(deps: AlertDeps): number {
  if (isSynthetic(deps)) return 0;
  const v = deps.patientDelayMin;
  return typeof v === 'number' && Number.isFinite(v) && v >= 0 ? v : 0;
}

export function resumeMaxMs(deps: AlertDeps): number {
  const v = deps.resumeMaxH;
  const hours = typeof v === 'number' && Number.isFinite(v) && v > 0 ? v : 24;
  return hours * 60 * 60 * 1000;
}
