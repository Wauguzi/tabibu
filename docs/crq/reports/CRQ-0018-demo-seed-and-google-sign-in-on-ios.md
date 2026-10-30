# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0018 |
| Title | Demo seed (one account per role, an alert approver, clinic patients) and the iOS URL scheme for Google sign-in |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 (emulator); live seed pending |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

1. **`functions/src/seed.ts`** creates the spec's demo accounts for Wed 28
   Oct:
   - An admin.
   - A doctor, at Mbagathi District Hospital, holding the `alertApprover`
     claim.
   - A pathologist, at Kenyatta National Hospital.
   - A patient in Westlands.
   - Two patients added by the doctor, with no accounts.

   It calls the same handlers as the callables (CRQ-0016), so seeded data
   passes every check a real sign-up does. Practitioners get a placeholder
   license in their own `licenses/` folder and are verified by the admin
   handler, so their claims and directory entries come from the real path.
   Running it again reuses what exists.
2. **Make targets:**
   - `seed-password` stores the demo password in the Keychain
     (`tabibu-seed-password`).
   - `seed-emulator` seeds running emulators.
   - `seed-live CONFIRM=tabibu-86ea2` seeds the live project through
     Application Default Credentials. `SEED_EMAIL_TEMPLATE` sets the account
     addresses, with `{role}` replaced per account (the default is
     `{role}@tabibu.test`); a plus-addressed Gmail sends every account's mail
     to one inbox.
3. **Guards** in the script:
   - Emulator mode needs all three emulator hosts (Firestore, Auth,
     Storage). A missing host would otherwise send that service's writes
     to the live project, because the emulators run under its id.
   - `--live` refuses if any emulator host is set.
   - The password must be at least 12 characters and is never printed.
4. The seed is excluded from the deployed build and upload.
5. **iOS `Info.plist`** registers the reversed client id as a URL scheme.
   Google sign-in on iOS returns through it.

## 2. Business justification

Judges need one working account per role, and the spec asks for an approver
permission on one doctor. Seeding through the handlers keeps the demo data
honest: nothing exists that the app could not have created.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** case, order and alert seed data (they arrive
with their features); choosing the live demo domain.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | Writes only through the handlers |
| Roles & case scoping | Affected | Creates claims, including `admin` and `alertApprover` |
| Clinical safety | None | No clinical data |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | Affected | The password stays in the Keychain; live seeding needs an explicit confirmation |
| Data protection | None | Invented people, `+2547000…` numbers |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

- **The admin account can verify practitioners.** Its password is the
  shared demo password; rotate it (`make seed-password`, then reset it in
  the Console) before any real practitioner signs up.
- **Demo addresses.** `tabibu.test` cannot receive mail, so password reset
  will not work for it. Use a domain we control for the live seed.

**Rollback plan:** delete the seeded users in the Console; their documents
follow with a manual delete (no data depends on them yet).

## 6. Implementation plan

1. Write the seed over the existing handlers.
2. Run it twice on the emulators to check idempotency.
3. Live: once the rules and functions are deployed, and the domain chosen.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| Seed twice on Auth, Firestore and Storage emulators | Both runs succeed; the second reuses everything |
| `tsc`, `eslint` | Clean |
| `plutil -lint ios/Runner/Info.plist` | OK |
| `make spell` | Pass |
| Live seed | Not yet |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-10-30 | Approved — [PR #6](https://github.com/Wauguzi/tabibu/pull/6), 5/5 at round 3 |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — Keychain password, confirmed live target |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- After the live seed, sign in as each role on Android, iOS and web.

## 10. Related records

- Previous CRQ: [CRQ-0017](./CRQ-0017-foundations-theme-and-swahili.md)
- Handlers: [CRQ-0016](./CRQ-0016-identity-functions-and-rules.md)
