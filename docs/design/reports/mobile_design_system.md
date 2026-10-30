# Tabibu — Design System

> **The single source of truth for Tabibu's UI language**, across the
> patient, doctor and pathologist workspaces and the web demo. Every token
> cites the file it lives in, so when this document and the code disagree,
> the code wins and this file is due an update. While the Lead Designer
> seat is open, I own both the visual language and its implementation.

| Field | Value |
|---|---|
| Platform | Flutter: web demo, Android, iOS |
| Owner | Theo — CTO, Mobile Engineer (covering Lead Designer) |
| Status | Draft — foundations defined; color values set in the first design CRQ |
| Last reviewed | 2026-10-27 |
| Reviewed by | Theo |

## 1. Purpose

Three audiences use Tabibu under very different conditions: a patient on a
budget Android phone, a doctor between consultations, a pathologist at a
desk working through a list. The design system has to make one product feel
coherent across all three while making one thing unmistakable everywhere:
**what the AI wrote, versus what a qualified person signed.** That rule
(§4.1) outranks every aesthetic choice in this document.

## 2. Brand foundations

### 2.1 Color

Source of truth: `lib/core/constants/app_colors.dart`, surfaced through
`ColorScheme` and the `AppStatusColors` theme extension, both built by
`buildTheme` in `theme_builder.dart`. The light values are the design
sheet's tokens, exactly. The sheet is light only; the dark values are
derived tints that keep each text role at WCAG AA, verified when the
tokens landed: every dark text-on-container pair measures at least 7:1
(`error` 7.16:1 is the lowest), and every light pair at least 5:1.

**Brand.** Ink `#0F1A1C` drives every action. Teal `#1F6F78` is the brand
and never a button; teal text on light uses `primaryText` `#1A626A`
(6.65:1). The pastels carry calm meaning: sky `#D7E8F5`, mint `#E4F1EF`,
lavender `#E7E1FB`, butter `#FFF1C2`, peach `#FFE6D6`, and
`primaryContainer` `#BDEBEF`.

**Surfaces.** `surface` `#F5FAFA`; lowest `#FFFFFF`, low `#EFF5F5`, high
`#E3E9EA`; `outlineVariant` `#DFE5E5`; text `onSurface` `#171D1E` and
`onSurfaceVariant` `#3F484A`; outline and placeholder `#5F696B`.

**Status triples** (container / dot / text): info `#DDE7F8` / `#2F5FA7` /
`#0E2C5C`; signed `#D3EEE2` / `#1E6B52` / `#06301F`; attention `#FFE6C4` /
`#8A5300` / `#3D2400`; lowConfidence `#ECE3FB` / `#6A4FA3` / `#2A1458`;
closed `#E4E8E9` / `#5C6466` / `#2B3133`; neutral `#E3E9EA` / `#5F696B` /
`#3F484A`; aiDraft `#F4F0FB` / `#5B4A86` / `#5B4A86`; brand chip `#BDEBEF` /
`#1A626A` / `#00363C`; error container `#F9DEDC` with `#B3261E` text and
field borders.

**Draft versus signed without colour.** The sheet's pair is nearly equal
in grayscale: the text colours sit 0.066 apart in light, the dark
containers 0.002 apart. The colours stay as the sheet sets them, so the
distinction is structural instead: the draft is always dashed and carries
the draft icon, and signed is never dashed and carries the badge.
`NoticeCard` draws the draft's 1.5 px dashed `draftBorder` frame and fixes
both icons; `StatusChip` outlines only the draft tone. Widget tests hold
this in both themes.

**Gradients** (`app_gradients.dart`): skyToLavender, mintToSky,
lavenderToMint, butterWash, tealHero (`#1F6F78→#3E9AA4`), tealDeep
(`#154F56→#1F6F78`), infoWash, each with a dark counterpart in the same
hue at low lightness, so a role wash reads as a tint on a dark surface.
Role washes: patient skyToLavender, doctor mintToSky, pathologist
lavenderToMint, picked from the theme by `RoleBackground`.

**Glass** (`GlassContainer`): a σ30 blur under `glassTint` (`#FFFFFF` at
72 % light, `#000000` at 60 % dark) with a hairline `glassBorder` and a
stronger shadow in dark. Ink text on light glass measures 15.99:1 over a
lavender wash, white text on dark glass 20.06:1 over the dark surface.

Every screen is built against these **semantic roles**:

| Role | Used for | Constraint |
|---|---|---|
| `primary` | Brand only, never a button; teal gradients and washes | AA contrast for white text |
| `secondary` | Accents, selected states | |
| `ink` | Every action: primary buttons, filled bars and marks | White text on light, ink text on the dark pill |
| `aiDraft` / `aiDraftContainer` | Every surface showing unsigned AI output (§4.1) | Hues differ from `signed`, lightness barely does; layouts separate the two |
| `signed` / `signedContainer` | Signed reports and released results | |
| `draftSurface` / `draftBorder`, `editedSurface` / `editedBorder` | AI-draft versus human-edited working surfaces | |
| `urgencyUrgent`, `urgencyPriority`, `urgencyRoutine` | Worklist urgency | Always paired with a text label and an icon |
| `confidenceLow` | The low-confidence label | Never the same token as an error |
| `alertNotice` | Outbreak notices to patients | Calm, not alarm red; a notice should inform, not frighten |
| `error`, `success`, `warning` | System feedback | `success`/`warning` live in `AppStatusColors`; Material has no slots for them |
| `overlayHeatmap` | Tumor-probability heatmap | A perceptually uniform, color-blind-safe sequential ramp (viridis-like); never red-to-green |
| `overlayMaskParasitized`, `overlayMaskUninfected` | Cell outlines | Distinguishable for the common forms of color blindness; outline style differs too (solid vs dashed) |

Every role has a light and a dark value.

### 2.2 Typography

Source of truth: `lib/gen/fonts.gen.dart` (generated by `flutter_gen` from
`pubspec.yaml`), wired into `TextTheme` slots in `theme_builder.dart`.
**Manrope throughout.** AR One Sans was dropped from the theme when the
sheet landed; its font files stay in the bundle until someone removes them
deliberately (§8). The sheet's styles map onto `TextTheme` like this,
verified against the 390-wide screen frames:

| Sheet style | TextTheme slot | Value |
|---|---|---|
| hero/large ("Welcome back") | `displaySmall` | 34, w700, letter-spacing −0.5, height 1.1 |
| hero/medium | `headlineMedium` | 28, w700 |
| title/large | `titleLarge` | 22, w600 |
| title/medium | `titleMedium` | 16, w600 |
| body/large | `bodyLarge` | 16, w400 |
| — | `bodyMedium` | 14, w400 (the slot between the sheet's two body sizes) |
| body/small | `bodySmall` | 13, w400 (never under 12) |
| label/large (buttons) | `labelLarge` | 16, w600 |
| numeric/large | `AppStyles.numericLarge` | 40, w700, tabular figures |

Widgets never set `fontSize` or `fontFamily`; they use
`Theme.of(context).textTheme.<slot>`. Measurements in a report use tabular
figures (`FontFeature.tabularFigures()`) so columns of numbers align.

Noto Naskh Arabic is bundled but no Arabic locale is planned (§8).

### 2.3 Spacing & layout grid

Source of truth: `lib/core/constants/app_spacing.dart`. Base unit **4**:

| Token | Value |
|---|---|
| `xxs` | 4 |
| `xs` | 8 |
| `sm` | 12 |
| `md` | 16 |
| `lg` | 20 |
| `xlg` | 24 |
| `xxlg` | 32 |

Layout tokens on top of the scale: screen margin 20, bento gap 12,
section gap 20. On-scale raw literals are a review finding. Off-scale
values are allowed where they are deliberate, with a reason — card
padding 18 is one (§2.4).

### 2.4 Elevation, radius, shadow

Sources of truth: `lib/core/constants/app_radii.dart` for radii,
`AppShadows` in `app_shadows.dart` for shadows (`AppStyles` keeps
`cardPadding` and the `numericLarge` text style):

| Token | Value |
|---|---|
| hero | 32 |
| tile | 28 |
| card | 24 |
| field, notice | 20 |
| pill | 999 |

Card padding is 18, deliberately off the spacing scale. Cards use one
subtle shadow. The sheet removed strokes from cards, fields, pills and
buttons: resting fields are borderless white, and only focus (teal) and
error (red) draw a border. A focused field's icons and cursor take its border's
colour, teal or red; at rest the icons keep their usual shade. Clinical content (reports, the viewer) sits on
flat surfaces, so nothing decorative competes with the image.

### 2.5 Iconography

One icon set: 46 SVGs under `assets/icons/` (36 landed with brief 03, ten since),
loaded only through the generated `Assets.icons` getters, never by path.
`AssetIcon` renders them at the sheet's glyph boxes (18, 22, 24, 28) and
tints only where the sheet calls for it, since several SVGs carry baked
colours. Portraits are seven 512 × 512 JPEGs under
`assets/images/portraits/`, each under 80 KB, cropped square on the face
with any badge or logo text removed. A raw `Icons.*` glyph is a finding.
Directional glyphs mirror under RTL.

## 3. Theming

Material 3, `ColorScheme.fromSeed` from `primary` and then overridden role
by role in `buildTheme()`. Light and dark are both first-class. The theme
follows the device setting unless the person picks one, and the choice is
persisted. Theme-dependent values are read once in `build()` and passed down;
a context-watching helper called from a callback throws.

## 4. Clinical UI conventions

These are product rules, not styling preferences. Each one has a widget that
enforces it, so no screen implements it on its own.

### 4.1 AI draft vs signed

- Any unsigned AI output sits inside an `AiDraftFrame`: the `aiDraft`
  surface, a persistent "AI draft — not signed" label in the header, and the
  model names on expansion. The frame **cannot be scrolled away** from its
  content.
- A signed report renders in a `SignedReportView`: the `signed` surface,
  "Signed by {name}, {date}", and a link to the original AI draft and the
  diff.
- The two never share a layout. Someone who glances at a screen must be
  able to tell which one they are looking at in under a second, including
  in grayscale.

### 4.2 Confidence and urgency

- `ConfidenceBadge` shows the band (`High`/`Moderate`/`Low`) as text plus an
  icon, never as a bare percentage or color. Low confidence is labeled in
  words: "Low confidence — read carefully".
- `UrgencyChip` uses text, an icon and a color. Removing any one of the
  three must still leave the meaning clear.

### 4.3 The viewer

- The image is the largest element on the pathologist's screen. Overlays
  (heatmap, masks, boxes) toggle individually, with opacity control, and a
  legend is always visible while an overlay is on.
- Every finding in the draft links to its tiles or cells. Selecting a
  finding highlights its evidence, and selecting a tile shows its label,
  probability and a one-tap relabel.
- Measurements update immediately after a relabel, with a brief highlight
  on the numbers that changed.

### 4.4 Patients

- Plain language at a primary-school reading level, in English and Swahili,
  with medical terms explained the first time they appear.
- A result explanation is unavailable until the doctor marks it discussed.
  The patient sees "Your doctor will go through this result with you", not
  a locked or blurred version of it.
- Outbreak notices use `alertNotice`, a calm layout, and always end with a
  button to the official guidance.

## 5. Motion & interaction

- **Page transitions**: `CupertinoPageTransitionsBuilder` on every platform,
  for one consistent navigation feel.
- **Snackbars and dialogs**: `FadeScaleTransition` from `package:animations`,
  so every transient surface uses one motion.
- **Multi-step flows** (intake, ordering, signing): steps in a `PageView`;
  the swap between steps and from the last step to its success screen uses
  `StepTransitionSwitcher`, a `PageTransitionSwitcher` with a horizontal
  `SharedAxisTransition` that runs in reverse when stepping back. Children
  carry distinct keys so the switcher sees the change. The progress bar in
  `StepHeader` is animated segmented bars with an "n/N" count; the labelled
  step-list variant is `VerificationTimeline`.
- **Bottom sheets** (`TabibuBottomSheet`): the page blurs behind an opaque
  sheet that slides and fades in over 300 ms; dragging the handle down
  dismisses it. Glass stays for floating chrome, not sheet surfaces.
- **Theme change**: `ThemeRevealTransition` plays a 550 ms circular reveal
  from the corner over a snapshot of the previous theme, instead of an
  instant swap.
- **Role shell tabs**: `FadeThroughTransition`, provided it does not defeat
  the shell's state retention (verify before adopting).
- **Container transform (`OpenContainer`)** is not used for list-to-detail.
  It navigates outside the typed router, which breaks deep links from
  notifications.
- **Pull-to-refresh** settles when the bloc leaves its loading state.
- **Reduced motion**: when the platform asks for it, transitions shorten to
  fades.

## 6. Accessibility & internationalization readiness

- **Locales**: `en` and `sw`, at parity. A string added in one ARB file only
  is incomplete.
- **Text scale**: natural on phones; capped at 1.15x on tablets and desktop
  web. Screens are tested at 1.0x and 2.0x; an overflow at 2.0x is a defect.
- **Contrast**: WCAG AA for text on every surface, checked when the palette
  lands (§2.1).
- **Color is never the only signal** (§2.1, §4.2): the overlay legend,
  urgency and confidence all carry text. Status is always colour plus text
  plus icon, and at most two chips sit on one card.
- **Targets and type**: every tap target is at least 48 dp; no text runs
  under 12 px.
- **Selection**: mint fill plus ink check, never a heavy border.
- **Draft versus signed**: the draft is always dashed with the draft
  icon, signed never dashed with the badge (§2.1); hue alone never carries
  the distinction.
- **Screen readers**: overlays and badges have semantic labels; the viewer
  announces the selected finding.
- **Large viewports**: the pathologist workspace is designed for a desktop
  browser first, since that is where a pathologist reads. Reading content in
  sheets is capped at 640 logical pixels wide.

## 7. Content & copy conventions

- UI strings live in the ARB files. Fixed, enumerable values (urgency, roles,
  statuses) are enums whose display text comes from the ARB bundle. Copy is
  stored cased, not upper-cased in code.
- Clinical wording for report headings, alert templates and the risk-check
  advisory is fixed in templates. Models fill in fields; they do not choose
  headings.
- Voice: calm, direct, respectful. Tabibu never reassures or alarms; it says
  what is known and who decides.

**Clinical vocabulary.** Every `sw` string uses these terms, so a native
speaker can review the vocabulary once rather than every string. All are
best-effort and **pending native review**; a change here changes every
string that uses the term.

| en | sw |
|---|---|
| patient | mgonjwa (pl. wagonjwa) |
| doctor | daktari (pl. madaktari) |
| pathologist | mtaalamu wa patholojia |
| practitioner | mhudumu wa afya |
| case | kesi |
| test | kipimo (pl. vipimo) |
| sample | sampuli |
| result | matokeo |
| report | ripoti |
| appointment | miadi |
| alert | tahadhari |
| facility | kituo cha afya |
| county / sub-county | kaunti / kaunti ndogo |
| license | leseni |
| verification | uthibitisho |

Quotation marks are straight double quotes in both languages.

## 8. Known debt / not-yet-adopted patterns

1. **Resolved (brief 03).** The sheet's tokens replaced the provisional
   palette in §2, and the 37-icon set plus seven portraits landed (§2.5).
2. **Resolved (CRQ-0017).** The constants files in §2 exist and
   `buildTheme` replaces the scaffold's inline `ThemeData`.
3. **Noto Naskh Arabic is bundled with no Arabic locale planned.** Remove it,
   or keep it deliberately and record why.
4. **Resolved (CRQ-0017).** `sw` replaces the scaffold's `es`, with the
   delegates fix in [`mobile_architecture.md` §16](../../architecture/reports/mobile_architecture.md#16-known-architectural-debt--watchlist)
   item 1.
5. **AR One Sans files are bundled but no longer themed.** Remove them, or
   keep them deliberately and record why.
6. **Resolved 2026-10-28: draft versus signed is structural** (§2.1, §6).
   The sheet's colours stand; the draft always wears the dashed `draftBorder`
   frame and the in-progress icon, and signed work always carries the
   verification badge and no frame, so the two differ without colour
   (CRQ-0030).

## 9. Change log

| Date | Change | Author |
|---|---|---|
| 2026-10-28 | §2.1, §6 and §8 item 6: draft versus signed made structural (CRQ-0030). | Theo |
| 2026-10-28 | §2 rewritten to the sheet's tokens (colour, Manrope type, spacing, radii, iconography); sheet rules added to §5 and §6; §8 items 1, 5 and 6 (brief 03). | Theo |
| 2026-10-27 | §2.1 provisional palette and the draft-versus-signed panel; §8 items 1, 2 and 4 updated (CRQ-0017). | Theo |
| 2026-10-27 | §7 clinical vocabulary for `sw`, pending native review (CRQ-0014). | Theo |
| 2026-10-27 | Initial version: semantic color roles, the type pairing, the 4-point spacing scale, clinical UI conventions (AI draft vs signed, confidence, urgency, viewer, patient copy), motion rules, and accessibility targets. | Theo |
