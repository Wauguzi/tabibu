// cspell:ignore muse
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

import { AiError } from './ai';
import { BUCKET, resetEmulators } from './emulator.test-support';
import { seedWorld, type World } from './case.test-support';
import { sha256 } from './case-support';
import {
  REPORT_TEXT_PROMPT_VERSION,
  containsDenyPhrase,
  languageLooksLike,
  processQueuedReportText,
  sourceFieldsOf,
  sourceNumberSet,
  stableReportContent,
  validateReportText,
  type ReportSourceFields,
} from './report-text-worker';

const SOURCE: ReportSourceFields = {
  title: 'Lymph node histology',
  diagnosis: 'Metastatic carcinoma in 2 of 5 nodes.',
  comments: 'Largest deposit 1.2 mm.',
  measurements: { largestFocusMm: 1.2, tumourTiles: 2 },
};

describe('report-text validation', () => {
  it('accepts a plain restatement that only uses report numbers', () => {
    const text =
      'The report says metastatic carcinoma in 2 of 5 nodes. The largest deposit is about 1.2 mm.';
    assert.deepEqual(validateReportText(text, SOURCE, 'en'), { ok: true });
  });

  it('rejects a number the model invents', () => {
    const text =
      'The report says metastatic carcinoma in 9 of 5 nodes. The largest deposit is about 1.2 mm.';
    assert.equal(validateReportText(text, SOURCE, 'en').ok, false);
    assert.equal(
      (validateReportText(text, SOURCE, 'en') as { reason: string }).reason,
      'NumberCheck',
    );
  });

  it('rejects an advice phrase from the deny list', () => {
    assert.ok(containsDenyPhrase('You should take medicine tonight.'));
    const text =
      'The report says metastatic carcinoma in 2 of 5 nodes. You should see a specialist soon for treatment.';
    assert.equal(
      (validateReportText(text, SOURCE, 'en') as { reason: string }).reason,
      'AdvicePhrase',
    );
  });

  it('flags a language mismatch cheaply', () => {
    assert.equal(languageLooksLike('The report and the result are clear.', 'en'), true);
    assert.equal(languageLooksLike('Ripoti hii na matokeo ya wagonjwa ni wazi.', 'sw'), true);
    const enAsSw = validateReportText(
      'The report says metastatic carcinoma in 2 of 5 nodes with a largest deposit of 1.2 mm.',
      SOURCE,
      'sw',
    );
    assert.equal(enAsSw.ok, false);
    if (!enAsSw.ok) assert.equal(enAsSw.reason, 'LanguageMismatch');
  });

  it('sourceNumberSet includes measurement values', () => {
    const set = sourceNumberSet(SOURCE);
    assert.ok(set.has('2'));
    assert.ok(set.has('5'));
    assert.ok(set.has('1.2'));
  });
});

describe('processQueuedReportText', () => {
  let w: World;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
  });

  async function seedQueued(opts?: {
    enabled?: boolean;
    kind?: 'Explanation' | 'Translation';
    language?: 'en' | 'sw';
    mutateReport?: (r: Record<string, unknown>) => void;
    caseExtra?: Record<string, unknown>;
    onSource?: (source: ReportSourceFields) => void;
  }): Promise<{ caseUid: string; textUid: string; reportUid: string }> {
    const caseUid = randomUUID();
    const reportUid = 'v1';
    const kind = opts?.kind ?? 'Explanation';
    const language = opts?.language ?? 'en';
    const textUid = `${reportUid}_${kind}_${language}`;
    const report: Record<string, unknown> = {
      caseUid,
      version: 1,
      stage: 'Initial',
      orderNumber: '',
      testName: 'Histology',
      sampleCollectedAt: '',
      sampleReceivedAt: '',
      labAccessionNo: '',
      profile: 'Cancer',
      templateKey: 'Histology',
      title: SOURCE.title,
      diagnosisType: 'Final',
      diagnosis: SOURCE.diagnosis,
      comments: SOURCE.comments,
      responses: {},
      isCritical: false,
      measurements: SOURCE.measurements,
      addenda: [],
      amendmentReason: '',
      notifiableFindings: [],
      confirmatoryRequests: [],
      signedByTitle: 'Dr',
      signedByName: 'Path',
      signedByKmpdcNumber: '',
      signedByFacilityName: '',
      signatureSha256: 'sig',
    };
    opts?.mutateReport?.(report);
    const contentSha256 = sha256(stableReportContent(report));
    await w.deps.db.collection('cases').doc(caseUid).set({
      uid: caseUid,
      currentReportUid: reportUid,
      doctorUid: w.doctor.uid,
      pathologistUid: w.pathologist.uid,
      participantUids: [w.doctor.uid, w.pathologist.uid],
      ...opts?.caseExtra,
    });
    await w.deps.db.collection('cases').doc(caseUid).collection('reports').doc(reportUid).set({
      ...report,
      contentSha256,
    });
    await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).set({
      uid: textUid,
      caseUid,
      reportUid,
      reportVersion: 1,
      kind,
      language,
      sourceLanguage: 'en',
      detectedSourceLanguage: '',
      languageMismatch: false,
      sourceSha256: contentSha256,
      status: 'Queued',
      machineText: {},
      models: {},
      approverUid: kind === 'Explanation' ? w.doctor.uid : w.pathologist.uid,
      requestCount: 0,
      failureReason: '',
      requestedAt: '2026-11-03T00:00:00.000Z',
      readyAt: '',
      approvedAt: '',
      lastUpdatedAt: '2026-11-03T00:00:00.000Z',
    });
    await processQueuedReportText(
      { ...w.deps, bucket: BUCKET },
      caseUid,
      textUid,
      {
        enabled: opts?.enabled ?? true,
        generate: async ({ language: lang, source }) => ({
          // The fake records what the model would have been sent.
          ...(opts?.onSource?.(source) ?? {}),
          text:
            lang === 'sw'
              ? 'Ripoti inasema metastatic carcinoma katika nodes 2 kati ya 5. Deposit kubwa ni 1.2 mm.'
              : 'The signed report finds metastatic carcinoma in 2 of 5 nodes. The largest deposit measures 1.2 mm.',
          models: { reportText: 'muse-spark-1.3' },
        }),
      },
    );
    return { caseUid, textUid, reportUid };
  }

  it('writes Ready machineText for each language', async () => {
    const en = await seedQueued({ language: 'en' });
    const enDoc = (
      await w.deps.db.collection('cases').doc(en.caseUid).collection('reportTexts').doc(en.textUid).get()
    ).data();
    assert.equal(enDoc?.status, 'Ready');
    assert.ok(String(enDoc?.machineText?.en).includes('1.2'));
    assert.equal(enDoc?.models?.promptVersion, REPORT_TEXT_PROMPT_VERSION);
    assert.match(String(enDoc?.models?.note), /awaiting the doctor's approval/i);

    const sw = await seedQueued({ language: 'sw' });
    const swDoc = (
      await w.deps.db.collection('cases').doc(sw.caseUid).collection('reportTexts').doc(sw.textUid).get()
    ).data();
    assert.equal(swDoc?.status, 'Ready');
    assert.ok(String(swDoc?.machineText?.sw).length > 40);
  });

  it('rejects an invented number as Failed', async () => {
    const caseUid = randomUUID();
    const reportUid = 'v1';
    const textUid = `${reportUid}_Explanation_en`;
    const report = {
      caseUid,
      version: 1,
      stage: 'Initial',
      orderNumber: '',
      testName: 'Histology',
      sampleCollectedAt: '',
      sampleReceivedAt: '',
      labAccessionNo: '',
      profile: 'Cancer',
      templateKey: 'Histology',
      title: SOURCE.title,
      diagnosisType: 'Final',
      diagnosis: SOURCE.diagnosis,
      comments: SOURCE.comments,
      responses: {},
      isCritical: false,
      measurements: SOURCE.measurements,
      addenda: [],
      amendmentReason: '',
      notifiableFindings: [],
      confirmatoryRequests: [],
      signedByTitle: '',
      signedByName: '',
      signedByKmpdcNumber: '',
      signedByFacilityName: '',
      signatureSha256: '',
    };
    const contentSha256 = sha256(stableReportContent(report));
    await w.deps.db.collection('cases').doc(caseUid).set({ uid: caseUid });
    await w.deps.db.collection('cases').doc(caseUid).collection('reports').doc(reportUid).set({
      ...report,
      contentSha256,
    });
    await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).set({
      uid: textUid,
      caseUid,
      reportUid,
      kind: 'Explanation',
      language: 'en',
      sourceSha256: contentSha256,
      status: 'Queued',
      machineText: {},
      models: {},
      failureReason: '',
      requestedAt: '2026-11-03T00:00:00.000Z',
      readyAt: '',
      lastUpdatedAt: '2026-11-03T00:00:00.000Z',
    });
    await processQueuedReportText(
      { ...w.deps, bucket: BUCKET },
      caseUid,
      textUid,
      {
        enabled: true,
        generate: async () => ({
          text: 'The report invents 99 new nodes somehow and quotes 1.2 mm.',
          models: { reportText: 'muse-spark-1.3' },
        }),
      },
    );
    const doc = (
      await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).get()
    ).data();
    assert.equal(doc?.status, 'Failed');
    assert.equal(doc?.failureReason, 'NumberCheck');
  });

  it('a changed source hash is Stale', async () => {
    const { caseUid, textUid, reportUid } = await seedQueued();
    // Reset to Queued with a stale hash.
    await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).update({
      status: 'Queued',
      sourceSha256: 'not-the-report-hash',
      failureReason: '',
      machineText: {},
      readyAt: '',
    });
    await processQueuedReportText(
      { ...w.deps, bucket: BUCKET },
      caseUid,
      textUid,
      {
        enabled: true,
        generate: async () => {
          throw new Error('must not call');
        },
      },
    );
    const doc = (
      await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).get()
    ).data();
    assert.equal(doc?.status, 'Failed');
    assert.equal(doc?.failureReason, 'Stale');
    void reportUid;
  });

  it('the model is never sent the patient, the clinicians, the facility or the order', async () => {
    let sent: ReportSourceFields | undefined;
    await seedQueued({
      caseExtra: {
        patientName: 'Amina Wambui',
        doctorName: 'Dr Achieng Odhiambo',
        pathologistName: 'Wanjiru Kamau',
        doctorFacilityName: 'Mbagathi District Hospital',
        orderNumber: 'ODR-AO-AW-03112026-005',
      },
      mutateReport: (r) => {
        r.comments =
          'Amina Wambui, seen by Dr Odhiambo at Mbagathi District Hospital, order ODR-AO-AW-03112026-005, call 0712 345 678.';
      },
      onSource: (source) => {
        sent = source;
      },
    });

    assert.ok(sent);
    const all = `${sent.title} ${sent.diagnosis} ${sent.comments}`;
    for (const leak of ['Amina', 'Wambui', 'Mbagathi', 'ODR-AO-AW', '0712']) {
      assert.ok(!all.includes(leak), `"${leak}" reached the model`);
    }
  });

  it('a de-identification placeholder echoed by the model is refused', () => {
    const verdict = validateReportText(
      'The report finds metastatic carcinoma in 2 of 5 nodes for [NAME], the largest deposit being 1.2 mm.',
      SOURCE,
      'en',
    );
    assert.equal(verdict.ok, false);
    if (!verdict.ok) assert.equal(verdict.reason, 'OffSchema');
  });

  it('switch off does no work', async () => {
    const { caseUid, textUid } = await seedQueued({ enabled: false });
    const doc = (
      await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).get()
    ).data();
    assert.equal(doc?.status, 'Queued');
  });

  it('ignores a text that is already Ready', async () => {
    const { caseUid, textUid } = await seedQueued();
    let calls = 0;
    await processQueuedReportText(
      { ...w.deps, bucket: BUCKET },
      caseUid,
      textUid,
      {
        enabled: true,
        generate: async () => {
          calls += 1;
          return { text: 'x', models: {} };
        },
      },
    );
    assert.equal(calls, 0);
    const doc = (
      await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).get()
    ).data();
    assert.equal(doc?.status, 'Ready');
  });

  it('sourceFieldsOf keeps only signed clinical fields', () => {
    const fields = sourceFieldsOf({
      title: 'T',
      diagnosis: 'D',
      comments: 'C',
      measurements: { a: 1 },
      patientUid: 'secret',
      orderNumber: 'ODR-1',
    });
    assert.deepEqual(fields, {
      title: 'T',
      diagnosis: 'D',
      comments: 'C',
      measurements: { a: 1 },
    });
  });

  it('OffSchema from the model becomes Failed without leaking content', async () => {
    const caseUid = randomUUID();
    const reportUid = 'v1';
    const textUid = `${reportUid}_Explanation_en`;
    const report = {
      caseUid,
      version: 1,
      stage: 'Initial',
      title: SOURCE.title,
      diagnosis: SOURCE.diagnosis,
      comments: SOURCE.comments,
      measurements: SOURCE.measurements,
      responses: {},
      isCritical: false,
      addenda: [],
      amendmentReason: '',
      notifiableFindings: [],
      confirmatoryRequests: [],
      signedByTitle: '',
      signedByName: '',
      signedByKmpdcNumber: '',
      signedByFacilityName: '',
      signatureSha256: '',
      orderNumber: '',
      testName: '',
      sampleCollectedAt: '',
      sampleReceivedAt: '',
      labAccessionNo: '',
      profile: '',
      templateKey: '',
      diagnosisType: '',
    };
    const contentSha256 = sha256(stableReportContent(report));
    await w.deps.db.collection('cases').doc(caseUid).set({ uid: caseUid });
    await w.deps.db.collection('cases').doc(caseUid).collection('reports').doc(reportUid).set({
      ...report,
      contentSha256,
    });
    await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(textUid).set({
      uid: textUid,
      caseUid,
      reportUid,
      kind: 'Explanation',
      language: 'en',
      sourceSha256: contentSha256,
      status: 'Queued',
      machineText: {},
      models: {},
      failureReason: '',
      requestedAt: '2026-11-03T00:00:00.000Z',
      readyAt: '',
      lastUpdatedAt: '2026-11-03T00:00:00.000Z',
    });
    const logs: { reason: string }[] = [];
    await processQueuedReportText(
      { ...w.deps, bucket: BUCKET },
      caseUid,
      textUid,
      {
        enabled: true,
        log: (e) => logs.push(e),
        generate: async () => {
          throw new AiError('OffSchema');
        },
      },
    );
    assert.equal(logs.length, 1);
    assert.equal(logs[0].reason, 'OffSchema');
    assert.ok(!JSON.stringify(logs).includes('metastatic'));
  });
});
