// cspell:ignore Wanjiru Kamau carcinoma ductal Saratani kiwango Seli zilizoonekana hatua
import assert from 'node:assert/strict';
import { createHash, randomUUID } from 'node:crypto';

import { getStorage } from 'firebase-admin/storage';

import {
  acceptedCase,
  caseDoc,
  docData,
  fillDraft,
  HISTOLOGY,
  later,
  noteId,
  prereadQueuedCase,
  receivedCase,
  seedWorld,
  signaturePng,
  signedCase,
  startedReport,
  unlockCodeOf,
  unlockUidOf,
  type World,
} from './case.test-support';
import { completeCaseHandler, recordSampleReceivedHandler } from './cases';
import { loadDiseasesFromDisk, setDiseasesForTest, type DiseaseNames } from './disease-data';
import { BUCKET, refusedWith, resetEmulators } from './emulator.test-support';
import {
  approveReportTextHandler,
  discardDraftHandler,
  markDiscussedHandler,
  onPrereadWrittenHandler,
  onReportDraftWrittenHandler,
  onReportCreatedHandler,
  onReportTextWrittenHandler,
  requestReportTextHandler,
  scorePrereadHandler,
  signReportHandler,
  startReportHandler,
} from './reports';
import { redeemShareCodeHandler } from './shares-callables';
import { stubAiClient, type AiClient } from './ai';

describe('reports', () => {
  let w: World;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
  });

  const sign = (caseUid: string, stamp: string, overrides: Record<string, unknown> = {}, deps = w.deps) =>
    signReportHandler(deps, w.pathologist, {
      caseUid,
      draftLastUpdatedAt: stamp,
      signaturePng: signaturePng(),
      ...overrides,
    });

  const draftRef = (caseUid: string) =>
    w.deps.db.collection('cases').doc(caseUid).collection('reportDrafts').doc(w.pathologist.uid);

  async function unlockForDoctor(signed: { caseUid: string; reportUid: string; stamp: string }): Promise<void> {
    await redeemShareCodeHandler(w.deps, w.doctor, {
      shareUid: unlockUidOf(signed),
      code: await unlockCodeOf(w, signed),
    });
  }

  describe('startReport', () => {
    it('opens an Editing draft, moves the case to ReportInProgress and the worklist to InProgress', async () => {
      const caseUid = await receivedCase(w);
      const result = await startReportHandler(w.deps, w.pathologist, { caseUid, kind: 'Initial' });
      assert.equal(result.status, 'started');
      const draft = (await draftRef(caseUid).get()).data();
      assert.equal(draft?.status, 'Editing');
      assert.equal(draft?.kind, 'Initial');
      assert.equal(draft?.pathologistUid, w.pathologist.uid);
      assert.equal(draft?.lastUpdatedAt, result.lastUpdatedAt);
      assert.equal((await caseDoc(w, caseUid)).currentStage, 'ReportInProgress');
      assert.equal((await docData(w, `worklist/${caseUid}`))?.status, 'InProgress');
    });

    it('is idempotent for the same kind and refuses a different draft in progress', async () => {
      const caseUid = await receivedCase(w);
      const first = await startReportHandler(w.deps, w.pathologist, { caseUid });
      const again = await startReportHandler(w.deps, w.pathologist, { caseUid });
      assert.deepEqual(again, { status: 'exists', lastUpdatedAt: first.lastUpdatedAt });
      await refusedWith(startReportHandler(w.deps, w.pathologist, { caseUid, kind: 'Amendment' }), 'caseNotActive');
    });

    it('refuses by role, ownership, stage and kind', async () => {
      const accepted = await acceptedCase(w);
      await refusedWith(startReportHandler(w.deps, w.pathologist, { caseUid: accepted }), 'sampleNotReceived');
      await refusedWith(startReportHandler(w.deps, w.doctor, { caseUid: accepted }), 'pathologistsOnly');
      await refusedWith(startReportHandler(w.deps, w.otherPathologist, { caseUid: accepted }), 'notOnCase');
      await refusedWith(startReportHandler(w.deps, w.pathologist, { caseUid: accepted, kind: 'Bogus' }), 'invalidKind');
      await refusedWith(startReportHandler(w.deps, w.pathologist, { caseUid: 'nope' }), 'invalidCase');
    });

    it('refuses a second Initial once one is signed, and an Addendum while an Amendment is open', async () => {
      const signed = await signedCase(w);
      await refusedWith(startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid }), 'alreadySigned');
      await startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Amendment' });
      await refusedWith(
        startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Addendum' }),
        'draftInProgress',
      );
    });

    it('waits for a fresh pre-read, and takes over once it is stale', async () => {
      const { caseUid, runUid } = await prereadQueuedCase(w);
      await recordSampleReceivedHandler(w.deps, w.pathologist, { caseUid, labAccessionNo: 'LAB/26-7' });
      await refusedWith(startReportHandler(w.deps, w.pathologist, { caseUid }), 'prereadPending');
      await startReportHandler(later(w.deps, 31 * 60 * 1000), w.pathologist, { caseUid });
      const run = await docData(w, `cases/${caseUid}/preread/${runUid}`);
      assert.equal(run?.status, 'Failed');
      assert.equal(run?.failureReason, 'Stale');
      assert.equal((await caseDoc(w, caseUid)).currentStage, 'ReportInProgress');
    });
  });

  async function freshWorld(): Promise<World> {
    await resetEmulators();
    w = await seedWorld();
    return w;
  }

  describe('signReport', () => {
    it('refuses a draft changed since the stamp the client holds', async () => {
      const caseUid = await startedReport(w);
      const stamp = await fillDraft(w, caseUid);
      await refusedWith(sign(caseUid, '2026-10-27T08:00:00.000Z'), 'draftChanged');
      assert.equal((await draftRef(caseUid).get()).get('status'), 'Editing');
      assert.equal((await caseDoc(w, caseUid)).currentStage, 'ReportInProgress');
      await sign(caseUid, stamp);
    });

    it('refuses an incomplete draft, a bad signature and an unverified signer', async () => {
      const caseUid = await startedReport(w);
      const stamp = await fillDraft(w, caseUid, { diagnosis: '' });
      await refusedWith(sign(caseUid, stamp), 'incomplete');
      await fillDraft(w, caseUid, { responses: [] }, stamp);
      await refusedWith(sign(caseUid, stamp), 'incomplete');
      await fillDraft(w, caseUid, {}, stamp);
      for (const bad of ['', 'AAAA', Buffer.from('not a png at all, but long enough to pass 33 bytes').toString('base64')]) {
        await refusedWith(sign(caseUid, stamp, { signaturePng: bad }), 'invalidSignature');
      }
      await w.deps.db.collection('doctors').doc(w.pathologist.uid).update({ verificationStatus: 'Pending' });
      await refusedWith(sign(caseUid, stamp), 'notVerified');
      assert.equal((await w.deps.db.collection('cases').doc(caseUid).collection('reports').get()).size, 0);
    });

    it('refuses without a draft, for another pathologist, a doctor and a missing key', async () => {
      const received = await receivedCase(w);
      await refusedWith(sign(received, 'x'), 'draftNotEditing');
      const caseUid = await startedReport(w);
      const stamp = await fillDraft(w, caseUid);
      await refusedWith(
        signReportHandler(w.deps, w.otherPathologist, { caseUid, draftLastUpdatedAt: stamp, signaturePng: signaturePng() }),
        'notOnCase',
      );
      await refusedWith(
        signReportHandler(w.deps, w.doctor, { caseUid, draftLastUpdatedAt: stamp, signaturePng: signaturePng() }),
        'pathologistsOnly',
      );
      await refusedWith(sign(caseUid, stamp, {}, { ...w.deps, shareCodeKey: undefined }), 'shareKeyMissing');
      await refusedWith(sign(caseUid, stamp, { draftLastUpdatedAt: '' }), 'invalidDraft');
    });

    it('refuses label overrides it cannot check or recompute', async () => {
      const caseUid = await startedReport(w);
      const stamp = await fillDraft(w, caseUid, { labelOverrides: { 'tile-1': 'Tumour' } });
      await refusedWith(sign(caseUid, stamp), 'invalidLabels');
    });

    it('writes v1 from the signer’s own record, with provenance, the pipeline and an unlock code', async () => {
      const caseUid = await startedReport(w);
      const stamp = await fillDraft(w, caseUid, {
        diagnosis: 'Invasive\u200b ductal\u202e carcinoma, grade 2.',
        signerName: 'Someone Else',
        signedByKmpdcNumber: 'FORGED',
      });
      const result = await sign(caseUid, stamp, { signedByName: 'Someone Else', signedByKmpdcNumber: 'FORGED' });
      assert.deepEqual(result, { status: 'signed', reportUid: 'v1', version: 1 });

      const report = await docData(w, `cases/${caseUid}/reports/v1`);
      assert.equal(report?.status, 'Signed');
      assert.equal(report?.stage, 'Initial');
      assert.equal(report?.diagnosis, 'Invasive ductal carcinoma, grade 2.');
      assert.equal(report?.signedByName, 'Wanjiru Kamau');
      assert.equal(report?.signedByTitle, 'Dr.');
      assert.equal(report?.signedByFacilityName, 'Test Hospital');
      assert.notEqual(report?.signedByKmpdcNumber, 'FORGED');
      const profile = await docData(w, `doctors/${w.pathologist.uid}`);
      assert.equal(report?.signedByKmpdcNumber, profile?.kmpdcNumber);
      assert.equal(report?.signedByFacilityName, profile?.facilityName);
      assert.deepEqual(report?.readerUids, [w.pathologist.uid]);
      assert.equal(report?.releasedToPatient, false);
      assert.equal(report?.doctorUid, w.doctor.uid);
      assert.match(String(report?.signaturePath), new RegExp(`^reports/${caseUid}/v1/signature-[0-9a-f]{64}\\.png$`));
      assert.match(String(report?.contentSha256), /^[0-9a-f]{64}$/);

      const provenance = await docData(w, `cases/${caseUid}/reportProvenance/v1`);
      assert.equal(provenance?.diffBase, 'None');
      assert.equal(provenance?.pathologistUid, w.pathologist.uid);

      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'ReportSigned');
      assert.equal(doc.currentReportUid, 'v1');
      assert.equal(doc.resultState, 'WithDoctor');
      assert.equal((await draftRef(caseUid).get()).get('status'), 'Signed');
      assert.equal((await draftRef(caseUid).get()).get('signedReportUid'), 'v1');
      assert.equal((await docData(w, `worklist/${caseUid}`))?.status, 'Signed');

      const unlock = await docData(w, `shareCodes/unlock_${caseUid}_v1`);
      assert.equal(unlock?.status, 'Pending');
      assert.equal(unlock?.purpose, 'ReportUnlock');
      assert.equal(unlock?.recipientUid, w.doctor.uid);
      assert.equal(unlock?.expiresAt, '2026-11-03T09:00:00.000Z');
      assert.ok(await docData(w, noteId('reportSigned', `${caseUid}_v1`, w.doctor.uid)));
      assert.ok(await docData(w, noteId('resultsWithDoctor', `${caseUid}-r${doc.stageSeq as number}`, w.patient.uid)));
    });

    it('is idempotent: a replay returns the first result, even with a stale stamp, and writes nothing', async () => {
      const caseUid = await startedReport(w);
      const stamp = await fillDraft(w, caseUid);
      await sign(caseUid, stamp);
      const seq = (await caseDoc(w, caseUid)).stageSeq;
      assert.deepEqual(await sign(caseUid, stamp), { status: 'exists', reportUid: 'v1', version: 1 });
      assert.deepEqual(await sign(caseUid, 'a stale stamp'), { status: 'exists', reportUid: 'v1', version: 1 });
      assert.equal((await w.deps.db.collection('cases').doc(caseUid).collection('reports').get()).size, 1);
      assert.equal((await caseDoc(w, caseUid)).stageSeq, seq);
    });

    it('stores the signature it hashed, and a replay uploads nothing', async () => {
      const caseUid = await startedReport(w);
      const stamp = await fillDraft(w, caseUid);
      await sign(caseUid, stamp);
      const report = await docData(w, `cases/${caseUid}/reports/v1`);
      const file = getStorage().bucket(BUCKET).file(String(report?.signaturePath));
      const [bytes] = await file.download();
      assert.equal(createHash('sha256').update(bytes).digest('hex'), report?.signatureSha256);
      const [before] = await file.getMetadata();

      await sign(caseUid, stamp, { signaturePng: Buffer.from('a different, but long enough, png body......').toString('base64') });
      const [after] = await file.getMetadata();
      assert.equal(after.generation, before.generation);
      const [files] = await getStorage().bucket(BUCKET).getFiles({ prefix: `reports/${caseUid}/` });
      assert.equal(files.length, 1);
    });

    it('keeps the patient out of the readers until the doctor has discussed the result', async () => {
      const signed = await signedCase(w);
      const reader = async () =>
        ((await docData(w, `cases/${signed.caseUid}/reports/${signed.reportUid}`))?.readerUids ?? []) as string[];
      assert.ok(!(await reader()).includes(w.patient.uid));
      assert.ok(!(await reader()).includes(w.doctor.uid), 'the doctor reads only after entering the code');
      await unlockForDoctor(signed);
      assert.ok((await reader()).includes(w.doctor.uid));
      assert.ok(!(await reader()).includes(w.patient.uid));
    });

    it('needs the pre-read scored first, and records how far the pathologist moved from it', async () => {
      const caseUid = await startedReport(w);
      const runUid = randomUUID();
      const runRef = w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid);
      await runRef.set({
        status: 'Ready',
        profile: 'Cancer',
        models: {},
        measurements: {},
        draft: {
          impression: 'Invasive ductal carcinoma, grade 2.',
          findings: [{ text: 'Atypical cells.' }],
          urgency: 'Urgent',
          confidenceBand: 'High',
          confidence: 0.8,
        },
      });
      const stamp = await fillDraft(w, caseUid, { prereadRunUid: runUid });
      await refusedWith(sign(caseUid, stamp), 'prereadNotScored');

      const score = {
        caseUid,
        runUid,
        findingsVerdict: 'PartlyAgree',
        impressionVerdict: 'Agree',
        urgencyVerdict: 'Agree',
        measurementsVerdict: 'NotApplicable',
        segmentationVerdict: 'NotApplicable',
        overall: 4,
        comment: 'Useful.',
        prereadShownAt: '2026-10-27T08:00:00.000Z',
      };
      await refusedWith(scorePrereadHandler(w.deps, w.pathologist, { ...score, overall: 6 }), 'invalidScore');
      await refusedWith(scorePrereadHandler(w.deps, w.pathologist, { ...score, prereadShownAt: '2027-01-01T00:00:00.000Z' }), 'invalidScore');
      await refusedWith(scorePrereadHandler(w.deps, w.otherPathologist, score), 'notOnCase');
      assert.deepEqual(await scorePrereadHandler(w.deps, w.pathologist, score), { status: 'scored' });
      assert.deepEqual(await scorePrereadHandler(w.deps, w.pathologist, score), { status: 'alreadyScored' });
      assert.equal((await docData(w, `cases/${caseUid}/prereadScores/${runUid}`))?.acceptedUnchanged, false);

      await sign(caseUid, stamp);
      const provenance = await docData(w, `cases/${caseUid}/reportProvenance/v1`);
      assert.equal(provenance?.diffBase, 'PrereadDraft');
      assert.ok(Number(provenance?.editRate) > 0, 'the comments differ from the pre-read');
      assert.equal(provenance?.acceptedUnchanged, false);
      const diff = provenance?.diff as { field: string; change: string }[];
      assert.equal(diff.find((d) => d.field === 'diagnosis')?.change, 'Unchanged');
      assert.equal(diff.find((d) => d.field === 'comments')?.change, 'Edited');
    });

    describe('notifiable findings and confirmatory requests', () => {
      const bundle = (id: string, extra: Partial<DiseaseNames>): DiseaseNames => ({
        diseaseId: id,
        nameEn: id,
        nameSw: id,
        reportingCategory: 'Immediate',
        publicAlertEligible: true,
        allowManualAlert: false,
        labTests: [{ labTestId: HISTOLOGY, strength: 'Confirms' }],
        ...extra,
      });

      beforeEach(() => {
        setDiseasesForTest([
          bundle('d-confirmed', {}),
          bundle('d-weekly', { reportingCategory: 'Weekly' }),
          bundle('d-no-alert', { publicAlertEligible: false }),
          bundle('d-unlisted', { reportingCategory: 'NotListed' }),
          bundle('d-elsewhere', { labTests: [{ labTestId: 'another-test', strength: 'Confirms' }] }),
          bundle('d-presumptive', { labTests: [{ labTestId: HISTOLOGY, strength: 'Presumptive' }] }),
          bundle('d-both', {
            labTests: [
              { labTestId: HISTOLOGY, strength: 'Presumptive' },
              { labTestId: HISTOLOGY, strength: 'Confirms' },
            ],
          }),
        ]);
      });
      after(() => loadDiseasesFromDisk());

      let lastCase = '';
      async function signWith(patch: Record<string, unknown>): Promise<void> {
        lastCase = await startedReport(w);
        await sign(lastCase, await fillDraft(w, lastCase, patch));
      }

      async function refusedFor(patch: Record<string, unknown>, reason: string): Promise<void> {
        await refusedWith(signWith(patch), reason);
        const written = await w.deps.db.collection('cases').doc(lastCase).collection('reports').get();
        assert.equal(written.size, 0, 'nothing is written, and no signature is uploaded');
      }

      it('signs a confirmed finding in its fixed shape, and keeps only real hints', async () => {
        const caseUid = await startedReport(w);
        const stamp = await fillDraft(w, caseUid, {
          notifiableFindings: [{ diseaseId: 'd-confirmed', alertRequested: true, note: 'dropped' }],
          hintShownDiseaseIds: ['d-confirmed', 'not-in-the-bundle'],
        });
        await sign(caseUid, stamp);
        const report = await docData(w, `cases/${caseUid}/reports/v1`);
        assert.deepEqual(report?.notifiableFindings, [{ diseaseId: 'd-confirmed', alertRequested: true }]);
        assert.deepEqual((await docData(w, `cases/${caseUid}/reportProvenance/v1`))?.hintShownDiseaseIds, ['d-confirmed']);

        // The signing transaction writes the anonymous event (S-5) and its server-only link.
        const link = await docData(w, `notifiableEventLinks/${caseUid}_d-confirmed`);
        assert.equal(link?.status, 'Active');
        assert.equal(link?.reportUid, 'v1');
        const event = await docData(w, `notifiableEvents/${String(link?.eventUid)}`);
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
        assert.equal(event?.alertRequested, true);
        assert.equal(event?.synthetic, false);
      });

      it('writes no event for a report with no findings', async () => {
        const caseUid = await startedReport(w);
        await sign(caseUid, await fillDraft(w, caseUid, {}));
        const links = await w.deps.db.collection('notifiableEventLinks').where('caseUid', '==', caseUid).get();
        assert.equal(links.size, 0);
      });

      it('refuses a finding that is free text, unlisted, unconfirmed or one that cannot raise an alert', async () => {
        await refusedFor({ notifiableFindings: [{ diseaseId: 'Ebola', alertRequested: false }] }, 'invalidNotifiable');
        await refusedFor({ notifiableFindings: [{ diseaseId: 'd-unlisted', alertRequested: false }] }, 'invalidNotifiable');
        await refusedFor({ notifiableFindings: [{ diseaseId: 'd-elsewhere', alertRequested: false }] }, 'invalidNotifiable');
        await refusedFor({ notifiableFindings: [{ diseaseId: 'd-presumptive', alertRequested: false }] }, 'invalidNotifiable');
        await refusedFor({ notifiableFindings: [{ diseaseId: 'd-no-alert', alertRequested: true }] }, 'invalidNotifiable');
        await refusedFor({ notifiableFindings: [{ diseaseId: 'd-weekly', alertRequested: true }] }, 'invalidNotifiable');
        await refusedFor(
          {
            notifiableFindings: [
              { diseaseId: 'd-confirmed', alertRequested: false },
              { diseaseId: 'd-confirmed', alertRequested: true },
            ],
          },
          'invalidNotifiable',
        );
        await refusedFor({ notifiableFindings: 'd-confirmed' }, 'invalidNotifiable');
      });

      it('takes a confirmatory request for a presumed disease, and refuses the rest', async () => {
        const caseUid = await startedReport(w);
        const stamp = await fillDraft(w, caseUid, { confirmatoryRequests: ['d-presumptive'] });
        await sign(caseUid, stamp);
        assert.deepEqual((await docData(w, `cases/${caseUid}/reports/v1`))?.confirmatoryRequests, ['d-presumptive']);

        await refusedFor({ confirmatoryRequests: ['d-both'] }, 'invalidConfirmatory');
        await refusedFor({ confirmatoryRequests: ['d-confirmed'] }, 'invalidConfirmatory');
        await refusedFor({ confirmatoryRequests: ['d-unlisted'] }, 'invalidConfirmatory');
        await refusedFor({ confirmatoryRequests: ['made-up'] }, 'invalidConfirmatory');
        await refusedFor({ confirmatoryRequests: ['d-presumptive', 'd-presumptive'] }, 'invalidConfirmatory');
      });

      it('an addendum cannot change the findings it extends', async () => {
        const signed = await signedCase(w, w.deps, {
          notifiableFindings: [{ diseaseId: 'd-confirmed', alertRequested: false }],
        });
        await startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Addendum' });
        const stamp = await fillDraft(
          w,
          signed.caseUid,
          { addendumText: 'More.', notifiableFindings: [] },
          '2026-10-27T09:06:00.000Z',
        );
        await refusedWith(sign(signed.caseUid, stamp), 'invalidNotifiable');
        await fillDraft(
          w,
          signed.caseUid,
          { notifiableFindings: [{ diseaseId: 'd-confirmed', alertRequested: false }] },
          '2026-10-27T09:07:00.000Z',
        );
        await sign(signed.caseUid, '2026-10-27T09:07:00.000Z');
        assert.deepEqual((await docData(w, `cases/${signed.caseUid}/reports/v2`))?.notifiableFindings, [
          { diseaseId: 'd-confirmed', alertRequested: false },
        ]);
      });
    });

    describe('the measurement preview (S-2, S-6)', () => {
      const countTiles = (r: { labelOverrides: Record<string, string> }) =>
        Promise.resolve({ measurements: { tumourTiles: 1 + Object.keys(r.labelOverrides).length } });
      let calls: number;
      const withService = (measure: AiClient['measure'] = countTiles) => ({
        ...w.deps,
        ai: { assessCase: stubAiClient.assessCase, measure } satisfies AiClient,
      });

      async function relabelled(): Promise<{ caseUid: string; stamp: string; runUid: string }> {
        calls = 0;
        const caseUid = await startedReport(w);
        const runUid = randomUUID();
        const labelsPath = `preread/${caseUid}/${runUid}/labels.json`;
        await getStorage()
          .bucket(BUCKET)
          .file(labelsPath)
          .save(
            Buffer.from(JSON.stringify({ labels: [{ id: 'tile-1', label: 'Normal' }, { id: 'tile-2', label: 'Tumour' }] })),
            { contentType: 'application/json', resumable: false },
          );
        await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).set({
          status: 'Ready',
          profile: 'Cancer',
          models: {},
          measurements: { tumourTiles: 1 },
          labelsPath,
          draft: { impression: 'x', findings: [], urgency: 'Routine', confidenceBand: 'High', confidence: 0.9 },
        });
        await scorePrereadHandler(w.deps, w.pathologist, {
          caseUid,
          runUid,
          findingsVerdict: 'Agree',
          impressionVerdict: 'Agree',
          urgencyVerdict: 'Agree',
          measurementsVerdict: 'Corrected',
          segmentationVerdict: 'NotApplicable',
          overall: 4,
          comment: '',
          prereadShownAt: '2026-10-27T08:00:00.000Z',
        });
        const stamp = await fillDraft(w, caseUid, { prereadRunUid: runUid, labelOverrides: { 'tile-1': 'Tumour' } });
        return { caseUid, stamp, runUid };
      }

      const written = async (deps: ReturnType<typeof withService>, caseUid: string) =>
        onReportDraftWrittenHandler(deps, caseUid, w.pathologist.uid, (await draftRef(caseUid).get()).data());

      it('the draft trigger writes the numbers with the input hash, and leaves the stamp alone', async () => {
        const { caseUid, stamp } = await relabelled();
        const deps = withService();
        await written(deps, caseUid);
        const draft = (await draftRef(caseUid).get()).data();
        assert.equal(draft?.lastUpdatedAt, stamp);
        assert.equal(draft?.measurementsPreview.status, 'Ready');
        assert.deepEqual(draft?.measurementsPreview.measurements, { tumourTiles: 2 });
        assert.match(String(draft?.measurementsPreview.inputHash), /^[0-9a-f]{64}$/);

        await sign(caseUid, stamp, {}, deps);
        const report = await docData(w, `cases/${caseUid}/reports/v1`);
        assert.deepEqual(report?.measurements, [{ key: 'tumourTiles', unit: '', value: 2, precision: 2 }]);
      });

      it('does not call the service again for an unchanged draft', async () => {
        const { caseUid } = await relabelled();
        const deps = withService((r) => {
          calls++;
          return countTiles(r);
        });
        await written(deps, caseUid);
        const first = (await draftRef(caseUid).get()).data()?.measurementsPreview;
        await written(withService(), caseUid);
        assert.equal(calls, 1);
        assert.deepEqual((await draftRef(caseUid).get()).data()?.measurementsPreview, first);
      });

      it('refuses to sign numbers the pathologist never saw', async () => {
        const { caseUid, stamp } = await relabelled();
        await refusedWith(sign(caseUid, stamp, {}, withService()), 'measurementsChanged');

        await written(withService(), caseUid);
        const drifted = withService(() => Promise.resolve({ measurements: { tumourTiles: 3 } }));
        await refusedWith(sign(caseUid, stamp, {}, drifted), 'measurementsChanged');

        await draftRef(caseUid).update({ labelOverrides: { 'tile-2': 'Normal' } });
        await refusedWith(sign(caseUid, stamp, {}, withService()), 'measurementsChanged');
        assert.equal((await w.deps.db.collection('cases').doc(caseUid).collection('reports').get()).size, 0);
      });

      it('records a failed preview, and signing is refused rather than guessed', async () => {
        const { caseUid, stamp } = await relabelled();
        await written({ ...w.deps, ai: { assessCase: stubAiClient.assessCase } } as ReturnType<typeof withService>, caseUid);
        const preview = (await draftRef(caseUid).get()).data()?.measurementsPreview;
        assert.equal(preview.status, 'Failed');
        assert.deepEqual(preview.measurements, {});
        await refusedWith(sign(caseUid, stamp, {}, withService()), 'measurementsChanged');
        await refusedWith(
          sign(caseUid, stamp, {}, { ...w.deps, ai: { assessCase: stubAiClient.assessCase } } as ReturnType<typeof withService>),
          'measurementFailed',
        );
      });

      it('records a label the pre-read never used as a failed preview, with no service call', async () => {
        const { caseUid } = await relabelled();
        await draftRef(caseUid).update({ labelOverrides: { 'tile-1': 'Invented' } });
        await written(
          withService(() => {
            calls++;
            return countTiles({ labelOverrides: {} });
          }),
          caseUid,
        );
        assert.equal((await draftRef(caseUid).get()).data()?.measurementsPreview.failureReason, 'invalidLabels');
        assert.equal(calls, 0);
      });

      it('writes nothing for a draft without overrides or one already signed', async () => {
        const caseUid = await startedReport(w);
        await fillDraft(w, caseUid);
        await written(withService(), caseUid);
        assert.equal((await draftRef(caseUid).get()).data()?.measurementsPreview, undefined);
      });
    });

    describe('revisions', () => {
      it('an addendum supersedes the previous version and revokes its unused code', async () => {
        const signed = await signedCase(w);
        await startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Addendum' });
        const stamp = await fillDraft(w, signed.caseUid, { addendumText: '' }, '2026-10-27T09:05:00.000Z');
        await refusedWith(sign(signed.caseUid, stamp), 'reasonRequired');
        await draftRef(signed.caseUid).update({
          addendumText: 'Immunohistochemistry confirms the grade.',
          lastUpdatedAt: '2026-10-27T09:06:00.000Z',
        });
        const result = await sign(signed.caseUid, '2026-10-27T09:06:00.000Z');
        assert.deepEqual(result, { status: 'signed', reportUid: 'v2', version: 2 });

        const first = await docData(w, `cases/${signed.caseUid}/reports/v1`);
        assert.equal(first?.status, 'Superseded');
        assert.equal(first?.supersededByUid, 'v2');
        const second = await docData(w, `cases/${signed.caseUid}/reports/v2`);
        assert.equal(second?.stage, 'Addendum');
        assert.equal(second?.diagnosis, first?.diagnosis);
        assert.equal((second?.addenda as unknown[]).length, 1);
        assert.equal((await docData(w, `shareCodes/${unlockUidOf(signed)}`))?.status, 'Revoked');
        assert.equal((await docData(w, `shareCodes/unlock_${signed.caseUid}_v2`))?.status, 'Pending');
        assert.ok(await docData(w, noteId('reportUpdated', `${signed.caseUid}_v2`, w.doctor.uid)));
        const doc = await caseDoc(w, signed.caseUid);
        assert.equal(doc.currentReportUid, 'v2');
        assert.equal(doc.currentStage, 'ReportSigned');
      });

      it('an amendment needs its reason, and can be discarded on the right stamp only', async () => {
        const signed = await signedCase(w);
        const started = await startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Amendment' });
        await refusedWith(sign(signed.caseUid, started.lastUpdatedAt), 'reasonRequired');
        await refusedWith(
          discardDraftHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, draftLastUpdatedAt: 'old' }),
          'draftChanged',
        );
        await discardDraftHandler(w.deps, w.pathologist, {
          caseUid: signed.caseUid,
          draftLastUpdatedAt: started.lastUpdatedAt,
        });
        assert.equal((await draftRef(signed.caseUid).get()).get('status'), 'Closed');
        assert.deepEqual(
          await discardDraftHandler(w.deps, w.pathologist, {
            caseUid: signed.caseUid,
            draftLastUpdatedAt: started.lastUpdatedAt,
          }),
          { status: 'ok' },
        );
        assert.equal(
          (await startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Amendment' })).status,
          'started',
        );
      });

      it('an Initial draft is never discarded', async () => {
        const caseUid = await startedReport(w);
        await refusedWith(
          discardDraftHandler(w.deps, w.pathologist, { caseUid, draftLastUpdatedAt: 'x' }),
          'initialDraft',
        );
        await refusedWith(
          discardDraftHandler(w.deps, w.otherPathologist, { caseUid, draftLastUpdatedAt: 'x' }),
          'notOnCase',
        );
        await refusedWith(
          discardDraftHandler(w.deps, w.pathologist, { caseUid: await receivedCase(w), draftLastUpdatedAt: 'x' }),
          'noDraft',
        );
      });
    });
  });

  describe('markDiscussed', () => {
    it('is refused until the doctor holds the report, then releases it and lets the patient read', async () => {
      const signed = await signedCase(w);
      const input = { caseUid: signed.caseUid, reportUid: signed.reportUid };
      await refusedWith(markDiscussedHandler(w.deps, w.doctor, input), 'notUnlocked');
      await unlockForDoctor(signed);
      await markDiscussedHandler(w.deps, w.doctor, input);

      const report = await docData(w, `cases/${signed.caseUid}/reports/v1`);
      assert.equal(report?.releasedToPatient, true);
      assert.equal(report?.releasedByUid, w.doctor.uid);
      assert.ok((report?.readerUids as string[]).includes(w.patient.uid));
      const doc = await caseDoc(w, signed.caseUid);
      assert.equal(doc.releasedToPatient, true);
      assert.equal(doc.currentStage, 'ResultReleased');
      assert.equal(doc.resultState, 'Released');
      assert.ok(await docData(w, noteId('resultReleased', `${signed.caseUid}_v1`, w.patient.uid)));

      const seq = doc.stageSeq;
      assert.deepEqual(await markDiscussedHandler(w.deps, w.doctor, input), { status: 'ok' });
      assert.equal((await caseDoc(w, signed.caseUid)).stageSeq, seq);
    });

    it('is the ordering doctor’s alone and names a current version', async () => {
      const signed = await signedCase(w);
      await unlockForDoctor(signed);
      const input = { caseUid: signed.caseUid, reportUid: signed.reportUid };
      await refusedWith(markDiscussedHandler(w.deps, w.pathologist, input), 'doctorsOnly');
      await refusedWith(markDiscussedHandler(w.deps, w.colleague, input), 'notOrderingDoctor');
      await refusedWith(markDiscussedHandler(w.deps, w.doctor, { ...input, reportUid: 'nope' }), 'invalidReport');
      await refusedWith(markDiscussedHandler(w.deps, w.doctor, { ...input, reportUid: 'v9' }), 'notCurrent');
      const report = await docData(w, `cases/${signed.caseUid}/reports/v1`);
      assert.equal(report?.releasedToPatient, false);
    });

    it('queues patient explanations for the doctor’s approval only when the switch is on', async () => {
      const on = { ...w.deps, config: { enabled: (key: string) => key === 'patient_explanations_enabled' } };
      const signed = await signedCase(w);
      await unlockForDoctor(signed);
      const input = { caseUid: signed.caseUid, reportUid: signed.reportUid };
      await markDiscussedHandler(on, w.doctor, input);
      for (const language of ['en', 'sw']) {
        const text = await docData(w, `cases/${signed.caseUid}/reportTexts/v1_Explanation_${language}`);
        assert.equal(text?.status, 'Queued');
        assert.equal(text?.approverUid, w.doctor.uid);
        assert.equal(text?.kind, 'Explanation');
      }

      const other = await freshWorld();
      const offSigned = await signedCase(other);
      await unlockForDoctor(offSigned);
      await markDiscussedHandler(other.deps, other.doctor, { caseUid: offSigned.caseUid, reportUid: 'v1' });
      assert.equal((await other.deps.db.collection('cases').doc(offSigned.caseUid).collection('reportTexts').get()).size, 0);
    });

    it('lets the doctor complete the case afterwards', async () => {
      const signed = await signedCase(w);
      await unlockForDoctor(signed);
      await markDiscussedHandler(w.deps, w.doctor, { caseUid: signed.caseUid, reportUid: signed.reportUid });
      await completeCaseHandler(w.deps, w.doctor, { caseUid: signed.caseUid });
      assert.equal((await caseDoc(w, signed.caseUid)).currentStage, 'Completed');
      assert.deepEqual(await completeCaseHandler(w.deps, w.doctor, { caseUid: signed.caseUid }), { status: 'ok' });
    });
  });

  describe('report texts', () => {
    async function textReady(status = 'Ready'): Promise<{ caseUid: string; id: string }> {
      const signed = await signedCase(w);
      const id = 'v1_Translation_sw';
      await w.deps.db.collection('cases').doc(signed.caseUid).collection('reportTexts').doc(id).set({
        uid: id,
        caseUid: signed.caseUid,
        reportUid: 'v1',
        reportVersion: 1,
        kind: 'Translation',
        language: 'sw',
        sourceLanguage: 'en',
        sourceSha256: 'a'.repeat(64),
        status,
        machineText: { diagnosis: 'Saratani ya kiwango cha 2', comments: 'Seli 12 zilizoonekana' },
        models: {},
        approverUid: w.pathologist.uid,
        requestCount: 0,
        failureReason: '',
        requestedAt: '2026-10-27T09:00:00.000Z',
        lastUpdatedAt: '2026-10-27T09:00:00.000Z',
      });
      return { caseUid: signed.caseUid, id };
    }

    it('creates a translation when a first report is created, if the switch is on, once', async () => {
      const signed = await signedCase(w);
      await onReportCreatedHandler(w.deps, signed.caseUid, 'v1');
      assert.equal((await w.deps.db.collection('cases').doc(signed.caseUid).collection('reportTexts').get()).size, 0);

      const on = { ...w.deps, config: { enabled: (key: string) => key === 'report_translation_enabled' } };
      await onReportCreatedHandler(on, signed.caseUid, 'v1');
      await onReportCreatedHandler(on, signed.caseUid, 'v1');
      const text = await docData(w, `cases/${signed.caseUid}/reportTexts/v1_Translation_sw`);
      assert.equal(text?.status, 'Queued');
      assert.equal(text?.approverUid, w.pathologist.uid);
      assert.equal(text?.sourceLanguage, 'en');
    });

    it('counts reportsSigned and casesReported once per first report', async () => {
      const signed = await signedCase(w);
      await onReportCreatedHandler(w.deps, signed.caseUid, 'v1');
      await onReportCreatedHandler(w.deps, signed.caseUid, 'v1');
      assert.equal((await docData(w, `doctors/${w.pathologist.uid}`))?.reportsSigned, 1);
      assert.equal((await docData(w, `patients/${w.patientId}`))?.casesReported, 1);
      await onReportCreatedHandler(w.deps, signed.caseUid, 'v2');
      assert.equal((await docData(w, `doctors/${w.pathologist.uid}`))?.reportsSigned, 1);
    });

    it('notifies the approver once when a text becomes Ready, and never for a Queued one', async () => {
      const queued = await textReady('Queued');
      await onReportTextWrittenHandler(w.deps, queued.caseUid, queued.id);
      assert.equal(await docData(w, noteId('translationReady', `${queued.caseUid}_${queued.id}-r0`, w.pathologist.uid)), undefined);

      await w.deps.db.collection('cases').doc(queued.caseUid).collection('reportTexts').doc(queued.id).update({ status: 'Ready' });
      await onReportTextWrittenHandler(w.deps, queued.caseUid, queued.id);
      await onReportTextWrittenHandler(w.deps, queued.caseUid, queued.id);
      const row = await docData(w, noteId('translationReady', `${queued.caseUid}_${queued.id}-r0`, w.pathologist.uid));
      assert.ok(row);
      assert.ok(!JSON.stringify(row).includes('Saratani'), 'the row carries no report text');
    });

    it('approves as written, records it in code, and counts it accepted unchanged', async () => {
      const { caseUid, id } = await textReady();
      await refusedWith(approveReportTextHandler(w.deps, w.doctor, { caseUid, textUid: id, decision: 'Approve' }), 'roleNotAllowed');
      await refusedWith(approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: id, decision: 'Maybe' }), 'invalidDecision');
      await refusedWith(approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: 'nope', decision: 'Approve' }), 'invalidText');
      await approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: id, decision: 'Approve' });
      const approved = await docData(w, `cases/${caseUid}/reportTextsApproved/${id}`);
      assert.equal(approved?.approverUid, w.pathologist.uid);
      assert.equal(approved?.acceptedUnchanged, true);
      assert.deepEqual(approved?.approvedText, {
        diagnosis: 'Saratani ya kiwango cha 2',
        comments: 'Seli 12 zilizoonekana',
      });
      assert.equal((await docData(w, `cases/${caseUid}/reportTexts/${id}`))?.status, 'Approved');
      assert.equal((await docData(w, 'modelSignals/20261027'))?.translationAcceptedUnchanged, 1);
      assert.deepEqual(await approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: id, decision: 'Reject' }), { status: 'ok' });
      assert.equal((await docData(w, `cases/${caseUid}/reportTexts/${id}`))?.status, 'Approved');
    });

    it('takes an edit that keeps every number, and refuses one that changes a number', async () => {
      const { caseUid, id } = await textReady();
      const edit = (approvedText: Record<string, string>) =>
        approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: id, decision: 'ApproveEdited', approvedText });
      await refusedWith(edit({ diagnosis: 'Saratani ya kiwango cha 3', comments: 'Seli 12 zilizoonekana' }), 'numbersChanged');
      await refusedWith(edit({ diagnosis: 'Saratani ya kiwango cha 2' }), 'invalidSegments');
      await refusedWith(edit({ diagnosis: 'Saratani ya kiwango cha 2', comments: '  ' }), 'invalidSegments');
      await edit({ diagnosis: 'Saratani ya hatua ya kiwango cha 2', comments: 'Seli 12 zilizoonekana' });
      const row = await docData(w, `cases/${caseUid}/reportTexts/${id}`);
      assert.equal(row?.status, 'Approved');
      assert.deepEqual(row?.editedSegmentKeys, ['diagnosis']);
      assert.equal((await docData(w, `cases/${caseUid}/reportTextsApproved/${id}`))?.acceptedUnchanged, false);
    });

    async function explanationFor(caseUid: string, reportUid: string): Promise<string> {
      const id = `${reportUid}_Explanation_en`;
      await w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(id).set({
        uid: id,
        caseUid,
        reportUid,
        reportVersion: Number(reportUid.slice(1)),
        kind: 'Explanation',
        language: 'en',
        sourceLanguage: 'en',
        sourceSha256: 'a'.repeat(64),
        status: 'Ready',
        machineText: { summary: 'The result has 2 findings.' },
        models: {},
        approverUid: w.doctor.uid,
        requestCount: 0,
        failureReason: '',
        requestedAt: '2026-10-27T09:00:00.000Z',
        lastUpdatedAt: '2026-10-27T09:00:00.000Z',
      });
      return id;
    }

    it('lets a doctor approve an explanation and a pathologist a translation, and nobody else', async () => {
      const signed = await signedCase(w);
      const id = await explanationFor(signed.caseUid, 'v1');
      const approve = (who: World['doctor'], textUid: string) =>
        approveReportTextHandler(w.deps, who, { caseUid: signed.caseUid, textUid, decision: 'Approve' });
      await refusedWith(approve(w.pathologist, id), 'roleNotAllowed');
      await refusedWith(approve(w.patient, id), 'roleNotAllowed');
      await refusedWith(approve(w.colleague, id), 'notApprover');
      await approve(w.doctor, id);
      assert.equal((await docData(w, `cases/${signed.caseUid}/reportTexts/${id}`))?.status, 'Approved');
    });

    it('refuses an explanation of a version that is no longer the current one', async () => {
      const signed = await signedCase(w);
      const old = await explanationFor(signed.caseUid, 'v1');
      await startReportHandler(w.deps, w.pathologist, { caseUid: signed.caseUid, kind: 'Addendum' });
      const stamp = await fillDraft(w, signed.caseUid, { addendumText: 'More.' }, '2026-10-27T09:06:00.000Z');
      await sign(signed.caseUid, stamp);
      await refusedWith(
        approveReportTextHandler(w.deps, w.doctor, { caseUid: signed.caseUid, textUid: old, decision: 'Approve' }),
        'notCurrent',
      );
      assert.equal((await docData(w, `cases/${signed.caseUid}/reportTexts/${old}`))?.status, 'Ready');
    });

    it('refuses an approver whose verification lapsed', async () => {
      const { caseUid, id } = await textReady();
      await w.deps.db.collection('doctors').doc(w.pathologist.uid).update({ verificationStatus: 'Pending' });
      await refusedWith(approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: id, decision: 'Approve' }), 'notVerified');
      await refusedWith(requestReportTextHandler(w.deps, w.pathologist, { caseUid, reportUid: 'v1', kind: 'Translation' }), 'notVerified');
      assert.equal((await docData(w, `cases/${caseUid}/reportTexts/${id}`))?.status, 'Ready');
    });

    it('does not approve a text that is not Ready', async () => {
      const { caseUid, id } = await textReady('Queued');
      await refusedWith(approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: id, decision: 'Approve' }), 'notReady');
    });

    it('lets the approver ask again after a rejection, three times at most', async () => {
      const { caseUid, id } = await textReady();
      const ask = () => requestReportTextHandler(w.deps, w.pathologist, { caseUid, reportUid: 'v1', kind: 'Translation' });
      await refusedWith(ask(), 'notRetryable');
      await approveReportTextHandler(w.deps, w.pathologist, { caseUid, textUid: id, decision: 'Reject' });
      const ref = w.deps.db.collection('cases').doc(caseUid).collection('reportTexts').doc(id);
      await refusedWith(requestReportTextHandler(w.deps, w.doctor, { caseUid, reportUid: 'v1', kind: 'Translation' }), 'roleNotAllowed');
      await ask();
      assert.equal((await ref.get()).get('status'), 'Queued');
      assert.equal((await ref.get()).get('requestCount'), 1);
      await ask();
      assert.equal((await ref.get()).get('requestCount'), 1, 'asking while queued changes nothing');
      await ref.update({ status: 'Failed', requestCount: 3 });
      await refusedWith(ask(), 'requestLimit');
    });
  });

  describe('onPrereadWritten', () => {
    it('moves a queued case to PrereadReady once, and tells the pathologist', async () => {
      const { caseUid, runUid } = await prereadQueuedCase(w);
      const run = w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid);
      await onPrereadWrittenHandler(w.deps, caseUid, runUid);
      assert.equal((await caseDoc(w, caseUid)).currentStage, 'PrereadQueued', 'a Queued run is the service’s');

      await run.update({
        status: 'Ready',
        draft: { urgency: 'Urgent', confidenceBand: 'High', confidence: 0.9, impression: 'x', findings: [] },
      });
      await onPrereadWrittenHandler(w.deps, caseUid, runUid);
      await onPrereadWrittenHandler(w.deps, caseUid, runUid);
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PrereadReady');
      const worklist = await docData(w, `worklist/${caseUid}`);
      assert.equal(worklist?.prereadStatus, 'Ready');
      assert.equal(worklist?.urgency, 'Urgent');
      assert.ok(await docData(w, noteId('prereadReady', `${caseUid}-r${doc.stageSeq as number}`, w.pathologist.uid)));
      assert.equal((await docData(w, 'modelSignals/20261027'))?.prereadReadyCount, 1);
    });

    it('a late write of an old run touches neither the stage nor the worklist', async () => {
      const { caseUid, runUid } = await prereadQueuedCase(w);
      await w.deps.db.collection('cases').doc(caseUid).update({ prereadRunUid: 'a-newer-run' });
      const before = await docData(w, `worklist/${caseUid}`);
      await w.deps.db.collection('cases').doc(caseUid).collection('preread').doc(runUid).update({
        status: 'Ready',
        draft: { urgency: 'Urgent', confidenceBand: 'High', confidence: 0.9, impression: 'x', findings: [] },
      });
      await onPrereadWrittenHandler(w.deps, caseUid, runUid);
      assert.equal((await caseDoc(w, caseUid)).currentStage, 'PrereadQueued');
      assert.deepEqual(await docData(w, `worklist/${caseUid}`), before);
    });

    it('moves a queued case to PrereadFailed when the run failed', async () => {
      const { caseUid, runUid } = await prereadQueuedCase(w);
      await w.deps.db
        .collection('cases')
        .doc(caseUid)
        .collection('preread')
        .doc(runUid)
        .update({ status: 'Failed', failureReason: 'Timeout' });
      await onPrereadWrittenHandler(w.deps, caseUid, runUid);
      const doc = await caseDoc(w, caseUid);
      assert.equal(doc.currentStage, 'PrereadFailed');
      assert.equal((await docData(w, `worklist/${caseUid}`))?.prereadStatus, 'Failed');
      assert.ok(await docData(w, noteId('prereadFailed', `${caseUid}-r${doc.stageSeq as number}`, w.pathologist.uid)));
    });
  });
});
