import assert from 'node:assert/strict';

import type { Firestore } from 'firebase-admin/firestore';

import { resetEmulators } from './emulator.test-support';
import { seedWorld, type World } from './case.test-support';
import { aggregateModelSignals, nairobiDayWindow } from './model-signals';

const DAY = '20261026';
const T10 = '2026-10-26T10:00:00.000Z';
const T11 = '2026-10-26T11:00:00.000Z';
const T12 = '2026-10-26T12:00:00.000Z';

describe('model-signals', () => {
  let db: Firestore;

  beforeEach(async () => {
    await resetEmulators();
    const w: World = await seedWorld();
    db = w.deps.db;
  });

  async function seedDay(): Promise<void> {
    await db.collection('cases').doc('c1').collection('preread').doc('r1').set({
      status: 'Ready',
      requestedAt: T10,
      readyAt: T11,
      failureReason: '',
    });
    // A failure is a completion: it carries the stamp of when it was recorded.
    await db.collection('cases').doc('c2').collection('preread').doc('r2').set({
      status: 'Failed',
      requestedAt: T10,
      readyAt: T11,
      failureReason: 'ServiceError',
    });
    await db.collection('cases').doc('c1').collection('prereadScores').doc('r1').set({
      acceptedUnchanged: true,
      overall: 5,
      findingsVerdict: 'Agree',
      impressionVerdict: 'Agree',
      confidenceBand: 'High',
      scoredAt: T12,
    });
    await db.collection('cases').doc('c2').collection('prereadScores').doc('r2').set({
      acceptedUnchanged: false,
      overall: 3,
      findingsVerdict: 'Disagree',
      impressionVerdict: 'Agree',
      confidenceBand: 'Low',
      scoredAt: T12,
    });
    await db.collection('cases').doc('c1').collection('reportProvenance').doc('v1').set({
      editRate: 0.2,
      acceptedUnchanged: false,
      hintShownDiseaseIds: ['ebola_virus_disease'],
      createdAt: T11,
    });
    await db.collection('cases').doc('c1').collection('reports').doc('v1').set({
      notifiableFindings: [{ diseaseId: 'ebola_virus_disease', alertRequested: false }],
    });
    await db.collection('cases').doc('c2').collection('reportProvenance').doc('v1').set({
      editRate: 0,
      acceptedUnchanged: true,
      hintShownDiseaseIds: ['cholera'],
      createdAt: T11,
    });
    await db.collection('cases').doc('c2').collection('reports').doc('v1').set({
      notifiableFindings: [],
    });
    await db.collection('cases').doc('c1').collection('reportDrafts').doc('p1').set({
      startedFromPreread: true,
      createdAt: T10,
    });
    await db.collection('cases').doc('c2').collection('reportDrafts').doc('p2').set({
      startedFromPreread: false,
      createdAt: T10,
    });
    await db.collection('cases').doc('c1').collection('reportTexts').doc('v1_Translation_en').set({
      kind: 'Translation',
      status: 'Approved',
      requestedAt: T10,
      readyAt: T11,
      approvedAt: T12,
      acceptedUnchanged: true,
      editDistance: 0,
      editedSegmentKeys: [],
      languageMismatch: false,
      failureReason: '',
    });
    await db.collection('cases').doc('c2').collection('reportTexts').doc('v1_Explanation_sw').set({
      kind: 'Explanation',
      status: 'Failed',
      requestedAt: T10,
      readyAt: T11,
      approvedAt: '',
      failureReason: 'NumberCheck',
    });
    await db.collection('appointments').doc('a1').collection('intake').doc('summary').set({
      status: 'Ready',
      requestedAt: T10,
      readyAt: T11,
      inputLanguage: 'en',
      inputMode: 'Typed',
      failureReason: '',
    });
    await db.collection('appointments').doc('a2').collection('intake').doc('summary').set({
      status: 'Ready',
      requestedAt: T10,
      readyAt: T11,
      inputLanguage: 'sw',
      inputMode: 'Voice',
      transcriptLanguage: 'sw',
      transcriptAcceptedUnchanged: true,
      transcriptEditDistance: 0.2,
      failureReason: '',
    });
    await db.collection('conversations').doc('c1').collection('messages').doc('m1').set({
      kind: 'Voice',
      deliveredAt: T10,
      transcriptStatus: 'Ready',
      transcriptLanguage: 'en',
      identifierFlagged: false,
      voiceDurationMs: 45000,
      inputMode: 'Voice',
    });
    await db
      .collection('conversations')
      .doc('c1')
      .collection('messages')
      .doc('m1')
      .collection('transcript')
      .doc('machine')
      .set({ lastUpdatedAt: T11 });
    await db
      .collection('conversations')
      .doc('c1')
      .collection('messages')
      .doc('m1')
      .collection('transcript')
      .doc('shared')
      .set({ acceptedUnchanged: true });
    await db.collection('conversations').doc('c1').collection('messages').doc('m2').set({
      kind: 'Voice',
      deliveredAt: T10,
      transcriptStatus: 'Failed',
      transcriptLanguage: '',
      identifierFlagged: true,
      voiceDurationMs: 90000,
      inputMode: 'Voice',
    });
    await db.collection('cases').doc('c1').collection('riskCheck').doc('current').set({
      status: 'Ready',
      requestedAt: T10,
      readyAt: T11,
      inputLanguage: 'en',
      suggestedLabTestIds: ['a', 'b'],
      advisoryKey: 'K',
      failureReason: '',
    });
    await db.collection('cases').doc('c2').collection('riskCheck').doc('current').set({
      status: 'Failed',
      requestedAt: T10,
      readyAt: '',
      inputLanguage: '',
      suggestedLabTestIds: [],
      advisoryKey: '',
      failureReason: 'ServiceError',
    });
    await db.collection('cases').doc('c1').collection('notesTranslation').doc('current').set({
      status: 'Ready',
      requestedAt: T10,
      readyAt: T11,
      sourceLanguage: 'en',
      language: 'sw',
      failureReason: '',
    });
    await db.collection('alerts').doc('alert-1').set({
      draftSource: 'Model',
      failureReason: '',
      requestedAt: T10,
      draftedAt: T11,
      decidedAt: T12,
      decision: 'Approve',
      status: 'Delivered',
      acceptedUnchanged: true,
      editDistance: 0,
    });
    await db.collection('alerts').doc('alert-2').set({
      draftSource: 'Template',
      failureReason: 'ServiceError',
      requestedAt: T10,
      draftedAt: T11,
      decidedAt: '',
      decision: '',
      status: 'Draft',
      acceptedUnchanged: false,
      editDistance: 0,
    });
  }

  it('aggregates the previous day into counts, rates and percentiles', async () => {
    await seedDay();
    const result = await aggregateModelSignals({ db }, DAY);
    assert.deepEqual(result, { day: DAY });
    const doc = (await db.collection('modelSignals').doc(DAY).get()).data();
    assert.equal(doc?.day, DAY);
    assert.equal(doc?.preread.ready, 1);
    assert.equal(doc?.preread.failed, 1);
    assert.deepEqual(doc?.preread.failedByReason, { ServiceError: 1 });
    assert.equal(doc?.preread.latency.count, 1);
    assert.equal(doc?.preread.agreeRate, 0.5);
    assert.equal(doc?.preread.startedFromPrereadRate, 0.5);
    assert.equal(doc?.translation.ready, 1);
    assert.equal(doc?.translation.approved, 1);
    assert.equal(doc?.translation.acceptedUnchangedRate, 1);
    assert.equal(doc?.explanation.failed, 1);
    assert.equal(doc?.explanation.numberCheckFailures, 1);
    assert.equal(doc?.intake.ready, 2);
    assert.equal(doc?.speech.requests, 1);
    assert.equal(doc?.speech.acceptedUnchangedRate, 1);
    assert.equal(doc?.voice.notes, 2);
    assert.equal(doc?.voice.shareRate, 0.5);
    assert.equal(doc?.voice.sharedUnchangedRate, 1);
    assert.equal(doc?.voice.identifierFlagRate, 0.5);
    assert.equal(doc?.risk.ready, 1);
    assert.equal(doc?.risk.advisoryRate, 1);
    assert.equal(doc?.risk.suggestedTests, 2);
    assert.equal(doc?.notesTranslation.ready, 1);
    assert.deepEqual(doc?.notesTranslation.pairMix, { 'en->sw': 1 });
    assert.equal(doc?.alerts.drafted, 2);
    assert.equal(doc?.alerts.fallbackRate, 0.5);
    assert.deepEqual(doc?.alerts.fallbackByReason, { ServiceError: 1 });
    assert.equal(doc?.alerts.decided, 1);
    assert.equal(doc?.alerts.acceptedUnchangedRate, 1);
    assert.equal(doc?.alerts.expiryRate, 0);
    assert.equal(doc?.hint.shown, 2);
    assert.equal(doc?.hint.marked, 1);
    assert.equal(doc?.hint.markedRate, 0.5);
  });

  it('merges without touching bumped counters, and reruns identically', async () => {
    await seedDay();
    await db.collection('modelSignals').doc(DAY).set({ day: DAY, alertDraftReady: 5 });
    await aggregateModelSignals({ db }, DAY);
    const doc = (await db.collection('modelSignals').doc(DAY).get()).data();
    assert.equal(doc?.alertDraftReady, 5);
    assert.equal(doc?.alerts.drafted, 2);
    await aggregateModelSignals({ db }, DAY);
    const rerun = (await db.collection('modelSignals').doc(DAY).get()).data();
    assert.deepEqual({ ...rerun, computedAt: '', lastUpdatedAt: '' }, { ...doc, computedAt: '', lastUpdatedAt: '' });
  });

  it('an expired alert counts as expired, never as decided', async () => {
    await seedDay();
    await db.collection('alerts').doc('alert-3').set({
      draftSource: 'Model',
      failureReason: '',
      requestedAt: T10,
      draftedAt: T11,
      decidedAt: '',
      decision: '',
      status: 'Expired',
      acceptedUnchanged: false,
      editDistance: 0,
      lastUpdatedAt: T12,
    });
    await aggregateModelSignals({ db }, DAY);
    const doc = (await db.collection('modelSignals').doc(DAY).get()).data();
    assert.equal(doc?.alerts.drafted, 3);
    assert.equal(doc?.alerts.decided, 1);
    assert.equal(doc?.alerts.expired, 1);
    assert.equal(doc?.alerts.expiryRate, 0.5);
    assert.equal(doc?.alerts.decisionLatency.count, 1);
  });

  it('a record stamped at the next midnight belongs to the next day', async () => {
    await seedDay();
    await db.collection('cases').doc('c3').collection('preread').doc('r3').set({
      status: 'Ready',
      requestedAt: '2026-10-26T20:00:00.000Z',
      readyAt: '2026-10-26T21:00:00.000Z',
      failureReason: '',
    });
    await aggregateModelSignals({ db }, DAY);
    const doc = (await db.collection('modelSignals').doc(DAY).get()).data();
    assert.equal(doc?.preread.ready, 1);
  });

  it('an empty day aggregates to zeros', async () => {
    await aggregateModelSignals({ db }, '20261025');
    const doc = (await db.collection('modelSignals').doc('20261025').get()).data();
    assert.equal(doc?.preread.ready, 0);
    assert.equal(doc?.alerts.drafted, 0);
    assert.equal(doc?.hint.markedRate, 0);
    const window = nairobiDayWindow('20261026');
    assert.equal(window.start, '2026-10-25T21:00:00.000Z');
    assert.equal(window.end, '2026-10-26T21:00:00.000Z');
  });
});
