# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0020 |
| Title | Session layer: auth datasource and helper, RoleHelper, the encrypted cache through DBHelper, and bootstrap wiring |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P1 Critical — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

1. **`RoleHelper`** reads the role, `admin` and `alertApprover` claims and
   answers typed questions (`canAddPatients`, `canApproveAlerts`,
   `canVerifyPractitioners`). An unknown, missing or mistyped claim grants
   nothing, and it never throws. Approving alerts needs a doctor with the
   approver claim, never the claim alone.
2. **`AuthFirebase`** (datasource):
   - email sign-in, account creation (with a best-effort verification
     email), password reset and sign-out;
   - Google sign-in: a popup on web, the plugin's `authenticate()` on
     mobile; a dismissed dialog returns `false` and shows nothing;
   - claims from the ID token, with an optional refresh;
   - the two sign-up callables;
   - profile reads. The patient record is queried on `uid`, which is what
     the rule checks: a linked record's id is not its uid.

   Every failure leaves as an `AppError`. A callable's reason key wins;
   otherwise the Firebase code decides.
3. **`AuthHelper`** resolves an `AuthSession`: signed out, sign-up
   incomplete, clinic record exists (T-15), pending verification (T-14),
   patient, or practitioner.
   - **Stale token.** A role granted since the token was issued (sign-up,
     verification, linking) is picked up by one forced refresh.
   - **Offline.** It reads the remote profile first and falls back to the
     cache only when offline. Any other failure, a permission denial for
     instance, is not hidden.
   - **A role with no profile** opens nothing.
   - **Sign-out** leaves Firebase before the cache is wiped.
4. **`DBHelper`**: typed CRUD with every failure mapped to `AppError`, and
   `deleteAll` dispatching on each box's type. Two failure modes are closed:
   - `HiveError` is an `Error`, so `on Exception` never caught it.
   - Closing a typed box as `Hive.box<dynamic>` throws, which would have
     left patient data on disk after sign-out. A test found this; it now
     reopens the boxes after sign-out and checks they are empty.
5. **`HiveHelper`:**
   - AES boxes for patients, the practitioner profile and the directory.
   - The key in secure storage: every call is bounded by a timeout,
     Android's reset sentinel is treated as no key, and an unreadable key
     rotates instead of hanging.
   - Sign-out **deletes** the encrypted boxes and rotates the key: a
     cleared box would still be encrypted with the old key.
   - An unencrypted `OnboardingHive` (typeId 3) holds the onboarding flag
     and language, which survive sign-out.
   - Cloud rows never replace unsynced edits or newer rows.
   - Every read takes the signed-in uid.
6. **The cache has one owner.** `scopeTo(uid)` compares the uid stored
   beside the key and wipes a cache filled for someone else. This covers a
   session that ended without a sign-out: an expired token, a deleted
   account, a killed app.
7. **`sync_cursor.dart`** (timestamps, delta cursors with a 24-hour
   overlap, the cloud-versus-cache rule).
8. **Bootstrap** runs DI, the Google sign-in setup and the cache, each
   bounded and caught.
9. Docs: architecture §6 and the typeId registry; two review rules in
   `.greptile/rules.md`.

## 2. Business justification

Every screen behind sign-in reads the session this resolves. The cache rules
are what make a shared clinic phone safe to use.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the auth bloc, the router and its claim guard,
screens, uploads of pictures and licenses.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | typeId 3; `DBHelper` is the only way into the boxes |
| Roles & case scoping | **Affected** | `RoleHelper`; uid-scoped cache reads; the cache owner check |
| Clinical safety | Affected | A pending practitioner resolves to no clinical session |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | T-11: the sign-out wipe now provably removes data |
| Data protection | **Affected** | Patient rows never cross people on a shared device |
| Design system / UI consistency | None | |
| Localisation | None | Errors already translated (CRQ-0019) |
| Existing data | None | |

## 5. Risk & rollback plan

- **If DI fails at startup** (for example, Firebase did not initialise), the
  app still starts, and getting a helper throws. The decision route must
  treat that as signed out with an error. That's for the router change.
- **The cache owner's uid** sits in secure storage beside the key. It is an
  identifier, not health data.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Designed `DBHelper` and the Hive helper with Theo: typed access and
   selective retention, and no cached password ("remember me"), because
   Firebase holds the session.
2. Wrote each helper test-first where the behaviour is a rule (scoping, the
   wipe, the merge, the session decisions).

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make gen`, `fmt`, `analyze`, `bloc-lint` | Clean |
| `make test` | 142 passing |
| The sign-out wipe test before the fix | Failed: typed boxes could not be closed as `dynamic` |
| `make spell` | Pass |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — wipe proven, cache owned |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | Data protection affected | Covered by CTO | 2026-10-27 | Approved |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- On a device: sign in as two people in turn without signing out (kill the
  app between), and confirm the second sees nothing of the first.

## 10. Related records

- Previous CRQ: [CRQ-0019](./CRQ-0019-identity-models-errors-and-di.md)
