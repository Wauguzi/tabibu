# Incident Report (IRP) — Tabibu

> Save a filled copy as `docs/incidents/reports/IRP-<number>-<short-slug>.md`,
> incrementing `<number>` from the highest existing report, and add a row to
> [`../reports/README.md`](../reports/README.md). Leave this template
> untouched. If the root-cause analysis shows a systemic or recurring cause
> rather than a one-off, open a companion
> [Problem record](../../problems/templates/PMF_TEMPLATE.md) and link it in §10.

| Field | Value |
|---|---|
| Incident ID | `[IRP-XXXX]` |
| Title | `[Short, specific, led by the symptom — e.g. "Preliminary report visible to doctor before signing"]` |
| Severity / Priority | `[P1 Critical / P2 High / P3 Medium / P4 Low]` — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Clinical-safety incident | `[Yes / No — Yes if any rule in the threat model's clinical-safety list was broken, even if no one acted on it]` |
| Status | `[Open / Investigating / Resolved / Closed]` |
| Detected by | `[name / role, a CI run, Crashlytics, or a judge]` |
| Date/time detected | `[YYYY-MM-DD HH:mm EAT]` |
| Date/time resolved | `[YYYY-MM-DD HH:mm EAT]` |
| Affected area(s) | `[workspace / feature / service]` |
| Affected users | `[e.g. "every pathologist opening a malaria case", "web demo only"]` |

## 1. Summary

`[Two or three plain sentences: what broke, who it affected, how it was
caught.]`

## 2. Impact

`[Concrete impact: crashes, wrong data, a blocked flow, an AI output that
reached someone unreviewed. Quantify where possible. Write "unknown, no
telemetry" rather than inventing a number.]`

## 3. Clinical, security & compliance sign-off

Required for every incident, even when every answer is "No".

| Reviewer | Required when | Name | Assessment |
|---|---|---|---|
| Clinical Reviewer | Any AI output, report, result or alert reached a person it should not have, or reached them early | `[name, "Covered by CTO", or "N/A — no clinical dimension"]` | `[...]` |
| Security Analyst | Any security, auth, rules, App Check or RASP dimension to the cause | `[...]` | `[...]` |
| Compliance Officer | Any patient-identifying field left a case, was exposed, or reached a model endpoint it should not have | `[...]` | `[If exposure occurred, the notification timeline starts at detection]` |

## 4. Timeline

| Time (EAT) | Event |
|---|---|
| `[HH:mm]` | `[Detected]` |
| `[HH:mm]` | `[Path disabled / mitigated]` |
| `[HH:mm]` | `[Root cause identified]` |
| `[HH:mm]` | `[Fix committed / deployed]` |
| `[HH:mm]` | `[Verified resolved]` |

## 5. Root cause analysis

`[Use 5 Whys or a fishbone breakdown, whichever fits. Keep going until you
reach the mechanical cause, not the first symptom. Read the stack frames
before the exception text: the package prefix in a frame is usually more
honest than the message.]`

**5 Whys:**
1. Why did `[symptom]` happen? → `[...]`
2. Why? → `[...]`
3. Why? → `[...]`
4. Why? → `[...]`
5. Why? → `[root cause]`

## 6. Resolution

`[What was changed to fix it, which files and functions, and why this fix
over the alternatives considered.]`

## 7. Verification

| Check | Result |
|---|---|
| Root cause reproduced before the fix | `[Yes/No — how]` |
| Fix verified to resolve it | `[Yes/No — how]` |
| `make test` | `[Pass/Fail]` |
| Regression test added | `[file, or why not]` |
| Certification | `[Date, by whom]` |

## 8. Lessons learned

`[What made this hard to catch, and what would have caught it sooner,
specifically. "Add more tests" is not a lesson. "This value was never
validated at the one point it is produced" is.]`

## 9. Follow-up actions

| Action | Owner | Status |
|---|---|---|
| `[...]` | `[name]` | `[Open/Done]` |

## 10. Related records

- Related CRQ(s): `[link]`
- Related Problem record(s): `[link, if a systemic cause was found]`
- Related architecture/design references: `[link]`
