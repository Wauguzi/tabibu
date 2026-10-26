# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0001 |
| Title | Project bootstrap, dependency baseline, and the engineering documentation baseline |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-26 |
| Date implemented | 2026-10-27 |
| Priority | P3 Medium — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `5dff96e` (bootstrap); the documentation commit that adds this record |

## 1. Description of change

Two commits that together give Tabibu its starting point:

1. **Bootstrap (`5dff96e`).** The Very Good CLI Flutter scaffold: three
   flavors, the counter example feature, l10n, `very_good_analysis` and
   `bloc_lint`, the CI workflows, platform runners for Android, iOS, macOS,
   web and Windows, the dependency baseline for the planned stack, and the
   bundled fonts.
2. **Engineering documentation baseline (this commit).** The `docs/` tree:
   the workflow, the architecture of the app, the AI service, the outbreak
   alert engine and the notifications engine; the design system; the threat
   model; the testing standard; templates for CRQs, incident reports,
   problem records, security audits, UAT and model evaluation. Also a
   `Makefile` with the targets the docs refer to, and the project words the
   CI spell check needs.

## 2. Business justification

The hackathon judges the repository alongside the demo video and the live
product, and Technical depth and execution carries 20% of the score. Fixing
the architecture, the clinical-safety rules and the change process in writing
on day one means every feature in the next nine days is built the same way and
can be checked against a written rule. It also gives Greptile the context to
review pull requests against Tabibu's own conventions rather than generic
ones.

## 3. Scope

**In scope:** everything listed in §1.

**Explicitly out of scope:**
- Firebase configuration, rules and functions (day 3 of the plan).
- Any feature code. The counter example stays until the first real feature
  replaces it.
- Fixes for the scaffold defects the docs found (§9): each one lands with
  the change that makes it matter.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | No models yet; the Hive typeId registry starts empty |
| Roles & case scoping | None | Defined in the architecture doc, not yet implemented |
| Clinical safety | None in code | Rules S-1 to S-7 defined in the threat model, before any AI path exists |
| AI service | None | Design only |
| Security | None in code | Three findings recorded in the threat model §3 |
| Data protection | None | No data of any kind |
| Design system / UI consistency | None in code | Foundations defined; palette deferred to the first design CRQ |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low.

**Rollback plan:** revert the documentation commit; the bootstrap commit is
the project's root and has nothing to roll back to.

## 6. Implementation plan

1. Generated the scaffold with Very Good CLI and added the dependency
   baseline; committed as `5dff96e`.
2. Wrote the workflow, then the architecture, AI service, alert and
   notifications documents, the design system, and the threat model.
3. Wrote the templates and each report folder's index.
4. Added the `Makefile` and the spell-check dictionary entries.
5. Ran the checks in §7.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `dart format --set-exit-if-changed lib test` | Pass — 19 files, 0 changed |
| `make analyze` | Pass — no issues |
| `make bloc-lint` | Pass — 0 issues |
| `make test` | Pass — 8/8 |
| Rules tests | N/A — no rules yet |
| Model evaluation | N/A — no AI service yet |
| cspell over `**/*.md` | Pass — see the commit |
| Manual run | N/A — documentation only; the scaffold is unchanged |
| Certification | Documentation-only change, exempt from the on-device gate (workflow §4 step 6) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` during the hackathon | — | — |
| Clinical Reviewer | Clinical wording changed | Covered by CTO — the S-rules and patient copy conventions | 2026-10-27 | Approved |
| Security Analyst | Security impact | Covered by CTO — the threat model | 2026-10-27 | Approved |
| Compliance Officer | Data protection impact | N/A — no data, no code | — | — |
| Lead Designer | Design-system impact | Covered by CTO — the design system foundations | 2026-10-27 | Approved |

## 9. Post-implementation review

The documentation pass found four defects in the scaffold, each recorded
where it will be fixed rather than fixed here:

1. `lib/app/view/app.dart` uses `material_ui` with the generated
   localizations delegates, which crashes in any locale but English. It is
   hidden today only because the second locale is the template's Spanish.
   Fix with the switch to `sw`
   ([architecture §16](../../architecture/reports/mobile_architecture.md#16-known-architectural-debt--watchlist) item 1).
2. `android:allowBackup` is unset ([threat model §3](../../security/reports/firebase_and_ai_service_threat_model.md#3-findings)).
3. CI workflows are pinned to a tag, not a SHA (same).
4. `test_api: any` sits in runtime dependencies (same).

## 10. Related records

- Architecture/design references: [`docs/README.md`](../../README.md)
- Evaluation report(s): none
- Related Incident Report(s): none
- Related Problem record(s): none
