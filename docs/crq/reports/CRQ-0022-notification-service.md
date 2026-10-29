# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0022 |
| Title | Notification service: three channels, a kept Android icon, iOS presentation, and a show that never throws |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Fitted to
[the notifications engine](../../architecture/reports/notifications_engine.md#7-delivery-surfaces).

1. **`NotificationService`** (`lib/core/services/`) wraps
   `flutter_local_notifications`:
   - one `androidIcon` constant used at initialise and on every show;
   - `showNotification` never throws and records failures to Crashlytics
     as non-fatal, guarded in case Firebase never initialised;
   - a stream of tapped payloads and the payload that launched the app, for
     the router's tap handler;
   - the permission request and the open-settings fallback.

   It is registered in DI and initialised in bootstrap, bounded, because it
   raises the OS permission dialog before the first frame.
2. **Three Android channels**, named from the ARB files in the device's
   language:
   - **Account and security**: sign-in, sign-up, password reset and RASP
     notices.
   - **Alerts**: approved outbreak alerts.
   - **Case updates**: case discussions and chat, invitations to a case or
     MDT, signed reports, released results.
3. **Android:**
   - `res/drawable/ic_notification.xml` is a white vector drawable built from
     the three paths of `assets/icons/logo_transparent_primary.svg`.
     Android draws the small icon as a silhouette tinted with the brand
     colour.
   - `res/raw/keep.xml` keeps that icon from R8's resource shrinker. It is
     resolved by name at runtime, which the shrinker cannot see. Without it,
     the plugin's initialise fails in release builds only, and every later
     show throws.
   - `POST_NOTIFICATIONS` (Android 13+) and `INTERNET` are declared rather
     than inherited.
   - `allowBackup="false"` keeps Android's auto-backup from copying the
     app's files (the encrypted cache included) off the device (T-11).
   - Core-library desugaring, which the plugin needs.
4. **iOS:**
   - The app delegate sets the notification-centre delegate, and each
     notification asks for a banner, so foreground notifications show.
   - `UIBackgroundModes` declares `remote-notification` for FCM.
5. Docs: notifications engine §7.

## 2. Business justification

Sign-in, sign-up and reset confirmations, security notices, case discussions,
MDT invitations and alerts all reach people this way. The guarantees are
against two known failure modes: an icon stripped from release builds,
and a notification failure that stops a sign-in.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- FCM push handling and token registration, which arrive with the inbox.
- The tap handler in the router.
- The iOS Push Notifications capability, which needs the Apple Developer
  account.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Clinical safety | Affected | Callers never put a diagnosis, name or result in notification text (S-3); stated on the service |
| Security (rules, App Check, RASP, secrets) | Affected | Backups disabled; the RASP notices will use the account channel |
| Data protection | Affected | Lock-screen text is generic by contract |
| Localisation | Affected | Six channel strings in `en` and `sw` |
| Everything else | None | |

## 5. Risk & rollback plan

- **Channel settings are sticky on Android.** Once created, a channel's
  importance cannot be raised by the app, so the importances here are
  deliberate.
- **The permission dialog appears at first launch.**
  If that turns out to be too early for onboarding, move the request behind
  `requestOrOpenSettings` and drop it from `initialize`.

**Rollback plan:** revert the commit.

## 6. Implementation plan

Wrote the service, manifest entries, delegate, `keep.xml` and bootstrap
step; added channels and the tap stream; built a release APK through R8 to
check the icon survives shrinking.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| Service tests (icon and channel on show, never throws, launch payload, channel names in `en`/`sw`) | 6 passing |
| The named icon exists and `keep.xml` keeps it | Test passing |
| Release APK through R8 | `drawable/ic_notification` present after shrinking (CRQ-0023) |
| `make analyze`, `make test`, `make spell` | Pass |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Clinical Reviewer | Notification text | Covered by CTO | 2026-10-27 | Approved — generic by contract |
| Lead Designer | — | N/A | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | 2026-10-27 | Approved |

## 9. Post-implementation review

- On a real Android device with a release build, show a notification and
  check the icon. On iPhone, check that a foreground notification appears.

## 10. Related records

- Previous CRQ: [CRQ-0021](./CRQ-0021-launcher-icons.md)
