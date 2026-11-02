# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0048 |
| Title | Firebase feature data sources and the index check |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-02 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: c6dfc8e, c755bde, b41c233, af2b1d8, d05d289 |

## 1. Description of change

The app's only path to Firestore for the new features, and the proof
that every query it runs has an index.

1. **Sources, cases to reports** (c6dfc8e): case reads through
   `participantUids`, a patient's log filtered to `patientVisible`,
   doctor-notes updates in the editable stages only; signed reports
   by reader, a patient's by release, a server-source read for the
   PDF. Share codes never reach a log or an error. Callables map to
   `AppError` by name.
2. **Sources, notifications to alerts** (c755bde): deltas scoped to
   the reader, targeted updates stamping `lastUpdatedAt` (R-4), voice
   notes uploaded before their message and fetched as bytes through
   the SDK, never as download URLs (F-34). The alert topic service
   follows the county and language topics with a demo variant, does
   nothing on the web (F-33, U-20), and retries a failed unsubscribe
   at the next sign-in. `FirebaseMessaging` is injectable.
3. **Indexes and TTL** (b41c233): 41 composite indexes, field
   exemptions for long text, the collection-group indexes the signals
   job reads, and TTL on `expireAt` for notifications, counters,
   order numbers, rate counters, transcriptions and finished
   deliveries.
4. **The check** (F-13): function queries go through one registry,
   tested against the index file, with the identity handlers' queries
   moved onto it unchanged, and every query the domain functions run
   registered beside them (d05d289, with one more field override, on
   `reportDrafts.createdAt`); the app's registry has the same test;
   `make smoke-indexes` runs every registered query against a
   deployed project, since the emulator never enforces indexes.
5. **Docs** (af2b1d8, 72082f5): the architecture lists every
   collection and the registry rows; the review rules pin reads by
   `participantUids` with a role claim and transactions for stage,
   signing, release, redemption and booking.

## 2. Business justification

A missing index fails only in production: the emulator never
enforces them. The registries and the smoke run move that failure
into the build, and the scoped sources keep every read inside the
rules the threat model names.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the callables the sources invoke (built
in this branch, CRQ-0041 to CRQ-0047 and CRQ-0049); the `ttl` fallback
target (U-5, Theo runs it if needed).

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | Reads only; no shape changed |
| Roles & case scoping | **Affected** | Every read scoped to participants, readers or the recipient |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | Affected | Reads stay inside the rules; server-source PDF read |
| Data protection (PHI, de-identification, model endpoints) | Affected | Voice and images as bytes, never URLs; log filter by visibility |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | None | — |
| Existing data | None | No data changed |

## 5. Risk & rollback plan

**Risk level:** Low: new reads and indexes; no writer changed.

**Rollback plan:** revert the commits; indexes already deployed stay
harmless. Deploy order stays indexes (`READY`) → smoke → functions
→ backfill → rules → app (§8 5e).

## 6. Implementation plan

1. Sources per domain, each with its registry entries.
2. Indexes from the registry, then the registry-against-index test
   on both sides.
3. `make smoke-indexes` against the dev project before the rules
   deploy.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01 |
| `make functions-test` | Pass — 518 emulator tests across the functions suite (d05d289), including the registry-against-index test over the domain functions' queries |
| Index proof | Pass — registry tests on both sides; `make smoke-indexes` on the dev project |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | The web build test of `AlertTopicService` (U-20); device run pending — Theo |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-11-02 | Approved — [PR #8](https://github.com/Wauguzi/tabibu/pull/8), 5/5 at round 3 |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | Reads inside the rules |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Bytes not URLs; visibility filters |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **U-17**: FCM topic limits for 47 × 2 topics still need the dev
  send test; topics already carry ids only, never names.
- **U-5** (TTL deploy) stays open as in CRQ-0046 §9.
- **Smoke run**: the dev-project run predates the queries the domain
  functions added (d05d289). Run `make smoke-indexes` again, with the
  indexes `READY`, before the functions deploy.
- **What Greptile found** ([PR #8](https://github.com/Wauguzi/tabibu/pull/8)):
  - Round 1: every data-source call was checked against its rule block
    (the client and rules matrix); the alert deltas filter out synthetic
    rows so the lists are provable; four composite indexes were added on
    both sides (7c3e416).
  - Round 2: eviction-driving reads ask the server (`Source.server`),
    across 23 reads in seven data sources (a828a9f). The client and
    rules matrix predates this change.

## 10. Related records

- Cache helpers: [CRQ-0040](./CRQ-0040-encrypted-cache-boxes-and-helpers.md)
- Rules: [CRQ-0043](./CRQ-0043-signed-reports-release-and-pdf.md),
  [CRQ-0045](./CRQ-0045-conversations-mdt-and-voice-notes.md)
- Outbreak alerts: [CRQ-0049](./CRQ-0049-outbreak-alerts.md)
