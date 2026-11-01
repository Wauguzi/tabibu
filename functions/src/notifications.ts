/**
 * Notification helpers (plan §4). Document id = idempotency key =
 * `{template}:{resourceKey}:{recipientUid}`. Read before write.
 */
import {
  Timestamp,
  type DocumentData,
  type DocumentReference,
  type DocumentSnapshot,
  type Firestore,
  type Transaction,
} from 'firebase-admin/firestore';

import { refuse, timestamp } from './common';
import { pushEn } from './copy/notifications.en';
import { pushSw } from './copy/notifications.sw';
import { diseaseDisplayName } from './disease-data';
import { countyById } from './reference-data';

export type NotifyLanguage = 'en' | 'sw';

export const GLOBAL_ARG_ALLOW = new Set(['newCount']);
export const ALERT_DELIVERY_ARG_ALLOW = new Set(['diseaseId', 'countyId']);

const CODE_TEMPLATES = new Set([
  'caseShared',
  'reportSigned',
  'reportUpdated',
  'shareCodeReissued',
]);

const NOTIFICATION_TTL_MS = 90 * 24 * 60 * 60 * 1000;

export interface TemplateDef {
  key: string;
  category: string;
  resourceType: string;
  actionType: '' | 'Approval' | 'Acknowledge';
  priority: 'Normal' | 'High';
  argKeys: readonly string[];
  pushes?: boolean;
  topicOnly?: boolean;
  carriesCode?: boolean;
}

export const TEMPLATES: readonly TemplateDef[] = [
  { key: 'orderCreated', category: 'Case', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'pathologistRequested', category: 'Case', resourceType: 'Case', actionType: 'Approval', priority: 'Normal', argKeys: [] },
  { key: 'pathologistAccepted', category: 'Case', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'pathologistAcceptedPatient', category: 'Case', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'pathologistRejected', category: 'Case', resourceType: 'Case', actionType: 'Acknowledge', priority: 'Normal', argKeys: [] },
  { key: 'pathologistRequestExpired', category: 'Case', resourceType: 'Case', actionType: 'Acknowledge', priority: 'Normal', argKeys: [] },
  { key: 'caseWithdrawn', category: 'Case', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'prereadReady', category: 'Preread', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'prereadFailed', category: 'Preread', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'orderCancelled', category: 'Case', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'caseShared', category: 'Case', resourceType: 'Case', actionType: 'Acknowledge', priority: 'Normal', argKeys: [], carriesCode: true },
  { key: 'shareRedeemed', category: 'Case', resourceType: 'Case', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'reportSigned', category: 'Report', resourceType: 'Report', actionType: 'Acknowledge', priority: 'Normal', argKeys: [], carriesCode: true },
  { key: 'reportUpdated', category: 'Report', resourceType: 'Report', actionType: 'Acknowledge', priority: 'Normal', argKeys: [], carriesCode: true },
  { key: 'shareCodeReissued', category: 'Report', resourceType: 'Report', actionType: 'Acknowledge', priority: 'Normal', argKeys: [], carriesCode: true },
  { key: 'criticalReportUnopened', category: 'Report', resourceType: 'Report', actionType: '', priority: 'High', argKeys: [] },
  { key: 'criticalReportUnopenedSigner', category: 'Report', resourceType: 'Report', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'resultsWithDoctor', category: 'Result', resourceType: 'Case', actionType: 'Acknowledge', priority: 'Normal', argKeys: [] },
  { key: 'resultUpdateWithDoctor', category: 'Result', resourceType: 'Case', actionType: 'Acknowledge', priority: 'Normal', argKeys: [] },
  { key: 'resultReleased', category: 'Result', resourceType: 'Report', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'translationReady', category: 'Report', resourceType: 'Report', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'explanationReady', category: 'Report', resourceType: 'Report', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'appointmentRequested', category: 'Appointment', resourceType: 'Appointment', actionType: 'Approval', priority: 'Normal', argKeys: [] },
  { key: 'caseDiscussionRequested', category: 'Appointment', resourceType: 'Appointment', actionType: 'Approval', priority: 'Normal', argKeys: [] },
  { key: 'appointmentAccepted', category: 'Appointment', resourceType: 'Appointment', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'appointmentDeclined', category: 'Appointment', resourceType: 'Appointment', actionType: 'Acknowledge', priority: 'Normal', argKeys: [] },
  { key: 'appointmentExpired', category: 'Appointment', resourceType: 'Appointment', actionType: 'Acknowledge', priority: 'Normal', argKeys: [] },
  { key: 'appointmentCancelledByPatient', category: 'Appointment', resourceType: 'Appointment', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'appointmentCancelledByDoctor', category: 'Appointment', resourceType: 'Appointment', actionType: 'Acknowledge', priority: 'Normal', argKeys: [] },
  { key: 'mdtInvited', category: 'Mdt', resourceType: 'Conversation', actionType: 'Approval', priority: 'Normal', argKeys: [] },
  { key: 'mdtInviteAccepted', category: 'Mdt', resourceType: 'Conversation', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'mdtInviteDeclined', category: 'Mdt', resourceType: 'Conversation', actionType: '', priority: 'Normal', argKeys: [], pushes: false },
  { key: 'messageReceived', category: 'Message', resourceType: 'Conversation', actionType: '', priority: 'Normal', argKeys: ['newCount'] },
  { key: 'mdtMessageReceived', category: 'Message', resourceType: 'Conversation', actionType: '', priority: 'Normal', argKeys: ['newCount'] },
  { key: 'alertDrafted', category: 'Alert', resourceType: 'Alert', actionType: 'Approval', priority: 'Normal', argKeys: [] },
  { key: 'alertDraftReminder', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'High', argKeys: [] },
  { key: 'alertExpired', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'alertWithdrawn', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'alertEvidenceChanged', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'alertDeliveredClinician', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'High', argKeys: ['diseaseId', 'countyId'] },
  { key: 'alertDeliveredPatient', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'High', argKeys: ['diseaseId', 'countyId'], topicOnly: true },
  { key: 'confirmatoryTestRequested', category: 'Report', resourceType: 'Report', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'alertDeliveryHeld', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'High', argKeys: [] },
  { key: 'alertDeliveryStopped', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'Normal', argKeys: [] },
  { key: 'alertDeliveredClinicianDemo', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'Normal', argKeys: ['diseaseId', 'countyId'] },
  { key: 'alertDeliveredPatientDemo', category: 'Alert', resourceType: 'Alert', actionType: '', priority: 'Normal', argKeys: ['diseaseId', 'countyId'], topicOnly: true },
];

const BY_KEY = new Map(TEMPLATES.map((t) => [t.key, t]));

export function templateOf(key: string): TemplateDef {
  const t = BY_KEY.get(key);
  if (!t) throw refuse('invalid-argument', 'invalidTemplate');
  return t;
}

export function notificationId(template: string, resourceKey: string, recipientUid: string): string {
  return `${template}:${resourceKey}:${recipientUid}`;
}

function fill(template: string, args: Record<string, string>): string {
  return template.replace(/\{(\w+)\}/g, (_, name: string) => {
    if (!(name in args) || args[name] === '') {
      throw refuse('invalid-argument', 'invalidTemplateArgs');
    }
    return args[name];
  });
}

/** Resolve alert display names from the bundled catalogues only. */
function resolvePushArgs(
  def: TemplateDef,
  args: Record<string, string>,
  language: NotifyLanguage,
): Record<string, string> {
  const out: Record<string, string> = { ...args };
  if (def.argKeys.includes('diseaseId') || def.argKeys.includes('countyId')) {
    const disease = diseaseDisplayName(args.diseaseId ?? '', language);
    const countyId = Number(args.countyId);
    const county =
      Number.isInteger(countyId) && args.countyId === String(countyId)
        ? countyById(countyId)
        : undefined;
    if (!disease || !county || !county.name.trim()) {
      throw refuse('invalid-argument', 'invalidTemplateArgs');
    }
    out.disease = disease;
    out.county = county.name;
  }
  return out;
}

export function renderPush(
  key: string,
  language: NotifyLanguage,
  args: Record<string, string>,
): { title: string; body: string } {
  const def = templateOf(key);
  assertArgs(def, args);
  const copy = language === 'sw' ? pushSw[key] : pushEn[key];
  if (!copy) throw refuse('invalid-argument', 'invalidTemplate');
  const resolved = resolvePushArgs(def, args, language);
  const count = Number(args.newCount ?? '1');
  const bodySrc = count > 1 && copy.bodyPlural ? copy.bodyPlural : copy.body;
  return {
    title: copy.title ? fill(copy.title, resolved) : '',
    body: fill(bodySrc, resolved),
  };
}

export function assertArgs(template: TemplateDef, args: Record<string, string>): void {
  for (const key of Object.keys(args)) {
    if (!template.argKeys.includes(key)) {
      throw refuse('invalid-argument', 'invalidTemplateArgs');
    }
  }
  for (const key of template.argKeys) {
    if (!(key in args) || args[key] === '') {
      throw refuse('invalid-argument', 'invalidTemplateArgs');
    }
  }
  if ('newCount' in args && !/^[1-9]\d{0,3}$/.test(args.newCount)) {
    throw refuse('invalid-argument', 'invalidTemplateArgs');
  }
  if ('diseaseId' in args) {
    if (!/^[a-z][a-z0-9_]*$/.test(args.diseaseId)) {
      throw refuse('invalid-argument', 'invalidTemplateArgs');
    }
  }
  if ('countyId' in args) {
    if (!/^\d{1,3}$/.test(args.countyId)) {
      throw refuse('invalid-argument', 'invalidTemplateArgs');
    }
  }
}

export interface CreateNotificationInput {
  template: string;
  resourceKey: string;
  resourceUid: string;
  threadUid: string;
  recipientUid: string;
  recipientRole: string;
  initiatorUid?: string;
  initiatorRole?: string;
  language: NotifyLanguage;
  templateArgs?: Record<string, string>;
  expiresAt?: string;
  priority?: 'Normal' | 'High';
  deepLink?: string;
  shareCode?: string;
}

export interface LoadedNotification {
  id: string;
  ref: DocumentReference;
  snap: DocumentSnapshot;
  exists: boolean;
}

export async function loadNotification(
  tx: Transaction,
  db: Firestore,
  template: string,
  resourceKey: string,
  recipientUid: string,
): Promise<LoadedNotification> {
  const id = notificationId(template, resourceKey, recipientUid);
  const ref = db.collection('notifications').doc(id);
  const snap = await tx.get(ref);
  return { id, ref, snap, exists: snap.exists };
}

function pendingActionStatus(def: TemplateDef): string {
  if (def.actionType === 'Approval' || def.carriesCode) return 'Pending';
  return '';
}

export function createNotification(
  tx: Transaction,
  loaded: LoadedNotification,
  input: CreateNotificationInput,
  now: Date,
): boolean {
  if (loaded.exists) return false;
  const def = templateOf(input.template);
  if (def.topicOnly) return false;
  const composed = notificationId(input.template, input.resourceKey, input.recipientUid);
  if (composed !== loaded.id) throw refuse('invalid-argument', 'notificationMismatch');

  const args = input.templateArgs ?? {};
  assertArgs(def, args);

  if (input.shareCode) {
    if (!def.carriesCode && !CODE_TEMPLATES.has(def.key)) {
      throw refuse('invalid-argument', 'shareCodeNotAllowed');
    }
    if (!/^\d{4}$/.test(input.shareCode)) {
      throw refuse('invalid-argument', 'invalidShareCode');
    }
  }

  const push = renderPush(def.key, input.language, args);
  const at = timestamp(now);
  const expireAt = Timestamp.fromMillis(now.getTime() + NOTIFICATION_TTL_MS);
  const metadata: DocumentData = {
    actionType: def.actionType,
    actionStatus: pendingActionStatus(def),
    actionedByUid: '',
    actionedAt: '',
    expiresAt: input.expiresAt ?? '',
    deepLink: input.deepLink ?? '',
    shareCode: input.shareCode ?? '',
    extras: {},
  };
  const row: DocumentData = {
    uid: loaded.id,
    threadUid: input.threadUid,
    idempotencyKey: loaded.id,
    creationDate: at,
    recipientUid: input.recipientUid,
    recipientRole: input.recipientRole,
    initiatorUid: input.initiatorUid ?? '',
    initiatorRole: input.initiatorRole ?? '',
    initiatorName: '',
    title: push.title,
    message: push.body,
    templateKey: def.key,
    templateArgs: args,
    category: def.category,
    priority: input.priority ?? def.priority,
    channel: 'Push',
    source: 'Function',
    scope: 'Cloud',
    status: 'Unread',
    readAt: '',
    resourceType: def.resourceType,
    resourceUid: input.resourceUid,
    metadata,
    pushRequestedAt: def.pushes === false ? '' : at,
    pushSentAt: '',
    expireAt,
    lastUpdatedAt: at,
  };
  tx.create(loaded.ref, row);
  return true;
}

export function settleNotification(
  tx: Transaction,
  loaded: LoadedNotification,
  actionStatus: string,
  byUid: string,
  now: Date,
): void {
  if (!loaded.exists) return;
  const data = loaded.snap.data() ?? {};
  const prior = (data.metadata as DocumentData | undefined) ?? {};
  const current = typeof prior.actionStatus === 'string' ? prior.actionStatus : '';
  if (current && current !== 'Pending') return;
  const at = timestamp(now);
  tx.update(loaded.ref, {
    metadata: {
      ...prior,
      actionStatus,
      actionedByUid: byUid,
      actionedAt: at,
      shareCode: '',
    },
    lastUpdatedAt: at,
  });
}

export function upsertCollapsed(
  tx: Transaction,
  loaded: LoadedNotification,
  input: CreateNotificationInput,
  now: Date,
): void {
  const at = timestamp(now);
  const expireAt = Timestamp.fromMillis(now.getTime() + NOTIFICATION_TTL_MS);
  if (!loaded.exists) {
    createNotification(
      tx,
      loaded,
      { ...input, templateArgs: { newCount: input.templateArgs?.newCount ?? '1' } },
      now,
    );
    return;
  }
  const data = loaded.snap.data() ?? {};
  const prevArgs = (data.templateArgs as Record<string, string> | undefined) ?? {};
  const prev = Number(prevArgs.newCount ?? '1');
  const alreadyRead = data.status === 'Read' || (typeof data.readAt === 'string' && data.readAt !== '');
  const next = String(alreadyRead ? 1 : prev + 1);
  const push = renderPush(input.template, input.language, { newCount: next });
  const priorPush = typeof data.pushRequestedAt === 'string' ? data.pushRequestedAt : '';
  const priorPushAt = priorPush ? Date.parse(priorPush) : 0;
  const refreshPush = !priorPushAt || now.getTime() - priorPushAt >= 60_000;
  tx.update(loaded.ref, {
    templateArgs: { newCount: next },
    title: push.title,
    message: push.body,
    creationDate: at,
    ...(refreshPush ? { pushRequestedAt: at } : {}),
    expireAt,
    lastUpdatedAt: at,
    status: 'Unread',
    readAt: '',
  });
}

export const NotificationTx = {
  load: loadNotification,
  create: createNotification,
  settle: settleNotification,
  upsertCollapsed,
};
