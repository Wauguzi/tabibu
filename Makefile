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

# cspell over every Markdown file, with the project dictionary.
spell:
		npx --yes cspell@8 --no-progress --config .github/cspell.json "**/*.md" ".greptile/*.md" ".github/*.md"

# The same check, allow-list and skip list as .github/workflows/license_check.yaml;
# change both together.
licenses:
		dart pub global activate very_good_cli > /dev/null
		dart pub global run very_good_cli:very_good packages check licenses \
		    --allowed="MIT,BSD-3-Clause,BSD-2-Clause,Apache-2.0" \
		    --dependency-type="direct-main,transitive" \
		    --skip-packages="antlr4,pubspec_lock_parse,dbus,geoclue,gsettings"

# Installs fastlane into vendor/bundle; run once after cloning or after editing the Gemfile.
fastlane-setup:
		bundle config set --local path vendor/bundle
		bundle install

test:
		flutter test --coverage --reporter=expanded

test-randomize:
		flutter test --coverage --reporter=expanded \
		    --test-randomize-ordering-seed=random

run-dev:
		flutter run --flavor development --target lib/main_development.dart

run-web:
		flutter run -d chrome --target lib/main_development.dart

.PHONY: gen gen-watch l10n fmt analyze bloc-lint spell licenses fastlane-setup test test-randomize run-dev run-web
