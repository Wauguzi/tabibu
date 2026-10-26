# Tabibu engineering docs

How Tabibu is built, how changes are made, and how quality and safety are
checked. Start with the workflow, then the architecture, then the design
system.

## Living documents

| Area | Document | What it answers |
|---|---|---|
| Workflow | [Engineering workflow](./workflow/reports/mobile_workflow.md) | Who does what, how a change ships, severity, definition of done |
| Architecture | [Mobile & web architecture](./architecture/reports/mobile_architecture.md) | Layers, state, data, lifecycle, roles, CI, standing rules |
| Architecture | [AI service & pre-read pipeline](./architecture/reports/ai_preread_service.md) | Segment, classify, measure, draft; signing; endpoint and cost policy |
| Architecture | [Outbreak alert engine](./architecture/reports/outbreak_alert_engine.md) | Tag, record, detect, draft, approve, deliver |
| Architecture | [Notifications engine](./architecture/reports/notifications_engine.md) | Inbox, push, idempotency, lock-screen safety |
| Design | [Design system](./design/reports/mobile_design_system.md) | Tokens, AI draft vs signed, motion, accessibility |
| Security | [Threat model](./security/reports/firebase_and_ai_service_threat_model.md) | Clinical-safety rules S-1 to S-7, threats T-1 to T-12 |
| Testing | [Testing standard](./testing/reports/README.md) | The test layers, UAT and model evaluation reports |

## Records

| Record | Index | Template |
|---|---|---|
| Change requests (CRQ) | [crq/reports](./crq/reports/README.md) | [CRQ_TEMPLATE](./crq/templates/CRQ_TEMPLATE.md) |
| Incident reports (IRP) | [incidents/reports](./incidents/reports/README.md) | [IRP_TEMPLATE](./incidents/templates/IRP_TEMPLATE.md) |
| Problem records (PMF) | [problems/reports](./problems/reports/README.md) | [PMF_TEMPLATE](./problems/templates/PMF_TEMPLATE.md) |
| Security audits | [security/reports](./security/reports/README.md) | [SECURITY_AUDIT_TEMPLATE](./security/templates/SECURITY_AUDIT_TEMPLATE.md) |
| UAT reports | [testing/reports](./testing/reports/README.md) | [UAT_TESTING_TEMPLATE](./testing/templates/UAT_TESTING_TEMPLATE.md) |
| Model evaluations | [testing/reports](./testing/reports/README.md#evaluation-reports) | [MODEL_EVALUATION_TEMPLATE](./testing/templates/MODEL_EVALUATION_TEMPLATE.md) |

Blank skeletons for new living documents:
[architecture](./architecture/templates/ARCHITECTURE_TEMPLATE.md),
[design system](./design/templates/DESIGN_SYSTEM_TEMPLATE.md),
[workflow](./workflow/templates/WORKFLOW_TEMPLATE.md).

## Conventions

- Every document carries an owner, a status and a "Last reviewed" date, and
  ends with a change log.
- Known gaps are written down, not glossed over. A document that claims more
  than the code does is worse than no document.
- A change that alters what a document says updates that document in the
  same commit.
