# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0032 |
| Title | Email addresses are validated before any call and confirmed before any profile is created |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-29 |
| Date implemented | 2026-10-29 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Device testing showed sign-up accepting any address and never confirming it.
The design has a verification step between the account and the profile; this
change builds everything under it. The screen itself follows in brief 05a
([CRQ-0034](./CRQ-0034-sign-up-screens.md)).

1. **Validation** (`lib/core/utils/email_address.dart`):
   - `isValidEmail`: one local part, one `@`, a dotted domain, a top-level
     domain of two or more letters, no spaces, no double dots, at most 254
     characters;
   - `AuthHelper` refuses a malformed address with `invalidEmail` before
     sign-in, account creation or a reset reaches Firebase;
   - `maskEmail` (`a•••@gmail.com`) for the verification screen.
2. **The session knows.** `SignUpIncompleteSession` carries `emailVerified`,
   from the Firebase user. A Google account arrives confirmed. An unknown
   value counts as unconfirmed.
3. **Landing and routing:**
   - `Landing.verifyEmail` sits before `finishSignUp`: a signed-in account
     with no profile and an unconfirmed address lands on `VerifyEmailRoute`
     (`/account/verify-email`), from a cold start or a sign-in;
   - the guard holds the route for signed-in accounts, like the other
     `/account` routes.
4. **`AuthBloc`:**
   - `EmailVerificationCheckRequested` reloads the user and, once confirmed,
     refreshes the ID token, so the `email_verified` claim the server checks
     is current. It then resolves the session again and emits
     `EmailVerificationCheckSuccess(isVerified:)`. "Not yet" is a success
     that says so, not an error.
   - `VerificationEmailResendRequested` sends another link.
   - Both are `droppable()` and check connectivity first.
   - A confirmed address logs `email_verified` to analytics.
5. **The server refuses an unconfirmed address.** `completePatientSignUp`
   and `completePractitionerSignUp` refuse a caller whose token is not
   `email_verified`, with `emailNotVerified`, which the app maps to its own
   message. A client gate alone could be skipped by calling the function.
   Accounts created by a doctor (`addPatient`) and by the seed are unaffected:
   the seed creates confirmed accounts.

## 2. Business justification

A profile tied to an address nobody controls cannot receive a password reset,
a verification decision or a result notice. It is also how an impersonator
would claim someone else's email.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the verification screen (brief 05a);
`addPatient` accounts, which a doctor creates in person.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Cloud Functions | **Affected** | Self sign-up refuses an unconfirmed caller |
| App auth and routing | **Affected** | New landing, route, events and states |
| Localisation | Affected | `errorEmailNotVerified` in English and Kiswahili |
| Security (rules, App Check, RASP, secrets) | Affected | Confirmation enforced on the server, not only in the app |

## 5. Risk & rollback plan

- **Deploy the functions with the app.** Until the verification screen
  ships, a fresh email sign-up cannot complete against the deployed
  functions, by design. The functions deploy after review, with the
  screen.
- **The token is refreshed only once confirmed.** A refresh while
  unconfirmed would change nothing and cost a round trip.

**Rollback plan:** revert the commits. A profile created meanwhile stays
valid: its address was confirmed.

## 6. Implementation plan

1. The verification flow: check by reloading the user;
   resend; the decision screen holding unconfirmed accounts.
2. The server gate, test first.
3. The validator, the session flag, the landing, the route, the bloc
   events.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make functions-test` | 40 passing: an unconfirmed caller is refused by both callables, and nothing is written |
| `email_address_test.dart` | Valid addresses pass; 11 malformed ones fail, including `a@b`, `a b@c.com`, `a@@b.com`, `a@b.c`, `a..b@example.com` |
| `auth_helper_test.dart` | A malformed address never reaches Firebase; "I've verified" reloads, then resolves; resend; the session carries the flag |
| `auth_bloc_test.dart` | Confirmed, not yet, offline, resend success and refusal |
| `landing_test.dart` | Unconfirmed lands on verification; confirmed goes on to the role choice; the route needs an account |
| Certification | 2026-10-29 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-29 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-10-30 | Approved — [PR #6](https://github.com/Wauguzi/tabibu/pull/6), 5/5 at round 3 |
| Security Analyst | Authentication | Covered by CTO | 2026-10-29 | Approved — enforced on the server |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No impact in §4 |
| Compliance Officer | §4 flags data protection impact | N/A | — | No impact in §4 |
| Lead Designer | §4 flags design-system impact | N/A | — | No impact in §4 |

## 9. Post-implementation review

- On a device: create an account, leave before confirming, sign in again and
  land on verification; confirm in the mail app, return, and continue.

## 10. Related records

- Previous CRQ: [CRQ-0031](./CRQ-0031-file-picker-service.md)
- Auth and routing: [CRQ-0027](./CRQ-0027-auth-bloc-and-router.md)
