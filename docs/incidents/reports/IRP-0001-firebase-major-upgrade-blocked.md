# Incident Report (IRP) — Tabibu

| Field | Value |
|---|---|
| Incident ID | IRP-0001 |
| Title | Dependabot's FlutterFire major upgrade fails CI and can't merge |
| Severity / Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Clinical-safety incident | No |
| Status | Open, deferred until the current release ships ([#7](https://github.com/Wauguzi/tabibu/issues/7)) |
| Detected by | CI: the `build` job on Dependabot's [#5](https://github.com/Wauguzi/tabibu/pull/5) |
| Date/time detected | 2026-10-30 08:55 EAT |
| Date/time resolved | — |
| Affected area(s) | Dependencies: the FlutterFire suite; `NotificationService`; the test fakes |
| Affected users | None: the upgrade never merged. Every iOS user keeps `cloud_firestore` 6.10.x without 7.1.0's certificate fix until it does |

## 1. Summary

Dependabot opened #5 to move eleven FlutterFire packages to their new majors
together. Its `build` job failed at `flutter analyze`, so the upgrade can't
merge. Nothing reached a user; the cost is a security fix that waits.

## 2. Impact

- **No user impact.** `main` stays on the versions it was tested and
  certified with.
- **A security fix waits.** `cloud_firestore` 7.1.0 removes root
  certificates tied to compromised eMudhra intermediate CAs from its iOS
  trust store
  ([changelog](https://pub.dev/packages/cloud_firestore/changelog)).
- **Two latent breaks** would follow a naive merge: the test fake falls
  behind `cloud_firestore`, and the device-token API changes shape.

## 3. Clinical, security & compliance sign-off

| Reviewer | Required when | Name | Assessment |
|---|---|---|---|
| Clinical Reviewer | Any AI output, report, result or alert reached a person it should not have, or reached them early | N/A — no clinical dimension | No case, result or alert path is involved |
| Security Analyst | Any security, auth, rules, App Check or RASP dimension to the cause | Covered by CTO | The delay keeps the iOS trust-store fix out; no rule, claim or App Check change. Accepted for the current release, tracked in #7 |
| Compliance Officer | Any patient-identifying field left a case, was exposed, or reached a model endpoint it should not have | N/A — no data exposure | — |

## 4. Timeline

| Time (EAT) | Event |
|---|---|
| 2026-10-30 08:55 | #5's `build` job fails at `flutter analyze` |
| 2026-10-30, morning | The bump is held: an earlier attempt at the same majors had been blocked |
| 2026-10-30, morning | Root cause found by applying #5's versions to the current code in a scratch worktree |
| 2026-10-30, morning | [#7](https://github.com/Wauguzi/tabibu/issues/7) opened to track the upgrade; this record filed |

## 5. Root cause analysis

**5 Whys:**
1. Why did #5 fail? → `flutter analyze` reported two `deprecated_member_use`
   infos, which the build treats as failures.
2. Why are they deprecated? → `firebase_messaging` 17 replaces `getToken()`
   and `onTokenRefresh` with the FID registration API (`register()`,
   `onRegistered`), and `NotificationService` uses both.
3. Why didn't Dependabot handle it? → It bumps versions, not call sites, and
   it groups the eleven packages FlutterFire releases together, but not
   `fake_cloud_firestore`, which has to move with `cloud_firestore`.
4. Why does the fake matter? → `fake_cloud_firestore` 4.4.0 doesn't
   implement `FieldValue.minimum`/`maximum`, added in `cloud_firestore`
   7.1.0. Once the analyzer is clean, the tests that load it would fail.
5. Why was neither caught earlier? → A major upgrade across a whole suite
   carries API and test-double changes that only a deliberate migration
   covers. The repo had no record of what blocks it, so each attempt started
   from scratch.

A third trap waits on iOS: `cloud_firestore` 7.0.0 pins the Firebase iOS SDK
to exactly 13.0.0 while the rest of the suite pins 13.1.1, so Swift Package
Manager can't resolve them together. Taking 7.1.0, as #5 does, avoids it.

## 6. Resolution

Not yet resolved. Deferred until the current release ships (#7):

- the eleven bumps from #5, plus `fake_cloud_firestore` ^4.5.0, which
  supports `cloud_firestore` ^7.1.0
  ([changelog](https://pub.dev/packages/fake_cloud_firestore/changelog));
- `NotificationService` moved to `register()`/`onRegistered`, with tests
  for the token on sign-in, on rotation and on sign-out;
- an iOS build that resolves its Swift packages, and a certified run on both
  platforms.

Alternatives rejected: merging #5 with the deprecations silenced (it hides an
API that will be removed), and pinning the old fake (the tests would break at
load time).

## 7. Verification

| Check | Result |
|---|---|
| Root cause reproduced before the fix | Yes: #5's versions on the current code fail `flutter analyze` on the two `NotificationService` calls |
| Fix verified to resolve it | Partly: with `fake_cloud_firestore` 4.5.0 all 777 tests pass on the new versions; the messaging migration is still open |
| `make test` | Pass on `main`'s versions; pass on the new versions with the 4.5.0 fake |
| Regression test added | Not yet; comes with the migration (#7) |
| Certification | Pending, with the upgrade |

## 8. Lessons learned

- A grouped Dependabot update is a start, not a fix. A suite major needs the
  test doubles that mirror it, and every deprecated call site, moved in the
  same branch.
- What blocks an upgrade is worth writing down where the next attempt will
  find it. This record and #7 now hold it.

## 9. Follow-up actions

| Action | Owner | Status |
|---|---|---|
| Upgrade the suite with the fake and the messaging migration ([#7](https://github.com/Wauguzi/tabibu/issues/7)) | Theo | Open — after the current release |
| Keep #5 open, unmerged, as the reminder; close it in favour of the upgrade branch | Theo | Open |

## 10. Related records

- Related CRQ(s): [CRQ-0022](../../crq/reports/CRQ-0022-notification-service.md) (notification service)
- Related Problem record(s): none, a one-off upgrade
- Tracking issue: [#7](https://github.com/Wauguzi/tabibu/issues/7); Dependabot pull request: [#5](https://github.com/Wauguzi/tabibu/pull/5)
