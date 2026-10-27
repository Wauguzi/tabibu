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

Naming convention: `CRQ-<4-digit-number>-<short-slug>.md`, numbered
sequentially from `0001`.
