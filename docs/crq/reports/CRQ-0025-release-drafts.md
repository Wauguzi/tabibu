# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0025 |
| Title | Draft a release on every merge to main, tagged with the pubspec version; publish and mark Latest with one command |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Ported from the reference implementation's web repository, with one change:
the version comes from `pubspec.yaml` instead of being computed from tags.

1. **`.github/workflows/release-draft.yaml`** runs when a pull request
   merges to `main`:
   - It reads the open draft this automation owns. A draft is ours when its
     tag matches the convention, so a draft opened by hand is never
     adopted; two such drafts fail the run rather than one being chosen.
   - It computes the tag from the merged `pubspec.yaml`.
   - It generates notes for every pull request since the last published
     tag, through the API, because `--generate-notes` exists on create and
     not on edit.
   - It creates the draft, or refreshes the open one. A refresh renames it
     to the newest tag and moves its target to the merge, so the tag is cut
     from the commit its notes describe.

   It never publishes. Only a published release can be Latest.
2. **`scripts/next-release.cjs`**:
   - The tag is `v` + the pubspec version.
   - The version must be `a.b.cd+build`, with the build being the version
     without its dots: the convention every branch's bump already follows.
   - It must be past the latest published release, so a merge without a
     bump fails instead of re-releasing.
   - Tags are compared numerically, because the padded patches are not
     semver.
3. **Make:**
   - `release-next` prints the tag this commit would release.
   - `release-check` runs the script's tests.
   - `release-publish` publishes our draft and marks it Latest in one
     command.
4. **Tests:**
   - `scripts/next-release.test.cjs` covers the arithmetic and the real
     pubspec.
   - `scripts/release-wiring.test.cjs` reads the workflow and the Makefile
     as text and holds their rules: every write aimed at the merge, no
     create-only flag on edit, a refreshed draft given the newest tag, CI never
     publishing, drafts chosen through the script, and every action pinned
     to a commit.

   Both run in `prod_apk.yaml`, so a pull request that breaks them fails
   before it can merge.
5. Docs:
   - Architecture §13 now lists all four workflows. The labeler (CRQ-0004)
     was missing from the list.
   - Workflow §4 step 9.

## 2. Business justification

Each merge to `main` is a version judges and testers can name, with notes
written from the pull requests rather than by hand, and a version number
nobody has to type.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** attaching build artefacts to the release; App
Distribution stays in `prod_apk.yaml`.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| CI | **Affected** | A new workflow with `contents: write`, under `pull_request`, so forks get no write token |
| Security (rules, App Check, RASP, secrets) | Affected | Actions pinned to commits, credentials not persisted by checkout |
| Everything else | None | |

## 5. Risk & rollback plan

- **The first run is the first real test**: `pull_request: closed` fires
  only on a merge. The wiring tests stand in for it before then; the first
  merge of `feat/auth` drafts `v1.0.02+1002`.
- **A merge without a version bump fails the workflow** by design. Bump on
  the branch, or leave the failure; nothing is drafted wrongly.

**Rollback plan:** delete the workflow; drafts it left can be deleted in
GitHub.

## 6. Implementation plan

Read the reference workflow, script, Makefile targets and tests; replaced the
tag arithmetic with the pubspec version; kept its ownership, notes, target
and Latest rules; added CI checks.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make release-check` | 23 passing |
| `make release-next` | `(no releases) -> v1.0.02+1002` |
| `actionlint` on every workflow | Clean |
| Action SHAs against their tags (checkout v7.0.1, setup-node v7.1.0) | Match |
| `make spell` | Pass |
| A real merge | The first merge of `feat/auth` |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | A workflow with write access | Covered by CTO | 2026-10-27 | Approved — `pull_request`, pinned, no publish |

## 9. Post-implementation review

- After the first merge, check the draft's tag, notes and target, then run
  `make release-publish` and confirm it shows as Latest.

## 10. Related records

- Previous CRQ: [CRQ-0024](./CRQ-0024-rasp-service.md)
- Labels: [CRQ-0004](./CRQ-0004-codeowners-pr-template-labels-and-merge-bar.md)
