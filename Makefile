# Day-to-day commands. docs/workflow/reports/mobile_workflow.md §6 is the
# order they run in before a commit: fmt, analyze, bloc-lint, test.

gen:
		dart run build_runner build --delete-conflicting-outputs

gen-watch:
		dart run build_runner watch --delete-conflicting-outputs

l10n:
		flutter gen-l10n

fmt:
		dart fix --apply && dart format lib test

analyze:
		flutter analyze lib test

# The same check CI runs through very_good_workflows' run_bloc_lint.
bloc-lint:
		dart pub global activate bloc_tools > /dev/null
		dart pub global run bloc_tools:bloc lint .

test:
		flutter test --coverage --reporter=expanded

test-randomize:
		flutter test --coverage --reporter=expanded \
		    --test-randomize-ordering-seed=random

run-dev:
		flutter run --flavor development --target lib/main_development.dart

run-web:
		flutter run -d chrome --target lib/main_development.dart

.PHONY: gen gen-watch l10n fmt analyze bloc-lint test test-randomize run-dev run-web
