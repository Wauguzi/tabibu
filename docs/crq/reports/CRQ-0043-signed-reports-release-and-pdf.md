# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0043 |
| Title | Signed reports, release, approvals and the PDF |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 718da1f, c6dfc8e, fe013dd, af2b1d8, 27d174b, d05d289 |

## 1. Description of change

The report half of the data layer: who may read an AI draft, who may
read a signed report, how a report is signed and released, and what the
PDF carries. This change lands the shapes, reads and rules, the signing
and approval callables that enforce them, and the PDF builder.

1. **The approved-text split** (F-1): the working `reportTexts`
   (machine text, models, signals) is approver-only with no Hive
   mirror; `reportTextsApproved` (approved text only) is the only
   shape readers get or cache, read by id only. Provenance stays
   signer and admin only.
2. **Reads** (c6dfc8e): signed reports by `readerUids`, a patient's by
   release, a server-source read for the PDF; the draft update refuses
   any field the rules forbid rather than dropping it, and `signReport`
   carries the draft's stamp, refusing `draftChanged` (F-2).
3. **Rules** (fe013dd): an unsigned AI draft only by the case's
   pathologist (S-1), a signed report only by its readers (S-2), a
   patient only once released (S-3); approved texts by id (RT-112);
   a missing text reads as absent, never "none" (F-18, RT-191).
   RT-104..113, RT-116.
4. **Approvals and PDF shapes**: template-driven sections with
   ordered responses; the signer snapshot; one-tap approve-as-is with
   `acceptedUnchanged` recorded; the PDF input, which refuses drafts,
   superseded and unreleased-for-patient versions, non-readers and
   untied translations, and carries the patient's name, age, sex and
   residence for the builder to localise (Theo (a)). No verify QR
   (Theo (b)); MDT never gets a PDF.
5. **The PDF** (27d174b): `ReportPdfBuilder` renders a signed report to
   A4 in Tabibu's own layout, from the approved mock-up (Theo (c)): a
   brand bar, the logo header with the order number, the patient and
   request cards, the diagnosis panel, numbered template sections,
   measurements computed in code, addenda, an approved translation
   after the signed original, and a signed block that never splits.
   Every page carries the patient, accession number, page count and
   disclaimer. The input now carries keys, not English text: the
   builder localises section and question keys, shows age as years and
   months, formats ISO dates in Nairobi time, and names the
   translation's approver. Sections follow template order.
6. **Callables and triggers** (d05d289): `startReport` and
   `discardDraft`; `scorePreread`; `signReport`, which checks the
   draft's stamp, snapshots the signer, verifies the measurement
   preview at signing, stores the signature content-addressed,
   validates notifiable findings against the bundle, marks the prior
   version `supersededByUid` and revokes its pending unlock; and
   `markDiscussed`, the only release to a patient.
   `approveReportText` and `requestReportText` carry the translation
   and the patient explanation. Triggers move the case when a pre-read
   finishes, queue the translation of a new report, refresh a draft's
   measurement preview and follow the texts' jobs. Every AI job goes through the seam with a timeout and a
   fail-closed switch, and records `Failed` until the service exists.
7. **Docs** (af2b1d8): the AI service records the approved
   explanation, translation, the labels move to Storage `labels.json`
   (F-12) and `modelSignals`; the design system shows the AI-draft
   link and diff to the signer and admins only, wraps every
   direct-use surface in `AiDraftFrame`, and gates the patient
   explanation on the doctor marking it discussed and approved.

## 2. Business justification

The signed report is the record of care, and the AI draft must never
be mistaken for it — by a reader, a cache or the PDF. The split, the
reader lists and the release gate are what keep the two apart.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the blocs and screens that call the
callables or show the PDF, and the AI-service jobs themselves
(`feat/ai-service`, F-43): every AI path records `Failed` until the
service exists.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Report, draft, approved-text and worklist shapes; Hive 16-26 and 52 |
| Roles & case scoping | **Affected** | Draft by pathologist, signed by readers, patient by release |
| Clinical safety | **Affected** | `signReport` and `markDiscussed` are the only release; an AI draft stays with the pathologist, and the patient explanation waits for the doctor |
| AI service (prompts, models, thresholds) | None | The seam is called with de-identified input; no client, prompt or threshold is added |
| Security (rules, App Check, RASP, secrets) | **Affected** | S-1/S-2/S-3 reader rules with tests per reader |
| Data protection (PHI, de-identification, model endpoints) | **Affected** | Working text never cached; approved text by id to readers |
| Design system / UI consistency | Affected | Docs, and the PDF's layout and its en and sw copy; no screen |
| Localisation (en, sw) | Affected | The PDF's labels, in both ARB files |
| Existing data | None | No report exists before this branch |

## 5. Risk & rollback plan

**Risk level:** Medium: reader rules change what live clients may do,
once deployed with the app, and the callables now sign and release
reports, though no screen calls them yet.

**Rollback plan:** redeploy the previous rules from `main`, then
revert the commits. Deploy order stays indexes → smoke → functions →
backfill → Firestore rules → Storage rules → server Remote Config →
app (§8 5e).

## 6. Implementation plan

1. Models with the no-mirror rule proven per AI shape.
2. Sources refusing forbidden draft fields, then rules with a test
   per reader.
3. The PDF input as a pure gate, independent of the builder, then the
   builder over it, after Theo approved the mock-up.
4. The callables on the shared core, each with its refusals tested on
   the emulator.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01, including the PDF builder and its input (27d174b) |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), covering signing, release, supersession, approvals and the report triggers |
| Rules tests | Pass — RT-104..113, RT-116, RT-191 (draft, readers, release, by-id, absent) within RT-45..RT-200 |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no screen calls the callables or shows the PDF yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-11-02 | Approved — [PR #8](https://github.com/Wauguzi/tabibu/pull/8), 5/5 at round 3 |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Covered by CTO | Pending | Release only by signature then the doctor's marking; no wording authored |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Reader rules with tests per reader |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Drafts uncached; approved text to readers only |
| Lead Designer | §4 flags design-system impact | N/A | — | Docs only, no built UI |

## 9. Post-implementation review

- **The §13 clinical pass** covers the report templates after the
  demo build; it does not gate them.
- **The AI jobs land in `feat/ai-service`** with EVAL reports; until
  then no AI client is wired, every AI path records `Failed`, and the
  functions tests inject fakes (F-43).
- **`discardDraft` and `draftInProgress`** (F-2) are built with the
  signing callable (d05d289); the sources already carried the stamp.
- **Review findings fixed** (three adversarial reviews, d05d289):
  notifiable findings are validated against the bundle; a superseded
  version carries `supersededByUid`; critical priority is handled; AI
  races and timeouts are closed (a late answer is dropped); the report
  callables check the caller's role; and a stranded report unlock is
  fixed (CRQ-0042).
- **Accepted deviation**: the service's measure endpoint recomputes
  measurements from relabelled tiles, and a signature is checked
  against the preview the pathologist saw. Until the service exists, a
  relabelled report cannot be signed: signing is refused with
  `measurementFailed`. A report with no relabels signs as before.
- **Accepted deviation**: a departing pathologist's MDTs close rather
  than pass on (CRQ-0045 §9).
- **Follow-ups**: the AI service client, including the measure
  endpoint; an index for a notes-AI `Running` sweep (CRQ-0041 §9).
- **What Greptile found** ([PR #8](https://github.com/Wauguzi/tabibu/pull/8), round 1): a failed or stale
  pre-read's run id reached the draft, and the rules then demanded a
  score `scorePreread` refuses to record, so the report could not be
  written and signed by hand. `startReport` now carries a run only when
  it is `Ready` (7c3e416).

## 10. Related records

- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Cache release gate: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Sources and indexes: [CRQ-0048](./CRQ-0048-feature-data-sources-and-indexes.md)
