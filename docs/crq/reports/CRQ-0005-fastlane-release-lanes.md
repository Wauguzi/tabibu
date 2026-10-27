# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0005 |
| Title | Fastlane release lanes for TestFlight and the Play Store internal track |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

1. **`Gemfile` / `Gemfile.lock`** at the repository root, with fastlane
   2.241.2. Gems install into `vendor/bundle` (`make fastlane-setup`), not the
   system Ruby. The lock file lists Linux platforms as well as macOS, so a CI
   runner resolves the same versions.
2. **One `fastlane/` folder for both platforms**, written by hand:
   `fastlane init` refuses to run at the root of a Flutter project because the
   Xcode project sits in `ios/`.
   - `Appfile`: `com.tabibukenya.tabibu` for both platforms; Apple team ids
     from the environment.
   - `Fastfile`, two lanes:

     | Lane | Builds | Signs with | Uploads to |
     |---|---|---|---|
     | `ios beta` | `flutter build ipa`, `production` flavor, obfuscated | A temporary keychain, the distribution certificate and an App Store profile | TestFlight |
     | `android deploy` | `flutter build appbundle`, `production` flavor, obfuscated | The release keystore, through the environment variables `android/app/build.gradle.kts` already reads | Play Store, internal track |

3. **No secret is written to the repository or left on disk.** Every value is
   read from the environment. The Android lane hands signing to Gradle through
   environment variables instead of writing a `key.properties` file. The
   decoded certificate and keystore are deleted, and the keychain removed, in
   each lane's `ensure` block, whether the lane succeeds or fails.
4. **Paths are absolute from the repository root.** Fastlane runs lane code
   in `fastlane/` but actions from the root; resolving one root avoids a path
   that is right for one and wrong for the other.
5. **Android flavors share one application id.** `applicationIdSuffix` is
   empty for `staging` and `development` (it was `.stg` and `.dev`).
   `google-services.json` registers only `com.tabibukenya.tabibu`, and the
   Google services Gradle plugin fails the build for a package it does not
   list. The cost: the three Android flavors install over each other on one
   device. iOS keeps `.dev` and `.stg`, which the single
   `GoogleService-Info.plist` does not match, so Firebase in iOS development
   and staging builds runs against a mismatched bundle id until those apps are
   registered in Firebase.
6. `.gitignore` excludes `vendor/bundle/`, `.bundle/`, fastlane's generated
   output, and the `debug-symbols/` that obfuscated builds produce.

## 2. Business justification

The judges see a release pipeline, not only an app: the same commit builds,
signs and ships to both stores with one command, and the obfuscated symbols
are kept for crash reports. It also removes manual signing steps from the
last days of the build, when a mistake costs most.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- **A CI workflow that calls the lanes.** It arrives with the replacement
  workflows (CRQ-0003); the lanes are written so a workflow only sets the
  secrets in §5 and runs `bundle exec fastlane <platform> <lane>`.
- **Store accounts and listings.** Prerequisites listed in §5, not created by
  this change.
- **Firebase App Distribution**, a candidate third lane for judges who want
  to install a build without a store listing.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | Signing material handled by the lanes; see §1 item 3 |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low. Nothing runs until a person or a workflow calls a lane
with the secrets set.

**Prerequisites before a lane can succeed:**

| Platform | Needs |
|---|---|
| iOS | Apple Developer Program membership; an App Store Connect app record for `com.tabibukenya.tabibu`; an App Store Connect API key; a distribution certificate (.p12); an App Store provisioning profile |
| Android | A Play Console app record for `com.tabibukenya.tabibu`, with the **first AAB uploaded by hand** (the Play API cannot create an app); a service account with the Release manager role; the release keystore |

**Environment variables / GitHub secrets the lanes read:**

| Variable | Lane | Value |
|---|---|---|
| `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID` | `ios beta` | From App Store Connect → Users and Access → Integrations |
| `APP_STORE_CONNECT_KEY_CONTENT` | `ios beta` | The `.p8` key, base64-encoded |
| `IOS_DIST_CERT_P12_BASE64`, `IOS_DIST_CERT_PASSWORD` | `ios beta` | The distribution certificate exported from Keychain Access, base64-encoded, and its password |
| `APPLE_TEAM_ID`, `ITC_TEAM_ID` | `ios beta` | Developer team id; App Store Connect team id |
| `RELEASE_KEYSTORE` | `android deploy` | The `.jks`, base64-encoded (`base64 -i release.jks \| tr -d '\n'`) |
| `ANDROID_KEYSTORE_ALIAS`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD` | `android deploy` | The keystore's alias and passwords |
| `SUPPLY_JSON_KEY_DATA` | `android deploy` | The service account's JSON key, raw |

**Rollback plan:** revert the commit. Nothing outside the repository changes.

## 6. Implementation plan

1. Created the `Gemfile` and installed fastlane into `vendor/bundle`. The
   Homebrew gem directory is root-owned, so a system-wide install failed;
   project-local gems avoid `sudo` entirely.
2. Ran `fastlane init`, which declined to run at the root; wrote the
   `Appfile` and `Fastfile` by hand.
3. Matched the Android lane to the signing environment variables already in
   `android/app/build.gradle.kts`.
4. Added `make fastlane-setup` and the `.gitignore` entries.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `bundle exec fastlane --version` | 2.241.2 |
| `ruby -c` on `Appfile` and `Fastfile` | Syntax OK |
| `bundle exec fastlane lanes` | Lists `ios beta` and `android deploy` |
| Working directory of lane code and `sh` | `fastlane/`, confirmed by a probe lane; hence the absolute `ROOT` paths in §1 item 4 |
| `make -n fastlane-setup` | Expected commands |
| A lane run end to end | Not yet: blocked on the §5 prerequisites |
| Certification | 2026-10-27 — Theo (release tooling; no app code changed) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — secrets only from the environment, removed in `ensure` |
| Clinical Reviewer | — | N/A — no clinical impact | — | — |
| Compliance Officer | — | N/A — no data impact | — | — |
| Lead Designer | — | N/A — no UI change | — | — |

## 9. Post-implementation review

- Run each lane once by hand when its prerequisites exist, and record the
  result here before a workflow depends on it.
- The `ensure` cleanup assumes a disposable CI runner for the keychain; on a
  developer machine, `ios beta` replaces the default keychain for the run.

## 10. Related records

- Architecture: [`mobile_architecture.md` §13](../../architecture/reports/mobile_architecture.md#13-cicd)
- Previous CRQ: [CRQ-0004](./CRQ-0004-codeowners-pr-template-labels-and-merge-bar.md)
