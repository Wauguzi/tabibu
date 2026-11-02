// cspell:ignore coun
import assert from 'node:assert/strict';

import type { Firestore } from 'firebase-admin/firestore';

import { ageBandFor, baselineStats, detect, epiWeeksBack, nairobiEpiWeek } from './alert-data';
import type { AlertDeps, AlertDraftInput, TopicMessage } from './alert-deps';
import { onNotifiableEventWrittenHandler, signalUidFor } from './alert-detector';
import { deliverAlert } from './alert-delivery';
import {
  approveAlertHandler,
  checkDraftOutput,
  onAlertWrittenHandler,
  requestAlertDraftHandler,
  sanitizedDraftOutput,
  templateDraft,
} from './alert-drafts';
import { runAlertSweep } from './alert-sweep';
import {
  linkUidFor,
  notifiableEventFor,
  validateFindings,
  writeNotifiableEvents,
  type EventWriteInput,
} from './alerts';
import type { Caller } from './common';
import { allOff, allOn } from './domain.test-support';
import { ALERT_TEMPLATE_SW, DEMO_PREFIX_SW } from './copy/alerts.sw';
import { account, emulatorDeps, refusedWith, resetEmulators } from './emulator.test-support';
import { seedWorld, type World } from './case.test-support';
import { countyById } from './reference-data';

const NOW_ISO = '2026-10-27T09:00:00.000Z';
const NOW = new Date(NOW_ISO);
const WEEK = nairobiEpiWeek(NOW);
const NAIROBI = 47;
const NAIROBI_NAME = countyById(NAIROBI)?.name ?? '';
const MOMBASA = 1;
const MOMBASA_NAME = countyById(MOMBASA)?.name ?? '';

const EBOLA_TEST = '9f7bb98b-55b4-4457-b87b-9363ede06454';
const MALARIA_TEST = '9f7bb988-7068-4bc4-a7c5-08c690da9482';
const CHIKUNGUNYA_TEST = '9f7bb98b-33ed-452e-9d52-ef49f8170711';

/** Placeholder-bearing English segments; Swahili comes from the template import. */
const MODEL_EN = {
  patient: {
    headline: 'Health alert: {disease} in {county} County',
    body: 'Cases of {disease} were confirmed in {county} County. Rest and drink fluids.',
  },
  clinician: {
    headline: 'Alert: {disease} in {county} County',
    body: 'Confirmed {disease} in {county} County, week of {weekStart}: {count}. Watch for cases.',
  },
};

function modelTexts() {
  return {
    patient_en: { ...MODEL_EN.patient },
    patient_sw: { headline: ALERT_TEMPLATE_SW.headline, body: ALERT_TEMPLATE_SW.patientBody },
    clinician_en: { ...MODEL_EN.clinician },
    clinician_sw: { headline: ALERT_TEMPLATE_SW.headline, body: ALERT_TEMPLATE_SW.clinicianBody },
  };
}

type AiMode = 'valid' | 'digit' | 'placeholder' | 'url' | 'banned' | 'timeout' | 'error';

function fakeAi(mode: AiMode, seen: { calls: number; input?: AlertDraftInput }) {
  return {
    assessCase: async () => {
      throw new Error('unused');
    },
    generateAlertDraft: async (input: AlertDraftInput) => {
      seen.calls++;
      seen.input = input;
      if (mode === 'timeout') throw new Error('timeout');
      if (mode === 'error') throw new Error('boom');
      const texts = modelTexts();
      if (mode === 'digit') texts.patient_en.body += ' Call 911.';
      if (mode === 'placeholder') texts.patient_en.body += ' See {hospital} soon.';
      if (mode === 'url') texts.patient_en.body += ' See https://example.com/a.';
      if (mode === 'banned') texts.patient_en.body += ' You have nothing to fear.';
      return { texts, models: { draft: 'test-model' } };
    },
  };
}

function fakeTopics(failures = 0) {
  const sends: TopicMessage[] = [];
  let remaining = failures;
  return {
    sends,
    send: async (message: TopicMessage): Promise<string> => {
      if (remaining > 0) {
        remaining--;
        throw new Error('transient');
      }
      sends.push(message);
      return `message-${sends.length}`;
    },
  };
}

function depsOf(db: Firestore, extra: Partial<AlertDeps> = {}): AlertDeps {
  return { db, now: new Date(NOW_ISO), config: allOn, ...extra };
}

async function approver(w: World, email: string, language = 'en'): Promise<Caller> {
  const caller = await account(emulatorDeps(), email, { admin: true });
  await w.deps.db.collection('alertApprovers').doc(caller.uid).set({
    uid: caller.uid,
    grantedByUid: caller.uid,
    grantedAt: NOW_ISO,
    fcmTokens: [],
    language,
    lastUpdatedAt: NOW_ISO,
  });
  return caller;
}

interface EventSeed {
  diseaseId: string;
  category: string;
  countyId?: number;
  week?: string;
  ageBand?: string;
  alertRequested?: boolean;
  status?: string;
  synthetic?: boolean;
}

async function seedEvent(db: Firestore, eventUid: string, seed: EventSeed): Promise<void> {
  await db.collection('notifiableEvents').doc(eventUid).set({
    uid: eventUid,
    diseaseId: seed.diseaseId,
    countyId: seed.countyId ?? NAIROBI,
    date: '2026-10-27',
    epiWeek: seed.week ?? WEEK,
    ageBand: seed.ageBand ?? '25-44',
    category: seed.category,
    alertRequested: seed.alertRequested ?? false,
    status: seed.status ?? 'Active',
    synthetic: seed.synthetic ?? false,
    createdAt: NOW_ISO,
    lastUpdatedAt: NOW_ISO,
  });
}

async function seedLink(
  db: Firestore,
  caseUid: string,
  diseaseId: string,
  eventUid: string,
  pathologistUid: string,
  extra: Record<string, unknown> = {},
): Promise<void> {
  await db.collection('notifiableEventLinks').doc(linkUidFor(caseUid, diseaseId)).set({
    caseUid,
    diseaseId,
    reportUid: 'v1',
    pathologistUid,
    eventUid,
    signalUid: '',
    status: 'Active',
    createdAt: NOW_ISO,
    lastUpdatedAt: NOW_ISO,
    ...extra,
  });
}

async function seedEpiCount(
  db: Firestore,
  diseaseId: string,
  countyId: number,
  week: string,
  count: number,
): Promise<void> {
  await db.collection('epiCounts').doc(`${diseaseId}_${countyId}_${week}`).set({
    diseaseId,
    countyId,
    epiWeek: week,
    count,
    lastUpdatedAt: NOW_ISO,
  });
}

async function seedPractitioner(
  db: Firestore,
  uid: string,
  countyName: string,
  language: string,
): Promise<void> {
  await db.collection('practitioners').doc(uid).set({ uid, county: countyName });
  await db.collection('doctors').doc(uid).set({
    uid,
    firstName: 'Test',
    lastName: 'Doctor',
    language,
    fcmTokens: [],
    receiveNotifications: true,
  });
}

async function seedDraftAlert(
  db: Firestore,
  alertUid: string,
  extra: Record<string, unknown> = {},
): Promise<void> {
  await db.collection('alerts').doc(alertUid).set({
    uid: alertUid,
    signalUid: alertUid,
    diseaseId: 'ebola_virus_disease',
    countyId: NAIROBI,
    countyName: NAIROBI_NAME,
    epiWeek: WEEK,
    category: 'Immediate',
    rule: 'Immediate',
    status: 'Draft',
    draftRevision: 1,
    requestCount: 0,
    draftSource: 'Model',
    machineText: modelTexts(),
    models: { draft: 'test-model' },
    failureReason: '',
    evidence: {
      confirmedCount: 1,
      baselineMean: 0,
      baselineSd: 0,
      threshold: 0,
      floor: 5,
      windowWeeks: 8,
      multiplier: 2,
      ageBandCounts: { '25-44': 1 },
      manualRequests: 0,
      categoryVerified: false,
      mappingVerified: true,
      categorySourceId: 'S1',
      weekStart: '2026-10-26',
    },
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
    requestedAt: NOW_ISO,
    draftedAt: NOW_ISO,
    expiresAt: '2026-10-28T09:00:00.000Z',
    reminderSentAt: '',
    synthetic: false,
    createdAt: NOW_ISO,
    lastUpdatedAt: NOW_ISO,
    ...extra,
  });
}

function eventInput(extra: Partial<EventWriteInput> = {}): EventWriteInput {
  return {
    caseUid: 'case-1',
    reportUid: 'v1',
    kind: 'Initial',
    signedAt: NOW_ISO,
    pathologistUid: 'pathologist-1',
    countyName: NAIROBI_NAME,
    ageYears: 30,
    caseLabTestIds: [EBOLA_TEST],
    findings: [{ diseaseId: 'ebola_virus_disease', alertRequested: false }],
    previousFindings: [],
    links: [],
    synthetic: false,
    now: NOW,
    ...extra,
  };
}

describe('alerts', () => {
  let w: World;
  let db: Firestore;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
    db = w.deps.db;
  });

  describe('record', () => {
    it('writes one event whose keys equal the allow-list, plus the link', async () => {
      const input = eventInput();
      const result = await db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, input)));
      assert.equal(result.written.length, 1);
      const event = (await db.collection('notifiableEvents').doc(result.written[0]).get()).data();
      assert.deepEqual(Object.keys(event ?? {}).sort(), [
        'ageBand',
        'alertRequested',
        'category',
        'countyId',
        'createdAt',
        'date',
        'diseaseId',
        'epiWeek',
        'lastUpdatedAt',
        'status',
        'synthetic',
        'uid',
      ]);
      assert.equal(event?.diseaseId, 'ebola_virus_disease');
      assert.equal(event?.countyId, NAIROBI);
      assert.equal(event?.epiWeek, WEEK);
      assert.equal(event?.ageBand, '25-44');
      const link = (await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).get()).data();
      assert.equal(link?.eventUid, result.written[0]);
      assert.equal(link?.signalUid, '');
      assert.equal(link?.status, 'Active');
    });

    it('the builder refuses off-shape input', async () => {
      assert.throws(
        () =>
          notifiableEventFor({
            uid: '',
            diseaseId: 'ebola_virus_disease',
            countyId: NAIROBI,
            date: '2026-10-27',
            epiWeek: WEEK,
            ageBand: '25-44',
            category: 'Immediate',
            alertRequested: false,
            synthetic: false,
            at: NOW_ISO,
          }),
        /invalidNotifiable/,
      );
      assert.throws(
        () =>
          notifiableEventFor({
            uid: 'e1',
            diseaseId: 'ebola_virus_disease',
            countyId: NAIROBI,
            date: '2026-10-27',
            epiWeek: WEEK,
            ageBand: '25-44',
            category: 'NotListed',
            alertRequested: false,
            synthetic: false,
            at: NOW_ISO,
          }),
        /invalidNotifiable/,
      );
    });

    it('a replay keeps the finding without a new event', async () => {
      const first = await db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput())));
      const kept = await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({
              reportUid: 'v2',
              previousFindings: [{ diseaseId: 'ebola_virus_disease', alertRequested: false }],
              links: [
                {
                  diseaseId: 'ebola_virus_disease',
                  eventUid: first.written[0],
                  status: 'Active',
                  alertRequested: false,
                  createdAt: NOW_ISO,
                },
              ],
            }),
          ),
        ),
      );
      assert.deepEqual(kept.written, []);
      assert.deepEqual(kept.kept, [first.written[0]]);
      const link = (await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).get()).data();
      assert.equal(link?.reportUid, 'v2');
    });

    it('ticking the alert request updates the kept event', async () => {
      const first = await db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput())));
      await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({
              reportUid: 'v2',
              findings: [{ diseaseId: 'ebola_virus_disease', alertRequested: true }],
              previousFindings: [{ diseaseId: 'ebola_virus_disease', alertRequested: false }],
              links: [
                {
                  diseaseId: 'ebola_virus_disease',
                  eventUid: first.written[0],
                  status: 'Active',
                  alertRequested: false,
                  createdAt: NOW_ISO,
                },
              ],
            }),
          ),
        ),
      );
      const event = (await db.collection('notifiableEvents').doc(first.written[0]).get()).data();
      assert.equal(event?.alertRequested, true);
    });

    it('dropping the finding retracts the event and the link', async () => {
      const first = await db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput())));
      const result = await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({
              reportUid: 'v2',
              findings: [],
              previousFindings: [{ diseaseId: 'ebola_virus_disease', alertRequested: false }],
              links: [
                {
                  diseaseId: 'ebola_virus_disease',
                  eventUid: first.written[0],
                  status: 'Active',
                  alertRequested: false,
                  createdAt: NOW_ISO,
                },
              ],
            }),
          ),
        ),
      );
      assert.deepEqual(result.retracted, [first.written[0]]);
      const event = (await db.collection('notifiableEvents').doc(first.written[0]).get()).data();
      assert.equal(event?.status, 'Retracted');
      const link = (await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).get()).data();
      assert.equal(link?.status, 'Retracted');
    });

    it('re-adding after a retraction writes a fresh event', async () => {
      const first = await db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput())));
      await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({
              reportUid: 'v2',
              findings: [],
              previousFindings: [{ diseaseId: 'ebola_virus_disease', alertRequested: false }],
              links: [
                {
                  diseaseId: 'ebola_virus_disease',
                  eventUid: first.written[0],
                  status: 'Active',
                  alertRequested: false,
                  createdAt: NOW_ISO,
                },
              ],
            }),
          ),
        ),
      );
      const third = await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({
              reportUid: 'v3',
              previousFindings: [],
              links: [
                {
                  diseaseId: 'ebola_virus_disease',
                  eventUid: first.written[0],
                  status: 'Retracted',
                  alertRequested: false,
                  createdAt: NOW_ISO,
                },
              ],
            }),
          ),
        ),
      );
      assert.equal(third.written.length, 1);
      assert.notEqual(third.written[0], first.written[0]);
    });

    it('refuses findings the case cannot confirm, and addendum changes', async () => {
      await refusedWith(
        db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput({ caseLabTestIds: [] })))),
        'invalidNotifiable',
      );
      await refusedWith(
        db.runTransaction((tx) =>
          Promise.resolve(writeNotifiableEvents(tx, db, eventInput({ kind: 'Addendum' }))),
        ),
        'invalidNotifiable',
      );
      await refusedWith(
        db.runTransaction((tx) =>
          Promise.resolve(
            writeNotifiableEvents(tx, db, eventInput({ countyName: 'Nowhere County' })),
          ),
        ),
        'unknownCounty',
      );
    });

    it('weeks the event by Nairobi midnight under a UTC clock', async () => {
      const result = await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({ signedAt: '2026-10-26T21:30:00.000Z', ageYears: 4 }),
          ),
        ),
      );
      const event = (await db.collection('notifiableEvents').doc(result.written[0]).get()).data();
      assert.equal(event?.date, '2026-10-27');
      assert.equal(event?.epiWeek, nairobiEpiWeek(new Date('2026-10-27T00:30:00.000Z')));
      assert.equal(event?.ageBand, '0-4');
      assert.equal(ageBandFor(200), '65+');
    });

    it('midnight crossings move the week, including across the year boundary', async () => {
      // Sunday 21:30Z is Monday in Nairobi: a new week, not the UTC Sunday's.
      const sunday = await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(tx, db, eventInput({ signedAt: '2026-10-25T21:30:00.000Z' })),
        ),
      );
      const sundayEvent = (await db.collection('notifiableEvents').doc(sunday.written[0]).get()).data();
      assert.equal(sundayEvent?.date, '2026-10-26');
      assert.equal(sundayEvent?.epiWeek, '2026-W44');
      // 2027-01-03 21:00Z is 2027-01-04 00:00 in Nairobi: 2027-W01, not 2026-W53.
      const newYear = await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({ caseUid: 'case-2', signedAt: '2027-01-03T21:00:00.000Z' }),
          ),
        ),
      );
      const newYearEvent = (await db.collection('notifiableEvents').doc(newYear.written[0]).get()).data();
      assert.equal(newYearEvent?.date, '2027-01-04');
      assert.equal(newYearEvent?.epiWeek, '2027-W01');
      const control = await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({ caseUid: 'case-3', signedAt: '2027-01-03T20:59:00.000Z' }),
          ),
        ),
      );
      const controlEvent = (await db.collection('notifiableEvents').doc(control.written[0]).get()).data();
      assert.equal(controlEvent?.epiWeek, '2026-W53');
    });

    it('identifying fields never reach the event', async () => {
      const tainted = {
        uid: 'e1',
        diseaseId: 'ebola_virus_disease',
        countyId: NAIROBI,
        date: '2026-10-27',
        epiWeek: WEEK,
        ageBand: '25-44',
        category: 'Immediate',
        alertRequested: false,
        synthetic: false,
        at: NOW_ISO,
        patientName: 'Jane Doe',
        phoneNumber: '+254700000000',
        facilityId: 'some-facility',
        orderNumber: 'ORD-1',
      } as never;
      const event = notifiableEventFor(tainted);
      assert.deepEqual(Object.keys(event).sort(), [
        'ageBand',
        'alertRequested',
        'category',
        'countyId',
        'createdAt',
        'date',
        'diseaseId',
        'epiWeek',
        'lastUpdatedAt',
        'status',
        'synthetic',
        'uid',
      ]);
    });

    it('the exported validator gates the manual request on eligibility', async () => {
      assert.doesNotThrow(() =>
        validateFindings(
          eventInput({
            caseLabTestIds: [CHIKUNGUNYA_TEST],
            findings: [{ diseaseId: 'chikungunya', alertRequested: true }],
          }),
        ),
      );
      assert.throws(
        () =>
          validateFindings(
            eventInput({
              caseLabTestIds: [MALARIA_TEST],
              findings: [{ diseaseId: 'malaria', alertRequested: true }],
            }),
          ),
        /invalidNotifiable/,
      );
      await refusedWith(
        db.runTransaction((tx) =>
          Promise.resolve(
            writeNotifiableEvents(
              tx,
              db,
              eventInput({
                caseLabTestIds: [MALARIA_TEST],
                findings: [{ diseaseId: 'malaria', alertRequested: true }],
              }),
            ),
          ),
        ),
        'invalidNotifiable',
      );
    });

    it('an unknown or negative age is refused, never banded', async () => {
      await refusedWith(
        db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput({ ageYears: -1 })))),
        'invalidAge',
      );
      await refusedWith(
        db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput({ ageYears: NaN })))),
        'invalidAge',
      );
    });

    it('the link carries alertRequested for the kept-findings edge', async () => {
      const first = await db.runTransaction((tx) => Promise.resolve(writeNotifiableEvents(tx, db, eventInput())));
      const link = (await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).get()).data();
      assert.equal(link?.alertRequested, false);
      await db.runTransaction((tx) =>
        Promise.resolve(
          writeNotifiableEvents(
            tx,
            db,
            eventInput({
              reportUid: 'v2',
              findings: [{ diseaseId: 'ebola_virus_disease', alertRequested: true }],
              previousFindings: [{ diseaseId: 'ebola_virus_disease', alertRequested: false }],
              links: [
                {
                  diseaseId: 'ebola_virus_disease',
                  eventUid: first.written[0],
                  status: 'Active',
                  alertRequested: false,
                  createdAt: NOW_ISO,
                },
              ],
            }),
          ),
        ),
      );
      const moved = (await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).get()).data();
      assert.equal(moved?.alertRequested, true);
    });
  });

  describe('detect', () => {
    it('Rule A raises a signal and a Drafting alert from one event', async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', {
        before: undefined,
        after: {},
      });
      assert.equal(outcome, 'created');
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      const signal = (await db.collection('alertSignals').doc(signalUid).get()).data();
      assert.equal(signal?.status, 'Raised');
      assert.equal(signal?.rule, 'Immediate');
      assert.equal(signal?.evidence.confirmedCount, 1);
      assert.equal(signal?.alertUid, signalUid);
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Drafting');
      assert.equal(alert?.countyName, NAIROBI_NAME);
      assert.equal(alert?.requestCount, 0);
      const link = (await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).get()).data();
      assert.equal(link?.signalUid, signalUid);
    });

    it('a redelivered event counts once and rewrites nothing', async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      const deps = depsOf(db);
      await onNotifiableEventWrittenHandler(deps, 'e-1', { before: undefined, after: {} });
      const outcome = await onNotifiableEventWrittenHandler(deps, 'e-1', { before: undefined, after: {} });
      assert.equal(outcome, 'unchanged');
      const count = (
        await db.collection('epiCounts').doc(`ebola_virus_disease_${NAIROBI}_${WEEK}`).get()
      ).data();
      assert.equal(count?.count, 1);
      const alert = (
        await db.collection('alerts').doc(signalUidFor('ebola_virus_disease', NAIROBI, WEEK)).get()
      ).data();
      assert.equal(alert?.evidenceRevision, 0);
    });

    it('two concurrent events raise one signal and one alert', async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedEvent(db, 'e-2', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await seedLink(db, 'case-2', 'ebola_virus_disease', 'e-2', w.pathologist.uid);
      const deps = depsOf(db);
      const [a, b] = await Promise.all([
        onNotifiableEventWrittenHandler(deps, 'e-1', { before: undefined, after: {} }),
        onNotifiableEventWrittenHandler(deps, 'e-2', { before: undefined, after: {} }),
      ]);
      assert.deepEqual([a, b].sort(), ['created', 'updated']);
      const signal = (
        await db.collection('alertSignals').doc(signalUidFor('ebola_virus_disease', NAIROBI, WEEK)).get()
      ).data();
      assert.equal(signal?.evidence.confirmedCount, 2);
    });

    it('a retraction seen first nets to zero with no signal', async () => {
      await seedEvent(db, 'e-1', {
        diseaseId: 'ebola_virus_disease',
        category: 'Immediate',
        status: 'Retracted',
      });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', {
        before: undefined,
        after: {},
      });
      assert.equal(outcome, 'counted');
      const count = (
        await db.collection('epiCounts').doc(`ebola_virus_disease_${NAIROBI}_${WEEK}`).get()
      ).data();
      assert.equal(count?.count, 0);
      const signal = await db
        .collection('alertSignals')
        .doc(signalUidFor('ebola_virus_disease', NAIROBI, WEEK))
        .get();
      assert.equal(signal.exists, false);
    });

    it('Rule B fires above the baseline and the floor, not at them', async () => {
      const weeks = epiWeeksBack(WEEK, 9);
      for (const week of weeks.slice(1)) {
        await seedEpiCount(db, 'chikungunya', NAIROBI, week, 4);
      }
      const stats = baselineStats([4, 4, 4, 4, 4, 4, 4, 4]);
      assert.equal(stats.mean, 4);
      assert.equal(stats.sd, 0);
      assert.equal(detect({ category: 'Weekly', count: 4, baseline: [4, 4, 4, 4, 4, 4, 4, 4], manualRequests: 0, allowManualAlert: true }), null);
      assert.equal(detect({ category: 'Weekly', count: 5, baseline: [4, 4, 4, 4, 4, 4, 4, 4], manualRequests: 0, allowManualAlert: true }), 'Baseline');
      assert.equal(detect({ category: 'Weekly', count: 4, baseline: [0, 0, 0, 0, 0, 0, 0, 0], manualRequests: 0, allowManualAlert: true }), null);
      assert.equal(detect({ category: 'Immediate', count: 1, baseline: [], manualRequests: 0, allowManualAlert: false }), 'Immediate');
      for (let i = 0; i < 5; i++) {
        await seedEvent(db, `e-b${i}`, { diseaseId: 'chikungunya', category: 'Weekly' });
        await seedLink(db, `case-b${i}`, 'chikungunya', `e-b${i}`, w.pathologist.uid);
        await onNotifiableEventWrittenHandler(depsOf(db), `e-b${i}`, { before: undefined, after: {} });
      }
      const signal = (
        await db.collection('alertSignals').doc(signalUidFor('chikungunya', NAIROBI, WEEK)).get()
      ).data();
      assert.equal(signal?.status, 'Raised');
      assert.equal(signal?.rule, 'Baseline');
      assert.equal(signal?.evidence.threshold, 4);
    });

    it('Rule M fires below the baseline on a manual request, unless disallowed', async () => {
      await seedEvent(db, 'e-m', {
        diseaseId: 'chikungunya',
        category: 'Weekly',
        alertRequested: true,
      });
      await seedLink(db, 'case-m', 'chikungunya', 'e-m', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-m', { before: undefined, after: {} });
      const chikungunya = (
        await db.collection('alertSignals').doc(signalUidFor('chikungunya', NAIROBI, WEEK)).get()
      ).data();
      assert.equal(chikungunya?.rule, 'Manual');
      assert.equal(chikungunya?.evidence.manualRequests, 1);

      await seedEvent(db, 'e-mal', { diseaseId: 'malaria', category: 'Weekly', alertRequested: true });
      await seedLink(db, 'case-mal', 'malaria', 'e-mal', w.pathologist.uid);
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-mal', {
        before: undefined,
        after: {},
      });
      assert.equal(outcome, 'counted');
      const malaria = await db
        .collection('alertSignals')
        .doc(signalUidFor('malaria', NAIROBI, WEEK))
        .get();
      assert.equal(malaria.exists, false);
    });

    it('ineligible diseases are counted but never broadcast', async () => {
      await seedEvent(db, 'e-tb', { diseaseId: 'tuberculosis', category: 'Monthly' });
      await seedLink(db, 'case-tb', 'tuberculosis', 'e-tb', w.pathologist.uid);
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-tb', {
        before: undefined,
        after: {},
      });
      assert.equal(outcome, 'counted');
      const count = (await db.collection('epiCounts').doc(`tuberculosis_${NAIROBI}_${WEEK}`).get()).data();
      assert.equal(count?.count, 1);
      const signal = await db
        .collection('alertSignals')
        .doc(signalUidFor('tuberculosis', NAIROBI, WEEK))
        .get();
      assert.equal(signal.exists, false);
    });

    it('retraction to zero withdraws a Draft and settles its rows', async () => {
      const caller = await approver(w, 'approver@example.com');
      void caller;
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await db.collection('alerts').doc(signalUid).update({ status: 'Draft' });
      await db.collection('notifications').doc(`alertDrafted:${signalUid}-r0:approver-1`).set({
        templateKey: 'alertDrafted',
        resourceUid: signalUid,
        metadata: { actionType: 'Approval', actionStatus: 'Pending' },
      });
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', {
        before: {},
        after: {},
      });
      assert.equal(outcome, 'withdrawn');
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Withdrawn');
      assert.equal(alert?.evidence.confirmedCount, 0);
      assert.equal(alert?.evidenceRevision, 1);
      const row = (await db.collection('notifications').doc(`alertDrafted:${signalUid}-r0:approver-1`).get()).data();
      assert.equal(row?.metadata.actionStatus, 'Cancelled');
    });

    it('retraction after approval marks the evidence retracted and notifies', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await db.collection('alerts').doc(signalUid).update({ status: 'Approved' });
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: {}, after: {} });
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Approved');
      assert.equal(alert?.evidenceRetracted, true);
      const row = (
        await db.collection('notifications').doc(`alertEvidenceChanged:${signalUid}-e1:${caller.uid}`).get()
      ).data();
      assert.equal(row?.templateKey, 'alertEvidenceChanged');
    });

    it('a firing detector revives a Withdrawn signal and redrafts its alert', async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: {}, after: {} });
      await seedEvent(db, 'e-2', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-2', 'ebola_virus_disease', 'e-2', w.pathologist.uid);
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-2', {
        before: undefined,
        after: {},
      });
      assert.equal(outcome, 'revived');
      const signal = (await db.collection('alertSignals').doc(signalUid).get()).data();
      assert.equal(signal?.status, 'Raised');
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Drafting');
      assert.equal(alert?.requestCount, 1);
    });

    it('a rejected alert keeps its verdict while its evidence follows the count', async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await db.collection('alerts').doc(signalUid).update({ status: 'Rejected' });
      await seedEvent(db, 'e-2', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-2', 'ebola_virus_disease', 'e-2', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-2', { before: undefined, after: {} });
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Rejected');
      assert.equal(alert?.evidence.confirmedCount, 2);
      assert.equal(alert?.evidenceRevision, 1);
    });

    it('only the retraction to zero notifies, keyed on its revision', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await db.collection('alerts').doc(signalUid).update({ status: 'Approved' });
      await seedEvent(db, 'e-2', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-2', 'ebola_virus_disease', 'e-2', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-2', { before: undefined, after: {} });
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: {}, after: {} });
      for (const revision of [1, 2]) {
        const silent = await db
          .collection('notifications')
          .doc(`alertEvidenceChanged:${signalUid}-e${revision}:${caller.uid}`)
          .get();
        assert.equal(silent.exists, false);
      }
      await db.collection('notifiableEvents').doc('e-2').update({ status: 'Retracted' });
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-2', { before: {}, after: {} });
      const row = (
        await db.collection('notifications').doc(`alertEvidenceChanged:${signalUid}-e3:${caller.uid}`).get()
      ).data();
      assert.equal(row?.templateKey, 'alertEvidenceChanged');
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.evidence.confirmedCount, 0);
      assert.equal(alert?.evidenceRetracted, true);
    });

    it('epi marks carry no expiry: a retraction after 31 days still removes the count', async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const mark = (await db.collection('counterMarks').doc('epi:e-1:count').get()).data();
      assert.ok(mark && !('expireAt' in mark));
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      const late = depsOf(db, { now: new Date('2026-11-27T09:00:00.000Z') });
      const outcome = await onNotifiableEventWrittenHandler(late, 'e-1', { before: {}, after: {} });
      assert.equal(outcome, 'withdrawn');
      const count = (
        await db.collection('epiCounts').doc(`ebola_virus_disease_${NAIROBI}_${WEEK}`).get()
      ).data();
      assert.equal(count?.count, 0);
    });

    it("a replaced event's late trigger settles its count without touching the link", async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      await seedEvent(db, 'e-2', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).update({
        eventUid: 'e-2',
        reportUid: 'v3',
      });
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-2', { before: undefined, after: {} });
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: {}, after: {} });
      assert.equal(outcome, 'updated');
      const count = (
        await db.collection('epiCounts').doc(`ebola_virus_disease_${NAIROBI}_${WEEK}`).get()
      ).data();
      assert.equal(count?.count, 1);
      const link = (
        await db.collection('notifiableEventLinks').doc(linkUidFor('case-1', 'ebola_virus_disease')).get()
      ).data();
      assert.equal(link?.eventUid, 'e-2');
      assert.equal(link?.signalUid, signalUidFor('ebola_virus_disease', NAIROBI, WEEK));
    });

    it('Rule B reads missing weeks as zero', async () => {
      const weeks = epiWeeksBack(WEEK, 9);
      await seedEpiCount(db, 'chikungunya', NAIROBI, weeks[1], 4);
      await seedEpiCount(db, 'chikungunya', NAIROBI, weeks[2], 5);
      await seedEpiCount(db, 'chikungunya', NAIROBI, weeks[3], 6);
      for (let i = 0; i < 7; i++) {
        await seedEvent(db, `e-g${i}`, { diseaseId: 'chikungunya', category: 'Weekly' });
        await seedLink(db, `case-g${i}`, 'chikungunya', `e-g${i}`, w.pathologist.uid);
        await onNotifiableEventWrittenHandler(depsOf(db), `e-g${i}`, { before: undefined, after: {} });
      }
      const signal = (
        await db.collection('alertSignals').doc(signalUidFor('chikungunya', NAIROBI, WEEK)).get()
      ).data();
      assert.equal(signal?.rule, 'Baseline');
      assert.ok(Math.abs((signal?.evidence.threshold as number) - 6.8184) < 0.001);
    });

    it('an HIV event is counted but never broadcast', async () => {
      await seedEvent(db, 'e-hiv', { diseaseId: 'hiv_newly_diagnosed', category: 'Monthly' });
      await seedLink(db, 'case-hiv', 'hiv_newly_diagnosed', 'e-hiv', w.pathologist.uid);
      const outcome = await onNotifiableEventWrittenHandler(depsOf(db), 'e-hiv', {
        before: undefined,
        after: {},
      });
      assert.equal(outcome, 'counted');
      const count = (await db.collection('epiCounts').doc(`hiv_newly_diagnosed_${NAIROBI}_${WEEK}`).get()).data();
      assert.equal(count?.count, 1);
      const signal = await db
        .collection('alertSignals')
        .doc(signalUidFor('hiv_newly_diagnosed', NAIROBI, WEEK))
        .get();
      assert.equal(signal.exists, false);
    });

    it('a revival clears the retracted flag: the evidence is back', async () => {
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await db.collection('alerts').doc(signalUid).update({ status: 'Approved' });
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: {}, after: {} });
      await seedEvent(db, 'e-2', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-2', 'ebola_virus_disease', 'e-2', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-2', { before: undefined, after: {} });
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.evidenceRetracted, false);
      assert.equal(alert?.evidence.confirmedCount, 1);
    });
  });

  describe('draft', () => {
    async function draftingAlert(extra: Record<string, unknown> = {}): Promise<string> {
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      if (Object.keys(extra).length > 0) {
        await db.collection('alerts').doc(signalUid).update(extra);
      }
      return signalUid;
    }

    it('a valid answer drafts Model and pages every approver', async () => {
      const caller = await approver(w, 'approver@example.com');
      const signalUid = await draftingAlert();
      const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
      const after = (await db.collection('alerts').doc(signalUid).get()).data();
      const outcome = await onAlertWrittenHandler(depsOf(db, { ai: fakeAi('valid', seen) }), signalUid, {
        before: undefined,
        after,
      });
      assert.equal(outcome, 'drafted');
      assert.equal(seen.calls, 1);
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Draft');
      assert.equal(alert?.draftSource, 'Model');
      assert.equal(alert?.failureReason, '');
      assert.equal(alert?.draftRevision, 1);
      assert.deepEqual(Object.keys(alert?.machineText ?? {}).sort(), [
        'clinician_en',
        'clinician_sw',
        'patient_en',
        'patient_sw',
      ]);
      const row = (
        await db.collection('notifications').doc(`alertDrafted:${signalUid}-r0:${caller.uid}`).get()
      ).data();
      assert.equal(row?.templateKey, 'alertDrafted');
      assert.equal(row?.metadata.actionType, 'Approval');
      assert.equal(row?.metadata.actionStatus, 'Pending');
      assert.equal(row?.metadata.expiresAt, alert?.expiresAt);
      const flat = JSON.stringify(seen.input);
      assert.ok(!/\d{4}-\d{2}-\d{2}/.test(flat));
      assert.ok(!/case-1/.test(flat));
      assert.ok(!/e-1/.test(flat));
      const signal = (await db.collection('modelSignals').doc('20261027').get()).data();
      assert.equal(signal?.alertDraftReady, 1);
    });

    it('a digit, a stray placeholder, a URL or a banned phrase falls back to the template', async () => {
      await approver(w, 'approver@example.com');
      const cases: [AiMode, string][] = [
        ['digit', 'NumberCheck'],
        ['placeholder', 'OffSchema'],
        ['url', 'OffSchema'],
        ['banned', 'Banned'],
      ];
      for (const [mode, reason] of cases) {
        const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
        await db.collection('alerts').doc(signalUid).delete();
        const uid = await draftingAlert();
        assert.equal(uid, signalUid);
        const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
        const after = (await db.collection('alerts').doc(signalUid).get()).data();
        const outcome = await onAlertWrittenHandler(depsOf(db, { ai: fakeAi(mode, seen) }), signalUid, {
          before: undefined,
          after,
        });
        assert.equal(outcome, 'template');
        const alert = (await db.collection('alerts').doc(signalUid).get()).data();
        assert.equal(alert?.draftSource, 'Template');
        assert.equal(alert?.failureReason, reason);
      }
      assert.equal(sanitizedDraftOutput({}), undefined);
      assert.equal(checkDraftOutput(modelTexts()), '');
    });

    it('zero-width smuggling is cleaned before the checks run', async () => {
      const smuggledUrl = modelTexts();
      smuggledUrl.patient_en.body += ' See https\u200B://example.com/a.';
      const urlClean = sanitizedDraftOutput(smuggledUrl);
      assert.ok(urlClean);
      assert.equal(checkDraftOutput(urlClean), 'OffSchema');
      const smuggledPlaceholder = modelTexts();
      smuggledPlaceholder.patient_en.body += ' See {coun\u200Bt} soon.';
      const placeholderClean = sanitizedDraftOutput(smuggledPlaceholder);
      assert.ok(placeholderClean);
      assert.equal(checkDraftOutput(placeholderClean), 'OffSchema');
      const bidi = modelTexts();
      bidi.patient_en.body += ' Rest\u202E now.';
      const bidiClean = sanitizedDraftOutput(bidi);
      assert.ok(bidiClean && !bidiClean.patient_en.body.includes('\u202E'));
      assert.equal(checkDraftOutput(bidiClean), '');
    });

    it('a timeout, a service error or a missing model still reaches Draft', async () => {
      await approver(w, 'approver@example.com');
      for (const [mode, reason] of [['timeout', 'Timeout'], ['error', 'ServiceError']] as const) {
        const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
        await db.collection('alerts').doc(signalUid).delete();
        await draftingAlert();
        const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
        const after = (await db.collection('alerts').doc(signalUid).get()).data();
        const outcome = await onAlertWrittenHandler(depsOf(db, { ai: fakeAi(mode, seen) }), signalUid, {
          before: undefined,
          after,
        });
        assert.equal(outcome, 'template');
        const alert = (await db.collection('alerts').doc(signalUid).get()).data();
        assert.equal(alert?.failureReason, reason);
      }
    });

    it('the kill switch fails closed with the template still reaching the approver', async () => {
      const caller = await approver(w, 'approver@example.com');
      const signalUid = await draftingAlert();
      const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
      const after = (await db.collection('alerts').doc(signalUid).get()).data();
      const outcome = await onAlertWrittenHandler(
        depsOf(db, { ai: fakeAi('valid', seen), config: allOff }),
        signalUid,
        { before: undefined, after },
      );
      assert.equal(outcome, 'template');
      assert.equal(seen.calls, 0);
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.draftSource, 'Template');
      assert.equal(alert?.failureReason, 'Disabled');
      const row = (
        await db.collection('notifications').doc(`alertDrafted:${signalUid}-r0:${caller.uid}`).get()
      ).data();
      assert.equal(row?.templateKey, 'alertDrafted');
    });

    it('synthetic alerts use the demo template without calling the model', async () => {
      await approver(w, 'approver@example.com');
      const signalUid = await draftingAlert({ synthetic: true });
      const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
      const after = (await db.collection('alerts').doc(signalUid).get()).data();
      const outcome = await onAlertWrittenHandler(depsOf(db, { ai: fakeAi('valid', seen) }), signalUid, {
        before: undefined,
        after,
      });
      assert.equal(outcome, 'template');
      assert.equal(seen.calls, 0);
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.draftSource, 'Template');
      assert.ok((alert?.machineText.patient_en.headline as string).startsWith('Demo: '));
      assert.ok((alert?.machineText.patient_sw.headline as string).startsWith(DEMO_PREFIX_SW));
      assert.deepEqual(templateDraft(false).patient_en.headline, 'Health alert: {disease} in {county} County');
    });

    it('a late answer after Withdrawn is dropped', async () => {
      await approver(w, 'approver@example.com');
      const signalUid = await draftingAlert();
      const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
      const stale = (await db.collection('alerts').doc(signalUid).get()).data();
      await db.collection('alerts').doc(signalUid).update({ status: 'Withdrawn' });
      const outcome = await onAlertWrittenHandler(depsOf(db, { ai: fakeAi('valid', seen) }), signalUid, {
        before: undefined,
        after: stale,
      });
      assert.equal(outcome, 'dropped');
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Withdrawn');
      assert.deepEqual(alert?.machineText, {});
    });
  });

  describe('approve', () => {
    async function draftRow(alertUid: string, approverUid: string): Promise<void> {
      await db.collection('notifications').doc(`alertDrafted:${alertUid}-r0:${approverUid}`).set({
        templateKey: 'alertDrafted',
        resourceUid: alertUid,
        metadata: { actionType: 'Approval', actionStatus: 'Pending' },
      });
    }

    it('Approve takes the machine text as is and hands to delivery', async () => {
      const caller = await approver(w, 'approver@example.com');
      await db.collection('doctors').doc(caller.uid).set({ firstName: 'Alex', lastName: 'Approver' });
      const topics = fakeTopics();
      await seedDraftAlert(db, 'alert-1');
      await draftRow('alert-1', caller.uid);
      const result = await approveAlertHandler(depsOf(db, { topics }), caller, {
        alertUid: 'alert-1',
        decision: 'Approve',
        draftRevision: 1,
        evidenceRevision: 0,
      });
      assert.deepEqual(result, { status: 'ok', alertUid: 'alert-1', decision: 'Approve' });
      const approved = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.deepEqual(approved?.approvedText, approved?.machineText);
      assert.equal(approved?.acceptedUnchanged, true);
      assert.deepEqual(approved?.editedKeys, []);
      assert.equal(approved?.decidedByUid, caller.uid);
      assert.equal(approved?.status, 'Approved');
      let delivery = (await db.collection('alertDeliveries').doc('alert-1').get()).data();
      assert.equal(delivery?.phase, 'Pending');
      const row = (await db.collection('notifications').doc(`alertDrafted:alert-1-r0:${caller.uid}`).get()).data();
      assert.equal(row?.metadata.actionStatus, 'Accepted');
      const outcome = await onAlertWrittenHandler(depsOf(db, { topics }), 'alert-1', {
        before: { ...approved, status: 'Draft' },
        after: approved,
      });
      assert.equal(outcome, 'delivered');
      const alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.equal(alert?.status, 'Delivered');
      assert.equal(alert?.deliveredTo, 'CliniciansAndPatients');
      delivery = (await db.collection('alertDeliveries').doc('alert-1').get()).data();
      assert.equal(delivery?.phase, 'Done');
      assert.equal(topics.sends.length, 2);
      const signal = (await db.collection('modelSignals').doc('20261027').get()).data();
      assert.equal(signal?.alertAcceptedUnchanged, 1);
    });

    it('a no-op redelivery never blocks a one-tap approve', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      const deps = depsOf(db);
      await onNotifiableEventWrittenHandler(deps, 'e-1', { before: undefined, after: {} });
      const redelivered = await onNotifiableEventWrittenHandler(deps, 'e-1', { before: undefined, after: {} });
      assert.equal(redelivered, 'unchanged');
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
      const drafting = (await db.collection('alerts').doc(signalUid).get()).data();
      await onAlertWrittenHandler(depsOf(db, { ai: fakeAi('valid', seen) }), signalUid, {
        before: undefined,
        after: drafting,
      });
      const result = await approveAlertHandler(depsOf(db, { topics: fakeTopics() }), caller, {
        alertUid: signalUid,
        decision: 'Approve',
        draftRevision: 1,
        evidenceRevision: 0,
      });
      assert.equal(result.status, 'ok');
    });

    it('ApproveEdited records keys and distance; Reject needs a reason', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1');
      const edited = modelTexts();
      edited.patient_en.body += ' Drink clean water.';
      const result = await approveAlertHandler(depsOf(db, { topics: fakeTopics() }), caller, {
        alertUid: 'alert-1',
        decision: 'ApproveEdited',
        draftRevision: 1,
        evidenceRevision: 0,
        editedText: edited,
      });
      assert.equal(result.decision, 'ApproveEdited');
      const alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.deepEqual(alert?.editedKeys, ['patient_en']);
      assert.ok((alert?.editDistance as number) > 0);
      assert.equal(alert?.acceptedUnchanged, false);

      await seedDraftAlert(db, 'alert-2');
      await refusedWith(
        approveAlertHandler(depsOf(db), caller, {
          alertUid: 'alert-2',
          decision: 'Reject',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'reasonRequired',
      );
      const rejected = await approveAlertHandler(depsOf(db), caller, {
        alertUid: 'alert-2',
        decision: 'Reject',
        draftRevision: 1,
        evidenceRevision: 0,
        reason: 'Duplicate of last week.',
      });
      assert.equal(rejected.decision, 'Reject');
      const delivery = await db.collection('alertDeliveries').doc('alert-2').get();
      assert.equal(delivery.exists, false);
    });

    it('stale revisions, second approvers and withdrawn alerts are refused', async () => {
      const first = await approver(w, 'approver@example.com');
      const second = await approver(w, 'approver2@example.com');
      await seedDraftAlert(db, 'alert-1');
      await refusedWith(
        approveAlertHandler(depsOf(db), first, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 0,
          evidenceRevision: 0,
        }),
        'draftChanged',
      );
      await refusedWith(
        approveAlertHandler(depsOf(db), first, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 1,
        }),
        'evidenceChanged',
      );
      await approveAlertHandler(depsOf(db, { topics: fakeTopics() }), first, {
        alertUid: 'alert-1',
        decision: 'Approve',
        draftRevision: 1,
        evidenceRevision: 0,
      });
      await refusedWith(
        approveAlertHandler(depsOf(db), second, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'alreadyDecided',
      );
      const replay = await approveAlertHandler(depsOf(db), first, {
        alertUid: 'alert-1',
        decision: 'Approve',
        draftRevision: 1,
        evidenceRevision: 0,
      });
      assert.equal(replay.status, 'ok');
      await seedDraftAlert(db, 'alert-w', { status: 'Withdrawn' });
      await refusedWith(
        approveAlertHandler(depsOf(db), first, {
          alertUid: 'alert-w',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'alertWithdrawn',
      );
    });

    it('an expired draft is expired in the transaction, then refused', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', { expiresAt: '2026-10-27T08:00:00.000Z' });
      await draftRow('alert-1', caller.uid);
      await refusedWith(
        approveAlertHandler(depsOf(db), caller, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'alertExpired',
      );
      const alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.equal(alert?.status, 'Expired');
      const row = (
        await db.collection('notifications').doc(`alertDrafted:alert-1-r0:${caller.uid}`).get()
      ).data();
      assert.equal(row?.metadata.actionStatus, 'Expired');
      const expired = (
        await db.collection('notifications').doc(`alertExpired:alert-1-r0:${caller.uid}`).get()
      ).data();
      assert.equal(expired?.templateKey, 'alertExpired');
    });

    it('self-approval and non-approvers are refused', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1');
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', caller.uid, {
        signalUid: 'alert-1',
      });
      await refusedWith(
        approveAlertHandler(depsOf(db), caller, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'selfApproval',
      );
      await refusedWith(
        approveAlertHandler(depsOf(db), w.doctor, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'notApprover',
      );
      const adminOnly = await account(emulatorDeps(), 'adminonly@example.com', { admin: true });
      await refusedWith(
        approveAlertHandler(depsOf(db), adminOnly, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'notApprover',
      );
    });

    it('two approvers at once: exactly one wins', async () => {
      const first = await approver(w, 'approver@example.com');
      const second = await approver(w, 'approver2@example.com');
      await seedDraftAlert(db, 'alert-1');
      const deps = depsOf(db, { topics: fakeTopics() });
      const [a, b] = await Promise.allSettled([
        approveAlertHandler(deps, first, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        approveAlertHandler(deps, second, {
          alertUid: 'alert-1',
          decision: 'Reject',
          draftRevision: 1,
          evidenceRevision: 0,
          reason: 'Racing.',
        }),
      ]);
      const won = [a, b].filter((r) => r.status === 'fulfilled');
      const lost = [a, b].filter((r) => r.status === 'rejected');
      assert.equal(won.length, 1);
      assert.equal(lost.length, 1);
      assert.equal((lost[0] as PromiseRejectedResult).reason.message, 'alreadyDecided');
      const alert = (await db.collection('alerts').doc('alert-1').get()).data();
      const deliveries = await db.collection('alertDeliveries').get();
      if (alert?.status === 'Rejected') {
        assert.equal(deliveries.size, 0);
      } else {
        assert.equal(alert?.status, 'Approved');
        assert.equal(deliveries.size, 1);
      }
    });

    it('a redraft from Withdrawn at zero evidence cannot be approved', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedEvent(db, 'e-1', { diseaseId: 'ebola_virus_disease', category: 'Immediate' });
      await seedLink(db, 'case-1', 'ebola_virus_disease', 'e-1', w.pathologist.uid);
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: undefined, after: {} });
      const signalUid = signalUidFor('ebola_virus_disease', NAIROBI, WEEK);
      await db.collection('notifiableEvents').doc('e-1').update({ status: 'Retracted' });
      await onNotifiableEventWrittenHandler(depsOf(db), 'e-1', { before: {}, after: {} });
      await requestAlertDraftHandler(depsOf(db), caller, { alertUid: signalUid });
      const seen: { calls: number; input?: AlertDraftInput } = { calls: 0 };
      const drafting = (await db.collection('alerts').doc(signalUid).get()).data();
      await onAlertWrittenHandler(depsOf(db, { ai: fakeAi('valid', seen) }), signalUid, {
        before: { ...drafting, status: 'Withdrawn', requestCount: 0 },
        after: drafting,
      });
      const draft = (await db.collection('alerts').doc(signalUid).get()).data();
      await refusedWith(
        approveAlertHandler(depsOf(db, { topics: fakeTopics() }), caller, {
          alertUid: signalUid,
          decision: 'Approve',
          draftRevision: draft?.draftRevision as number,
          evidenceRevision: draft?.evidenceRevision as number,
        }),
        'noEvidence',
      );
      const alert = (await db.collection('alerts').doc(signalUid).get()).data();
      assert.equal(alert?.status, 'Draft');
    });

    it('an ineligible disease is refused on every path, never broadcast', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', { diseaseId: 'tuberculosis' });
      await refusedWith(
        approveAlertHandler(depsOf(db, { topics: fakeTopics() }), caller, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'notEligible',
      );
      await seedDraftAlert(db, 'alert-2', {
        diseaseId: 'tuberculosis',
        status: 'Approved',
        decision: 'Approve',
        decidedByUid: caller.uid,
        decidedByName: 'Alex Approver',
        decidedAt: NOW_ISO,
        approvedText: modelTexts(),
        approvedEvidence: { confirmedCount: 1, weekStart: '2026-10-26' },
      });
      await db.collection('alertDeliveries').doc('alert-2').set({
        alertUid: 'alert-2',
        phase: 'Pending',
        heldReason: '',
        leaseOwner: '',
        leaseUntil: '',
        clinicianCursor: '',
        cliniciansNotified: 0,
        patientsNotBefore: '',
        topicClaims: { en: '', sw: '' },
        topicSentAt: { en: '', sw: '' },
        messageIds: { en: '', sw: '' },
        createdAt: NOW_ISO,
        lastUpdatedAt: NOW_ISO,
      });
      const topics = fakeTopics();
      const outcome = await deliverAlert(depsOf(db, { topics }), 'alert-2');
      assert.equal(outcome, 'ineligible');
      assert.equal(topics.sends.length, 0);
      const delivery = (await db.collection('alertDeliveries').doc('alert-2').get()).data();
      assert.equal(delivery?.phase, 'Pending');
      assert.equal(delivery?.leaseOwner, '');
    });

    it('a claim without admin is refused even with a registry row', async () => {
      const caller = await account(emulatorDeps(), 'claimonly@example.com', {});
      await db.collection('alertApprovers').doc(caller.uid).set({
        uid: caller.uid,
        grantedByUid: caller.uid,
        grantedAt: NOW_ISO,
        fcmTokens: [],
        language: 'en',
        lastUpdatedAt: NOW_ISO,
      });
      await seedDraftAlert(db, 'alert-1');
      await refusedWith(
        approveAlertHandler(depsOf(db), caller, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'notApprover',
      );
    });

    it("a redraft under the approver's hand refuses the stale tap", async () => {
      const first = await approver(w, 'approver@example.com');
      const second = await approver(w, 'approver2@example.com');
      await seedDraftAlert(db, 'alert-1');
      await requestAlertDraftHandler(depsOf(db), first, { alertUid: 'alert-1' });
      await refusedWith(
        approveAlertHandler(depsOf(db), second, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        'notReady',
      );
    });

    it('approval racing the expiry sweep always reports the expiry', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', { expiresAt: '2026-10-27T08:00:00.000Z' });
      const deps = depsOf(db, { topics: fakeTopics() });
      const [approval] = await Promise.allSettled([
        approveAlertHandler(deps, caller, {
          alertUid: 'alert-1',
          decision: 'Approve',
          draftRevision: 1,
          evidenceRevision: 0,
        }),
        runAlertSweep(deps, NOW),
      ]);
      assert.equal(approval.status, 'rejected');
      assert.equal((approval as PromiseRejectedResult).reason.message, 'alertExpired');
      const alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.equal(alert?.status, 'Expired');
      assert.equal(alert?.decidedAt, '');
    });
  });

  describe('redraft', () => {
    it('redrafts a Rejected alert and caps rounds at three', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', { status: 'Rejected', decision: 'Reject' });
      const result = await requestAlertDraftHandler(depsOf(db), caller, { alertUid: 'alert-1' });
      assert.deepEqual(result, { status: 'redrafting', alertUid: 'alert-1' });
      const alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.equal(alert?.status, 'Drafting');
      assert.equal(alert?.requestCount, 1);
      assert.equal(alert?.decision, '');
      await db.collection('alerts').doc('alert-1').update({ status: 'Draft', requestCount: 3 });
      await refusedWith(requestAlertDraftHandler(depsOf(db), caller, { alertUid: 'alert-1' }), 'redraftLimit');
      await db.collection('alerts').doc('alert-1').update({ status: 'Approved', requestCount: 0 });
      await refusedWith(requestAlertDraftHandler(depsOf(db), caller, { alertUid: 'alert-1' }), 'invalidState');
    });

    it('redrafts from Expired and Withdrawn', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', { status: 'Expired' });
      await requestAlertDraftHandler(depsOf(db), caller, { alertUid: 'alert-1' });
      let alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.equal(alert?.status, 'Drafting');
      await db.collection('alerts').doc('alert-1').update({ status: 'Withdrawn' });
      await requestAlertDraftHandler(depsOf(db), caller, { alertUid: 'alert-1' });
      alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.equal(alert?.status, 'Drafting');
      assert.equal(alert?.requestCount, 2);
    });
  });

  describe('deliver', () => {
    async function approvedAlert(
      extra: Record<string, unknown> = {},
      deliveryExtra: Record<string, unknown> = {},
    ): Promise<string> {
      await seedDraftAlert(db, 'alert-1', {
        status: 'Approved',
        decision: 'Approve',
        decidedByUid: 'approver-1',
        decidedByName: 'Alex Approver',
        decidedAt: NOW_ISO,
        approvedText: modelTexts(),
        approvedEvidence: {
          confirmedCount: 3,
          baselineMean: 1,
          baselineSd: 0.5,
          threshold: 2,
          floor: 5,
          windowWeeks: 8,
          multiplier: 2,
          ageBandCounts: { '25-44': 3 },
          manualRequests: 0,
          categoryVerified: false,
          mappingVerified: true,
          categorySourceId: 'S1',
          weekStart: '2026-10-26',
        },
        acceptedUnchanged: true,
        ...extra,
      });
      await db.collection('alertDeliveries').doc('alert-1').set({
        alertUid: 'alert-1',
        phase: 'Pending',
        heldReason: '',
        leaseOwner: '',
        leaseUntil: '',
        clinicianCursor: '',
        cliniciansNotified: 0,
        patientsNotBefore: '',
        topicClaims: { en: '', sw: '' },
        topicSentAt: { en: '', sw: '' },
        messageIds: { en: '', sw: '' },
        createdAt: NOW_ISO,
        lastUpdatedAt: NOW_ISO,
        ...deliveryExtra,
      });
      return 'alert-1';
    }

    it('writes rows only for the county, once each, then releases to patients', async () => {
      await seedPractitioner(db, 'doc-nairobi', NAIROBI_NAME, 'en');
      await seedPractitioner(db, 'doc-nairobi-sw', NAIROBI_NAME, 'sw');
      await seedPractitioner(db, 'doc-mombasa', MOMBASA_NAME, 'sw');
      const topics = fakeTopics();
      const uid = await approvedAlert();
      const outcome = await deliverAlert(depsOf(db, { topics }), uid);
      assert.equal(outcome, 'delivered');
      const row = (await db.collection('notifications').doc(`alertDeliveredClinician:${uid}:doc-nairobi`).get()).data();
      assert.equal(row?.templateKey, 'alertDeliveredClinician');
      assert.deepEqual(row?.templateArgs, { diseaseId: 'ebola_virus_disease', countyId: String(NAIROBI) });
      const swahili = (
        await db.collection('notifications').doc(`alertDeliveredClinician:${uid}:doc-nairobi-sw`).get()
      ).data();
      assert.equal(swahili?.templateKey, 'alertDeliveredClinician');
      const elsewhere = await db
        .collection('notifications')
        .doc(`alertDeliveredClinician:${uid}:doc-mombasa`)
        .get();
      assert.equal(elsewhere.exists, false);
      const alert = (await db.collection('alerts').doc(uid).get()).data();
      assert.equal(alert?.deliveredTo, 'CliniciansAndPatients');
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.cliniciansNotified, 2);
      assert.equal(delivery?.phase, 'Done');
      assert.ok(delivery?.expireAt);
      const released = (await db.collection('publicAlerts').doc(uid).get()).data();
      assert.equal(released?.patientsReleased, true);
      assert.equal(topics.sends.length, 2);
      assert.deepEqual(
        topics.sends.map((s) => s.topic).sort(),
        [`alerts_patient_${NAIROBI}_en`, `alerts_patient_${NAIROBI}_sw`],
      );
      for (const send of topics.sends) {
        assert.equal(send.android.notification.tag, uid);
        assert.equal(send.apns.headers['apns-collapse-id'], uid);
      }
      const again = await deliverAlert(depsOf(db, { topics }), uid);
      assert.equal(again, 'done');
      assert.equal(topics.sends.length, 2);
    });

    it('renders numbers from the approved evidence, guidance verbatim', async () => {
      const topics = fakeTopics();
      const uid = await approvedAlert();
      await deliverAlert(depsOf(db, { topics }), uid);
      const released = (await db.collection('publicAlerts').doc(uid).get()).data();
      assert.equal(released?.diseaseNameEn, 'Ebola virus disease');
      assert.deepEqual(released?.clinicianCountyIds, [NAIROBI]);
      assert.equal(released?.issuedAt, NOW_ISO);
      assert.ok(!(released?.patientText.en.body as string).includes('{'));
      assert.ok(!(released?.patientText.sw.body as string).includes('{'));
      assert.equal(released?.patientGuidance.length, 2);
      assert.ok((released?.sources as unknown[]).length > 0);
      const brief = (
        await db.collection('publicAlerts').doc(uid).collection('doctor').doc('brief').get()
      ).data();
      assert.equal(brief?.confirmedCount, 3);
      assert.equal(brief?.weekStart, '2026-10-26');
      assert.equal(brief?.rule, 'Immediate');
      assert.ok((brief?.clinicianText.en.body as string).includes('3'));
      assert.ok(!(brief?.clinicianText.en.body as string).includes('{count}'));
      assert.equal(brief?.clinicianGuidance.length, 2);
    });

    it('the switch holds the delivery with its cursor and resumes it', async () => {
      await seedPractitioner(db, 'doc-nairobi', NAIROBI_NAME, 'en');
      const uid = await approvedAlert();
      const held = await deliverAlert(depsOf(db, { topics: fakeTopics(), config: allOff }), uid);
      assert.equal(held, 'held');
      let delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.phase, 'Held');
      assert.equal(delivery?.heldReason, 'KillSwitch');
      const topics = fakeTopics();
      const outcome = await deliverAlert(
        depsOf(db, { topics, now: new Date('2026-10-27T09:03:00.000Z') }),
        uid,
      );
      assert.equal(outcome, 'delivered');
      delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.phase, 'Done');
    });

    it('a held runner keeps its lease; a foreign lease is left alone', async () => {
      const uid = await approvedAlert(
        {},
        { leaseUntil: '2026-10-27T09:05:00.000Z', leaseOwner: 'someone-else' },
      );
      const outcome = await deliverAlert(depsOf(db, { topics: fakeTopics() }), uid);
      assert.equal(outcome, 'leased');
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.leaseOwner, 'someone-else');
    });

    it('CliniciansOnly and retracted alerts stop before patients', async () => {
      const caller = await approver(w, 'approver@example.com');
      const topics = fakeTopics();
      const chosen = await approvedAlert({ audience: 'CliniciansOnly' });
      await deliverAlert(depsOf(db, { topics }), chosen);
      let alert = (await db.collection('alerts').doc(chosen).get()).data();
      assert.equal(alert?.deliveredTo, 'CliniciansOnly');
      assert.equal(topics.sends.length, 0);
      const quiet = await db.collection('notifications').doc(`alertDeliveryStopped:${chosen}:${caller.uid}`).get();
      assert.equal(quiet.exists, false);

      await db.collection('alerts').doc('alert-2').delete();
      await db.collection('alertDeliveries').doc('alert-2').delete();
      await seedDraftAlert(db, 'alert-2', {
        status: 'Approved',
        decision: 'Approve',
        decidedByUid: caller.uid,
        decidedByName: 'Alex Approver',
        decidedAt: NOW_ISO,
        approvedText: modelTexts(),
        approvedEvidence: { confirmedCount: 1, weekStart: '2026-10-26' },
        evidenceRetracted: true,
      });
      await db.collection('alertDeliveries').doc('alert-2').set({
        alertUid: 'alert-2',
        phase: 'Pending',
        heldReason: '',
        leaseOwner: '',
        leaseUntil: '',
        clinicianCursor: '',
        cliniciansNotified: 0,
        patientsNotBefore: '',
        topicClaims: { en: '', sw: '' },
        topicSentAt: { en: '', sw: '' },
        messageIds: { en: '', sw: '' },
        createdAt: NOW_ISO,
        lastUpdatedAt: NOW_ISO,
      });
      await deliverAlert(depsOf(db, { topics }), 'alert-2');
      alert = (await db.collection('alerts').doc('alert-2').get()).data();
      assert.equal(alert?.deliveredTo, 'CliniciansOnly');
      const stopped = (
        await db.collection('notifications').doc(`alertDeliveryStopped:alert-2:${caller.uid}`).get()
      ).data();
      assert.equal(stopped?.templateKey, 'alertDeliveryStopped');
    });

    it('patients release only after the delay and within the resume bound', async () => {
      const topics = fakeTopics();
      const uid = await approvedAlert();
      const waiting = await deliverAlert(depsOf(db, { topics, patientDelayMin: 30 }), uid);
      assert.equal(waiting, 'waiting');
      assert.equal(topics.sends.length, 0);
      const later = await deliverAlert(
        depsOf(db, { topics, patientDelayMin: 30, now: new Date('2026-10-27T09:31:00.000Z') }),
        uid,
      );
      assert.equal(later, 'delivered');
      assert.equal(topics.sends.length, 2);
    });

    it('a stale delivery stops with row 44', async () => {
      await approver(w, 'approver@example.com');
      const topics = fakeTopics();
      const uid = await approvedAlert({ decidedAt: '2026-10-25T09:00:00.000Z' });
      await deliverAlert(depsOf(db, { topics }), uid);
      const alert = (await db.collection('alerts').doc(uid).get()).data();
      assert.equal(alert?.deliveredTo, 'CliniciansOnly');
      assert.equal(topics.sends.length, 0);
    });

    it('one send per language; claims are stored as {id, at}', async () => {
      const topics = fakeTopics();
      const uid = await approvedAlert();
      await deliverAlert(depsOf(db, { topics }), uid);
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      for (const language of ['en', 'sw'] as const) {
        const claim = (delivery?.topicClaims as Record<string, { id: string; at: string }>)[language];
        assert.match(claim.id, /^[0-9a-f-]{36}$/);
        assert.ok(Number.isFinite(Date.parse(claim.at)));
      }
      assert.equal(topics.sends.length, 2);
    });

    it('an eleven-minute-old claim re-sends once the earlier language is sent', async () => {
      const topics = fakeTopics();
      const uid = await approvedAlert(
        {},
        {
          phase: 'Patients',
          topicSentAt: { en: NOW_ISO, sw: '' },
          topicClaims: { sw: { id: 'alert-1-stale', at: '2026-10-27T08:49:00.000Z' } },
        },
      );
      await db.collection('publicAlerts').doc(uid).set({ patientsReleased: true });
      const outcome = await deliverAlert(depsOf(db, { topics }), uid);
      assert.equal(outcome, 'delivered');
      assert.equal(topics.sends.length, 1);
      assert.equal(topics.sends[0].topic, `alerts_patient_${NAIROBI}_sw`);
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.notEqual(
        (delivery?.topicClaims as Record<string, { id: string }>).sw.id,
        'alert-1-stale',
      );
    });

    it('a five-minute-old foreign claim is left alone and the runner waits', async () => {
      const topics = fakeTopics();
      const uid = await approvedAlert(
        {},
        {
          phase: 'Patients',
          topicSentAt: { en: '', sw: '' },
          topicClaims: { en: { id: 'alert-1-other', at: '2026-10-27T08:55:00.000Z' } },
        },
      );
      await db.collection('publicAlerts').doc(uid).set({ patientsReleased: true });
      const outcome = await deliverAlert(depsOf(db, { topics }), uid);
      assert.equal(outcome, 'waiting');
      assert.equal(topics.sends.length, 0);
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(
        (delivery?.topicClaims as Record<string, { id: string }>).en.id,
        'alert-1-other',
      );
      assert.equal((delivery?.topicSentAt as Record<string, string>).en, '');
    });

    it('a transient failure releases the claim so the retry can re-claim', async () => {
      const topics = fakeTopics(1);
      const uid = await approvedAlert(
        {},
        { phase: 'Patients', topicSentAt: { en: NOW_ISO, sw: '' } },
      );
      await db.collection('publicAlerts').doc(uid).set({ patientsReleased: true });
      const failed = await deliverAlert(depsOf(db, { topics }), uid);
      assert.equal(failed, 'sendFailed');
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal((delivery?.topicClaims as Record<string, unknown>).sw, '');
      const done = await deliverAlert(
        depsOf(db, { topics, now: new Date('2026-10-27T09:03:00.000Z') }),
        uid,
      );
      assert.equal(done, 'delivered');
      assert.equal(topics.sends.length, 1);
      assert.equal(topics.sends[0].topic, `alerts_patient_${NAIROBI}_sw`);
    });

    it('a second runner mid-send takes the lease but never double-sends', async () => {
      const uid = await approvedAlert(
        {},
        { phase: 'Patients', topicSentAt: { en: '', sw: NOW_ISO } },
      );
      await db.collection('publicAlerts').doc(uid).set({ patientsReleased: true });
      let releaseSend!: () => void;
      const gate = new Promise<void>((resolve) => {
        releaseSend = resolve;
      });
      const sends: TopicMessage[] = [];
      let inFlight = 0;
      const topics = {
        sends,
        send: async (message: TopicMessage): Promise<string> => {
          inFlight++;
          await gate;
          sends.push(message);
          return `message-${sends.length}`;
        },
      };
      const first = deliverAlert(depsOf(db, { topics }), uid);
      for (let waited = 0; inFlight === 0 && waited < 200; waited++) {
        await new Promise((r) => setTimeout(r, 5));
      }
      assert.equal(inFlight, 1);
      const second = await deliverAlert(
        depsOf(db, { topics, now: new Date('2026-10-27T09:03:00.000Z') }),
        uid,
      );
      assert.equal(second, 'waiting');
      releaseSend();
      assert.equal(await first, 'leaseLost');
      assert.equal(sends.length, 1);
      assert.equal(sends[0].topic, `alerts_patient_${NAIROBI}_en`);
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.notEqual((delivery?.topicSentAt as Record<string, string>).en, '');
      const retry = await deliverAlert(
        depsOf(db, { topics, now: new Date('2026-10-27T09:06:00.000Z') }),
        uid,
      );
      assert.equal(retry, 'delivered');
      assert.equal(sends.length, 1);
    });

    it('a runner takes over an expired lease mid-run and finishes it', async () => {
      await seedPractitioner(db, 'doc-a', NAIROBI_NAME, 'en');
      await seedPractitioner(db, 'doc-b', NAIROBI_NAME, 'sw');
      await seedPractitioner(db, 'doc-c', NAIROBI_NAME, 'en');
      const topics = fakeTopics();
      const uid = await approvedAlert(
        {},
        {
          phase: 'Clinicians',
          leaseOwner: 'dead-runner',
          leaseUntil: '2026-10-27T08:00:00.000Z',
          clinicianCursor: 'doc-a',
          cliniciansNotified: 1,
        },
      );
      await db.collection('publicAlerts').doc(uid).set({ patientsReleased: false });
      const outcome = await deliverAlert(depsOf(db, { topics }), uid);
      assert.equal(outcome, 'delivered');
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.cliniciansNotified, 3);
      assert.equal(delivery?.phase, 'Done');
      const resumed = (
        await db.collection('notifications').doc(`alertDeliveredClinician:${uid}:doc-c`).get()
      ).data();
      assert.equal(resumed?.templateKey, 'alertDeliveredClinician');
    });

    it('a switch flipped between pages holds with the cursor, then resumes', async () => {
      for (let i = 0; i < 205; i += 1) {
        await seedPractitioner(db, `doc-${i}`, NAIROBI_NAME, 'en');
      }
      const topics = fakeTopics();
      const uid = await approvedAlert();
      let checks = 0;
      // On for the render and the first page, off from the second page on.
      const flipping = {
        enabled: (): boolean => {
          checks++;
          return checks <= 2;
        },
      };
      const held = await deliverAlert(depsOf(db, { topics, config: flipping }), uid);
      assert.equal(held, 'held');
      let delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.phase, 'Held');
      assert.equal(delivery?.heldReason, 'KillSwitch');
      assert.equal(delivery?.cliniciansNotified, 200);
      assert.notEqual(delivery?.clinicianCursor, '');
      const outcome = await deliverAlert(
        depsOf(db, { topics, now: new Date('2026-10-27T09:03:00.000Z') }),
        uid,
      );
      assert.equal(outcome, 'delivered');
      delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.cliniciansNotified, 205);
      assert.equal(delivery?.phase, 'Done');
    });

    it('the patient push speaks Swahili on the Swahili topic', async () => {
      const topics = fakeTopics();
      const uid = await approvedAlert();
      await deliverAlert(depsOf(db, { topics }), uid);
      const sw = topics.sends.find((s) => s.topic === `alerts_patient_${NAIROBI}_sw`);
      assert.ok(sw);
      assert.ok(sw.notification.body.includes('Tahadhari ya afya'));
      assert.ok(sw.notification.body.includes('Ebola'));
      assert.ok(!sw.notification.body.includes('{'));
      const en = topics.sends.find((s) => s.topic === `alerts_patient_${NAIROBI}_en`);
      assert.ok(en?.notification.body.includes('Health alert'));
    });

    it('notifies past two hundred clinicians across page boundaries', async () => {
      for (let i = 0; i < 205; i += 1) {
        await seedPractitioner(db, `doc-${i}`, NAIROBI_NAME, i % 2 === 0 ? 'en' : 'sw');
      }
      const topics = fakeTopics();
      const uid = await approvedAlert();
      const outcome = await deliverAlert(depsOf(db, { topics }), uid);
      assert.equal(outcome, 'delivered');
      const delivery = (await db.collection('alertDeliveries').doc(uid).get()).data();
      assert.equal(delivery?.cliniciansNotified, 205);
      assert.notEqual(delivery?.clinicianCursor, '');
      const last = (
        await db.collection('notifications').doc(`alertDeliveredClinician:${uid}:doc-204`).get()
      ).data();
      assert.equal(last?.templateKey, 'alertDeliveredClinician');
    });

    it('synthetic alerts reach only demo accounts and the demo topic', async () => {
      await seedPractitioner(db, 'doc-nairobi', NAIROBI_NAME, 'en');
      await db.collection('demoAccounts').doc('demo-1').set({ county: NAIROBI_NAME, language: 'sw' });
      await db.collection('demoAccounts').doc('demo-2').set({ county: MOMBASA_NAME, language: 'en' });
      const topics = fakeTopics();
      const uid = await approvedAlert({ synthetic: true });
      await deliverAlert(depsOf(db, { topics, synthetic: true }), uid);
      const demo = (
        await db.collection('notifications').doc(`alertDeliveredClinicianDemo:${uid}:demo-1`).get()
      ).data();
      assert.equal(demo?.templateKey, 'alertDeliveredClinicianDemo');
      const real = await db.collection('notifications').doc(`alertDeliveredClinician:${uid}:doc-nairobi`).get();
      assert.equal(real.exists, false);
      const other = await db.collection('notifications').doc(`alertDeliveredClinicianDemo:${uid}:demo-2`).get();
      assert.equal(other.exists, false);
      assert.deepEqual(
        topics.sends.map((s) => s.topic).sort(),
        [`alerts_patient_demo_${NAIROBI}_en`, `alerts_patient_demo_${NAIROBI}_sw`],
      );
    });

    it('push copy names only the bundled disease and county', async () => {
      const topics = fakeTopics();
      const uid = await approvedAlert();
      await deliverAlert(depsOf(db, { topics }), uid);
      const bodies = Object.fromEntries(topics.sends.map((s) => [s.topic, s.notification.body]));
      assert.equal(
        bodies[`alerts_patient_${NAIROBI}_en`],
        'Health alert: Ebola virus disease in Nairobi County. Open Tabibu for guidance.',
      );
      assert.ok(!/\d/.test(bodies[`alerts_patient_${NAIROBI}_en`] as string));
      assert.ok(!(bodies[`alerts_patient_${NAIROBI}_en`] as string).includes('you'));
    });
  });

  describe('sweep', () => {
    it('reminds once for an Immediate draft waiting over an hour', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', { draftedAt: '2026-10-27T07:30:00.000Z' });
      const counts = await runAlertSweep(depsOf(db, { topics: fakeTopics() }), NOW);
      assert.equal(counts.reminded, 1);
      const alert = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.notEqual(alert?.reminderSentAt, '');
      const row = (
        await db.collection('notifications').doc(`alertDraftReminder:alert-1-r0:${caller.uid}`).get()
      ).data();
      assert.equal(row?.priority, 'High');
      const again = await runAlertSweep(depsOf(db, { topics: fakeTopics() }), NOW);
      assert.equal(again.reminded, 0);
    });

    it('expires past-due drafts and drafts stuck Drafting', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', { expiresAt: '2026-10-27T08:00:00.000Z' });
      await seedDraftAlert(db, 'alert-2', {
        status: 'Drafting',
        machineText: {},
        draftedAt: '',
        expiresAt: '',
        requestedAt: '2026-10-27T08:00:00.000Z',
      });
      const counts = await runAlertSweep(depsOf(db, { topics: fakeTopics() }), NOW);
      assert.equal(counts.expired, 1);
      assert.equal(counts.drafted, 1);
      const expired = (await db.collection('alerts').doc('alert-1').get()).data();
      assert.equal(expired?.status, 'Expired');
      const stuck = (await db.collection('alerts').doc('alert-2').get()).data();
      assert.equal(stuck?.status, 'Draft');
      assert.equal(stuck?.draftSource, 'Template');
      assert.equal(stuck?.failureReason, 'Stale');
      const row = (
        await db.collection('notifications').doc(`alertDrafted:alert-2-r0:${caller.uid}`).get()
      ).data();
      assert.equal(row?.templateKey, 'alertDrafted');
    });

    it('resumes held deliveries and pages Held past fifteen minutes once', async () => {
      const caller = await approver(w, 'approver@example.com');
      await seedDraftAlert(db, 'alert-1', {
        status: 'Approved',
        decision: 'Approve',
        decidedByUid: caller.uid,
        decidedByName: 'Alex Approver',
        decidedAt: NOW_ISO,
        approvedText: modelTexts(),
        approvedEvidence: { confirmedCount: 1, weekStart: '2026-10-26' },
      });
      await db.collection('alertDeliveries').doc('alert-1').set({
        alertUid: 'alert-1',
        phase: 'Held',
        heldReason: 'KillSwitch',
        leaseOwner: '',
        leaseUntil: '',
        clinicianCursor: '',
        cliniciansNotified: 0,
        patientsNotBefore: '',
        topicClaims: { en: '', sw: '' },
        topicSentAt: { en: '', sw: '' },
        messageIds: { en: '', sw: '' },
        createdAt: '2026-10-27T08:00:00.000Z',
        lastUpdatedAt: '2026-10-27T08:00:00.000Z',
      });
      const counts = await runAlertSweep(depsOf(db, { topics: fakeTopics() }), NOW);
      assert.equal(counts.resumed, 1);
      const delivery = (await db.collection('alertDeliveries').doc('alert-1').get()).data();
      assert.equal(delivery?.phase, 'Done');

      await db.collection('alertDeliveries').doc('alert-2').set({
        alertUid: 'alert-2',
        phase: 'Held',
        heldReason: 'KillSwitch',
        leaseOwner: '',
        leaseUntil: '',
        clinicianCursor: '',
        cliniciansNotified: 0,
        patientsNotBefore: '',
        topicClaims: { en: '', sw: '' },
        topicSentAt: { en: '', sw: '' },
        messageIds: { en: '', sw: '' },
        createdAt: '2026-10-27T08:00:00.000Z',
        lastUpdatedAt: '2026-10-27T08:00:00.000Z',
      });
      const held = await runAlertSweep(depsOf(db, { topics: fakeTopics(), config: allOff }), NOW);
      assert.equal(held.held, 1);
      const row = (
        await db.collection('notifications').doc(`alertDeliveryHeld:alert-2:${caller.uid}`).get()
      ).data();
      assert.equal(row?.priority, 'High');
      const again = await runAlertSweep(depsOf(db, { topics: fakeTopics(), config: allOff }), NOW);
      assert.equal(again.held, 0);
    });
  });
});
