# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0023 |
| Title | Android builds run again: Kotlin 2.3.20, Gradle 9.3.1, compileSdk 37, one launcher background colour, and no template icons on dev and staging |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Building a release APK to verify CRQ-0022 found that no Android build could
run:

1. **Kotlin 2.2.10 is below Flutter's minimum (2.2.20)**, so the Flutter
   Gradle plugin refused to apply. This affected every Android build,
   including `prod_apk.yaml` in CI. Kotlin is now 2.3.20, which rejects
   the `android { kotlinOptions {} }` DSL, so the JVM target moves to
   `kotlin { compilerOptions {} }`.
2. **Gradle 9.0.0 does not run on Java 25**, the JDK Android Studio bundles
   and Flutter picks locally. The wrapper is now 9.3.1.
3. **`permission_handler_android` compiles against SDK 37**, so the app
   does too (`compileSdk = 37`). `targetSdk` and `minSdk` are unchanged.
4. **Two definitions of `ic_launcher_background`.** `make icons` creates
   `values/colors.xml` (teal), and the template already had
   `values/ic_launcher_background.xml` (white). The resource merge failed on
   the duplicate, a regression from CRQ-0021. The template's file is gone,
   and the generator's survives every rerun.
5. **Dev and staging showed the template's placeholder icon.** The template
   gave both flavors their own launcher resources, which override `main/`,
   so `make icons` only ever changed production. Both folders held nothing
   else and are removed; every flavor now shows the Tabibu icon, as on iOS.
6. Flutter's migrator added `android.builtInKotlin=false` and
   `android.newDsl=false` to `gradle.properties`; they are kept, as Flutter
   expects.

## 2. Business justification

Android builds, including the first CI run and every App Distribution build,
could not run, and dev and staging builds carried a placeholder icon.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the Android Gradle Plugin 9 upgrade. Flutter
warns that 8.12 support will be dropped. AGP 9 changes the DSL and Kotlin
handling, so it gets its own change before Flutter drops 8.x.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| CI | **Affected** | `prod_apk.yaml` could not have built |
| Everything else | None | Bytecode target (Java 11) unchanged |

## 5. Risk & rollback plan

**Rollback plan:** revert the commit. Android builds then fail again until
Kotlin is at least 2.2.20.

## 6. Implementation plan

Diagnosed while building a release APK through R8, with a throwaway key kept
outside the repository; raised each failing version to a current release that builds.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `flutter build apk --release --flavor development` (Java 25, R8) | Built |
| `ic_launcher_background` in the APK | `#ff1f6f78` |
| `drawable/ic_notification` in the APK (CRQ-0022) | Present after resource shrinking |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |

## 9. Post-implementation review

- Plan the AGP 9 upgrade before Flutter drops 8.x support.

## 10. Related records

- Previous CRQ: [CRQ-0022](./CRQ-0022-notification-service.md)
