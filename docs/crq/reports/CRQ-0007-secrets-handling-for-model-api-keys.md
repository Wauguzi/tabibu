# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0007 |
| Title | Secrets handling for the model API keys: Keychain for local runs, server-side stores in production, scanning before a push |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | The commit that adds this record |

## 1. Description of change

The Baseten key ($100 of credit, Muse Spark Open only) and the Meta Model API
key ($150 of credit) have been issued. This change decides where they may
live before either is used.

| Where | Holds | Never holds |
|---|---|---|
| macOS Keychain (`tabibu-baseten-api-key`, `tabibu-meta-api-key`) | Both keys, for local runs | — |
| Modal secret `tabibu-models` | Both keys, for the AI service | — |
| Firebase Secret Manager | The secret Cloud Functions use to call the AI service | — |
| `ai_service/.env` (ignored) | Non-secret local settings | Any key |
| `ai_service/.env.example` (committed) | Setting names and non-secret values (Baseten base URL, model id) | Any key |
| Remote Config | Non-secret settings: model ids, base URLs, thresholds, kill switches | Any key |
| The Flutter app (`--dart-define`, assets, code) | Nothing secret | Any key |

Changes:

1. **`.gitignore`**: `.env` and `.env.*` (with `.env.example` kept),
   `*.p8`, `*.p12`, `*.pem`, `*.mobileprovision` and `*service-account*.json`.
2. **`ai_service/.env.example`**, with the Baseten base URL and the exact
   hackathon model id, `meta-models/muse-spark-open-1026`; the key works with
   no other model.
3. **Makefile**:
   - `make keys-add` stores each key in the Keychain, prompting without
     echo, so the key never enters shell history.
   - `make keys-check` confirms each key is stored, showing only its length
     and last four characters; `keys-add` runs it at the end. Keys are never
     printed in full, because terminal scrollback and screen recordings
     outlive the session.
   - `make ai-dev CMD="…"` runs a command with both keys in that command's
     environment only.
   - `make secrets` runs gitleaks over the committed history and the staged
     changes, with values redacted in its output.
4. **Docs**: threat-model T-13, architecture §10, a Greptile **Secrets**
   section, and `make secrets` in the definition of done.

## 2. Business justification

The repository is public, and leaked keys pushed to public GitHub are
typically abused within minutes; deleting the commit afterwards does not undo
it. Either key would let anyone spend the hackathon credits, and putting a key
in the app would let a user bypass the AI service entirely, and with it the
record of every AI output and the rule that unsigned drafts reach only the
case's pathologist (S-1).

**Alternatives considered and rejected:**
- **Keys in Remote Config, cached in encrypted Hive.** Firebase's guidance is
  not to store confidential data in Remote Config, because every app instance
  can read it. The fetch uses the public client config already in
  `lib/firebase_options.dart`, App Check is not documented as enforceable on
  Remote Config, obfuscation does not hide values fetched at runtime, and
  on-device encryption does not protect a key from the device's own user.
- **1Password `op run`.** It meets the need (secret references in `.env`, values in memory only)
  but is paid. The macOS Keychain gives the same property at no cost.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- Creating the Modal secret and the Firebase secret: done by hand when the AI
  service and Cloud Functions exist, so the keys never pass through a file or
  a chat.
- Enabling repository secret scanning and installing gitleaks: by hand (§9).
- Scoping the Baseten key to the hackathon model with a workspace key, if the
  issued key is a personal one.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | |
| Roles & case scoping | None | |
| Clinical safety | Protected | Keeping keys server-side keeps every model call inside the AI service, where S-1 and S-6 are enforced |
| AI service | Affected | The service reads its keys from its environment; locally that environment comes from `make ai-dev` |
| Security (rules, App Check, RASP, secrets) | **Affected** | New threat T-13 and its controls |
| Data protection | None | |
| Design system / UI consistency | None | |
| Localisation | None | |
| Existing data | None | |

## 5. Risk & rollback plan

**Risk level:** Low for the change itself; it removes risk.

**If a key leaks:** revoke it at the provider first, issue a new one, update
the Keychain (`make keys-add`) and the Modal secret, then investigate. Do not
rewrite history: the key is already compromised, and `main-protection`
blocks force pushes anyway.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Weighed `.env`, Remote Config with encrypted Hive, 1Password and the
   Keychain against where the keys need to be: only the AI service and Cloud
   Functions call a model.
2. Added the ignore rules and the example file, then confirmed `.env` is
   ignored and `.env.example` is tracked.
3. Added the three Makefile targets and tested `ai-dev` with throwaway
   Keychain items.
4. Updated the threat model, architecture, Greptile rules and workflow.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `git check-ignore` on `ai_service/.env` | Ignored (`.gitignore` `.env` rule) |
| `ai_service/.env.example` | Tracked |
| `make ai-dev` with throwaway Keychain items | Both values reached the command (lengths 17 and 13); never printed; absent from the parent shell; items deleted afterwards |
| `make ai-dev` without `CMD` | Stops with the usage message |
| `make keys-check` | `MISSING` for absent keys; length and last four characters for a stored test item |
| `make secrets` | Stops with the install hint until gitleaks is installed |
| `make spell` | Pass |
| Certification | 2026-10-27 — Theo (tooling and documentation) |

The first `ai-dev` test failed: the usage check was a shell `test` on `CMD`,
which broke on a command containing quotes. The check now runs in Make
itself.

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | N/A — committed directly to `main` | — | — |
| Security Analyst | §4 flags security impact | Covered by CTO | 2026-10-27 | Approved |
| Compliance Officer | — | N/A — no patient data | — | — |
| Clinical Reviewer | — | N/A — protective only | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

| Step | Result |
|---|---|
| 1. `make keys-add` with both keys | Done 2026-10-27: both stored; `make keys-check` shows 45 and 48 characters |
| 2. Repository secret scanning and push protection | Enabled 2026-10-27, confirmed through the API |
| 3. `brew install gitleaks`, then `make secrets` | Pending |
| 4. Modal secret `tabibu-models` with `META_API_KEY` and `BASETEN_API_KEY` | Pending: when the AI service exists |

**Secret-scanning alerts.** The first scan raised two `google_api_key`
alerts, both from commit `3a49df4`: the Android and iOS Firebase client
keys in `google-services.json`, `GoogleService-Info.plist` and
`lib/firebase_options.dart`. Neither is a model key. Both keys already
carried Firebase's API restrictions (24 Firebase APIs, confirmed in the
Google Cloud console), so the alerts were closed as "won't fix" on
2026-10-27. App restrictions were considered and declined; the reasoning is
in the threat model §2. When gitleaks is installed, the same three files
will need an exemption in `.gitleaks.toml`, scoped to those paths only.

**Signing fingerprints.** The upload keystore's SHA-1 and SHA-256 are
registered on the Firebase Android app, and `google-services.json` was
downloaded again; it now carries the Android OAuth client for that
certificate.

## 10. Related records

- Threat model: [T-13](../../security/reports/firebase_and_ai_service_threat_model.md#42-security-threats)
- Architecture: [`mobile_architecture.md` §10](../../architecture/reports/mobile_architecture.md#10-security)
- Previous CRQ: [CRQ-0006](./CRQ-0006-makefile-targets-and-repo-wide-spell-check.md)
