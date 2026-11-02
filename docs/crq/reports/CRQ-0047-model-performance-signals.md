# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0047 |
| Title | Model performance signals |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 155630b, af2b1d8, d05d289 |

## 1. Description of change

The counts that say whether the models earn their place
(Trust 4, §3.9): `modelSignals/{day}` holds admin-only daily
aggregates — one-tap acceptance rates for pre-reads, translations,
explanations and transcripts, latency, language mix and failure
rates — with nothing patient-identifying.

1. **Allow-list** (155630b): `MODEL_SIGNAL_FIELDS` names every
   writable field; anything else is refused, so a signal can never
   carry a uid or free text.
2. **Aggregation**: daily counts and rates only, incremented on the
   edge with the redelivery guard (D-9, F-9).
3. **The daily job** (d05d289): `aggregateModelSignals` runs at 00:10
   Nairobi time. It reads the previous Nairobi day's AI records
   (pre-reads and their scores, translations and explanations, symptom
   summaries and speech, voice notes, the risk check and notes
   translation, alert drafts and the notifiable hint) and writes
   counts, rates and latency percentiles to `modelSignals/{day}`. It
   overwrites the day, and the counters the callables bumped live keep
   their own fields. No uid and no text.
4. **Docs** (af2b1d8): the AI service records `modelSignals` and the
   approvals' `acceptedUnchanged`; §13 keeps the numbers for the
   judging narrative.

## 2. Business justification

Acceptance rates and failure rates are the only honest answer to
"does the AI help". Recording them from the first build, with no
identifiers by construction, keeps the answer available and the
patients out of it.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the admin KPI screen over the signals
(§13, later); the AI-service jobs that emit them
(`feat/ai-service`). Until the service exists, every AI path records
`Failed`.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | New admin-only aggregate collection |
| Roles & case scoping | None | Admin reads only |
| Clinical safety | None | Counts only; no AI output changed |
| AI service (prompts, models, thresholds) | None | The service's emitters land with its jobs |
| Security (rules, App Check, RASP, secrets) | None | — |
| Data protection (PHI, de-identification, model endpoints) | None | No identifier or text can be written, by allow-list |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | None | — |
| Existing data | None | New collection |

## 5. Risk & rollback plan

**Risk level:** Low: a new aggregate with no readers yet; the job
writes counts only.

**Rollback plan:** revert the commits. Rows already written are
counts without identifiers and need no cleanup.

## 6. Implementation plan

1. The allow-list and the edge increments with the shared core.
2. The daily job over the domain records, once the functions that write
   them existed.
3. The AI-service doc entries with the branch.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01 |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), covering a daily aggregate without a uid or text |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no UI |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | Counts only |
| Security Analyst | §4 flags security impact | N/A | — | No security impact |
| Compliance Officer | §4 flags data protection impact | N/A | — | No identifiers by construction |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- The admin KPI screen stays a §13 later item; the aggregates are
  shaped for it.
- **Follow-up**: the AI service client, whose jobs emit the rest of
  these signals.

## 10. Related records

- AI service: [CRQ-0043](./CRQ-0043-signed-reports-release-and-pdf.md)
- Shared core: [CRQ-0041](./CRQ-0041-case-orchestrator-orders-and-payment.md)
