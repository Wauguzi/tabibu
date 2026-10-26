# Problem Management Form (PMF) — Tabibu

> Save a filled copy as `docs/problems/reports/PMF-<number>-<short-slug>.md`,
> incrementing `<number>` from the highest existing report, and add a row to
> [`../reports/README.md`](../reports/README.md). Leave this template untouched.

## When to open a Problem record vs. just an Incident

Not every incident needs a Problem record. Open one only when an
[Incident Report](../../incidents/templates/IRP_TEMPLATE.md)'s root-cause
analysis shows one of the following. Otherwise the incident's own lessons and
follow-up actions are enough.

- **Recurrence**: the same or a structurally similar defect has happened more
  than once (e.g. two incidents both traced to a model output being trusted
  where it should have been measured in code).
- **Systemic cause**: the root cause is a pattern built into the
  architecture or a widely reused helper, not a one-off mistake at one call
  site. Fixing the symptom does not prevent the next occurrence.
- **Known Error candidate**: the cause is understood, but the full fix is
  deliberately deferred for cost, risk or scope, with a workaround in place.
  The Problem record makes sure the deferred fix is not forgotten.

A Problem record owns the **systemic fix**, separately from whatever patch
resolved the originating incident(s), and it usually outlives them.

| Field | Value |
|---|---|
| Problem ID | `[PMF-XXXX]` |
| Title | `[Short and led by the cause, not the symptom — e.g. "Pre-read measurements taken from model text instead of computed in code" rather than "tumor size sometimes wrong"]` |
| Status | `[Open / Investigating / Known Error / Resolved / Closed]` |
| Opened by | `[name / role]` |
| Date opened | `[YYYY-MM-DD]` |
| Date resolved | `[YYYY-MM-DD, or "—" while open]` |
| Priority | `[P1-P4]` — set by how often it recurs and how far it reaches if left unresolved, not by any single incident's severity |

## 1. Problem statement

`[The systemic issue, stated as a cause, not a symptom.]`

## 2. Triggering incident(s)

| Incident ID | Title | Date |
|---|---|---|
| `[IRP-XXXX]` | `[...]` | `[...]` |

`[Every incident that contributed evidence. A Problem record opened with no
triggering incident is worth a second look.]`

## 3. Root cause (systemic)

`[The cause at the level of the architecture or pattern: what makes this
class of defect possible.]`

## 4. Affected scope

`[Every place this cause could plausibly recur: a specific list, not "the
whole codebase".]`

## 5. Workaround (if any, while open)

`[What mitigates the symptom today. If nothing does, say so: "no workaround,
exposure remains live" is a valid and important status.]`

## 6. Permanent fix

`[The systemic change that closes this record: a refactor, a lint rule, a
test that pins the invariant, a structural convention. Link the
implementing CRQ once it lands.]`

## 7. Known Error record

`[If the status is "Known Error": the cause is accepted for now, with a
documented workaround and a target date or trigger for the permanent fix.]`

## 8. Verification

| Check | Result |
|---|---|
| Permanent fix implemented | `[Yes/No]` |
| Verified to prevent recurrence, not just the original symptom | `[Yes/No — how]` |
| `make test` | `[Pass/Fail]` |

## 9. Clinical, security & compliance sign-off

`[Required whenever the systemic cause or its scope touches clinical safety,
security or data protection. A Problem record usually reaches further than
any single incident, so this matters even when each triggering IRP was
assessed "No". Write "N/A" with a one-line reason only if it genuinely does
not apply.]`

| Reviewer | Required when | Name | Assessment |
|---|---|---|---|
| Clinical Reviewer | The cause affects what AI output reaches a person, or when | `[name, "Covered by CTO", or "N/A — reason"]` | `[...]` |
| Security Analyst | The cause affects rules, auth, App Check or RASP | `[...]` | `[...]` |
| Compliance Officer | The cause affects what data leaves a case or reaches a model endpoint | `[...]` | `[...]` |

## 10. Related records

- Triggering Incident Report(s): `[link]`
- Implementing CRQ(s): `[link]`
- Related architecture/design references: `[link]`
