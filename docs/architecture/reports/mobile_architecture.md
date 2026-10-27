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

**Reach.** The pilot is Nairobi, which had the most health facilities of any
county in the Ministry of Health's 2023 census: 1,319 targeted
([Kenya Health Facility Census, September 2023, §3.1](https://www.health.go.ke/sites/default/files/2024-01/Kenya%20Health%20Facility%20Census%20Report%20September%202023.pdf#page=20)).
Tabibu ships the Ministry's current Nairobi list from the
[Kenya Master Health Facility List](https://api.kmhfr.health.go.ke/media/KMHFL_Implementation_Guide_Jan_2020.pdf):
**1,447 facilities across all 17 sub-counties, 1,241 of them operational**,
and a doctor or pathologist at any operational one can join from the first
day (§6.2). The country is the next step. The same census targeted 14,366
listed facilities across the 47 counties and visited 14,883, 2,633 of which
were not yet on the list
([Table 1](https://www.health.go.ke/sites/default/files/2024-01/Kenya%20Health%20Facility%20Census%20Report%20September%202023.pdf#page=20)).
Adding a county is a data step, the same script run on that county's
export, with no change to the data model.

## 2. Tech stack

Versions are the constraints in `pubspec.yaml`; `pubspec.lock` is
authoritative for what resolved.

| Layer | Technology | Notes |
|---|---|---|
| Language / SDK | Dart `^3.12.2`, Flutter `^3.47.8` | The Dart floor sits below the toolchain's 3.13 because the code generators' `analyzer` cannot yet parse 3.13 syntax (CRQ-0008). |
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
│   ├── auth/                  # Sign-in, the three sign-up routes, reset,
│   │                          # session, the decision route
│   ├── profile/               # The signed-in person's profile, language,
│   │                          # picture, license, sign-out
│   ├── patients/              # Patient records, self- or doctor-added (§6.1)
│   ├── practitioners/         # The directory; nearest-first by geohash
│   ├── facilities/            # The bundled facility, county and
│   │                          # sub-county lists (§6.2)
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
| 0 | `PatientHive` | `patients` | Reserved 2026-10-27 (CRQ-0014) |
| 1 | `DoctorHive` | `profile` | Reserved 2026-10-27 (CRQ-0014) |
| 2 | `PractitionerHive` | `practitioners` | Reserved 2026-10-27 (CRQ-0014) |

A reserved row becomes "Added" in the commit that creates the class. Reserving
ahead stops two agents working in parallel from taking the same id.

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

### 6.1 Identity: patients, practitioners and the directory

There is no `users` collection. A person is their role claim (§11) plus one
profile document: `patients` for patients, `doctors` for doctors and
pathologists. The public `practitioners` directory is a server-written
projection of verified `doctors`. Field order below is the Freezed
constructor order. "Server" means a Cloud Function or the trigger; "owner"
means the signed-in person whose document it is.

**`patients/{patientId}`.** A self-registered patient's `patientId` is their
Auth uid. A doctor-added patient has no Auth account, so their `patientId`
is generated, and it never changes, even when they later register.

| Field | Type | Written by | Notes |
|---|---|---|---|
| `patientId` | String | Server | The document id |
| `uid` | String | Server | Auth uid; `''` until the patient has an account |
| `isRegistered` | bool | Server | `true` exactly when `uid` is set |
| `createdByUid` | String | Server | The patient themselves, or the doctor who added them |
| `firstName`, `middleName`, `lastName` | String | Server at creation; owner after | `middleName` may be `''` |
| `sex` | String (`Sex`) | Server at creation; owner after | Clinical: reference ranges depend on it |
| `dateOfBirth` | String (ISO date) | Server at creation; owner after | Required for every patient; age is derived, never stored |
| `phoneNumber` | String (E.164) | Server at creation; owner after | Normalised to `+254…` |
| `email` | String | Server | From the Auth token; never changes once registered. Before then, the creating doctor may correct it |
| `profilePictureUrl` | String | Owner, or a care-team doctor while unregistered | `''` until uploaded; never public |
| `county` | String | Owner | One of the 47; defaults to Nairobi |
| `subCounty` | String | Owner | Nairobi sub-counties only; `''` outside Nairobi |
| `geohash` | String | Server | 9 characters, computed from the sub-county's centre, so it locates an area, never a home (T-9). `''` outside Nairobi |
| `doctorUids` | List\<String\> | Server | The care team: the doctors and pathologists who may read this profile |
| `fcmTokens` | List\<String\> | Owner | One per signed-in device; read only by Cloud Functions |
| `language` | String | Owner | `en` or `sw`; also the language of server-sent pushes |
| `receiveNotifications` | bool | Owner | |
| `casesReported`, `appointmentsBooked` | int | Server | Counters |
| `createdAt`, `lastUpdatedAt` | String | Both | §6 timestamps |

**`doctors/{uid}`**, for doctors and pathologists. The document id is the Auth
uid.

| Field | Type | Written by | Notes |
|---|---|---|---|
| `uid` | String | Server | |
| `title`, `firstName`, `lastName` | String | Owner | |
| `email` | String | Server | From the Auth token; never changes |
| `phoneNumber` | String (E.164) | Owner | |
| `profilePictureUrl` | String | Owner | Public: copied to the directory |
| `isPathologist` | bool | Server | Chosen on sign-up; fixed after |
| `specialization`, `bio` | String | Owner | `bio` is plain text through `InputSanitizer` |
| `kmpdcNumber` | String | Owner until verified | Unique across accounts. Final once `Verified` |
| `licenseUrl` | String | Owner until verified | The practising license. Final once `Verified`; never public |
| `verificationStatus` | String (`VerificationStatus`) | Server | `Pending`, `Verified` or `Rejected` |
| `facilityId`, `facilityMflCode`, `facilityName` | String | Owner picks; server checks | From the facility list (§6.2) |
| `county`, `subCounty`, `geohash` | String | Server | Copied from the facility; `geohash` is the facility's 9 characters |
| `isAvailable` | bool | Owner | |
| `fcmTokens`, `language`, `receiveNotifications` | | Owner | As for patients |
| `appointmentsHandled`, `ordersCreated`, `reportsSigned` | int | Server | `reportsSigned` stays 0 for doctors |
| `termsAcceptedAt`, `createdAt`, `lastUpdatedAt` | String | Server, Both | |

**`practitioners/{uid}`** is the directory every signed-in user may read. Only
the `syncPractitioner` trigger on `doctors` writes it, and only while the
doctor is `Verified`; a doctor's own profile edit therefore updates the entry,
and an entry is removed if the doctor stops being verified. Its fields are the
public subset of `doctors`, in the same order: `uid`, `title`, `firstName`,
`lastName`, `profilePictureUrl`, `isPathologist`, `specialization`, `bio`,
the facility fields, `county`, `subCounty`, `geohash`, `isAvailable`, the three
counters, and `lastUpdatedAt`. The facility fields come from the server's
facility list, not from what the client sent. It never carries email, phone,
KMPDC number, license or tokens.

**Every geohash is 9 characters** (about 5 m), from `GeohashService.encode`. A
search widens by truncating the prefix. Characters that were never stored
cannot be recovered.

**Counters** are incremented only by triggers, with `FieldValue.increment`.
Triggers are delivered at least once, so each records its event id before
incrementing, and a redelivered event counts nothing. A counter added later
is `@Default(0)` in its model, so older documents still parse.

**How each document is created.** Clients never create a `patients`,
`doctors` or `practitioners` document; callables do, and set the role claim
in the same step.

| Callable | Caller | Does |
|---|---|---|
| `completePatientSignUp` | A new account | Normalises the phone, then looks for an unregistered record with the same phone and date of birth. With no match, it creates `patients/{uid}` and sets `role: patient`. With a match, it creates nothing and returns `clinic-record-exists`: an account is linked to an existing record only in person (`linkPatientAccount`), because a phone number and birth date are not proof of identity |
| `completePractitionerSignUp` | A new account | Checks the KMPDC number is unused and the facility exists, then creates `doctors/{uid}` as `Pending`. **No role claim is set**, so a pending account reaches no clinical route |
| `verifyPractitioner` | Admin only (seed script for the pilot) | Sets `Verified` or `Rejected`; on `Verified`, sets `role: doctor` or `role: pathologist` |
| `addPatient` | A verified doctor | Same duplicate check, then creates the record with `uid: ''` and the doctor in `doctorUids` |
| `linkPatientAccount` | A doctor on the record's care team | Attaches a registered account to a doctor-added record, with the patient present |
| `inviteToCase` | The patient | Adds a verified practitioner to a case's participants and to `doctorUids` |

Being in `doctorUids` grants the patient's profile, not their cases. Each
case's own participant list (§11) still decides who reads which case. A
second-opinion doctor sees the shared case only. The patient may remove a
doctor from `doctorUids`.

**Storage.** Each path is written only by the people listed below. Image
uploads must be `image/*`; a license may also be `application/pdf`.

| Path | Who writes | Who reads | Limit |
|---|---|---|---|
| `profilePictures/{id}/…` (`id` is a `doctors` uid or a `patientId`) | The owner; or, for an unregistered patient, a doctor in their `doctorUids` | Any signed-in user; no listing | 3 MB |
| `licenses/{uid}/…` | Owner, until `Verified` | Owner and admin | 3 MB |

There is no picture collection: the download URL is stored on the profile
(`profilePictureUrl`), and the trigger copies a practitioner's into the
directory, so a screen fetches one document. A download URL works for
anyone who holds it, so the Storage read rule only stops listing a folder.
What actually keeps a patient's picture private is that its URL sits on a
document only the patient and their care team can read.

### 6.2 Reference data shipped with the app

The pilot is Nairobi. Three JSON assets, produced by
`scripts/facilities/` (`make facilities`) from the Ministry of Health's
exports, are read from the bundle and never written:

| Asset | Holds |
|---|---|
| `assets/data/facilities_nairobi.json` | All 1,447 facilities: `facilityId` (the Ministry's id), `mflCode`, `name`, `kephLevel`, `facilityType`, `owner`, `wardId`, `ward`, `subCountyId`, `subCounty`, `countyId`, `county`, `latitude`, `longitude`, `geohash` (9), `isLocationApproximate`, `isLab`, `operationStatus`, `isOperational` |
| `assets/data/counties.json` | All 47 counties, with their official codes (Nairobi is 47) |
| `assets/data/sub_counties_nairobi.json` | Nairobi's 17 sub-counties, each with its id, its centre and its 9-character geohash |

What the script does to the export, and why:

- **Keyed by the Ministry's `id`.** Ten facilities have no MFL code (the
  export says `"None"`); their `mflCode` is `''`.
- **Closed facilities are kept**, with `isOperational: false` (206 of
  them). The picker greys them out, and `completePractitionerSignUp`
  refuses one, so the full list can be quoted without anyone joining a
  closed facility. A facility is operational only when the export says
  both `active` and `Operational`.
- **223 facilities have no coordinates** (exported as `0, 0`). They take
  their sub-county's centre and `isLocationApproximate: true`; hashing
  `0, 0` would put them in the Gulf of Guinea.
- **A sub-county's centre** is the mean of its located facilities.
- Fields that are null in every row (`facility_type_category`,
  `owner_type`, `constituency`, `phone_number`, `email`) are dropped; every
  other `null` becomes `''`, `0` or `false`, and whitespace is trimmed and
  collapsed.
- Rows outside Nairobi, coordinates outside Kenya, a sub-county with no
  located facility, or a county list other than 1 to 47 stop the run.
  Repeated rows from overlapping batches are kept once, so the script is
  safe to run again.

`functions/` holds a byte-identical copy, so the server checks a facility
against its own list rather than trusting a client; a test compares the
two. A patient outside Nairobi can still sign up: they see a pilot notice,
and the directory lists every practitioner rather than the nearest.

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
  Activated in `bootstrap` (CRQ-0010): release builds use the attestation
  providers, debug and profile builds the debug provider, with a token from
  the Keychain (`make app-check-token`, injected by `make run-dev`).
  **Not yet enforced**: enforcement applies per API to every client, so it
  waits until each platform's release build can attest (§16 item 7).
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
- **Remote Config at startup** (CRQ-0011): `bootstrap` sets in-app defaults,
  then fetches and activates within the bootstrap timeout; on any failure
  the defaults stand. Every parameter the app reads has a default there.
  Release builds fetch at most every 12 hours, so a value change can take
  that long to reach a running install; debug builds fetch every launch.
  The force-update parameters (`min_required_version`, `force_update`,
  `store_url_android`, `store_url_ios`, `update_title`, `update_message`)
  default to letting the app through; the gate itself arrives with the
  router on the auth branch.
- **Input**: free text (symptoms, notes, report edits) goes through
  `InputSanitizer` at the call site before it is stored or sent to the AI
  service.
- **Crash reporting**: Crashlytics, release builds only. Framework and
  platform errors are recorded as fatal, bloc errors as non-fatal, and a
  stream torn down after its native handler is gone as non-fatal. Release
  builds are obfuscated, with Dart symbols uploaded from CI, R8 mapping
  files by the Crashlytics Gradle plugin and dSYMs by the FlutterFire build
  phase. Crash reports carry no patient data: ids and types only (CRQ-0009).

## 11. Roles & authorization model

| Role / permission | Can | Cannot |
|---|---|---|
| Patient | Describe symptoms; see their own cases; read a signed result's explanation once released; choose a county and sub-county; browse the practitioner directory; invite a practitioner to a case | See any other patient's case; see an AI draft; see a cancer result before the doctor marks it discussed |
| Pending practitioner (no role claim) | Edit their own `doctors` profile, KMPDC number and license | Reach any clinical route or read any patient |
| Doctor | Add a patient; read the profiles of patients whose care team they are on; accept a patient or open a case; order tests; attach a pathologist; receive signed reports; mark a result discussed | Edit or sign a report; see cases they are not on |
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

Two workflows run in CI:

- **Production APK** (`prod_apk.yaml`), on every pull request to `main`.
  Format check, code generation, `flutter analyze`, bloc lint and the tests
  run on every PR. When the signing secrets are present (not on Dependabot
  or fork PRs), it then builds the `production` APK, obfuscated and signed
  with the release keystore, keeps the debug symbols for 90 days, uploads
  the Dart symbols to Crashlytics, and sends the APK to the
  `internal-production` group in Firebase App Distribution (CRQ-0008).
- **License check** (`license_check.yaml`), on changes to `pubspec.yaml`,
  `pubspec.lock` or the workflow itself. It fails if any dependency's license
  is outside MIT, BSD-2-Clause, BSD-3-Clause and Apache-2.0. Packages that
  never ship in an app build (dev-tool dependencies, Linux-only plugin code)
  are skipped by name, with the reason beside the list.

Every gate also runs locally and is part of the definition of done
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

**iOS** targets 15.0 (Firebase's minimum) and resolves plugins through
Swift Package Manager; `Package.resolved` is committed so every machine
builds the same Firebase SDK versions (CRQ-0012).

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
- **Rules tests** under `test/firestore_rules/` against the Firestore and
  Storage emulators, with one case per row of the §11 table, run by
  `make rules-test`. A rules change without a rules test is not finished.
  Each denial has a matching allowed write that differs only in the field
  under test, so a test cannot pass because of an unrelated failure.
- **Function tests** in `functions/src/*.test.ts`, run by
  `make functions-test`: lint and build as a deploy would, then the handlers
  against the Firestore and Auth emulators, so transactions and queries
  behave as in production. Both suites run on the `demo-tabibu` project id,
  which cannot reach the live project.
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
   moved; a SHA cannot. `prod_apk.yaml` follows the same rule (CRQ-0008).
   Spelling and secret scanning still run only locally, through
   `make spell` and `make secrets`.
4. **`test_api: any` is listed under `dependencies`**, not
   `dev_dependencies`, and is unconstrained. Move it, or remove it if nothing
   imports it.
5. **Rules and functions cover identity only, and are not deployed yet**
   (CRQ-0016). `firestore.rules`, `storage.rules` and `functions/` enforce
   §6.1, and every other collection is closed. Cases, orders, reports and
   alerts get their rules with their features. Deploy (`make deploy-rules`,
   `deploy-storage`, `deploy-functions`) waits for the pull request's
   review; until then the live project runs whatever the console holds.
6. **Cache wipe on sign-out costs a full re-download on sign-in.** Acceptable
   at demo volumes; a pilot with real caseloads needs delta sync that
   survives sign-out, which in turn needs a policy decision on health data
   at rest on shared devices.
7. **App Check is active but not enforced.** Play Integrity needs a Play
   Console app record with at least one upload; App Attest needs an Apple
   Developer team registered in Firebase; the web demo needs a reCAPTCHA
   Enterprise key. Until each exists, that platform's release build cannot
   attest, and enforcing would reject it, App Distribution builds included.
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
| 2026-10-27 | §14 function tests and the rules-test discipline; §16 item 5: identity rules and functions exist, not yet deployed (CRQ-0016). | Theo |
| 2026-10-27 | §1 reach: the Nairobi facility count and the national census figures, linked to their sources. §6.2 rewritten for the generated assets: all 1,447 facilities with `isOperational`, approximate locations, sanitising rules; `make facilities` (CRQ-0015). | Theo |
| 2026-10-27 | §6.1 identity collections (`patients`, `doctors`, `practitioners`), their callables and Storage paths; §6.2 bundled facility data; typeIds 0–2 reserved; §4 features and §11 roles updated (CRQ-0014). | Theo |
| 2026-10-27 | §13: iOS target 15.0 and Swift Package Manager (CRQ-0012). | Theo |
| 2026-10-27 | §10 Remote Config at startup: defaults, fetch bounds, and the force-update parameters (CRQ-0011). | Theo |
| 2026-10-27 | §10 App Check activated, not enforced; §16 item 7 lists what enforcement waits on (CRQ-0010). | Theo |
| 2026-10-27 | §10 crash reporting: what is recorded, at what severity, and that reports carry no patient data (CRQ-0009). | Theo |
| 2026-10-27 | §2 SDK floor lowered to Dart `^3.12.2`, Flutter `^3.47.8`. §13 adds the production APK workflow; §16 item 3 updated (CRQ-0008). | Theo |
| 2026-10-27 | §10 sets where secrets may live, and that Remote Config never carries one (CRQ-0007). | Theo |
| 2026-10-27 | §13 describes the repository-wide spell check and the Firebase `make` targets (CRQ-0006). | Theo |
| 2026-10-27 | §13 adds the fastlane release lanes (CRQ-0005). | Theo |
| 2026-10-27 | §13 rewritten for the interim CI: `main.yaml` removed pending purpose-built workflows; only the license check runs in CI, now fixed for Flutter; every other gate is a local `make` target. §16 item 3 updated; the license check is now pinned to a commit SHA. | Theo |
| 2026-10-27 | §16 updated for the Firebase connection: item 5 narrowed to rules and functions; items 8 (web not configured) and 9 (one project for every flavor) added. | Theo |
| 2026-10-26 | Initial version: target architecture for the three-role app, the Firebase/AI-service split, data and lifecycle conventions, standing rules, and a watchlist of what the scaffold does not yet match. | Theo |
