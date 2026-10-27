# Testing standard & reports

What "tested" means in Tabibu, and the index of every UAT and model
evaluation report.

## The layers

| Layer | What it proves | Command | Where |
|---|---|---|---|
| Unit & bloc | Logic is correct: helpers, blocs, measurement functions | `make test` | `test/` mirroring `lib/` |
| Widget | Screens render and respond, at 1.0x and 2.0x text scale, in `en` and `sw` | `make test` | `test/features/**/presentation/` |
| Rules | Every role and clinical-safety rule holds at the data boundary | `make rules-test` (arrives with Firebase) | `test/firestore_rules/` |
| Model evaluation | The AI is accurate, not just fluent | AI service eval command | [EVAL reports](#evaluation-reports) |
| UAT | The feature works end to end for a real person | Manual, certified by me | [UAT reports](#uat-reports) |

For now CI runs only the license check; format, analyze, `bloc_lint`, the
tests and the spell check run locally through `make` until the
purpose-built workflows land with the auth work. Passing checks are
necessary but not sufficient: code is committed only after I have run it
and certified it (see
[`mobile_workflow.md` §4](../../workflow/reports/mobile_workflow.md#4-core-workflow)).

## When to file a report

- **UAT-ITR**: after the final commit of every CRQ-bearing change, once I
  have certified each story in scope. Template:
  [`UAT_TESTING_TEMPLATE.md`](../templates/UAT_TESTING_TEMPLATE.md).
- **EVAL**: for the baseline, and whenever a model, prompt, profile or
  threshold change moves a held-out number. Template:
  [`MODEL_EVALUATION_TEMPLATE.md`](../templates/MODEL_EVALUATION_TEMPLATE.md).

## Naming

```
UAT-ITR-<NNNN>-<short-slug>-<YYYY-MM-DD>.md
EVAL-<NNNN>-<profile>-<short-slug>-<YYYY-MM-DD>.md
```

Numbers are zero-padded and sequential from `0001`, separately for each type.

## UAT reports

| Report | Date | CRQ | Status |
|---|---|---|---|
| — | — | — | None yet |

## Evaluation reports

| Report | Profile | Date | Sensitivity | Specificity |
|---|---|---|---|---|
| — | — | — | — | None yet |
