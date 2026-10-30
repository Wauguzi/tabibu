# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0038 |
| Title | Pull requests merge with a merge commit, branches are kept, and a branch's records are completed on `main` after its merge |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-10-30 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | Repository settings and the `Collaboration Rules` ruleset, changed through the GitHub API before merging [PR #6](https://github.com/Wauguzi/tabibu/pull/6); the commit that adds this record |

## 1. Description of change

1. **Merge commits, not squash.** Repository merge settings: merge commits
   only (squash and rebase off), with the pull request title and description
   as the merge commit's message. In the `Collaboration Rules` ruleset the
   pull request rule allows only `merge`, and the linear-history rule, which
   forbids merge commits, is removed. The rest of CRQ-0004's rules stand: one
   approval, code-owner review, dismissed stale approvals, resolved
   conversations, no deletion or force push, the admin bypass.
2. **Branches are kept.** Head branches are not deleted on merge, and no
   branch is deleted by hand.
3. **Records after the merge.** A branch's CRQs record Greptile's rounds
   (§8's engineering reviewer row, and §9 for what each round found) in a
   commit on `main` right after the merge, so the next branch starts from
   complete records.

## 2. Business justification

A feature branch is a sequence of small commits, each with its reason, and
its CRQs cite those commits by hash. A squash merge left `main` with one
commit per branch and those hashes reachable only through the pull request.
With a merge commit every commit lands on `main` unchanged, and the judges
and any later engineer read the same trail the records point to.

## 3. Scope

**In scope:** everything in §1, first applied to PR #6 (`feat/auth`, 114
commits).

**Explicitly out of scope:** required status checks on the ruleset
(CRQ-0004 §9, still to add).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | — |
| Roles & case scoping | None | — |
| Clinical safety | None | — |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | None | `main` still cannot be deleted or force-pushed (`main-protection` has no bypass) |
| Data protection (PHI, de-identification, model endpoints) | None | — |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | None | — |
| Existing data | None | `main`'s earlier history is unchanged |

## 5. Risk & rollback plan

**Risk level:** Low.

**Rollback plan:** restore squash in the repository settings and the
ruleset (the previous ruleset is in CRQ-0004 §9). Merges already made stay
as they are.

## 6. Implementation plan

1. The ruleset updated through the API, keeping every other rule; the
   repository settings changed; both read back.
2. PR #6 merged with a merge commit (2655348): `main` went from 25 to 140
   commits, the branch's 114 with their hashes plus the merge commit.
3. The branch's records completed on `main` in the commit that adds this
   record.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` | N/A — no code |
| `make analyze` / `make bloc-lint` | N/A — no code |
| `make test` | N/A — no code |
| Rules tests | N/A |
| Model evaluation | N/A |
| Manual run (device / simulator / web) | N/A |
| Settings | Ruleset and repository settings read back through the API; PR #6's merge commit on `main` with every branch commit beneath it |
| Certification | N/A — documentation and settings only |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-30 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | On the next pull request, as part of `main`'s history |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | None |
| Security Analyst | §4 flags security impact | N/A | — | None |
| Compliance Officer | §4 flags data protection impact | N/A | — | None |
| Lead Designer | §4 flags design-system impact | N/A | — | None |

## 9. Post-implementation review

- PR #6 was the first feature pull request: the labeler applied the
  expected `area/*` labels, and the rounds' scores (1/5, 4/5, 5/5) are in
  the records rather than the template, which is filled in before the first
  round.

## 10. Related records

- Rulesets and merge settings first set: [CRQ-0004](./CRQ-0004-codeowners-pr-template-labels-and-merge-bar.md)
- Release drafts on merge: [CRQ-0025](./CRQ-0025-release-drafts.md)
- Previous CRQ: [CRQ-0037](./CRQ-0037-build-platform-and-repository.md)
