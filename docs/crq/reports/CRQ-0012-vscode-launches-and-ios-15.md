# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0012 |
| Title | VS Code launch configurations with the App Check debug token; iOS 15.0 and Swift Package Manager |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

1. **`.vscode/launch.json`**: development, staging, production, two
   release configurations and two test configurations.
   - The three debug configurations read the App Check debug token with
     `--dart-define-from-file=build/app_check_defines.json`. A
     `preLaunchTask` writes that file from the Keychain
     (`make app-check-defines`, owner-only permissions, under the ignored
     `build/`), and a `postDebugTask` deletes it. A launch configuration
     cannot read the Keychain itself, and an environment variable would
     leave the token in shell profiles (CRQ-0010).
   - The release configurations pass `--release` in `toolArgs`. Flutter's
     debug adapter detects release mode only there; with `--release` in
     `args` it still starts the app paused and waits for a debugger that a
     release build never offers.
   - They never receive the debug token.
2. **`.vscode/tasks.json`** with the two tasks; tracked, like
   `launch.json` (`.gitignore`).
3. **iOS deployment target 13.0 → 15.0** (`make pods-ios-target`).
   Firebase's Apple SDKs require 15.0, and the build failed below it.
4. **Swift Package Manager.** The first iOS build migrated the project:
   plugin packages in the Xcode project and the `development` scheme, the
   `MinimumOSVersion` key dropped from `AppFrameworkInfo.plist` (the
   deployment target now governs), `.build/` and `.swiftpm/` ignored, and
   `Package.resolved` committed. No `Podfile` was generated: every current
   plugin resolves through Swift Package Manager. The `staging` and
   `production` schemes migrate on their first build.

## 2. Business justification

Launching from the editor must behave like `make run-dev`, or App Check
silently stops verifying during development. The release configurations
are how a release build is checked on a device before it ships.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** local release signing for Android
(`android/key.properties`, ignored, pointing at the upload keystore); iOS
release signing, which needs the Apple Developer account; registering the
`.dev` and `.stg` iOS bundle ids in Firebase (CRQ-0005).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | Affected | The debug token is written to an owner-only file under `build/` for the length of a debug session |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low.

**Rollback plan:** revert the commit. Reverting the iOS changes also
reverts the Swift Package Manager migration; the next iOS build redoes it.

## 6. Implementation plan

1. Compared the launch configurations with `make run-dev`; added the token
   tasks.
2. Read Flutter's debug adapter (`flutter_adapter.dart`): it runs
   `flutter run … <toolArgs> --target <program> <args>`, so `args` reach
   `flutter run`, but release and profile mode are read from `toolArgs`
   only.
3. Raised the iOS target and built the development flavor for iOS.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make app-check-defines` | File written, `-rw-------`, 36-character token; ignored by git |
| `make app-check-defines-clean` | File removed |
| `flutter build ios --flavor development --debug --no-codesign` with the defines file | Built `Runner.app`; Swift Package Manager migration applied |
| cspell on `launch.json`, `tasks.json`, `Makefile` | Pass |
| `Launch development` on a device | Not yet: my first run |
| Certification | 2026-10-27 — Theo (tooling and project settings) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — owner-only, ignored, removed after each session |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- On the first `Launch development`, confirm the log shows Remote Config
  values and no App Check debug-token message asking to register a new
  token.
- Commit the `staging` and `production` scheme migrations when they
  happen.

## 10. Related records

- Previous CRQ: [CRQ-0011](./CRQ-0011-remote-config-at-startup.md)
- App Check debug token: [CRQ-0010](./CRQ-0010-app-check-activation.md)
