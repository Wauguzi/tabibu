# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0013 |
| Title | Muse Code as a second coding agent: `make muse`, `AGENTS.md`, and a credit floor |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

1. **`make muse`** starts Muse Code (Meta's terminal coding agent,
   1.4.13) with the Meta API key from the Keychain in its environment only.
   It never receives the Baseten key, and the key is never stored by Muse
   Code (`muse auth set`) or exported in a shell profile (CRQ-0007). It
   stops with a message if `muse` or the key is missing. Extra flags pass
   through `ARGS`.
2. **`AGENTS.md`** at the root: the rules Muse Code loads for this
   repository. It points at `.greptile/rules.md` and the governing docs
   and sets hard rules: never commit or push, the app talks only to
   Firebase, no credentials, stop and ask near AI output, no names of other
   projects, no new dependencies or edits to CI, rules, functions or
   signing unless briefed, and the `make` gates before handing back.
3. **Way of working.** I write a brief for each repetitive task; Muse Code
   implements it in its own terminal on the same branch; I review the diff
   and run the gates, then it is committed. Design, security rules, custom
   claims, the auth flow and anything touching S-1 to S-7 are not briefed
   out. Both agents never edit the same files at the same time.
4. **Workflow §5** lists Muse Code.

## 2. Business justification

Repetitive work (screens to the design system, `en`/`sw` strings, models,
test scaffolding) is most of the remaining build, and the deadline is
fixed. A second agent working from written briefs moves that work in
parallel while review stays with one person.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** Muse Code in CI or Greptile's place; any
change to the merge bar.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | Guarded | `AGENTS.md` keeps AI-output paths out of briefs and requires stopping to ask |
| AI service | **Affected** | Shares the Meta API credits (§5) |
| Security (rules, App Check, RASP, secrets) | Affected | The Meta key sits in Muse Code's process environment |
| Data protection | None | No patient data exists; the repository is public |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Credits.** Muse Code bills per token against the same $150 Meta API
balance that Muse Spark 1.3 and SAM 3.1 need for the pre-read and its
evaluation. **Floor: stop using Muse Code when the balance reaches $100.**
That leaves the product its budget; check the balance at the end of each
session.

**Key exposure.** The key is in Muse Code's environment, so commands it
runs may inherit it. Its sandbox, approvals (`on-request`) and network
proxy (`proxy-only`) stay on, `--yolo` is never used, and `AGENTS.md`
forbids printing the environment. If the key is ever printed into a
session, rotate it (CRQ-0007 §5).

**Workspace.** Muse Code cannot write to `.git`, so it cannot commit.

**Rollback plan:** revert the commit; `muse logout` clears anything Muse
Code stored.

## 6. Implementation plan

1. Read the install script before running it: HTTPS only, checksum when
   the server advertises one, installs to `~/.local/bin` without `sudo`,
   adds a PATH line to the shell profile.
2. Read Muse Code's configuration, authentication and permissions docs.
3. Added the target, `AGENTS.md` and the record.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `muse --version` | 1.4.13 (1.4.13-R6996.1) |
| `~/.config/muse/settings.json` | `schema_version` 1, sessions kept 14 days |
| `make -n muse` | Expected commands; the key is read inside the recipe |
| `make spell` | Pass |
| First session (`make muse`, trust the workspace) | Not yet |
| Certification | 2026-10-27 — Theo (tooling; no app code) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — key from the Keychain, sandbox and approvals on |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Record the balance after the first day of use; revisit the floor if the
  pre-read evaluation needs more.

## 10. Related records

- Previous CRQ: [CRQ-0012](./CRQ-0012-vscode-launches-and-ios-15.md)
- Secrets handling: [CRQ-0007](./CRQ-0007-secrets-handling-for-model-api-keys.md)
