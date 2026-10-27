# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0009 |
| Title | Crashlytics error reporting in bootstrap: framework, platform and bloc errors, release builds only |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

`lib/bootstrap.dart` reports errors to Crashlytics, in release builds only:

| Source | Handler | Severity |
|---|---|---|
| Flutter framework | `FlutterError.onError` | Fatal |
| An `EventChannel` cancel that reached an already-disposed native handler | `FlutterError.onError` | Non-fatal: the stream was being discarded and the app keeps running |
| Uncaught async and platform errors | `PlatformDispatcher.onError` | Fatal |
| Bloc and cubit errors | `AppBlocObserver.onError`, with the bloc type as the reason | Non-fatal: bloc catches them, so neither handler above ever sees them |

- Crashlytics is reached only inside the handlers, each wrapped in
  `try`/`catch`, so a failed or timed-out `Firebase.initializeApp()` cannot
  crash the app at startup.
- Collection is switched off outside release builds. All three Android
  flavors share one Firebase app, so without this, native crashes from
  development builds would land in the production dashboard.
- Debug and profile builds keep logging to the console.
- The native side was already in place: the Crashlytics Gradle plugin
  uploads R8 mapping files, the FlutterFire build phase uploads dSYMs, and
  `prod_apk.yaml` uploads the Dart symbols (CRQ-0008).
- The bootstrap comment that said `debugPrint` stays visible after release
  is gone; the call sits behind `kDebugMode`.
- **Privacy rule:** crash reports carry ids and types, never patient data
  (architecture §10, Greptile **Privacy**).

## 2. Business justification

The demo runs on release builds. A crash during judging, or in a tester's
hands, has to be visible with a readable stack trace, and the crash-free rate
has to count only real crashes. Recording bloc errors matters most: every
feature's logic lives in a bloc, so without the observer, most failures
would never be reported.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** App Check (next change); setting a Crashlytics
user identifier, which arrives with auth and is the uid only.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | None | |
| Data protection | **Affected** | Crash reports leave the device; the rule in §1 keeps patient data out of them |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low. The handlers only report; behaviour on error is
unchanged.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Added the framework and platform handlers, with the stream-teardown
   exception.
2. On review: added bloc-error recording, switched collection off outside
   release builds, trimmed the comments, and confirmed the Android and iOS
   symbol uploads.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `flutter analyze lib test` | No issues |
| `make bloc-lint` | 0 issues |
| `flutter test` | 8 passed |
| `dart format` | No changes |
| `make spell` | Pass |
| A test crash from a release build appearing in the console | Not yet: verify on the first App Distribution build |
| Certification | 2026-10-27 — Theo (startup error handling; no feature code) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | — | N/A | — | — |
| Compliance Officer | §4 flags data protection | Covered by CTO | 2026-10-27 | Approved — ids and types only |
| Clinical Reviewer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Force a test crash on the first App Distribution build and confirm a
  deobfuscated stack trace in the Crashlytics console.

## 10. Related records

- Previous CRQ: [CRQ-0008](./CRQ-0008-production-apk-workflow.md)
- Architecture: [`mobile_architecture.md` §10](../../architecture/reports/mobile_architecture.md#10-security)
