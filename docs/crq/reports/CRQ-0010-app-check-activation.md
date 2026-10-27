# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0010 |
| Title | App Check activated in bootstrap, with a Keychain-held debug token; enforcement deferred |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

1. **`lib/bootstrap.dart`** activates App Check after Firebase initialises,
   bounded by the bootstrap timeout and caught on failure:

   | Build | Android | iOS |
   |---|---|---|
   | Release | Play Integrity | App Attest |
   | Debug, profile | Debug provider | Debug provider |

2. **The debug token is a credential**: any request carrying a registered
   token passes App Check. It is kept like the model keys:
   - `make app-check-token` creates a token, stores it in the Keychain
     (`tabibu-app-check-debug-token`) and copies it to the clipboard for
     Firebase → App Check → Apps → ⋮ → Manage debug tokens.
   - `make app-check-token-copy` copies the stored token again, for another
     app or machine, without printing it.
   - `make run-dev` passes it as `--dart-define=APP_CHECK_DEBUG_TOKEN`.
     Without it, the debug provider generates a token per install and logs
     it, and each one must be registered by hand.
   - `make keys-check` reports it with the model keys.
   - It is read only by the debug provider, which release builds never use,
     and is never passed to a release build, CI or fastlane. The Greptile
     rules carry this as the single exception to "no credential in
     `--dart-define`".
3. **Enforcement stays off** for every API. Enforcement applies per API to
   every client, and today no release build can attest:

   | Platform | Attestation needs | Status |
   |---|---|---|
   | Android | Play Console app record with at least one upload; the app-signing certificate's SHA-256 in Firebase | No Play Console app yet |
   | iOS | Apple Developer team id registered for App Attest | No Apple Developer account yet |
   | Web | reCAPTCHA Enterprise key; Firebase configured for web | Neither yet |

   Enforcing now would reject every App Distribution build.
4. **Docs:** architecture §10 and §16 item 7; threat model T-7 and T-10
   moved to partial; the Greptile exception.

## 2. Business justification

Activating now means every build already sends App Check tokens, the
console's request metrics show what enforcement would reject, and the switch
to enforcement is a console change, not a code change, once attestation is
possible. Rules remain the primary control (T-1 to T-3) in the meantime.

**Alternative considered:** passing the debug token from a shell
environment variable. It works, but leaves a bypass credential in shell
history and dotfiles; the Keychain keeps it with the other keys.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** enforcement; the App Attest entitlement in
`Runner.entitlements` (needs the Apple Developer account); the web provider
(needs Firebase for web, §16 item 8).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | **Affected** | App Check active, unenforced; a new Keychain-held credential |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low. Unenforced, App Check only attaches tokens; a failed
activation is caught and the app starts normally.

**When enforcing:** enforce one API at a time, starting with Firestore,
after the console's metrics show verified requests from release builds, and
watch error rates; Authentication's enforcement is still in preview.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Confirmed the resolved `firebase_app_check` (0.5.1) provider API.
2. Added activation to `bootstrap`, and the Keychain token targets.
3. Updated the docs and the Greptile exception.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `flutter analyze lib test` | No issues |
| `make bloc-lint` | 0 issues |
| `flutter test` | 8 passed |
| `dart format` | No changes |
| `make spell` | Pass |
| `make -n run-dev`, `make -n app-check-token` | Expected commands |
| `make keys-check` | Lists the token as `MISSING` until created |
| Debug build sends a valid token (console metrics) | Not yet: after the token is registered |
| Certification | 2026-10-27 — Theo (startup only; no feature code) |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved — token in the Keychain, debug builds only |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

| Step | Result |
|---|---|
| Play Integrity registered for the Android app | Done 2026-10-27 |
| iOS attestation provider | Not registered: needs the Apple Developer account |
| Debug token created (`make app-check-token`) and registered as `theo-macbook-dev` on the Android and iOS apps | Done 2026-10-27 |
| Verified requests from `make run-dev` in the console | Pending: the scaffold makes no Firestore or Auth calls; checked once the auth branch does |

- Revoke `theo-macbook-dev` in the console if this machine is lost, then
  create a new token with `make app-check-token`.
- Decide before the demo whether enforcement is possible: it needs the Play
  Console record ($25, one-time) at minimum, or it waits until after the
  hackathon.

## 10. Related records

- Previous CRQ: [CRQ-0009](./CRQ-0009-crashlytics-error-reporting.md)
- Threat model: [T-7, T-10](../../security/reports/firebase_and_ai_service_threat_model.md#42-security-threats)
