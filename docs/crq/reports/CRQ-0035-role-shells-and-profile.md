# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0035 |
| Title | Each role lands on its own shell of four tabs under a floating menu, with a profile tab that signs out |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-29 |
| Date implemented | 2026-10-30 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth`: 6cf42fa, 35857fd, 63834d4 (the shared sign-out sheet), f90e9ac, 6b8dbe7, d6709f1 |

## 1. Description of change

1. **Role shells** (`lib/features/home`, `app_routes.dart`). Each role home is
   a `StatefulShellRoute` of four tabs under its home path, so the guard's
   role check covers every tab:
   - patients: Home, Appointments, Results, Profile;
   - doctors: Today, Cases, MDT, Profile;
   - pathologists: Desk, Signed, MDT, Profile.

   A tab keeps its state while another shows; a tap on the open tab returns
   it to its first screen; back from another tab returns to the first before
   it leaves the app. `RoutePlaceholder` is gone.
2. **The floating menu** (`FloatingTabBar`): a solid pill, not glass, whose
   selected tab is an ink pill with its label; the others show the icon and
   keep their label for screen readers. In dark it is raised by a lighter
   tone, never a light shadow.
3. **The tabs.** Home shows the greeting header (photo, "Habari", the area or
   facility with today's date, the bell); the middle tabs their titles; their
   bodies come with their screens.
4. **The profile tab.** The person's card (a patient's with the phone masked,
   a practitioner's teal hero with the KMPDC badge), each role's settings
   groups, the app version, and Sign out behind a confirmation sheet that
   says what stays safe. The switches show the stored value, disabled until
   a bloc saves them. A doctor who approves alerts is told so; a pathologist
   sees their areas.
5. **Shared pieces**: `IconTile` neutral and danger tones; a centred leading
   icon on `TabibuBottomSheet`; nine tab and settings icons.

## 2. Business justification

Signing in used to land on a placeholder. Every role now lands on a home with
its own navigation, and can sign out, which the hand-off to App Distribution
testing needs.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the tabs' bodies (appointments, results, cases,
MDT, the desk), the profile's nested screens, and delete account; each
comes with its own change.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | Reads the session's profile only |
| Roles & case scoping | Affected | Twelve routes under the three role paths, all held by the existing guard; `landing_test` covers each role on another's tab paths |
| Clinical safety | None | No case, result or alert is shown yet |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | Affected | Sign-out from the profile and the pending screen; its robustness is CRQ-0036 |
| Data protection (PHI, de-identification, model endpoints) | Affected | A patient's phone is masked on their own card; photos load through the stored URL |
| Design system / UI consistency | Affected | New floating menu and settings rows; design system §2.4, §2.5 and §5 updated |
| Localisation (en, sw) | Affected | Tab labels, titles and profile copy in both ARB files |
| Existing data | None | — |

## 5. Risk & rollback plan

**Risk level:** Low.

**Rollback plan:** revert the commits; the role routes fall back to their
previous single screens. No deploy is involved.

## 6. Implementation plan

1. The designs for all three roles; built in a separate worktree while the
   second agent worked, then moved into the branch.
2. Rendered every tab and the sign-out sheet at 390 points, light and dark,
   and compared with the designs; fixed the menu's spacing and the dark-mode
   shadows that showed as a second container.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` | Pass |
| `make analyze` / `make bloc-lint` | Pass, 0 issues |
| `make test` | Pass — 756 tests in the branch |
| Rules tests | N/A |
| Model evaluation | N/A |
| Manual run (device / simulator / web) | Rendered previews of every tab, light and dark; device check pending with the App Distribution build |
| UI/UX review of the surrounding screen | Menu width, label truncation and dark-mode tones fixed against the designs |
| Certification | Pending — Theo, on the App Distribution build |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-30 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical content |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-30 | Approved — the guard holds every tab |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | 2026-10-30 | Approved — the phone is masked |
| Lead Designer | §4 flags design-system impact | Covered by CTO | 2026-10-30 | Approved — compared with the designs |

## 9. Post-implementation review

- Accepted against the designs: one wording across roles where the designs
  differ ("Privacy and data", "Biometrics", Notifications as a row); the app
  version on every profile; "Health notices for my area" wraps at the type
  scale's size; the sign-out sheet is full height, as every sheet is.
- On a device: tab state, back, sign-out offline, Kiswahili, dark.

## 10. Related records

- Previous CRQ: [CRQ-0034](./CRQ-0034-sign-up-screens.md)
- Routing: [`mobile_architecture.md` §8](../../architecture/reports/mobile_architecture.md#8-routing--navigation)
