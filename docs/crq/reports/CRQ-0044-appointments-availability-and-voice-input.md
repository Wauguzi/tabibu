# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0044 |
| Title | Appointments, availability and symptom voice input |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-01 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 718da1f, c000a7e, c755bde, fe013dd, 155630b, af2b1d8 |

## 1. Description of change

Booking, the doctor's week, and the patient's spoken symptoms. The
booking and transcription callables are planned; this change lands the
shapes, reads, rules and counters they will enforce.

1. **Models** (718da1f): appointments with intake and bilingual
   drafts, `inputMode` and the detected language on the appointment.
2. **Availability** (c000a7e): working days and minutes plus
   `busySlots` on the doctor and practitioner, parsed with defaults
   and migrated in the F-11 order (functions, then
   `backfillAvailability`, then rules), hours validated only when
   changed (RT-131).
3. **Sources and rules** (c755bde, fe013dd): delta queries scoped to
   the patient or the doctor; the intake doctor-only; slot booking
   and sibling auto-declines specified as transactions (F-3).
4. **Quotas and writers** (155630b): counting on the edge (T-7 gains
   the transcription quota); T-16 writers extended
   (`respondToAppointment` accept among them).
5. **Voice input (Trust 5)**: `speechAudio/` holds the patient's
   dictation for `transcribeSymptoms`, which discards it after
   transcription; the patient confirms the text. Speech goes to the
   transcription model only (S-8): the one exception to
   de-identified input.

## 2. Business justification

Booking is the front door, and typing symptoms excludes the patients
least able to type. The availability model stops double-booking, and
the voice path keeps the audio off every record except the confirmed
text.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the booking callables, `transcribeSymptoms`
and the intake summary job (planned; `feat/ai-service` for the model
side).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Appointment and intake shapes; availability fields (CRQ-0039) |
| Roles & case scoping | **Affected** | Patient/doctor deltas; doctor-only intake |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | Jobs planned in the next branch |
| Security (rules, App Check, RASP, secrets) | Affected | Scoped reads; transcription quotas (T-7) |
| Data protection (PHI, de-identification, model endpoints) | Affected | Symptom audio discarded after transcription (S-8) |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | Affected | Bilingual intake drafts |
| Existing data | Affected | Availability backfilled by `backfillAvailability` before the rules land |

## 5. Risk & rollback plan

**Risk level:** Low: shapes and reads; the booking writes do not exist
yet.

**Rollback plan:** revert the commits. The backfill is additive and
idempotent.

## 6. Implementation plan

1. Models and availability migration first.
2. Sources and rules with scoped-read tests.
3. The voice path specified end to end (upload, transcribe-and-discard,
   confirm) ahead of the callable.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pending — reviewer's full run |
| Rules tests | Pass — RT-131 (availability) within RT-45..RT-200 |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no UI yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Scoped reads; quotas |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Audio discarded; intake role-gated |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **U-7 (speech latency)**: measure p95 against the dev AI endpoint
  during the callable build; the fallback is the asynchronous
  pattern (the service writes back, a small trigger fills the
  templates).
- **Doctor-notes dictation** (Q-15) stays a later item (§13).
- **F-20**: profiles keep display names; county ids derive at the
  edge, with `unknownCounty` and an audit in `backfillAvailability`.

## 10. Related records

- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Cache helpers: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Orchestrator: [CRQ-0041](./CRQ-0041-case-orchestrator-orders-and-payment.md)
