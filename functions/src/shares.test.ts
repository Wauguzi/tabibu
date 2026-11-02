import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';

import { emulatorDeps, resetEmulators } from './emulator.test-support';
import { NotificationTx } from './notifications';
import {
  closeShare,
  generateShareCode,
  hmacCode,
  judgeRedemption,
  loadShareClose,
  mintShareCode,
  type ShareRecord,
} from './shares';

describe('shares', () => {
  beforeEach(async () => {
    await resetEmulators();
  });

  it('mints without returning a code; public doc has no code field', async () => {
    const deps = emulatorDeps();
    const key = randomBytes(32).toString('hex');
    const fixed = '4242';
    await deps.db.runTransaction(async (tx) => {
      const loaded = await NotificationTx.load(tx, deps.db, 'caseShared', 'share-1', 'rec');
      const result = mintShareCode(
        tx,
        deps.db,
        {
          shareUid: 'share-1',
          caseUid: 'case-1',
          purpose: 'Join',
          createdByUid: 'doc',
          createdByRole: 'doctor',
          recipientUid: 'rec',
          expiresAt: '2026-10-28T09:00:00.000Z',
          template: 'caseShared',
        },
        loaded,
        key,
        deps.now!(),
        undefined,
        () => fixed,
      );
      assert.deepEqual(Object.keys(result), ['shareUid']);
      assert.equal('code' in result, false);
    });
    const share = (await deps.db.collection('shareCodes').doc('share-1').get()).data()!;
    assert.equal(Object.prototype.hasOwnProperty.call(share, 'code'), false);
    assert.equal(share.notificationUid, 'caseShared:share-1:rec');
    const note = (await deps.db.collection('notifications').doc(share.notificationUid as string).get()).data()!;
    assert.equal((note.metadata as { shareCode: string }).shareCode, fixed);
    const secret = (await deps.db.collection('shareSecrets').doc('share-1').get()).data()!;
    assert.equal(secret.codeHmac, hmacCode(key, 'share-1', fixed));
  });

  it('closeShare Expired deletes the secret and clears the code', async () => {
    const deps = emulatorDeps();
    const key = randomBytes(32).toString('hex');
    const fixed = '7373';
    await deps.db.runTransaction(async (tx) => {
      const loaded = await NotificationTx.load(tx, deps.db, 'caseShared', 'share-2', 'rec');
      mintShareCode(
        tx,
        deps.db,
        {
          shareUid: 'share-2',
          caseUid: 'case-2',
          purpose: 'Join',
          createdByUid: 'doc',
          createdByRole: 'doctor',
          recipientUid: 'rec',
          expiresAt: '2026-10-27T08:00:00.000Z',
          template: 'caseShared',
        },
        loaded,
        key,
        deps.now!(),
        undefined,
        () => fixed,
      );
    });
    await deps.db.runTransaction(async (tx) => {
      const loaded = await loadShareClose(tx, deps.db, 'share-2');
      closeShare(tx, deps.db, loaded, 'Expired', deps.now!());
    });
    assert.equal((await deps.db.collection('shareSecrets').doc('share-2').get()).exists, false);
    const after = (await deps.db.collection('shareCodes').doc('share-2').get()).data()!;
    assert.equal(after.status, 'Expired');
    const note = (
      await deps.db.collection('notifications').doc('caseShared:share-2:rec').get()
    ).data()!;
    assert.equal((note.metadata as { shareCode: string }).shareCode, '');
    const pending = (
      await deps.db.collection('rateCounters').doc('pendingShares:case-2').get()
    ).data();
    assert.equal(pending?.count, 0);
  });

  it('reissues into the same share id after expiry, four times', async () => {
    const deps = emulatorDeps();
    const key = randomBytes(32).toString('hex');
    const shareUid = 'unlock_c_v1';
    for (let round = 0; round < 4; round++) {
      const resourceKey = round === 0 ? shareUid : `${shareUid}-r${round}`;
      const template = round === 0 ? 'reportSigned' : 'shareCodeReissued';
      await deps.db.runTransaction(async (tx) => {
        // All reads first.
        const closing = round > 0 ? await loadShareClose(tx, deps.db, shareUid) : null;
        const prior =
          closing?.share != null
            ? await tx.get(deps.db.collection('shareCodes').doc(shareUid))
            : await tx.get(deps.db.collection('shareCodes').doc(shareUid));
        const loaded = await NotificationTx.load(tx, deps.db, template, resourceKey, 'doc');
        // Then writes.
        if (closing) closeShare(tx, deps.db, closing, 'Expired', deps.now!());
        mintShareCode(
          tx,
          deps.db,
          {
            shareUid,
            caseUid: 'c',
            reportUid: 'v1',
            purpose: 'ReportUnlock',
            createdByUid: 'path',
            createdByRole: 'pathologist',
            recipientUid: 'doc',
            expiresAt: '2026-11-03T09:00:00.000Z',
            template,
            resourceKey,
            mode: round === 0 ? 'create' : 'reissue',
          },
          loaded,
          key,
          deps.now!(),
          prior,
          () => `5${round}${round}5`,
        );
      });
      const secrets = await deps.db.collection('shareSecrets').get();
      assert.equal(secrets.size, 1);
      const share = (await deps.db.collection('shareCodes').doc(shareUid).get()).data()!;
      assert.equal(share.status, 'Pending');
      assert.equal(share.reissueCount, round);
    }
  });

  describe('reissuing a revoked share', () => {
    async function reissueOver(purpose: 'Join' | 'ReportUnlock'): Promise<void> {
      const deps = emulatorDeps();
      const key = randomBytes(32).toString('hex');
      await deps.db.collection('shareCodes').doc('s-1').set({
        uid: 's-1',
        caseUid: 'c',
        purpose,
        status: 'Revoked',
        reissueCount: 0,
        createdAt: '2026-10-27T08:00:00.000Z',
      });
      await deps.db.runTransaction(async (tx) => {
        const prior = await tx.get(deps.db.collection('shareCodes').doc('s-1'));
        const loaded = await NotificationTx.load(tx, deps.db, 'shareCodeReissued', 's-1-r1', 'doc');
        mintShareCode(
          tx,
          deps.db,
          {
            shareUid: 's-1',
            caseUid: 'c',
            reportUid: purpose === 'ReportUnlock' ? 'v1' : undefined,
            purpose,
            createdByUid: 'path',
            createdByRole: 'pathologist',
            recipientUid: 'doc',
            expiresAt: '2026-11-03T09:00:00.000Z',
            template: 'shareCodeReissued',
            resourceKey: 's-1-r1',
            mode: 'reissue',
          },
          loaded,
          key,
          deps.now!(),
          prior,
          () => '4321',
        );
      });
    }

    it('lets a revoked unlock code come back, since the doctor’s right to it never lapses', async () => {
      await reissueOver('ReportUnlock');
      const share = (await emulatorDeps().db.collection('shareCodes').doc('s-1').get()).data()!;
      assert.equal(share.status, 'Pending');
      assert.equal(share.reissueCount, 1);
    });

    it('keeps a revoked invitation closed', async () => {
      await assert.rejects(reissueOver('Join'), (e: Error) => e.message === 'shareNotReusable');
    });
  });

  it('judgeRedemption locks after five wrong codes and refuses after lock', () => {
    const key = randomBytes(32).toString('hex');
    const share: ShareRecord = {
      uid: 's',
      caseUid: 'c',
      reportUid: '',
      purpose: 'Join',
      createdByUid: 'd',
      createdByRole: 'doctor',
      recipientUid: 'r',
      status: 'Pending',
      attempts: 0,
      reissueCount: 0,
      expiresAt: '2026-10-28T09:00:00.000Z',
      redeemedAt: '',
      notificationUid: '',
      createdAt: '',
      lastUpdatedAt: '',
    };
    const hmac = hmacCode(key, 's', '1111');
    let attempts = 0;
    for (let i = 0; i < 5; i++) {
      const j = judgeRedemption({ ...share, attempts }, hmac, key, '9999', new Date('2026-10-27T09:00:00.000Z'));
      assert.equal(j.outcome, 'Wrong');
      if (j.outcome === 'Wrong') {
        attempts = j.attempts;
        assert.equal(j.lock, i === 4);
      }
    }
    const locked = judgeRedemption(
      { ...share, attempts: 5, status: 'Locked' },
      hmac,
      key,
      '1111',
      new Date('2026-10-27T09:00:00.000Z'),
    );
    assert.equal(locked.outcome, 'Locked');
    const expired = judgeRedemption(
      share,
      hmac,
      key,
      '1111',
      new Date('2026-10-29T09:00:00.000Z'),
    );
    assert.equal(expired.outcome, 'Expired');
  });

  it('generateShareCode is four digits', () => {
    for (let i = 0; i < 20; i++) assert.match(generateShareCode(), /^\d{4}$/);
  });
});
