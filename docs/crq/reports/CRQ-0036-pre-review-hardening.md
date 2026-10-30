# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0036 |
| Title | The pre-PR review: Storage, rules and functions hardened, and sign-out and session reads made safe |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-29 |
| Date implemented | 2026-10-30 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth`: 0207e33, fb28178, b3a5950, 4326963, 06b144b, d923ce5 |

## 1. Description of change

Before the branch's pull request, I reviewed all of it the way Greptile
does: every rule in `.greptile/rules.md`, the documents it reads, and every
class of the defect catalogue, in five areas (infra; data and state; the
auth screens; shared UI and copy; scripts, CI and docs). Screen
and copy findings went to four fix bundles (CRQ-0034); this records the rest.

1. **Storage** (`storage.rules`):
   - each path takes fixed names only (`photo.jpg` or `photo.png`;
     `license_1` or `license_2` as `.jpg`, `.png` or `.pdf`), so an account
     holds at most two pictures and six licence files;
   - the extension must match the content type, and only JPEG, PNG and PDF
     pass, so an SVG or HTML file cannot be stored as an image;
   - an upload under the caller's own uid needs a confirmed email, and
     licence files a role-less account;
   - with names that can be guessed, a patient's picture is read only by the
     patient and their care team.
2. **Firestore rules** (`firestore.rules`):
   - a file URL on a profile must be in this project's bucket, so an owner
     cannot serve a file they swap after verification (T-14);
   - a verified practitioner's title and names are final, as the KMPDC
     number is (T-14);
   - every profile update carries a new `lastUpdatedAt`, so delta sync sees
     it.
3. **Functions:**
   - `linkPatientAccount` refuses an account whose address nobody confirmed:
     anyone could open one under a clinic patient's email and take their
     record (T-15). A link whose role failed to set finishes on a retry;
   - a linked patient's own sign-up returns the linked record instead of a
     second one under the same uid;
   - `syncPractitioner` projects the profile as it stands, in a transaction,
     not the event's copy, so a late "Verified" never republishes a rejected
     practitioner; it retries on failure;
   - a birth date is checked against Nairobi's date, not UTC's;
   - the seed type-checks again and adopts only accounts it created, so a
     pre-registered seeded address is never given a role or admin.
4. **The app's session** (`AuthHelper`, `AuthBloc`, `HiveHelper`):
   - offline, a Firestore write waits for the server instead of failing, so
     removing the device token held sign-out for ever; it and the language
     write now wait three seconds at most;
   - a session read that started before a sign-out and answered after it
     signed the person back in and cached their record unowned on a shared
     phone; each sign-out now drops such a read, resume skips its refresh
     while signing out, and `scopeTo` wipes an unowned cache;
   - offline with nothing cached is "could not read", never "no profile";
   - the patient's optional photo is bounded and cannot fail a sign-up; an
     account created but not read back stays signed in; the Remote Config
     setup at start is bounded.
5. **Configuration**: Hosting for `make deploy-hosting`; the iOS team in the
   RASP config, without which an iOS release closes at launch.

## 2. Business justification

The branch carries the identity layer every later feature trusts. Two
findings let one person take another's record or reappear on their phone,
and several left the live rules weaker than the documents said.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** enforcing App Check (C-9, before the public
rollout); deleting old-format uploads (§9).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | No field added; `scopeTo` now wipes an unowned cache |
| Roles & case scoping | Affected | A patient's picture is read by the care team only; licences by role-less accounts only |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | **Affected** | Rules, Storage rules, four callables or triggers, the RASP team; `gitleaks` clean over the branch |
| Data protection (PHI, de-identification, model endpoints) | Affected | A patient's photo and record are kept from strangers and from the next person on a shared phone |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | None | Existing refusals (`emailNotVerified`) reused |
| Existing data | Affected | A file already stored under another name stays readable by its owner; new uploads use the fixed names |

## 5. Risk & rollback plan

**Risk level:** Medium: rules and functions change what live clients may do.

- **Deploy together.** `firestore.rules`, `storage.rules` and the functions
  deploy with this app build; the live project enforces the old rules until
  then. An older build is unaffected: it already uploads the fixed names and
  stamps every update.
- **A practitioner already verified** can no longer rename themselves; an
  admin corrects a name if needed.

**Rollback plan:** redeploy the previous rules and functions from `main`
(`make deploy`), then revert the commits. No data migration either way.

## 6. Implementation plan

1. Five read-only reviews in parallel, each walking every catalogue class
   against its area; every finding verified in the code before a fix.
2. The fixes here by me; contained screen and copy fixes as four bundles to
   the second agent, each reviewed, gated and committed.
3. Every new guard proven: broken, its test red, restored.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` | Pass |
| `make analyze` / `make bloc-lint` | Pass, 0 issues |
| `make test` | Pass — 756 tests, and with `TZ=UTC` |
| Rules tests | Pass — 44: RT-36 to RT-44 new (fixed names and types, a confirmed owner, the name final once verified, this project's bucket, a new stamp, who reads a patient's picture, licences for role-less accounts) |
| `make functions-test` | Pass — 45, with lint and the build: an unconfirmed link refused, a link replay, a linked patient's sign-up, a late Verified event, Nairobi's date |
| Late-read guard | Proven: removed, its test red; restored |
| Secrets | `gitleaks` over the branch: no leaks |
| Manual run (device / simulator / web) | Pending — sign-out offline and on resume, on the App Distribution build |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-30 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-30 | Approved — each control has a rules or functions test |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | 2026-10-30 | Approved — photos and cached records kept to their owners |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

Accepted as risks, each with what would reopen it:

- **A confirmed email stands in for a profile** in the Storage binding
  (catalogue class 18), because a practitioner's files go up before their
  profile exists. Reopen if abuse shows: move the uploads after the callable.
- **A new stamp, not a later one.** Rules cannot compare a string with the
  server clock; a device behind it could send an earlier stamp. Reopen if
  delta sync misses an update: stamp on the server.
- **Old-format uploads remain** (`photo.jpg` beside a later `photo.png`),
  readable by their owner only. Reopen if storage cost matters.
- **A pending account can enter another doctor's KMPDC number** and block
  that doctor's verification until an admin resolves it.
- **The clinic-record outcome does not survive a restart**: the person
  resolves to an unfinished sign-up and is shown it again on resubmit.
- **On the emulator only**, a Storage URL's `http://127.0.0.1` form is not
  the hosted form the rules accept.

## 10. Related records

- Threat model: [T-14, T-15](../../security/reports/firebase_and_ai_service_threat_model.md)
- Identity rules: [CRQ-0016](./CRQ-0016-identity-functions-and-rules.md);
  licences: [CRQ-0026](./CRQ-0026-specialties-and-license-files.md)
- Screens: [CRQ-0034](./CRQ-0034-sign-up-screens.md)
