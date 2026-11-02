# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0042 |
| Title | Share codes |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 155630b, c6dfc8e, fe013dd, af2b1d8, d05d289 |

## 1. Description of change

How a case is shared with one practitioner: a short code bound to one
recipient, not a credential (T-18 reworded, F-15).

1. **Server** (155630b): codes are HMAC-hashed with an injected key,
   compared in constant time, locked after five attempts, reissued in
   place with no ceiling (throttled 3/hour), and shown only in the
   recipient's notification. `inviteToCase` is retired: a patient's
   `Join` share replaces it. Redemption re-checks the cap, the
   participation and the recipient's verified-practitioner role.
2. **App reads** (c6dfc8e): share-code queries by participant, with the
   secret never reaching a log, an error or a Hive box (CRQ-0040).
3. **Rules** (fe013dd): the `shareCodes` read is two equalities
   (F-26.14); RT-58, RT-69/70.
4. **Docs** (af2b1d8, 72082f5): the threat model carries T-18 with its
   controls; redemption and reissue are transactions in the review
   rules.

5. **Callables** (d05d289): `createShareCode`, `redeemShareCode`,
   `revokeShareCode` and `reissueShareCode`, with the hashing key
   injected into the three that mint, redeem or reissue one. A `Join` share
   is the patient's; a `ReportUnlock` is made by the signer for the
   ordering doctor, and refuses revocation, so a released report can
   never be stranded. Only signing a newer version retires one.
   `sweepCases` expires pending shares.

An `isCritical` version unopened after 24 hours re-notifies the doctor
and the signer daily, with no "critical" in the push (F-15); the
`sweepCases` schedule runs it (d05d289).

## 2. Business justification

Sharing is the riskiest handoff: a code that leaks must open nothing
for a stranger, and a report must never strand because its code
expired. Binding, attempt limits and reissue give both.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the join/accept screens that redeem the
code (the blocs branch). No AI path is involved.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | Server-only code hashes; no client write, no box holds a secret |
| Roles & case scoping | **Affected** | Redemption grants participation to one verified practitioner |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | **Affected** | HMAC key injected (F-26.2); constant-time compare; 5-attempt lock; T-18 |
| Data protection (PHI, de-identification, model endpoints) | Affected | A code opens one case for one recipient only |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | None | No new user-visible strings |
| Existing data | None | `inviteToCase` callers are gone from the branch |

## 5. Risk & rollback plan

**Risk level:** Medium: a secret-handling path. The callables exist,
though no screen calls them yet.

**Rollback plan:** revert the commits. Rotate the HMAC key if a code
was ever issued against it.

## 6. Implementation plan

1. The server hashing and redemption first, with lockout and reissue
   tests, then the callables over them.
2. The app's read-only sources, with the secret excluded by
   construction and by test.
3. Rules and their tests, then docs.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01 |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), covering hashing, lockout, reissue, recipient binding and the four callables |
| Rules tests | Pass — RT-58, RT-69/70 (two equalities, delta queries) within RT-45..RT-200 |
| Secrets | Injected key; emulator `.secret.local` ignored; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no screen calls the callables yet |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | Pending | Recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | HMAC, lockout, reissue; rules tests per read |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | One recipient per code; no secret on the device |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **Residual (T-18)**: a recipient's own device shows the code in
  their notification; nothing further can bind it. Reopen if codes are
  seen redeemed by strangers: shorten the expiry.
- **`pendingShares` counts `Join` only** (F-11b F-23); `signReport`
  revokes the previous version's pending unlock when it lands.
- **Review finding fixed** (d05d289): a stranded report unlock. The
  signer's `ReportUnlock` can no longer be revoked, and a reissue
  replaces a lapsed code in place, so the ordering doctor always has a
  way to open the report.

## 10. Related records

- Pipeline: [CRQ-0041](./CRQ-0041-case-orchestrator-orders-and-payment.md)
- Cache eviction on leaving: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Notifications: [CRQ-0046](./CRQ-0046-notification-model-v2-and-push.md)
