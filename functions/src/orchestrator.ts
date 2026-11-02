/**
 * Case working-state pipeline (plan §3.1). `transition` is the only way a stage
 * changes; `commitCase` writes the case once and creates every queued log entry.
 */
import type {
  DocumentData,
  DocumentReference,
  Transaction,
} from 'firebase-admin/firestore';

import { participants } from './access';
import { refuse, timestamp } from './common';

export type CaseStage =
  | ''
  | 'OrderCreated'
  | 'PathologistRequested'
  | 'PathologistRejected'
  | 'PathologistAccepted'
  | 'SampleReceived'
  | 'SlidesUploaded'
  | 'PrereadQueued'
  | 'PrereadReady'
  | 'PrereadFailed'
  | 'ReportInProgress'
  | 'ReportSigned'
  | 'DiscussionRequested'
  | 'DiscussionBooked'
  | 'ResultReleased'
  | 'Completed'
  | 'Cancelled';

export type CaseLocation = '' | 'Doctor' | 'Pathologist' | 'Lab' | 'Patient';
export type CaseStep =
  | ''
  | 'RequestPathologist'
  | 'AwaitPathologist'
  | 'ReceiveSample'
  | 'UploadSlides'
  | 'ReviewPreread'
  | 'WriteReport'
  | 'ReadReport'
  | 'BookDiscussion'
  | 'ReplyToDiscussion'
  | 'MarkDiscussed'
  | 'Complete';

export type CaseAction =
  | ''
  | 'Reject'
  | 'Expire'
  | 'Reassign'
  | 'Cancel'
  | 'Share'
  | 'RemoveViewer'
  | 'Revise'
  | 'Receive'
  | 'AddSlides';

export type ActorRole = 'Doctor' | 'Pathologist' | 'Patient' | 'System';

export const PATIENT_VISIBLE_REASONS = new Set([
  'OrderedInError',
  'Duplicate',
  'PatientDeclined',
  'Other',
  'SlotUnavailable',
  'OutsidePractice',
  'ReferredElsewhere',
  'SlotTaken',
]);

/** The reasons a doctor may give when cancelling an order; the rest belong to requests and slots. */
export const ORDER_CANCEL_REASONS = new Set(['OrderedInError', 'Duplicate', 'PatientDeclined', 'Other']);

/** Stages a patient may see on a log row (plan §3.1 "Patient sees"). */
export const PATIENT_VISIBLE_STAGES = new Set<CaseStage>([
  'OrderCreated',
  'PathologistAccepted',
  'ReportSigned',
  'DiscussionRequested',
  'DiscussionBooked',
  'ResultReleased',
  'Completed',
  'Cancelled',
]);

const FORBIDDEN_WITH_KEYS = new Set([
  'currentStage',
  'currentLocation',
  'currentStep',
  'stageSeq',
  'stageEnteredAt',
  'participantUids',
]);

export interface QueuedLog {
  fromLocation: CaseLocation;
  fromStage: CaseStage;
  fromStep: CaseStep;
  toLocation: CaseLocation;
  toStage: CaseStage;
  toStep: CaseStep;
  createdByUid: string;
  actorRole: ActorRole;
  actionType: CaseAction;
  actionReason: string;
  patientVisible: boolean;
}

export interface RequestedPathologist {
  uid: string;
  name: string;
  requestedAt: string;
  expiresAt: string;
}

export interface TransitionOpts {
  actorUid: string;
  actorRole: ActorRole;
  action?: CaseAction;
  reason?: string;
  /** Required on Reassign and on any transition into PathologistRequested. */
  requested?: RequestedPathologist;
}

interface TransitionRule {
  from: CaseStage[];
  to: CaseStage;
  location: CaseLocation;
  step: CaseStep | 'SampleReceivedStep';
  actions: CaseAction[];
  patientVisible: boolean;
  self?: boolean;
}

const BEFORE_REPORT_SIGNED: CaseStage[] = [
  'OrderCreated',
  'PathologistRequested',
  'PathologistRejected',
  'PathologistAccepted',
  'SampleReceived',
  'SlidesUploaded',
  'PrereadQueued',
  'PrereadReady',
  'PrereadFailed',
  'ReportInProgress',
];

const REASSIGN_FROM: CaseStage[] = [
  'PathologistRequested',
  'PathologistAccepted',
  'SampleReceived',
  'SlidesUploaded',
  'PrereadQueued',
  'PrereadReady',
  'PrereadFailed',
];

const ALL_STAGES: CaseStage[] = [
  'OrderCreated',
  'PathologistRequested',
  'PathologistRejected',
  'PathologistAccepted',
  'SampleReceived',
  'SlidesUploaded',
  'PrereadQueued',
  'PrereadReady',
  'PrereadFailed',
  'ReportInProgress',
  'ReportSigned',
  'DiscussionRequested',
  'DiscussionBooked',
  'ResultReleased',
  'Completed',
  'Cancelled',
];

const RULES: TransitionRule[] = [
  {
    from: [''],
    to: 'OrderCreated',
    location: 'Doctor',
    step: 'RequestPathologist',
    actions: [''],
    patientVisible: true,
  },
  {
    from: ['OrderCreated', 'PathologistRejected'],
    to: 'PathologistRequested',
    location: 'Pathologist',
    step: 'AwaitPathologist',
    actions: [''],
    patientVisible: false,
  },
  {
    from: ['PathologistRequested'],
    to: 'PathologistAccepted',
    location: 'Pathologist',
    step: 'ReceiveSample',
    actions: [''],
    patientVisible: true,
  },
  {
    from: ['PathologistRequested'],
    to: 'PathologistRejected',
    location: 'Doctor',
    step: 'RequestPathologist',
    actions: ['Reject', 'Expire'],
    patientVisible: false,
  },
  {
    from: REASSIGN_FROM,
    to: 'PathologistRequested',
    location: 'Pathologist',
    step: 'AwaitPathologist',
    actions: ['Reassign'],
    patientVisible: false,
  },
  {
    from: ['PathologistAccepted'],
    to: 'SampleReceived',
    location: 'Lab',
    step: 'SampleReceivedStep',
    actions: [''],
    patientVisible: false,
  },
  {
    from: ['SlidesUploaded', 'PrereadQueued', 'PrereadReady', 'PrereadFailed'],
    to: 'SlidesUploaded',
    location: 'Pathologist',
    step: 'ReviewPreread',
    actions: ['Receive'],
    patientVisible: false,
    self: true,
  },
  {
    from: ['PathologistAccepted', 'SampleReceived'],
    to: 'SlidesUploaded',
    location: 'Pathologist',
    step: 'ReviewPreread',
    actions: [''],
    patientVisible: false,
  },
  {
    from: ['PrereadReady', 'PrereadFailed'],
    to: 'SlidesUploaded',
    location: 'Pathologist',
    step: 'ReviewPreread',
    actions: ['AddSlides'],
    patientVisible: false,
  },
  {
    from: ['SlidesUploaded'],
    to: 'SlidesUploaded',
    location: 'Pathologist',
    step: 'ReviewPreread',
    actions: ['AddSlides'],
    patientVisible: false,
    self: true,
  },
  {
    from: ['PathologistAccepted', 'SampleReceived', 'SlidesUploaded'],
    to: 'PrereadQueued',
    location: 'Pathologist',
    step: 'ReviewPreread',
    actions: [''],
    patientVisible: false,
  },
  {
    from: ['PrereadQueued'],
    to: 'PrereadReady',
    location: 'Pathologist',
    step: 'ReviewPreread',
    actions: [''],
    patientVisible: false,
  },
  {
    from: ['PrereadQueued'],
    to: 'PrereadFailed',
    location: 'Pathologist',
    step: 'WriteReport',
    actions: [''],
    patientVisible: false,
  },
  {
    from: ['SampleReceived', 'SlidesUploaded', 'PrereadReady', 'PrereadFailed'],
    to: 'ReportInProgress',
    location: 'Pathologist',
    step: 'WriteReport',
    actions: [''],
    patientVisible: false,
  },
  {
    from: ['ReportInProgress'],
    to: 'ReportSigned',
    location: 'Doctor',
    step: 'ReadReport',
    actions: [''],
    patientVisible: true,
  },
  {
    from: ['ReportSigned', 'DiscussionRequested', 'DiscussionBooked'],
    to: 'ReportSigned',
    location: 'Doctor',
    step: 'ReadReport',
    actions: ['Revise'],
    patientVisible: true,
    self: true,
  },
  {
    from: ['ResultReleased', 'Completed'],
    to: 'ReportSigned',
    location: 'Doctor',
    step: 'ReadReport',
    actions: ['Revise'],
    patientVisible: true,
  },
  {
    from: ['ReportSigned'],
    to: 'DiscussionRequested',
    location: 'Doctor',
    step: 'ReplyToDiscussion',
    actions: [''],
    patientVisible: true,
  },
  {
    from: ['DiscussionRequested'],
    to: 'DiscussionBooked',
    location: 'Doctor',
    step: 'MarkDiscussed',
    actions: [''],
    patientVisible: true,
  },
  {
    from: ['DiscussionRequested', 'DiscussionBooked'],
    to: 'ReportSigned',
    location: 'Doctor',
    step: 'ReadReport',
    actions: ['Reject', 'Expire', 'Cancel'],
    patientVisible: true,
  },
  {
    from: ['ReportSigned', 'DiscussionRequested', 'DiscussionBooked'],
    to: 'ResultReleased',
    location: 'Patient',
    step: 'Complete',
    actions: [''],
    patientVisible: true,
  },
  {
    from: ['ResultReleased'],
    to: 'Completed',
    location: 'Doctor',
    step: '',
    actions: [''],
    patientVisible: true,
  },
  {
    from: BEFORE_REPORT_SIGNED,
    to: 'Cancelled',
    location: 'Doctor',
    step: '',
    actions: ['Cancel'],
    patientVisible: true,
  },
  {
    from: ALL_STAGES,
    to: 'OrderCreated',
    location: 'Doctor',
    step: '',
    actions: ['Share', 'RemoveViewer'],
    patientVisible: true,
    self: true,
  },
];

function str(data: DocumentData, key: string): string {
  const v = data[key];
  return typeof v === 'string' ? v : '';
}

function strList(data: DocumentData, key: string): string[] {
  const v = data[key];
  return Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string') : [];
}

function num(data: DocumentData, key: string): number {
  const v = data[key];
  return typeof v === 'number' && Number.isFinite(v) ? v : 0;
}

function bool(data: DocumentData, key: string): boolean {
  return data[key] === true;
}

function patientFacingStage(stage: CaseStage): CaseStage {
  if (!stage || PATIENT_VISIBLE_STAGES.has(stage)) return stage;
  return 'PathologistAccepted';
}

function patientFacingStep(step: CaseStep): CaseStep {
  if (
    step === '' ||
    step === 'RequestPathologist' ||
    step === 'ReceiveSample' ||
    step === 'ReadReport' ||
    step === 'ReplyToDiscussion' ||
    step === 'MarkDiscussed' ||
    step === 'Complete' ||
    step === 'BookDiscussion'
  ) {
    return step;
  }
  return 'ReceiveSample';
}

/** Keys whose value is a list of plain records; every other list holds scalars only. */
const OBJECT_LIST_KEYS = new Set(['slideImages', 'slideUploadUids']);

function isScalar(value: unknown): boolean {
  const t = typeof value;
  return t === 'string' || t === 'number' || t === 'boolean';
}

function isPlainRecord(value: unknown): boolean {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) return false;
  if (Object.getPrototypeOf(value) !== Object.prototype) return false;
  return Object.values(value as Record<string, unknown>).every(
    (v) => isScalar(v) || (Array.isArray(v) && v.every(isScalar)),
  );
}

function isPlainValue(key: string, value: unknown): boolean {
  if (value === null || value === undefined) return true;
  if (isScalar(value)) return true;
  if (Array.isArray(value)) {
    if (value.every(isScalar)) return true;
    return OBJECT_LIST_KEYS.has(key) && value.every(isPlainRecord);
  }
  return false;
}

export class CaseState {
  readonly uid: string;
  readonly doctorUid: string;
  readonly patientUid: string;
  readonly requestedPathologistUid: string;
  readonly requestedPathologistName: string;
  readonly pathologistRequestedAt: string;
  readonly pathologistRequestExpiresAt: string;
  readonly pathologistUid: string;
  readonly viewerUids: string[];
  readonly requiresSlides: boolean;
  readonly labAccessionNo: string;
  readonly discussionAppointmentUid: string;
  readonly currentLocation: CaseLocation;
  readonly currentStage: CaseStage;
  readonly currentStep: CaseStep;
  readonly stageSeq: number;
  readonly stageEnteredAt: string;
  readonly queuedLogs: readonly QueuedLog[];
  readonly fields: DocumentData;

  private constructor(init: {
    uid: string;
    doctorUid: string;
    patientUid: string;
    requestedPathologistUid: string;
    requestedPathologistName: string;
    pathologistRequestedAt: string;
    pathologistRequestExpiresAt: string;
    pathologistUid: string;
    viewerUids: string[];
    requiresSlides: boolean;
    labAccessionNo: string;
    discussionAppointmentUid: string;
    currentLocation: CaseLocation;
    currentStage: CaseStage;
    currentStep: CaseStep;
    stageSeq: number;
    stageEnteredAt: string;
    queuedLogs: readonly QueuedLog[];
    fields: DocumentData;
  }) {
    this.uid = init.uid;
    this.doctorUid = init.doctorUid;
    this.patientUid = init.patientUid;
    this.requestedPathologistUid = init.requestedPathologistUid;
    this.requestedPathologistName = init.requestedPathologistName;
    this.pathologistRequestedAt = init.pathologistRequestedAt;
    this.pathologistRequestExpiresAt = init.pathologistRequestExpiresAt;
    this.pathologistUid = init.pathologistUid;
    this.viewerUids = init.viewerUids;
    this.requiresSlides = init.requiresSlides;
    this.labAccessionNo = init.labAccessionNo;
    this.discussionAppointmentUid = init.discussionAppointmentUid;
    this.currentLocation = init.currentLocation;
    this.currentStage = init.currentStage;
    this.currentStep = init.currentStep;
    this.stageSeq = init.stageSeq;
    this.stageEnteredAt = init.stageEnteredAt;
    this.queuedLogs = init.queuedLogs;
    this.fields = init.fields;
  }

  static from(
    snap: { id: string; data: () => DocumentData | undefined } | (DocumentData & { id?: string }),
  ): CaseState {
    const data =
      typeof (snap as { data?: () => DocumentData }).data === 'function'
        ? ((snap as { data: () => DocumentData | undefined }).data() ?? {})
        : (snap as DocumentData);
    const id =
      typeof (snap as { id?: string }).id === 'string'
        ? (snap as { id: string }).id
        : str(data, 'uid');
    return new CaseState({
      uid: id,
      doctorUid: str(data, 'doctorUid'),
      patientUid: str(data, 'patientUid'),
      requestedPathologistUid: str(data, 'requestedPathologistUid'),
      requestedPathologistName: str(data, 'requestedPathologistName'),
      pathologistRequestedAt: str(data, 'pathologistRequestedAt'),
      pathologistRequestExpiresAt: str(data, 'pathologistRequestExpiresAt'),
      pathologistUid: str(data, 'pathologistUid'),
      viewerUids: strList(data, 'viewerUids'),
      requiresSlides: bool(data, 'requiresSlides'),
      labAccessionNo: str(data, 'labAccessionNo'),
      discussionAppointmentUid: str(data, 'discussionAppointmentUid'),
      currentLocation: str(data, 'currentLocation') as CaseLocation,
      currentStage: str(data, 'currentStage') as CaseStage,
      currentStep: str(data, 'currentStep') as CaseStep,
      stageSeq: num(data, 'stageSeq'),
      stageEnteredAt: str(data, 'stageEnteredAt'),
      queuedLogs: [],
      fields: { ...data },
    });
  }

  static initial(seed: DocumentData & { uid: string }): CaseState {
    return CaseState.from({
      ...seed,
      currentStage: '',
      currentLocation: '',
      currentStep: '',
      stageSeq: 0,
    });
  }

  /** @internal Used only by transition() in this module. */
  static _continue(
    base: CaseState,
    queuedLogs: readonly QueuedLog[],
    stageEnteredAt: string,
    requiresSlides: boolean,
  ): CaseState {
    return new CaseState({
      uid: base.uid,
      doctorUid: base.doctorUid,
      patientUid: base.patientUid,
      requestedPathologistUid: base.requestedPathologistUid,
      requestedPathologistName: base.requestedPathologistName,
      pathologistRequestedAt: base.pathologistRequestedAt,
      pathologistRequestExpiresAt: base.pathologistRequestExpiresAt,
      pathologistUid: base.pathologistUid,
      viewerUids: base.viewerUids,
      requiresSlides,
      labAccessionNo: base.labAccessionNo,
      discussionAppointmentUid: base.discussionAppointmentUid,
      currentLocation: base.currentLocation,
      currentStage: base.currentStage,
      currentStep: base.currentStep,
      stageSeq: base.stageSeq,
      stageEnteredAt,
      queuedLogs,
      fields: base.fields,
    });
  }

  with(patch: DocumentData): CaseState {
    for (const key of Object.keys(patch)) {
      if (FORBIDDEN_WITH_KEYS.has(key)) {
        throw refuse('invalid-argument', 'invalidPatch');
      }
      if (!isPlainValue(key, patch[key])) {
        throw refuse('invalid-argument', 'invalidPatch');
      }
    }
    if ('viewerUids' in patch && !Array.isArray(patch.viewerUids)) {
      throw refuse('invalid-argument', 'invalidPatch');
    }
    const next = { ...this.fields, ...patch, uid: this.uid };
    const base = CaseState.from({ id: this.uid, data: () => next });
    return new CaseState({
      uid: this.uid,
      doctorUid: base.doctorUid,
      patientUid: base.patientUid,
      requestedPathologistUid: base.requestedPathologistUid,
      requestedPathologistName: base.requestedPathologistName,
      pathologistRequestedAt: base.pathologistRequestedAt,
      pathologistRequestExpiresAt: base.pathologistRequestExpiresAt,
      pathologistUid: base.pathologistUid,
      viewerUids: base.viewerUids,
      requiresSlides: base.requiresSlides,
      labAccessionNo: base.labAccessionNo,
      discussionAppointmentUid: base.discussionAppointmentUid,
      currentLocation: this.currentLocation,
      currentStage: this.currentStage,
      currentStep: this.currentStep,
      stageSeq: this.stageSeq,
      stageEnteredAt: this.stageEnteredAt,
      queuedLogs: this.queuedLogs,
      fields: {
        ...next,
        currentStage: this.currentStage,
        currentLocation: this.currentLocation,
        currentStep: this.currentStep,
        stageSeq: this.stageSeq,
        stageEnteredAt: this.stageEnteredAt,
      },
    });
  }
}

function sampleStep(s: CaseState): CaseStep {
  return s.requiresSlides ? 'UploadSlides' : 'WriteReport';
}

function matchRule(from: CaseStage, to: CaseStage, action: CaseAction): TransitionRule | undefined {
  return RULES.find((rule) => {
    if (!rule.from.includes(from)) return false;
    if (!rule.actions.includes(action)) return false;
    if (rule.self) return to === from;
    return rule.to === to;
  });
}

/** Module-private rebuild; keeps the CaseState constructor closed to callers. */
function rebuild(
  s: CaseState,
  to: CaseStage,
  location: CaseLocation,
  step: CaseStep,
  log: QueuedLog,
  extras: DocumentData,
): CaseState {
  const fields: DocumentData = {
    ...s.fields,
    ...extras,
    currentStage: to,
    currentLocation: location,
    currentStep: step,
    stageSeq: s.stageSeq + 1,
  };
  const next = CaseState.from({ id: s.uid, data: () => fields });
  return CaseState._continue(next, [...s.queuedLogs, log], s.stageEnteredAt, s.requiresSlides);
}

/**
 * Pure stage transition. Validates against the §3.1 table, queues one log, and
 * clears requested-pathologist fields whenever the destination is not
 * PathologistRequested (F-26). Reassign also clears pathologistUid.
 */
export function transition(s: CaseState, to: CaseStage, opts: TransitionOpts): CaseState {
  const action: CaseAction = opts.action ?? '';
  const reason = opts.reason ?? '';
  const from = s.currentStage;
  const rule = matchRule(from, to, action);
  if (!rule) throw refuse('failed-precondition', 'invalidStage');

  const selfStay = rule.self === true && to === from;
  const location = selfStay ? s.currentLocation : rule.location;
  let step: CaseStep;
  if (selfStay) {
    step = s.currentStep;
  } else if (rule.step === 'SampleReceivedStep') {
    step = sampleStep(s);
  } else {
    step = rule.step;
  }

  if (action === 'Cancel' && !PATIENT_VISIBLE_REASONS.has(reason)) {
    throw refuse('invalid-argument', 'invalidReason');
  }
  if (rule.patientVisible && reason !== '' && !PATIENT_VISIBLE_REASONS.has(reason)) {
    throw refuse('invalid-argument', 'invalidReason');
  }
  if (to === 'ReportInProgress' && !s.labAccessionNo) {
    throw refuse('failed-precondition', 'sampleNotReceived');
  }

  // A log-only row leaves every field as it was, so a pending request stays pending.
  const extras: DocumentData = {};
  if (rule.self === true) {
    // nothing to change
  } else if (action === 'Reassign' || to === 'PathologistRequested') {
    if (action === 'Reassign') {
      extras.pathologistUid = '';
      extras.pathologistName = '';
      extras.pathologistAcceptedAt = '';
    }
    if (!opts.requested?.uid) throw refuse('invalid-argument', 'invalidPathologist');
    extras.requestedPathologistUid = opts.requested.uid;
    extras.requestedPathologistName = opts.requested.name;
    extras.pathologistRequestedAt = opts.requested.requestedAt;
    extras.pathologistRequestExpiresAt = opts.requested.expiresAt;
  } else {
    extras.requestedPathologistUid = '';
    extras.requestedPathologistName = '';
    extras.pathologistRequestedAt = '';
    extras.pathologistRequestExpiresAt = '';
  }

  const logFromStage = rule.patientVisible ? patientFacingStage(from) : from;
  const logToStage = rule.patientVisible ? patientFacingStage(to) : to;
  const logFromStep = rule.patientVisible ? patientFacingStep(s.currentStep) : s.currentStep;
  const logToStep = rule.patientVisible ? patientFacingStep(step) : step;

  const log: QueuedLog = {
    fromLocation: s.currentLocation,
    fromStage: logFromStage,
    fromStep: logFromStep,
    toLocation: location,
    toStage: logToStage,
    toStep: logToStep,
    createdByUid: opts.actorUid,
    actorRole: opts.actorRole,
    actionType: action,
    actionReason: reason,
    patientVisible: rule.patientVisible,
  };

  return rebuild(s, to, location, step, log, extras);
}

export function closeDiscussion(
  s: CaseState,
  appointmentUid: string,
  opts: TransitionOpts & { action: 'Reject' | 'Expire' | 'Cancel' },
): CaseState {
  if (
    s.discussionAppointmentUid !== appointmentUid ||
    (s.currentStage !== 'DiscussionRequested' && s.currentStage !== 'DiscussionBooked')
  ) {
    return s;
  }
  const next = transition(s, 'ReportSigned', {
    actorUid: opts.actorUid,
    actorRole: opts.actorRole,
    action: opts.action,
    reason: opts.reason ?? '',
  });
  return next.with({ discussionAppointmentUid: '' });
}

function padSeq(seq: number): string {
  return String(seq).padStart(4, '0');
}

/**
 * ONE case write with `participantUids = participants(s)` plus tx.create for
 * each queued log as `log/{seq padded to 4}`.
 */
export function commitCase(
  tx: Transaction,
  caseRef: DocumentReference,
  s: CaseState,
  now: Date,
): void {
  const at = timestamp(now);
  const stageChanged = s.queuedLogs.some((l) => l.fromStage !== l.toStage);
  const data: DocumentData = {
    ...s.fields,
    uid: s.uid,
    currentStage: s.currentStage,
    currentLocation: s.currentLocation,
    currentStep: s.currentStep,
    stageSeq: s.stageSeq,
    stageEnteredAt: stageChanged ? at : s.stageEnteredAt || at,
    requestedPathologistUid: s.requestedPathologistUid,
    requestedPathologistName: s.requestedPathologistName,
    pathologistRequestedAt: s.pathologistRequestedAt,
    pathologistRequestExpiresAt: s.pathologistRequestExpiresAt,
    pathologistUid: s.pathologistUid,
    discussionAppointmentUid: s.discussionAppointmentUid,
    viewerUids: s.viewerUids,
    participantUids: participants(s),
    lastUpdatedAt: at,
  };
  tx.set(caseRef, data, { merge: true });

  const baseSeq = s.stageSeq - s.queuedLogs.length;
  s.queuedLogs.forEach((log, i) => {
    const seq = baseSeq + i + 1;
    const id = padSeq(seq);
    tx.create(caseRef.collection('log').doc(id), {
      uid: id,
      caseUid: s.uid,
      seq,
      fromLocation: log.fromLocation,
      fromStage: log.fromStage,
      fromStep: log.fromStep,
      toLocation: log.toLocation,
      toStage: log.toStage,
      toStep: log.toStep,
      createdByUid: log.createdByUid,
      actorRole: log.actorRole,
      actionType: log.actionType,
      actionReason: log.actionReason,
      patientVisible: log.patientVisible,
      createdAt: at,
      lastUpdatedAt: at,
    });
  });
}

export function allowedTransition(from: CaseStage, to: CaseStage, action: CaseAction): boolean {
  return matchRule(from, to, action) !== undefined;
}

/** Every stage the table knows, for exhaustive tests. */
export const TABLE_STAGES: CaseStage[] = ['', ...ALL_STAGES];
export const TABLE_ACTIONS: CaseAction[] = [
  '',
  'Reject',
  'Expire',
  'Reassign',
  'Cancel',
  'Share',
  'RemoveViewer',
  'Revise',
  'Receive',
  'AddSlides',
];
