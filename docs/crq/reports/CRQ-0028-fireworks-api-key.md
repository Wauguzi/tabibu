# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0028 |
| Title | Store the Fireworks API key the same way as the other model keys; replace one key at a time |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-28 |
| Date implemented | 2026-10-28 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

Fireworks granted Tabibu $100 of inference credit. The key follows the rules
CRQ-0007 set for the Baseten and Meta keys: it lives in the macOS Keychain
for local runs and in the Modal secret for the AI service, and never in the
repository, the app or Remote Config.

1. **Makefile:**
   - `KEYCHAIN_FIREWORKS := tabibu-fireworks-api-key`.
   - `make keys-add` prompts for it after the Meta key.
   - **`make key-add KEY=baseten|meta|fireworks`** stores or replaces one
     key, so adding a key no longer means pasting every other key again.
     Any other value is refused with the usage line.
   - `make keys-check` lists it, as length and last four characters only.
   - `make ai-dev` passes it as `FIREWORKS_API_KEY`, to that command only.
2. **`ai_service/.env.example`** gains `FIREWORKS_BASE_URL`, Fireworks'
   OpenAI-compatible endpoint
   ([docs](https://docs.fireworks.ai/tools-sdks/openai-compatibility)). No
   model id is set until the AI service chooses one.
3. **`mobile_workflow.md` §5** lists Fireworks among the external systems.

## 2. Business justification

$100 of inference credit adds headroom beyond the Baseten and Meta credits
for the AI service, without changing where any key may live.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**

- which model the AI service runs on Fireworks;
- adding the key to the Modal secret `tabibu-models`, done with the other
  two when the AI service exists (CRQ-0007 §9 step 4).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Local tooling | Affected | Three Makefile targets and one new target |
| Security (rules, App Check, RASP, secrets) | Affected | One more secret, under the same rules (T-13) |
| The app | None | It never holds a model key |

## 5. Risk & rollback plan

- **A key pasted into the terminal by mistake** ends up in shell history.
  The prompt reads without echo, so paste only at the prompt.
- **A leaked key:** revoke it in the Fireworks dashboard, store the new one
  with `make key-add KEY=fireworks`, and update the Modal secret.

**Rollback plan:** revert the commit, then delete the Keychain item with
`security delete-generic-password -a "$USER" -s tabibu-fireworks-api-key`.

## 6. Implementation plan

Added the Keychain name and the targets; dry-ran `make key-add`, checked that
a wrong `KEY` is refused, and checked that `make keys-check` reports the key
missing before it is stored.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make -n key-add KEY=fireworks` | Prompts for `tabibu-fireworks-api-key` only |
| `make key-add KEY=x` | Refused with the usage line |
| `make keys-check` before storing | `tabibu-fireworks-api-key MISSING`; the others unchanged |
| `make spell` | Pass |
| Certification | 2026-10-28 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-28 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | A new secret | Covered by CTO | 2026-10-28 | Approved — same rules as CRQ-0007 |

## 9. Post-implementation review

| Step | Result |
|---|---|
| 1. `make key-add KEY=fireworks` | Done 2026-10-28 by Theo |
| 2. `make keys-check` shows it stored | Done 2026-10-28: 24 characters; the other three keys unchanged |
| 3. Fireworks key in the Modal secret `tabibu-models` | Pending: when the AI service exists |

## 10. Related records

- Previous CRQ: [CRQ-0027](./CRQ-0027-auth-bloc-and-router.md)
- Secrets handling: [CRQ-0007](./CRQ-0007-secrets-handling-for-model-api-keys.md)
