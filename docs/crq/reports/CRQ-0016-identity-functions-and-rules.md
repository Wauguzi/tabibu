# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0016 |
| Title | Identity functions, Firestore and Storage rules, and their emulator tests |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 (not deployed) |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

This implements the server side of
[CRQ-0014](./CRQ-0014-identity-data-model.md), as
[architecture §6.1](../../architecture/reports/mobile_architecture.md#61-identity-patients-practitioners-and-the-directory)
describes it.

1. **`functions/`** (TypeScript, Node 22, `europe-west1`, inside the
   database's `eur3` region; at most 10 instances until App Check is
   enforced). Each handler is a pure function of the database, Auth and the
   caller, behind a thin `onCall` wrapper:

   | Function | Does |
   |---|---|
   | `completePatientSignUp` | Validates the biodata, normalises the phone to `+254…`, resolves the county and sub-county from the bundled lists and takes the sub-county's geohash. In one transaction it looks for a record with the same phone and birth date: an unregistered match returns `clinicRecordExists` and writes nothing (T-15); a registered match is refused. Otherwise it creates `patients/{uid}`, then sets `role: patient`. A retry finishes the job |
   | `completePractitionerSignUp` | Requires the terms, a KMPDC number no other account holds, a license URL inside the caller's own `licenses/` folder, and an operational facility from the bundled list, whose fields it copies. Creates `doctors/{uid}` as `Pending` and **sets no claim** (T-14) |
   | `verifyPractitioner` | Admin claim only. Re-checks the KMPDC number (the owner may edit it until verified), sets the status, and sets or removes the role claim, keeping any other claim |
   | `addPatient` | Doctors only. The same duplicate check: the same doctor gets their record back; another doctor's patient is refused (T-16) |
   | `linkPatientAccount` | A doctor on the record's care team attaches a role-less account, by email, in person |
   | `syncPractitioner` | Trigger on `doctors/{uid}`: writes the public projection to `practitioners/{uid}` while `Verified`, deletes it otherwise. Facility fields come from the server's list |

   Refusals carry a stable reason key (`invalidPhone`, `kmpdcNumberInUse`,
   …) that the app maps to a translated `AppError`.
2. **`functions/data/`**: a copy of `assets/data/`, written by
   `make facilities` and checked byte for byte by a test.
3. **`firestore.rules`**: patients, doctors and practitioners as §6.1
   says; everything else closed. Clients create nothing. Owners change only
   their listed fields, with types, lengths, the phone format and picture
   URLs that must point into the record's own Storage folder. A patient can
   remove a doctor but never add one. The KMPDC number and license lock once
   verified; a rejected practitioner may move only to `Pending`.
4. **`storage.rules`**: `profilePictures/{id}` and `licenses/{uid}`, as §6.1
   says. Images under 3 MB (a license may be a PDF). A linked patient owns
   their record's folder through its `uid`; a doctor on an unregistered
   patient's care team may upload their picture. Licenses lock once
   verified. Everything else closed.
5. **`firebase.json`**: Firestore, Storage, functions (lint and build as
   predeploy steps, tests excluded from the upload) and the emulators.
   `firestore.indexes.json` is empty: the duplicate checks use equality
   filters only, which need no composite index.
6. **Make:** `functions-test` runs lint, build and the handler suites on the
   Firestore and Auth emulators. `rules-test` runs on the `demo-tabibu`
   project id, so neither suite can reach the live project.
7. Docs: architecture §14 and §16 item 5; threat model T-9 and T-14 to T-16
   moved to "in place, not deployed".

## 2. Business justification

Sign-up is the first screen a judge uses, and these are the controls
behind it. Without them, anyone could claim to be a pathologist, take over a
doctor-added record, or join a care team uninvited. Rules and functions go
first so the app is built against the real boundary.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- `inviteToCase`, which arrives with cases.
- A callable to change a practitioner's facility or a patient's sub-county.
  Both are server-derived, so the rules refuse them from a client for now.
- Counter triggers.
- The admin seed script.
- Deploying.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | Affected | Implements §6.1; no change to it |
| Roles & case scoping | **Affected** | Claims are set here and nowhere else |
| Clinical safety | Affected | An unverified practitioner has no role, so reaches no case (S-2) |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | First rules; T-9, T-14 to T-16 enforced |
| Data protection | Affected | Licenses readable by owner and admin only; directory has no contact details |
| Design system / UI consistency | None | |
| Localisation | Affected | Reason keys need `en` and `sw` strings in the app |
| Existing data | None | Nothing deployed, no data |

## 5. Risk & rollback plan

- **A download URL works for anyone holding it** (CRQ-0014 §5). The rules
  stop a profile pointing at another person's folder; they cannot make a
  leaked URL stop working.
- **Read cost in Storage rules.** A picture or license upload costs one or
  two Firestore reads. That's acceptable for uploads.
- **Changing claims needs a token refresh.** After sign-up or verification,
  the app must refresh the ID token before the router reads the claim.
  That's for the auth client to handle; noted here so it isn't lost.
- **The emulator reports some denials as "evaluation error".** Checked with
  `debug()` on RT-18 and RT-19: the field check evaluates `false`, and the
  denial is for the intended reason. Each denial test sits beside an allowed
  write that differs only in the field under test.

**Rollback plan:** nothing is deployed. After deploy, `make deploy-rules`
and `deploy-storage` from the previous commit restore the rules;
`firebase functions:delete` removes a function.

## 6. Implementation plan

1. Pure handlers, thin wrappers, reason-key
   refusals, the geohash pinned to the app's vectors.
2. Tested the handlers on the emulators rather than a hand-written fake, so
   transactions and query reads are the real ones.
3. Wrote the rules from §6.1's "written by" column, then a test for each
   allowed and refused path.
4. Deploy after the pull request's review: rules, Storage, then functions.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make functions-test` (eslint, tsc, mocha on emulators) | 31 passing |
| `make rules-test` (Firestore and Storage emulators) | 31 passing (RT-1 to RT-31) |
| Denial reason, `debug()` on RT-18 and RT-19 | `hasOnly` false on the forbidden key |
| `make spell` and cspell on rules and TypeScript | Pass |
| `make secrets` (staged) | No leaks |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-10-30 | Approved — [PR #6](https://github.com/Wauguzi/tabibu/pull/6), 5/5 at round 3 |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — claims server-side only; every collection closed by default |
| Clinical Reviewer | Clinical safety affected | Covered by CTO | 2026-10-27 | Approved — no unverified practitioner reaches a case |
| Compliance Officer | Data protection affected | Covered by CTO | 2026-10-27 | Approved |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- After deploy, confirm the claim on a real sign-up in each role. Confirm the
  directory entry appears on verification and disappears on rejection.
- Add the case rules with cases, and re-run RT-1 to RT-31 alongside them.

## 10. Related records

- Previous CRQ: [CRQ-0015](./CRQ-0015-nairobi-facility-data.md)
- Data model: [CRQ-0014](./CRQ-0014-identity-data-model.md)
