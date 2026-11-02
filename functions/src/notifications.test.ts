// cspell:ignore Kipindupindu
import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';

import type { DocumentSnapshot } from 'firebase-admin/firestore';

import { applyCounts, loadMarks } from './counters';
import { loadDiseasesFromDisk, setDiseasesForTest } from './disease-data';
import { emulatorDeps, resetEmulators } from './emulator.test-support';
import {
  ALERT_DELIVERY_ARG_ALLOW,
  GLOBAL_ARG_ALLOW,
  NotificationTx,
  TEMPLATES,
  renderPush,
  templateOf,
} from './notifications';
import { CaseState, commitCase, transition } from './orchestrator';
import { pushEn } from './copy/notifications.en';
import { pushSw } from './copy/notifications.sw';
import { closeShare, loadShareClose, mintShareCode } from './shares';

describe('notifications', () => {
  after(() => {
    loadDiseasesFromDisk();
  });

  beforeEach(async () => {
    await resetEmulators();
    setDiseasesForTest([
      { diseaseId: 'cholera', nameEn: 'Cholera', nameSw: 'Kipindupindu' },
    ]);
  });

  it('every template args ⊆ allow-list', () => {
    for (const t of TEMPLATES) {
      for (const key of t.argKeys) {
        const ok =
          GLOBAL_ARG_ALLOW.has(key) ||
          (ALERT_DELIVERY_ARG_ALLOW.has(key) &&
            (t.key === 'alertDeliveredClinician' ||
              t.key === 'alertDeliveredPatient' ||
              t.key === 'alertDeliveredClinicianDemo' ||
              t.key === 'alertDeliveredPatientDemo'));
        assert.ok(ok, `${t.key} forbids arg ${key}`);
      }
    }
  });

  it('push copy has no diagnosis, name, critical, or free-text disease', () => {
    const banned = /\b(critical|diagnosis|cancer|otieno|amina|cholera)\b/i;
    for (const t of TEMPLATES) {
      for (const lang of [pushEn, pushSw] as const) {
        const copy = lang[t.key];
        assert.ok(copy, t.key);
        const text = `${copy.title ?? ''} ${copy.body} ${copy.bodyPlural ?? ''}`;
        if (t.argKeys.includes('diseaseId')) {
          assert.equal(/\bcritical\b/i.test(text), false, t.key);
          assert.ok(text.includes('{disease}'));
          continue;
        }
        assert.equal(banned.test(text), false, `${t.key}: ${text}`);
      }
    }
  });

  it('resolves alert names from the bundle and refuses free text / unknown ids', () => {
    const ok = renderPush('alertDeliveredClinician', 'en', {
      diseaseId: 'cholera',
      countyId: '47',
    });
    assert.ok(ok.body.includes('Cholera'));
    assert.ok(ok.body.includes('Nairobi'));
    assert.throws(
      () =>
        renderPush('alertDeliveredClinician', 'en', {
          diseaseId: '12 cases of cholera',
          countyId: '47',
        }),
      (e: Error) => e.message === 'invalidTemplateArgs',
    );
    assert.throws(
      () =>
        renderPush('alertDeliveredClinician', 'en', {
          diseaseId: 'cholera',
          countyId: '999',
        }),
      (e: Error) => e.message === 'invalidTemplateArgs',
    );
  });

  it('synthetic alert copy starts with Demo / Majaribio', () => {
    assert.ok(pushEn.alertDeliveredClinicianDemo.body.startsWith('Demo:'));
    assert.ok(pushSw.alertDeliveredClinicianDemo.body.startsWith('Majaribio:'));
  });

  it('collapsed count resets after the row was read', async () => {
    const deps = emulatorDeps();
    const id = 'messageReceived:conv-1:u1';
    await deps.db.collection('notifications').doc(id).set({
      uid: id,
      templateKey: 'messageReceived',
      templateArgs: { newCount: '3' },
      status: 'Read',
      readAt: '2026-10-27T08:00:00.000Z',
      pushRequestedAt: '2026-10-27T07:00:00.000Z',
    });
    await deps.db.runTransaction(async (tx) => {
      const loaded = await NotificationTx.load(tx, deps.db, 'messageReceived', 'conv-1', 'u1');
      NotificationTx.upsertCollapsed(
        tx,
        loaded,
        {
          template: 'messageReceived',
          resourceKey: 'conv-1',
          resourceUid: 'conv-1',
          threadUid: 'conv-1',
          recipientUid: 'u1',
          recipientRole: 'doctor',
          language: 'en',
        },
        deps.now!(),
      );
    });
    const after = (await deps.db.collection('notifications').doc(id).get()).data()!;
    assert.equal(after.templateArgs.newCount, '1');
    assert.ok(after.expireAt);
  });

  it('chains two closes, reissue, two counters, transition+notify in one Tx', async () => {
    const deps = emulatorDeps();
    const key = randomBytes(32).toString('hex');
    const caseRef = deps.db.collection('cases').doc('case-tx');
    const pathologist = deps.db.collection('doctors').doc('path-1');
    const patient = deps.db.collection('patients').doc('pat-rec');
    await pathologist.set({ uid: 'path-1', reportsSigned: 0 });
    await patient.set({ uid: 'pat-rec', casesReported: 0 });

    for (const [shareUid, code] of [
      ['share-a', '1010'],
      ['share-b', '2020'],
    ] as const) {
      await deps.db.runTransaction(async (tx) => {
        const loaded = await NotificationTx.load(tx, deps.db, 'caseShared', shareUid, 'rec');
        mintShareCode(
          tx,
          deps.db,
          {
            shareUid,
            caseUid: 'case-tx',
            purpose: 'Join',
            createdByUid: 'doc-1',
            createdByRole: 'doctor',
            recipientUid: 'rec',
            expiresAt: '2026-10-28T09:00:00.000Z',
            template: 'caseShared',
          },
          loaded,
          key,
          deps.now!(),
          undefined,
          () => code,
        );
      });
    }
    await deps.db.runTransaction(async (tx) => {
      const loaded = await NotificationTx.load(tx, deps.db, 'reportSigned', 'unlock_c_v1', 'doc-1');
      mintShareCode(
        tx,
        deps.db,
        {
          shareUid: 'unlock_c_v1',
          caseUid: 'case-tx',
          reportUid: 'v1',
          purpose: 'ReportUnlock',
          createdByUid: 'path-1',
          createdByRole: 'pathologist',
          recipientUid: 'doc-1',
          expiresAt: '2026-10-27T08:00:00.000Z',
          template: 'reportSigned',
        },
        loaded,
        key,
        deps.now!(),
        undefined,
        () => '3030',
      );
    });

    await deps.db.runTransaction(async (tx) => {
      const closeA = await loadShareClose(tx, deps.db, 'share-a');
      const closeB = await loadShareClose(tx, deps.db, 'share-b');
      const unlock = await loadShareClose(tx, deps.db, 'unlock_c_v1');
      const reissueNote = await NotificationTx.load(
        tx,
        deps.db,
        'shareCodeReissued',
        'unlock_c_v1-r1',
        'doc-1',
      );
      const orderNote = await NotificationTx.load(
        tx,
        deps.db,
        'orderCancelled',
        'case-tx-r1',
        'pat-1',
      );
      const marks = await loadMarks(tx, deps.db, [
        { counter: 'reportsSigned', resourceUid: 'case-tx' },
        { counter: 'casesReported', resourceUid: 'case-tx' },
      ]);
      const priorSnap = {
        exists: true,
        data: () => ({ ...(unlock.share as object), status: 'Pending', reissueCount: 0 }),
      } as unknown as DocumentSnapshot;

      closeShare(tx, deps.db, closeA, 'Revoked', deps.now!());
      closeShare(tx, deps.db, closeB, 'Revoked', deps.now!());
      closeShare(tx, deps.db, unlock, 'Expired', deps.now!());
      mintShareCode(
        tx,
        deps.db,
        {
          shareUid: 'unlock_c_v1',
          caseUid: 'case-tx',
          reportUid: 'v1',
          purpose: 'ReportUnlock',
          createdByUid: 'path-1',
          createdByRole: 'pathologist',
          recipientUid: 'doc-1',
          expiresAt: '2026-11-03T09:00:00.000Z',
          template: 'shareCodeReissued',
          resourceKey: 'unlock_c_v1-r1',
          mode: 'reissue',
        },
        reissueNote,
        key,
        deps.now!(),
        priorSnap,
        () => '4040',
      );
      applyCounts(
        tx,
        marks,
        [
          {
            counter: 'reportsSigned',
            resourceUid: 'case-tx',
            targetRef: pathologist,
            field: 'reportsSigned',
          },
          {
            counter: 'casesReported',
            resourceUid: 'case-tx',
            targetRef: patient,
            field: 'casesReported',
          },
        ],
        deps.now!(),
      );
      let s = CaseState.initial({
        uid: 'case-tx',
        doctorUid: 'doc-1',
        patientUid: 'pat-1',
      });
      s = transition(s, 'OrderCreated', { actorUid: 'doc-1', actorRole: 'Doctor' });
      s = transition(s, 'Cancelled', {
        actorUid: 'doc-1',
        actorRole: 'Doctor',
        action: 'Cancel',
        reason: 'OrderedInError',
      });
      commitCase(tx, caseRef, s, deps.now!());
      NotificationTx.create(
        tx,
        orderNote,
        {
          template: 'orderCancelled',
          resourceKey: 'case-tx-r1',
          resourceUid: 'case-tx',
          threadUid: 'case-tx',
          recipientUid: 'pat-1',
          recipientRole: 'patient',
          language: 'en',
        },
        deps.now!(),
      );
    });

    assert.equal((await deps.db.collection('shareCodes').doc('share-a').get()).data()?.status, 'Revoked');
    assert.equal((await deps.db.collection('shareCodes').doc('share-b').get()).data()?.status, 'Revoked');
    assert.equal((await deps.db.collection('shareCodes').doc('unlock_c_v1').get()).data()?.status, 'Pending');
    assert.equal((await deps.db.collection('shareCodes').doc('unlock_c_v1').get()).data()?.reissueCount, 1);
    assert.equal((await pathologist.get()).data()?.reportsSigned, 1);
    assert.equal((await patient.get()).data()?.casesReported, 1);
    assert.equal((await caseRef.get()).data()?.currentStage, 'Cancelled');
    assert.equal(
      (await deps.db.collection('notifications').doc('orderCancelled:case-tx-r1:pat-1').get()).exists,
      true,
    );
    assert.equal(
      (await deps.db.collection('notifications').doc('shareCodeReissued:unlock_c_v1-r1:doc-1').get())
        .exists,
      true,
    );
  });

  it('raises a row’s priority only for a template that allows it', async () => {
    const deps = emulatorDeps();
    const send = (template: string, priority: 'High' | 'Normal') =>
      deps.db.runTransaction(async (tx) => {
        const loaded = await NotificationTx.load(tx, deps.db, template, 'k', 'u1');
        NotificationTx.create(
          tx,
          loaded,
          {
            template,
            resourceKey: 'k',
            resourceUid: 'k',
            threadUid: 'k',
            recipientUid: 'u1',
            recipientRole: 'doctor',
            language: 'en',
            priority,
          },
          deps.now!(),
        );
      });
    await assert.rejects(send('orderCreated', 'High'), (e: Error) => e.message === 'priorityNotAllowed');
    assert.equal((await deps.db.collection('notifications').doc('orderCreated:k:u1').get()).exists, false);
    await send('reportSigned', 'High');
    assert.equal((await deps.db.collection('notifications').doc('reportSigned:k:u1').get()).data()?.priority, 'High');
    await send('orderCreated', 'Normal');
    assert.equal((await deps.db.collection('notifications').doc('orderCreated:k:u1').get()).data()?.priority, 'Normal');
  });

  it('deliberately reading after a write throws', async () => {
    const deps = emulatorDeps();
    await assert.rejects(
      deps.db.runTransaction(async (tx) => {
        const ref = deps.db.collection('cases').doc('x');
        tx.set(ref, { uid: 'x' });
        await tx.get(ref);
      }),
    );
  });

  it('templateOf covers all 46 keys', () => {
    assert.equal(TEMPLATES.length, 46);
    for (const t of TEMPLATES) {
      assert.equal(templateOf(t.key).key, t.key);
      assert.ok(pushEn[t.key]);
      assert.ok(pushSw[t.key]);
    }
  });
});
