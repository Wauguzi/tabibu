## Description

<!--- What changed and why, in a few sentences. The detail lives in the CRQ. -->

## Type of Change

<!--- Tick every box that applies and apply the matching `type/` label. -->

- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 🛠️ Bug fix (non-breaking change which fixes an issue)
- [ ] ❌ Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 🧹 Code refactor
- [ ] ✅ Build configuration change
- [ ] 📝 Documentation
- [ ] 🗑️ Chore

## Testing & Verification

<!--- Tick what you ran. docs/testing/reports/README.md says what each covers. -->

- [ ] `make fmt`, `make analyze`, `make bloc-lint`
- [ ] `make test` — count:
- [ ] `make spell`
- [ ] `make licenses` (dependencies changed)
- [ ] `make rules-test` (rules or functions changed)
- [ ] Run on device, simulator or the web demo, and certified (required for anything a person sees)
- [ ] Checked at 1.0x and 2.0x text scale, in `en` and `sw` (UI changes)
- [ ] Evaluation report filed (a model, prompt, profile or threshold changed a held-out number)

## Clinical Safety

<!--- Answer every line. A "yes" to the first needs the CRQ to explain how it was prevented,
      and the `clinical-safety` label. See the threat model, S-1 to S-7. -->

- [ ] This PR touches a path where AI output, a report, a result or an alert reaches a person
- [ ] Unsigned drafts are still readable only by the case's pathologist (S-1, S-2)
- [ ] A cancer result is still unavailable to the patient until the doctor marks it discussed, and push copy names no diagnosis (S-3)
- [ ] No alert can be delivered without approval (S-4)
- [ ] No new field leaves a case into an event, a log or a model prompt (S-5)
- [ ] Every number shown in a report is still computed in code (S-6)

## Security Boundary

<!--- Delete this section if the PR touches none of these. The `security-boundary` label is
      applied automatically from the changed paths; add `needs-deploy` if merging does not ship it. -->

- [ ] This PR touches `firestore.rules`, `storage.rules`, `firestore.indexes.json` or `functions/`
- [ ] `test/firestore_rules/` was extended to cover the change
- [ ] Deployed after merge, or a follow-up is filed

## Related Documentation

<!--- One CRQ per branch. Skip it only for a genuinely trivial change, and say why. -->

- **CRQ:** `[docs/crq/reports/CRQ-XXXX-....md, or "N/A — trivial change: <reason>"]`
- **UAT / EVAL report:** `[link, or N/A]`
- **Labels:** the CRQ's priority (`P1`–`P4`) and its `type/`. `area/*` and `security-boundary`
  are applied automatically from changed paths.
- **Architecture** docs updated: [ ] Yes &nbsp; [ ] N/A
- **Workflow** (`docs/workflow/reports/mobile_workflow.md`) updated: [ ] Yes &nbsp; [ ] N/A
- **Design system** (`docs/design/reports/mobile_design_system.md`) updated: [ ] Yes &nbsp; [ ] N/A
- **Threat model** updated: [ ] Yes &nbsp; [ ] N/A
- **Testing standard** (`docs/testing/reports/README.md`) updated: [ ] Yes &nbsp; [ ] N/A
- **Incident Report / Problem record** this PR resolves: `[link, or N/A]`

## Review

<!--- The merge bar is a 5/5 Greptile confidence score. Every finding is fixed, or answered on
      its thread; a finding accepted as a risk is recorded in CRQ §9, never silenced in config. -->

- [ ] Greptile confidence score: `_/5`
- [ ] Every Greptile finding fixed or answered
- [ ] CRQ §8 sign-offs recorded (open seats: "Covered by CTO")
