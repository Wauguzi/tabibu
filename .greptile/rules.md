# Review context for Tabibu

What this file is for: making a review better informed, not quieter. Everything below is a
convention that already exists in this repository and that a diff does not reveal on its own,
the kind of thing a reviewer would otherwise have to rediscover, or would flag as wrong because
the reason for it lives somewhere else.

It is **not** a place to record disagreements with findings. If a finding is wrong, the answer is
a reply on the thread. If it is right but the risk is accepted, the answer is the CRQ, which
records the acceptance and what would reopen it. A rule added here to stop a finding recurring
would silence it in the case where it finally matters.

`files.json` beside this file points at the documents these rules are drawn from. Where the two
disagree, prefer those: they are maintained as part of the work, and this is a summary.

## Clinical safety — review these first

Tabibu's AI prepares and a person decides. A change that lets any AI output reach a person before
a qualified human has approved it is a P1 defect, however small the diff. Flag it as the top
finding.

- **Unsigned AI drafts are readable only by the case's pathologist** (S-1). A query, rule,
  listener or screen that exposes `cases/{caseUid}/preread` to a doctor or patient is a breach,
  even if the UI hides it.
- **Only a signed report reaches the doctor** (S-2). Reports are created by the `signReport`
  function. A client write path to a report is a defect, not missing plumbing.
- **A patient never sees a cancer result before the doctor marks it discussed** (S-3). Push and
  notification copy for a result is generic and never names a diagnosis, because lock screens are
  public.
- **No alert is delivered without approval** (S-4). Nothing on the client may set an alert's
  status.
- **Nothing that identifies a patient leaves a case** (S-5). A notifiable event carries disease,
  county, date, epi-week, age band, category and the synthetic flag, and nothing else. A new field
  on that shape needs a CRQ.
- **Every number in a report is computed in code** (S-6). A report field, chart or label whose
  number is parsed out of model prose is a defect.
- **The risk check never confirms or rules out a disease** (S-7). Its advisory is a fixed template.

## Architecture boundaries

- **The app never calls a model.** A model SDK, model endpoint or model key anywhere under `lib/`
  is a defect. Model calls belong to the AI service, triggered through Firebase.
- **The app talks to the backend only through the Firebase SDKs.** A raw HTTP client (`dio`,
  `http`, `HttpClient`) under `lib/` or in `pubspec.yaml` needs a CRQ that justifies the endpoint;
  without one it is a defect. A `badCertificateCallback` that returns `true` is a P1 finding in any
  build: it accepts any certificate and exposes every request to interception.
- **A bloc never imports Flutter.** `package:flutter/*` in a bloc file is a layering break,
  enforced by `bloc_lint`, and it means the bloc cannot be tested without pumping a widget.
- **A bloc asks its helper; it never reaches Hive or Firestore directly.** The helper owns
  cache-versus-remote decisions.
- **Dependencies are constructor parameters with a `getIt` fallback, held in private fields.**
  The public parameter / private field pairing is deliberate, not an inconsistency.
- **A listener matches concrete failure states, never the bloc's base failure class.** Matching the
  base catches sibling operations' failures and shows the wrong message.
- **Every user-visible action logs one analytics event.** A new action that logs nothing is an
  omission.
- **Concurrency transformers are chosen per event with a reason.** Sign, approve and other
  must-not-double-send actions are `droppable()`; ordered writes are `sequential()`.

## Roles and data scope

- **A case is readable only by its participants**: `patientUid`, `doctorUid`, `pathologistUid`.
  A query or helper method without that filter crosses the boundary. This is the most consequential
  class of defect here and it looks locally correct in a diff.
- **Role and alert-approver permission are Firebase Auth custom claims**, set only by an admin
  function. A role field a client can write, or a screen that decides permission by comparing a
  role string instead of going through `RoleHelper`, is a defect.
- **Every privileged transition is a Cloud Function**: signing, marking a result discussed,
  approving or rejecting an alert, setting a role.

## Data layer and persistence

- **Freezed model and Hive mirror keep the same field order**, and a Hive model imports another
  feature's Hive classes only inside `toModel()` / `fromModel()`.
- **Hive typeIds are never reused**, and every new one is added to the registry table in
  `docs/architecture/reports/mobile_architecture.md` §6 in the same change.
- **Adapters register in the hand-maintained cascade in `hive_helper.dart`.** A model registered
  only in a generated registrar that nothing imports fails at runtime, not at compile time.
- **Documents are complete at creation.** Absence is `''`, `0`, `false` or an empty list, never a
  missing key or `null`. Because of that, a status field gates use: `confidence: 0` on a `Queued`
  pre-read means "not measured", not "zero".
- **Timestamps are ISO-8601 UTC strings from one helper.** Delta sync compares them as strings.
- **Sign-out wipes the case-bearing boxes and rotates the Hive key.** Retaining case data across
  sign-out is a deliberate decision for a pilot, not an optimisation to make in passing.
- **Hive is reached only through `DBHelper`.** A `Hive.box` call elsewhere bypasses the error
  mapping, and `Hive.box<dynamic>` on a typed box throws. A new encrypted box needs its case in
  `DBHelper.deleteAll`, or sign-out cannot delete it.
- **Every cached read takes the signed-in uid, and `scopeTo(uid)` runs before a session's first
  read.** A cache read with no uid filter is the on-device version of an unscoped query.

## AI service

- **Standard endpoints only.** A model id naming a contributor (training-enabled) variant is a
  defect even with public data.
- **No image generation or editing.** Diagnostic images are always the real sample.
- **Model output is validated against a schema and stored beside what a person did with it.**
- **A change to a prompt, model, profile or threshold needs an evaluation report** if it moves a
  held-out number.

## Secrets

- **A credential anywhere the client can read it is a P1 finding**: in `--dart-define`, a Flutter
  asset, a `.env` under `lib/`, Remote Config, Firestore, or any committed file. Keys live in Modal
  secrets, Firebase Secret Manager and the macOS Keychain only (T-13).
- **One exception: the App Check debug token**, read from the Keychain and passed as
  `--dart-define=APP_CHECK_DEBUG_TOKEN` by `make run-dev` only. It is used only outside release
  builds; passing it to a release build, a CI workflow or fastlane is a P1 finding.
- **Every Remote Config parameter the app reads has an in-app default** in `bootstrap`'s
  `setDefaults`.
- **Remote Config is for non-secret settings** (model ids, base URLs, thresholds, kill switches).
  It is served to every app instance and is fetchable with the public client config.
- **`.env.example` holds names and non-secret values only**; a real value in it is a leak.

## Privacy

- **Patients choose a county and sub-county; Tabibu never reads their location.** A `geolocator`
  call on a patient's behalf, a client-written `geohash`, or a latitude or longitude on a patient
  profile is a defect. The patient geohash is the server's, from the sub-county's centre.
- **A practitioner has no role claim until verified**, and `kmpdcNumber`, `licenseUrl` and
  `email` are final once set as the architecture doc §6.1 describes. A rule that lets the owner
  change them after verification is a P1.
- **`doctorUids` grants a patient's profile, never their cases.** A case read that trusts
  `doctorUids` instead of the case's own participants crosses the boundary.
- **Free text goes through `InputSanitizer`** before it is stored or sent to the AI service.
- **Nothing about a patient reaches Crashlytics.** Exception messages, `reason` strings and custom
  keys carry ids and types, never names, symptoms, results or free text; the user identifier, if
  set, is the uid. Crash reports leave the case and the country.

## Design system and localisation

- **Unsigned AI output always sits inside `AiDraftFrame`; signed content in `SignedReportView`.**
  The two never share a layout.
- **Confidence and urgency are never conveyed by color alone.**
- **Spacing uses `AppSpacing` tokens; text uses `TextTheme` slots.** No `fontSize` or
  `fontFamily` on a widget, and no raw on-scale pixel literals.
- **Assets and fonts go through the generated `Assets.*` and `FontFamily.*`.** A raw path string
  compiles and breaks silently on a rename.
- **`en` and `sw` are kept at parity.** A user-visible string in one ARB file only is incomplete.
- **User-facing text from Remote Config** (`update_title`, `update_message`) is an optional
  override; the screen falls back to its ARB strings when the value is empty.
- **Localization delegates come from `material_ui` and `cupertino_ui`**, not the generated
  `AppLocalizations.localizationsDelegates`, which crashes in any non-English locale under these
  libraries.
- **A context-watching helper is called only inside `build()`.**

## Startup and platform

- **Every awaited call before `runApp()` is bounded and caught.** A hang there leaves the app on
  the native splash with nothing to report it.
- **`flutter_secure_storage` is pinned exactly.** A bump is tested against an install that already
  holds data before it is accepted.
- **Resources looked up by name (the Android notification icon) are kept in `res/raw/keep.xml`**,
  and anything resolved by name is verified against a release build.
- **Writes that must land together use a batch**; a transaction is only for writes whose values
  depend on a read.
- **Every release build passes `--obfuscate`.** freeRASP treats missing obfuscation as a critical
  threat and terminates a release binary; a build target or workflow without it ships an app that
  closes on launch.
- **A RASP notice names an area, never the detection.** Naming the check tells whoever triggered it
  which one to defeat next.
- **The FlutterFire config files are tracked on purpose.** They are public client identifiers;
  flagging them as leaked secrets is a false positive.

## Tests

- **A rules change is not finished until `test/firestore_rules/` covers it.** The rules are the
  real boundary, and a permissive mistake there is invisible to every other suite.
- **`make test`, not raw `flutter test`**: the target carries the coverage and reporter flags.
- **Widget tests run at 1.0x and 2.0x text scale, in `en` and `sw`.** An overflow at 2.0x is a
  real finding.
- **`fake_cloud_firestore` tracks `cloud_firestore`'s minor version.**
- **There is no on-device integration suite, deliberately.** Suggesting one that registers a
  dev-only plugin into the release build is suggesting a known breakage.
- **Assert the behaviour, not the edit.**

## CI and supply chain

- **GitHub Actions and reusable workflows are pinned to a full commit SHA, never a tag**, with the
  release in a trailing comment (`@<sha> # v2.0.3`). A diff that replaces a SHA with a tag reopens a
  supply-chain hole. Dependabot updates the SHA and the comment together.
- **Secrets reach a workflow step only through `env:`**, never interpolated into a `run:` script,
  and signing material is written to `$RUNNER_TEMP` and removed in an `always()` step. Steps that
  need secrets are gated on `CAN_SIGN`, so Dependabot and fork PRs still run every quality gate.
- **The license check's `skip_packages` list is deliberate**: each entry never ships in an app
  build, and the reason sits beside the list. A new entry needs the same justification.

## Change records and hygiene

- **Every non-trivial change has a CRQ** under `docs/crq/reports/`, and always one for rules,
  the AI service, anything a patient reads, or the alert path.
- **Nothing is committed until the author has run and certified it.** Documentation-only changes
  are exempt.
- **A change that alters what a doc says updates that doc in the same change.**
- **Every change passes `make spell`**, which covers docs, config, scripts and Dart; new terms go in
  `.github/cspell.json`. Generated files are excluded by path, never by adding their fragments as words.
- **Rationale lives in the CRQ; inline comments stay lean**, except where a decision would
  otherwise look arbitrary and be undone. A comment that merely restates the code is a finding;
  length alone is not.
- **No emojis in commit messages.**
