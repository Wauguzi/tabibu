# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0041 |
| Title | Case orchestrator, order number, lab fields and payment |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 155630b, af2b1d8, d05d289 |

## 1. Description of change

The pipeline every case write runs through. `transition()` is the only
way a stage changes: chained calls in one transaction share a working
`CaseState`, append one log entry each, and `commitCase` writes the
case once (F-4). Participants and readers are recomputed on every
write, never merged, so a reassigned pathologist loses the case and
its pre-read (F-5). Free text is refused on a `patientVisible` log row
(F-17). Counting sits on the edge with a fact key (F-9, D-9).

Landed with it: the de-identifier (names as whole words, phones,
dates, ID and order numbers, facilities), the sanitiser, per-case
counters, the idempotency-keyed notification writer with fixed en and
sw push copy, and HMAC share-code hashing over an injected key
(recorded in CRQ-0042). The threat model records §5 payments as
recorded, never collected: Tabibu keeps the method, insurer and policy
number in a doctor-and-patient-only record and takes no money.

Built on it (d05d289), the case callables:

- `createOrder`: the order number minted from the doctor's daily
  counter on the Nairobi date, prices taken from the server's own
  catalogue, and the payment record written beside the case.
- The pathologist request and assignment: `requestPathologist`,
  `acceptCase`, `rejectCase` and `reassignPathologist`.
- Slide-name reservations and registration, and sample receipt:
  `reserveSlideUploads`, `registerSlides` and `recordSampleReceived`.
- `cancelOrder`, `completeCase` and `removeCaseViewer`.
- `onCaseWritten`, which runs the risk check and the translation of the
  doctor's notes through the AI seam: de-identified input, a timeout,
  and the kill switches failing closed. No AI client is wired until the
  AI service exists, so each run records `Failed`.
- `sweepCases` (every five minutes): it expires requests, fails stale
  AI jobs and runs the share and report sweeps (CRQ-0042, CRQ-0043).

Patient linking goes through the same core: linking an account to a
doctor-added record moves the record's cases onto it in per-case
transactions. The order-number and rate-counter collections carry TTL
(CRQ-0048).

## 2. Business justification

A case passes between a doctor, a pathologist, a lab and a patient,
and every handoff moves data one of them must not see. One pipeline,
with readers recomputed at every step, is what keeps the scoping true
while the case moves.

## 3. Scope

**In scope:** the pipeline core and the case callables (§1), the shared
writers, the payment record and its threat-model row.

**Explicitly out of scope:** the blocs and screens that call the
callables (the blocs branch), and the AI service itself: the risk
check and the notes translation record `Failed` until it exists.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Case stages, log entries and the payment record, written by the callables; clients write only the doctor's notes fields |
| Roles & case scoping | **Affected** | Readers recomputed per write; reassignment revokes |
| Clinical safety | **Affected** | The risk check and the notes translation reach the doctor directly, labelled as AI, and only through the fail-closed seam; no result path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | Affected | Share-code HMAC key injected; the emulator reads an ignored `.secret.local` |
| Data protection (PHI, de-identification, model endpoints) | Affected | The de-identifier all summaries pass through |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | Affected | Fixed push copy in both languages |
| Existing data | None | No live case path changed |

## 5. Risk & rollback plan

**Risk level:** Medium: the callables write every case, though no
screen calls them yet and the AI paths record `Failed` until the
service exists.

**Rollback plan:** revert the commits. Deploy order: indexes → smoke →
functions → backfill → Firestore rules → Storage rules → server Remote
Config → app (§8 5e).

## 6. Implementation plan

1. The pipeline and shared writers first, each proved by a chained
   test in one transaction, reading before writing.
2. The functions tests gained the Storage emulator (F-26.3).
3. Docs with the branch (af2b1d8): architecture, README flow, threat
   model §5.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01 |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), covering chained transitions, recomputed readers, de-identification fixtures, edge counters and the case callables |
| Secrets | The emulator key file is git-ignored (e00021a); `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no screen calls the callables yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Covered by CTO | Pending | Risk check and notes translation are labelled AI, key-selected advisories only |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Injected HMAC key; ignored emulator secret |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | De-identification before any summary leaves the case |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **U-3/U-4**: caps already use counter documents and the sibling
  query serialises on the doctor, so no design depends on
  transaction locking or the 500-write limit; the fake enforces it.
- **U-10 (cost)**: about twenty `onCaseWritten` invocations per case
  at pilot scale; negligible. Reopen from the billing console after a
  week of demo traffic.
- **Review findings fixed** (three adversarial reviews, d05d289): AI
  races and timeouts on the risk check and the notes translation, role
  checks on every case callable, and patient linking through the core.
  The report-side findings are in CRQ-0042 and CRQ-0043.
- **Accepted deviation**: a departing pathologist's MDTs close rather
  than pass on (CRQ-0045 §9).
- **Pre-review (44a3127)**: the Storage rule compared the full object
  name with the bare ids `reserveSlideUploads` stores, so every real
  slide upload was refused. It now checks the name's stem. Accepted
  risk: between reserving and `registerSlides`, the case's own clinician
  could store both `{id}.jpg` and `{id}.png`; one is registered and the
  reservation cleared, the other is left unreferenced. Bounded by the
  20-slide cap and an authorised writer.
- **Follow-ups**: the AI service client; an index for a sweep of notes
  translations stuck `Running` (today a stale run fails when the next
  write retriggers it, and `sweepCases` covers the pre-read and report
  texts only).

## 10. Related records

- Share codes: [CRQ-0042](./CRQ-0042-share-codes.md)
- Notifications: [CRQ-0046](./CRQ-0046-notification-model-v2-and-push.md)
- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
