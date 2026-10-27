# Working on Tabibu

Rules for coding agents working in this repository. They apply to every task, whatever the brief
says.

## What Tabibu is

A Flutter app for patients, doctors and pathologists, backed by Firebase. AI prepares pathology
pre-reads and outbreak alert drafts; a qualified person always decides. Read before changing
anything in an area:

| Area | Read |
|---|---|
| Conventions a diff does not show | `.greptile/rules.md` (the review rules every change is held to) |
| Architecture, layering, startup, security | `docs/architecture/reports/mobile_architecture.md` |
| Design system and copy | `docs/design/reports/mobile_design_system.md` |
| Workflow, definition of done | `docs/workflow/reports/mobile_workflow.md` |
| Why something is the way it is | `docs/crq/reports/` (one record per change) |

## Hard rules

- **Never commit, amend, push or rewrite history.** Leave changes in the working tree; they are
  reviewed and committed by someone else.
- **The app talks only to Firebase.** No model SDK, model endpoint, raw HTTP client or API key
  under `lib/` or in `pubspec.yaml`.
- **No credential anywhere in the repository**: not in code, `--dart-define`, assets, Remote
  Config, fixtures or docs. Never print environment variables, and never read the Keychain.
- **AI output reaches a person only through a human approval.** Treat any change near drafts,
  reports, results or alerts as high risk and stop to ask rather than guess.
- **Name no other product, company project or repository** in code, comments, docs or commit-ready
  text, even when a brief points you at one for reference.
- **Do not add dependencies** unless the brief asks for one.
- **Do not edit** `.github/`, `.greptile/`, `firestore.rules`, `storage.rules`, `functions/`,
  signing or Firebase configuration, or anything under `docs/crq/` unless the brief says so.

## How code is written here

- Follow the patterns already in the codebase before inventing one: bloc for state, `getIt` and
  `injectable` for dependencies, `go_router` for navigation, `freezed` for models.
- A bloc never imports Flutter and never reaches Hive or Firestore directly.
- Every user-visible string goes in `lib/l10n/arb/app_en.arb` and its Swahili counterpart
  (`app_sw.arb`, which replaces the template's `app_es.arb`).
- Comments are lean: say why, never what. Records in `docs/crq/` carry the detail.
- Tests mirror `lib/` under `test/`, with `bloc_test` and `mocktail`.

## Before handing work back

Run these and fix every finding, including spelling (add genuine terms to `.github/cspell.json`):

```bash
make gen        # when models, routes or injectables changed
make fmt
make analyze
make bloc-lint
make test
make spell
```

Then report: the files changed, what each change does, anything left undone, and anything you
were unsure of.
