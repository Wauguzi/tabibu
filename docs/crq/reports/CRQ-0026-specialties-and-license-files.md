# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0026 |
| Title | Practitioner specialties as a list, one or two license files, a required photo, and an information-security header on the Firestore rules |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-28 |
| Date implemented | 2026-10-28 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

The sign-up screens asked for things the identity model (CRQ-0014,
CRQ-0016) could not hold:

- a pathologist reports in several areas;
- a license scan often comes with a separate certificate;
- the directory is chosen partly by face.

This change makes the model fit the screens.

1. **`specialties` replaces `specialization`** on `doctors` and
   `practitioners`.
   - It holds one to five values (`MAX_SPECIALTIES`).
   - Each value comes from the role's own list: five pathology areas, or
     fifteen clinical specialties. The lists are `PATHOLOGY_SPECIALTIES` and
     `CLINICAL_SPECIALTIES` in `functions/src/identity.ts`.
   - Values are deduplicated and stored in list order, so the same choice
     always gives the same array.
   - Anything else is refused with `invalidSpecialties`.
2. **`licenseUrls` replaces `licenseUrl`.**
   - It holds one or two files (`MAX_LICENSE_FILES`), with no duplicates.
   - Each file must be in the caller's own `licenses/{uid}/` folder;
     anything else is refused with `invalidLicense`.
   - The Storage limit for license files rises from 3 MB to 10 MB, because
     a multi-page scanned PDF does not fit in 3 MB.
   - The rules on what is final are unchanged: the owner may edit the files
     until `Verified`, and they are never public.
3. **The profile picture is required** at practitioner sign-up, and an
   owner update cannot empty it or point it outside the owner's folder.
4. **`isAvailable` is set at sign-up.** The server defaults it to `true`
   and refuses a non-boolean value with `invalidAvailability`.
5. **The same lists in three places stay identical.**
   - `firestore.rules` cannot import, and the app needs the lists offline,
     so there are three copies: the functions' lists, the rules'
     `specialties()` and the app's `enum Specialty`.
   - `functions/src/reference-data.test.ts` reads the other two as text and
     fails when either drifts from the functions' lists.
6. **An information-security header on `firestore.rules`**, for a reader
   who has not seen the code. It covers:
   - the collection layout, the actors and the helpers;
   - a table per collection;
   - the cross-cutting concerns;
   - each threat scenario, mapped to the RT test that proves it fails;
   - the security checklist with its status;
   - the full RT-1 to RT-35 list.

   It carries the date it was last updated and the passing count. **Any
   change to the rules updates the header in the same commit.**
7. **App:**
   - `DoctorModel`, `PractitionerModel` and their Hive mirrors are
     regenerated.
   - `PractitionerSignUpRequest` sends `specialties`, `licenseUrls` and
     `isAvailable`.
   - `AppError.invalidSpecialties` replaces `invalidSpecialization`, and
     `invalidAvailability` is added.
   - Specialty names and pathology hints are added in English and
     Kiswahili.
8. **Seed:** each practitioner gets a license file, a profile picture and
   two specialties.
9. **Functions test runner:** mocha runs with
   `--no-experimental-strip-types`. Node 24 strips types natively, which
   bypassed `ts-node` and broke the CommonJS imports.

## 2. Business justification

A patient looking for a doctor needs to see what that doctor treats and
what they look like. A pathologist reviewing a case should be someone who
reports in that area. A doctor who cannot upload both pages of their
license, or a certificate with it, cannot finish sign-up.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**

- the sign-up screens themselves (brief 04);
- searching the directory by specialty;
- deploying the rules and functions, which happens after Greptile.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Firestore and Storage rules | **Affected** | New field checks on `doctors`; license size 10 MB |
| Cloud Functions | **Affected** | Sign-up validation, the directory sync, the seed |
| App models and Hive cache | Affected | Field indices kept in Freezed order; safe only because no build has shipped (architecture §6) |
| Localisation | Affected | New strings in `app_en.arb` and `app_sw.arb` |
| Security (rules, App Check, RASP, secrets) | Affected | License files stay owner-only and final once verified; no new public field |

## 5. Risk & rollback plan

- **Three copies of the lists can drift.** The drift test fails on any
  difference. Red proof: removing one clinical specialty from the rules
  made the test fail, and restoring it made it pass.
- **Hive field types changed at reused indices** (`specialties` at 6 and 8,
  `licenseUrls` at 11). This is harmless before the first release. Once a
  build ships, a type change takes a new index.
- **The Kiswahili specialty names are a best effort.** A clinician who
  reads Kiswahili should review them before the pilot.
- **No live data uses the old fields.** The live project has not been
  seeded, so there is nothing to migrate.

**Rollback plan:** revert the commit. Nothing is deployed until after
review.

## 6. Implementation plan

1. Functions: the lists, the validators and their tests.
2. Rules: the new checks and RT-32 to RT-35, then the header.
3. Storage: the size limit.
4. Dart: models, enum, errors, strings; regenerate.
5. Add the drift test and prove it red, then green.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make functions-test` | 38 passing |
| `make rules-test` | 35 passing (RT-32 specialties, RT-33 one or two files, RT-34 photo kept, RT-35 10 MB) |
| Drift test, red proof | One specialty removed from the rules → fails; restored → passes |
| Flutter model and enum tests | Passing |
| `make analyze`, `make test`, `make spell` | See the pull request |
| Certification | 2026-10-28 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-28 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-10-30 | Approved — [PR #6](https://github.com/Wauguzi/tabibu/pull/6), 5/5 at round 3 |
| Security Analyst | A rules change | Covered by CTO | 2026-10-28 | Approved — no new public field; license files stay owner-only |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No impact in §4 |
| Compliance Officer | Licence scans and the required photo are personal data | Covered by CTO | 2026-10-28 | Approved — owner and admin read licences; Storage rules bound them (CRQ-0036) |
| Lead Designer | §4 flags design-system impact | N/A | — | No impact in §4 |

## 9. Post-implementation review

- After deploy, sign up a test practitioner with two files and three
  specialties, verify them, and confirm the directory entry shows the
  specialties and no license.
- Have the Kiswahili specialty names reviewed.

## 10. Related records

- Previous CRQ: [CRQ-0025](./CRQ-0025-release-drafts.md)
- Identity model: [CRQ-0014](./CRQ-0014-identity-data-model.md)
- Sign-up callables and rules: [CRQ-0016](./CRQ-0016-identity-functions-and-rules.md)
