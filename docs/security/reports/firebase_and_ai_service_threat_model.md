# Firebase + AI Service — Threat Model & Security Baseline

| Field | Value |
|---|---|
| Scope | The Flutter app, Firebase (Auth, Firestore, Storage, Functions, FCM, App Check), and the Tabibu AI service on Modal |
| Owner | Theo — CTO (covering Security Analyst and Compliance Officer) |
| Status | Living — new findings append to §3, new threats to §4, and a dated row to §7 |
| Audit date | 2026-10-27 |
| Last updated | 2026-11-01 |
| Performed by | Theo |
| Methodology | "Never trust the client": every role, signature, approval, release and threshold is enforced server-side; plus a clinical-safety pass, which asks whether an AI output can reach a person before a qualified human approves it |

## 1. Purpose & scope

Written before Firebase is wired, so the rules, functions and AI service
are built against a threat list rather than audited against one afterwards.
It covers the hackathon build, which handles **public datasets and invented
patients only**, and states the controls a pilot with real patients would
need on top (§6).

## 2. Verified clean

- **No secrets in the repository.** No keystores, `key.properties` or
  `.env` files are tracked (checked with `git ls-files` and `git grep` on
  2026-10-27). *Updated 2026-10-27:* `google-services.json`,
  `GoogleService-Info.plist` and `lib/firebase_options.dart` are now tracked
  on purpose. They hold public client identifiers (API key, project id, app
  ids), not secrets: what protects the project is the rules and App Check
  (T-1 to T-3, T-7), not keeping these files private. Both keys carry the
  API restrictions Firebase applies to the keys it creates (24 Firebase
  APIs, confirmed in the Google Cloud console). They are deliberately not
  restricted by app: package, certificate and bundle-id checks rely on
  values the app sends with each request, which anyone can copy, and every
  missed flavor or signing certificate breaks Firebase in that build. App
  Check is the control that verifies the app. GitHub secret scanning raised
  one alert per key; both are closed as "won't fix" with this reasoning.
- **Signing material is ignored.** `.gitignore` covers `**/android/key.properties`
  and `*.jks`.
- **No model call from the client.** The app has no model SDK or model key;
  the architecture routes every call through the AI service.
- **No patient data exists anywhere in the project.** Demo records are
  synthetic, and the images are from PatchCamelyon, CAMELYON16 and the NIH
  malaria set.

## 3. Findings

### Medium — `android/app/src/main/AndroidManifest.xml` — `allowBackup` not set

The manifest leaves `android:allowBackup` at its default, `true`. Once the
encrypted Hive cache holds case data, the app's data directory, including
the encrypted boxes, goes into cloud and device-to-device backups. The key
stays in the Keystore, so the boxes are not readable from a backup alone,
but the health cache should not leave the device at all.
**Fix:** set `android:allowBackup="false"` and add
`android:dataExtractionRules` and `android:fullBackupContent` that exclude
everything, in the same change that introduces the Hive cache.

### Medium — `.github/workflows/license_check.yaml` — reusable workflows pinned to a tag

*Updated 2026-10-27:* first raised against `main.yaml`, which has since been
removed; the finding now applies to `license_check.yaml` and to every
workflow that replaces `main.yaml`.

`VeryGoodOpenSource/very_good_workflows/...@v1` resolves to whatever `v1`
points at when CI runs. A moved or compromised tag changes what runs with
this repository's permissions.
**Fix:** pin each `uses:` to a commit SHA, with the release in a trailing
comment, before the repository is opened to judges.
**Status, 2026-10-27:** resolved for `license_check.yaml`, which is pinned to
the v2.0.3 commit (CRQ-0003). `prod_apk.yaml` is pinned the same way
(CRQ-0008). It stays open as a rule for every new workflow.

### Low — `pubspec.yaml` — `test_api: any` in runtime `dependencies`

Unconstrained and in the wrong section. A test-only package in the runtime
graph widens what ships, and `any` accepts any future version.
**Fix:** move it to `dev_dependencies` with a constraint, or remove it if
nothing imports it.

## 4. Threat register

Each threat has a control and the test that proves the control. Status is
`Planned` until the test exists and passes.

### 4.1 Clinical-safety rules

These are the rules whose breach is a P1 even when no attacker is involved
(see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity)).

| ID | Rule | Control | Proof | Status |
|---|---|---|---|---|
| S-1 | No unsigned AI draft is readable by anyone but the case's pathologist | Rules: `preread`, `reportDrafts`, `reportProvenance` (the signer and admins), `worklist` (cleared when the pathologist leaves the case), and the `preread/` Storage files and labels readable only when `request.auth.uid == case.pathologistUid`, with the pathologist role | Rules test per role | Planned |
| S-2 | Only a signed report reaches the doctor | Reports created only by `signReport`, a transaction that signs only the draft revision the pathologist reviewed (its `lastUpdatedAt`), with a content-addressed signature; rules deny client writes | Rules test; function test | Planned |
| S-3 | A patient never sees a cancer result before the doctor marks it discussed | `releasedToPatient` set only by the `markDiscussed` callable; patient read gated on it, through `readerUids` and a release filter on every patient query; approved texts in `reportTextsApproved`, read by id under the same gate; patient-visible log rows carry no free text; push copy is generic. A public outbreak alert is addressed to an area, not a person: its push may name the disease and the county, from the bundled names, and never a count, a date, a facility or a person | Rules test; push-copy test | Planned |
| S-4 | No alert is delivered without approval | `alerts` has no client write, approvers included; only `approveAlert` sets `Approved`; `deliverAlert` runs only from `Approved` and is the only writer of `Delivered` and `publicAlerts`; topic sends need server credentials | Rules test; function test | Planned |
| S-5 | No patient-identifying field leaves a case into an event or a model prompt | `notifiableEvents` built from an allow-list of fields (disease, county, date, epi-week, age band, category, the alert request, its status and the synthetic flag); the link to the case only in the server-only `notifiableEventLinks`; the alert-drafting input has no case data; the signal names no pathologist; the same de-identifier runs before every other prompt | Unit test on the allow-list, with a case carrying a name, phone, facility and order number; fixture with identifying fields | Planned |
| S-6 | No number in a report comes from model prose | Draft numbers checked against the measurement record before `Ready` | Service test with a draft that invents a number | Planned |
| S-7 | The risk check never confirms or rules out a disease | Advisory text is a fixed template; the model only selects whether it applies | Service test | Planned |
| S-8 | AI output reaches a person without an approval only where the docs name that reader as the qualified person who acts on it: the symptom summary and risk advice to the doctor, the notes translation to the doctor and pathologist, the speaker's own transcript, and **any voice-note transcript to the clinicians in that conversation, who also hear the audio**. A patient reads a clinician's transcript only after the sender shares it. Always labelled as AI, with de-identified input. Speech is the one exception: it goes to the transcription model only, symptom audio is deleted after transcription, and voice notes are stored as the sender's message | Each direct-use record is readable only by the readers named; the machine transcript of a voice note sits apart from the message, and a patient is denied it on a clinician's note; sharing it is the sender's one-tap approval (`acceptedUnchanged`); `AiDraftFrame` labels every direct-use surface. Alerts never use S-8: they always pass an approval (S-4) | Rules tests per reader, including a patient denied a clinician's machine transcript; a function test that symptom audio is deleted on success and failure | Planned |

### 4.2 Security threats

| ID | Threat | Control | Proof | Status |
|---|---|---|---|---|
| T-1 | A user reads a case they are not on | Rules: participant check on every case-bearing collection; no list query without the participant filter | Rules tests, including cross-patient reads | Planned |
| T-2 | A user escalates their role or grants themselves alert approval | Role and `alertApprover` are custom claims set only by an admin function; no role field is client-writable. Approving needs `admin` **and** `alertApprover`, and the approver registry read inside the transaction; `setAlertApprover` is callable only by an existing approver, never on themselves, and revokes the target's refresh tokens on a revoke | Rules test that writes a role field; claim-set function test; self-grant and revoked-approver function tests | Planned |
| T-3 | A forged notification in someone's inbox (phishing with Tabibu's chrome) | `notifications` `create: if false`; Functions only | Rules test | Planned |
| T-4 | A model API key leaks from the app binary | No key in the app; service secrets in Modal and Firebase secret parameters | Release-build string scan in CI | Planned |
| T-5 | The AI service endpoint is called by anyone on the internet | Shared-secret header checked first; Modal endpoint not listed | Service test without the header | Planned |
| T-6 | Demo data is sent to a contributor (training-enabled) endpoint | Endpoint ids are constants; a test fails if any names a contributor variant | Service test | Planned |
| T-7 | Write flood or credit drain from a scripted client | App Check enforced on Firestore, Storage, Functions; per-user rate limits in the trigger functions; result cache. Race-safe caps in `rateCounters`, read and written inside the transaction: shares 20 a day, 5 pending on a case, MDTs 10 a day, symptom transcriptions 20 a day, share-code reissues 3 an hour; orders 50 a day. The message quota (30 a minute, 600 a day) and the **voice-note quota** (20 an hour, 30 minutes a day, each note at most 2 minutes and 512 KB) block a sender for 15 minutes | App Check enforcement checked in the Console; function test | Partial: App Check active, not enforced (CRQ-0010) |
| T-8 | A slide image is fetched by URL guessing | Storage paths are not public; rules mirror case participation; signed URLs are never stored. Slides go only under names a callable reserved; signatures are content-addressed and readable by the version's readers; conversation images and voice notes are fetched as bytes through the SDK, never by download URL; symptom audio is readable by nobody and deleted after transcription | Storage rules test | Planned |
| T-9 | A patient's precise location is collected | Patients choose a county and sub-county; `geolocator` is never called on a patient's behalf; the patient geohash is computed by the server from the sub-county's centre, so no field locates a home (CRQ-0014) | Code-review rule; rules test rejecting a client-written `geohash` or any latitude/longitude field on `patients` | In place, not deployed (CRQ-0016) |
| T-14 | Someone claims to be a doctor or pathologist and signs reports | Practitioner sign-up sets no role claim; the claim follows verification of the KMPDC number and license by an admin; the name, KMPDC number and license are final once verified; every file URL must be in this project's bucket; the directory projects the stored profile, so a late event never republishes a rejected practitioner | Function tests: a pending practitioner has no claim, a late Verified event; rules tests RT-21, RT-38, RT-39 | In place, not deployed (CRQ-0016, CRQ-0036) |
| T-15 | Someone takes over a doctor-added patient's record by signing up with their phone and birth date, or by opening an account under their email | Sign-up never merges into an existing record; a doctor on the care team links an account in person, and only one whose address its owner confirmed | Function tests: a matching sign-up creates nothing and returns `clinic-record-exists`; an unconfirmed account is refused the link | In place, not deployed (CRQ-0016, CRQ-0036) |
| T-16 | A doctor adds themselves to a patient's care team to read their profile | `doctorUids` is server-written: only `addPatient` (the creating doctor), a patient's `Join` share (which replaces the planned `inviteToCase`), and a doctor accepting the patient's appointment add to it | Rules test: a doctor's own `arrayUnion` on `doctorUids` is denied | In place for `addPatient`, not deployed (CRQ-0016); the other two planned (CRQ-0042, CRQ-0044) |
| T-17 | An MDT member learns a patient's identity | The MDT gets an allow-listed case summary and never reads the case; the signed excerpt is scrubbed of the patient's identifiers; a voice note's transcript that may name the patient is flagged to its sender, who can withdraw the note within 15 minutes. **Residual:** clinician free text and speech; the composer shows a fixed reminder | Function test with a summary and a transcript fixture that carry the patient's name, a phone and a date | Planned (CRQ-0045) |
| T-18 | A share code is misused | The code is **an acknowledgement step bound to one recipient, not a credential**: only that recipient may redeem it. Its HMAC sits in a server-only record; 5 attempts, then locked; it expires; one helper closes it on every path. It never strands a report: the doctor or the signer can always reissue it, and a critical report not opened in 24 hours re-notifies the doctor and the signer daily | Function tests: a wrong code five times locks it, redemption after expiry leaves no secret, a fourth expiry still reissues | Planned (CRQ-0042) |
| T-19 | An unapproved, forged or repeated public alert reaches a county (mass phishing with Tabibu's chrome, or alarm) | S-4 controls; `admin && alertApprover`, granted only by `setAlertApprover`; four eyes (the pathologist who raised it cannot approve it); a lease, keyed rows and topic claims make delivery at most once per recipient row and per topic, with a collapse id for the rare re-send; `alerts_delivery_enabled` halts delivery between pages | Rules test that every client write to `alerts` is denied; delivery function tests | Planned (CRQ-0049) |
| T-20 | A case is re-identified from an alert or a signal (a single immediate case in a small county) | The event allow-list; links server-only; the signal names no pathologist or facility; the patient notice carries no count, age band or date; the clinician brief carries the count only | The S-5 fixture; rules tests that events, links and counts are closed to everyone and that a patient cannot read the brief | Planned (CRQ-0049) |
| T-10 | A tampered or repackaged app talks to the backend | freeRASP (CRQ-0024): certificate, store and integrity checks in release binaries; root, hooks, tampering and debuggers terminate the app; App Check attestation | freeRASP configured with the release signing hash; 28 service tests | Partial: RASP active; App Check active, not enforced (CRQ-0010); Play App Signing hash pending |
| T-11 | A case read from a shared clinic phone after sign-out | Sign-out wipes case boxes (the 21 boxes of the data layer included) and the cached audio and image files, and rotates the Hive key; biometric re-entry option | Unit test on sign-out wipe | Planned |
| T-12 | A prompt injected through free-text notes changes the draft's structure | Notes passed as data fields, never instructions; schema validation rejects off-schema output. The same holds for the translation, explanation, intake, notes-translation, transcription and alert-drafting prompts | Service test with injection fixtures | Planned |
| T-13 | A model API key leaks through the repository, the app bundle or Remote Config. Keys pushed to public GitHub are typically abused within minutes, and deleting the commit does not undo it | Keys live only in Modal secrets, Firebase Secret Manager and the macOS Keychain (`make keys-add`, `make ai-dev`). `.env` files are ignored and hold non-secret settings only. No key in `--dart-define`, Flutter assets or Remote Config, which serves every app instance and is fetchable with the public client config. GitHub push protection for the account, plus `make secrets` (gitleaks over history and staged changes). On a leak: revoke first, then clean up | `git check-ignore` on `.env`; `make secrets` clean; release-build string scan (shared with T-4) | Partly in place: ignore rules, Keychain targets and scan target done; repository secret scanning and gitleaks install pending |

## 5. Not applicable

- **Payments**: Tabibu records the payment method, insurer and policy number in a doctor-and-patient-only record (`cases/{c}/private/payment`). It collects no money.
- **Real patient data**: none in the hackathon build. This changes at a pilot
  (§6).
- **Custom URL schemes**: none beyond OAuth redirects; deep links are
  push payloads routed through the typed router.

## 6. Remediation roadmap

**For the hackathon, in order:**

1. Rules for every collection, with tests for S-1 to S-4 and T-1 to T-3,
   in the same change that creates the collections (day 3).
2. The claim-setting admin function and seeded accounts (T-2).
3. App Check in debug-provider mode for development, enforced for the
   deployed demo (T-7).
4. The §3 findings: `allowBackup`, SHA pinning, `test_api`.
5. The service-side tests S-5 to S-7, T-5, T-6 and T-12 alongside the
   pipeline (day 4).

**Before any pilot with real patients:** consent; a data protection impact
assessment under Kenya's Data Protection Act; the Digital Health Act 2023's
processing rules; in-country hosting where required (self-hosted open
weights are the route to keeping inference in Kenya); an external
penetration test; and validation against local samples before any draft is
trusted.

## 7. Change log

| Date | Change | Author |
|---|---|---|
| 2026-11-01 | For the `feat/infra` data layer: S-1 to S-5 controls extended; S-8 added (direct use of AI output, including any voice-note transcript to the conversation's clinicians, and the speech exception); T-2, T-7, T-8, T-11, T-12 and T-16 extended; T-17 to T-20 added (MDT identity, share codes, public alerts); §5 payments are recorded, never collected (CRQ-0041 to CRQ-0049). | Theo |
| 2026-10-30 | T-14: the name final once verified, file URLs pinned to the project's bucket, the directory built from the stored profile. T-15: linking needs a confirmed address (CRQ-0036). | Theo |
| 2026-10-27 | T-10: freeRASP active in release binaries (CRQ-0024). | Theo |
| 2026-10-27 | T-9, T-14 to T-16 in place in rules and functions, with tests; deploy pending (CRQ-0016). | Theo |
| 2026-10-27 | T-9 reworded for sub-county geohashes; T-14 to T-16 added for practitioner sign-up, record linking and the care team (CRQ-0014). | Theo |
| 2026-10-27 | T-7 and T-10: App Check active, not enforced (CRQ-0010). | Theo |
| 2026-10-27 | §2: API keys confirmed API-restricted by Firebase; app restrictions declined, with the reason; secret-scanning alerts closed (CRQ-0007). | Theo |
| 2026-10-27 | §3 tag-pinning finding: `prod_apk.yaml` pinned to commit SHAs (CRQ-0008). | Theo |
| 2026-10-27 | §4.2 adds T-13: API keys in the repository, the app bundle or Remote Config (CRQ-0007). | Theo |
| 2026-10-27 | §3 tag-pinning finding resolved for `license_check.yaml` (pinned to a commit SHA). | Theo |
| 2026-10-27 | §3 tag-pinning finding moved from the removed `main.yaml` to `license_check.yaml` and its successors. | Theo |
| 2026-10-27 | §2 corrected: the FlutterFire client config files are now tracked deliberately and are not secrets. | Theo |
| 2026-10-27 | Initial version: clean baseline, three findings on the scaffold, seven clinical-safety rules (S-1 to S-7) and twelve security threats (T-1 to T-12) with controls and proofs, and the remediation roadmap. | Theo |
