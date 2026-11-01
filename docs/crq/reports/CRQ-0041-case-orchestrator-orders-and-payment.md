# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0041 |
| Title | Case orchestrator, order number, lab fields and payment |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-01 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 155630b, af2b1d8 |

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

Still planned in this branch's design, not yet built: the `createOrder`
callable and assignment, slide-name reservations and the sweeps, and
the payment record's writer. The order-number and rate-counter
collections already carry TTL (CRQ-0048).

## 2. Business justification

A case passes between a doctor, a pathologist, a lab and a patient,
and every handoff moves data one of them must not see. One pipeline,
with readers recomputed at every step, is what keeps the scoping true
while the case moves.

## 3. Scope

**In scope:** the pipeline core (§1), the shared writers, the payment
record shape and its threat-model row.

**Explicitly out of scope:** `createOrder`, assignment, slide
reservations, the sweeps, and the payment writer (planned; the blocs
branch calls them).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Case stages, log entries, payment record shape; no client writes new paths yet |
| Roles & case scoping | **Affected** | Readers recomputed per write; reassignment revokes |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | Affected | Share-code HMAC key injected; the emulator reads an ignored `.secret.local` |
| Data protection (PHI, de-identification, model endpoints) | Affected | The de-identifier all summaries pass through |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | Affected | Fixed push copy in both languages |
| Existing data | None | No live case path changed |

## 5. Risk & rollback plan

**Risk level:** Low: no live caller exists yet; the pipeline runs only
in tests.

**Rollback plan:** revert the commits. Deploy order when the callers
land: indexes → functions → backfill → rules → app (§8 5e).

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
| `make test` | Pending — reviewer's full run |
| `make functions-test` | Pass — 125, observed 2026-11-01: chained transitions, recomputed readers, de-identification fixtures, edge counters |
| Secrets | The emulator key file is git-ignored (e00021a); `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no caller yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
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

## 10. Related records

- Share codes: [CRQ-0042](./CRQ-0042-share-codes.md)
- Notifications: [CRQ-0046](./CRQ-0046-notification-model-v2-and-push.md)
- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
