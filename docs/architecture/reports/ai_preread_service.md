# Tabibu — AI Service & Pre-read Pipeline

> The one service in Tabibu that calls a model. It prepares; a person
> decides. This document is the contract between the service, Firebase and
> the app. Pair it with [`mobile_architecture.md`](./mobile_architecture.md)
> §3 (why the app never calls a model) and
> [`outbreak_alert_engine.md`](./outbreak_alert_engine.md), which uses the
> same service for detection and drafting.

| Field | Value |
|---|---|
| Owner | Theo — CTO, Mobile Engineer |
| Status | Draft — design fixed before the day-2 model tests; §10 records the gates |
| Last reviewed | 2026-10-26 |
| Runs on | Modal (Python), triggered by Cloud Functions |
| Writes to | Firestore `cases/{caseUid}/preread/{runUid}`, Storage `preread/{caseUid}/{runUid}/` |

## 1. Jobs

| Job | Trigger | Models | Output | Who sees it first |
|---|---|---|---|---|
| **Pre-read** | A case with an image-bearing specimen is assigned to a pathologist | SAM 3.1, Muse Spark 1.3 (vision), Muse Spark Open | Masks, labels, measurements, a structured draft report | The case's pathologist, only |
| **Order risk check** | A doctor submits an order | Muse Spark 1.3 with tool calls | Suggested tests; a notifiable-disease protocol advisory | The ordering doctor |
| **Symptom intake** | A patient records or types symptoms | Muse Voice Transcribe, Muse Spark 1.3 | Transcript and structured intake | The doctor who takes the case |
| **Patient explanation** | A signed result is released to the patient | Muse Spark Open | Plain-language explanation in English and Swahili | The patient, after release |
| **Alert drafting** | The detector raises a signal | Muse Spark Open | Doctor guidance and a patient notice in en and sw | The alert approver |

Every output is a **draft written to Firestore for a person to act on**.
None is delivered to anyone directly by the service.

## 2. Invocation

```
App write ──► Firestore ──► Cloud Function trigger ──► HTTPS ──► Modal endpoint
                                 (checks state,          (shared secret     │
                                  sets status=Queued)     in a header)      │
                                                                            ▼
App listens ◄── Firestore ◄── Admin SDK write (status=Ready|Failed) ◄── pipeline
```

- The Cloud Function owns the state transition to `Queued` and passes only
  ids and Storage paths, never patient-identifying fields.
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
| **5. Rank** — code | Worklist priority from urgency, risk flags, confidence and time waiting | Same |

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
2. Relabelling a tile or cell recalculates the measurements immediately. The
   measurement functions are pure, defined once in the service, with a Dart
   port in the app for instant feedback. The two are kept in step by a
   **shared fixture suite** that both test runs read.
3. The pathologist edits the draft text.
4. **Sign** calls the `signReport` Cloud Function. It recomputes the
   measurements from the final labels with the service's implementation,
   which is authoritative, then writes in one batch: the signed report, the
   untouched AI draft beside it, and the field-level diff that the edit-rate
   KPI is computed from. Only a signed report is readable by the doctor.

## 5. Firestore contract

`cases/{caseUid}/preread/{runUid}`, complete at creation:

| Field | Type | Notes |
|---|---|---|
| `uid`, `caseUid`, `profile` | string | `profile`: `Cancer` / `Malaria` |
| `status` | string | `Queued` → `Running` → `Ready` / `Failed`. Gates every other field. |
| `imagePaths` | string[] | Storage paths; never a public URL |
| `micronsPerPixel` | number | `0` means unknown, so no size claim |
| `segmentationPath` | string | Masks and boxes, as one JSON file in Storage |
| `labels` | map | tile/cell id → label and probability |
| `measurements` | map | Profile-specific; every value computed in code |
| `draft` | map | §3.3 |
| `models` | map | Model id and version per step |
| `requestedAt`, `startedAt`, `readyAt` | string (UTC) | `readyAt − requestedAt` is time to preliminary report |
| `error` | string | Empty unless `Failed` |
| `lastUpdatedAt` | string (UTC) | |

The pathologist's client listens to this document while the case is open and
stops when it closes or the app is backgrounded.

## 6. Endpoint and data policy

- **Standard endpoints only.** Contributor (training-enabled) versions of
  Muse Spark are never called, even with public demo data, so the habit holds
  when the data is real. The endpoint ids are constants in the service, and a
  test fails if any id names a contributor variant.
- **No Muse Image.** Diagnostic images are always the real sample, never
  generated or altered.
- **Only ids and images go to a model.** Notes sent for drafting are passed
  through the same de-identification as alert events (no name, phone, exact
  location or date of birth).
- **Every model output is stored** beside what the person did with it.

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

## 9. Kill switches

Remote Config, read by the Cloud Function trigger and by the app:
`preread_enabled`, `risk_check_enabled`, `patient_explanations_enabled`,
`alerts_delivery_enabled`. Turning one off stops new work and hides the
affected surface. It does not delete anything already stored.

## 10. Day-2 gates

Decided by the 27 October tests, recorded here once run:

| Gate | If it fails | Result |
|---|---|---|
| Muse Spark reads 96 px PatchCamelyon tiles well enough | Switch the cancer profile to BreakHis breast images labeled at whole-image level | Pending |
| SAM 3.1 segments thin-smear cells reliably | Classify the NIH set's ready-cut cells and draw boxes instead of masks | Pending |
| Swahili output from Muse Spark and Muse Spark Open is usable | Patient copy reviewed by hand before the demo; English shown alongside | Pending |
| Muse Voice Transcribe accepts Swahili speech | Text intake for Swahili; voice for English | Pending |

## 11. Change log

| Date | Change | Author |
|---|---|---|
| 2026-10-26 | Initial version: jobs, invocation path, the five-step pipeline, measurement-in-code and confidence rules, signing, the Firestore contract, endpoint policy, cost control, and the day-2 gates. | Theo |
