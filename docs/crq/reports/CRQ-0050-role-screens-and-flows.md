# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0050 |
| Title | The patient, doctor and pathologist screens: every designed screen whose backend exists |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-11-02 |
| Date implemented | Pending — completed on `main` after the merge (CRQ-0038) |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/ui`: 625bc08 to a16f7a1 so far (the contracts, the widgets, the blocs, the screens); hashes for the rest and the PR link are added after the merge |

## 1. Description of change

The mobile screens for the three roles, built on the data layer, functions
and rules of `feat/infra` (CRQ-0039 to CRQ-0049). Nothing on the server
changes; the app now calls what was built. The scope started as the demo
spine (S-1) and was widened by S-3.

1. **Contracts first** (625bc08, 89e9c12). Every bloc's events and states
   and an empty bloc in `BlocsHelper`, reset on sign-out; typed routes (26 at the start)
   carrying ids only (F-2); the shared widgets (headline, bars, carousel,
   tiles, rows, cards, empty and loading states, options sheet and menu,
   `AiDraftFrame`, `CheckRow`, `SignaturePad`, charts); the designer's icons
   (b9af655).
2. **Patient.** Home; find a doctor; the doctor's profile and booking
   against the server's slot rules (N-18); booked; appointments and one
   appointment; results, waiting, the shared result, and the explained
   result in English and Kiswahili once approved (F-8, H-8, H-9); the health
   notice (H-10, H-12); the signed report as a PDF shared from a temporary
   file (a16f7a1).
3. **Doctor.** Home; reports ready; booking requests with accept and a
   decline sheet of the server's four reasons (N-16); the cases tab and a
   case; an appointment with notes saved on the case (N-23); the signed
   report, summary and full, signed text only (H-19); the order flow in
   three steps with the risk check in `AiDraftFrame` and the Ministry of
   Health protocol screen (F-12, F-13); mark as discussed and approve the
   explanation (H-8); the approver's alert queue, review, reject and sent
   screens, for a doctor holding the approver claim (S-2, H-13, F-9).
4. **Pathologist.** The desk, all cases and search, with every AI item
   labelled (H-18, N-20, N-21); the case workspace with the score card
   first, then "Start from the AI draft" or "Write my own", and notifiable
   findings ticked one by one (H-16, H-20, H-21); the signing sheet with
   the attestation unticked and a drawn signature (H-3, H-17); the signed
   case and the comparison with the AI draft, for the signer and admins
   only (H-4, H-5); the signed tab (N-22).
5. **All roles.** One notifications screen, live (N-19), whose rows open
   their own screen through one mapping (F-7); the profile tab, with rows
   that lead nowhere hidden and the Accept-cases and Health-notices
   switches written through `AuthBloc` (bundle 45).
6. **S-3 additions** (rounds 5 and 6):
   - **Landed:** the profile switches (718f038); sharing a report, who can
     see it, shared reports and a doctor entering a code, with the share
     error texts (f4445e0, 4cac1b5, c8f3c26); 402 strings for the rest of
     the round (ef62efc, de3de32).
   - **Landing:** slide upload for the order flow (bundles 54 and 55: a
     bloc, a storage datasource and a Slides card on the last order step);
     the calendar, cancel and reschedule.
   - **Queued:** the consult team, appointment chat, profile details and
     settings, privacy and help pages, case history, the app lock. Each is
     added to §9 as it merges.
7. **Demo data.** `make seed-cases` seeds ten backdated cases for the three
   demo accounts through the real handlers (CRQ pending the seed's review):
   slides from public data sets, and pre-reads stored as examples, never
   live model output.
8. **Support.** Shared helpers every search screen uses (`closestMatch`,
   `isOrderNumber`); a demo directory of 22 doctors and pathologists and
   `make seed-directory`; `make verify-practitioner`, the stand-in for an
   approval screen; the approver claims on the demo doctor.

## 2. Business justification

The data layer and functions exist and no screen calls them. The demo and
the judges see screens. Each role's path runs end to end on the live
project: book, order, pre-read, score, sign, release, explain, read. The
scope widened on 2026-11-03 (S-3) because each remaining designed screen
whose backend exists would otherwise ship as a gap in front of a judge.

## 3. Scope

**In scope:** everything in §1. Group D of `design-audit.md`, which waits
for its backend, is the only exclusion, and each group-D control is hidden
(S-3).

**Explicitly out of scope:**

- Doctor-created appointments, suggest another time, download my data,
  delete account, SMS alerts, lab or facility change, and the treatment
  recommendation field: no backend yet.
- The tiles view and relabel, repeat cuts and sample problems, magnification,
  range bands, the confidence rationale, the slide viewer: no data (F-14).
- H-15's line "Your changes help the AI learn": until I confirm it matches
  the privacy notice.
- Distance on "Doctors near you" and "Get directions" (N-17): the directory
  holds a county and sub-county, never coordinates.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | No rule, function or field changes; screens read what CRQ-0040 and CRQ-0048 cache. The demo directory is seed data only |
| Roles & case scoping | Affected, not widened | Every read goes through a helper that takes the signed-in uid. The approver surfaces are guarded twice: the router redirect and the rules (F-6). A doctor without the claim never sees them (S-2) |
| Clinical safety | **Affected** | See below |
| AI service (prompts, models, thresholds) | None | The app calls no model and adds no client, key or endpoint |
| Security (rules, App Check, RASP, secrets) | None | A raw share code is held in memory once, never logged, cached or routed (bundle 47 rule 1). The signature is never stored on the phone (H-17). No credential added |
| Data protection (PHI, de-identification, model endpoints) | None | No new field leaves a case. The PDF is shared from a temporary file |
| Design system / UI consistency | Existing pattern reused | One `AiDraftFrame` for every unsigned AI output (H-1) and `SignedReportView` for signed text; status tones fixed (N-3) |
| Localisation (en, sw) | Affected | Every string in both ARB files. Kiswahili is ours and is labelled so |
| Existing data | None | — |

**Clinical safety.** No AI output reaches a person without an approval,
except to the readers S-8 names, each labelled. How each path is held:

- **Pre-read and report draft** reach the pathologist only, in
  `AiDraftFrame`, and lose the label once edited (H-1, H-2). A doctor never
  sees an unsigned draft or the AI diff (H-6, H-7, H-19).
- **Signing** needs the unticked attestation, a drawn signature, and a
  device online (H-3, H-17). The pre-read is scored before writing, because
  the rules require it (H-20). Nothing in the score is preselected or
  inferred (H-16).
- **Notifiable findings** are the pathologist's, ticked one by one, from
  the diseases the case's own tests confirm. A ticked finding is sent with
  `alertRequested: false`; the engine decides (H-21, H-3).
- **A cancer result** reaches the patient only after "Mark as discussed"
  (S-3 in the threat model, H-8). The explanation reaches the patient only
  once approved, with the approval labelled (F-8, H-9).
- **An alert** reaches a patient only after the approver's decision. The
  approver sees both drafts in `AiDraftFrame` and approves the revision they
  saw (H-13). Hotline numbers come from the guidance asset (H-12).
- **The risk check** is advice, never the signed colour, and never says it
  confirms or rules out a disease (H-11, S-7).
- **The pathologist's desk** shows AI items to its qualified reader under
  S-8, each with the AI tone and sparkle (H-18).

## 5. Risk & rollback plan

**Risk level:** High. These are the screens where an unsigned AI output
could be shown as signed, or a result shown early. The rules in
`decisions.md` H-1 to H-21 are mapped to tests in each high-risk bundle's
report, and I read each against the code line by line before it was
committed.

**Rollback plan:** revert the merge commit; the app returns to the
placeholder screens and every server-side gate is unchanged. A single
screen can be reverted by its commit. Nothing is deployed with this change,
so there is no rules, functions or Remote Config step.

## 6. Implementation plan

1. Contracts, routes and shared widgets ahead of the screens, so the two
   coding agents work on disjoint files.
2. Data and blocs before screens, each with `bloc_test`.
3. Screens per role, one bundle each: Muse Code owns the ARB files and the
   screens, Cursor owns data, blocs and feature widgets. Neither commits.
4. Each bundle reviewed by me, high-risk bundles against their numbered
   rules in the code, gated on its own files, and committed on its own.
5. The decisions that depart from the designs recorded in `decisions.md`
   and summarised in §9.
6. The device pass per role, then the pre-review, then the pull request.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass at the last full gates (round 5); each later bundle gated on its own files. Full run with the pull request |
| `make test` | Pass — 2,630 tests at the last full run, before bundles 42 to 44; later bundles gated on their own directories. Final count with the pull request |
| `make spell` | Full run with the pull request; every edited file checked as it was committed |
| Rules tests | N/A — no rules change |
| Model evaluation | N/A — no model, prompt or threshold change |
| Manual run (device / simulator / web) | Pending — the device pass per role, with the designer |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-03 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | Pending — rounds recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Pending | — | The Kiswahili copy and the clinical wording are read by a clinician after the demo build |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | No rules or secrets change; share-code handling reviewed in bundle 47 |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | No new data leaves a case |
| Lead Designer | §4 flags design-system impact | Pending | — | The device pass with the designer |

## 9. Post-implementation review

Decisions that depart from the designs (the full text is in
`.briefs/07/decisions.md`):

- **S-1, S-2, S-3.** The scope began as the demo spine and was widened to
  every designed screen with a backend. The alert approver is a doctor
  holding the `admin` and `alertApprover` claims, so approver surfaces show
  only to that doctor. This reverses the earlier assumption of a separate
  approver account.
- **N-20 to N-23.** Case numbers are the server's
  (`ODR-JK-AW-02112026-001`), never the designs' "TB-0231". The desk shows
  only what the worklist and the case carry: no thumbnails or heatmaps, no
  headline measurement, no "Repeat test". The signed tab counts only what
  is stored and omits "Draft fields edited". "End appointment" is disabled
  until the slot starts, as the server requires.
- **F-12, the order flow.** The designs assumed a risk check before the
  order exists and a "paused" order. The server creates the order first and
  runs the check afterwards, so the flow is three steps (tests, details,
  risk check and pathologist) with the case uid made once, so a retry never
  makes a second case. A flagged check adds the protocol card outside the
  frame and a ticked "The protocol is in place" before sending. AI-suggested
  tests read "Order separately". I accepted this.
- **H-20, score first.** The designs score the pre-read at signing. The
  rules require a score before the pathologist can set a diagnosis or adopt
  the AI text, so the workspace opens on the score card. The signing sheet
  keeps the score step as a safety net.
- **H-19 footnote.** "The AI draft is kept on record beside this report."
  stays on the doctor's report: it states provenance, not the diff. I
  confirmed this.
- **P-14's listen card** is removed until there is audio (e859157).
- **F-10 and F-11** hid controls whose screens were not yet in scope; S-3
  shows each as its bundle lands. A control leading to group D stays hidden.
- **Share-code handling.** The server returns no plain code (it sits on
  the recipient's notification, T-18), so the share screens never show or
  cache one: the sender sees who it went to and when access ends, the
  recipient types the code from the notification into an empty field, and a
  notification route carries the share id only. The share button says
  "Share", not "Share with Face ID", until the app lock lands, because no
  Face ID check runs before then.
- **Slides.** Slides are uploaded to Storage and never linked: the server
  fetches no external URL. The doctor uploads between creating the order and
  the pathologist's acceptance, the pathologist after; each slide needs a
  pixel size the uploader supplies, with no default, because it sets the
  physical size in every measurement. Order attachments (files and links)
  stay out: `createOrder` has no field for them.
- **Contact details.** The help and privacy pages carry one confirmed
  number; invented addresses, a short code and SMS and WhatsApp rows were
  removed (de3de32), and the copy no longer claims an SMS the server does
  not send.
- **Attribution line.** CRQ-0049 deferred the alert attribution line to
  this branch. It is built as O-1 resolved it: "Approved for release by an
  authorised Tabibu clinician. Guidance: {source}", with no approver name,
  because the outbreak engine keeps the approver anonymous on a delivered
  alert. The design system, architecture, outbreak engine, AI service and
  threat model documents were updated with it.

Follow-ups:

- `notification_cache_helper_test` "watchInbox a failing merge is skipped"
  is flaky under parallel load; it passes alone.
- Rounds 5 and 6 (bundles 45 to 53) are recorded here as they merge.
- Greptile's rounds and the final test count, after the merge.

## 10. Related records

- Data layer: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md), [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Orders and the risk check: [CRQ-0041](./CRQ-0041-case-orchestrator-orders-and-payment.md)
- Share codes: [CRQ-0042](./CRQ-0042-share-codes.md)
- Signed reports, release and the PDF: [CRQ-0043](./CRQ-0043-signed-reports-release-and-pdf.md)
- Appointments: [CRQ-0044](./CRQ-0044-appointments-availability-and-voice-input.md)
- Conversations and the consult team: [CRQ-0045](./CRQ-0045-conversations-mdt-and-voice-notes.md)
- Notifications: [CRQ-0046](./CRQ-0046-notification-model-v2-and-push.md)
- Model performance signals (the score): [CRQ-0047](./CRQ-0047-model-performance-signals.md)
- Outbreak alerts: [CRQ-0049](./CRQ-0049-outbreak-alerts.md)
- Records after the merge: [CRQ-0038](./CRQ-0038-merge-commits-and-kept-branches.md)
