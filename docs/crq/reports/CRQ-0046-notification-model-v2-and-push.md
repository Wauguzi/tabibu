# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0046 |
| Title | Notification model v2 and the push trigger |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 965d919, c755bde, 155630b, ac146ae, af2b1d8, d05d289 |

## 1. Description of change

Notifications move to v2: one server-written row per recipient, an
idempotency-keyed writer, and fixed bilingual push copy.

1. **Model** (965d919): typed getters, expiry and actionable checks,
   `metadata` with `deepLink`, `pushRequestedAt`, and the server-only
   `expireAt` with 90-day TTL. Collapsed rows move `creationDate` to
   last activity and refresh `expireAt`; `newCount` lives in
   `templateArgs` only (F-20).
2. **Engine** (155630b): the notification id is the idempotency key;
   the writer reads before it writes; `sendPush` clears only its own
   claim (Catalogue 6); push copy comes from fixed en and sw
   templates, and a public alert names only the bundled disease and
   county.
3. **Sources** (c755bde): the inbox delta scoped to the recipient,
   targeted read updates that stamp `lastUpdatedAt` (R-4).
4. **The push trigger** (d05d289): `sendPush` sends the copy the row
   already carries, so it names no diagnosis, person, order number or
   model text. It acts only on a push request (`pushRequestedAt` set or
   moved), takes its claim (`pushSentAt`) only after it has found a
   token, and releases it only when still its own. A recipient with no
   device, or who turned notifications off, costs nothing and is never
   marked as pushed; a dead token is removed from the profile. An
   approver's tokens come from the staff record that
   `registerStaffToken` writes. A message from a thread collapses on
   the device by thread.
5. **Docs** (ac146ae, af2b1d8): the engine moves to v2 with its event
   list; a public outbreak alert's push may name the disease and the
   county (the push exception); the notifiable event adds the alert
   request and status, with the case link server-only.

## 2. Business justification

Every handoff in the branch — a share, a decision, an approval, an
alert — reaches the person as a notification. One writer, one id per
row and fixed copy keep redeliveries from doubling and pushes from
leaking what the inbox does not show.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the inbox screens and the push handling in
the app (the blocs branch). The alert delivery fan-out is CRQ-0049's.
No AI path is involved.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | v2 row shape; Hive 40-41; TTL on `expireAt` |
| Roles & case scoping | **Affected** | One row per recipient; reads scoped to them |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | None | Server-written rows; no new control |
| Data protection (PHI, de-identification, model endpoints) | Affected | Push copy fixed per language; alert pushes name disease and county only |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | Affected | Fixed push templates in both |
| Existing data | Affected | v1 rows keep their shape; TTL needs the field deployed (U-5) |

## 5. Risk & rollback plan

**Risk level:** Low: an additive row shape; the writer and the
trigger exist, though no screen reads the rows yet.

**Rollback plan:** revert the commits. Rows written by this branch
stay readable: the v1 readers ignore the new fields.

## 6. Implementation plan

1. The model with its expiry and actionable checks.
2. The idempotent writer with fixed copy, then the sources.
3. The engine doc to v2 with the branch (af2b1d8).
4. The push trigger, with its claim and release tested against a
   redelivered event.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01 |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), covering idempotent writes, claim and release, fixed copy, dead tokens and a push that never re-fires itself |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no screen reads the rows yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
| Security Analyst | §4 flags security impact | N/A | — | No security impact |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Fixed push copy; server-only case links |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **U-5**: whether `firebase-tools` deploys TTL from
  `fieldOverrides` is still open; the check is `make deploy-indexes`
  on dev, then the console's TTL tab. Fallback: a `make ttl` target
  (Theo runs it).
- **F-26.8 kept**: local keys include the resource uid, so two rows
  for one resource in one minute collapse by design (the one-minute
  dedupe).
- **Review finding fixed** (d05d289): the push re-fire loop. The claim
  and its release also write the notification, and neither may start
  another send, so one failure now waits for the platform's backoff
  instead of looping at once.

## 10. Related records

- Model: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Cache helper: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Outbreak alerts: [CRQ-0049](./CRQ-0049-outbreak-alerts.md)
