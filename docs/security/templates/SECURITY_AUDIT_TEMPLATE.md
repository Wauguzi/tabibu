# [Scope] Security Audit

> **Template status:** blank skeleton. Copy into
> `docs/security/reports/<scope>_security_audit.md` and fill in every
> `[bracketed]` placeholder before deleting this notice.

| Field | Value |
|---|---|
| Scope | `[e.g. firestore.rules + Cloud Functions / the AI service's endpoints and secrets]` |
| Owner | `[Security Analyst; covered by the CTO while that seat is open]` |
| Status | `[Point-in-time audit / Living — see note below]` |
| Audit date | `[YYYY-MM-DD — the original audit; never changes]` |
| Last updated | `[YYYY-MM-DD — bump when a Living doc gains a finding; omit for Point-in-time]` |
| Performed by | `[name / role]` |
| Methodology | `[e.g. "never trust the client": every role, signature, approval and threshold enforced server-side]` |

> **Living vs. Point-in-time:** most audits should be **Living**. Append new
> findings to §3, new items to §6 and a dated row to §7 as later work
> surfaces them. Never delete or quietly rewrite a past finding to make the
> document look cleaner. Correct it in place with a note and let §7 carry the
> history. Reserve **Point-in-time** for a genuine one-off snapshot.

## 1. Purpose & scope

`[What prompted this audit, what it covers and what it deliberately leaves
out. Name the trigger, so a reader months from now knows why it exists.]`

## 2. Verified clean

`[Controls checked and found correct, one line each. This section exists so
the report shows what was actually checked, not only what is wrong.]`

## 3. Findings

`[Graded Critical → High → Medium → Low. Skip an empty tier rather than
writing "no findings". Grade any finding that lets an AI output, a report or
an alert reach a person without its human approval at least High,
regardless of how hard it is to exploit.]`

### [Severity] — `[file:line]` — [Vulnerability name]

`[What an attacker or a faulty client could concretely do, then a
before/after fix, or a recommendation if the fix needs a design decision this
document cannot make alone.]`

## 4. Threat scenario reconciliation

`[Reconcile against existing tracked threats (the threat model's T-IDs, a
prior audit): what is now resolved, what is still open, and how each new
finding maps onto an existing item. Cross-reference; do not duplicate.]`

## 5. Not applicable

`[Checklist areas that do not apply right now, each with a one-line reason.]`

## 6. Remediation roadmap

`[What should happen next, in priority order, and which surface owns each
item: a rules change, a Cloud Function, the AI service, or a client fix.]`

## 7. Change log

| Date | Change | Author |
|---|---|---|
| `[YYYY-MM-DD]` | `[Initial version]` | `[name]` |
