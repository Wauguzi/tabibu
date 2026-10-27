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

Naming convention: `CRQ-<4-digit-number>-<short-slug>.md`, numbered
sequentially from `0001`.
