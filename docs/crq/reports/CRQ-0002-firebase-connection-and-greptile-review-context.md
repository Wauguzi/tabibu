# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0002 |
| Title | Connect Firebase for Android and iOS, and give Greptile the repository's review context |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `3a49df4` (Firebase); the commit that adds this record (Greptile context) |

## 1. Description of change

**Firebase connection (`3a49df4`).** The app is connected to the
`tabibu-86ea2` Firebase project through the FlutterFire CLI:

- Client config added: `lib/firebase_options.dart`,
  `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`,
  `firebase.json`.
- Android applies the Google services, Firebase Performance and Crashlytics
  Gradle plugins.
- iOS adds `GoogleService-Info.plist` to the Runner target and a build phase
  that uploads Crashlytics debug symbols.
- `bootstrap()` initialises Firebase before `runApp()`, bounded by a
  10-second timeout and caught, so a hang or failure on the cold-start path
  still starts the app rather than leaving it on the native splash.
- Every flavor entrypoint calls `WidgetsFlutterBinding.ensureInitialized()`
  before `bootstrap()`.

**Greptile review context (this commit).**

- `.greptile/files.json` points Greptile at the eight documents that govern
  the code, each scoped to the paths it applies to.
- `.greptile/rules.md` summarises the conventions a diff does not reveal by
  itself, with the clinical-safety rules (S-1 to S-7) first, so a breach is
  reported as the top finding.
- [`mobile_workflow.md` §5](../../workflow/reports/mobile_workflow.md#5-tools--systems)
  now records where Greptile's context lives.

## 2. Business justification

Firebase is the app's only backend: day 3 of the plan (auth with one account
per role, the Firestore collections, Storage, seeded records) cannot start
without it.

Greptile is the only reviewer besides me. Without the context files it
reviews against generic Flutter conventions and cannot know, for example,
that a doctor reading an unsigned draft is a P1 breach, or that the tracked
Firebase config files are not leaked secrets. With them, every pull request
is checked against Tabibu's own rules, which serves the technical-depth
criterion and lowers the chance of a clinical-safety regression reaching the
demo.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- **Firebase for web.** Not configured yet, although the web demo is the main
  judged surface. Recorded as
  [architecture §16 item 8](../../architecture/reports/mobile_architecture.md#16-known-architectural-debt--watchlist);
  it must land before any Firebase-backed screen.
- **Separate projects per flavor.** All three flavors use `tabibu-86ea2`
  (architecture §16 item 9).
- **Crashlytics, App Check, Remote Config and the other Firebase services**:
  the packages and Gradle plugins are in, but nothing initialises or reports
  to them yet.
- **Security rules, Cloud Functions and the rules test harness**: none exist
  yet (architecture §16 item 5). Until they do, the backend has whatever
  default rules the Firebase console set when the databases were created.
- **The `ai_service/` path** named in `.greptile/files.json` does not exist
  yet. The scope is written ahead of it so the AI-service documents apply from
  its first commit.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | No collections or models yet |
| Roles & case scoping | None yet | Claims and rules arrive with the auth work |
| Clinical safety | None in code | Greptile now reviews against S-1 to S-7 on every pull request |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | Public client config is now tracked (not secrets; see the threat model §2). No rules are deployed from this repository, so the console's defaults apply until rules land |
| Data protection | None | No data of any kind; no patient-identifying fields exist |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low for the app; Medium for the backend posture until rules
land.

The real risk is not in this diff: it is the period between creating the
Firestore and Storage databases and deploying rules from this repository.
Console-created databases in test mode allow open reads and writes until a
date. The project holds no data yet, so nothing is exposed today, but the
first seeded record must not be written before the rules are deployed.

**Rollback plan:** revert `3a49df4` to disconnect the app (the build no
longer applies the Firebase Gradle plugins or initialises Firebase), and
revert this commit to remove the Greptile context. Neither touches data.
Rollback takes minutes.

## 6. Implementation plan

1. Ran `flutterfire configure` for Android and iOS against `tabibu-86ea2`.
2. Added the bounded, caught `Firebase.initializeApp()` to `bootstrap()`, and
   `WidgetsFlutterBinding.ensureInitialized()` to the three entrypoints.
3. Confirmed the app starts on device with Firebase connected.
4. Updated the threat model (config files are tracked on purpose) and the
   architecture watchlist (web not configured; one project for all flavors)
   in the same commit.
5. Wrote `.greptile/files.json` and `.greptile/rules.md` from the docs, and
   pointed the workflow's tools table at them.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | Pass — 19 files, 0 changed |
| `make analyze` | Pass — no issues |
| `make test` | Pass — 8/8 |
| cspell over `**/*.md` | Pass — 0 issues |
| `.greptile/files.json` | Valid JSON; every `path` exists |
| Rules tests | N/A — no rules yet |
| Manual run | Pass — Firebase connected on device (Android and iOS) |
| Greptile reading the context | Not yet observed — confirmed on the first pull request |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` during the hackathon | — | — |
| Clinical Reviewer | Clinical wording changed | Covered by CTO — the S-rules as summarised in `.greptile/rules.md` | 2026-10-27 | Approved |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved with changes — deploy rules before the first seeded record (§5) |
| Compliance Officer | Data protection impact | N/A — no data | — | — |
| Lead Designer | Design-system impact | N/A — no UI change | — | — |

## 9. Post-implementation review

To check after the first pull request:

- Does Greptile's review cite `.greptile/rules.md` or the scoped documents?
  If a finding contradicts a rule, answer it on the thread; do not weaken the
  rule.
- Does the `bootstrap()` failure path need a Crashlytics report once
  Crashlytics is initialised? A failed Firebase start in a release build is
  currently invisible: the `debugPrint` is behind `kDebugMode`, although the
  comment beside it says it stays visible after release. Fix the code or the
  comment with the Crashlytics change.

## 10. Related records

- Architecture/design references:
  [`mobile_architecture.md` §16](../../architecture/reports/mobile_architecture.md#16-known-architectural-debt--watchlist),
  [threat model §2](../../security/reports/firebase_and_ai_service_threat_model.md#2-verified-clean)
- Previous CRQ: [CRQ-0001](./CRQ-0001-bootstrap-and-engineering-docs-baseline.md)
- Related Incident Report(s): none
- Related Problem record(s): none
