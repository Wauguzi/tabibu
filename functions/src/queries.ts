/**
 * Firestore query registry (plan §5.3). Every Cloud Functions query is built
 * through [buildQuery] so the index check can see it.
 */
import type {
  Firestore,
  Query,
  WhereFilterOp,
} from 'firebase-admin/firestore';

export type QueryFilterOp = WhereFilterOp;

export interface QueryFilter {
  field: string;
  op: QueryFilterOp;
}

export interface QueryOrder {
  field: string;
  direction: 'asc' | 'desc';
}

export interface QueryEntry {
  id: string;
  collection: string;
  scope: 'collection' | 'collectionGroup';
  filters: QueryFilter[];
  orderBy: QueryOrder[];
}

/**
 * Queries identity handlers run today. New domains append here; leave
 * [futureQuerySlots] as the typed place for the reviewer to fill.
 */
export const queryRegistry: QueryEntry[] = [
  {
    id: 'patients.byPhoneAndDob',
    collection: 'patients',
    scope: 'collection',
    filters: [
      { field: 'phoneNumber', op: '==' },
      { field: 'dateOfBirth', op: '==' },
    ],
    orderBy: [],
  },
  {
    id: 'patients.byUid',
    collection: 'patients',
    scope: 'collection',
    filters: [{ field: 'uid', op: '==' }],
    orderBy: [],
  },
  {
    id: 'doctors.byKmpdcNumber',
    collection: 'doctors',
    scope: 'collection',
    filters: [{ field: 'kmpdcNumber', op: '==' }],
    orderBy: [],
  },
  // sweepCases: pathologist requests past their 24 h window (I-2).
  {
    id: 'cases.requestExpired',
    collection: 'cases',
    scope: 'collection',
    filters: [
      { field: 'currentStage', op: '==' },
      { field: 'pathologistRequestExpiresAt', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepCases: Pending shares past their expiry (I-4).
  {
    id: 'shareCodes.pendingExpired',
    collection: 'shareCodes',
    scope: 'collection',
    filters: [
      { field: 'status', op: '==' },
      { field: 'expiresAt', op: '<=' },
    ],
    orderBy: [],
  },
  // cancelOrder: every share of a case, narrowed to Pending in code, so no composite index.
  {
    id: 'shareCodes.byCase',
    collection: 'shareCodes',
    scope: 'collection',
    filters: [{ field: 'caseUid', op: '==' }],
    orderBy: [],
  },
  // expireAppointments: requests nobody answered in time (I-17).
  {
    id: 'appointments.requestedExpired',
    collection: 'appointments',
    scope: 'collection',
    filters: [
      { field: 'status', op: '==' },
      { field: 'expiresAt', op: '<=' },
    ],
    orderBy: [],
  },
  // requestAppointment: the pending cap, narrowed to one doctor in code (I-19's first two fields).
  {
    id: 'appointments.pendingByPatient',
    collection: 'appointments',
    scope: 'collection',
    filters: [
      { field: 'patientUid', op: '==' },
      { field: 'status', op: '==' },
    ],
    orderBy: [],
  },
  // respondToAppointment: other requests for the slot being accepted (I-18).
  {
    id: 'appointments.siblingsBySlot',
    collection: 'appointments',
    scope: 'collection',
    filters: [
      { field: 'doctorUid', op: '==' },
      { field: 'status', op: '==' },
      { field: 'scheduledStart', op: '==' },
    ],
    orderBy: [],
  },
  // expireAppointments: symptom summaries that never came back (I-13).
  {
    id: 'intake.staleQueued',
    collection: 'intake',
    scope: 'collectionGroup',
    filters: [
      { field: 'status', op: '==' },
      { field: 'requestedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepConversations: MDT invites past their seven days (I-23). A range on one field is one
  // index entry, and `> ''` leaves out threads with no open invite.
  {
    id: 'conversations.inviteExpiring',
    collection: 'conversations',
    scope: 'collection',
    filters: [
      { field: 'type', op: '==' },
      { field: 'nextInviteExpiresAt', op: '>' },
      { field: 'nextInviteExpiresAt', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepConversations: senders whose text block has run out (I-29).
  {
    id: 'messageQuotas.textBlocked',
    collection: 'messageQuotas',
    scope: 'collection',
    filters: [
      { field: 'blocked', op: '==' },
      { field: 'blockedUntil', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepConversations: senders whose voice block has run out (I-39).
  {
    id: 'messageQuotas.voiceBlocked',
    collection: 'messageQuotas',
    scope: 'collection',
    filters: [
      { field: 'voiceBlocked', op: '==' },
      { field: 'voiceBlockedUntil', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepConversations: transcripts claimed and never finished (I-38).
  {
    id: 'messages.transcriptStale',
    collection: 'messages',
    scope: 'collectionGroup',
    filters: [
      { field: 'transcriptStatus', op: '==' },
      { field: 'lastUpdatedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // linkPatientAccount: one patient's cases, paged by document id.
  {
    id: 'cases.byPatientId',
    collection: 'cases',
    scope: 'collection',
    filters: [{ field: 'patientId', op: '==' }],
    orderBy: [],
  },
  // resumeLinkJobs: account links that stopped part-way (I-30).
  {
    id: 'linkJobs.stalled',
    collection: 'linkJobs',
    scope: 'collection',
    filters: [
      { field: 'status', op: '==' },
      { field: 'lastUpdatedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // closeCaseConversations: every thread on one case, direct and group (no composite index).
  {
    id: 'conversations.byCase',
    collection: 'conversations',
    scope: 'collection',
    filters: [{ field: 'linkedResourceUid', op: '==' }],
    orderBy: [],
  },
  // sweepCases: AI jobs still Queued or Running past the stale window (one query per status).
  {
    id: 'preread.stale',
    collection: 'preread',
    scope: 'collectionGroup',
    filters: [
      { field: 'status', op: '==' },
      { field: 'requestedAt', op: '<=' },
    ],
    orderBy: [],
  },
  {
    id: 'reportTexts.stale',
    collection: 'reportTexts',
    scope: 'collectionGroup',
    filters: [
      { field: 'status', op: '==' },
      { field: 'requestedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepCases: critical reports the ordering doctor has not opened, signed more than a day ago.
  {
    id: 'reports.criticalUnopened',
    collection: 'reports',
    scope: 'collectionGroup',
    filters: [
      { field: 'isCritical', op: '==' },
      { field: 'doctorOpenedAt', op: '==' },
      { field: 'signedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // backfillAvailability: every practitioner and patient, paged by document id.
  { id: 'doctors.all', collection: 'doctors', scope: 'collection', filters: [], orderBy: [] },
  { id: 'patients.all', collection: 'patients', scope: 'collection', filters: [], orderBy: [] },
  // approveAlert: the four-eyes check — a link naming the caller on this alert (I-40).
  {
    id: 'notifiableEventLinks.bySignalPathologist',
    collection: 'notifiableEventLinks',
    scope: 'collection',
    filters: [
      { field: 'signalUid', op: '==' },
      { field: 'pathologistUid', op: '==' },
    ],
    orderBy: [],
  },
  // onNotifiableEventWritten: the event's audit link (single-field).
  {
    id: 'notifiableEventLinks.byEventUid',
    collection: 'notifiableEventLinks',
    scope: 'collection',
    filters: [{ field: 'eventUid', op: '==' }],
    orderBy: [],
  },
  // Approval rows of one alert, narrowed to open drafts in code (single-field).
  {
    id: 'notifications.byResourceUid',
    collection: 'notifications',
    scope: 'collection',
    filters: [{ field: 'resourceUid', op: '==' }],
    orderBy: [],
  },
  // sweepCases: drafts past their expiry (I-32).
  {
    id: 'alerts.expirySweep',
    collection: 'alerts',
    scope: 'collection',
    filters: [
      { field: 'status', op: '==' },
      { field: 'expiresAt', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepCases: Immediate drafts waiting over an hour (I-33).
  {
    id: 'alerts.reminderSweep',
    collection: 'alerts',
    scope: 'collection',
    filters: [
      { field: 'status', op: '==' },
      { field: 'category', op: '==' },
      { field: 'draftedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepCases: drafts stuck without an answer (I-37).
  {
    id: 'alerts.stuckDrafting',
    collection: 'alerts',
    scope: 'collection',
    filters: [
      { field: 'status', op: '==' },
      { field: 'requestedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // sweepCases: deliveries to resume or page about, one phase at a time (I-36).
  {
    id: 'alertDeliveries.byPhaseRecency',
    collection: 'alertDeliveries',
    scope: 'collection',
    filters: [
      { field: 'phase', op: '==' },
      { field: 'lastUpdatedAt', op: '<=' },
    ],
    orderBy: [],
  },
  // deliverAlert: verified practitioners of one county, paged by document id.
  {
    id: 'practitioners.byCounty',
    collection: 'practitioners',
    scope: 'collection',
    filters: [{ field: 'county', op: '==' }],
    orderBy: [],
  },
  // deliverAlert: demo recipients of one county, paged by document id.
  {
    id: 'demoAccounts.byCounty',
    collection: 'demoAccounts',
    scope: 'collection',
    filters: [{ field: 'county', op: '==' }],
    orderBy: [],
  },
  // The approver registry, read whole (single-field).
  { id: 'alertApprovers.all', collection: 'alertApprovers', scope: 'collection', filters: [], orderBy: [] },
  // aggregateModelSignals: the previous day's AI records, one timestamp field each.
  // Collection-group order reads ride the single-field overrides, not a composite.
  {
    id: 'preread.byReadyAt',
    collection: 'preread',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'readyAt', direction: 'asc' }],
  },
  {
    id: 'prereadScores.byScoredAt',
    collection: 'prereadScores',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'scoredAt', direction: 'asc' }],
  },
  {
    id: 'reportProvenance.byCreatedAt',
    collection: 'reportProvenance',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'createdAt', direction: 'asc' }],
  },
  {
    id: 'reportDrafts.byCreatedAt',
    collection: 'reportDrafts',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'createdAt', direction: 'asc' }],
  },
  {
    id: 'reportTexts.byReadyAt',
    collection: 'reportTexts',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'readyAt', direction: 'asc' }],
  },
  {
    id: 'reportTexts.byApprovedAt',
    collection: 'reportTexts',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'approvedAt', direction: 'asc' }],
  },
  {
    id: 'intake.byReadyAt',
    collection: 'intake',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'readyAt', direction: 'asc' }],
  },
  {
    id: 'messages.byDeliveredAt',
    collection: 'messages',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'deliveredAt', direction: 'asc' }],
  },
  {
    id: 'riskCheck.byReadyAt',
    collection: 'riskCheck',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'readyAt', direction: 'asc' }],
  },
  {
    id: 'notesTranslation.byReadyAt',
    collection: 'notesTranslation',
    scope: 'collectionGroup',
    filters: [],
    orderBy: [{ field: 'readyAt', direction: 'asc' }],
  },
  {
    id: 'alerts.byDraftedAt',
    collection: 'alerts',
    scope: 'collection',
    filters: [],
    orderBy: [{ field: 'draftedAt', direction: 'asc' }],
  },
  {
    id: 'alerts.byDecidedAt',
    collection: 'alerts',
    scope: 'collection',
    filters: [],
    orderBy: [{ field: 'decidedAt', direction: 'asc' }],
  },
  // aggregateModelSignals: expiries carry no decidedAt, so the day's Expired alerts are
  // found by last update and narrowed by status in code.
  {
    id: 'alerts.byUpdatedAt',
    collection: 'alerts',
    scope: 'collection',
    filters: [],
    orderBy: [{ field: 'lastUpdatedAt', direction: 'asc' }],
  },
];

/** Typed slots for domains the reviewer adds later. Keep empty until then. */
export const futureQuerySlots: QueryEntry[] = [];

export function queryById(id: string): QueryEntry {
  const entry = [...queryRegistry, ...futureQuerySlots].find((q) => q.id === id);
  if (!entry) throw new Error(`Unknown query id: ${id}`);
  return entry;
}

/**
 * Builds a Firestore [Query] from a registry entry and one value per filter,
 * in filter order.
 */
export function buildQuery(
  db: Firestore,
  entry: QueryEntry,
  values: unknown[],
): Query {
  if (values.length !== entry.filters.length) {
    throw new Error(
      `Query ${entry.id}: expected ${entry.filters.length} values, got ${values.length}`,
    );
  }
  let q: Query =
    entry.scope === 'collectionGroup'
      ? db.collectionGroup(entry.collection)
      : db.collection(entry.collection);
  entry.filters.forEach((filter, i) => {
    q = q.where(filter.field, filter.op, values[i]);
  });
  for (const order of entry.orderBy) {
    q = q.orderBy(order.field, order.direction);
  }
  return q;
}
