# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0017 |
| Title | Foundations: counter removed, Swahili replaces Spanish with the localizations-delegates fix, and the design-system theme |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Implemented by Muse Code from a written brief (CRQ-0013), then reviewed,
gated and committed by me.

1. **Counter example removed** (`lib/counter/`, `test/counter/`). The app
   shows a placeholder home with the app title until the router lands.
2. **`sw` replaces the template's `es`.** `app_sw.arb` is added and `appTitle`
   is the first key.
3. **Localizations delegates.** `tabibuLocalizationsDelegates` in
   `app.dart` lists `material_ui`'s and `cupertino_ui`'s own delegates. The
   generated `AppLocalizations.localizationsDelegates` satisfies the
   framework's types, not these libraries', and throws in any non-English
   locale.
   - `test/helpers/pump_app.dart` uses the same list.
   - `test/app/localizations_delegates_test.dart` mounts a `TextField`, an
     `AppBar` and a dialog in `en` and `sw`. Muse Code confirmed that the
     `sw` cases fail with the generated list.
4. **Theme** (`lib/core/constants/`):
   - `app_spacing.dart`, `app_colors.dart` (every §2.1 role, light and dark),
     `app_status_colors.dart` (a `ThemeExtension` for the roles Material
     has no slot for), and `app_styles.dart`.
   - `theme_builder.dart`: `buildTheme(Brightness)`, Material 3 seeded from
     `primary`, with the two type families from §2.2 through `FontFamily`
     and Cupertino page transitions on every platform.
   - The app uses light and dark themes and follows the system setting.
5. **Draft versus signed.** The provisional light `aiDraft` and `signed`
   were 0.002 apart in luminance, which would break §2.1's grayscale rule.
   The signed report becomes a deep green panel and the AI draft stays a
   pale surface (design doc §2.1). Theo chose this during the session.
6. **`lib/gen/`** (flutter_gen output for `Assets` and `FontFamily`) is
   tracked, so a fresh checkout builds without running the generator.
7. **`make fmt`** now formats the same file set as CI's format check, so it
   no longer rewrites `lib/firebase_options.dart`.
8. Docs: design system §2.1 and §8; architecture §4 and §16 items 1 and 2.

## 2. Business justification

Every screen depends on the theme and the Swahili locale. The delegates fix
removes a crash that would have hit the first Swahili screen.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the router, any screen, and the icon set.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | Affected | The draft and signed frames now differ in grayscale (§2.1, §4.1) |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | None | |
| Data protection | None | |
| Design system / UI consistency | **Affected** | First palette and theme |
| Localisation | **Affected** | `sw` live; delegates fixed |
| Existing data | None | |

## 5. Risk & rollback plan

- **Provisional palette.** Light values await design review. The dark
  containers are close in luminance (0.006 apart), so in dark mode the
  draft and signed frames are told apart by their accents (0.31 apart)
  and by their layouts, which are never shared.
- **`sheetRadius` 28 and `cardPadding`** are on-scale choices that neither
  document fixed; revisit with the designs.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Brief written.
2. Muse Code implemented it and ran the gates.
3. Reviewed the diff; fixed `make fmt`; reran every gate on the combined
   tree.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt`, `make analyze`, `make bloc-lint` | Clean |
| `make test` | 35 passing |
| `make spell` | Pass |
| Delegates test fails with the generated list (Muse Code) | `sw` cases failed, as expected |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-10-30 | Approved — [PR #6](https://github.com/Wauguzi/tabibu/pull/6), 5/5 at round 3 |
| Security Analyst | — | N/A | — | — |
| Clinical Reviewer | Draft versus signed | Covered by CTO | 2026-10-27 | Approved — frames differ in grayscale |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | Design system affected | Covered by CTO | 2026-10-27 | Provisional — palette to be reviewed against the designs |

## 9. Post-implementation review

- Review the palette against the auth designs when they are shared.

## 10. Related records

- Previous CRQ: [CRQ-0016](./CRQ-0016-identity-functions-and-rules.md)
- Muse Code: [CRQ-0013](./CRQ-0013-muse-code-agent.md)
