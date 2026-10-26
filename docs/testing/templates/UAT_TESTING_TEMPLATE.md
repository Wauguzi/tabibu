# UAT & Internal Testing Report — Tabibu

> **How to use this template:** after the final commit of every CRQ-bearing
> change, I run the affected user stories on a device, the simulator or the
> deployed web demo, and record ✅ Pass / ❌ Fail / ⚠️ Partial for each. A
> report is written **only after** I have certified the stories myself.
> Never infer one from test results: unit tests check the code, and UAT
> checks the feature.
>
> Save a filled copy as
> `docs/testing/reports/UAT-ITR-<N>-<short-slug>-<YYYY-MM-DD>.md`, incrementing
> `<N>` from the highest existing report, and add a row to
> [`../reports/README.md`](../reports/README.md). Copy only the stories in
> scope, and keep their IDs. Leave this template untouched.

---

## Metadata

| Field | Value |
|---|---|
| Report ID | `UAT-ITR-XXXX` |
| Title | `[e.g. "Pathologist workspace: worklist, overlays, signing"]` |
| Date | `[YYYY-MM-DD]` |
| Tester | `[name / role]` |
| Build / commit | `[short SHA]` |
| Environment | `[Web demo (browser) / Android device / iOS Simulator — version]` |
| Related CRQ | `[CRQ-XXXX]` |
| Overall status | `[✅ PASS / ❌ FAIL / ⚠️ PARTIAL]` |

## 1. Scope

`[What this cycle covers, and what is explicitly out of scope.]`

## 2. Test environment

| Item | Detail |
|---|---|
| Device / browser | `[...]` |
| Flutter version | `[flutter --version]` |
| Firebase project | `[development / staging / production]` |
| Accounts | `[seeded account names only, never passwords]` |
| Locale / text scale / theme | `[en, sw · 1.0x, 2.0x · light, dark]` |

## 3. User stories

### AUTH

**US-AUTH-01 — Sign in per role.** For each seeded account (patient,
doctor, pathologist, doctor with alert approval): sign in; verify the right
shell and tabs; verify no other role's route opens by URL on web.

**US-AUTH-02 — Sign out wipes the case cache.** Sign in as a doctor, open a
case, sign out, sign in as the patient on the same device; verify none of the
doctor's cases are visible, including offline.

**US-AUTH-03 — County choice.** As a patient, choose a county; verify the
alert topic subscription changes when the county changes.

### CASE FLOW

**US-CASE-01 — Patient first.** Patient describes symptoms by voice and by
text → structured intake appears to doctors → a doctor accepts → patient is
notified.

**US-CASE-02 — Doctor first.** Doctor opens a case for a patient in front of
them; patient is notified.

**US-CASE-03 — Order from one catalogue.** Doctor orders a sentinel lymph
node histology and a malaria smear from the same catalogue; attaches a
pathologist; suggested tests appear.

**US-CASE-04 — Risk check advisory.** Doctor enters notes whose symptoms,
malaria results and travel history fit a suspected viral hemorrhagic fever;
verify the protocol advisory appears and that it neither confirms nor rules
out a disease (S-7).

### PATHOLOGIST

**US-PATH-01 — Draft is waiting.** Open an assigned cancer case; verify the
draft, heatmap, largest-focus size, micro/macro classification and confidence
are already on screen; record the time to preliminary report.

**US-PATH-02 — Ranked worklist.** Verify that urgent and low-confidence cases
sort above routine ones, and that the low-confidence label is visible.

**US-PATH-03 — Evidence links.** Select a finding; verify its tiles or cells
are highlighted.

**US-PATH-04 — Relabel recalculates.** Relabel one tile; verify the focus
size and classification update immediately.

**US-PATH-05 — Sign.** Edit the draft and sign; verify the doctor receives
only the signed version, the original draft is stored beside it, and the diff
is recorded.

**US-PATH-06 — Malaria profile.** Open a malaria case; verify cell outlines,
counts and parasitemia.

**US-PATH-07 — Draft privacy.** As the ordering doctor, try to open the
unsigned draft (UI and direct document read); verify it is denied (S-1, S-2).

### RESULTS

**US-RES-01 — Doctor receives the report.** Verify the signed report and its
provenance block.

**US-RES-02 — Cancer result gate.** Before the doctor marks it discussed,
verify the patient sees only "Your doctor will go through this result with
you", and that the push text names no diagnosis (S-3).

**US-RES-03 — Plain-language explanation.** After it is marked discussed,
verify the explanation in English and in Swahili.

### ALERTS

**US-ALR-01 — Baseline rule.** Seed the malaria burst; verify a signal and a
draft in both languages with the evidence shown.

**US-ALR-02 — Immediate rule.** Sign one synthetic Ebola PCR result; verify a
signal is raised on its own.

**US-ALR-03 — Approval required.** Verify nothing is delivered before
approval (S-4); edit and approve; verify the edit is stored beside the draft.

**US-ALR-04 — Two-phase delivery.** Verify doctors in the county and its
neighbors are notified first, then patients who chose the county.

**US-ALR-05 — Event privacy.** Inspect the event document; verify only
disease, county, date, epi-week and age band are present (S-5).

### NOTIFICATIONS

**US-NOT-01 — Inbox and badge.** Verify rows appear, the badge counts unread,
and reading on one device clears it on another.

**US-NOT-02 — Tap routing.** Tap a push with the app closed and backgrounded;
verify it opens the right case or alert.

### RULES (automated, `make rules-test`)

**FS-01…** One row per rule in
[`mobile_architecture.md` §11](../../architecture/reports/mobile_architecture.md#11-roles--authorization-model)
and per S-/T- control in the
[threat model](../../security/reports/firebase_and_ai_service_threat_model.md).

## 4. Pass / fail summary

| Story ID | Scenario | Result | Notes |
|---|---|---|---|
| US-AUTH-01 | Sign in per role | ⬜ | |
| US-AUTH-02 | Sign-out cache wipe | ⬜ | |
| US-AUTH-03 | County choice | ⬜ | |
| US-CASE-01 | Patient first | ⬜ | |
| US-CASE-02 | Doctor first | ⬜ | |
| US-CASE-03 | Order from catalogue | ⬜ | |
| US-CASE-04 | Risk check advisory | ⬜ | |
| US-PATH-01 | Draft waiting | ⬜ | Time to report: |
| US-PATH-02 | Ranked worklist | ⬜ | |
| US-PATH-03 | Evidence links | ⬜ | |
| US-PATH-04 | Relabel recalculates | ⬜ | |
| US-PATH-05 | Sign | ⬜ | |
| US-PATH-06 | Malaria profile | ⬜ | |
| US-PATH-07 | Draft privacy | ⬜ | |
| US-RES-01 | Doctor receives report | ⬜ | |
| US-RES-02 | Cancer result gate | ⬜ | |
| US-RES-03 | Plain-language explanation | ⬜ | |
| US-ALR-01 | Baseline rule | ⬜ | |
| US-ALR-02 | Immediate rule | ⬜ | |
| US-ALR-03 | Approval required | ⬜ | |
| US-ALR-04 | Two-phase delivery | ⬜ | |
| US-ALR-05 | Event privacy | ⬜ | |
| US-NOT-01 | Inbox and badge | ⬜ | |
| US-NOT-02 | Tap routing | ⬜ | |

## 5. Known issues (non-blocking)

| ID | Description | Feature | Severity | Linked record |
|---|---|---|---|---|
| | | | | |

## 6. Regression check

| Feature | Spot-checked | Verdict |
|---|---|---|
| | | |

## 7. Sign-off

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| CTO / Mobile Engineer | Always | | | ✅ Approved / ❌ Blocked |
| Clinical Reviewer | Any story under PATHOLOGIST, RESULTS or ALERTS is in scope | Covered by CTO until filled | | ✅ Approved / N/A |
| Security Analyst | Rules or auth stories in scope | Covered by CTO until filled | | ✅ Approved / N/A |

## 8. Related records

- CRQ: `[link]`
- Evaluation report: `[link, if the AI service changed]`
- IRP: `[link, if an incident was raised]`
