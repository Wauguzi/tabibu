# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0008 |
| Title | Production APK workflow: quality gates on every pull request, then a signed APK to Firebase App Distribution |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

1. **`.github/workflows/prod_apk.yaml`**, on every pull request to `main`.
   This is the replacement for `main.yaml` promised in CRQ-0003.

   | Stage | Steps | Runs when |
   |---|---|---|
   | Quality gates | Format check, code generation, `flutter analyze`, bloc lint, unit and widget tests | Every PR |
   | Release | Decode the keystore, build the obfuscated `production` APK, keep the debug symbols 90 days, upload Dart symbols to Crashlytics, send the APK to the `internal-production` App Distribution group | When the signing secrets are present |

   Hardening, compared with a typical Flutter release workflow:
   - Every `uses:` is pinned to a commit SHA. Each SHA was checked against
     its release tag, and each is the action's latest release.
   - Secrets reach a step only through `env:`, never as `${{ }}` inside a
     `run:` script, so a value can never be parsed as shell.
   - The keystore is decoded with `base64` in a `run:` step rather than a
     third-party action, so no extra code handles it. It and the service
     account file go to `$RUNNER_TEMP` and are deleted in an `always()` step.
   - Signing goes through the `ANDROID_KEYSTORE_*` variables that
     `android/app/build.gradle.kts` and the fastlane lane already read. No
     `key.properties` is written, and CI and fastlane share one set of
     secret names.
   - `CAN_SIGN` gates the release stage. GitHub passes no secrets to
     Dependabot or fork PRs, and secrets cannot appear in `if:`. Those PRs
     still run every quality gate instead of failing on an empty keystore.
   - `permissions: contents: read`, `persist-credentials: false`, a
     45-minute timeout, and superseded runs cancelled.
   - The Firebase CLI is pinned to the same version as the Makefile.
   - The Android Firebase app id is written into the workflow, not stored as
     a secret: it is the public `mobilesdk_app_id` already in
     `google-services.json`.
2. **Dart SDK floor lowered to `^3.12.2`; Flutter to `^3.47.8`.** The code
   generators run on the `analyzer` package (12.1.0, held there by
   `freezed 3.2.6-dev.1`), which cannot parse Dart 3.13 primary constructors
   (`const new(...)`) in the scaffold. `make gen` failed on every file. With
   the language version at 3.12 and the scaffold's constructors written
   conventionally, code generation, analysis and tests pass. The toolchain
   itself is unchanged (Flutter 3.47.8, Dart 3.13.7).
3. **Format check skips `lib/firebase_options.dart`.** It is FlutterFire
   output, regenerated as a whole, and the 3.12 formatter style differs from
   the one it was generated with. Spell check already skips it.
4. **Spell check.** The dictionary is sorted, with the new terms added.
   Action references (`uses: owner/repo@sha`) are skipped by pattern: one
   action's repository name misspells GitHub, which cspell forbids and which
   is not ours to rename.
5. **Docs:** architecture §2, §13 and §16 item 3; workflow §4 step 8 and §5;
   the threat model's tag-pinning finding; a Greptile rule on secrets in
   workflows; the Makefile's `bloc-lint` comment, which named the removed
   workflow.

## 2. Business justification

Until now, no pull request was checked by CI: every gate was a `make` target
that only worked if I remembered to run it. The auth branch is the first
branch with real code, and Greptile's 5/5 bar is worth more when the PR's
checks are green as well. A signed APK in App Distribution on every PR gives
judges and testers an installable build without a store listing.

**Alternatives considered:**
- **Workflow dependency lockfiles** (`.github/workflows/actions.lock`) are
  GitHub's successor to SHA pinning, but are in public preview for
  Enterprise Cloud only. SHA pinning stays.
- **Workload Identity Federation instead of a service account key.** It
  removes the long-lived JSON key, which is the strongest option. It needs a
  pool and provider in Google Cloud, and App Distribution would then read a
  credentials file rather than the key's content. Deferred (§9).
- **Building on `push` to `main` as well.** Every change reaches `main`
  through a PR that already built, so a second build adds only cost.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- An iOS workflow; the `ios beta` lane (CRQ-0005) covers TestFlight.
- Spell check and secret scanning in CI; both stay local (`make spell`,
  `make secrets`).
- Upgrading the code generators (`freezed` 4, `analyzer` 14), which would
  allow the 3.13 floor again.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | The release keystore and a Firebase service account key are stored as repository secrets; handling in §1 item 1 |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low. The workflow only reads the repository, and the release
stage runs only for PRs from this repository.

**Repository secrets** (Settings → Secrets and variables → Actions):

| Secret | Value |
|---|---|
| `RELEASE_KEYSTORE` | The upload keystore, base64-encoded (`make base64 FILE=<path>`) |
| `ANDROID_KEYSTORE_ALIAS` | `tabibu` |
| `ANDROID_KEYSTORE_PASSWORD` | The keystore password |
| `ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD` | The key password; with a PKCS12 keystore, the same as the keystore password |
| `CREDENTIAL_FILE_CONTENT` | A service account's JSON key, with **Firebase App Distribution Admin** and **Firebase Crashlytics Admin** |

GitHub masks secrets by exact match, so a JSON key is masked less reliably
than a single value. No step prints it.

**Before the release stage can pass:** create the `internal-production`
group in Firebase → App Distribution → Testers & Groups.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Ported a working Flutter release workflow and adapted it as in §1 item 1.
2. Confirmed each action SHA against its tag through the GitHub API.
3. Ran every quality-gate step locally; found and fixed the code-generation
   failure (§1 item 2).
4. Checked GitHub's documentation on secrets in conditionals, Dependabot and
   fork PRs, script injection and runner sizes; Firebase's documentation on
   symbol upload and App Distribution roles; and Flutter's own Gradle
   version checker.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `actionlint` on every workflow | Pass, after `find -print0 \| xargs -0` in the format step |
| Action SHAs against tags | All 6 match, all at their latest release |
| Format step, as CI runs it | Pass — 15 files, 0 changed |
| `make gen` | Pass on `^3.12.2`; failed on `^3.13.0` (analyzer 12.1.0) |
| `flutter analyze lib test` | No issues |
| `make bloc-lint` | 0 issues, 438 files |
| `flutter test --coverage` | 8 passed |
| `make spell` | Pass — 63 files, 0 issues |
| Flutter 3.47.8 Gradle floors (`DependencyVersionChecker.kt`) | Java 17 required (the workflow uses 17); Gradle 9.0.0, AGP 8.12.0 pass; KGP 2.2.10 is above the 2.0.0 error floor but below the 2.2.20 warning floor |
| Release stage end to end | Not yet: needs the §5 secrets and group; the first PR run is the test |
| Certification | 2026-10-27 — Theo (CI and SDK floor; scaffold constructors only) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — secrets through `env:` only, removed in `always()` |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Record the first PR run here, release stage included.
- Raise the Kotlin Gradle plugin to 2.2.20 or later to clear Flutter's
  warning.
- Move from the service account key to Workload Identity Federation after
  the hackathon.
- Restore the Dart `^3.13` floor once the generators' `analyzer` supports it.

## 10. Related records

- Previous CRQ: [CRQ-0007](./CRQ-0007-secrets-handling-for-model-api-keys.md)
- Replaces the workflow removed in [CRQ-0003](./CRQ-0003-interim-ci-license-check-fix-and-main-workflow-removal.md)
- Release lanes and the shared secret names: [CRQ-0005](./CRQ-0005-fastlane-release-lanes.md)
