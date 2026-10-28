# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0030 |
| Title | Design tokens from the design system, the shared widget library and its assets; AI draft and signed told apart by structure |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-28 |
| Date implemented | 2026-10-28 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Muse Code built this from two briefs; I reviewed each against the design
system sheet, the brief, and the gates.

1. **Tokens** (`lib/core/constants/`):
   - `app_colors.dart` carries the sheet's light values exactly: 48 checked
     one by one against the brief's table. Dark values were derived and every
     text pair passes WCAG AA; the lowest is the error text at 7.16.
   - New `app_radii.dart` (32/28/24/20/999), `app_gradients.dart` (seven
     washes, each with a dark counterpart), and `app_shadows.dart` (card,
     raised, glass, scrim), so no widget writes a shadow by hand.
   - `app_spacing.dart` gains the screen margin, bento gap and section gap;
     `app_styles.dart` gains `numericLarge`.
   - `theme_builder.dart` uses Manrope throughout, with the measured sizes.
2. **Assets:**
   - 36 SVG icons, byte-identical to their sources; none contains a script,
     an embedded image or an external link.
   - Seven 512 px portraits (each under 80 KB), cropped so no badge or logo
     text remains.
3. **Shared widgets** (`lib/core/widgets/`, 30 files):
   - buttons, fields, the password meter, tiles, chips and notices;
   - step header, timeline, sheets, search and the role background;
   - glass, the step transition and the theme reveal.

   Each takes its text as parameters, has a 48 dp target, and lays out at
   200 % text.
4. **AI draft versus signed is structural.** The sheet's draft and signed
   colours are nearly equal in grayscale: the text pair is 0.066 apart in
   light, and the dark containers 0.002 apart. The colours stand, as Theo
   decided. The difference comes from structure:
   - an AI draft always wears a dashed `draftBorder` frame and the
     in-progress icon;
   - signed work always carries the verification badge and no frame;
   - the caller cannot choose either icon.

   Widget tests check both variants in both themes.
5. **Screen readers.** Every control announces what it is and its state:
   - icon-only buttons take a required label;
   - selection and toggles are announced;
   - step progress reads as a phrase;
   - a field's label and input form one node;
   - a loading button keeps its label.
6. **Behaviour:**
   - the button's loading state is `SpinKitCircle`, at a fixed size;
   - the character counter no longer covers the error text;
   - the theme reveal swaps instantly under reduced motion;
   - `CodeInput` is removed, since sign-in is email only.
7. **Docs:** design system §2 rewritten to the tokens; layout and
   accessibility rules in §5 and §6; §8 items updated.

## 2. Business justification

Every screen in briefs 04 onwards is built from these pieces. Telling an AI
draft from a signed report must not depend on seeing colour: that is a
patient-safety property, not a style.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the screens (brief 04); the AR One Sans files,
still bundled but unused (§8 item 5).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Theme and widgets | **Affected** | New tokens and the widget library |
| Accessibility | Affected | Semantics throughout, 48 dp, 200 % text |
| Clinical safety | Affected | AI draft versus signed now differs by structure |
| Dependencies | None | `flutter_spinkit` and `animations` were already present |

## 5. Risk & rollback plan

- **The password field's label and input are adjacent nodes, not one.** A
  separate toggle button cannot sit inside a merged node (the framework
  asserts), so screen readers read the label, then the field, then the
  toggle.
- **The bottom sheet gained a close button** the sheet does not show,
  because dragging alone strands screen-reader users.
- **The Kiswahili for new strings comes with brief 04**, which uses these
  widgets.

**Rollback plan:** revert the commit; nothing else depends on it yet.

## 6. Implementation plan

1. Brief 03: tokens, assets, widgets, docs.
2. Review: palette and ratios recomputed, assets compared byte for byte, and
   every widget read.
3. Brief 03b: draft versus signed, screen readers, loading, counter,
   reduced motion, shadows.
4. Review: the draft and signed tests read, a `throw` in `NoticeCard.build`
   replaced with an assert and a fallback, and the gates run.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make gen`, `make fmt`, `make analyze`, `make bloc-lint` | Clean |
| `make test` | 375 passing |
| `make spell` | Pass |
| Light palette against the brief | 48 of 48 match |
| Dark and light ratios, recomputed | Match the report; all text AA |
| Icons against their sources | 36 of 36 identical; no script, embedded image or link |
| Certification | 2026-10-28 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-28 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Clinical Reviewer | Draft versus signed presentation | Covered by CTO | 2026-10-28 | Approved — structural distinction, chosen by Theo |

## 9. Post-implementation review

- With brief 04's screens, run TalkBack and VoiceOver through sign-up.
- View a draft and a signed notice in grayscale on a device.

## 10. Related records

- Previous CRQ: [CRQ-0029](./CRQ-0029-modal-token-pair.md)
- Theme foundations: [CRQ-0017](./CRQ-0017-foundations-theme-and-swahili.md)
