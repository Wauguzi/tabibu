# Tabibu — Mobile & Web Architecture

> **The single source of truth for how the Tabibu app is built.** It is
> written for a new engineer's first 30 minutes on the code, for Greptile
> reviewing a pull request, and for a judge reading the repository to see
> whether the build matches the claims. Pair it with
> [`mobile_design_system.md`](../../design/reports/mobile_design_system.md)
> for the visual layer,
> [`ai_preread_service.md`](./ai_preread_service.md) for the one service that
> calls a model, [`notifications_engine.md`](./notifications_engine.md) for
> the inbox and push, and
> [`outbreak_alert_engine.md`](./outbreak_alert_engine.md) for alerts.

| Field | Value |
|---|---|
| Platform | Flutter: web demo, Android, iOS; 3 build flavors |
| Owner | Theo — CTO, Mobile Engineer |
| Status | Draft — the target architecture; §4 and §16 say what exists today |
| Last reviewed | 2026-10-26 |
| Reviewed by | Theo |

## 1. Purpose

Tabibu is one Flutter app with three role workspaces (patient, doctor and
pathologist) built over one shared case record. This document fixes the
structural decisions before the features land, so every feature is built
the same way, and so that a reviewer can check a change against a written
rule rather than a guess. Where the code does not yet match this document,
the gap is listed in §16 rather than glossed over.

## 2. Tech stack

Versions are the constraints in `pubspec.yaml`; `pubspec.lock` is
authoritative for what resolved.

| Layer | Technology | Notes |
|---|---|---|
| Language / SDK | Dart `^3.13.0`, Flutter `^3.47.0` (3.47.8 locally) | |
| UI libraries | `material_ui ^1.8.0`, `cupertino_ui ^1.1.4` | The Material and Cupertino libraries published separately from the framework. They carry their **own** localizations types; see §15 rule 1. |
| State management | `bloc ^9.2.1`, `flutter_bloc ^9.1.1`, `bloc_concurrency ^0.3.0` | Bloc app-wide; transformers chosen per event (§5). |
| Lint | `very_good_analysis ^11.0.0`, `bloc_lint ^0.4.1` | `bloc_lint` enforces bloc-layer hygiene and runs in CI. |
| Routing | `go_router ^18.1.1`, `go_router_builder ^4.5.2` | Typed `GoRouteData` routes, code-generated (§8). |
| Dependency injection | `get_it ^9.3.0`, `injectable ^3.0.0` | Annotation-driven, code-generated (§7). |
| Immutable models | `freezed ^3.2.6-dev.1`, `freezed_annotation ^3.1.0`, `json_serializable ^6.15.2` | |
| Local persistence | `hive_ce ^2.22.0`, `hive_ce_flutter ^2.5.0`, `hive_ce_generator ^1.11.2` | An encrypted, offline-first cache, not a key-value store (§6). |
| Backend | Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions`, `firebase_messaging`, `firebase_remote_config`, `firebase_app_check`, `firebase_crashlytics`, `firebase_analytics`, `firebase_performance` | The app talks **only** to Firebase. It never calls a model (§3). |
| Notifications | `firebase_messaging ^16.7.1`, `flutter_local_notifications ^22.3.3` | Push for alerts and case updates; local banners for foreground arrivals. See [`notifications_engine.md`](./notifications_engine.md). |
| Anti-tamper | `freerasp ^8.2.4` | Root/jailbreak, repackaging, debugger and hook detection (§10). |
| Secure storage | `flutter_secure_storage 11.2.0` (exact pin) | Holds the Hive encryption key. On the cold-start path; see §15 rule 2. |
| Auth providers | `firebase_auth`, `google_sign_in ^7.2.0`, `local_auth ^3.0.2` | Email/password for the seeded demo accounts; Google sign-in; biometric re-entry. |
| Charts / PDF | `fl_chart ^1.3.0`, `pdf ^3.13.1`, `printing ^5.15.1` | Evaluation charts on the proof screen; the signed report as a PDF. |
| Asset/font codegen | `flutter_gen ^5.15.0` | Generates `Assets` and `FontFamily` into `lib/gen/`. No hand-written asset paths. |
| Testing | `flutter_test`, `bloc_test ^10.0.0`, `mocktail ^1.0.5`, `fake_cloud_firestore ^4.4.0` | `fake_cloud_firestore` must track `cloud_firestore`'s minor version (§15 rule 9). |

## 3. High-level architecture

Two halves, joined only through Firebase:

```
┌──────────────────────── Tabibu app (Flutter) ─────────────────────────┐
│  Widget  ── dispatches events, renders state                          │
│    ▼                                                                  │
│  Bloc    ── no Flutter imports; one bloc per feature concern          │
│    ▼                                                                  │
│  Helper  ── core/helpers/<feature>_helper.dart: cache-vs-remote logic │
│    ▼                       ▼                                          │
│  Hive cache  ◄── sync ──►  Firestore datasource                       │
│  (encrypted; first read)   (features/<f>/data/datasources/)           │
└───────────────────────────────┬───────────────────────────────────────┘
                                │ Auth · Firestore · Storage · FCM
┌───────────────────────────────▼───────────────────────────────────────┐
│ Firebase: rules are the data boundary; Cloud Functions own every      │
│ privileged write (signing, approval, alert fan-out, role claims)      │
└───────────────────────────────┬───────────────────────────────────────┘
                                │ trigger: case opened / result signed
┌───────────────────────────────▼───────────────────────────────────────┐
│ Tabibu AI service (Modal): pre-read, order risk check, intake,        │
│ outbreak detector, alert drafts → writes drafts back to Firestore     │
│   ├─ Meta Model API: Muse Spark 1.3, SAM 3.1, Muse Voice Transcribe   │
│   └─ Open weights: Muse Spark Open on Baseten; Glimmer on Modal       │
└───────────────────────────────────────────────────────────────────────┘
```

Three rules follow from the diagram and are not negotiable:

1. **The app never calls a model.** No model API key ships in the binary.
   The app writes a request (a case opened, a result signed, an intake
   recorded) and reads back a draft the service wrote.
2. **The helper, not the bloc and not the datasource, decides cache versus
   remote.** A bloc asks its helper. It never reaches into Hive or Firestore
   directly.
3. **Every privileged transition is server-side.** Signing a report,
   approving an alert, marking a cancer result discussed and setting a role
   are done by Cloud Functions that check the caller. A client cannot write
   any of them.

## 4. Folder structure

**Today** the app is the Very Good CLI scaffold: `lib/app/`, `lib/counter/`
(the template's example feature, to be deleted when the first real feature
lands), `lib/l10n/`, `bootstrap.dart` and three flavor entrypoints.

**Target** layout, which every feature is built to:

```
lib/
├── app/view/app.dart          # Root widget: lifecycle observer (§9), theme,
│                              # router, localizations, text scale
├── bootstrap.dart             # Shared startup for all flavors: Firebase,
│                              # App Check, Crashlytics, DI, Hive, freeRASP,
│                              # BlocObserver; every awaited call is bounded
├── main_development.dart      # Flavor entrypoints
├── main_staging.dart
├── main_production.dart
├── core/
│   ├── constants/             # enums.dart, app_colors.dart, app_spacing.dart,
│   │                          # app_styles.dart, theme_builder.dart,
│   │                          # app_error.dart, rasp_config.dart
│   ├── helpers/               # <feature>_helper.dart (cache/remote),
│   │                          # hive_helper.dart, db_helper.dart,
│   │                          # role_helper.dart, get_it_helper.dart
│   ├── routing/               # app_router.dart, app_routes.dart
│   ├── services/              # analytics, notification, internet,
│   │                          # rasp, remote_config, performance
│   ├── utils/                 # extensions, sync_cursor, input_sanitizer,
│   │                          # text_scale
│   └── widgets/               # Shared Custom* components (design doc §4)
├── features/
│   ├── auth/                  # Sign-in, role resolution, profile, county
│   ├── cases/                 # The shared case record and its timeline
│   ├── intake/                # Patient symptoms by voice or text
│   ├── orders/                # Test catalogue, ordering, risk-check banner
│   ├── worklist/              # Pathologist's ranked case list
│   ├── preread/               # Image viewer, overlays, draft editor, signing
│   ├── results/               # Signed report (doctor), explanation (patient)
│   ├── alerts/                # Approval queue (approver), area alerts
│   ├── notifications/         # Inbox, push handling
│   └── themes/                # Theme bloc
├── gen/                       # flutter_gen output; never edited by hand
└── l10n/                      # ARB files: en, sw
```

Every `features/<feature>/` has the same internal shape:
`blocs/<name>_bloc/{<name>_bloc,_event,_state}.dart`,
`data/{datasources,models}/`, `presentation/{<screen>.dart, widgets/}`.

## 5. State management

Bloc, enforced by `bloc_lint` in CI. The rules:

1. **No Flutter imports in a bloc.** Anything UI-shaped a bloc would need
   (strings, formatting) lives in `core/constants/`, so blocs are testable
   without a widget tree.
2. **Dependencies are constructor-injected with a `getIt` fallback, and
   held in private fields.** A screen talks to its bloc and never reaches past
   it to a datasource.
3. **Events are requests, named `<Verb><Noun>Requested`** (e.g.
   `SignReportRequested`). States are outcomes:
   `<Verb><Noun>InProgress`, `…Success`, `…Failure`.
4. **Failures share an abstract base per bloc** (e.g.
   `PrereadOperationFailure`) carrying an `AppError` that localises itself.
   **A listener matches the concrete failure, never the base**: listening on
   the base catches a sibling operation's failure and shows the wrong message.
5. **A value several screens watch gets a mixin, not a list of states.** For
   example, `UnreadCountState` is carried by every state that reports an
   unread count, so the bell icon and the inbox both update without each
   listing every state that carries the number.
6. **Concurrency is chosen per event, with the reason in a comment:**
   `droppable()` for loads and for actions a double tap must not send twice
   (sign, approve); `sequential()` for writes whose order matters (tile
   relabels while reviewing); `restartable()` for search-as-you-type and for
   listener refreshes where only the latest matters.
7. **Every user-visible action logs one analytics event** in its handler.
   A new action that logs nothing is an omission.
8. **Blocs are provided above the router and outlive individual screens.** A
   screen that keeps local state derived from a bloc seeds it from
   `bloc.state` on build rather than waiting for an emission that may never
   come.

**UI consumers.** Use the narrowest widget for the job:

| Widget | Use it when |
|---|---|
| `BlocSelector` | The widget depends on one derived value (brightness, a count) |
| `BlocBuilder` | The widget renders from state and has no side effects |
| `BlocListener` | Side effects only: navigation, snackbars, haptics |
| `BlocConsumer` | Both, on the same bloc. The listener still matches concrete states only |

A `RefreshIndicator`'s `onRefresh` awaits the bloc leaving its loading state.
Returning as soon as the event is added retracts the spinner before anything
changed.

## 6. Data layer

**Offline-first.** Hive is what the UI reads first; Firestore is the durable
source of truth that Hive syncs against. Every `<feature>_helper.dart`
follows the same three verbs:

- **Cache**: write fetched, created or updated records into the feature's box.
- **Get**: read from Hive first; go to Firestore only when the cache is empty,
  stale, or a refresh was asked for.
- **Search**: filter the in-memory box, not a Firestore query, so search is
  instant.

**Models come in pairs.** Each Firestore document has a Freezed model
(`<name>_model.dart`, `fromJson`/`toJson`) and a Hive mirror
(`<name>_hive.dart`, `fromModel`/`toModel`). The Hive class's `@HiveField`
indices follow the Freezed constructor's field order exactly, so the two can
be compared line by line in review. A Hive model never imports another
feature's Hive classes except inside `toModel`/`fromModel`.

**Hive typeIds are allocated once and never reused.** A reused id lets an
old install decode bytes written for a different class without any error.
The registry below is the record. Add a row in the same commit as the model.

| typeId | Class | Feature | Added |
|---|---|---|---|
| — | none allocated yet | — | — |

**Adapters register in one hand-maintained cascade in `hive_helper.dart`**,
and `test/core/helpers/hive_adapter_registration_test.dart` asserts that
every `*_hive.dart` class is registered. A model added only to a generated
registrar that nothing imports fails at runtime with "unknown type", never
at compile time.

**Documents are complete at creation.** Absence is `''`, `0`, `false` or an
empty list, never a missing key and never `null`, because the models
declare fields `required` and a missing key crashes the parse. A status
field gates any field that may be empty: `confidence: 0` with
`prereadStatus: 'Queued'` means "not yet measured", not "zero confidence".

**Timestamps are ISO-8601 UTC strings**, minted by one helper
(`syncTimestamp()`). Delta sync compares them as strings, and a local-offset
value sorts wrongly across time zones.

**Sync.** Records carry `synced` and `lastUpdatedAt`. Reads are delta pulls
from a cursor derived from the newest cached row (with a small overlap for
clock skew). A cloud row never overwrites a cached row that is still
unsynced; otherwise the newer `lastUpdatedAt` wins.

**Case scoping replaces tenant scoping.** Tabibu's boundary is the case. Every
case-bearing record carries `patientUid`, `doctorUid` and `pathologistUid`,
and every helper method that reads or writes one takes the signed-in user's
uid and role and filters on them. There is **no unscoped `getAll*` method**.
The rules enforce the same scope server-side (§11); the client filter keeps
the cache honest, and the rules are what actually protect the data.

**Health data on the device.** The Hive boxes are AES-encrypted with a key
held in secure storage. **Sign-out wipes every case-bearing box and rotates
the key**, because a clinic phone is often shared. The cost is a full
re-download on the next sign-in, which is acceptable at demo volumes. Slide
tiles and smear images are not stored in Hive; they stream from Storage
through the image cache.

## 7. Dependency injection

`injectable` + `get_it`, generated via `@InjectableInit()` in
`core/helpers/get_it_helper.dart`. Constructor parameters are public and
fields private. Firebase singletons, `SharedPreferences` and
`FlutterSecureStorage` are provided by a `@module` class, not registered by
hand, so tests can substitute any of them.

## 8. Routing / navigation

`go_router` with typed routes from `go_router_builder`: every route is a
`GoRouteData` subclass, and one `TabibuRouter` holds the generated
`$appRoutes`. A cold start lands on a `DecisionRoute`, which reads the
cached session and the role claim and sends the person to onboarding,
sign-in, or their role's shell. Each role has its own
`StatefulShellRoute` with its own tabs. A patient cannot reach a
pathologist route by typing a URL on web, because the redirect checks the
role claim, not a cached flag. Page transitions use
`CupertinoPageTransitionsBuilder` on every platform.

## 9. Lifecycle

`App` is a `WidgetsBindingObserver`. Lifecycle is where listeners and
cost are controlled:

| Transition | What happens |
|---|---|
| `paused` | Set `_hasBeenBackgrounded`. Stop the Firestore listeners: the inbox, the pathologist's worklist, the pre-read status of an open case. Nothing listens while nobody is looking. |
| `resumed` **after a real background** | Re-fetch Remote Config (kill switches, §10); reopen the listeners from the cache's cursor so nothing is missed; refresh the worklist; re-check that the account is still active. |
| `inactive → resumed` on cold start | Ignored. The `DecisionRoute` already ran these checks, and only the one-way `_hasBeenBackgrounded` flag can tell a cold start from a real resume. |
| Sign-out | Stop every listener, flush any queued writes while the credentials are still valid, then wipe the case-bearing boxes and rotate the key (§6). |
| Notification tapped (cold or warm) | The payload (a case or alert uid) routes through the typed router; a cold launch reads it once after the `DecisionRoute` resolves. |

## 10. Security

The full threat model, with IDs, is in
[`firebase_and_ai_service_threat_model.md`](../../security/reports/firebase_and_ai_service_threat_model.md).
In summary:

- **Auth**: Firebase Auth. **Role and the alert-approver permission are
  Firebase Auth custom claims**, set by an admin-only Cloud Function or seeding
  script. They are never a field a client can write.
- **App Check**: Play Integrity on Android, App Attest on iOS, reCAPTCHA
  Enterprise on the web demo. Enforced on Firestore, Storage and Functions.
- **RASP**: freeRASP, configured in `core/constants/rasp_config.dart`.
- **Secrets**: no model or service key is in the app, in any form: not in
  `--dart-define`, not in a Flutter asset, not in Remote Config (Firebase's
  own guidance; every app instance can read it). The AI service reads its
  keys from a Modal secret, Cloud Functions from Firebase Secret Manager, and
  local development from the macOS Keychain through `make ai-dev`. Remote
  Config carries non-secret settings only: model ids, base URLs, thresholds,
  kill switches. Release signing material lives in CI secrets (CRQ-0007, T-13).
- **Kill switches**: Remote Config flags (`preread_enabled`,
  `alerts_delivery_enabled`, `patient_explanations_enabled`) let me take a
  misbehaving AI path offline without a release. This is the first step of a
  P1 response.
- **Input**: free text (symptoms, notes, report edits) goes through
  `InputSanitizer` at the call site before it is stored or sent to the AI
  service.
- **Crash reporting**: Crashlytics, with obfuscated release builds and
  symbols uploaded from CI.

## 11. Roles & authorization model

| Role / permission | Can | Cannot |
|---|---|---|
| Patient | Describe symptoms; see their own cases; read a signed result's explanation once released; choose a county; receive area alerts | See any other patient's case; see an AI draft; see a cancer result before the doctor marks it discussed |
| Doctor | Accept a patient or open a case; order tests; attach a pathologist; receive signed reports; mark a result discussed | Edit or sign a report; see cases they are not on |
| Pathologist | Work the ranked list of cases assigned to them; review, edit and sign reports; mark a result notifiable | Release a result to a patient |
| Alert approver (a permission on a doctor) | Read, edit and approve a drafted alert | Approve an alert they drafted by hand without the draft being recorded |

**Scope is participation.** A user reads a case only if their uid is the
case's `patientUid`, `doctorUid` or `pathologistUid`. The rules check this
on every read and write. **AI drafts are invisible to anyone but the case's
pathologist** until signed, and that is enforced by the rules, not by the
UI hiding them. `RoleHelper` wraps the claims and exposes typed checks
(`canSign(case)`, `canApproveAlerts`), so no screen ever compares a role
string itself. Unknown roles resolve to no permissions; the helper never
throws and never returns null.

## 12. Integration contracts

| Contract | Owner document |
|---|---|
| Pre-read request and result shape, status lifecycle, measurement fields | [`ai_preread_service.md`](./ai_preread_service.md) |
| Notification rows, push payloads, idempotency | [`notifications_engine.md`](./notifications_engine.md) |
| Notifiable-event shape, detector rules, alert drafting, approval and delivery | [`outbreak_alert_engine.md`](./outbreak_alert_engine.md) |
| Rules and indexes | `firestore.rules`, `firestore.indexes.json`, tested in `test/firestore_rules/` |

## 13. CI/CD

**Interim state (from 2026-10-27).** The scaffold's `main.yaml` was removed
deliberately. It is replaced by purpose-built workflows that arrive with the
auth work, and this section is rewritten when they land. Until then, one
workflow runs in CI:

- **License check** (`license_check.yaml`), on changes to `pubspec.yaml`,
  `pubspec.lock` or the workflow itself. It fails if any dependency's license
  is outside MIT, BSD-2-Clause, BSD-3-Clause and Apache-2.0. Packages that
  never ship in an app build (dev-tool dependencies, Linux-only plugin code)
  are skipped by name, with the reason beside the list.

Every other gate runs locally and is part of the definition of done
([`mobile_workflow.md` §6](../../workflow/reports/mobile_workflow.md#6-definition-of-done)):
`make fmt`, `make analyze`, `make bloc-lint`, `make test`, `make spell` (cspell
over docs, config, scripts and Dart, with `.github/cspell.json` as the project
dictionary, imported by the root `.cspell.json`) and `make licenses`. The
Firebase targets (`emulators`, `rules-test`, `deploy-rules`,
`deploy-indexes`, `deploy-storage`, `deploy-functions`, `deploy-hosting`) use
one pinned CLI version against `tabibu-86ea2` (CRQ-0006).

**Release lanes** (fastlane, `fastlane/Fastfile`): `ios beta` builds the
`production` IPA and uploads it to TestFlight; `android deploy` builds the
`production` AAB and uploads it to the Play internal track. Both read every
secret from the environment and leave none on disk (CRQ-0005). Install with
`make fastlane-setup`; run with `bundle exec fastlane <platform> <lane>`.

Release builds use `--obfuscate --split-debug-info`. The web demo is
deployed to Firebase Hosting. Rules, indexes and functions are deployed with
`make deploy-*` targets, and a commit that changes them is not finished
until it is deployed.

## 14. Testing strategy

- **Unit and bloc tests** with `bloc_test` and `mocktail`, under `test/`
  mirroring `lib/`. Run with `make test`, which carries the coverage and
  reporter flags.
- **Widget tests** for every screen, pumped through `test/helpers/pump_app.dart`.
  That helper **imports** the app's localizations, theme and providers rather
  than re-declaring them, so tests cannot drift from what ships. Screens are
  tested at 1.0x and 2.0x text scale, in `en` and `sw`.
- **Rules tests** under `test/firestore_rules/` against the emulator, with one
  case per row of the §11 table, run by `make rules-test`. A rules change
  without a rules test is not finished.
- **Model evaluation** in the AI service: held-out PatchCamelyon tiles and NIH
  cells, a fixed sample, recorded with the
  [evaluation template](../../testing/templates/MODEL_EVALUATION_TEMPLATE.md).
- **Manual certification** before every code commit (workflow §4 step 6).
- **No on-device integration suite.** Unit, widget and rules tests plus manual
  certification carry the guard (§15 rule 5).

## 15. Standing rules

Each rule exists because the failure it prevents is easy to cause and hard
to see. Greptile is pointed at this section.

1. **Localization delegates come from `material_ui` and `cupertino_ui`, not
   the generated list.** Both libraries declare their own
   `MaterialLocalizations`/`CupertinoLocalizations` types, which the generated
   `AppLocalizations.localizationsDelegates` (built from
   `flutter_localizations`) can never satisfy. English hides this because
   `DefaultMaterialLocalizations` covers `en` only. Every other locale throws
   on the first `RefreshIndicator`, `TextField` or dialog. The app declares its
   own delegate list, and a test resolves `MaterialLocalizations` under `sw`.
   It does not just ask `isSupported`, which passes even when the bug is present.
2. **Nothing on the cold-start path is trusted to return.** Every awaited call
   before `runApp` is bounded. A Dart `.timeout()` cannot rescue a blocked
   platform thread, though: if the app hangs on the native splash, get a
   device log before shipping a fix. Secure storage is pinned exactly, and
   any bump is tested against an install that already holds data.
3. **A resource the platform looks up by name is kept explicitly.** The
   Android notification small icon is referenced by a string the shrinker
   cannot follow, so release builds keep it with `res/raw/keep.xml`. Anything
   resolved by name is verified against a release build, because debug
   builds do not shrink.
4. **Writes that must land together use a batch; a transaction is only for
   writes whose values depend on a read.** Signing (report status, signed
   copy, audit row) is a batch inside the Cloud Function.
5. **No test tooling that registers dev-only plugins into the release plugin
   registrant.** A dev dependency missing from the release classpath breaks
   every release build.
6. **A context-watching helper is called only inside `build()`.** Compute
   values like `isDark` once and pass them down. Calling them from a callback
   throws.
7. **A value is minted where it becomes true.** `signedAt`, `signedBy`,
   `approvedAt` and every measurement are produced by the function that makes
   them true, never copied from an upstream field with a similar name.
8. **Every number in a report is computed in code.** Tumor focus size, cell
   counts, parasitemia and confidence aggregation come from the AI service's
   measurement step. The model's prose never supplies a number the report
   displays.
9. **`fake_cloud_firestore` tracks `cloud_firestore`'s minor version.** When
   they diverge, test writes fail at load time or silently.
10. **Generated asset and font references only** (`Assets.*`,
    `FontFamily.*`). A raw path compiles, then breaks silently when a file is
    renamed.

## 16. Known architectural debt / watchlist

1. **The scaffold's localizations delegates are wrong for any non-English
   locale** (`lib/app/view/app.dart`). The app imports `material_ui` but
   passes `AppLocalizations.localizationsDelegates`, which is exactly the
   defect rule 1 describes. It is hidden today because the second locale is
   the template's Spanish and no screen has been tested in it. It must be
   fixed in the same change that replaces `es` with `sw`.
2. **The counter example feature is still in `lib/` and `test/`.** Delete it
   when the first real feature lands.
3. **Every `uses:` is pinned to a full commit SHA with the release in a
   trailing comment** (`license_check.yaml` is, since CRQ-0003). A tag can be
   moved; a SHA cannot. The workflows that replace `main.yaml` follow the
   same rule. Until those workflows land, nothing but the license check runs in CI, so
   format, analysis, tests and spelling are only as reliable as running the
   `make` targets before each commit.
4. **`test_api: any` is listed under `dependencies`**, not
   `dev_dependencies`, and is unconstrained. Move it, or remove it if nothing
   imports it.
5. **Firebase is connected (Android and iOS) but no `firestore.rules`,
   `functions/` or rules test harness exists yet**, and neither do the
   `make rules-test` and `make deploy-*` targets that drive them. Until they
   land, §10 and §11 describe intent, not enforcement.
6. **Cache wipe on sign-out costs a full re-download on sign-in.** Acceptable
   at demo volumes; a pilot with real caseloads needs delta sync that
   survives sign-out, which in turn needs a policy decision on health data
   at rest on shared devices.
7. **iOS App Attest and reCAPTCHA Enterprise site keys are not yet
   provisioned.** App Check stays in debug-provider mode until they are.
8. **Firebase is not configured for web**, and the web demo is the main
   judged surface. `DefaultFirebaseOptions.currentPlatform` throws on web,
   `bootstrap` catches it, and the app starts with no Firebase. Re-run
   `flutterfire configure` with web selected before any Firebase-backed
   screen is built.
9. **All three flavors share one Firebase project** (`tabibu-86ea2`). That is
   acceptable for the hackathon, but development writes land in the project
   the demo runs on, so seeded demo data must be kept apart from test data
   by convention until the flavors get their own projects.

## 17. Change log

| Date | Change | Author |
|---|---|---|
| 2026-10-27 | §10 sets where secrets may live, and that Remote Config never carries one (CRQ-0007). | Theo |
| 2026-10-27 | §13 describes the repository-wide spell check and the Firebase `make` targets (CRQ-0006). | Theo |
| 2026-10-27 | §13 adds the fastlane release lanes (CRQ-0005). | Theo |
| 2026-10-27 | §13 rewritten for the interim CI: `main.yaml` removed pending purpose-built workflows; only the license check runs in CI, now fixed for Flutter; every other gate is a local `make` target. §16 item 3 updated; the license check is now pinned to a commit SHA. | Theo |
| 2026-10-27 | §16 updated for the Firebase connection: item 5 narrowed to rules and functions; items 8 (web not configured) and 9 (one project for every flavor) added. | Theo |
| 2026-10-26 | Initial version: target architecture for the three-role app, the Firebase/AI-service split, data and lifecycle conventions, standing rules, and a watchlist of what the scaffold does not yet match. | Theo |
