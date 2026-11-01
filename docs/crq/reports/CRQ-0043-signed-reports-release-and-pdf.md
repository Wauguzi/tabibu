# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0043 |
| Title | Signed reports, release, approvals and the PDF |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-01 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 718da1f, c6dfc8e, fe013dd, af2b1d8 |

## 1. Description of change

The report half of the data layer: who may read an AI draft, who may
read a signed report, and what the PDF carries. The signing and
approval callables are planned; this change lands the shapes, reads
and rules they will enforce.

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
4. **Approvals and PDF (shapes)**: template-driven sections with
   ordered responses; the signer snapshot; one-tap approve-as-is with
   `acceptedUnchanged` recorded; the PDF input, which refuses drafts,
   superseded and unreleased-for-patient versions, non-readers and
   untied translations, and carries the patient's name, age, sex and
   residence for the builder to localise (Theo (a)). No verify QR
   (Theo (b)); MDT never gets a PDF. The PDF look stays Tabibu's own,
   with a mock-up step before the builder (Theo (c)).
5. **Docs** (af2b1d8): the AI service records the approved
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

**Explicitly out of scope:** the signing, approval and release
callables, the PDF builder and its mock-up, and the AI-service jobs
(`feat/ai-service`, F-43).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Report, draft, approved-text and worklist shapes; Hive 16-26 and 52 |
| Roles & case scoping | **Affected** | Draft by pathologist, signed by readers, patient by release |
| Clinical safety | None | Shapes and gates only; no wording authored, no result path changed |
| AI service (prompts, models, thresholds) | None | Jobs planned in the next branch; prompts untouched |
| Security (rules, App Check, RASP, secrets) | **Affected** | S-1/S-2/S-3 reader rules with tests per reader |
| Data protection (PHI, de-identification, model endpoints) | **Affected** | Working text never cached; approved text by id to readers |
| Design system / UI consistency | Affected | Docs only: draft/approved telling-apart, approval screen |
| Localisation (en, sw) | None | No new user-visible strings in code |
| Existing data | None | No live report path changed |

## 5. Risk & rollback plan

**Risk level:** Medium: reader rules change what live clients may do,
once deployed with the app.

**Rollback plan:** redeploy the previous rules from `main`, then
revert the commits. Deploy order stays indexes → functions →
backfill → rules → app (§8 5e).

## 6. Implementation plan

1. Models with the no-mirror rule proven per AI shape.
2. Sources refusing forbidden draft fields, then rules with a test
   per reader.
3. The PDF input as a pure gate, independent of the builder.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pending — reviewer's full run |
| Rules tests | Pass — RT-104..113, RT-116, RT-191 (draft, readers, release, by-id, absent) within RT-45..RT-200 |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no UI yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | Shapes and gates only |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Reader rules with tests per reader |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Drafts uncached; approved text to readers only |
| Lead Designer | §4 flags design-system impact | N/A | — | Docs only, no built UI |

## 9. Post-implementation review

- **The §13 clinical pass** covers the report templates after the
  demo build; it does not gate them.
- **The AI jobs land in `feat/ai-service`** with EVAL reports; until
  then the functions tests inject `FakeAiClient` (F-43).
- **`discardDraft` and `draftInProgress`** (F-2) are specified with
  the signing callable; the sources already carry the stamp.

## 10. Related records

- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Cache release gate: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Sources and indexes: [CRQ-0048](./CRQ-0048-feature-data-sources-and-indexes.md)
