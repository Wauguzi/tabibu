# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0014 |
| Title | Identity data model: patients, practitioners, the public directory and the bundled Nairobi facility list |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | Design 2026-10-27; code lands across `feat/auth` |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

The schema itself is in
[`mobile_architecture.md` §6.1 and §6.2](../../architecture/reports/mobile_architecture.md#61-identity-patients-practitioners-and-the-directory).
This record says why it has that shape.

1. **No `users` collection.** A person is a role claim plus one profile:
   `patients` or `doctors`. Doctors and pathologists share `doctors`,
   told apart by `isPathologist`. The earlier plan's `users` would have
   duplicated both.
2. **Doctor-added patients have no account.** A doctor can register a
   patient in clinic. Their record gets a generated `patientId`, `uid: ''`
   and `isRegistered: false`. A self-registered patient's `patientId` is
   their Auth uid. Every record stores `uid` and `createdByUid` separately,
   because for a doctor-added patient they differ.
3. **Duplicates are checked in a function.** Firestore rules can read a
   document by path but cannot search a collection by phone number, so
   every `patients` and `doctors` document is created by a callable, which
   searches first.
4. **Sign-up never merges into an existing record (T-15).** A phone number
   and birth date are not proof of identity. With email, password and Google
   sign-in, nothing shows the person signing up owns that phone. A matching
   sign-up creates nothing; the record's doctor links the account in
   person.
5. **Practitioners are verified before they get a role (T-14).** Sign-up asks
   for a KMPDC number and an uploaded license and creates a `Pending`
   profile with no role claim. Verification sets the claim. The KMPDC
   number and license are then final, and email is final from the start,
   because it is tied to the Auth account.
6. **The care team.** `doctorUids` on a patient holds every doctor and
   pathologist the patient has worked with. It grows as the patient invites
   practitioners to a case. It grants the patient's profile only; each
   case's participants still decide who reads which case. Only server code
   adds to it (T-16).
7. **The public directory** is a projection of verified `doctors`, written by
   a trigger, so a profile edit updates it and nothing private reaches it.
8. **Counters** (`appointmentsHandled`, `ordersCreated`, `reportsSigned`;
   `casesReported`, `appointmentsBooked` for patients) are written only by
   triggers, deduplicated by event id because triggers are delivered at
   least once.
9. **Pictures and licenses** go to Storage (3 MB, images; a license may be a
   PDF). The profile stores the download URL.
10. **Nine-character geohashes everywhere.** A search widens by trimming the
    prefix, and characters never stored cannot be recovered. Facilities
    and practitioners use the facility's coordinates. Patients use their
    sub-county's centre, so the hash locates an area, not a home (T-9).
11. **No Places or Maps API.** Choosing a sub-county gives patients a
    location good enough for nearest-first, and doctors take theirs from
    their facility. That removes a Google Maps key, a proxy function and
    Places billing.
12. **Bundled reference data.** Nairobi's facilities (from the Ministry of
    Health's list), all 47 counties and Nairobi's sub-counties ship as JSON
    assets. `functions/` holds an identical copy so the server never trusts
    a client's facility.
13. **Outside Nairobi**, a patient can still sign up. They see a pilot
    notice and the full directory, unsorted.
14. **Push tokens are a list** (`fcmTokens`), one per device, so a person
    signed in on a phone and on the web demo receives on both.
15. **Clinical vocabulary for Swahili** in the design doc §7, so every
    screen uses the same terms and a native speaker reviews them once.
16. Docs updated: architecture §4, §6, §11; threat model T-9, T-14 to T-16;
    `.greptile/rules.md` privacy section; outbreak engine §8;
    notifications engine §7; design system §7.

## 2. Business justification

Sign-up is the first thing a judge touches, and every later feature
(appointments, chat, cases, the directory) reads these documents. Fixing the
shape now avoids migrating it mid-build. The verification and linking
decisions close two ways to reach patient data that the simpler design
left open.

## 3. Scope

**In scope:** the schema, its rules and Storage paths, the callables and
trigger named in §6.1, and the reference-data assets and script.

**Explicitly out of scope:** appointments and chat rooms (their models arrive
with them, reading `fcmTokens` and `doctorUids`); AI-draft metrics on
practitioners (to be added with `@Default(0)`); counties outside Nairobi
for sub-counties and geohashes.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Three collections; typeIds 0–2 reserved |
| Roles & case scoping | **Affected** | Claims follow verification; `doctorUids` grants profiles, not cases |
| Clinical safety | Affected | Unverified practitioners cannot reach a case or sign (S-2) |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | T-14 to T-16 added; no Maps key needed |
| Data protection | **Affected** | Patients now give a sub-county; licenses are personal documents held privately |
| Design system / UI consistency | None | |
| Localisation | Affected | Vocabulary table; pilot notice in `en` and `sw` |
| Existing data | None | No data exists yet |

## 5. Risk & rollback plan

- **Download URLs work for anyone who holds them.** That suits the public
  directory. For patient pictures, the URL sits on a document only the care
  team reads. A leaked URL exposes one picture; the Storage rule still
  guards listing and writing. Acceptable for a pilot without real patient
  data; revisit before real patients (fetch through the SDK instead of
  storing the URL).
- **A sub-county centre taken from facility coordinates** can sit off-centre
  where facilities cluster. It only orders the directory, so an error moves
  a doctor up or down the list and nothing more.
- **A shared phone** (common in families) with the same birth date would make
  the duplicate check report a clinic record that is not the person's. The
  doctor resolves it in person; nothing is merged automatically.

**Rollback plan:** the schema is not yet written to Firestore. Revert the
documentation commit, and later the code commits that follow it.

## 6. Implementation plan

1. Documents (this change).
2. `functions/`: the callables and trigger, with mocha tests; the facility
   list copy and its equality test.
3. `firestore.rules` and `storage.rules` with emulator tests for T-9 and
   T-14 to T-16 and the locked fields.
4. `scripts/facilities/`: the sanitiser, run on the batches as they arrive.
5. Freezed and Hive model pairs (briefed to Muse Code against §6.1).

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make spell` | Pass |
| Rules and function tests | With steps 2 and 3 |
| Certification | 2026-10-27 — Theo (documentation) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — verification before claims; server-only care team |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | Data protection affected | Covered by CTO | 2026-10-27 | Approved — area, not location; licenses private |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Check the sub-county list against Nairobi's 17 official sub-counties once
  the facility batches are in.
- A native speaker reviews the vocabulary table before any real patient
  sees the Swahili.

## 10. Related records

- Previous CRQ: [CRQ-0013](./CRQ-0013-muse-code-agent.md)
