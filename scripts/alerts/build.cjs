// Builds notifiable_diseases.json + public_health_guidance.json from the
// reviewed source tables in this directory (make alerts-data). Every rule
// the bundle states is enforced here, loudly: a broken source fails the
// build naming the entry, never ships a half-true asset.
//
// Primary-source-only: a bullet may list corroborating sources in
// alsoCites (checked to exist), but only its primary sourceId ships, so
// every built line traces to exactly one checked source. Sources nothing
// shipped cites leave with the bullets that cited them.

const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..', '..');
const sources = path.join(__dirname);
const appData = path.join(root, 'assets', 'data');
const functionsData = path.join(root, 'functions', 'data');

const IHR = ['AlwaysNotifiable', 'AlwaysAssessed', 'EventAssessed', 'None'];
const CATEGORIES = ['Immediate', 'Weekly', 'Monthly', 'NotListed'];
const GROUPS = ['EpidemicProne', 'Elimination', 'PublicHealthImportance', 'NotListed'];
const STRENGTHS = ['Confirms', 'Presumptive', 'Supportive', 'Uncertain'];

// The statutory reminder, word for word from plan §1.4. Only the two
// categories with guidance entries exist here; anything else fails closed.
// cspell:disable -- the plan's English and Kiswahili statutory wording.
const STATUTORY = {
  Immediate: {
    en: 'Report a suspected or confirmed case to the medical officer of health: immediately for this disease, on form MOH 502',
    sw: 'Ripoti kesi inayoshukiwa au iliyothibitishwa kwa afisa wa afya: mara moja kwa ugonjwa huu, kwa fomu MOH 502',
  },
  Weekly: {
    en: 'Report a suspected or confirmed case to the medical officer of health: weekly, on MOH 505',
    sw: 'Ripoti kesi inayoshukiwa au iliyothibitishwa kwa afisa wa afya: kila wiki, kwa fomu MOH 505',
  },
};
// cspell:enable

const fail = (entry, message) => {
  throw new Error(`alerts-data: ${entry}: ${message}`);
};

const readJson = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));

const nonEmpty = (value, entry, field) => {
  if (typeof value !== 'string' || value.length === 0) {
    fail(entry, `expected a non-empty ${field}`);
  }
};

const oneOf = (value, allowed, entry, field) => {
  if (!allowed.includes(value)) {
    fail(entry, `expected ${field} to be one of ${allowed.join(', ')}, got ${JSON.stringify(value)}`);
  }
};

// Every test name resolves to exactly one catalogue row. The names in the
// source table are the catalogue's own `name` values, matched exactly.
const resolveLabTests = (diseases, catalogue) => diseases.map((disease) => {
  const tests = disease.labTests.map((test) => {
    nonEmpty(test.name, disease.diseaseId, 'lab test name');
    oneOf(test.strength, STRENGTHS, disease.diseaseId, 'strength');
    if (typeof test.mappingVerified !== 'boolean') {
      fail(disease.diseaseId, `expected mappingVerified on "${test.name}"`);
    }
    const matches = catalogue.filter((row) => row.name === test.name);
    if (matches.length === 0) {
      fail(disease.diseaseId, `lab test "${test.name}" matches no catalogue row`);
    }
    if (matches.length > 1) {
      fail(disease.diseaseId, `lab test "${test.name}" matches ${matches.length} catalogue rows`);
    }
    return {
      labTestId: matches[0].labTestId,
      name: test.name,
      strength: test.strength,
      mappingVerified: test.mappingVerified,
    };
  });
  return {...disease, labTests: tests};
});

const checkDisease = (disease, seen) => {
  const id = disease.diseaseId;
  nonEmpty(id, id, 'diseaseId');
  if (seen.has(id)) fail(id, 'duplicate diseaseId');
  seen.add(id);
  nonEmpty(disease.nameEn, id, 'nameEn');
  nonEmpty(disease.nameSw, id, 'nameSw');
  oneOf(disease.ihrStatus, IHR, id, 'ihrStatus');
  oneOf(disease.reportingCategory, CATEGORIES, id, 'reportingCategory');
  oneOf(disease.kenyaGroup, GROUPS, id, 'kenyaGroup');
  if (disease.categoryVerified !== false) {
    fail(id, 'categoryVerified must be false until the category check lands');
  }
  if (!Array.isArray(disease.labTests)) fail(id, 'labTests must be an array');
  if (!Array.isArray(disease.sourceIds)) fail(id, 'sourceIds must be an array');
  for (const sourceId of disease.sourceIds) {
    if (!/^(S\d+|W)$/.test(sourceId)) fail(id, `bad sourceId ${JSON.stringify(sourceId)}`);
  }
  if (typeof disease.publicAlertEligible !== 'boolean') fail(id, 'publicAlertEligible must be a boolean');
  if (typeof disease.allowManualAlert !== 'boolean') fail(id, 'allowManualAlert must be a boolean');
};

// Flagged bullets stay in the working source only; their sources leave with
// them when nothing shipped cites them. Case-definition bullets must match
// the disease row exactly: one truth, checked.
const buildGuidance = (guidance, diseasesById) => guidance.map((entry) => {
  const id = entry.diseaseId;
  nonEmpty(id, id, 'diseaseId');
  const disease = diseasesById.get(id);
  if (!disease) fail(id, 'has guidance but no disease row');
  if (!disease.publicAlertEligible) fail(id, 'has guidance but is not alert-eligible');
  nonEmpty(entry.reviewedOn, id, 'reviewedOn');
  if (!Array.isArray(entry.bullets)) fail(id, 'bullets must be an array');
  if (!Array.isArray(entry.sources)) fail(id, 'sources must be an array');
  const sourcesById = new Map(entry.sources.map((s) => [s.sourceId, s]));
  for (const source of entry.sources) {
    nonEmpty(source.sourceId, id, 'sourceId');
    nonEmpty(source.title, id, `title of ${source.sourceId}`);
    nonEmpty(source.publisher, id, `publisher of ${source.sourceId}`);
    nonEmpty(source.url, id, `url of ${source.sourceId}`);
    if (!source.url.startsWith('https://')) fail(id, `url of ${source.sourceId} must be https`);
    if (source.publishedOn.length === 0 && source.accessedOn.length === 0) {
      fail(id, `${source.sourceId} needs a date`);
    }
  }
  const seenBullets = new Set();
  const shipped = [];
  for (const bullet of entry.bullets) {
    nonEmpty(bullet.bulletId, id, 'bulletId');
    if (seenBullets.has(bullet.bulletId)) fail(id, `duplicate ${bullet.bulletId}`);
    seenBullets.add(bullet.bulletId);
    oneOf(bullet.audience, ['Patient', 'Clinician'], id, `audience of ${bullet.bulletId}`);
    nonEmpty(bullet.textEn, id, `textEn of ${bullet.bulletId}`);
    nonEmpty(bullet.textSw, id, `textSw of ${bullet.bulletId}`);
    if (bullet.swIsOfficial !== false) fail(id, `${bullet.bulletId} swIsOfficial must be false: every Swahili line here is mine`);
    if (!sourcesById.has(bullet.sourceId)) fail(id, `${bullet.bulletId} cites missing ${bullet.sourceId}`);
    for (const extra of bullet.alsoCites ?? []) {
      if (!sourcesById.has(extra)) fail(id, `${bullet.bulletId} alsoCites missing ${extra}`);
    }
    if (bullet.sourceCheck !== undefined && bullet.sourceCheck !== 'Ocr') {
      fail(id, `${bullet.bulletId} has an unknown sourceCheck`);
    }
    if (bullet.sourceCheck === 'Ocr') continue;
    const {sourceCheck: _dropped, alsoCites: _alsoDropped, ...clean} = bullet;
    shipped.push(clean);
  }
  checkClinicianBullets(id, shipped, disease);
  const cited = new Set(shipped.map((b) => b.sourceId));
  return {
    diseaseId: id,
    reviewedOn: entry.reviewedOn,
    bullets: shipped,
    sources: entry.sources.filter((s) => cited.has(s.sourceId)),
  };
});

const checkClinicianBullets = (id, shipped, disease) => {
  const clinician = shipped.filter((b) => b.audience === 'Clinician');
  const statutory = STATUTORY[disease.reportingCategory];
  if (!statutory) fail(id, `no statutory wording for ${disease.reportingCategory}`);
  const line = clinician.find((b) => b.textEn === statutory.en);
  if (!line) fail(id, 'is missing its statutory reminder line');
  if (line.textSw !== statutory.sw) fail(id, 'statutory reminder Swahili does not match');
  const rest = clinician.filter((b) => b !== line);
  if (disease.caseDefinitionEn.length === 0) {
    if (rest.length > 0) fail(id, 'has a case-definition bullet but no case definition');
    return;
  }
  if (rest.length !== 1) fail(id, `expected one case-definition bullet, found ${rest.length}`);
  if (rest[0].textEn !== disease.caseDefinitionEn || rest[0].textSw !== disease.caseDefinitionSw) {
    fail(id, 'case-definition bullet drifted from the disease row');
  }
};

// The Ebola-2026 quarantine, over prose only: dates and urls carry years
// legitimately, but no sentence may mention 2026 or an imported case.
const scanProse = (diseases, guidance) => {
  const fieldsOf = (row, fields) => fields.map((field) => [field, row[field]]);
  for (const disease of diseases) {
    for (const [field, text] of fieldsOf(disease, ['nameEn', 'nameSw', 'caseDefinitionEn', 'caseDefinitionSw'])) {
      checkText(disease.diseaseId, field, text);
    }
  }
  for (const entry of guidance) {
    for (const bullet of entry.bullets) {
      checkText(entry.diseaseId, `${bullet.bulletId}.textEn`, bullet.textEn);
      checkText(entry.diseaseId, `${bullet.bulletId}.textSw`, bullet.textSw);
    }
    for (const source of entry.sources) {
      checkText(entry.diseaseId, `${source.sourceId}.title`, source.title);
    }
  }
};

const checkText = (id, field, text) => {
  if (/\b2026\b/.test(text)) fail(id, `${field} mentions 2026`);
  if (/imported/i.test(text)) fail(id, `${field} mentions an imported case`);
};

const main = () => {
  const catalogue = readJson(path.join(appData, 'lab_tests.json'));
  const diseases = readJson(path.join(sources, 'diseases.source.json'));
  const guidance = readJson(path.join(sources, 'guidance.source.json'));
  if (!Array.isArray(catalogue)) fail('lab_tests.json', 'expected an array');
  if (!Array.isArray(diseases)) fail('diseases.source.json', 'expected an array');
  if (!Array.isArray(guidance)) fail('guidance.source.json', 'expected an array');
  const seen = new Set();
  for (const disease of diseases) checkDisease(disease, seen);
  const builtDiseases = resolveLabTests(diseases, catalogue);
  const diseasesById = new Map(builtDiseases.map((d) => [d.diseaseId, d]));
  const builtGuidance = buildGuidance(guidance, diseasesById);
  scanProse(builtDiseases, builtGuidance);
  for (const [name, rows] of [['notifiable_diseases.json', builtDiseases], ['public_health_guidance.json', builtGuidance]]) {
    const bytes = `${JSON.stringify(rows, null, 2)}\n`;
    fs.writeFileSync(path.join(appData, name), bytes);
    fs.writeFileSync(path.join(functionsData, name), bytes);
  }
  console.log(`alerts-data: ${builtDiseases.length} diseases, ${builtGuidance.length} guidance entries.`);
};

if (require.main === module) main();

module.exports = {resolveLabTests, buildGuidance, scanProse, STATUTORY, main};
