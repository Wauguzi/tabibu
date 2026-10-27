# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0003 |
| Title | Interim CI: fix the license check for Flutter, and remove the scaffold's main workflow |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

1. **License check fixed.** `license_check.yaml` failed on the bootstrap
   commit before checking anything: the reusable workflow runs `flutter pub
   get` only when `flutter_version` is set, so it ran `dart pub get` and
   stopped at "Because tabibu requires the Flutter SDK, version solving
   failed". It now sets `flutter_version: "3.47.x"`, and also triggers on
   `pubspec.lock` changes.
2. **Five packages skipped by name.** Once it could resolve, the check
   reported five licenses outside the allow-list, none of which ships in an
   app build:

   | Package | License | Arrives through | Why it does not ship |
   |---|---|---|---|
   | `antlr4` | BSD-3-Clause-HP | `fake_cloud_firestore` (dev) | Dev tool only |
   | `pubspec_lock_parse` | unknown | `bloc_lint` (dev) | Dev tool only |
   | `dbus` | MPL-2.0 | `flutter_local_notifications_linux`, `geolocator_linux` | Linux plugin code; Tabibu has no Linux target |
   | `geoclue` | MPL-2.0 | `geolocator_linux` | Same |
   | `gsettings` | MPL-2.0 | `geolocator_linux` | Same |

   The allow-list itself is unchanged: MIT, BSD-2-Clause, BSD-3-Clause,
   Apache-2.0. The project's own license is MIT (`LICENSE`), which this check
   does not examine.
3. **`main.yaml` removed.** The scaffold's workflow (semantic PR, build,
   spell check) is replaced by purpose-built workflows that arrive with the
   auth work.
4. **Local gates.** `make spell` and `make licenses` added. The license
   target mirrors the workflow's allow-list and skip list exactly.
5. **Docs.** Architecture §13 rewritten for the interim CI; §16 item 3,
   workflow §4/§5/§6, the testing standard, `.greptile/rules.md` and the
   threat model's tag-pinning finding updated to match.

## 2. Business justification

A red CI on every commit trains the eye to ignore red. The license check
was failing for a configuration reason, not a license reason, so it was
protecting nothing. `main.yaml` was the template's general pipeline, and I
would rather design the replacement once, around the auth work, than tune a
template I plan to discard.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- The replacement workflows. They land with the auth branch and their own CRQ.
- SHA pinning ([threat model §3](../../security/reports/firebase_and_ai_service_threat_model.md#3-findings)):
  done with the replacement workflows, so it is done once.
- The open Dependabot pull requests. #1, #2 and #4 bump workflows used only
  by `main.yaml` and are obsolete; #3 bumps the license check to v2; #5 bumps
  the Firebase packages.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | Fewer automated gates until the replacement lands: format, analysis, tests and spelling are enforced only by running the `make` targets before each commit |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Medium for the interim period. A commit that skips the local
gates reaches `main` unchecked. While I am the only committer that risk is
mine to manage, and the definition of done lists every target.

**Rollback plan:** restore `main.yaml` from `ea2da39` and revert the
license-check change. Minutes.

**Branch protection:** with no build workflow there are no status checks to
require. The `main` ruleset protects against deletion and force pushes now;
required status checks are added when the replacement workflows exist.

## 6. Implementation plan

1. Ran the license check locally with `very_good_cli` to see what the
   workflow would report once it could resolve: 5 packages outside the
   allow-list.
2. Traced each to the dependency that brings it in (§1 table).
3. Set `flutter_version` and `skip_packages` in the workflow, with the reason
   beside the list.
4. Removed `main.yaml`, added `make spell` and `make licenses`, and updated
   every document that described the old CI.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make licenses` (same settings as the workflow) | Pass — 252 licenses from 249 packages, all allowed |
| `make spell` | Pass — 27 files, 0 issues |
| `license_check.yaml` in CI | Confirmed on the first push that touches `pubspec.yaml` or `pubspec.lock` |
| Manual run | N/A — no app code changed |
| Certification | 2026-10-27 — Theo (CI and documentation change) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` during the hackathon | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — interim period ends with the replacement workflows |
| Compliance Officer | License compliance | Covered by CTO | 2026-10-27 | Approved — skipped packages never ship in a build |
| Clinical Reviewer | — | N/A — no clinical impact | — | — |
| Lead Designer | — | N/A — no UI change | — | — |

## 9. Post-implementation review

- If a Linux target is ever added, `dbus`, `geoclue` and `gsettings` must
  come off the skip list and be assessed: MPL-2.0 is file-level copyleft.
- If `geolocator` is removed (the alert design never locates patients),
  `geoclue` and `gsettings` disappear; `dbus` remains through notifications.

## 10. Related records

- Architecture: [`mobile_architecture.md` §13](../../architecture/reports/mobile_architecture.md#13-cicd)
- Previous CRQ: [CRQ-0002](./CRQ-0002-firebase-connection-and-greptile-review-context.md)
