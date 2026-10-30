# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0034 |
| Title | The onboarding, sign-in and sign-up screens (A1 to F5) to the designs, with errors under their fields and input kept on back |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-29 |
| Date implemented | 2026-10-30 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth`: 70c041b, 9a07c61, 78a8721, 7928f37 to 97e7762, 3a04a34 to a92d5c5, 63834d4, 084523d, f70ca47, f90e9ac, 6b8dbe7, 263383f, d6709f1, 270857c |

## 1. Description of change

The screens a person meets before their home: A1 (brand), A2 to A6
(language, intro, get started), B1 to B5 (sign-in, reset, verify email), C1
(role), D1 to D5 (patient), E1 to E6 (doctor) and F1 to F5 (pathologist,
sharing E's screens). CRQ-0027 built the blocs and routes under them and
scoped the screens out; CRQ-0032 the verification logic. This records the
screens.

1. **Built to the designs**: step headers at the designs' title size, icons at
   their drawn size, native Cupertino sheets with no close control, taps
   through `GestureDetector` with no ripple, a Cupertino date picker, the
   +254 phone (a fixed box on D3, inside the field on E1), the D5 calendar
   drawn in code, the E3/F3 facility lists grouped by type and level
   (`facility_group.dart`; nursing homes as hospitals, Medical Center as a
   health centre), and each role's review and terms.
2. **Errors under their field.** `fieldFor` maps a refusal to its field and
   `fieldErrorText` gives the short message; the notice above the form keeps
   only errors with no field. Each field clears only its own error
   (`errorAfterChange`). A refusal from the bloc is taken in the listener,
   never the builder, so an old one does not return on a later visit.
3. **Input kept on back.** `DraftPopScope` commits a step's fields to the
   sign-up draft when it pops, on all three tracks, so a Continue after a
   back reopens the next step filled in. A cleared draft is never refilled.
   A sign-up begun from sign-in or Get started starts a fresh draft.
4. **Once the account exists**, D2 and E1 show the email read-only and ask
   for no password.
5. **Pending and verified.** A pending practitioner holds no role, so E5/F4b
   carry Sign out (the shared confirmation sheet, CRQ-0035) under Check
   again, which says so when nothing changed.
6. **Pre-review fixes** (CRQ-0036 §1 lists the review): a photo or licence
   still being read holds Continue; every await checks it is still mounted;
   D4 retries a failed county list; 48 dp targets and keyboard activation;
   Kiswahili for dates, areas and the intro's sample times; the update screen
   on the web.

## 2. Business justification

These are the first screens every judge and every person sees, and the only
way into the product. The design pass and device testing found them behind
the designs and losing input on back.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- The profile's nested screens (language, area, theme, notifications);
  their rows are in place and wait for them.
- "Explore Tabibu", "Contact support" and "Finish my profile": dropped until
  there is somewhere for them to go.
- Saving the profile switches: shown disabled until a bloc saves them.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | Additive | `SignUpDraft.email`; no Hive change |
| Roles & case scoping | None | No case is read or written |
| Clinical safety | None | No AI output, report, result or alert passes through these screens |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | None here | The rules and functions changes are CRQ-0036 |
| Data protection (PHI, de-identification, model endpoints) | Affected | The draft holds a person's details in memory only, cleared after sign-up or sign-out and on a fresh sign-up |
| Design system / UI consistency | Affected | New shared pieces: `TabibuTextField.inputFormatters` and `readOnly`, `PhotoRow`, `FieldIconTint`; brand mint and lavender for selection |
| Localisation (en, sw) | Affected | Every new string in both ARB files; two unused keys removed |
| Existing data | None | — |

## 5. Risk & rollback plan

**Risk level:** Low. Screens only; the blocs, routes and callables they use
are unchanged in behaviour.

**Rollback plan:** revert the commits; no deploy is involved.

## 6. Implementation plan

1. The designs in Downloads, one task at a time through briefs to a second
   coding agent, each reviewed, gated and committed by me (`.briefs/05/`).
2. Reviewer steps between bundles: input kept on back, the role shells, D2
   and E1 read-only, the pending screen's wiring.
3. The pre-PR review (CRQ-0036) and its four fix bundles.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` | Pass |
| `make analyze` / `make bloc-lint` | Pass, 0 issues |
| `make test` | Pass — 756 tests, and with `TZ=UTC` |
| `make spell` | Pass |
| Rules tests | N/A here (CRQ-0036) |
| Model evaluation | N/A |
| Manual run (device / simulator / web) | Every tab and the sign-out sheet rendered at 390 points in light and dark and compared with the designs; sign-up on a device pending with the App Distribution build |
| UI/UX review of the surrounding screen | The pre-PR review; findings fixed in bundles 13 to 16 |
| Certification | Pending — Theo, on the App Distribution build |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-30 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path or wording |
| Security Analyst | §4 flags security impact | N/A | — | None here (CRQ-0036) |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | 2026-10-30 | Approved — the draft stays in memory and is cleared |
| Lead Designer | §4 flags design-system impact | Covered by CTO | 2026-10-30 | Approved — compared with the designs |

## 9. Post-implementation review

- On a device: each track end to end, back from every step, at 2.0x text, in
  Kiswahili, in dark mode.
- Accepted: E1's phone label reads "Phone number", shared with D3, where the
  E1 and F1 designs say "Phone".

## 10. Related records

- Previous CRQ: [CRQ-0033](./CRQ-0033-lab-test-catalogue.md)
- Blocs and routes: [CRQ-0027](./CRQ-0027-auth-bloc-and-router.md); email
  confirmation: [CRQ-0032](./CRQ-0032-email-verification.md)
- Role shells: [CRQ-0035](./CRQ-0035-role-shells-and-profile.md); the
  pre-review: [CRQ-0036](./CRQ-0036-pre-review-hardening.md)
