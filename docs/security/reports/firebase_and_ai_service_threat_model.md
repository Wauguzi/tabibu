# Firebase + AI Service — Threat Model & Security Baseline

| Field | Value |
|---|---|
| Scope | The Flutter app, Firebase (Auth, Firestore, Storage, Functions, FCM, App Check), and the Tabibu AI service on Modal |
| Owner | Theo — CTO (covering Security Analyst and Compliance Officer) |
| Status | Living — new findings append to §3, new threats to §4, and a dated row to §7 |
| Audit date | 2026-10-27 |
| Last updated | 2026-10-27 |
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
  (T-1 to T-3, T-7), not keeping these files private. Restricting the API
  keys to their apps in the Google Cloud console is still worth doing.
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
| S-1 | No unsigned AI draft is readable by anyone but the case's pathologist | Rules: `preread` readable only when `request.auth.uid == case.pathologistUid` | Rules test per role | Planned |
| S-2 | Only a signed report reaches the doctor | Reports created only by `signReport`; rules deny client writes | Rules test; function test | Planned |
| S-3 | A patient never sees a cancer result before the doctor marks it discussed | `releasedToPatient` set only by the `markDiscussed` callable; patient read gated on it; push copy is generic | Rules test; push-copy test | Planned |
| S-4 | No alert is delivered without approval | `deliverAlert` runs only on `Approved`; no client can write alert status | Rules test; function test | Planned |
| S-5 | No patient-identifying field leaves a case into an event or a model prompt | `notifiableEvents` built from an allow-list of fields; the same de-identifier runs before drafting | Unit test on the allow-list; fixture with identifying fields | Planned |
| S-6 | No number in a report comes from model prose | Draft numbers checked against the measurement record before `Ready` | Service test with a draft that invents a number | Planned |
| S-7 | The risk check never confirms or rules out a disease | Advisory text is a fixed template; the model only selects whether it applies | Service test | Planned |

### 4.2 Security threats

| ID | Threat | Control | Proof | Status |
|---|---|---|---|---|
| T-1 | A user reads a case they are not on | Rules: participant check on every case-bearing collection; no list query without the participant filter | Rules tests, including cross-patient reads | Planned |
| T-2 | A user escalates their role or grants themselves alert approval | Role and `alertApprover` are custom claims set only by an admin function; no role field is client-writable | Rules test that writes a role field; claim-set function test | Planned |
| T-3 | A forged notification in someone's inbox (phishing with Tabibu's chrome) | `notifications` `create: if false`; Functions only | Rules test | Planned |
| T-4 | A model API key leaks from the app binary | No key in the app; service secrets in Modal and Firebase secret parameters | Release-build string scan in CI | Planned |
| T-5 | The AI service endpoint is called by anyone on the internet | Shared-secret header checked first; Modal endpoint not listed | Service test without the header | Planned |
| T-6 | Demo data is sent to a contributor (training-enabled) endpoint | Endpoint ids are constants; a test fails if any names a contributor variant | Service test | Planned |
| T-7 | Write flood or credit drain from a scripted client | App Check enforced on Firestore, Storage, Functions; per-user rate limits in the trigger functions; result cache | App Check enforcement checked in the Console; function test | Planned |
| T-8 | A slide image is fetched by URL guessing | Storage paths are not public; rules mirror case participation; signed URLs are never stored | Storage rules test | Planned |
| T-9 | Patient location is collected | Patients choose a county; `geolocator` is never called for alerts; no location field exists on the patient profile | Code-review rule; rules test rejecting location fields | Planned |
| T-10 | A tampered or repackaged app talks to the backend | freeRASP; App Check attestation | freeRASP configured with release signing hashes | Planned |
| T-11 | A case read from a shared clinic phone after sign-out | Sign-out wipes case boxes and rotates the Hive key; biometric re-entry option | Unit test on sign-out wipe | Planned |
| T-12 | A prompt injected through free-text notes changes the draft's structure | Notes passed as data fields, never instructions; schema validation rejects off-schema output | Service test with injection fixtures | Planned |

## 5. Not applicable

- **Payments**: Tabibu takes no payments.
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
| 2026-10-27 | §3 tag-pinning finding moved from the removed `main.yaml` to `license_check.yaml` and its successors. | Theo |
| 2026-10-27 | §2 corrected: the FlutterFire client config files are now tracked deliberately and are not secrets. | Theo |
| 2026-10-27 | Initial version: clean baseline, three findings on the scaffold, seven clinical-safety rules (S-1 to S-7) and twelve security threats (T-1 to T-12) with controls and proofs, and the remediation roadmap. | Theo |
