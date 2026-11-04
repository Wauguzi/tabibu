# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0051 |
| Title | Live AI on the Meta Model API: the risk check, the symptom summary, the pre-read, the explanation and the alert draft |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-11-03 |
| Date implemented | 2026-11-04 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/ui`: d8c2ce1, 3d67132, 1b5df57, 8fa2e4c, f7b61ae, 0f6028b, e5b9d85, 1cea586, da333dc, 0384bc9, e6da270, d65d76b, bd4cae1, fee2e7d, 517dc3c, 145c7b5, 3a9c95a; merged as `61b77b4` in [#19](https://github.com/Wauguzi/tabibu/pull/19) |

## 1. Description of change

The AI the architecture described is built, on one provider. Every model call
is a server-side call from Cloud Functions to the Meta Model API with the
model `muse-spark-1.3`; nothing in the app calls a model, holds a key or knows
an endpoint. Five jobs, each behind its own Remote Config switch:

1. **Order risk check and doctor's-notes translation** (`risk_check_enabled`,
   d8c2ce1). The model reads the de-identified notes, a banded age, the sex,
   the county and the ordered test ids, and picks an advisory key from a fixed
   table; the sentence a doctor reads comes from that table, never from the
   model (S-7). Suggested tests are filtered to the catalogue.
2. **Symptom summary** (`symptom_intake_enabled`, d8c2ce1). A short English
   and Kiswahili summary of what a patient typed, de-identified first.
3. **Pathology pre-read** (`preread_enabled`; 3d67132, 1b5df57, 8fa2e4c,
   f7b61ae, e5b9d85). The slide is cut into tiles, the model labels each one
   Tumour or Normal (or Parasitized or Uninfected), and **every number is
   computed in code**: counts, area, the largest focus in millimetres, the
   confidence band and the draft's text. JPEG and PNG are read; the tile count
   is bounded; a run that stalls is swept; the final write is guarded.
4. **Patient explanation of a signed report, and its translation**
   (`patient_explanations_enabled`, `report_translation_enabled`; 1cea586).
   A plain-language restatement in one language, from the signed fields only,
   de-identified from what the case holds; it stays a draft until the doctor
   approves it (H-8).
5. **Outbreak alert draft** (`alert_drafting_enabled`; 1cea586). The input is
   disease and county names, the rule, the audience keys and the guidance
   bullets; never a case, a patient or a count. Every required placeholder
   must appear and every other sentence must be framing or an exact guidance
   bullet, or the template draft is used. An approver reviews every alert
   either way.

Supporting changes: the evaluation tooling (0f6028b, e5b9d85, da333dc, 0384bc9,
e6da270), and every cloud notification pushed at high priority on the app's own
channel and shown by the notification service where no push can arrive
(d65d76b).

**A departure from the architecture, recorded.** The architecture routed the
AI service through Modal and Baseten on partner credits, with Muse Spark Open
for the pathology draft, the alert drafts and the patient explanations. None of
that was built. One model on one provider, with one key in Secret Manager and
one client, was the smaller thing to get right and to review before the
deadline, and it serves all five jobs. **SAM 3.1, Muse Spark Open and Muse
Voice Transcribe are not used**; the README's partner table says so. The
heatmap is built in code from the tile labels; no segmentation model is called.

## 2. Business justification

The product's claim is "AI prepares, a qualified person decides." A demo that
shows only stored AI output cannot show the preparing. The pre-read ran live on
a slide Theo uploaded and was Ready in about nine seconds for 36 tiles, in the first shape of the worker (it now sends one tile per request, slower but measured better, §7); the
explanation of a signed report was Ready in about fifteen seconds, in English
and Kiswahili, after the doctor marked it discussed. The same switches let each
job be turned off on the day if it misbehaves, falling back to the human path
or, for alerts, the fixed template.

## 3. Scope

**In scope:** §1.

**Explicitly out of scope:**

- SAM 3.1 overlay, Muse Voice Transcribe (`voice_input_enabled` stays off), and
  Muse Spark Open: not built.
- A claim of accuracy beyond what §7 measured. The model's own stated
  probabilities are not calibrated (§7), so the confidence band is capped at
  Low for every model-labelled draft.
- Any model-written text reaching a person without an approval, except to the
  readers S-8 names, each labelled as AI.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | Affected, additive | Run, text and alert documents gain `models`, `promptVersion`, `failureReason` and a provenance line; no rule changes |
| Roles & case scoping | None | Workers run as the server; each reads the one case it was triggered on |
| Clinical safety | **Affected** | See below |
| AI service (prompts, models, thresholds) | **Affected** | Prompts `preread-classify-v4` and `report-text-v1`; one model; a band cap; the thresholds are in code and tested |
| Security (rules, App Check, RASP, secrets) | Affected | `META_API_KEY` is read from Secret Manager by the three triggers that need it; it is never logged, returned or put in a document; the scripts read it from the Keychain at run time |
| Data protection (PHI, de-identification, model endpoints) | **Affected** | See below |
| Design system / UI consistency | None | AI drafts keep their frame (H-1) |
| Localisation (en, sw) | Affected | The explanation and the symptom summary are generated in both languages; Kiswahili is machine text until a clinician reads it |
| Existing data | None | Seeded pre-reads keep their "Stored demo example, not a live model run" line |

**Clinical safety.** The model never decides anything a person does not see
first:

- **Pre-read:** reaches the pathologist only, labelled AI, scored before any
  diagnosis can be started (H-20). Counts and measurements are computed in code
  from the labels, so the model cannot state a number. The band never reads
  High on a model run.
- **Explanation:** a draft the doctor approves, edits or rejects (H-8). Every
  number in it must appear in the signed report; an advice, prognosis,
  treatment or reassurance phrase fails it; so does a wrong language, a bad
  length or an echoed placeholder. A failure leaves the human path.
- **Alert draft:** an approver sees both languages in the AI frame and approves
  the revision they saw (H-13). A draft that is not grounded in the guidance
  bullets is replaced by the template.
- **Risk check:** advice only; the sentence comes from a fixed table; it never
  says it confirms or rules out a disease (H-11, S-7).

**Data protection.** The model is called with `store: false`. Free text is
de-identified before it leaves: the notes and the symptom text from the
patient's record and the case; a signed report's text from the patient, the
clinicians, the facility, the order number and the ids (a review of the
explanation worker found it was passing no subject, so a name in the comments
would have reached the model; fixed in 1cea586 with a test). The pre-read
sends tile images of a slide; no name or id travels with them, and image text is
treated as data, not an instruction. Logs carry a reason and a status class,
never text.

## 5. Risk & rollback plan

**Risk level:** High. This is where a model can say something wrong to a
clinician or a patient. The controls above are tested, and each job has a switch.

**Rollback plan:** turn the job's Remote Config switch off; the function then
does no work and the record stays `Queued` for the human path (alerts: the
template). The whole change reverts with the merge commit and a functions
deploy. The switches' state when this record was written: risk check, symptom
summary and pre-read on; explanation drafts on; translation off; alert drafting
off.

## 6. Implementation plan

1. The client and the two cheap jobs first, behind switches; deploy; check live.
2. The pre-read worker, then the fixes the first live runs showed: an effort the
   model accepts (`none` is refused with HTTP 400; `minimal` is its floor), a
   parallel batch design with a time budget, and a guarded final write.
3. The evaluation tooling, with intervals and a held-out set that is never tuned
   on, before any accuracy is quoted.
4. The explanation and alert jobs, reviewed line by line against the privacy and
   no-advice rules; the explanation switched on and checked live; the alert
   drafter left off.
5. Deploys from a clean checkout, run by Theo, one switch at a time.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make functions-test` | Pass — 609 tests at the last run, on the emulators |
| `eslint`, `tsc`, `check-scripts`, `make spell` | Pass |
| Live: risk check | Returned "No flags" with the AI summary on a real order (3 Nov) |
| Live: pre-read | Ready in about 9 s for 36 tiles on a slide Theo uploaded, at 16 tiles per request (the worker now sends one tile per request with examples, which takes longer; not yet timed live); `models.promptVersion` `preread-classify-v3` at that run; the pathologist scored and signed it |
| Live: explanation | Ready in about 15 s in English and Kiswahili on a signed report (3 Nov); `models.promptVersion` `report-text-v1`; no name, facility or placeholder in either text |
| Evaluation, first run (3 Nov) | Too small to use: the staging could read only the first 100 rows of each split, almost all tumour, leaving 4 tuning tiles and 2 held-out tiles. **No accuracy figure comes from it**; latency and token cost were measured (minimal effort about 3 to 4 s a tile, low about 6 s, medium about 11 s) |
| Evaluation, second run (4 Nov), held-out, one tile per request, live configuration | 200 tiles (100 tumour, 100 normal): accuracy **63%** (95% interval 56 to 69), sensitivity 56%, specificity 70% (30 normal tiles called tumour, 44 tumour tiles missed). Of 167 tiles where the model stated at least 0.8, 35% were wrong |
| Same, with the four labelled examples in the prompt | Accuracy **72%** (65 to 78), sensitivity 54%, specificity 90% (10 false tumours, 46 missed). Of 170 tiles stated at least 0.8, 25% were wrong |
| Same, 16 tiles per request (how the first live worker sent them) | Without examples: accuracy **51.5%** (45 to 58), sensitivity 36%, 33 false tumours, 50% of stated-at-least-0.8 wrong. With examples: **62%** (55 to 68), sensitivity 39%, 15 false tumours, 28% wrong. Sending 16 tiles at once cost accuracy, so the worker now sends one tile per request with the examples |
| Variants on 200 tuning tiles (single tile) | Baseline 64.5% (58 to 71); tiles enlarged three times 65%, no gain; with examples 73.5% (67 to 79), specificity 90%. Two of the four example tiles are also in the tuning set, so that figure is slightly generous; the held-out run above is the clean one |
| Demo mosaics, normal tiles called tumour (108 tiles) | One tile per request: 22% (15 to 32) without examples, **11.1%** (6 to 19) with them. At 16 per request: 27.8% (20 to 38) without, 13.3% (8 to 22) with |
| Model evaluation threshold | Not met by anything quoted: the model still misses about half of the tumour tiles. The band is capped at Low and the pre-read is a prompt for the pathologist, never a result |
| Manual run | Done by Theo on the live project; the device pass is separate (CRQ-0050) |

The evaluation set is a community copy of PatchCamelyon on Hugging Face
([`KE9037/PatchCamelyon`](https://huggingface.co/datasets/KE9037/PatchCamelyon),
CC0 1.0), used because the seed's own copy
([`1aurent/PatchCamelyon`](https://huggingface.co/datasets/1aurent/PatchCamelyon),
CC0 1.0) has its viewer off. The staging script refuses the copy unless its
labels match the seed copy's on at least 98% of the rows both serve; the seed
copy still serves its first 100 training rows, and the labels matched on all
100. That is a spot check, not a proof, and I have not compared it with the
original release.

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-04 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-11-04 | Approved at 5/5 after two rounds; the three worker findings are in §9 |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Pending | — | The explanation's wording and its Kiswahili are read by a clinician after the demo build |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | One secret, three triggers; read line by line |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | De-identification tested; slides contain no identifiers beyond what a scanner embeds, which is not inspected |
| Lead Designer | §4 flags design-system impact | N/A | — | No design change |

## 9. Post-implementation review

- The first live pre-read timed out and a seed raced the worker; the worker now
  runs tiles in parallel batches inside a 240 s budget, and the seed writes in a
  transaction. A later live check found `reasoning.effort: none` refused with
  HTTP 400, which had silently broken the risk check, the symptom summary and
  the pre-read; the effort is `minimal`, pinned by a test.
- On the seeded mosaic the model over-called tumour (12 tiles against the data
  set's 2) and stated a High band. On a slide Theo uploaded it called 10 of 36,
  and that slide's own ground truth was not recorded, so it says nothing about
  accuracy. Neither is a measurement. The demo-mosaics check in §7 measures the
  first directly.
- The tile enlarge (×3) showed no gain and stays off. The four labelled
  examples did help on 200 held-out tiles, but only when each request carries
  one tile: at 16 tiles per request the worker was close to chance (51.5%). So
  the worker now sends one tile per request with the examples, retries a failed
  request once, and takes about four times as long per case (roughly 35 s for
  36 tiles in place of 10 s). The model still misses about half the tumour
  tiles, so none of this changes what the pre-read is for.
- A local review before the pull request (CRQ-0050 §9) found four gaps in the workers, each fixed with a test shown failing without it. The
  alert draft's headline and any sentence with a placeholder were not grounded, and a sentence that mentioned the guidance could carry a
  claim of its own: a draft now keeps only an exact guidance bullet or one of the template's own sentences, so a model draft is rarely
  kept and the template stands in, which is the safe direction. The explanation job ran on near-raw text when the case or patient could
  not be read: it now fails before any model call, and both facility names and the national id are removed. A pre-read counted tiles the
  model could not label as Normal, so a section it could not read said "No tumour suspected": unlabelled tiles are counted apart, and
  more than a tenth of them, or none usable, says the pre-read could not label enough. A case reassigned after its sample was recorded
  could not continue: the new pathologist can now receive the sample.
- Greptile's first round (0/5) found three flaws in the workers, all valid and
  fixed in 3a9c95a. The explanation and translation ignored signed addenda, so an
  addendum report was explained from its old content. A run over several slides
  measured them as one grid, so tumour tiles from separate slides could join into
  one focus and one resize factor applied to every slide. A first slide could use
  the whole 64-tile budget and fail the second after its model calls were paid
  for. Each slide now has its own grid and scale and a share of the budget, and
  an impossible set fails before any call. The heatmap is the first slide's,
  which is the one the viewer shows. A run of two byte-identical slides shares a
  classification cache key and its second slide reads Unknown; I left that for
  after the merge.
- Known limits: an explanation left `Running` by a crash is not reclaimed (the
  doctor writes their own); the no-advice list matches word fragments (the pre-read words match whole words only); the
  language check is cheap; the approver's review stays the real gate for an alert.

## 10. Related records

- Pre-read, scoring and signing: [CRQ-0043](./CRQ-0043-signed-reports-release-and-pdf.md), [CRQ-0047](./CRQ-0047-model-performance-signals.md)
- Outbreak alerts: [CRQ-0049](./CRQ-0049-outbreak-alerts.md)
- The screens: [CRQ-0050](./CRQ-0050-role-screens-and-flows.md)
- Secrets: [CRQ-0007](./CRQ-0007-secrets-handling-for-model-api-keys.md)
- Records after the merge: [CRQ-0038](./CRQ-0038-merge-commits-and-kept-branches.md)
