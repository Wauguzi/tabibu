# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0004 |
| Title | CODEOWNERS, the pull request template, the label taxonomy, and a 5/5 Greptile merge bar |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

Sets up the pull request path that feature branches will use from the auth
work onwards.

1. **`.github/CODEOWNERS`**: `* @art-sparrow`. Every path is owned by me,
   so I am requested on every pull request, Dependabot's included.
2. **Pull request template rewritten.** The scaffold's template had a
   description and a type checklist. It now also covers the local checks run,
   a **Clinical Safety** section that walks S-1 to S-6, a **Security
   Boundary** section for rules and functions, links to the CRQ and any UAT or
   evaluation report, the docs updated, and a **Review** section that records
   the Greptile confidence score.
3. **Label taxonomy as code** (`scripts/labels.sh`): `type/*` (the seven
   template boxes), `area/*` (the feature areas), `clinical-safety`,
   `security-boundary`, `needs-deploy`, `needs/*` (the CRQ §8 reviewer
   seats), `P1`–`P4`, and Dependabot's three. It renames GitHub's defaults
   rather than recreating them, retires the drive-by-contributor ones, and
   ends by verifying the result.
4. **Path-derived labels** (`.github/labeler.yml` and
   `.github/workflows/labeler.yml`): `area/*` and `security-boundary` are
   applied from changed files. The workflow uses `pull_request_target`, so a
   pull request cannot relabel itself through its own copy of the config. It
   never checks out pull request code, holds only `pull-requests: write`,
   never removes a label, and pins `actions/labeler` to the v7.0.0 commit.
5. **The merge bar.** A pull request merges only at a 5/5 Greptile
   confidence score with every finding fixed or answered. Recorded in
   [`mobile_workflow.md`](../../workflow/reports/mobile_workflow.md) §4 step 7
   and §6, and in the CRQ template's §8.
6. `make spell` now also covers `.github/*.md`.

## 2. Business justification

Feature work starts on branches with the auth work. Greptile is the only
reviewer besides me, and it has proved strongest at catching edge cases, so
the bar for merging is set at its top score rather than at "no blocking
findings". The template makes each pull request carry its own evidence:
which checks ran, which clinical-safety rules were considered, which CRQ
explains it. A reviewer, or a judge reading the history, does not have to
reconstruct any of that.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- **Running `scripts/labels.sh`.** It changes the repository's labels on
  GitHub, so I run it myself; nothing in this commit applies it.
- **Branch rulesets.** Configured in the GitHub settings, not in the
  repository. The proposal is recorded in §9.
- **Required status checks**, which wait for the replacement CI workflows
  (CRQ-0003).
- **An issue template.** Not needed while the ten-day plan is the backlog.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | **Affected (process)** | Every pull request now answers S-1 to S-6 explicitly |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected (CI)** | A new workflow with `pull-requests: write` under `pull_request_target`; mitigated as described in §1 item 4 |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low.

The one sensitive pattern is `pull_request_target` with a write token. It
is dangerous only when the job runs code from the pull request. This job runs
none: it reads the changed-file list and calls the labels API.

**Rollback plan:** revert the commit. Labels already created on GitHub stay
until removed by hand. Minutes.

## 6. Implementation plan

1. Added `CODEOWNERS` and confirmed `@art-sparrow` has write access
   (admin), which GitHub requires for an owner entry to take effect.
2. Rewrote the pull request template around Tabibu's checks, its
   clinical-safety rules and the merge bar.
3. Wrote the label taxonomy and the path rules to match the architecture's
   feature folders and the CRQ's priority and reviewer seats.
4. Pinned `actions/labeler` to the v7.0.0 commit.
5. Updated the workflow doc, the CRQ template and the `spell` target.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `bash -n scripts/labels.sh` | Pass |
| `.github/labeler.yml`, `.github/workflows/labeler.yml` parse as YAML | Pass |
| `make spell` (now including `.github/*.md`) | Pass |
| `@art-sparrow` permission on `Wauguzi/tabibu` | `admin` |
| Labeler applying labels | Confirmed on the first pull request |
| Certification | 2026-10-27 — Theo (CI, template and documentation change) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — no PR code is checked out under the write token |
| Clinical Reviewer | §4 flags clinical-safety impact | Covered by CTO | 2026-10-27 | Approved — the template's S-rule checklist |
| Compliance Officer | — | N/A — no data impact | — | — |
| Lead Designer | — | N/A — no UI change | — | — |

## 9. Post-implementation review

**Applied 2026-10-27, verified through the GitHub API:**

| Ruleset | Enforcement | Target | Bypass | Rules |
|---|---|---|---|---|
| `Collaboration Rules` | Active | Default branch | Repository admin, always | Restrict deletions, block force pushes, linear history, pull request (1 approval, code-owner review, dismiss stale approvals, conversation resolution, squash only) |
| `main-protection` | Active | Default branch | None | Restrict deletions, block force pushes |

`main-protection` has no bypass, so nobody, me included, can delete `main` or
rewrite its history. Repository merge settings: squash merging only, with the
pull request title and description as the commit message; merge commits and
rebase merging off; head branches kept after merge. The labels were applied
with `scripts/labels.sh` (31 labels, verified by the script). Required status
checks are added to `Collaboration Rules` when the replacement CI exists.

With the bypass in place, the 5/5 bar on my own pull requests is held by
this workflow rather than enforced by GitHub, because GitHub does not let an
author approve their own pull request. The code-owner approval does gate
Dependabot's pull requests, which I can approve.

To check after the first feature pull request: that the labeler applied the
expected `area/*` labels, that Greptile's score was recorded in the
template, and whether the template's length helps or hinders.

## 10. Related records

- Workflow: [`mobile_workflow.md` §4, §6](../../workflow/reports/mobile_workflow.md#4-core-workflow)
- Previous CRQ: [CRQ-0003](./CRQ-0003-interim-ci-license-check-fix-and-main-workflow-removal.md)
