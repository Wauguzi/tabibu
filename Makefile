# Before a commit: fmt, analyze, bloc-lint, spell, test (docs/workflow/reports/mobile_workflow.md §6).

adb:
		adb logcat -s flutter

# The generator turns a 16-bit logo into a black iOS icon when it strips alpha (CRQ-0021).
icons:
		@bits=$$(sips -g bitsPerSample assets/icons/tabibu_logo.png | awk '/bitsPerSample/ {print $$2}'); \
		  test "$$bits" = "8" || { echo "assets/icons/tabibu_logo.png is $$bits-bit; export it as 8-bit PNG."; exit 1; }
		dart run flutter_launcher_icons

splash:
		dart run flutter_native_splash:create

gen:
		dart run build_runner build --delete-conflicting-outputs

gen-watch:
		dart run build_runner watch --delete-conflicting-outputs

l10n:
		flutter gen-l10n

# Same file set as the format check in prod_apk.yaml; change both together.
fmt:
		dart fix --apply
		find lib test -type f -name "*.dart" \
		    ! -path "lib/l10n/gen/*" ! -path "lib/gen/*" ! -name "firebase_options.dart" -print0 \
		    | xargs -0 dart format

commas:
		dart fix --apply

analyze:
		flutter analyze lib test

# The same check prod_apk.yaml runs in CI.
bloc-lint:
		dart pub global activate bloc_tools > /dev/null
		dart pub global run bloc_tools:bloc lint .

spell:
		npx --yes cspell@8 --no-progress \
		    "**/*.md" ".greptile/*" ".github/**/*" "fastlane/*" "scripts/*" "ai_service/*" .gitignore .gitleaks.toml \
		    Makefile Gemfile pubspec.yaml "lib/**/*.dart" "test/**/*.dart" \
		    firebase.json firestore.rules storage.rules "functions/src/*.ts" "test/firestore_rules/*.js"

# Same allow-list and skip list as .github/workflows/license_check.yaml; change both together.
licenses:
		dart pub global activate very_good_cli > /dev/null
		dart pub global run very_good_cli:very_good packages check licenses \
		    --allowed="MIT,BSD-3-Clause,BSD-2-Clause,Apache-2.0" \
		    --dependency-type="direct-main,transitive" \
		    --skip-packages="antlr4,pubspec_lock_parse,dbus,geoclue,gsettings"

# Scans committed history, then staged changes. Install: brew install gitleaks.
secrets:
		@command -v gitleaks >/dev/null 2>&1 || { echo "gitleaks not found: brew install gitleaks"; exit 1; }
		gitleaks git --redact --verbose .
		gitleaks git --redact --verbose --staged .

# Every release build obfuscates: freeRASP terminates a release binary without it (CRQ-0024).
apk:
		flutter build apk --flavor production --target lib/main_production.dart \
		    --obfuscate --split-debug-info=debug-symbols -vv

apk-release:
		flutter build apk --flavor production --release --target lib/main_production.dart \
		    --obfuscate --split-debug-info=debug-symbols -vv

dev-apk:
		flutter build apk --flavor development --target lib/main_development.dart \
		    --obfuscate --split-debug-info=debug-symbols -vv

aab:
		flutter build appbundle --flavor production --target lib/main_production.dart \
		    --obfuscate --split-debug-info=debug-symbols

aab-release:
		flutter build appbundle --flavor production --release --target lib/main_production.dart \
		    --obfuscate --split-debug-info=debug-symbols

# make base64 FILE=release.jks copies it as base64, for a CI secret.
base64:
		@test -n "$(FILE)" || { echo "Usage: make base64 FILE=<path>"; exit 1; }
		openssl base64 -in "$(FILE)" | tr -d '\n' | pbcopy

ipa:
		flutter build ipa --flavor production --release --target lib/main_production.dart \
		    --obfuscate --split-debug-info=debug-symbols

web-release:
		flutter build web --release --target lib/main_production.dart

sha1:
		keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey \
		    -storepass android -keypass android

rdr:
		flutter run --flavor development --target lib/main_development.dart --release

rpr:
		flutter run --flavor production --target lib/main_production.dart --release

# Passes the App Check debug token from the Keychain, if stored (make app-check-token).
run-dev:
		flutter run --flavor development --target lib/main_development.dart \
		    --dart-define=APP_CHECK_DEBUG_TOKEN="$$(security find-generic-password -a "$$USER" -s $(KEYCHAIN_APP_CHECK) -w 2>/dev/null)"

run-web:
		flutter run -d chrome --target lib/main_development.dart

clean-pods:
		rm -f ios/Podfile.lock && rm -rf ios/Pods

pods:
		cd ios && pod install --repo-update --verbose && cd ..

pods-clean:
		rm -rf ios/Pods
		rm -f ios/Podfile.lock
		rm -rf ios/.symlinks
		pod cache clean --all --verbose || true
		cd ios && pod deintegrate --verbose && cd ..

pods-no-update:
		cd ios && pod install && cd ..

pods-no-cdn:
		cd ios && pod install --no-repo-update && cd ..

# Installs fastlane into vendor/bundle; run once after cloning or after editing the Gemfile.
fastlane-setup:
		bundle config set --local path vendor/bundle
		bundle install

# Model API keys live in the macOS Keychain, never in a file (CRQ-0007).
KEYCHAIN_BASETEN := tabibu-baseten-api-key
KEYCHAIN_META := tabibu-meta-api-key
KEYCHAIN_APP_CHECK := tabibu-app-check-debug-token
KEYCHAIN_SEED := tabibu-seed-password

# Each prompt asks twice and shows nothing as you paste; re-run to replace a key.
keys-add:
		@echo "Baseten API key (paste, Enter, then paste again to confirm):"
		@security add-generic-password -U -a "$$USER" -s $(KEYCHAIN_BASETEN) -w
		@echo "Meta Model API key (paste, Enter, then paste again to confirm):"
		@security add-generic-password -U -a "$$USER" -s $(KEYCHAIN_META) -w
		@$(MAKE) --no-print-directory keys-check

# Confirms each key is stored, showing only its length and last four characters.
keys-check:
		@for s in $(KEYCHAIN_BASETEN) $(KEYCHAIN_META) $(KEYCHAIN_APP_CHECK); do \
		  k="$$(security find-generic-password -a "$$USER" -s "$$s" -w 2>/dev/null)"; \
		  if [ -n "$$k" ]; then printf '%-30s stored  (%s chars, ends …%s)\n' "$$s" "$${#k}" "$${k: -4}"; \
		  else printf '%-30s MISSING\n' "$$s"; fi; \
		done

# Creates an App Check debug token, stores it in the Keychain and copies it to the clipboard
# for Firebase → App Check → Apps → ⋮ → Manage debug tokens. Re-running replaces it.
app-check-token:
		@t="$$(uuidgen)"; \
		security add-generic-password -U -a "$$USER" -s $(KEYCHAIN_APP_CHECK) -w "$$t" && \
		printf '%s' "$$t" | pbcopy && \
		echo "Stored as $(KEYCHAIN_APP_CHECK) and copied; register it for the Android and iOS apps."

# Copies the stored token again without printing it.
app-check-token-copy:
		@security find-generic-password -a "$$USER" -s $(KEYCHAIN_APP_CHECK) -w | tr -d '\n' | pbcopy && \
		echo "Copied $(KEYCHAIN_APP_CHECK)."

# VS Code's debug launches read the token from this file (ignored under build/); removed after each session.
APP_CHECK_DEFINES := build/app_check_defines.json
app-check-defines:
		@mkdir -p build
		@umask 077; printf '{"APP_CHECK_DEBUG_TOKEN":"%s"}\n' \
		    "$$(security find-generic-password -a "$$USER" -s $(KEYCHAIN_APP_CHECK) -w 2>/dev/null)" > $(APP_CHECK_DEFINES)

app-check-defines-clean:
		@rm -f $(APP_CHECK_DEFINES)

# Starts Muse Code with only the Meta key in its environment, from the Keychain (CRQ-0013).
muse:
		@command -v muse >/dev/null 2>&1 || { echo "muse not found: curl -fsSL https://dev.meta.ai/install.sh | sh"; exit 1; }
		@k="$$(security find-generic-password -a "$$USER" -s $(KEYCHAIN_META) -w 2>/dev/null)"; \
		test -n "$$k" || { echo "Meta key missing: make keys-add"; exit 1; }; \
		META_API_KEY="$$k" muse $(ARGS)

# make ai-dev CMD="<command>" runs it with both keys in its environment only.
ai-dev:
		$(if $(CMD),,$(error Usage: make ai-dev CMD="<command>"))
		@BASETEN_API_KEY="$$(security find-generic-password -a "$$USER" -s $(KEYCHAIN_BASETEN) -w)" \
		META_API_KEY="$$(security find-generic-password -a "$$USER" -s $(KEYCHAIN_META) -w)" \
		$(CMD)

# make pods-ios-target IOS_MIN=16.0 (Firebase needs 15.0+). The Podfile exists once an iOS build has run.
IOS_MIN ?= 15.0
pods-ios-target:
		sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9][0-9.]*;/IPHONEOS_DEPLOYMENT_TARGET = $(IOS_MIN);/g' \
		    ios/Runner.xcodeproj/project.pbxproj
		if [ -f ios/Podfile ]; then sed -i '' "s/^platform :ios, '[0-9.]*'/platform :ios, '$(IOS_MIN)'/" ios/Podfile; fi
		@echo "iOS deployment target → $(IOS_MIN)"

# Rebuilds assets/data/ from the Ministry of Health exports (RTF or text), e.g.
# make facilities FACILITIES=~/Downloads/nairobi_facilities_moh.rtf COUNTIES=~/Downloads/kenya_counties_moh.rtf
facilities:
		@test -f "$(wildcard $(FACILITIES))" -a -f "$(wildcard $(COUNTIES))" || { echo "usage: make facilities FACILITIES=<file> COUNTIES=<file>"; exit 1; }
		@mkdir -p build/facilities
		textutil -convert txt -output build/facilities/facilities.txt "$(wildcard $(FACILITIES))"
		textutil -convert txt -output build/facilities/counties.txt "$(wildcard $(COUNTIES))"
		dart run scripts/facilities/build_facility_assets.dart build/facilities/facilities.txt build/facilities/counties.txt assets/data
		cp assets/data/*.json functions/data/

test:
		flutter test --coverage --reporter=expanded

test-randomize:
		flutter test --coverage --reporter=expanded \
		    --test-randomize-ordering-seed=random

test-watch:
		flutter test --reporter=expanded

COVERAGE_MIN ?= 25
coverage:
		flutter test --coverage --reporter=compact
		@python3 -c "import re,sys; d=re.findall(r'DA:\d+,(\d+)', open('coverage/lcov.info').read()); \
		h=sum(1 for x in d if x != '0'); t=len(d); p=100*h//t if t else 0; \
		print(f'Coverage: {h}/{t} = {p}%  (threshold: $(COVERAGE_MIN)%)'); sys.exit(0 if p >= $(COVERAGE_MIN) else 1)"

# Pinned so every machine runs the same CLI; npx caches it after the first run.
FIREBASE := npx --yes firebase-tools@15.31.0
PROJECT := tabibu-86ea2

# firebase-tools 15 needs Java 21+ for the emulators and reads `java` from PATH, not JAVA_HOME.
JDK21_BIN = $(shell \
	if java -version 2>&1 | head -1 | grep -qE '"(2[1-9]|[3-9][0-9])'; then \
	  dirname "$$(command -v java)"; \
	elif [ -x "$$(brew --prefix openjdk@21 2>/dev/null)/libexec/openjdk.jdk/Contents/Home/bin/java" ]; then \
	  echo "$$(brew --prefix openjdk@21)/libexec/openjdk.jdk/Contents/Home/bin"; \
	fi)

define require_java21
	@test -x "$(JDK21_BIN)/java" || \
	  { echo "Java 21+ required by firebase-tools 15 (PATH java: $$(java -version 2>&1 | head -1))."; \
	    echo "  brew install openjdk@21   (keg-only is fine; this target finds it)"; exit 1; }
endef

emulators:
		$(require_java21)
		PATH="$(JDK21_BIN):$$PATH" $(FIREBASE) emulators:start \
		    --only auth,firestore,storage,functions --project $(PROJECT)

# Firestore and Storage rules tests against fresh emulators; the suite clears their data.
rules-test:
		@command -v npx >/dev/null 2>&1 || \
		  { echo "Node.js (npx) not found. Install Node 22+."; exit 1; }
		$(require_java21)
		@! lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null 2>&1 || \
		  { echo "Port 8080 (Firestore emulator) is taken; stop that emulator first."; exit 1; }
		@! lsof -nP -iTCP:9199 -sTCP:LISTEN >/dev/null 2>&1 || \
		  { echo "Port 9199 (Storage emulator) is taken; stop that emulator first."; exit 1; }
		cd test/firestore_rules && npm install --silent
		PATH="$(JDK21_BIN):$$PATH" $(FIREBASE) emulators:exec --only firestore,storage --project demo-tabibu \
		    "cd test/firestore_rules && node_modules/.bin/mocha --timeout 20000 '*.test.js'"

# Lint and build as a deploy would, then the handler suites against Firestore and Auth emulators
# on a demo- project, which cannot reach the live one.
functions-test:
		$(require_java21)
		cd functions && npm install --silent && ./node_modules/.bin/eslint src \
		    && ./node_modules/.bin/tsc -p tsconfig.build.json
		PATH="$(JDK21_BIN):$$PATH" $(FIREBASE) emulators:exec --only firestore,auth --project demo-tabibu \
		    "cd functions && npm test"

# Demo accounts, one per role (CRQ-0018). The password lives in the Keychain only.
seed-password:
		@security add-generic-password -U -a "$$USER" -s $(KEYCHAIN_SEED) -w

# Into running emulators (make emulators in another terminal).
seed-emulator:
		cd functions && npm install --silent && \
		  FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
		  FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199 \
		  SEED_PASSWORD="$$(security find-generic-password -a "$$USER" -s $(KEYCHAIN_SEED) -w)" \
		  ./node_modules/.bin/ts-node src/seed.ts

# Into the live project, through Application Default Credentials (gcloud auth application-default login),
# e.g. make seed-live CONFIRM=tabibu-86ea2 SEED_EMAIL_TEMPLATE='tabibu.demo+{role}@gmail.com'
seed-live:
		@test "$(CONFIRM)" = "$(PROJECT)" || { echo "usage: make seed-live CONFIRM=$(PROJECT)"; exit 1; }
		cd functions && npm install --silent && \
		  SEED_CONFIRM=$(CONFIRM) SEED_EMAIL_TEMPLATE="$(SEED_EMAIL_TEMPLATE)" \
		  SEED_PASSWORD="$$(security find-generic-password -a "$$USER" -s $(KEYCHAIN_SEED) -w)" \
		  ./node_modules/.bin/ts-node src/seed.ts --live

# The tag this commit would release: v + the pubspec.yaml version (CRQ-0025).
release-next:
		node scripts/next-release.cjs

# The release script's arithmetic and the wiring of the files that call it.
release-check:
		node --test scripts/*.test.cjs

# Publishes the draft the merge workflow left and marks it Latest: a draft cannot be marked Latest,
# so it happens here, in the same command. It asks which draft is ours rather than taking the first.
release-publish:
		@tag=$$(gh release list --limit 50 --json tagName,isDraft \
		          | node scripts/next-release.cjs --managed-draft); \
		  case "$$tag" in \
		    v*) ;; \
		    *) echo "No draft matching the release convention is open."; exit 1;; \
		  esac; \
		  gh release edit "$$tag" --draft=false --latest && \
		  echo "Published $$tag as the latest release."

deploy-rules:
		$(FIREBASE) deploy --only firestore:rules --project $(PROJECT)

deploy-functions:
		$(FIREBASE) deploy --only functions --project $(PROJECT)

deploy-indexes:
		$(FIREBASE) deploy --only firestore:indexes --project $(PROJECT)

deploy-storage:
		$(FIREBASE) deploy --only storage --project $(PROJECT)

deploy-hosting:
		$(FIREBASE) deploy --only hosting --project $(PROJECT)

.PHONY: adb icons splash gen gen-watch l10n fmt commas analyze bloc-lint spell licenses secrets \
	apk apk-release dev-apk aab aab-release base64 ipa web-release sha1 rdr rpr run-dev run-web \
	clean-pods pods pods-clean pods-no-update pods-no-cdn fastlane-setup keys-add keys-check app-check-token app-check-token-copy app-check-defines app-check-defines-clean muse ai-dev pods-ios-target facilities test test-randomize test-watch coverage \
	emulators rules-test functions-test seed-password seed-emulator seed-live \
	release-next release-check release-publish \
	deploy-rules deploy-functions deploy-indexes deploy-storage deploy-hosting
