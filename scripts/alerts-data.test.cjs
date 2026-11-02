// The notifiable-disease bundle's build rules (make alerts-data, checked by
// make release-check): the pure functions' contracts, then the same checks
// over the built files.

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const {resolveLabTests, buildGuidance, scanProse, STATUTORY, main} = require('./alerts/build.cjs');

const root = path.join(__dirname, '..');
const appData = path.join(root, 'assets', 'data');

const disease = (overrides = {}) => ({
  diseaseId: 'test_disease',
  nameEn: 'Test disease',
  nameSw: 'Test disease, in Swahili',
  ihrStatus: 'None',
  reportingCategory: 'Immediate',
  kenyaGroup: 'NotListed',
  categorySourceId: '',
  categoryVerified: false,
  caseDefinitionEn: 'A case for tests.',
  caseDefinitionSw: 'A case for tests, in Swahili.',
  labTests: [],
  publicAlertEligible: true,
  allowManualAlert: false,
  preReadHint: '',
  sourceIds: [],
  ...overrides,
});

const source = (overrides = {}) => ({
  sourceId: 'S9',
  title: 'A test source',
  publisher: 'Test publisher',
  url: 'https://example.com/source',
  publishedOn: '2025-01-01',
  accessedOn: '2026-10-30',
  ...overrides,
});

const bullet = (overrides = {}) => ({
  bulletId: 'test_disease-p1',
  audience: 'Patient',
  textEn: 'Seek care promptly.',
  textSw: 'Seek care promptly, in Swahili.',
  swIsOfficial: false,
  sourceId: 'S9',
  ...overrides,
});

test('lab names resolve to exactly one catalogue row', () => {
  const catalogue = [
    {labTestId: 'id-1', name: 'Mpox NAATs'},
    {labTestId: 'id-2', name: 'Mpox NAATs'},
    {labTestId: 'id-3', name: 'Blood culture'},
  ];
  const [built] = resolveLabTests(
    [disease({labTests: [{name: 'Blood culture', strength: 'Supportive', mappingVerified: true}]})],
    catalogue,
  );
  assert.deepEqual(built.labTests, [
    {labTestId: 'id-3', name: 'Blood culture', strength: 'Supportive', mappingVerified: true},
  ]);
  assert.throws(
    () => resolveLabTests(
      [disease({labTests: [{name: 'No such test', strength: 'Confirms', mappingVerified: true}]})],
      catalogue,
    ),
    /matches no catalogue row/,
  );
  assert.throws(
    () => resolveLabTests(
      [disease({labTests: [{name: 'Mpox NAATs', strength: 'Confirms', mappingVerified: true}]})],
      catalogue,
    ),
    /matches 2 catalogue rows/,
  );
});

const guidanceEntry = (bullets, sources) => [{diseaseId: 'test_disease', reviewedOn: '2026-10-30', bullets, sources}];

const clinicianPair = (d) => [
  bullet({bulletId: 'test_disease-c1', audience: 'Clinician', textEn: d.caseDefinitionEn, textSw: d.caseDefinitionSw}),
  bullet({
    bulletId: 'test_disease-c2',
    audience: 'Clinician',
    textEn: STATUTORY.Immediate.en,
    textSw: STATUTORY.Immediate.sw,
  }),
];

test('flagged bullets and their sources never ship', () => {
  const d = disease();
  const [built] = buildGuidance(
    guidanceEntry(
      [
        bullet(),
        bullet({bulletId: 'test_disease-p2', textEn: 'Held back.', textSw: 'Held back, in Swahili.', sourceId: 'S12', sourceCheck: 'Ocr'}),
        ...clinicianPair(d),
      ],
      [source(), source({sourceId: 'S12', title: 'Scanned release', url: 'https://example.com/scan'})],
    ),
    new Map([[d.diseaseId, d]]),
  );
  assert.deepEqual(
    built.bullets.map((b) => b.bulletId),
    ['test_disease-p1', 'test_disease-c1', 'test_disease-c2'],
  );
  assert.deepEqual(built.sources.map((s) => s.sourceId), ['S9']);
  assert.ok(!('sourceCheck' in built.bullets[0]) && !('alsoCites' in built.bullets[0]));
});

test('guidance fails loudly on broken references', () => {
  const d = disease();
  const byId = new Map([[d.diseaseId, d]]);
  assert.throws(
    () => buildGuidance(guidanceEntry([bullet({sourceId: 'missing'}), ...clinicianPair(d)], [source()]), byId),
    /cites missing missing/,
  );
  assert.throws(
    () => buildGuidance(
      guidanceEntry([bullet({alsoCites: ['missing']}), ...clinicianPair(d)], [source()]),
      byId,
    ),
    /alsoCites missing missing/,
  );
  assert.throws(
    () => buildGuidance(guidanceEntry([bullet()], [source()]), new Map()),
    /no disease row/,
  );
  assert.throws(
    () => buildGuidance(
      guidanceEntry([bullet(), ...clinicianPair(d)], [source()]),
      new Map([[d.diseaseId, disease({publicAlertEligible: false})]]),
    ),
    /not alert-eligible/,
  );
});

test('case-definition and statutory bullets must match exactly', () => {
  const d = disease();
  const byId = new Map([[d.diseaseId, d]]);
  const statutory = clinicianPair(d)[1];
  assert.throws(
    () => buildGuidance(
      guidanceEntry([bullet(), statutory, bullet({
        bulletId: 'test_disease-c1',
        audience: 'Clinician',
        textEn: 'Drifted wording.',
        textSw: d.caseDefinitionSw,
      })], [source()]),
      byId,
    ),
    /drifted from the disease row/,
  );
  assert.throws(
    () => buildGuidance(
      guidanceEntry([bullet(), statutory, bullet({
        bulletId: 'test_disease-c1',
        audience: 'Clinician',
        textEn: d.caseDefinitionEn,
        textSw: 'Drifted wording.',
      })], [source()]),
      byId,
    ),
    /drifted from the disease row/,
  );
  assert.throws(
    () => buildGuidance(
      guidanceEntry([bullet(), statutory, bullet({
        bulletId: 'test_disease-c1',
        audience: 'Clinician',
        textEn: d.caseDefinitionEn,
        textSw: d.caseDefinitionSw,
      }), bullet({
        bulletId: 'test_disease-c3',
        audience: 'Clinician',
        textEn: 'A second case-definition bullet.',
        textSw: 'A second case-definition bullet, in Swahili.',
      })], [source()]),
      byId,
    ),
    /expected one case-definition bullet, found 2/,
  );
  assert.doesNotThrow(
    () => buildGuidance(
      guidanceEntry([bullet(), ...clinicianPair(d)], [source()]),
      byId,
    ),
  );
  assert.throws(
    () => buildGuidance(
      guidanceEntry([bullet(), bullet({
        bulletId: 'test_disease-c1',
        audience: 'Clinician',
        textEn: d.caseDefinitionEn,
        textSw: d.caseDefinitionSw,
      }), bullet({
        ...statutory,
        textSw: 'Wrong Swahili.',
      })], [source()]),
      byId,
    ),
    /statutory reminder Swahili does not match/,
  );
  const noDefinition = disease({caseDefinitionEn: '', caseDefinitionSw: ''});
  assert.throws(
    () => buildGuidance(
      guidanceEntry([bullet(), statutory, bullet({
        bulletId: 'test_disease-c1',
        audience: 'Clinician',
        textEn: 'A bullet with no definition behind it.',
        textSw: 'A bullet with no definition behind it, in Swahili.',
      })], [source()]),
      new Map([[noDefinition.diseaseId, noDefinition]]),
    ),
    /no case definition/,
  );
  assert.throws(
    () => buildGuidance(guidanceEntry([bullet()], [source()]), byId),
    /statutory reminder/,
  );
});

test('prose never mentions 2026 or an imported case', () => {
  assert.throws(
    () => scanProse([disease({nameEn: 'Outbreak 2026 edition'})], []),
    /mentions 2026/,
  );
  assert.throws(
    () => scanProse([], [{diseaseId: 'x', bullets: [bullet({textEn: 'After imported cases arrived'})], sources: []}]),
    /imported case/,
  );
  // Dates live in date fields, which the scan does not read.
  assert.doesNotThrow(() => scanProse(
    [],
    [{
      diseaseId: 'x',
      bullets: [bullet()],
      sources: [source({publishedOn: '2026-09-29', url: 'https://example.com/2026/report'})],
    }],
  ));
});

test('the built files hold 38 diseases and 20 eligible guidance entries', () => {
  const diseases = JSON.parse(fs.readFileSync(path.join(appData, 'notifiable_diseases.json'), 'utf8'));
  const guidance = JSON.parse(fs.readFileSync(path.join(appData, 'public_health_guidance.json'), 'utf8'));
  assert.equal(diseases.length, 38);
  assert.equal(guidance.length, 20);
  const byId = new Map(diseases.map((d) => [d.diseaseId, d]));
  assert.equal(byId.size, 38);
  const catalogue = new Set(
    JSON.parse(fs.readFileSync(path.join(appData, 'lab_tests.json'), 'utf8')).map((t) => t.labTestId),
  );
  for (const entry of guidance) {
    const diseaseRow = byId.get(entry.diseaseId);
    assert.ok(diseaseRow, `${entry.diseaseId} has no disease row`);
    assert.ok(diseaseRow.publicAlertEligible, `${entry.diseaseId} is not eligible`);
  }
  for (const row of diseases) {
    for (const testRow of row.labTests) {
      assert.ok(catalogue.has(testRow.labTestId), `${testRow.labTestId} is not catalogued`);
    }
  }
  assert.doesNotThrow(() => scanProse(diseases, guidance));
});

test('rebuilding is byte-identical', () => {
  const files = ['notifiable_diseases.json', 'public_health_guidance.json'].map((name) => [
    path.join(appData, name),
    path.join(root, 'functions', 'data', name),
  ]).flat();
  const before = files.map((file) => fs.readFileSync(file));
  main();
  for (const [index, file] of files.entries()) {
    assert.ok(fs.readFileSync(file).equals(before[index]), `${file} changed on rebuild`);
  }
});

test('no source links to social media; every source is a published document', () => {
  const guidance = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'assets', 'data', 'public_health_guidance.json'), 'utf8'));
  for (const entry of guidance) {
    for (const source of entry.sources) {
      assert.match(source.url, /^https:\/\//, `${source.sourceId} must be https`);
      assert.doesNotMatch(source.url, /facebook\.com|twitter\.com|x\.com\/|instagram\.com/, `${source.sourceId} links to social media`);
    }
  }
});

