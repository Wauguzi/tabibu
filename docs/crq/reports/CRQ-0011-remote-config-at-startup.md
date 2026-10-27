# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0011 |
| Title | Remote Config at startup: in-app defaults, a bounded fetch, and the force-update parameters |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

1. **`lib/bootstrap.dart`**, after the error handlers and before `runApp`:
   - Settings: release builds fetch at most every 12 hours; debug builds
     every launch, so console changes show at once. The fetch timeout is
     the bootstrap timeout.
   - In-app defaults for every parameter the app reads, chosen so that a
     config that was never fetched lets the app through.
   - `fetchAndActivate`, bounded by the bootstrap timeout. On any failure
     the defaults stand, and debug builds log why.
   - The whole step is inside one `try`, including
     `FirebaseRemoteConfig.instance`. Read outside it, a failed
     `Firebase.initializeApp()` would throw before `runApp` and leave the
     app on the splash screen.
2. **Parameters published in the console** (version 1):

   | Parameter | Type | Console value | In-app default |
   |---|---|---|---|
   | `min_required_version` | String | `1.0.01` | `''` (no gate) |
   | `force_update` | Boolean | `true` (hard block; `false` = soft prompt) | `false` |
   | `store_url_android` | String | `''` | `''` |
   | `store_url_ios` | String | `''` | `''` |
   | `update_title` | String | `Update Available` | `''` |
   | `update_message` | String | `A new version is required.` | `''` |

   `update_title` and `update_message` are optional overrides: the
   force-update screen falls back to its `en`/`sw` strings when they are
   empty, so the app never shows English-only text from the console.
3. **Docs:** architecture §10; Greptile rules for defaults and for
   Remote Config text.

## 2. Business justification

The force-update gate lets me retire a broken build, or one that predates
App Check enforcement, without waiting for users to update. It needs the
config fetched before the first route is chosen, and it must never block
startup when the network is down.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the version comparison, the force-update
screen and its route guard (auth branch); real-time Remote Config updates;
the AI kill switches, which get their defaults when their features land.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | None | Non-secret values only (T-13) |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | Noted | Console text is an override; ARB strings are the source |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low. Every failure path falls back to defaults that let
the app through.

**Worst-case startup:** each bootstrap step is bounded at 10 seconds, and
four steps now wait before the first frame (Firebase, App Check, Crashlytics
collection, Remote Config). On a network that hangs rather than fails, the
splash can last up to 40 seconds. Revisit if that shows up in testing.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Added initialisation in `bootstrap`.
2. On review: moved the instance read inside the `try`, caught all
   throwables, added the defaults, bounded the fetch, used a zero fetch
   interval in debug, and logged like the rest of `bootstrap`.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `flutter analyze lib test` | No issues |
| `make bloc-lint` | 0 issues |
| `flutter test` | 8 passed |
| `dart format` | No changes |
| `make spell` | Pass |
| Debug run logs the fetched values | Not yet: on the next `make run-dev` |
| Certification | 2026-10-27 — Theo (startup only; no feature code) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | — | N/A | — | — |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Run `make run-dev` and confirm the log shows `min_required_version=1.0.01`
  and `force_update=true`.
- When the gate lands, compare versions numerically per part:
  `1.0.01` and `1.0.1` are the same version.

## 10. Related records

- Previous CRQ: [CRQ-0010](./CRQ-0010-app-check-activation.md)
- Architecture: [`mobile_architecture.md` §10](../../architecture/reports/mobile_architecture.md#10-security)
