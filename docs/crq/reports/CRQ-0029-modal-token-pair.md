# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0029 |
| Title | Keep the Modal token pair in the Keychain and run the Modal CLI through make |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-28 |
| Date implemented | 2026-10-28 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Modal granted Tabibu $100 of credit, for serving open-weight models on
Modal Endpoints, serverless GPUs, sandboxes and training, valid for the
hackathon. Modal hosts the AI service (architecture §3).

Modal authenticates with a token pair, an ID (`ak-…`) and a secret
(`as-…`), created in the dashboard under Settings → API Tokens. By default
`modal token new` writes both in plain text to `~/.modal.toml`. Instead,
they follow CRQ-0007's rule for every credential:

1. **Makefile:**
   - `make modal-token-add` stores the pair in the Keychain
     (`tabibu-modal-token-id`, `tabibu-modal-token-secret`), prompting
     without echo, then runs `keys-check`.
   - `make modal ARGS="…"` runs the Modal CLI with `MODAL_TOKEN_ID` and
     `MODAL_TOKEN_SECRET` in its environment only. The client reads these
     variables in place of the config file
     ([docs](https://modal.com/docs/reference/modal.config)).
   - `make keys-check` lists both, as length and last four characters only.
   - `make modal ARGS="token info"` confirms the workspace without
     printing the secret.
2. **`mobile_workflow.md` §5** records the credit on the Modal row.

The redemption link in Modal's email is personal and limited to approved
participants. It is never recorded in the repository.

## 2. Business justification

The AI service needs somewhere to run, and the credit covers it for the
length of the hackathon.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**

- installing the Modal CLI (`pip install modal`);
- creating the Modal secret `tabibu-models`, which holds the model keys for
  the AI service (CRQ-0007 §9 step 4) and is created with the service.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Local tooling | Affected | Two new targets; `keys-check` lists two more items |
| Security (rules, App Check, RASP, secrets) | Affected | A deploy credential, under the same rules (T-13) |
| The app | None | It never holds a credential |

## 5. Risk & rollback plan

- **`~/.modal.toml` left on disk** from an earlier `modal token new` holds
  the pair in plain text. Delete it once the Keychain holds the pair.
- **A leaked token:** revoke it in the Modal dashboard, create another, and
  store it with `make modal-token-add`. Never pass a token on the command
  line (`modal token set --token-secret …`): it reaches shell history and
  `~/.modal.toml`.

**Rollback plan:** revert the commit, then delete both Keychain items with
`security delete-generic-password -a "$USER" -s <name>`.

## 6. Implementation plan

Added the Keychain names and the two targets; dry-ran `modal-token-add`;
confirmed `keys-check` reports the pair missing before it is stored.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make -n modal-token-add` | Prompts for the ID, then the secret |
| `make keys-check` before storing | Both `MISSING`; the other keys unchanged |
| `make spell` | Pass |
| Certification | 2026-10-28 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-28 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | A new credential | Covered by CTO | 2026-10-28 | Approved — same rules as CRQ-0007 |

## 9. Post-implementation review

| Step | Result |
|---|---|
| 1. Redeem the credit (personal form in Modal's email) | Done 2026-10-28 by Theo |
| 2. Create a token in the Modal dashboard | Done 2026-10-28. The first token was pasted into a chat, so it was revoked and replaced before use |
| 3. `make modal-token-add`, then `make keys-check` | Done 2026-10-28: both stored (25 characters each) |
| 4. Install the CLI (`uv tool install modal`, 1.6.3), then `make modal ARGS="token info"` | Done 2026-10-28: workspace `theophilousworship`, the replacement token; `app list` empty. `profile current` prints `default` with no config file, so it proves nothing |
| 5. No `~/.modal.toml` on disk | Confirmed 2026-10-28 |

## 10. Related records

- Previous CRQ: [CRQ-0028](./CRQ-0028-fireworks-api-key.md)
- Secrets handling: [CRQ-0007](./CRQ-0007-secrets-handling-for-model-api-keys.md)
