# [Platform or Service] Architecture

> **Template status:** blank skeleton. Copy into
> `docs/architecture/reports/<platform>_architecture.md` and fill in every
> `[bracketed]` placeholder before deleting this notice.

| Field | Value |
|---|---|
| Platform | `[e.g. Mobile & web demo (Flutter) / AI service (Python on Modal)]` |
| Owner | `[name / role]` |
| Status | `[Draft / Living / Deprecated]` |
| Last reviewed | `[YYYY-MM-DD]` |
| Reviewed by | `[name / role]` |

## 1. Purpose

`[Why this document exists and who it is for: usually a new engineer's first
30 minutes on the code, and anyone integrating with this platform.]`

## 2. Tech stack

`[Table: layer → technology → version → why, where it is not obvious.]`

## 3. High-level architecture

`[The shape of the system: layers, how state and data flow, dependency
direction. Include a diagram, even an ASCII one.]`

## 4. Folder structure

`[Annotated tree of the source layout.]`

## 5. State management

`[The pattern, the rules for using it correctly, and known footguns.]`

## 6. Data layer

`[Local cache, remote source of truth, sync strategy, offline behaviour, and
the convention for adding a new data type.]`

## 7. Dependency injection

`[Framework and the convention new code follows to be wired in.]`

## 8. Routing / navigation

`[Framework, route conventions, deep links.]`

## 9. Lifecycle

`[What starts, stops and refreshes as the app moves between foreground,
background and sign-out.]`

## 10. Security

`[Auth, secrets, anti-tamper, transport, and compliance posture.]`

## 11. Roles / authorization model

`[How roles and data scope are enforced, and the rule against any unscoped
data-access escape hatch.]`

## 12. Integration contracts

`[The interfaces to sibling services, and which document owns each.]`

## 13. CI/CD

`[Pipeline stages, what gates a merge and a release, and what deliberately
runs locally instead, and why.]`

## 14. Testing strategy

`[The test pyramid as practised, the commands, and what is out of scope.]`

## 15. Standing rules

`[Rules that exist to stop a known failure from happening, each with the
failure it prevents and the test or check that guards it.]`

## 16. Known architectural debt / watchlist

`[Trade-offs accepted for now that must be revisited before a scale or
compliance milestone. Honesty here is what makes the document trustworthy.]`

## 17. Change log

| Date | Change | Author |
|---|---|---|
| `[YYYY-MM-DD]` | `[Initial version]` | `[name]` |
