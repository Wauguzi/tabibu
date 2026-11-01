# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0039 |
| Title | Data-layer models and bundled reference data |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-01 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: a5e6769, d1d9be6, c7c4bb4, 8072288, 718da1f, 965d919, d0bd1e7, f1106c9, c000a7e, 622100f, af2b1d8 |

## 1. Description of change

The shapes every later bundle builds on: wire-value enums, freezed models
with Hive mirrors, the Doctor/Practitioner availability fields with their
migration, and the insurers and report-template assets with their loader.

1. **Enums** (a5e6769, d1d9be6, c7c4bb4): 52 wire-value enums for cases,
   reports, appointments, conversations and notifications, plus decline,
   cancel and report-section enums with en and sw descriptions, plus the
   alert bundle's reporting category, IHR status, Kenya group, test
   strength, guidance audience, alert rule, status, draft source and
   audience. Every `fromValue` reads an unknown or empty value as a safe
   default, so a document from a newer build never crashes an older one.
   The wire value `Case` is `patientCase` in Dart, since `case` is a
   keyword. A test resolves every value to text in en and sw.
2. **Cases and conversations** (8072288): the case (participants, stage,
   order number, lab fields), ordered tests, slides, the log, payment,
   share codes, the risk check and notes translation; conversations with
   members, the de-identified case summary, messages, previews, read
   cursors and voice-note transcripts. The case helpers never match an
   empty uid, so an unassigned pathologist cannot be mistaken for the
   caller. Hive 4-11 and 32-38, registered nested first.
3. **Reports, worklist, pre-read, appointments** (718da1f): signed
   reports, drafts, responses, addenda, measurements, pre-read scores,
   the approved report text and worklist entries; appointments with
   intake and bilingual drafts; the notifiable finding a report carries.
   The AI provenance, diff, pre-read, working text and transcription
   result have no Hive mirror, so no AI draft is cached on a device
   (S-1). The PDF input refuses drafts, superseded versions, unreleased
   versions for a patient, non-readers, and a translation not tied to
   the signed version. Hive 16-26 and 52, registered nested first.
4. **Notifications** (965d919): one server-written row per recipient,
   with typed getters, expiry and actionable checks, and a local factory
   for device-only rows. The share code never prints. Hive 40-41,
   registered nested first.
5. **Orders reference models** (d0bd1e7): the bundled catalogue's
   shapes, checked by tests that parse every row of the real assets
   (247 tests, 11 types, each test's type present).
6. **Alerts and reference models** (f1106c9): public alerts with text,
   guidance and the clinician brief, and the receipt a device keeps;
   the working alert, signal and evidence records, which hold unapproved
   draft text for approvers and have no Hive mirror. Reference models
   for notifiable diseases with their confirming tests, public-health
   guidance and report templates. Hive 46-51, registered nested first.
7. **Availability fields and migration** (c000a7e): `workingDays`,
   `dayStartMinute`, `dayEndMinute` and `busySlots` on the doctor and
   practitioner models, with defaults so documents written before them
   still parse. The Hive mirrors append the fields after `synced` with
   a `defaultValue`, so a row cached by an older build loads; a
   legacy-adapter test proves it (U-6 either way).
8. **Insurers and report templates** (622100f): `insurers.json` (SHA,
   the twelve insurers that write medical cover, and Other) and
   `report_templates.json` (Cancer for histopathology and cytology,
   Malaria for parasitology, General for the rest), each with a
   byte-identical functions copy, and the reference-data loader that
   reads lab tests, test types, insurers and templates through the
   generated asset references. Template questions are labelled in en
   and sw, with a test resolving every key in both.
9. **Docs** (af2b1d8): the architecture lists every new collection,
   Storage path, box and Hive typeId; the README walks the flow.

The insurer list's sources: the IRA's
licensed-insurers notice (Kenya Gazette, 30 April 2026), the IRA's Q4
2025 industry release for medical premium (read as a reproduction),
and SHA's own site; insurers under statutory management are left out.
The report-template mapping needed no judgement beyond the plan: the
histopathology type takes Cancer, parasitology (which holds the
malaria smear) takes Malaria, and the other nine types take General.

## 2. Business justification

Without agreed shapes, the cache, sources, rules and functions bundles
could not start. The enums' safe defaults keep older builds alive
against newer documents, and the migration rule keeps older caches
readable.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the notifiable-disease and guidance assets
(CRQ-0049); the boxes and cache helpers (CRQ-0040); the data sources
(CRQ-0048).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | New models; Hive 4-11, 16-26, 32-38, 40-41, 46-52; availability fields appended with defaults |
| Roles & case scoping | None | Shapes only; no access path changed |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | None | — |
| Data protection (PHI, de-identification, model endpoints) | None | No new store of patient data; AI drafts deliberately without a Hive mirror |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | Affected | Enum descriptions and template-question labels in both |
| Existing data | Affected | Old documents and old Hive rows still parse, by default (c000a7e) |

## 5. Risk & rollback plan

**Risk level:** Low: additive shapes with safe defaults; nothing reads
them except the new code.

**Rollback plan:** revert the commits. No migration either way: old
builds never wrote the new fields.

## 6. Implementation plan

1. Enums first, then models per domain, each with Hive mirrors and
   parsing tests over real shapes.
2. The availability migration with a legacy-adapter test before the
   rules or functions touched the fields.
3. The two assets from the reviewed sources, with functions copies and
   the loader, last.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pending — reviewer's full run. Observed in-session: the reference-data loader (6) |
| Parsing tests | Pass — every row of the real lab catalogue, insurers and templates parses (d0bd1e7, 622100f) |
| Legacy adapter | Pass — an old Hive row loads under the new mirrors (c000a7e) |
| Secrets | No secret in the branch's assets; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no behaviour change |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
| Security Analyst | §4 flags security impact | N/A | — | No security impact |
| Compliance Officer | §4 flags data protection impact | N/A | — | No data protection impact |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **U-6 closed either way**: whether or not a build holding the
  old boxes shipped, the append with `defaultValue` loads old rows.
- **U-9 (insurer sources)**: the list was built from reproductions of
  the IRA documents; the record cites the primary notice and release.
  Reopen with the primary documents before a pilot quotes them.
- **The report templates await the §13 clinical pass** after the demo
  build; it does not gate them.

## 10. Related records

- Lab catalogue: [CRQ-0033](./CRQ-0033-lab-test-catalogue.md)
- Boxes and helpers: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Data sources: [CRQ-0048](./CRQ-0048-feature-data-sources-and-indexes.md)
- Disease assets: [CRQ-0049](./CRQ-0049-outbreak-alerts.md)
