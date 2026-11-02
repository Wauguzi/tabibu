<!-- cspell:ignore Siaya Serotyping -->
# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0049 |
| Title | Outbreak alerts |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: f1106c9, a5bf9ba, c755bde, fe013dd, 155630b, af2b1d8, d05d289, 0c3dfe8 |

## 1. Description of change

The data the outbreak detector runs on, the guidance its alerts carry,
and the engine itself. This change lands the disease bundle, the
sources, the reads and the rules, and the detector, drafting, approval
and delivery functions that enforce them.

1. **`notifiable_diseases.json`** (a5bf9ba): 38 diseases in plan §1.4
   order with IHR status, reporting category, Kenya group, the S1
   case definition, 115 lab mappings at four strengths, alert
   eligibility (21), manual-alert eligibility (20; not malaria) and
   the `MalariaParasites` pre-read hint. `categoryVerified` is false
   on every row until the second-source check lands.
2. **`public_health_guidance.json`** (a5bf9ba): 20 guidance entries
   (no confirming test exists for smallpox, so no report can raise it), each with patient
   bullets, the case definition plus the statutory reminder for
   clinicians, and sources with a url, a publisher and a date.
   Ebola ships its S15 bullets only; every OCR-sourced bullet stays
   in the working source flagged `Ocr` (§9). All Kiswahili is ours
   (`swIsOfficial: false`); nothing claims a Ministry translation.
3. **Sources** (c755bde): public alerts by county and demo flag,
   clinician briefs by id, the county/language topic service with a
   demo variant (CRQ-0048).
4. **Rules** (fe013dd): public alerts to the county and release,
   briefs to clinicians, receipts and approver records by role;
   RT-172..185/186.
5. **Shared core** (155630b): the bundled disease names for push
   (S-3), the push exception naming disease and county only, and the
   notification writer the delivery will use (CRQ-0046).
6. **Specified with it** (af2b1d8): notifiable findings and
   confirmatory requests, suspicion events, the Rule A/B/M detector
   over delta windows with the §3.8 quarantine (T-19), grounded
   drafting with cited sentences (T-20), approval by an authorised
   public-health officer, two-phase delivery, `updatePatientArea`
   and `setAlertApprover`. Threat model T-19/T-20 dated.
7. **The engine** (d05d289), as specified:
   - **Events:** `signReport` writes the anonymous, allow-listed
     notifiable events in its own transaction. A new finding creates an
     event and a link, a kept one moves its link to the new version,
     and a dropped one retracts both.
   - **Detector:** `onNotifiableEventWritten` counts each edge once and
     applies Rules A, B and M to weekly counts, then reconciles the
     signal and the alert. Eligibility is Q-23's: only epidemic-prone
     diseases can raise an alert, and HIV, STIs, hepatitis B and C, TB
     and leprosy are counted, never broadcast. A count that falls back
     to zero withdraws a draft.
   - **Drafts:** the draft is the model's, or the template when the
     model is off, fails or writes off-schema, so an approver always
     gets one. An authorised public-health officer (MoH or county
     health department) approves it in one tap, edits it, or rejects
     it, and `requestAlertDraft` redrafts up to three rounds. Nobody
     approves an alert raised from their own finding.
   - **Delivery:** the county's clinicians first, then, after the
     patient delay, one topic push per language and the `publicAlerts`
     read model for patients. A lease serialises runners, and keyed
     rows and once-only topic claims make every send at-most-once.
     The kill switch fails closed to `Held`. Delivery reaches the alert
     county only until adjacency is sourced (§9).
   - **Sweep and signals:** the alert sweep runs on `sweepCases`'
     schedule (reminder, expiry, a stuck draft turned into the
     template draft, delivery resumes, a held-too-long page);
     `aggregateModelSignals` is CRQ-0047's.
   - **Accounts:** `setAlertApprover` grants the permission on an admin
     account, `updatePatientArea` moves a patient's county, and the
     seed moves the approver role to the admin account and seeds the
     demo accounts synthetic alerts reach.
   - **No AI client is wired**, so every draft is the template until
     the service exists. An in-app alert never replaces the facility's
     statutory report.

The scope default (Q-23): county-level scope for Rule A unless the
Kenya clinical advisor names counted cross-border detector scope —
in which case the clinical build's counties make the rules, and
these data records say the same.

## 2. Business justification

An outbreak alert is the one message Tabibu sends unasked, so every
sentence in it must trace to a source the reviewer has read. The
bundle fixes the diseases, the confirming tests and the guidance
before the detector exists, with the reviewer's source check as the
gate after it.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the approval queue and alert screens (the
blocs branch); the alert attribution line, which is app copy on the UI
branch; the AI service that drafts (`feat/ai-service`); the
county-adjacency source (still unsourced, §12 U-12); the OCR PDF check
(step 1l).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Alert, brief, receipt and working-record shapes; Hive 46-51 |
| Roles & case scoping | **Affected** | Public alerts to the county; briefs and approvals by role |
| Clinical safety | **Affected** | Guidance text authored; S-8 names clinician transcripts to clinicians |
| AI service (prompts, models, thresholds) | None | The drafting seam is called with disease and county names and guidance only; no client or prompt is added, so drafts are the template |
| Security (rules, App Check, RASP, secrets) | **Affected** | Approver records approver-only; T-19/T-20 controls built |
| Data protection (PHI, de-identification, model endpoints) | **Affected** | Alerts carry disease and county only; drafts never cached (F-39) |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | **Affected** | Every name, definition and bullet in both; ours, labelled so |
| Existing data | None | No live alert path changed |

## 5. Risk & rollback plan

**Risk level:** High: this is the one message Tabibu sends unasked.
Delivery fails closed to `Held`, an approver decides every alert, and
no screen calls the callables yet.

**Rollback plan:** turn `alerts_delivery_enabled` off on both templates,
server first, so every alert is `Held`; then revert the commits. Deploy
order: indexes → smoke → functions → backfill → Firestore rules →
Storage rules → server Remote Config → app (§8 5e).

## 6. Implementation plan

1. Alert and reference models, the draft shapes with no Hive mirror.
2. The two assets built from reviewed source tables
   (`make alerts-data`), with byte-identical functions copies and
   the quarantine test.
3. Sources, rules with a test per reader, then the threat-model
   rows.
4. The engine on the shared core: events, then the detector, drafting
   and decisions, delivery and the sweep, each proved on the emulator,
   with the model seam faked.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01, including the alert assets (4) |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), including byte-identical over both assets and the events, detector, drafting, decisions, delivery and sweep |
| Rules tests | Pass — RT-172..185/186 within RT-45..RT-200 |
| Release check | Pass — the quarantine and idempotence tests run under `make release-check` |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no screen calls the callables yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-11-02 | Approved — [PR #8](https://github.com/Wauguzi/tabibu/pull/8), 5/5 at round 3 |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Pending | — | §13 clinical pass after the demo build |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Approver-only working records; T-19/T-20 controls built |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Disease and county only; drafts uncached |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **OCR-held bullets** (step 1l): Ebola's airborne, report-the-unwell
  and 719-line bullets, all five cholera bullets and the malaria
  spraying bullet stay flagged until checked against the PDFs. Ebola
  ships its S15 bullets only; the 2026 case facts, Orders and the
  hotline stay out of both files.
- **U-14 reconciliation**: two URLs arrived in §1 as read-only scans.
  They were read as stated, and after 1c neither the build nor any
  record treats them as citable, quotes them, or links them; the QR
  scan and "supported by" line were not saved. Reopen only by
  re-reading them as citable sources with the reviewer's agreement.
- **U-12**: county adjacency is still unsourced, so clinicians in
  the alert county only.
- **U-16 (Ebola CFR)**: the number is saved nowhere and quoted
  nowhere; the S-2 form is the record of what the approver weighs.
- **§13 clinical pass**: the names, definitions and bullets — ours
  in both languages — are read by a clinician after the demo build;
  the detector never runs before its source check.
- **Q-23 demo rule**: non-demo accounts see nothing synthetic, so a
  synthetic drill cannot leak through a mis-set flag; the demo build
  clears the flag on every sign-in.
- **Review findings fixed** (three adversarial reviews, d05d289):
  delivery dropped `templateArgs` from the rows it wrote (they now
  carry the disease and county ids); an evidence write that changed
  nothing rewrote the alert, and a no-op redelivery now never blocks a
  one-tap approve; `epiCounts` drifted from the events; the topic
  claim was read wrongly, so only a `{id, at}` claim now counts and
  anything else reads as absent; and an alert could be released at
  zero evidence, which approval now refuses with `noEvidence`.
- **Accepted deviation: county-only delivery.** Clinicians in the
  alert county only, until county adjacency is sourced (U-12).
- **alsoCites is review trail, not shipped citations.** A bullet may list
  corroborating sources in `alsoCites` (the build checks they exist), but
  only the primary `sourceId` ships, so every built line traces to exactly
  one checked source. The RVF patient bullet's WHO sheet
  (`who-rvf-2024-12-20`) stays out on that rule: the nets-and-repellent
  advice is already carried by its primary MoH source (S17).
- **Accepted deviation: the attribution line.** The line that tells a
  reader who approved an alert is app copy, to come on the UI branch.
- **Accepted deviation: zero-evidence redraft.** A redraft from
  `Withdrawn` cannot release to patients on zero evidence: approval is
  refused with `noEvidence`, which fails closed.
- **Follow-ups**: the AI service client, so drafts stop being the
  template; county adjacency; an index for a notes-AI `Running` sweep
  (CRQ-0041 §9).
- **Source links corrected before commit.** The first build of the
  guidance carried social-media links for the Ministry's sources; every
  Ministry and county source now points at its published document
  (Appendix A), and the build test fails on any social-media link.

## 10. Related records

- Reference models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Approver queue uncached: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Push: [CRQ-0046](./CRQ-0046-notification-model-v2-and-push.md)
- Sources: [CRQ-0048](./CRQ-0048-feature-data-sources-and-indexes.md)

## Appendix A. Sources

Titles, publishers and dates below are §1's, read on 2026-11-01.
S22/S23 exist (KNPHI launch background; an unopened strategy plan)
but nothing cites them.

| Id | Document | Publisher | Date | Read as |
|---|---|---|---|---|
| S1 | Clinician's Handbook for IDSR Priority Diseases (reporting requirements, standard and lay case definitions, MOH 502/503/504/505) | MoH Disease Surveillance and Response Unit, now hosted by KNPHI | Undated, 2nd-edition era (describes the 2012 revision); uploaded 2024-02 | Full text (archived copy; the live host's TLS expired) |
| S4 | Kenya IDSR priority list, 3rd edition | MoH Kenya | 2021 | Full text |
| S5 | Public Health Act Cap. 242 | Kenya Law | current | Full text |
| S6 | IHR (2005), consolidated text as amended 2014/2022/2024 | WHO | Amendments in force 19 Sept 2025 | Full text |
| S7 | Resolution WHA77.17 with the IHR amendments | World Health Assembly | 1 June 2024 | Full text |
| S8 | Circular C.L.34.2025 on the IHR amendments in force | WHO Director-General | 17 Nov 2025 | Full text (a public registry copy) |
| S9 | IHR Annex 2, right box | UK Government and Bahrain MoH copies | Current pages | Search extracts |
| S10 | R&D Blueprint priority-disease list | WHO | 2018, COVID-19 added 2020 | Read |
| S11 | Pathogens prioritization framework | WHO R&D Blueprint | 30 July 2024 | Listing page only; full list not opened |
| S12 | MoH press release, 2026-10-06 (held, not cited) | MoH Kenya, Cabinet Secretary | 2026-10-06 | OCR scan — held |
| S13 | MoH press release, 2026-10-14 (held, not cited) | MoH Kenya, Director General for Health | 2026-10-14 | OCR scan — held |
| S14 | EVD preparedness status in Kenya (press statement) | MoH Kenya, Cabinet Secretary | 2026-05-19 | OCR scan — held |
| S15 | EVD outbreak in Ituri Province, DRC: public health advisory | MoH Kenya, Director General | 2026-05-18 | Full text |
| S16 | Cholera outbreak in parts of the country (press statement) | MoH Kenya, Cabinet Secretary | 2025-04-08 | OCR scan — held |
| S17 | Advisory on health risks amid heavy rains (press release) | MoH Kenya, PS for Public Health | 2023-11-22 | Full text |
| S18 | Mpox key messages (social posts) | MoH Kenya | 2024 (posted 21 Jan 2025) | Full text |
| S19 | Mpox response and Marburg preparedness (press statement) | MoH Kenya, PS | 2024-10-31 | Full text |
| S20 | Indoor residual spraying and chemoprevention (press statement) | MoH Kenya, PS | 2025-03-08 | OCR scan — held |
| S21 | Siaya anthrax advisory (news relay of a joint county statement) | The Star (Kenya) | 2026-04-17 | Full text |
| W | WHO fact sheets (16 read: Marburg, Lassa, CCHF, RVF, yellow fever, dengue, chikungunya, plague, typhoid, diarrhoeal, meningitis, malaria, measles, polio, COVID-19, avian flu; 15 ship — RVF corroborates via alsoCites, see §9) | WHO | per sheet 2023–2026 | Full text |

The disease rows keep the §3 table's `W` token; the guidance build
cites each WHO sheet by its own id and fetched every URL (all 200,
titles checked) before writing it in. The §1 urls for S1 and
S12–S21 are file-host links, not the press-page links the shipped
bundle carries — see the §9 follow-up.

## Appendix B. Lab-test names that needed judgement

Every mapping below was resolved against the catalogue by name and
checked back to the research id; the rest are exact catalogue names
needing no judgement.

- **Unnamed in research, resolved by id**: the first syphilis test
  (`Syphilis – Treponema pallidum test`, en dash) and the malaria
  `Rapid diagnostic test` (Parasitology).
- **Research shorthand vs catalogue**: `Bone marrow aspirate (BMA)`,
  hyphenated `Serotyping-cholera` / `Serotyping-Shigella`,
  `Blood smear for light microscopy for malaria`.
- **Mixed strengths**: TB LAM is `Confirms` with
  `mappingVerified: false` (the plan table beats the weaker-value
  rule); typhoid antigen is `Presumptive`; Marburg IgM, plague FNA
  and the SAT take the weaker value; the five `C/?` NAATs
  and ELISAs (yellow fever, meningococcal, polio, leprosy, anthrax)
  are `Confirms` with `mappingVerified: false`.
- **Left out**: the cholera water analysis (environmental), the
  cryptococcal culture under meningococcal (not this disease), the
  four §3.2 NCD tests (never mapped), and smallpox (the Mpox NAATs
  note is variola-negative, so no tests).
- **Ungraded in research, all `Confirms` per the plan table**: the
  13 hepatitis and 9 STI tests.
