# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0019 |
| Title | Identity models, facility reference data, enums, translated errors, and dependency injection |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Models, enums and strings were implemented by Muse Code from a brief
(CRQ-0013). The DI module and Google sign-in helper are mine. I reviewed and
gated the whole change.

1. **Model pairs** in [architecture §6.1](../../architecture/reports/mobile_architecture.md#61-identity-patients-practitioners-and-the-directory)
   field order:
   - `PatientModel`/`PatientHive` (typeId 0).
   - `DoctorModel`/`DoctorHive` (1).
   - `PractitionerModel`/`PractitionerHive` (2).

   `synced` is client-only and never in `toJson()`, because the rules refuse
   unknown keys; a test enforces this. The typeId rows move from reserved
   to added. The adapters are registered with the Hive helper in the next
   change.
2. **Reference data:**
   - `FacilityModel`, `SubCountyModel` and `CountyModel`, Freezed only.
   - `FacilitiesHelper` loads the bundled lists once. Its search matches
     name, ward or sub-county. It orders results nearest-first by shared
     geohash prefix when given a location, and otherwise puts operational
     facilities first.
3. **Enums:** `Role`, `Sex`, `VerificationStatus`, `AppLanguage` and
   `PractitionerTitle`, each with translated descriptions. Parsing never
   throws, because a getter that throws in `build()` takes the screen down:
   - An unknown sex is `null` ("not recorded"), never a guess.
   - An unknown verification status is `pending`, the state with the least
     access.
   - An unknown language is `en`.
4. **`AppError`:**
   - The general and Firebase cases.
   - Every refusal reason the functions return (CRQ-0016), through
     `fromFunctionsException`: a known reason key wins; otherwise the
     Firebase code decides.
   - Two cases for the auth flow.
   - Every case has an `en` and `sw` string. Swahili follows the design
     doc's §7 vocabulary and is best-effort.
5. **DI** (`get_it_helper.dart`):
   - Firebase, secure storage and preferences, registered as a module so
     tests can replace them.
   - Callables go through `FirebaseFunctions.instanceFor(region:
     'europe-west1')`; the default instance calls us-central1, where
     nothing is deployed.
6. **`GoogleSignInHelper`** initialises the native plugin with the iOS and
   web OAuth clients. Web signs in through Firebase Auth's popup instead.
7. Generated files (`*.freezed.dart`, `*.g.dart`, the DI config, the Hive
   registrar) are tracked, as `lib/gen/` is.

## 2. Business justification

The auth helper, bloc and screens all read these types. Translated errors
mean no refusal reaches a person as an English code.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the Hive helper and adapter registration, the
auth helper, the router.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | typeIds 0–2 now in use |
| Roles & case scoping | Affected | `Role.fromClaim` resolves unknown claims to no role |
| Clinical safety | Affected | Unknown sex is never guessed |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | None | OAuth client ids are public identifiers |
| Data protection | None | No error string carries patient data |
| Design system / UI consistency | None | |
| Localisation | **Affected** | 62 new keys in `en` and `sw` |
| Existing data | None | |

## 5. Risk & rollback plan

- **Swahili is best-effort.** A native speaker reviews it with the
  vocabulary table (design doc §7). Muse Code flagged its least certain
  terms. I replaced "kagua" (inspect) with "angalia" and "jukumu" (duty)
  with plainer wording.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Brief 02 to Muse Code.
2. Review: changed the throwing parsers, rewrote the two role errors that
   had identical copy for different situations, and applied the Swahili
   fixes Muse Code suggested.
3. Ran every gate on the combined tree.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make gen`, `fmt`, `analyze`, `bloc-lint` | Clean |
| `make test` | 90 passing |
| `make spell` | Pass |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-10-30 | Approved — [PR #6](https://github.com/Wauguzi/tabibu/pull/6), 5/5 at round 3 |
| Security Analyst | — | N/A | — | — |
| Clinical Reviewer | Unknown sex handling | Covered by CTO | 2026-10-27 | Approved — null, never guessed |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Native review of the Swahili error strings.

## 10. Related records

- Previous CRQ: [CRQ-0018](./CRQ-0018-demo-seed-and-google-sign-in-on-ios.md)
- Data model: [CRQ-0014](./CRQ-0014-identity-data-model.md)
