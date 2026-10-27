# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0024 |
| Title | Runtime protection with freeRASP: tiered threats, translated notices, screen-capture blocking, and obfuscated release builds |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Ported from the reference implementation's `main` branch.

1. **`RaspService`** (`lib/core/services/`) over freeRASP, behind a
   `RaspPlatform` interface for tests. Every `Threat` is classified:
   - **critical**: root or jailbreak, hooks, tampering, a debugger, missing
     obfuscation. In a release binary the person is notified and the app
     terminates.
   - **severe**: unofficial store, emulator, multi-instance, cloning,
     unlocked bootloader, malware. Notified, and emitted on `threatStream`.
   - **advisory**: no passcode, VPN, developer mode, ADB, screenshots and
     recordings, weak Wi-Fi, spoofing, automation, reinstall. Notified and
     logged.

   Every detection is recorded to Crashlytics (fatal for critical).
   Malware package names go to the log only.
2. **Notices** go on the account and security channel (CRQ-0022), in the
   person's language: the onboarding choice, else the device, else English.
   They name a coarse area (device, app, another app, network), never the
   detection, which would tell an attacker which check to defeat.
3. **`RaspConfig`**:
   - the package and bundle id;
   - the Base64 SHA-256 of the Tabibu release key (production) and of the
     local debug key (development);
   - Google Play as the only supported store;
   - the Talsec watcher email (the address Theo chose);
   - screen-capture blocking on.
4. **Bootstrap** gains `isProd`, which follows the build mode, not the
   flavor: a debug build of any flavor is debug-signed, and enforcing
   certificates there would terminate it. RASP starts after notifications,
   bounded. It is registered in DI, and `bindUser(uid)` ties Talsec reports
   to a uid after sign-in.
5. **Android:**
   - `DETECT_SCREEN_CAPTURE`, `DETECT_SCREEN_RECORDING` and
     `ACCESS_WIFI_STATE` are declared.
   - `minSdk` is at least 23, freeRASP's floor (it resolves to 24).
   - `proguard-rules.pro` is created: `build.gradle.kts` named it, but it
     did not exist, and AGP 9 refuses a missing one.
   - iOS needs nothing further: freeRASP resolves through Swift Package
     Manager.
6. **`make apk` and `make dev-apk` now obfuscate.** Without it, a release
   binary detects missing obfuscation and terminates itself. CI and
   fastlane already did.
7. Docs: architecture §10 and §16 item 10; threat model T-10; two review
   rules.

## 2. Business justification

The app holds health records on shared phones. A rooted, hooked or
repackaged copy should not run, and the person should be told why it
closed.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- The Play App Signing hash and the iOS Team ID (§16 item 10).
- A UI for severe threats on `threatStream`.
- Calling `bindUser` from the session layer, with the auth bloc.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Security (rules, App Check, RASP, secrets) | **Affected** | T-10 partly in place |
| Data protection | Affected | Captures render black; detections log no patient data |
| Localisation | Affected | Eight notice strings in `en` and `sw` |
| CI | Affected | Release builds must obfuscate (they did) |
| Everything else | None | |

## 5. Risk & rollback plan

- **Screen capture is blocked in every build.** That includes the demo
  video if it is recorded on a phone: the app records as black. Record the
  demo from the web build, or set `RaspConfig.blockScreenCapture` to
  `false` in the demo build only and back afterwards.
- **A Play install terminates until the Play App Signing hash is added.**
  App Distribution builds are signed with our release key and are
  unaffected.
- **Emulators raise a severe notice**, which is expected in development.
- Firebase Analytics merges the `AD_ID` permission into the manifest. A
  health app should probably remove it; that is a separate decision.

**Rollback plan:** revert the commit.

## 6. Implementation plan

Read the reference's service, config, tests, manifest, Gradle, Makefile and
bootstrap on `main`; ported them with Tabibu's identifiers and fingerprints;
moved the user binding out of bootstrap; built a debug APK to check the
merged manifest.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| RASP service tests (ported: order of start, config per mode, every threat classified, critical handling only in production, malware, the stream, hints) | 28 passing |
| Debug APK: declared permissions and SDK levels | Five permissions present; min 24, target 36, compile 37 |
| `make analyze`, `make test`, `make spell` | Pass |
| A release build on a device | Theo, on the device test |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved |

## 9. Post-implementation review

- On a device with a CI-signed release build, confirm the app runs. A
  debug-signed release build should be stopped as tampered.
- Add the Play App Signing hash when the Play Console app exists.

## 10. Related records

- Previous CRQ: [CRQ-0023](./CRQ-0023-android-toolchain.md)
- Notifications: [CRQ-0022](./CRQ-0022-notification-service.md)
