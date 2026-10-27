# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0021 |
| Title | Launcher icons on Android and iOS: the missing iOS icon set, and a guard against 16-bit logos |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Standard |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

1. **iOS `AppIcon.appiconset`** is restored with Xcode's standard
   `Contents.json`. The template never shipped one, so `make icons` failed
   writing into it, and iOS builds had no icon.
2. **One icon set for every flavor.** The development and staging builds
   named `AppIcon-dev` and `AppIcon-stg`, which never existed;
   `flutter_launcher_icons` points all of them at `AppIcon`.
3. **8-bit logo.** The generator strips alpha for iOS, as App Store Connect
   requires. On a 16-bit PNG that produced a black icon, so the logo is
   converted to 8-bit, which looks the same.
4. **`make icons` refuses a logo that is not 8-bit**, with a message saying
   how to fix it.
5. Assets regenerated (`Assets.icons.*`).

## 2. Business justification

The icon is the first thing a judge sees on a device, and a black icon on
iOS looks broken.

## 3. Scope

**In scope:** everything in §1. **Explicitly out of scope:** the splash
screen, the notification icon (CRQ-0022).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Design system / UI consistency | Affected | The brand icon on both platforms |
| Everything else | None | |

## 5. Risk & rollback plan

- **The logo is 512 px**, so the 1024 px App Store icon is upscaled. Export a
  1024 px, 8-bit logo before a store submission.

**Rollback plan:** revert the commits.

## 6. Implementation plan

Diagnosed the missing asset catalog and the 16-bit source against the
reference (whose logo is 8-bit), restored the catalog, converted the logo,
and added the guard.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make icons` | Succeeds; refuses the 16-bit logo with a message |
| iOS 1024 px icon | No alpha; the logo on teal, checked visually |
| Android adaptive icon | The logo on teal, checked visually |
| `make analyze`, `make test`, `make spell` | Pass |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Lead Designer | Design system affected | Covered by CTO | 2026-10-27 | Approved |

## 9. Post-implementation review

- Replace the logo with a 1024 px export before store submission.

## 10. Related records

- Previous CRQ: [CRQ-0020](./CRQ-0020-session-layer-auth-and-encrypted-cache.md)
