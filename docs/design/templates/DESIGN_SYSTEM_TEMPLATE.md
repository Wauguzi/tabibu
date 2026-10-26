# [Platform] Design System

> **Template status:** blank skeleton. Copy into
> `docs/design/reports/<platform>_design_system.md` and fill in every
> `[bracketed]` placeholder before deleting this notice.

| Field | Value |
|---|---|
| Platform | `[e.g. Mobile & web demo (Flutter)]` |
| Owner | `[name / role]` |
| Status | `[Draft / Living / Deprecated]` |
| Last reviewed | `[YYYY-MM-DD]` |
| Reviewed by | `[name / role]` |

## 1. Purpose

`[Why this document exists and who reads it: engineers implementing UI, and
anyone building a sibling surface that must look the same.]`

## 2. Brand foundations

### 2.1 Color

`[Token table: name → hex → usage. Cite the constants file; never re-type
values by hand, so this doc cannot drift from the code.]`

| Token | Value | Usage |
|---|---|---|
| `[primary]` | `[#XXXXXX]` | `[...]` |

### 2.2 Typography

`[Font pairing and rationale, weights, and the mapping from TextTheme slots
to family, size and weight. Cite the generated token source.]`

### 2.3 Spacing & layout grid

`[Base unit, scale, and how fully it has been adopted. Say so plainly if it
has not been adopted everywhere.]`

### 2.4 Elevation, radius, shadow

`[Shadow and radius tokens, and where they live.]`

### 2.5 Iconography

`[The icon set, and when a platform icon is acceptable.]`

## 3. Theming

`[Light/dark strategy, how the theme is resolved at runtime, and any theme
extensions.]`

## 4. Component inventory

`[Every shared component, one line each: name → purpose → states → location.]`

## 5. Motion & interaction

`[Transitions, micro-interactions, loading states; what is restrained and
what is expressive.]`

## 6. Accessibility & internationalization readiness

`[Text scaling, contrast, color-blind safety, RTL, locales, and known gaps.]`

## 7. Content & copy conventions

`[Where strings live, tone and voice, localisation hooks.]`

## 8. Known debt / not-yet-adopted patterns

`[Everything that exists but is not used everywhere yet.]`

## 9. Change log

| Date | Change | Author |
|---|---|---|
| `[YYYY-MM-DD]` | `[Initial version]` | `[name]` |
