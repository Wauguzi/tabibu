# Contributing to Tabibu

Thank you for your interest in Tabibu. It is a Flutter app for patients, doctors and
pathologists, backed by Firebase. AI prepares pathology pre-reads and outbreak alert drafts,
and a qualified person always decides.

## Before judging: issues, not pull requests

Tabibu is a sole-author hackathon entry until judging closes on 4 November 2026. Until then:

- **Bug reports and suggestions are welcome.** Open an issue with the
  [bug report](https://github.com/Wauguzi/tabibu/issues/new?template=bug_report.yml) or
  [feature request](https://github.com/Wauguzi/tabibu/issues/new?template=feature_request.yml)
  form.
- **Pull requests from others open after judging.** I will close earlier ones with thanks, so
  the entry stays my own work.
- **Security vulnerabilities** never go in an issue: report them privately, as
  [`SECURITY.md`](SECURITY.md) describes.

Everyone taking part follows the [code of conduct](CODE_OF_CONDUCT.md).

## Reporting a problem

Say which role you were using (patient, doctor or pathologist), the platform and the app
version, the language (English or Kiswahili), and the steps to reproduce it.

**Never include real patient information**: no names, phone numbers, results, or images of
slides or smears. Use a test account and made-up data, and blur anything personal in a
screenshot.

## Working on the code

The rules every change is held to are in [`AGENTS.md`](AGENTS.md); the ones that matter most:

- The app talks only to Firebase. No model SDK, model endpoint, raw HTTP client or API key goes
  under `lib/` or into `pubspec.yaml`.
- No credential goes anywhere in the repository.
- AI output reaches a person only through a human approval.
- Every user-visible string goes in both `lib/l10n/arb/app_en.arb` and `app_sw.arb`.

Read these before changing an area:

| Area | Read |
|---|---|
| Architecture, layering, security | [`mobile_architecture.md`](docs/architecture/reports/mobile_architecture.md) |
| Design system and copy | [`mobile_design_system.md`](docs/design/reports/mobile_design_system.md) |
| Workflow and definition of done | [`mobile_workflow.md`](docs/workflow/reports/mobile_workflow.md) |
| Threats and the clinical-safety rules | [threat model](docs/security/reports/firebase_and_ai_service_threat_model.md) |
| Why something is the way it is | [`docs/crq/reports/`](docs/crq/reports/) |

### Setting up

You need the Flutter version in `pubspec.yaml`. Then:

```sh
flutter pub get
make gen        # generated models, routes, injectables and assets
flutter run --flavor development --target lib/main_development.dart
```

### Before a pull request

Run these and fix every finding:

```sh
make fmt
make analyze
make bloc-lint
make test
make spell      # add genuine new terms to .github/cspell.json
make secrets
```

Then:

1. Work on a branch, with a change record for each change it carries (copy
   [the CRQ template](docs/crq/templates/CRQ_TEMPLATE.md)) and the `pubspec.yaml` version
   bumped. The pull request lists every record.
2. Write the title in [Conventional Commits](https://www.conventionalcommits.org/) form, for
   example `feat(auth): D3 phone field`, and the description from the
   [pull request template](.github/PULL_REQUEST_TEMPLATE.md), answering its clinical-safety
   questions.
3. Greptile reviews every pull request. It merges at a 5/5 confidence score, with every
   finding fixed or answered.

By contributing, you agree that your work is released under the [MIT License](LICENSE).
