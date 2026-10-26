# Model Evaluation Report (EVAL) — Tabibu

> **How to use this template:** file a report whenever a model, prompt,
> profile or threshold in the AI service changes and the held-out numbers
> move, and once for the baseline. The numbers here are what the README's
> Results section quotes, so every figure must be reproducible from the
> command in §2.
>
> Save a filled copy as
> `docs/testing/reports/EVAL-<N>-<profile>-<short-slug>-<YYYY-MM-DD>.md`
> and add a row to [`../reports/README.md`](../reports/README.md). Leave this
> template untouched.

| Field | Value |
|---|---|
| Report ID | `EVAL-XXXX` |
| Profile | `[Cancer / Malaria]` |
| Date | `[YYYY-MM-DD]` |
| Service commit | `[short SHA]` |
| Related CRQ | `[CRQ-XXXX]` |
| Previous report | `[EVAL-XXXX, or "baseline"]` |

## 1. What changed

`[The model, prompt, threshold or pipeline change being measured, or
"baseline".]`

## 2. Setup

| Item | Value |
|---|---|
| Dataset | `[PatchCamelyon test split / NIH thin-smear set]` |
| Sample | `[N items, how drawn, random seed — the fixed held-out sample]` |
| Class balance in sample | `[positives / negatives]` |
| Models and versions | `[SAM 3.1 …, Muse Spark 1.3 …]` |
| Prompt version | `[id]` |
| Decision threshold | `[value, and how it was chosen — never tuned on this sample]` |
| Command | `[exact command that reproduces every number below]` |
| Cost | `[credits spent]` |

## 3. Results

| Metric | Value | 95% CI | Previous |
|---|---|---|---|
| Sensitivity (recall on positives) | | | |
| Specificity | | | |
| Positive predictive value | | | |
| Negative predictive value | | | |
| Confusion matrix (TP / FP / FN / TN) | | — | |
| Low-confidence rate | | — | |
| Sensitivity outside the low-confidence band | | | |
| Time to preliminary report (median / p90, seconds) | | — | |

Report confidence intervals (Wilson score for proportions). A difference
inside overlapping intervals is "no measurable change", not an improvement.

## 4. Error analysis

`[A sample of false negatives and false positives with their tile/cell ids
and what they have in common. For a screening pre-read, false negatives
matter most: say whether any landed outside the low-confidence band, since
those are the ones a busy reader is least likely to catch.]`

## 5. Limitations

`[What this sample cannot tell us: tile-level vs slide-level, dataset vs
local samples, staining and scanner differences, the absence of real
pathologist review. State them plainly; the README repeats them.]`

## 6. Decision

`[Adopt / Revert / Adopt behind a flag — and why.]`

## 7. Sign-off

| Role | Name | Date | Decision |
|---|---|---|---|
| CTO / Mobile Engineer | | | |
| Clinical Reviewer | Covered by CTO until filled | | |
