# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0037 |
| Title | Build and platform: AGP 9 and JVM 17, the native splash, iOS signing and icons, Hosting; the repository's community files |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-29 |
| Date implemented | 2026-10-30 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth`: 61d4a96, b1b0676, 0db5a8e, 29c5573, 8c21890, ec814e2, d923ce5, c5acc63 |

## 1. Description of change

1. **Android**: Android Gradle Plugin 9.1.1, the upgrade CRQ-0023 deferred
   to its own change, with Java and Kotlin compiled for JVM 17.
2. **The native splash** in the brand teal on Android, iOS and the web,
   handing off to A1; the Android manifest kept as the generator writes it.
3. **iOS**:
   - device builds signed with the development team;
   - the template's Icon Composer icons removed, which Xcode used ahead of the
     generated `AppIcon` set, so every flavour showed the template's icon;
   - `RaspConfig.iosTeamId` set to the signing team, so a release is no
     longer flagged as repackaged and closed at launch (CRQ-0024).
4. **Hosting**: `firebase.json` gains the block `make deploy-hosting` needs
   (`build/web`, every path to `index.html`, no-cache on `index.html`,
   `nosniff`).
5. **Community files**: a Contributor Covenant 3.0 code of conduct reported
   through GitHub; a security policy through private vulnerability
   reporting (switched on), which keeps real patient data out of reports and
   commits to an acknowledgement within 3 working days and a decision within
   10; a contributing guide (issues now, outside pull requests after
   judging); bug and feature issue forms that confirm no patient data.

## 2. Business justification

Release builds must run on both platforms for App Distribution testing and
the judges; the web demo must deploy; and a public repository needs a way to
report a vulnerability that does not publish it.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the Play App Signing certificate
([`mobile_architecture.md`](../../architecture/reports/mobile_architecture.md) §16 item 10, at
the first Play upload).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | — |
| Roles & case scoping | None | — |
| Clinical safety | None | — |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | Affected | The RASP team now enforced on iOS; a private vulnerability channel |
| Data protection (PHI, de-identification, model endpoints) | Affected | The security policy and issue forms keep patient data out of reports |
| Design system / UI consistency | Affected | The splash and launcher icons |
| Localisation (en, sw) | None | — |
| Existing data | None | — |

## 5. Risk & rollback plan

**Risk level:** Low.

**Rollback plan:** revert the commits; a build tool upgrade reverts with its
Gradle files. Private vulnerability reporting can be switched off in the
repository settings.

## 6. Implementation plan

1. AGP 9 and JVM 17, with a clean Android build.
2. The splash and icons regenerated; the iOS project's Icon Composer
   references removed and a dev build's asset catalogue checked to hold only
   the generated set.
3. The community files from GitHub's recommended standards.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` | Pass |
| `make analyze` / `make bloc-lint` | Pass |
| `make test` | Pass — 756 tests in the branch |
| Rules tests | N/A |
| Model evaluation | N/A |
| Manual run (device / simulator / web) | A dev iOS simulator build's `Assets.car` holds only the `AppIcon` set; the icon on a device and an iOS release launch pending |
| UI/UX review of the surrounding screen | N/A |
| Certification | Pending — Theo, on the App Distribution build |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-30 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | None |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-30 | Approved |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | 2026-10-30 | Approved — no patient data in reports |
| Lead Designer | §4 flags design-system impact | Covered by CTO | 2026-10-30 | Approved |

## 9. Post-implementation review

- The splash generator writes a viewport that blocks pinch zoom; `make splash`
  now removes the lock after generating, and `web/index.html` allows zoom.
- CRQ-0023 §9's "plan the AGP 9 upgrade" is done here.

## 10. Related records

- Android build: [CRQ-0023](./CRQ-0023-android-toolchain.md); RASP:
  [CRQ-0024](./CRQ-0024-rasp-service.md)
- Previous CRQ: [CRQ-0036](./CRQ-0036-pre-review-hardening.md)
