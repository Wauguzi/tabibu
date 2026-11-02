# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0040 |
| Title | Encrypted cache boxes and feature cache helpers |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-30 |
| Date implemented | 2026-11-01 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/infra`: 54136b0, 035ee9e, 2babeb3, af2b1d8 |

## 1. Description of change

Twenty-one encrypted Hive boxes for every new record, and the scoped
cache helpers the blocs will call, with the offline replay mapping.

1. **Boxes** (54136b0): twenty boxes opened at start with a debug
   timing log, and messages as a `LazyBox` opened on first use and
   pruned per conversation (F-26.7), never before `runApp`. Sign-out
   deletes all twenty-one, opened or not, with the cached voice and
   image files (T-11). The lazy messages box sits on the `HiveHelper`
   interface.
2. **Appointments, conversations, notifications, alerts** (035ee9e):
   remote first with the cache as fallback; a cloud row never
   overwrites an unsynced one (Catalogue 25: "could not read" stays
   apart from "none"); reads scoped to the signed-in person; queued
   writes replay as targeted updates, a denial dropping the change and
   refetching (F-16). A patient never caches an intake or a clinician's
   machine transcript; messages are paged and pruned; cursors move
   forward only; local-only notifications are never sent; public alerts
   scope by county and demo flag, and the approver queue is never
   cached (F-39).
3. **Cases, reports, the desk** (2babeb3): a patient's device caches a
   report only once released, checked at write time whatever the source
   returned (S-3), and only patient-visible log entries; payment, risk
   checks and notes translations only for the roles that read them. A
   share code's secret never reaches a box. Leaving a case evicts it
   and its children, and its desk entry (F-14). Sign stays off while a
   draft edit is queued (F-2). The desk ranks by base priority plus
   waiting time capped at 72 hours.

## 2. Business justification

Doctors and patients work where the network drops. The cache carries
the visit, and the replay mapping decides, per error, whether a queued
write still stands — without ever showing one person's records to
another or caching what their role may not read.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the blocs that call the helpers (the next
branch). The domain callables the replays target are built in this
branch (CRQ-0041 to CRQ-0047, CRQ-0049); no screen calls them yet.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | **Affected** | 21 boxes join the encrypted set and sign-out wipe |
| Roles & case scoping | **Affected** | Patients cache released reports and shared transcripts only; intake, machine transcripts and the approver queue are role-gated at write time |
| Clinical safety | None | No AI output, result or alert path changed |
| AI service (prompts, models, thresholds) | None | — |
| Security (rules, App Check, RASP, secrets) | None | Encryption reuses the existing key; no new secret |
| Data protection (PHI, de-identification, model endpoints) | **Affected** | Records encrypted at rest and wiped at sign-out, with the media cache (T-11) |
| Design system / UI consistency | None | — |
| Localisation (en, sw) | None | No user-visible strings |
| Existing data | None | New boxes only; old rows untouched |

## 5. Risk & rollback plan

**Risk level:** Low: new boxes and helpers; the old cache paths are
unchanged.

**Rollback plan:** revert the commits. A box created by this branch and
left behind holds encrypted rows no old build opens; sign-out deletes
them.

## 6. Implementation plan

1. Boxes first, with sign-out deletion proven opened and unopened.
2. The four helpers, then cases, reports and the desk, each with its
   merge, scope, replay and domain-rule tests, clock tests under
   `TZ=UTC` (F-26.6).
3. The lazy box moved onto the `HiveHelper` interface so the
   conversation helper opens it without the concrete class.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make fmt` / `make analyze` / `make bloc-lint` | Pass — each bundle's scoped gates before its report; full-tree run with the PR |
| `make test` | Pass — 1,364 app tests, the whole suite, observed 2026-11-01, including the four helpers (99) |
| Replay mapping | Pass — drop-and-refetch, evict on a denied refetch, stay queued; patient-box and transcript gates covered |
| Secrets | No secret committed; `gitleaks` pending with the PR |
| Manual run (device / simulator / web) | N/A — no UI; bloc behaviour follows in the next branch |
| Certification | Pending — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-01 | — |
| Engineering reviewer | Always, on the pull request | Greptile | 2026-11-02 | Approved — [PR #8](https://github.com/Wauguzi/tabibu/pull/8), 5/5 at round 3 |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | N/A | — | No clinical path |
| Security Analyst | §4 flags security impact | N/A | — | No security impact |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Records encrypted and wiped; role gates at write time |
| Lead Designer | §4 flags design-system impact | N/A | — | No UI change |

## 9. Post-implementation review

- **`failed-precondition` stays queued** (F-16, §13.x):
  `AppError.fromFirebaseCode` folds it into `unknown`, which also
  covers transient faults, so the helpers keep such a replay queued
  rather than drop a user's write. In the blocs branch, callable
  domain refusals get their own `AppError`s and drop on those.
- **Voice replay vs write-once uploads**: a refused voice send whose
  upload already landed keeps its `Failed` row visible rather than
  vanish; the recording file survives until sign-out.
- **What Greptile found** ([PR #8](https://github.com/Wauguzi/tabibu/pull/8)):
  - Round 1: a removed viewer's cached cases, reports, conversations
    and messages stayed on the device. A successful sync now evicts the
    rows the server no longer returns, and a failed read never evicts
    (7c3e416).
  - Round 2: that eviction trusted Firestore's offline answer, which
    comes from its partial local cache, so an offline refresh could
    delete downloads. Every read that drives an eviction or a
    replacement now asks the server (`Source.server`); offline it
    throws, and the helper keeps its rows (a828a9f).

## 10. Related records

- Models: [CRQ-0039](./CRQ-0039-data-layer-models-and-reference-data.md)
- Data sources: [CRQ-0048](./CRQ-0048-feature-data-sources-and-indexes.md)
- Sign-out wipe: [CRQ-0036](./CRQ-0036-pre-review-hardening.md) (T-11)
