# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0045 |
| Title | Conversations, MDT and voice notes |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 8072288, c755bde, fe013dd, 155630b, bd353e0, af2b1d8, d05d289 |

## 1. Description of change

Case conversations and the voice notes inside them. This change lands
the shapes, reads, rules and shared writers, and the membership, share
and withdraw callables that enforce them.

1. **Models** (8072288): conversations with members and the
   de-identified case summary, messages with `kind`, duration, peaks,
   language and `transcriptStatus`, read cursors in their own
   child collection (F-24; the conversation has no client writes), and
   voice-note transcripts split into `transcript/machine` (the sender
   and clinicians) and `transcript/shared` (F-1). The message carries
   no transcript text.
2. **Sources and rules** (c755bde, fe013dd): deltas by participant,
   targeted cursor writes; every case-bearing rule pairs
   participation with a role (F-6); media rules pair a role too and
   compare attachment paths exactly (F-19, U-1); images and voice
   notes are one object per message id with an orphan sweep after
   24 h (F-22); RT-139..143, RT-159, RT-162, RT-164/165, RT-169..171,
   RT-187..190, RT-192/193.
3. **Voice notes**: stored at `conversations/{c}/voice/{m}.m4a`,
   written once, never updated or deleted by a client; 2-minute cap
   at AAC 32 kbps mono with a 512 KB Storage cap and a 20/hour,
   30 min/day quota (T-7). Playback fetches the bytes through the SDK
   (`getData`, never a download URL) into the private cache at play
   time; offline recording queues the local file.
4. **Identity safety**: the MDT summary is allow-listed, the case is
   never read for it, and the excerpt is scrubbed (T-17); the
   identifier flag runs after send on the transcript, with
   `withdrawMessage` as the sender's remedy, measured from
   `deliveredAt` (F-15). `ApproveEdited` text is sanitised and
   URL-checked (F-40).
5. **S-8** (bd353e0, ac146ae): a voice-note transcript reaches the
   conversation's clinicians directly, as a clinician's does; a
   patient reads a clinician's transcript only once the sender
   shares it (one tap, `acceptedUnchanged`).
6. **Callables, triggers and sweeps** (d05d289): `openDirectConversation`,
   `openMdt`, `inviteToMdt`, `respondToMdtInvite`, `leaveMdt`,
   `removeFromMdt`, `closeConversation`, `withdrawMessage` and
   `shareTranscript`. `onMessageCreated` takes the message quotas
   (text, and the voice-note hourly and daily limits), fans out the
   delivery or withholds the message, and queues the voice note's
   transcript, flagging one that still holds an identifier.
   A direct thread or an MDT closes when its pathologist, a viewer or
   its case leaves, and a person who leaves reads nothing more.
   `sweepConversations` (every five minutes) expires open invites,
   unblocks quotas, fails stale transcripts and deletes orphaned media
   in pages, resuming from a stored page token. With no AI service a
   transcript records `Failed`; the voice note itself is delivered.

## 2. Business justification

The MDT must discuss a case it cannot open, and a voice note must
reach the thread even offline. The split transcripts, the
post-send flag and the sender's withdraw keep identity and consent
attached to every word.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the thread, MDT and voice-note screens
and the voice recording UI (the blocs and voice bundles), and the
transcription model itself (`feat/ai-service`): every transcript
records `Failed` until the service exists.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Conversation, message, cursor and transcript shapes; Hive 32-38 |
| Roles & case scoping | **Affected** | Participation plus role on every read; transcripts split by reader |
| Clinical safety | **Affected** | A voice-note transcript is an AI draft that reaches clinicians directly, labelled AI (S-8); it records `Failed` until the service exists. No result or alert path changed |
| AI service (prompts, models, thresholds) | None | The seam is called with the voice note; no client or prompt is added |
| Security (rules, App Check, RASP, secrets) | **Affected** | Media rules with exact paths; quotas (T-7); T-17 controls |
| Data protection (PHI, de-identification, model endpoints) | **Affected** | De-identified MDT summary; scrubbed excerpts; no transcript on the message |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | None | No new user-visible strings in code |
| Existing data | None | No live conversation path changed |

## 5. Risk & rollback plan

**Risk level:** Medium: media rules change what live clients may
store, once deployed with the app.

**Rollback plan:** redeploy the previous rules from `main`, then
revert the commits. Objects already stored stay readable by their
writers.

## 6. Implementation plan

1. Models with the transcript split, then sources.
2. Rules with a test per reader, including a patient denied a
   clinician's machine transcript.
3. The S-8 wording through the rules docs (bd353e0), ahead of the
   direct-use producers (F-21).

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01 |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), covering membership and closing, quotas, voice-note transcripts, withdrawal and the paged media sweep |
| Rules tests | Pass — RT-139..143, RT-159..171, RT-187..193 within RT-45..RT-200 |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no screen calls the callables yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Covered by CTO | Pending | Transcripts labelled AI (S-8); no result path |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Media rules; quotas; T-17 controls |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | De-identified summaries; split transcripts |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **U-1**: the media rules use two cross-service calls; RT-164/165
  and RT-169/170 prove them on the emulator, and one real upload on
  the dev project settles it. Fallback: content-addressed names.
- **U-11**: the m4a duration parse needs fixtures from iOS and
  Android recorders; the fallback is the speech service's duration.
- **Residual (T-17)**: clinician free text and speech stay outside
  the scrub. Reopen if a review finds identity in either.
- **Review findings fixed** (three adversarial reviews, d05d289):
  conversations did not close when someone left (a pathologist, a
  viewer or the case), and the orphan-media sweep did not page.
- **Accepted deviation**: a departing pathologist's MDTs close rather
  than pass on to someone else. The owner leaving closes the MDT; any
  other member is removed.
- **Follow-up**: the AI service client, for the voice-note transcript.
- **Later**: a pre-send identifier check for typed MDT messages
  (Q-22); de-identified slides in the MDT (§13).

## 10. Related records

- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Cache helpers: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Sources and indexes: [CRQ-0048](./CRQ-0048-feature-data-sources-and-indexes.md)
