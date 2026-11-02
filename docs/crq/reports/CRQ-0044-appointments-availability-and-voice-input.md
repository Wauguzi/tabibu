# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0044 |
| Title | Appointments, availability and symptom voice input |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 718da1f, c000a7e, c755bde, fe013dd, 155630b, af2b1d8, d05d289 |

## 1. Description of change

Booking, the doctor's week, and the patient's spoken symptoms. This
change lands the shapes, reads, rules and counters, and the booking and
transcription callables that enforce them.

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
6. **Callables and triggers** (d05d289): `requestAppointment`,
   `respondToAppointment`, `cancelAppointment` and
   `completeAppointment`, and `transcribeSymptoms`. Accepting reads
   `busySlots` on the doctor's document and writes it in the same
   transaction, so two accepts of one slot serialise and one succeeds,
   and the sibling requests decline. `onAppointmentWritten` builds the
   bilingual symptom summary from the de-identified text, and
   `expireAppointments` (every five minutes) expires requests, fails a
   stale summary and deletes any symptom audio left behind. Identity
   gains the availability defaults, `backfillAvailability`
   so the migration order of item 2 can run. With no AI service, `transcribeSymptoms`
   is refused as unavailable and a summary records `Failed`.

## 2. Business justification

Booking is the front door, and typing symptoms excludes the patients
least able to type. The availability model stops double-booking, and
the voice path keeps the audio off every record except the confirmed
text.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the booking screens and the voice
recording UI (the blocs and voice bundles), and the speech and summary
models themselves (`feat/ai-service`): every AI path records `Failed`
or refuses until the service exists.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Appointment and intake shapes; availability fields (CRQ-0039) |
| Roles & case scoping | **Affected** | Patient/doctor deltas; doctor-only intake |
| Clinical safety | **Affected** | The symptom summary is an AI draft shown to the doctor, labelled; it records `Failed` until the service exists. No result or alert path changed |
| AI service (prompts, models, thresholds) | None | The seam is called with de-identified text; no client or prompt is added |
| Security (rules, App Check, RASP, secrets) | Affected | Scoped reads; transcription quotas (T-7) |
| Data protection (PHI, de-identification, model endpoints) | Affected | Symptom audio discarded after transcription (S-8) |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | Affected | Bilingual intake drafts |
| Existing data | Affected | Availability backfilled by `backfillAvailability` before the rules land |

## 5. Risk & rollback plan

**Risk level:** Medium: the callables now write bookings and the
doctor's busy slots, though no screen calls them yet.

**Rollback plan:** revert the commits. The backfill is additive and
idempotent.

## 6. Implementation plan

1. Models and availability migration first.
2. Sources and rules with scoped-read tests.
3. The voice path end to end (upload, transcribe-and-discard,
   confirm), then the callables over the sources and rules.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01 |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), covering booking and slot locking, expiry, symptom-audio deletion on every path and the availability backfill |
| Rules tests | Pass — RT-131 (availability) within RT-45..RT-200 |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no screen calls the callables yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Covered by CTO | Pending | Summary is a labelled AI draft; `Failed` until the service exists |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Scoped reads; quotas |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Audio discarded; intake role-gated |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **U-7 (speech latency)**: measure p95 against the dev AI endpoint
  during the callable build; the fallback is the asynchronous
  pattern (the service writes back, a small trigger fills the
  templates).
- **Doctor-notes dictation** (Q-15) stays a later item (§13).
- **Review findings fixed** (three adversarial reviews, d05d289):
  symptom audio was kept when a transcription was refused. It is now
  deleted on every path, a refusal for the switch or the daily limit
  included, with `expireAppointments` sweeping any that remain.
- **Follow-up**: the AI service client, for the transcription and the
  summary.
- **F-20**: profiles keep display names; county ids derive at the
  edge, with `unknownCounty` and an audit in `backfillAvailability`.

## 10. Related records

- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Cache helpers: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Orchestrator: [CRQ-0041](./CRQ-0041-case-orchestrator-orders-and-payment.md)
