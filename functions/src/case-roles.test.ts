import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';

import {
  acceptCaseHandler,
  cancelOrderHandler,
  completeCaseHandler,
  createOrderHandler,
  reassignPathologistHandler,
  recordSampleReceivedHandler,
  registerSlidesHandler,
  rejectCaseHandler,
  removeCaseViewerHandler,
  requestPathologistHandler,
  reserveSlideUploadsHandler,
} from './cases';
import { orderInput, seedWorld, type World } from './case.test-support';
import { callerWithoutRole, resetEmulators } from './emulator.test-support';
import {
  approveReportTextHandler,
  discardDraftHandler,
  markDiscussedHandler,
  requestReportTextHandler,
  scorePrereadHandler,
  signReportHandler,
  startReportHandler,
} from './reports';
import {
  createShareCodeHandler,
  redeemShareCodeHandler,
  reissueShareCodeHandler,
  revokeShareCodeHandler,
} from './shares-callables';

// A signed-in account whose sign-up has not finished holds no role. Each handler checks the role
// before it reads anything, so what it is asked for does not matter; these are plausible values.
describe('a caller with no role', () => {
  let w: World;

  beforeEach(async () => {
    await resetEmulators();
    w = await seedWorld();
  });

  it('is refused by every case, share and report callable, and nothing is written', async () => {
    const caseUid = randomUUID();
    const shareUid = randomUUID();
    const data = {
      ...orderInput(w),
      caseUid,
      shareUid,
      recipientUid: w.colleague.uid,
      viewerUid: w.colleague.uid,
      pathologistUid: w.pathologist.uid,
      reasonCode: 'Other',
      reason: 'No capacity.',
      labAccessionNo: 'LAB/26-1',
      count: 1,
      images: [{ imageUid: randomUUID(), contentType: 'image/jpeg', micronsPerPixel: 0.25 }],
      code: '1234',
      kind: 'Translation',
      reportUid: 'v1',
      textUid: 'v1_Translation_sw',
      decision: 'Approve',
      draftLastUpdatedAt: '2026-10-27T08:30:00.000Z',
      signaturePng: '',
      runUid: randomUUID(),
    };
    const handlers = {
      createOrderHandler,
      requestPathologistHandler,
      acceptCaseHandler,
      rejectCaseHandler,
      reassignPathologistHandler,
      recordSampleReceivedHandler,
      reserveSlideUploadsHandler,
      registerSlidesHandler,
      cancelOrderHandler,
      completeCaseHandler,
      removeCaseViewerHandler,
      createShareCodeHandler,
      redeemShareCodeHandler,
      revokeShareCodeHandler,
      reissueShareCodeHandler,
      startReportHandler,
      discardDraftHandler,
      scorePrereadHandler,
      signReportHandler,
      markDiscussedHandler,
      approveReportTextHandler,
      requestReportTextHandler,
    };
    const who = callerWithoutRole();
    for (const [name, handler] of Object.entries(handlers)) {
      await assert.rejects(
        (handler as (deps: World['deps'], caller: typeof who, data: unknown) => Promise<unknown>)(w.deps, who, data),
        (e: { code?: string }) => e.code === 'permission-denied',
        `${name} served a caller with no role`,
      );
    }
    for (const path of ['cases', 'shareCodes', 'worklist', 'orderNumbers']) {
      assert.equal((await w.deps.db.collection(path).get()).size, 0, `${path} was written`);
    }
  });
});
