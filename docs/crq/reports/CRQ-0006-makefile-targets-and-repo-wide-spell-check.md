# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0006 |
| Title | Full Makefile command set, including Firebase rules, indexes and Storage; repository-wide spell check |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

**Makefile.** 44 targets, grouped in the order the work happens:

| Group | Targets |
|---|---|
| Device and assets | `adb`, `icons`, `splash` |
| Code generation | `gen`, `gen-watch`, `l10n` |
| Quality gates | `fmt`, `commas`, `analyze`, `bloc-lint`, `spell`, `licenses` |
| Builds | `apk`, `apk-release`, `dev-apk`, `aab`, `aab-release`, `ipa`, `web-release` |
| Signing helpers | `base64 FILE=<path>`, `sha1` |
| Run | `rdr`, `rpr`, `run-dev`, `run-web` |
| CocoaPods | `clean-pods`, `pods`, `pods-clean`, `pods-no-update`, `pods-no-cdn`, `pods-ios-target` |
| Release | `fastlane-setup` |
| Tests | `test`, `test-randomize`, `test-watch`, `coverage` (`COVERAGE_MIN`, default 25) |
| Firebase | `emulators`, `rules-test`, `functions-test`, `deploy-rules`, `deploy-functions`, `deploy-indexes`, `deploy-storage`, `deploy-hosting` |

- Every build target names its flavor and entrypoint. A bare
  `flutter build apk` fails on a flavored Android project.
- The Firebase CLI is pinned (`firebase-tools@15.31.0`) and run through
  `npx`, so every machine runs the same version against `tabibu-86ea2`.
- The emulator targets locate Java 21+ (firebase-tools 15 requires it) even
  when the default `java` is older, and stop with install instructions when
  none is found.
- `rules-test` runs the Firestore **and** Storage emulators, and refuses to
  start if either port (8080, 9199) is already in use, because the suite
  clears the emulator's data.
- `pods-ios-target` sets the deployment target in the Xcode project and, once
  it exists, in `ios/Podfile`. Firebase needs iOS 15.0+, and the project is
  still at the scaffold's 13.0.
- **Deliberately not added:** a target that stages everything, commits with a
  fixed message and pushes. It would bypass the certification gate and the
  rule that I push my own commits.

**Spell check, repository-wide.**

- `make spell` now covers Markdown, `.greptile/`, `.github/`, `fastlane/`,
  `scripts/`, the `Makefile`, `Gemfile`, `pubspec.yaml`, and all Dart under
  `lib/` and `test/`, not Markdown alone.
- A root `.cspell.json` imports `.github/cspell.json`. Without it, cspell,
  including the editor's spell checker, never found the project dictionary,
  which is why the editor flagged words the dictionary already held.
- Generated files (`firebase_options.dart`, l10n and `flutter_gen` output,
  `*.g.dart`, `*.freezed.dart`, lock files) are excluded, and 6-digit hex
  colours are ignored by pattern. Fragments of API keys and colour codes are
  not words, and adding them to the dictionary would hide real typos.

## 2. Business justification

One command per routine task, identical on every machine, keeps the build
reproducible and the documentation honest: the docs name `make` targets, and
now every target they name exists. Deploying rules, indexes and Storage rules
as separate, pinned commands makes the security boundary a first-class
operation rather than a console click.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** `firestore.rules`, `storage.rules`,
`firestore.indexes.json`, `functions/` and `test/firestore_rules/`. The
Firebase targets are ready for them; until they exist, those targets fail with
a clear "not found" message.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | None in effect | Deploy targets exist; nothing is deployed by this change |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low. Targets run only when called.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Ported the Makefile target by target, in its established order, adapting
   each build target to Tabibu's flavors and each Firebase target to
   `tabibu-86ea2`, and adding Storage, emulator and hosting targets.
2. Dry-ran every target with `make -n`.
3. Widened `make spell`, added the root `.cspell.json`, excluded generated
   files and hex colours, and added the genuine terms to the dictionary.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make -n <target>` for all 44 targets | All resolve; `base64` stops by design without `FILE=` |
| `make spell` | Pass — 59 files, 0 issues |
| cspell without `--config` (how the editor runs it) | Pass — the root config is found |
| `pod` available | `/opt/homebrew/bin/pod` |
| Certification | 2026-10-27 — Theo (tooling; no app code changed) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | — | N/A — nothing deployed | — | — |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Run `make pods-ios-target` before the first iOS release build, and confirm
  the Podfile picks it up once Flutter generates it.
- Revisit `COVERAGE_MIN` when feature tests land; 25% is a floor, not a goal.

## 10. Related records

- Previous CRQ: [CRQ-0005](./CRQ-0005-fastlane-release-lanes.md)
