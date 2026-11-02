# Tabibu — AI Service & Pre-read Pipeline

> The one service in Tabibu that calls a model. It prepares; a person
> decides. This document is the contract between the service, Firebase and
> the app. Pair it with [`mobile_architecture.md`](./mobile_architecture.md)
> §3 (why the app never calls a model) and
> [`outbreak_alert_engine.md`](./outbreak_alert_engine.md), which uses the
> same service for drafting; its detector is code in the Cloud Functions.

| Field | Value |
|---|---|
| Owner | Theo — CTO, Mobile Engineer |
| Status | Draft — design fixed before the day-2 model tests; §10 records the gates |
| Last reviewed | 2026-11-01 |
| Runs on | Modal (Python), triggered by Cloud Functions |
| Writes to | Firestore `cases/{caseUid}/preread/{runUid}`, Storage `preread/{caseUid}/{runUid}/`. The other jobs return to the Cloud Function that called them, which writes the result (§2) |

## 1. Jobs

| Job | Trigger | Models | Output | Who sees it first |
|---|---|---|---|---|
| **Pre-read** | A case with an image-bearing specimen is assigned to a pathologist | SAM 3.1, Muse Spark 1.3 (vision), Muse Spark Open | Masks, labels, measurements, a structured draft report | The case's pathologist, only (S-1) |
| **Order risk check and notes translation** | A doctor submits an order, or edits its notes while they are editable | Muse Spark 1.3 with tool calls | Suggested tests; a notifiable-disease protocol advisory from a fixed template; the doctor's notes in the other language. **One call** returns all three | The ordering doctor; the translation also the pathologist, with the original beside it |
| **Symptom intake** | A patient books, typing or speaking their symptoms | Muse Voice Transcribe, Muse Spark 1.3 | Speech: a transcript, which the patient checks and corrects before sending; the audio is then deleted. Then a structured summary in **English and Swahili from one call** | The doctor who takes the appointment |
| **Report translation** | A version is signed | Muse Spark Open | The signed report in the other language | The signer, who approves it before any reader sees it |
| **Patient explanation** | The doctor marks a result discussed | Muse Spark Open | Plain-language explanation in English and Swahili | The ordering doctor, who approves it before the patient sees it |
| **Voice-note transcription** | A voice note is delivered in a conversation | Muse Voice Transcribe | A transcript, stored apart from the message | The sender, and the doctors and pathologists in the thread; a patient only once the sender shares it |
| **Alert drafting** | The detector raises a signal | Muse Spark Open | Doctor guidance and a patient notice in en and sw, with placeholders for every number, grounded in the bundled guidance, which it may not rewrite. It receives no case data. If the model fails, a fixed template draft is used | The alert approver |

Every output is written to Firestore for a person to act on, and none goes
from the service to anyone directly. **Where the docs require an approval, it
is a one-tap "approve as is"**, with editing secondary: the pre-read (scored,
then signed), the report translation (the signer), the patient explanation
(the ordering doctor), a clinician's transcript shared with a patient (the
sender), and an alert (an authorised clinician holding the approver permission). **Where the
threat model's S-8 names the reader as the qualified person who acts on the
output, it is used directly**: the symptom summary and risk advice to the
doctor, the notes translation to the doctor and pathologist, the speaker's
own transcript, and any voice-note transcript to the clinicians in that
conversation, who also hear the audio. Either way the output is labelled as AI, its input is
de-identified, and it records its signals (§6).

The jobs this document did not describe before are built in the
`feat/ai-service` branch, each with its evaluation report. Until then the
Cloud Functions tests inject a fake AI client that returns fixtures,
failures and timeouts.

## 2. Invocation

```
App write ──► Firestore ──► Cloud Function trigger ──► HTTPS ──► Modal endpoint
                                 (checks state,          (shared secret     │
                                  sets status=Queued)     in a header)      │
                                                                            ▼
App listens ◄── Firestore ◄── Admin SDK write (status=Ready|Failed) ◄── pipeline
```

- The Cloud Function owns the state transition to `Queued` and passes only
  ids, Storage paths, **de-identified text or the speaker's audio**, never
  patient-identifying fields. Free text goes as data, never as instructions,
  and the output is schema-validated (T-12).
- Only the pre-read writes back on its own, through the service account.
  The risk check and notes translation, the report texts, the symptom
  summary and the voice-note transcript are **synchronous calls from their
  trigger**, which writes the result; symptom speech to text is a callable
  the app waits on. A service error or a 60-second timeout writes `Failed`
  and a `failureReason`, and is never thrown back into the trigger's retry
  loop. A pre-read, report text or symptom summary still `Queued` or
  `Running` 30 minutes after it was requested is failed as `Stale` by a
  sweep, and a voice-note transcript after 10 minutes.
- The Modal endpoint rejects any call without the shared secret. The secret
  lives in Firebase secret parameters and Modal secrets, never in the app.
- The service writes back with a scoped service account. Rules deny
  client writes to every `preread` document.
- A re-trigger for the same image and profile reuses the cached result
  (§7) instead of spending credits again.

## 3. The pre-read pipeline

The specimen type on the order selects a **profile**. Both profiles run the
same five steps; the agent calls them as tools in order and hands the
pathologist one finished draft.

| Step | Cancer profile (hero) | Malaria profile |
|---|---|---|
| **1. Segment** — SAM 3.1, text prompt | Outline tumor regions on each H&E tile | Outline every red blood cell on the thin smear |
| **2. Classify** — Muse Spark 1.3 vision | Label each tile tumor / normal | Label each cell parasitized / uninfected |
| **3. Measure** — code, not a model | Tumor heatmap; size of the largest tumor focus; micro-metastasis (0.2–2 mm) vs macro-metastasis (over 2 mm) | Cells counted; parasitized cells; parasitemia % |
| **4. Draft** — Muse Spark Open | Structured report from the measurements, the labels and the doctor's notes | Same |
| **5. Rank** — code | Worklist priority from urgency, risk flags and confidence (`rankCase`, in the Cloud Functions); the app adds the time waiting | Same |

Labeled data each profile is measured against: PatchCamelyon (327,680
labeled 96 × 96 px tiles from the CAMELYON16 slides, CC0) and the NIH
thin-smear set (27,558 cell images, half parasitized). Cytology, such as a
cervical Pap smear, reuses the malaria steps and is the next profile. Any
other test has no image pre-read: the lab enters the result and the
pathologist signs it.

### 3.1 Measurement is code

Every number the report shows comes from step 3. The drafting model receives
the numbers as input and is instructed to quote them, and the service checks
the draft's numbers against the measurement record before marking it `Ready`.
A draft that states a number not in the record is rejected and re-drafted
once, then marked `Failed`.

Physical size needs the slide's micrometres-per-pixel. It is stored with each
image at upload and used for every millimetre conversion. A tile without it
gets no size claim.

### 3.2 Confidence

Confidence is computed in code from the per-tile or per-cell probabilities
and from how much the labels near the deciding region agree. It is not the
drafting model's opinion of itself. Below the low-confidence threshold the
draft is marked **Low confidence**, the case moves **up** the worklist for a
careful read, and the label is shown wherever the draft is shown. The
threshold is a Remote Config value so it can be tuned against the
evaluation without a release.

### 3.3 The draft

Structured output, validated against a schema before it is stored:
`findings[]` (each linked to the tile or cell ids it came from), `impression`,
`confidence`, `confidenceBand` (`High`/`Moderate`/`Low`), `urgency`
(`Routine`/`Priority`/`Urgent`), `nextSteps[]`, plus the model id and version
of every model that touched it.

## 4. Review and signing

1. The pathologist opens the case. The viewer shows the image with the
   heatmap or masks overlaid; each finding links to its evidence.
2. **The pathologist scores the pre-read before writing.** The primary action
   is a one-tap "Agree with the pre-read"; each verdict can be changed. Once
   scored, the pathologist may start the report from the pre-read in one tap.
3. Relabelling a tile or cell recalculates the measurements immediately. The
   measurement functions are pure, defined once in the service, with a Dart
   port in the app for instant feedback. The two are kept in step by a
   **shared fixture suite** that both test runs read.
4. The pathologist edits the draft text.
5. **Sign** calls the `signReport` Cloud Function with the draft's
   `lastUpdatedAt`. It recomputes the measurements from the final labels with
   the service's implementation, which is authoritative, uploads the
   signature under a content-addressed name (`signature-{sha256}.png`), then
   writes in **one transaction**: the signed version, the untouched AI draft
   beside it, and the field-level diff that the edit-rate KPI is computed
   from. It is a transaction because its writes depend on the draft's state
   and the version's existence: it **refuses a draft that changed** since the
   pathologist last saw it, and a replay returns the version already signed,
   before any upload. Only a signed report is readable by the doctor.

### 4.1 Texts that follow a signed report

- **Translation.** Each signed version is translated into the other
  language. The signer approves it, as is in one tap or edited, before a
  reader sees it. Numbers are tokenised before the model sees the text and
  restored in code afterwards, and an edit that changes a number is refused.
- **Patient explanation.** When the doctor marks a result discussed, an
  explanation is drafted in English and Swahili. **The ordering doctor
  approves it**, as is in one tap or edited, and only then does the patient
  read it.
- **Two records.** The model's text lives in a working record that only its
  approver reads, by id, and that is never cached. Approval creates a
  separate, reader-facing record holding the approved text alone, so readers
  never receive unapproved model text. Every approval records
  `acceptedUnchanged`, and an edit records which segments changed and by how
  much.

## 5. Firestore contract

`cases/{caseUid}/preread/{runUid}`, complete at creation:

| Field | Type | Notes |
|---|---|---|
| `uid`, `caseUid`, `profile` | string | `profile`: `Cancer` / `Malaria` |
| `status` | string | `Queued` → `Running` → `Ready` / `Failed`. Gates every other field. |
| `imagePaths` | string[] | Storage paths; never a public URL |
| `micronsPerPixel` | number | `0` means unknown, so no size claim |
| `segmentationPath` | string | Masks and boxes, as one JSON file in Storage |
| `labelsPath` | string | The labels (tile or cell id → label and probability), as one JSON file in Storage |
| `labelCounts` | map | label → count |
| `measurements` | map | Profile-specific; every value computed in code |
| `draft` | map | §3.3 |
| `models` | map | Model id and version per step |
| `inputLanguage` | string | The language of the doctor's notes |
| `requestedAt`, `startedAt`, `readyAt` | string (UTC) | `readyAt − requestedAt` is time to preliminary report |
| `failureReason` | string | `''` unless `Failed`: for example `Timeout`, `ServiceError`, `OffSchema`, `NumberCheck`, `Stale` |
| `lastUpdatedAt` | string (UTC) | |

The pathologist's client listens to this document while the case is open and
stops when it closes or the app is backgrounded. A run still `Queued` or
`Running` after 30 minutes is failed as `Stale`, and the case moves on to a
manual read. Slides added after a pre-read start a new run.

## 6. Endpoint and data policy

- **Standard endpoints only.** Contributor (training-enabled) versions of
  Muse Spark are never called, even with public demo data, so the habit holds
  when the data is real. The endpoint ids are constants in the service, and a
  test fails if any id names a contributor variant.
- **No Muse Image.** Diagnostic images are always the real sample, never
  generated or altered.
- **Only ids, images and de-identified text go to a model.** Notes sent for
  drafting are passed through the same de-identification as alert events (no
  name, phone, exact location or date of birth). **Speech is the one
  exception** (S-8): symptom audio goes only to the transcription model and
  is deleted straight after, and its transcript is de-identified before the
  summary model reads it; voice-note audio goes only to the transcription
  model, and the stored note is the sender's own message.
- **Every model output is stored** beside what the person did with it, and
  **every approval records `acceptedUnchanged`**, plus the edit distance or
  the field diff when it was edited.
- **Model performance signals.** Each output records its signals: counts,
  rates, durations, language codes and model ids, never a uid, a name or
  text. A daily function, `aggregateModelSignals`, writes them to
  `modelSignals/{YYYYMMDD}`, which only admins read.

  | Output | Signals |
  |---|---|
  | Pre-read | One-tap agree rate, verdict mix, the report's edit rate against the AI draft, the started-from-pre-read rate, confidence bands, failures by reason, latency |
  | Report translation, patient explanation | Accepted-unchanged rate, edit distance, number-check failures, language mismatches, failures, latency |
  | Symptom intake | Failures, input language mix, latency |
  | Symptom speech to text | Transcript accepted-unchanged rate, edit distance, detected language, fallback to typing, latency |
  | Voice-note transcription | Ready and failed rates, language mix, latency, share rate and shared-as-is rate, the MDT identifier-flag and withdraw rates, durations |
  | Risk check, notes translation | Failures, advisory rate, dropped suggestions, languages, latency |
  | Alert drafting | Accepted-unchanged rate, edit distance, template fallbacks by reason, draft latency, time to decision, expiry rate |
  | Pre-read notifiable hint | Hint shown, then marked |

## 7. Cost control

$150 of Meta Model API credit covers the whole build. Images are the
expensive part, so:

- Tiles and cell crops go to Muse Spark **many to an image**.
- Every model result is cached by `(model version, prompt version, image
  content hash)`. A re-run of an unchanged case costs nothing.
- Evaluation runs on a **fixed** held-out sample, not the full datasets.
- Text-only work (reports, alert drafts, patient explanations) runs on Muse
  Spark Open on Baseten credits.

## 8. Order risk check

Muse Spark 1.3 reads the doctor's notes and the order and calls two tools: a
**catalogue lookup** (tests, specimen types, the disease each confirms and
its reporting category) and an **outbreak lookup** (the detector's open
signals by county). It returns suggested tests and, when symptoms, malaria
results and travel history fit a suspected viral hemorrhagic fever, an
advisory to follow Ministry of Health protocol before the sample travels.
**It never confirms or rules out a disease**, and its wording is fixed by a
template, not generated freely.

The same call translates the doctor's notes. The trigger writes two records
under the case, each `Queued` → `Running` → `Ready` or `Failed`:

| Record | Holds |
|---|---|
| `riskCheck/current` | `suggestedLabTestIds` (unknown ids dropped), `advisoryKey` and the template's `advisoryEn` and `advisorySw`, `inputLanguage`, `models`, `failureReason` |
| `notesTranslation/current` | `sourceLanguage`, `language`, `text`, `sourceSha256` of the notes (the app shows nothing when the notes have changed since), `models`, `failureReason` |

A notes edit while the order is still editable re-runs the call. A risk flag
also raises the case on the pathologist's worklist.

## 9. Kill switches

Remote Config, read by the Cloud Function trigger and by the app:
`preread_enabled`, `risk_check_enabled`, `patient_explanations_enabled`,
`alerts_delivery_enabled`, `symptom_intake_enabled`,
`report_translation_enabled`, `voice_input_enabled` and
`alert_drafting_enabled`. Turning one off stops new work and hides the
affected surface. It does not delete anything already stored. The server
reads its own template; when that cannot load, every AI-job switch fails
closed (no new job; the human path continues) and alert drafting fails open
to the template draft, so the approver still gets one
([`mobile_architecture.md` §10](./mobile_architecture.md#10-security)).

## 10. Day-2 gates

Decided by the 27 October tests, recorded here once run:

| Gate | If it fails | Result |
|---|---|---|
| Muse Spark reads 96 px PatchCamelyon tiles well enough | Switch the cancer profile to BreakHis breast images labeled at whole-image level | Pending |
| SAM 3.1 segments thin-smear cells reliably | Classify the NIH set's ready-cut cells and draw boxes instead of masks | Pending |
| Swahili output from Muse Spark and Muse Spark Open is usable | English shown alongside; a fluency pass later (not a gate) | Pending |
| Muse Voice Transcribe accepts Swahili speech | Text intake for Swahili; voice for English. Typing is always the fallback when a transcription fails | Pending |

## 11. Change log

| Date | Change | Author |
|---|---|---|
| 2026-11-02 | The alert's approver is an authorised clinician holding the approver permission (`feat/ui`, decision S-2). | Theo |
| 2026-11-01 | For the `feat/infra` data layer: §1 the report translation, the doctor-approved explanation, the en and sw intake from one call, speech to text, voice-note transcripts, grounded alert drafting, one-tap approval and S-8 direct use; §2 de-identified text or the speaker's audio, synchronous calls, `Failed` without retries; §3 ranking split between the functions and the app; §4 scoring first, `signReport` as a transaction, §4.1 the report texts with numbers tokenised; §5 `labelsPath`, `inputLanguage`, `failureReason`, stale runs; §6 the speech exception, `acceptedUnchanged` and the model performance signals; §8 the two records; §9 eight switches; §10 the Swahili fallback (CRQ-0041, CRQ-0043, CRQ-0044, CRQ-0047). | Theo |
| 2026-10-26 | Initial version: jobs, invocation path, the five-step pipeline, measurement-in-code and confidence rules, signing, the Firestore contract, endpoint policy, cost control, and the day-2 gates. | Theo |
