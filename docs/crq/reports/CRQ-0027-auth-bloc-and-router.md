# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0027 |
| Title | Auth, sign-up and theme blocs; typed router with a role-claim guard; app shell; analytics, connectivity, force-update and push-token services |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-28 |
| Date implemented | 2026-10-28 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

The session layer (CRQ-0020) could resolve who someone is, but nothing
drove it and nothing routed on it. This change adds the state, the routes and
the services they need. Screens come in brief 04; every route renders a
placeholder until its screen exists.

1. **`AuthBloc`** (`features/auth/blocs/auth_bloc/`) owns every action that
   changes the session:
   - load the session, sign in by email or Google, create the account,
     reset the password, submit patient or practitioner sign-up, sign out;
   - every state carries the session, so the router and screens read it from
     whichever state is current;
   - failures share `AuthOperationFailure`, carrying an `AppError`;
   - handlers catch `Object`, not `Exception`, so an `Error` still ends in a
     failure state instead of a spinner that never stops;
   - every action is `droppable()`, so a double tap sends once;
   - a network action checks connectivity first and fails fast with
     `noInternet`. Loading the session and signing out do not: offline, the
     cache answers, and signing out must always work;
   - one analytics event per action;
   - after any sign-in it binds the uid to RASP reports, tags analytics with
     the role, and registers the device's push token. None of these can fail
     the sign-in.
2. **Sign-up.**
   - `SignUpDraft` (Freezed) holds what the C to F screens collect. It never
     holds the password: the account is created on the screen that asks for
     it.
   - Its `toPatientRequest` and `checkPractitioner` throw the same
     `AppError` the server would, before any network call.
   - `SignUpBloc` only holds the draft, so going back a step keeps it. The
     draft is cleared after sign-up or sign-out.
   - Practitioner submission uploads the photo and one or two license files
     to the caller's own folders (`ProfileStorage`), then sends their URLs.
     Files over the rules' limits (3 MB, 10 MB) are refused on the device
     with a new `AppError.fileTooLarge`.
3. **Push tokens.**
   - Added with `arrayUnion` and removed with `arrayRemove`, so another
     device's token written since the session was read is never lost.
   - At the rules' ten, the oldest is removed first.
   - Sign-out removes this device's token **before** leaving Firebase, while
     it can still write, so a signed-out phone stops receiving that person's
     pushes. Offline, the removal is skipped and the sign-out still happens.
   - A rotated token is registered again.
4. **`NotificationService`** gains the device token, token refreshes,
   push taps (joining the existing tap stream), the push that launched the
   app, and a local banner for a push received in the foreground on Android.
5. **Router** (`core/routing/`), as architecture §8 now describes:
   - typed routes for every designed screen A1 to F5, the update screen and
     one home per role;
   - the decision route, deciding through `resolveLanding`;
   - the guard, `guardLocation`, reading the role claims on the session;
   - both pure functions, so each rule is a unit test.
6. **Services:**
   - `AnalyticsService`: typed events whose parameters are roles and
     methods only, never personal data; failures swallowed;
   - `InternetService`;
   - `AppUpdateService`: stops a build only when `force_update` is on and
     the build is below `min_required_version`; version comparison is
     numeric, so `1.0.10` is after `1.0.09`;
   - `NotificationsHelper`: localised account notices (patient welcome,
     licence received), in the language chosen on A2.
7. **App shell:**
   - `BlocsHelper.initializeBlocs()` lists the app-wide blocs, and
     `bootstrap` mounts them in the one `MultiBlocProvider` around `App`;
   - `App` builds the router from the provided `AuthBloc`, reads the saved
     language for its locale and switches on `LanguageChangeSuccess`;
   - on a real return from the background it re-fetches Remote Config,
     re-runs the update gate, and re-resolves a signed-in session;
   - `MaterialApp.builder` scales type up on tablets, keeping the person's
     own text scaling.
8. **`ThemeBloc`** holds only the choice (light, dark, the device's), read
   synchronously at start through `ThemeHelper`; `App` maps it to
   `themeMode`. It imports no Flutter and never hooks the platform's
   brightness callback, which the framework itself relies on.
9. **Language:** `LanguageChangeRequested` saves the choice on the device,
   then on the signed-in profile, which sets the language of its push
   notifications.
10. **Logging:** the two events that carry a password never print
    themselves, because the bloc observer logs what passes through it.

## 2. Business justification

Nothing in the app can be reached until a person can sign in, sign up and be
sent to the right place. The guard is also a security control: a patient
must not reach a pathologist's screen by typing a URL on the web demo.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**

- the screens (brief 04);
- the theme-change reveal animation, which wraps `MaterialApp.builder`'s
  child once brief 03 delivers the widget;
- routing a notification tap, which needs the case and alert screens;
- an audit log of sign-ins and sign-ups, which would need a Cloud Function
  and rules of its own;
- each role's tabbed shell, until the tabs are designed.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| App state and navigation | **Affected** | `App` now builds the router and provides both blocs |
| Firestore writes | Affected | `fcmTokens` and `lastUpdatedAt` on the owner's profile, already allowed by the rules |
| Storage writes | Affected | Into the caller's own `profilePictures/` and `licenses/` folders, already allowed |
| Analytics | Affected | New events; no personal data |
| Localisation | Affected | `errorFileTooLarge`, two notices and the theme names, in English and Kiswahili |
| Security (rules, App Check, RASP, secrets) | Affected | Role-claim guard; RASP bound after sign-in; no rule change |

## 5. Risk & rollback plan

- **The guard trusts the session's claims until the next resolve.** A role
  removed on the server is enforced by the rules at once, and in the app
  from the next cold start. The guard never grants data access.
- **Offline with an expired token**, the session still resolves from the
  cache, so the guard and the rules can disagree until the device is back
  online. The rules win.
- **A token left behind after an offline sign-out** keeps reaching that
  device until it rotates out at ten. A function that prunes tokens FCM
  reports as unregistered would close this.
- **The Kiswahili notices are my best effort**, as for CRQ-0026.

**Rollback plan:** revert the commit. `App` then shows its placeholder
again; no data or rules change.

## 6. Implementation plan

1. Write the services, the uploads and the token handling.
2. Write the blocs, then the routes and the decision route.
3. Write the tests, including the `App` driving the real router.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make test` | All passing, including: `AuthBloc` (15), `SignUpBloc` (2), `ThemeBloc` and `ThemeHelper`, language change, tablet text scaling, the draft, `ProfileStorage` limits, `AuthHelper` tokens, uploads and sign-out order, `resolveLanding` and `guardLocation`, version comparison, the update gate, and `App`, mounted as `bootstrap` mounts it, landing first-run, returning and outdated cases in the saved language |
| `make analyze`, `make bloc-lint`, `make fmt` | Clean |
| `make spell` | Pass |
| On a device | With brief 04's screens |
| Certification | 2026-10-28 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-28 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | Authentication and authorisation | Covered by CTO | 2026-10-28 | Approved — guard by claim, no password in state or logs, tokens removed on sign-out |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No impact in §4 |
| Compliance Officer | §4 flags data protection impact | N/A | — | No impact in §4 |
| Lead Designer | §4 flags design-system impact | Covered by CTO | 2026-10-28 | Approved |

## 9. Post-implementation review

- On a device, sign up each role end to end and confirm the token on the
  profile, the notices, and the landing after a cold start.
- On the web demo, type a doctor URL as a patient and confirm the redirect.

## 10. Related records

- Previous CRQ: [CRQ-0026](./CRQ-0026-specialties-and-license-files.md)
- Session layer: [CRQ-0020](./CRQ-0020-session-layer-auth-and-encrypted-cache.md)
- Notifications: [CRQ-0022](./CRQ-0022-notification-service.md)
