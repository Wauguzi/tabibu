import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';

import { getStorage } from 'firebase-admin/storage';

import { runAlertSweep } from './alert-sweep';
import { expireAppointmentsHandler } from './appointments';
import { sweepCasesHandler } from './cases';
import { BUCKET, emulatorDeps, resetEmulators } from './emulator.test-support';
import { seedAccounts } from './seed';
import {
  findPeople,
  seedCases,
  uidFor,
  weekStartOf,
  type People,
  type SeedResult,
} from './seed-cases';
import {
  histologyMeasurements,
  loadManifest,
  malariaMeasurements,
  type MalariaSpec,
  type Raster,
  type Tile,
} from './seed-cases-media';
import { hmacCode } from './shares';

const PASSWORD = randomBytes(12).toString('hex');
const email = (role: string): string => `${role}@seed.test`;
const KEY = randomBytes(32).toString('hex');
const FROM = new Date('2026-10-26T00:00:00+03:00');
const PROJECT_ID = 'demo-tabibu';

const STAGES: Record<string, string> = {
  explained: 'ResultReleased',
  signed: 'ReportSigned',
  hero: 'PrereadReady',
  lowConfidence: 'PrereadReady',
  queued: 'PrereadQueued',
  requested: 'PathologistRequested',
  accepted: 'PathologistAccepted',
  malaria: 'ReportSigned',
  blood: 'ReportInProgress',
  cancelled: 'Cancelled',
  completed: 'Completed',
};

const STAMPS = [
  'createdAt',
  'lastUpdatedAt',
  'signedAt',
  'readyAt',
  'startedAt',
  'requestedAt',
  'acceptedAt',
  'respondedAt',
  'completedAt',
  'cancelledAt',
  'discussedAt',
  'releasedAt',
  'decidedAt',
  'draftedAt',
  'deliveredAt',
  'sampleCollectedAt',
  'sampleReceivedAt',
  'stageEnteredAt',
  'pathologistAcceptedAt',
  'pathologistRequestedAt',
  'issuedAt',
  'raisedAt',
  'approvedAt',
];

/** Stand-ins for the archive's cell crops, so the suite never reaches the network. */
function fakeCells(spec: MalariaSpec): Promise<Raster[]> {
  return Promise.resolve(
    spec.cells.map((cell) => {
      const data = Buffer.alloc(40 * 40 * 3, cell.label === 'Parasitized' ? 90 : 200);
      return { width: 40, height: 40, channels: 3 as const, data };
    }),
  );
}

async function idToken(address: string): Promise<string> {
  const res = await fetch(
    `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=demo`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: address, password: PASSWORD, returnSecureToken: true }),
    },
  );
  const body = (await res.json()) as { idToken?: string };
  assert.ok(body.idToken, `no token for ${address}`);
  return body.idToken;
}

/** The status the rules give `token` reading `path`: 200 or 403. */
async function read(token: string, path: string): Promise<number> {
  const res = await fetch(
    `http://${process.env.FIRESTORE_EMULATOR_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/${path}`,
    { headers: { Authorization: `Bearer ${token}` } },
  );
  return res.status;
}

async function storedJson(path: string): Promise<{ labels: Tile[]; grid: { rows: number; cols: number; tilePx: number; micronsPerPixel: number } }> {
  const [bytes] = await getStorage().bucket(BUCKET).file(path).download();
  return JSON.parse(bytes.toString('utf8'));
}

async function seedWorld(now: Date): Promise<{ people: People; result: SeedResult }> {
  await resetEmulators();
  const deps = emulatorDeps();
  await seedAccounts(deps, PASSWORD, email);
  const people = await findPeople(deps.db, email);
  const result = await seedCases({
    db: deps.db,
    bucket: BUCKET,
    now,
    from: FROM,
    tag: '',
    shareCodeKey: KEY,
    people,
    cells: fakeCells,
  });
  return { people, result };
}

/** Every stamp lies in [from, now], each case's log runs forward, and a visit precedes its order. */
async function assertHistory(cases: Record<string, string>, now: Date): Promise<void> {
  const db = emulatorDeps().db;
  const stamp = (v: unknown): number => Date.parse(String(v));
  const inside = (v: unknown, where: string): void => {
    assert.ok(stamp(v) >= FROM.getTime() && stamp(v) <= now.getTime(), `${where}: ${String(v)}`);
  };
  for (const name of ['cases', 'appointments', 'notifications', 'alerts', 'notifiableEvents', 'publicAlerts']) {
    for (const doc of (await db.collection(name).get()).docs) {
      for (const field of STAMPS) {
        const v = doc.get(field);
        if (typeof v === 'string' && v !== '') inside(v, `${name}/${doc.id}.${field}`);
      }
    }
  }
  for (const [key, caseUid] of Object.entries(cases)) {
    const log = (await db.collection('cases').doc(caseUid).collection('log').orderBy('seq').get()).docs;
    assert.ok(log.length >= 2, key);
    let previous = 0;
    for (const entry of log) {
      const at = stamp(entry.get('createdAt'));
      inside(entry.get('createdAt'), `${key} log ${entry.id}`);
      assert.ok(at >= previous, `${key}: log ${entry.id} runs backwards`);
      previous = at;
    }
    const data = (await db.collection('cases').doc(caseUid).get()).data() ?? {};
    assert.ok(stamp(data.createdAt) <= stamp(data.lastUpdatedAt), key);
    assert.equal(stamp(data.lastUpdatedAt), previous, `${key}: the case was last written by its last step`);
    const slot = stamp((await db.collection('appointments').doc(String(data.appointmentUid)).get()).get('scheduledStart'));
    assert.ok(slot <= stamp(data.createdAt), `${key}: the visit comes before the order`);
  }
  for (const doc of (await db.collection('appointments').get()).docs) {
    const a = doc.data();
    const times = [a.createdAt, a.acceptedAt, a.completedAt, a.cancelledAt].filter((v) => v);
    assert.deepEqual([...times].sort(), times, `${doc.id}: appointment steps out of order`);
  }
}

/** The live sweeps, a minute after the seed, expire and fail nothing, and every case keeps its stage. */
async function assertSweepsQuiet(cases: Record<string, string>, now: Date): Promise<void> {
  const db = emulatorDeps().db;
  const at = new Date(now.getTime() + 60_000);
  const deps = { db, bucket: BUCKET, now: () => at };
  assert.deepEqual(await sweepCasesHandler(deps), { expiredRequests: 0, expiredShares: 0, staleJobs: 0, criticalReminders: 0 });
  assert.equal((await expireAppointmentsHandler(deps)).expired, 0);
  assert.deepEqual(await runAlertSweep({ db, now: at, synthetic: true }, at), {
    reminded: 0,
    expired: 0,
    drafted: 0,
    resumed: 0,
    held: 0,
    failed: 0,
  });
  for (const [key, stage] of Object.entries(STAGES)) {
    const data = (await db.collection('cases').doc(cases[key]).get()).data();
    assert.equal(data?.currentStage, stage, key);
  }
  const waiting = (await db.collection('appointments').get()).docs.filter((d) => d.get('status') === 'Requested');
  assert.equal(waiting.length, 1);
}

describe('seed-cases', function () {
  this.timeout(300_000);
  const now = new Date('2026-11-05T09:30:00.000Z');
  let people: People;
  let first: SeedResult;
  const db = () => emulatorDeps().db;
  const caseData = async (key: string) => (await db().collection('cases').doc(first.cases[key]).get()).data() ?? {};

  before(async () => {
    ({ people, result: first } = await seedWorld(now));
  });

  it('puts every case at the stage it is meant to wait in', async () => {
    for (const [key, stage] of Object.entries(STAGES)) {
      assert.equal((await caseData(key)).currentStage, stage, key);
    }
    assert.equal(Object.keys(first.cases).length, Object.keys(STAGES).length);
    assert.equal(first.created.filter((k) => k in STAGES).length, Object.keys(STAGES).length);
  });

  it('gives the mixed appointment states and the two alerts', async () => {
    const appointments = (await db().collection('appointments').get()).docs.map((d) => d.data());
    const count = (status: string) => appointments.filter((a) => a.status === status).length;
    assert.ok(count('Completed') >= 10, 'one completed visit per case, and the discussion');
    assert.equal(count('Accepted'), 1, 'one upcoming visit');
    assert.equal(count('Requested'), 1, 'one waiting for the doctor');
    assert.equal(count('Cancelled'), 1);
    assert.ok(appointments.every((a) => a.patientUid === people.patient.uid && a.doctorUid === people.doctor.uid));

    const alerts = (await db().collection('alerts').get()).docs.map((d) => d.data());
    const malaria = alerts.find((a) => a.diseaseId === 'malaria');
    assert.equal(malaria?.status, 'Draft', 'awaiting the approver');
    assert.equal(malaria?.synthetic, true);
    assert.match(String(malaria?.machineText.patient_en.headline), /^Demo: /);
    assert.equal(malaria?.evidence.confirmedCount, 5);
    const measles = alerts.find((a) => a.diseaseId === 'measles');
    assert.equal(measles?.status, 'Delivered');
    assert.equal(measles?.decidedByUid, people.doctor.uid);
    const published = (await db().collection('publicAlerts').doc(String(measles?.uid)).get()).data();
    assert.equal(published?.patientsReleased, true);
    assert.equal(published?.synthetic, true);
    assert.match(String(published?.patientText.en.headline), /^Demo: /);
  });

  it('is idempotent: a second run makes and changes nothing', async () => {
    const counts = async () => {
      const out: Record<string, number> = {};
      for (const name of ['cases', 'appointments', 'notifications', 'alerts', 'notifiableEvents', 'shareCodes']) {
        out[name] = (await db().collection(name).get()).size;
      }
      return out;
    };
    const stamps = async () =>
      Object.fromEntries((await db().collection('cases').get()).docs.map((d) => [d.id, d.get('lastUpdatedAt')]));
    const before = { counts: await counts(), stamps: await stamps() };
    const second = await seedCases({
      db: db(),
      bucket: BUCKET,
      now,
      from: FROM,
      tag: '',
      shareCodeKey: KEY,
      people,
      cells: fakeCells,
    });
    assert.deepEqual(second.created, []);
    assert.deepEqual(second.cases, first.cases);
    assert.deepEqual({ counts: await counts(), stamps: await stamps() }, before);
  });

  describe('what each person can read, by the Firestore rules', () => {
    let doctor: string;
    let pathologist: string;
    let patient: string;
    before(async () => {
      doctor = await idToken(email('doctor'));
      pathologist = await idToken(email('pathologist'));
      patient = await idToken(email('patient'));
    });
    const path = (key: string, rest: string) => `cases/${first.cases[key]}/${rest}`;

    it('shows an unsigned draft and a pre-read to the pathologist alone', async () => {
      const draft = path('blood', `reportDrafts/${people.pathologist.uid}`);
      assert.equal(await read(pathologist, draft), 200);
      assert.equal(await read(doctor, draft), 403);
      assert.equal(await read(patient, draft), 403);

      for (const key of ['hero', 'lowConfidence', 'queued']) {
        const run = (await db().collection('cases').doc(first.cases[key]).collection('preread').get()).docs[0];
        assert.equal(await read(pathologist, path(key, `preread/${run.id}`)), 200, key);
        assert.equal(await read(doctor, path(key, `preread/${run.id}`)), 403, key);
        assert.equal(await read(patient, path(key, `preread/${run.id}`)), 403, key);
      }
    });

    it('keeps a signed report from the doctor until the code is entered, and from the patient until it is discussed', async () => {
      for (const key of ['signed', 'malaria']) {
        const report = path(key, 'reports/v1');
        assert.equal(await read(pathologist, report), 200, key);
        assert.equal(await read(doctor, report), 403, key);
        assert.equal(await read(patient, report), 403, key);
        const data = await caseData(key);
        assert.equal(data.releasedToPatient, false);
        assert.equal(data.discussedAt, '');
      }
      for (const key of ['explained', 'completed']) {
        assert.equal(await read(doctor, path(key, 'reports/v1')), 200, key);
        assert.equal(await read(patient, path(key, 'reports/v1')), 200, key);
      }
      assert.equal(await read(patient, path('explained', 'reportTextsApproved/v1_Explanation_sw')), 200);
      assert.equal(await read(doctor, path('signed', 'reportTextsApproved/v1_Explanation_sw')), 403);
    });

    it('lets the approver, and nobody else clinical, read the alert awaiting a decision', async () => {
      const malaria = (await db().collection('alerts').get()).docs.find((d) => d.get('diseaseId') === 'malaria');
      assert.ok(malaria);
      assert.equal(await read(doctor, `alerts/${malaria.id}`), 200);
      assert.equal(await read(pathologist, `alerts/${malaria.id}`), 403);
      assert.equal(await read(patient, `alerts/${malaria.id}`), 403);
      const measles = (await db().collection('publicAlerts').get()).docs.find((d) => d.get('diseaseId') === 'measles');
      assert.ok(measles);
      assert.equal(await read(patient, `publicAlerts/${measles.id}`), 200);
    });
  });

  it('holds the doctor a working unlock code for the signed report', async () => {
    const shareUid = `unlock_${first.cases.signed}_v1`;
    const share = (await db().collection('shareCodes').doc(shareUid).get()).data();
    assert.equal(share?.status, 'Pending');
    assert.equal(share?.recipientUid, people.doctor.uid);
    const row = (
      await db().doc(`notifications/reportSigned:${first.cases.signed}_v1:${people.doctor.uid}`).get()
    ).data();
    const code = String(row?.metadata.shareCode);
    assert.match(code, /^\d{4}$/);
    const secret = (await db().collection('shareSecrets').doc(shareUid).get()).data();
    assert.equal(secret?.codeHmac, hmacCode(KEY, shareUid, code));
  });

  it('computes every pre-read number from the stored labels', async () => {
    const manifest = loadManifest();
    for (const key of ['hero', 'lowConfidence', 'malaria']) {
      const run = (await db().collection('cases').doc(first.cases[key]).collection('preread').get()).docs[0].data();
      const { labels, grid } = await storedJson(String(run.labelsPath));
      assert.equal(run.status, 'Ready');
      assert.ok(String(run.models.provenance).startsWith('Stored demo example'));
      const counts: Record<string, number> = {};
      for (const t of labels) counts[t.label] = (counts[t.label] ?? 0) + 1;
      assert.deepEqual(run.labelCounts, counts, key);
      const m = run.measurements as Record<string, number>;

      if (key === 'malaria') {
        const parasitised = counts.Parasitized;
        assert.equal(labels.length, manifest.malaria.cells.length);
        assert.deepEqual(m, malariaMeasurements(labels));
        assert.equal(m.parasitizedCells, parasitised);
        assert.equal(m.cellsCounted, labels.length);
        assert.equal(m.parasitaemiaPercent, Math.round((10000 * parasitised) / labels.length) / 100);
        const text = [run.draft.impression, ...run.draft.findings.map((f: { text: string }) => f.text)].join(' ');
        assert.ok(text.includes(`${m.parasitaemiaPercent}%`) && text.includes(`${parasitised} of ${labels.length}`));
        const report = (await db().collection('cases').doc(first.cases[key]).collection('reports').doc('v1').get()).data();
        assert.deepEqual(
          report?.measurements,
          Object.keys(m).sort().map((k) => ({ key: k, unit: '', value: m[k], precision: 2 })),
        );
        assert.ok(String(report?.diagnosis).includes(`${m.parasitaemiaPercent}%`));
        assert.deepEqual(report?.notifiableFindings, [{ diseaseId: 'malaria', alertRequested: false }]);
      } else {
        const tumour = counts.Tumour ?? 0;
        assert.deepEqual(m, histologyMeasurements(labels, grid, grid.micronsPerPixel), key);
        assert.equal(m.tumourTiles, tumour);
        assert.equal(m.normalTiles, labels.length - tumour);
        assert.equal(m.tumourAreaPercent, Math.round((10000 * tumour) / labels.length) / 100);
        assert.equal(grid.micronsPerPixel, 0.972);
        const text = run.draft.findings.map((f: { text: string }) => f.text).join(' ');
        assert.ok(text.includes(`${tumour} of ${labels.length}`) && text.includes(`${m.largestFocusMm} mm`), key);
      }
      assert.ok(run.draft.confidence > 0 && run.draft.confidence <= 1);
    }
    const low = (await db().collection('cases').doc(first.cases.lowConfidence).collection('preread').get()).docs[0].data();
    assert.equal(low.draft.confidenceBand, 'Low');
    const hero = (await db().collection('cases').doc(first.cases.hero).collection('preread').get()).docs[0].data();
    assert.equal(hero.draft.confidenceBand, 'High');
    assert.equal(hero.draft.urgency, 'Urgent');
  });

  it('runs every step of every case forward, inside the history', async () => {
    await assertHistory(first.cases, now);
  });

  it('leaves every waiting case, request and alert alone when the live sweeps run just after the seed', async () => {
    await assertSweepsQuiet(first.cases, now);
  });

  it('builds the explained case the way the app reads it', async () => {
    const data = await caseData('explained');
    assert.equal(data.releasedToPatient, true);
    assert.equal(data.resultState, 'Released');
    assert.notEqual(data.discussedAt, '');
    for (const language of ['en', 'sw']) {
      const approved = (
        await db().collection('cases').doc(first.cases.explained).collection('reportTextsApproved').doc(`v1_Explanation_${language}`).get()
      ).data();
      assert.equal(approved?.acceptedUnchanged, true);
      assert.equal(approved?.approverUid, people.doctor.uid);
      assert.deepEqual(Object.keys(approved?.approvedText), ['summary', 'meaning', 'next']);
    }
    assert.equal((await caseData('cancelled')).cancelReason, 'OrderedInError');
    assert.equal(uidFor('', 'case:explained'), first.cases.explained);
  });
});

describe('seed-cases at every hour of the week', function () {
  this.timeout(600_000);
  const db = () => emulatorDeps().db;
  // Nairobi is three hours ahead of these stamps.
  const runs: [string, string][] = [
    ['Monday 03:30, before any working hour of the new week', '2026-11-02T00:30:00.000Z'],
    ['Monday 13:20', '2026-11-02T10:20:00.000Z'],
    ['Tuesday 08:05', '2026-11-03T05:05:00.000Z'],
    ['Wednesday 17:40', '2026-11-04T14:40:00.000Z'],
    ['Friday 16:55', '2026-11-06T13:55:00.000Z'],
    ['Saturday 11:00', '2026-11-07T08:00:00.000Z'],
    ['Sunday 23:00, the week nearly over', '2026-11-01T20:00:00.000Z'],
  ];

  for (const [name, at] of runs) {
    it(`builds every case and keeps the waiting ones waiting on ${name}`, async () => {
      const when = new Date(at);
      const { result } = await seedWorld(when);
      assert.equal(Object.keys(result.cases).length, Object.keys(STAGES).length);
      for (const [key, stage] of Object.entries(STAGES)) {
        const data = (await db().collection('cases').doc(result.cases[key]).get()).data();
        assert.equal(data?.currentStage, stage, key);
      }
      await assertHistory(result.cases, when);
      await assertSweepsQuiet(result.cases, when);
      const malaria = (await db().collection('alerts').get()).docs.find((d) => d.get('diseaseId') === 'malaria');
      assert.equal(malaria?.get('status'), 'Draft');
      assert.equal(malaria?.get('evidence').confirmedCount, 5);
      assert.ok(weekStartOf(when.getTime()) <= Date.parse(String(malaria?.get('createdAt'))));
    });
  }
});
