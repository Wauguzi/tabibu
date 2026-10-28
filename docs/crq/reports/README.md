# CRQ reports

Filed under [`../templates/CRQ_TEMPLATE.md`](../templates/CRQ_TEMPLATE.md).
A CRQ is due for any non-trivial change, and always for a change to the
security rules, the AI service's prompts, models or thresholds, anything a
patient reads, or the alert path.

| CRQ | Title | Date | Status |
|---|---|---|---|
| [CRQ-0001](./CRQ-0001-bootstrap-and-engineering-docs-baseline.md) | Project bootstrap, dependency baseline, and the engineering documentation baseline | 2026-10-27 | Implemented |
| [CRQ-0002](./CRQ-0002-firebase-connection-and-greptile-review-context.md) | Connect Firebase for Android and iOS, and give Greptile the repository's review context | 2026-10-27 | Implemented — rules must deploy before the first seeded record |
| [CRQ-0003](./CRQ-0003-interim-ci-license-check-fix-and-main-workflow-removal.md) | Interim CI: fix the license check for Flutter, and remove the scaffold's main workflow | 2026-10-27 | Implemented — replacement workflows due with the auth work |
| [CRQ-0004](./CRQ-0004-codeowners-pr-template-labels-and-merge-bar.md) | CODEOWNERS, the pull request template, the label taxonomy, and a 5/5 Greptile merge bar | 2026-10-27 | Implemented — labels and rulesets applied and verified |
| [CRQ-0005](./CRQ-0005-fastlane-release-lanes.md) | Fastlane release lanes for TestFlight and the Play Store internal track | 2026-10-27 | Implemented — first runs wait on store accounts |
| [CRQ-0006](./CRQ-0006-makefile-targets-and-repo-wide-spell-check.md) | Full Makefile command set, including Firebase rules, indexes and Storage; repository-wide spell check | 2026-10-27 | Implemented |
| [CRQ-0007](./CRQ-0007-secrets-handling-for-model-api-keys.md) | Secrets handling for the model API keys: Keychain for local runs, server-side stores in production, scanning before a push | 2026-10-27 | Implemented — scanning and key storage completed by hand |
| [CRQ-0008](./CRQ-0008-production-apk-workflow.md) | Production APK workflow: quality gates on every pull request, then a signed APK to Firebase App Distribution | 2026-10-27 | Implemented — release stage awaits the secrets |
| [CRQ-0009](./CRQ-0009-crashlytics-error-reporting.md) | Crashlytics error reporting in bootstrap: framework, platform and bloc errors, release builds only | 2026-10-27 | Implemented |
| [CRQ-0010](./CRQ-0010-app-check-activation.md) | App Check activated in bootstrap, with a Keychain-held debug token; enforcement deferred | 2026-10-27 | Implemented — enforcement awaits Play Console and Apple Developer |
| [CRQ-0011](./CRQ-0011-remote-config-at-startup.md) | Remote Config at startup: in-app defaults, a bounded fetch, and the force-update parameters | 2026-10-27 | Implemented — the gate arrives with the auth branch |
| [CRQ-0012](./CRQ-0012-vscode-launches-and-ios-15.md) | VS Code launch configurations with the App Check debug token; iOS 15.0 and Swift Package Manager | 2026-10-27 | Implemented |
| [CRQ-0013](./CRQ-0013-muse-code-agent.md) | Muse Code as a second coding agent: `make muse`, `AGENTS.md`, and a credit floor | 2026-10-27 | Implemented |
| [CRQ-0014](./CRQ-0014-identity-data-model.md) | Identity data model: patients, practitioners, the public directory and the bundled Nairobi facility list | 2026-10-27 | Design approved — code lands across `feat/auth` |
| [CRQ-0015](./CRQ-0015-nairobi-facility-data.md) | Nairobi facility data: the Ministry of Health's 1,447 facilities, 17 sub-counties and 47 counties as app assets, with a geohash service | 2026-10-27 | Implemented |
| [CRQ-0016](./CRQ-0016-identity-functions-and-rules.md) | Identity functions, Firestore and Storage rules, and their emulator tests | 2026-10-27 | Implemented — deploy after review |
| [CRQ-0017](./CRQ-0017-foundations-theme-and-swahili.md) | Foundations: counter removed, Swahili replaces Spanish with the localizations-delegates fix, and the design-system theme | 2026-10-27 | Implemented — palette provisional |
| [CRQ-0018](./CRQ-0018-demo-seed-and-google-sign-in-on-ios.md) | Demo seed (one account per role, an alert approver, clinic patients) and the iOS URL scheme for Google sign-in | 2026-10-27 | Implemented on the emulators — live seed pending |
| [CRQ-0019](./CRQ-0019-identity-models-errors-and-di.md) | Identity models, facility reference data, enums, translated errors, and dependency injection | 2026-10-27 | Implemented |
| [CRQ-0020](./CRQ-0020-session-layer-auth-and-encrypted-cache.md) | Session layer: auth datasource and helper, RoleHelper, the encrypted cache through DBHelper, and bootstrap wiring | 2026-10-27 | Implemented |
| [CRQ-0021](./CRQ-0021-launcher-icons.md) | Launcher icons on Android and iOS: the missing iOS icon set, and a guard against 16-bit logos | 2026-10-27 | Implemented |
| [CRQ-0022](./CRQ-0022-notification-service.md) | Notification service: three channels, a kept Android icon, iOS presentation, and a show that never throws | 2026-10-27 | Implemented |
| [CRQ-0023](./CRQ-0023-android-toolchain.md) | Android builds run again: Kotlin 2.3.20, Gradle 9.3.1, compileSdk 37, one launcher background colour, and no template icons on dev and staging | 2026-10-27 | Implemented |
| [CRQ-0024](./CRQ-0024-rasp-service.md) | Runtime protection with freeRASP: tiered threats, translated notices, screen-capture blocking, and obfuscated release builds | 2026-10-27 | Implemented — Play App Signing hash and iOS Team ID pending |
| [CRQ-0025](./CRQ-0025-release-drafts.md) | Draft a release on every merge to main, tagged with the pubspec version; publish and mark Latest with one command | 2026-10-27 | Implemented — first run on the first merge |
| [CRQ-0026](./CRQ-0026-specialties-and-license-files.md) | Practitioner specialties as a list, one or two license files, a required photo, and an information-security header on the Firestore rules | 2026-10-28 | Implemented — rules and functions deploy after review |
| [CRQ-0027](./CRQ-0027-auth-bloc-and-router.md) | Auth, sign-up and theme blocs; typed router with a role-claim guard; app shell; analytics, connectivity, force-update and push-token services | 2026-10-28 | Implemented — screens in brief 04 |
| [CRQ-0028](./CRQ-0028-fireworks-api-key.md) | Store the Fireworks API key the same way as the other model keys; replace one key at a time | 2026-10-28 | Implemented — key stored |
| [CRQ-0029](./CRQ-0029-modal-token-pair.md) | Keep the Modal token pair in the Keychain and run the Modal CLI through make | 2026-10-28 | Implemented — token stored, workspace confirmed |
| [CRQ-0030](./CRQ-0030-design-tokens-and-shared-widgets.md) | Design tokens from the design system, the shared widget library and its assets; AI draft and signed told apart by structure | 2026-10-28 | Implemented |
| [CRQ-0031](./CRQ-0031-file-picker-service.md) | Pick the sign-up photo and licence files as bytes, with the size limits checked on the device | 2026-10-28 | Implemented |

Naming convention: `CRQ-<4-digit-number>-<short-slug>.md`, numbered
sequentially from `0001`.
