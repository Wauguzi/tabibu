# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0015 |
| Title | Nairobi facility data: the Ministry of Health's 1,447 facilities, 17 sub-counties and 47 counties as app assets, with a geohash service |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-27 |
| Date implemented | 2026-10-27 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

1. **`GeohashService`** (`lib/core/services/`): nine-character geohashes,
   checked against published vectors from independent implementations.
2. **`scripts/facilities/`**: a sanitiser and a runner, invoked by
   `make facilities FACILITIES=<export> COUNTIES=<export>`. It reads the
   Ministry's API responses as exported (RTF or text, several responses per
   file), and writes the three assets in
   [architecture §6.2](../../architecture/reports/mobile_architecture.md#62-reference-data-shipped-with-the-app).
   The rules it applies, and why, are listed there.
3. **`assets/data/`**, registered in `pubspec.yaml`:
   `facilities_nairobi.json` (1,447), `sub_counties_nairobi.json` (17),
   `counties.json` (47). One record per line, about 690 KB in all.
4. **Architecture §1** states the reach, linked to its sources; §6.2 is
   rewritten for the generated files.

**What the export contained** (Theo exported it on 2026-10-27 from the
Ministry's facility list):

| Finding | Count | Handling |
|---|---|---|
| Facilities, all in Nairobi | 1,447 | All shipped |
| Operational (`active` and `Operational`) | 1,241 | `isOperational: true` |
| Closed or non-operational | 206 | Kept, greyed out, refused at sign-up |
| No coordinates (`0, 0`) | 223 (168 operational) | Sub-county centre, `isLocationApproximate: true` |
| No MFL code (`"None"`) | 10 | `mflCode: ''`; keyed by the Ministry's `id` |
| Sub-counties | 17 | All of Nairobi's |
| Wards | 85 | Kept on each facility |
| Flagged `is_lab` | 5 | National reference labs only, so not used to filter pathologists |

## 2. Business justification

A practitioner's location, the directory's nearest-first order, and the
patient's sub-county all come from this data, so sign-up cannot be built
without it. It also states Tabibu's reach in numbers a judge can check: all
of Nairobi's 1,447 listed facilities from the first day, against a national
list of 14,366 targeted in the
[2023 census](https://www.health.go.ke/sites/default/files/2024-01/Kenya%20Health%20Facility%20Census%20Report%20September%202023.pdf#page=20).

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:** the facility picker, the Freezed facility model
and the `functions/` copy (they arrive with sign-up); counties other than
Nairobi.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | None | Bundled assets, not Firestore; no Hive box |
| Roles & case scoping | None | |
| Clinical safety | None | |
| AI service | None | |
| Security (rules, App Check, RASP, secrets) | None | Public data; no credential |
| Data protection | None | Facilities, not people; the export holds no phone or email |
| Design system / UI consistency | None | |
| Localisation | None | Facility names are proper nouns |
| Existing data | None | |

## 5. Risk & rollback plan

- **Approximate locations.** 168 operational facilities sit at their
  sub-county's centre. That only affects ordering in the directory, and
  the flag lets the UI say "approximate".
- **Bundle size.** About 690 KB of JSON, compressed in transit on the web.
  If it matters, the next step is dropping fields the picker does not show.
- **Staleness.** The list is a snapshot. A rerun of `make facilities`
  replaces it; rows are keyed by the Ministry's id, so a rerun updates
  rather than duplicates.

**Rollback plan:** revert the commit.

## 6. Implementation plan

1. Profiled the export: shapes, nulls, duplicates, coordinate bounds,
   status agreement.
2. Wrote the geohash encoder and checked it against the standard geohash test
   vectors; wrote the sanitiser test-first
   on synthetic rows.
3. Generated the assets and cross-checked all 1,464 hashes against an
   independent Python encoder.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `flutter test test/core/services test/scripts` | 24 passed |
| `dart analyze --fatal-infos` on the new files | No issues |
| Independent geohash check (1,447 facilities, 17 centres) | 0 mismatches |
| `make facilities` with a missing file | Stops with usage |
| `make spell` | Pass |
| Certification | 2026-10-27 — Theo |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-27 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |
| Security Analyst | — | N/A | — | — |
| Clinical Reviewer | — | N/A | — | — |
| Compliance Officer | — | N/A | — | — |
| Lead Designer | — | N/A | — | — |

## 9. Post-implementation review

- Recount after the next export; the figures in architecture §1 quote this
  one.

## 10. Related records

- Previous CRQ: [CRQ-0014](./CRQ-0014-identity-data-model.md)
- [Kenya Health Facility Census, September 2023](https://www.health.go.ke/sites/default/files/2024-01/Kenya%20Health%20Facility%20Census%20Report%20September%202023.pdf)
- [Kenya Master Health Facility List implementation guide](https://api.kmhfr.health.go.ke/media/KMHFL_Implementation_Guide_Jan_2020.pdf)
