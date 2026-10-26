# Change Request (CRQ) — Tabibu

> **How to use this template:** I am the only engineer, so a CRQ is filled in
> **as the change lands**, after implementation, testing and certification,
> not as a pre-approval gate. That keeps a written record of what changed and
> why without making me approve my own plan twice. Review still happens:
> Greptile reviews the pull request, and every duty whose seat is open (§8)
> is covered by me and recorded as covered, never as "N/A". When a second
> engineer joins, this flips to a true pre-approval gate.
>
> Save a filled copy as `docs/crq/reports/CRQ-<number>-<short-slug>.md`
> (e.g. `CRQ-0002-firebase-auth-and-role-claims.md`), incrementing `<number>`
> from the highest existing report, and add a row to
> [`../reports/README.md`](../reports/README.md). Leave this template untouched.

| Field | Value |
|---|---|
| CRQ number | `[CRQ-XXXX]` |
| Title | `[Short and specific — e.g. "Pre-read results written to cases/{caseUid}/preread with a status field"]` |
| Requested by | `[name / role]` |
| Date raised | `[YYYY-MM-DD]` |
| Date implemented | `[YYYY-MM-DD]` |
| Priority | `[P1 Critical / P2 High / P3 Medium / P4 Low]` — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | `[Standard / Normal / Emergency]` |
| Commit(s) / PR | `[short SHA(s), or PR link]` |

**Change type definitions:**
- **Standard**: a low-risk change that repeats an established pattern (a new
  screen built the way existing ones are). A CRQ is optional.
- **Normal**: follows this template: scoping, implementation, testing,
  certification, CRQ.
- **Emergency**: a fix for something breaking the live demo or a
  clinical-safety rule. File the CRQ within 24 hours and link the
  [Incident Report](../../incidents/templates/IRP_TEMPLATE.md).

## 1. Description of change

`[What changed, in plain language. Link the commit(s) or PR.]`

## 2. Business justification

`[Why it was needed: the problem for a patient, doctor or pathologist, the
judging criterion it serves, or the day of the ten-day plan it delivers.
Link to existing context rather than re-explaining it.]`

## 3. Scope

**In scope:**
`[...]`

**Explicitly out of scope:**
`[What was deliberately deferred, and why. A recorded boundary is not an
oversight.]`

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | `[None / Additive / Breaking]` | `[New Hive typeIds must be recorded in the architecture doc's registry]` |
| Roles & case scoping | `[Does any read or write now reach a case the actor is not a participant in?]` | `[...]` |
| Clinical safety | `[Can any AI output now reach a person before a qualified human approves it? Does anything change the signing, alert-approval or cancer-result gates?]` | `[If yes, the change is wrong; say how it was prevented]` |
| AI service (prompts, models, thresholds) | `[Changed? Which?]` | `[Link the evaluation report if any number moved]` |
| Security (rules, App Check, RASP, secrets) | `[Affected? How?]` | `[...]` |
| Data protection (PHI, de-identification, model endpoints) | `[Does any new field leave a case? Does any data reach a new endpoint?]` | `[Contributor (training-enabled) endpoints are never acceptable]` |
| Design system / UI consistency | `[Existing pattern reused, or a new one introduced?]` | `[...]` |
| Localisation (en, sw) | `[New strings in both ARB files?]` | `[...]` |
| Existing data | `[Migration needed? Backward compatible?]` | `[...]` |

## 5. Risk & rollback plan

**Risk level:** `[Low / Medium / High]`

**Rollback plan:** `[Commit(s) to revert, any rules/functions/index deploy to
roll back, any Remote Config switch that disables the path, and how fast.]`

## 6. Implementation plan

`[Numbered steps actually taken. Should match mobile_workflow.md §4 unless a
deviation is documented here.]`

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` | `[Pass/Fail]` |
| `make analyze` / `make bloc-lint` | `[Pass/Fail]` |
| `make test` | `[Pass/Fail — test count]` |
| Rules tests (if `firestore.rules` changed) | `[Pass/Fail — count]` |
| Model evaluation (if the AI service changed) | `[Link to EVAL report, or N/A]` |
| Manual run (device / simulator / web) | `[Pass/Fail — what was exercised]` |
| UI/UX review of the surrounding screen | `[Findings, if any]` |
| Certification | `[Date certified, by whom]` |

## 8. Approval

A row whose seat is open is covered by me: write "Covered by CTO" and decide
it. Write "N/A" only when §4 genuinely shows no impact in that area.

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | `[name]` | `[YYYY-MM-DD]` | — |
| Engineering reviewer | Always, on the pull request | `[Greptile — PR link; or "N/A — committed directly to main during the hackathon"]` | `[YYYY-MM-DD]` | `[Approved / Changes requested / Findings accepted in §9]` |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | `[name, or "Covered by CTO"]` | `[YYYY-MM-DD]` | `[Approved / Rejected / Approved with changes]` |
| Security Analyst | §4 flags security impact | `[name, or "Covered by CTO"]` | `[YYYY-MM-DD]` | `[...]` |
| Compliance Officer | §4 flags data protection impact | `[name, or "Covered by CTO"]` | `[YYYY-MM-DD]` | `[...]` |
| Lead Designer | §4 flags design-system impact | `[name, or "Covered by CTO"]` | `[YYYY-MM-DD]` | `[...]` |

## 9. Post-implementation review

`[Filled in once the change has been live for a while: did it meet its goal,
did it cause follow-up issues, should it update an architecture or design
doc? Record any Greptile finding accepted as a risk here, with what would
reopen it.]`

## 10. Related records

- Architecture/design references: `[link]`
- Evaluation report(s): `[link, if the AI service changed]`
- Related Incident Report(s): `[link, if emergency-triggered]`
- Related Problem record(s): `[link, if this resolves a known problem]`
