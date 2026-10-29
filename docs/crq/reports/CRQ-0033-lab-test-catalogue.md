<!-- cspell:ignore aspi -->
# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0033 |
| Title | Lab test catalogue: the Ministry of Health's 11 test types and 247 lab tests as app assets, each with a price in Kenya shillings |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-10-29 |
| Date implemented | 2026-10-29 |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/auth` |

## 1. Description of change

1. **`scripts/lab_tests/`**: a sanitiser, a price table and a runner,
   invoked by `make lab-tests TESTS=<export>`. It reads the Ministry's
   test-type list as exported (RTF or text), and writes two assets,
   described in
   [architecture §6.2](../../architecture/reports/mobile_architecture.md#62-reference-data-shipped-with-the-app).
2. **`assets/data/lab_test_types.json`** (11 types, the ordering menu) and
   **`assets/data/lab_tests.json`** (247 tests). Each test carries its type's
   id and name, so the order screen filters one flat list by type without a
   join.
3. **`testPriceKes`** on every test, a whole number of shillings, and
   **`isPriceEstimate: true`**, because no price is a lab's own tariff (§1.2).
4. **Turnaround times** on every test, as the export gives them:
   `tatCollectionToDelivery`, `tatDeliveryToResults` and
   `totalTurnaroundTime`. Each must be a whole, non-negative number, and the
   two stages must add up to the total, or the run stops.
5. **`functions/data/`** holds byte-identical copies, checked by
   `reference-data.test.ts`, so an order's total can later be computed on the
   server from its own list rather than taken from the app. `make facilities`
   now copies only its own three files.

**What the export contained** (Theo exported it on 2026-10-28):

| Finding | Count | Handling |
|---|---|---|
| Test types | 12 | 11 shipped; "Category 10" has no tests and is dropped |
| Lab tests | 251 | 247 shipped |
| Data-entry rows (`test`, `Test run`, `Migraine`; descriptions "testing…") | 3 | Dropped, by name |
| A repeat (`Covid 19 Rapid Test`, the same test as `SARS-CoV-2 antigen test`) | 1 | Dropped, by name |
| Names broken across lines in the source (`aspi- rate`, `ge-↵nome`) | about 90 | Mended by rule: a break inside a word joins; `Beta- 2` keeps its hyphen; `IgM/ IgG` closes up |
| Names the rule cannot mend (a lost bracket, `Transferring`, `HBsA-g`, `EBOLA`) | 13 | Corrected by a listed table |
| `external_sys_id` | null in every row | Dropped |
| `description` | equal to the name in every kept row | Dropped; a row whose description says more stops the run |
| Turnaround times (`tat_*`) | every row; the two stages always add up to the total | Shipped as given, in the export's unit (§5) |
| Malaria | 4 tests | Blood smear, rapid tests, NAATs, genome sequencing |
| Ebola | 1 test | `NAATs for Ebola` (Virology) |

Every listed drop, correction and price must match a row, or the run stops:
a list that has gone stale is caught the next time the export changes.

### 1.2 Where the prices come from

Laboratory prices in Kenya are not regulated, and most labs do not publish
them; a 2019 survey of Nairobi laboratories found private in-facility labs
charging on average 468% of public prices
([Global Health Action, 2021](https://doi.org/10.1080/16549716.2021.1964172)).
So there is no single list to copy. The prices are a demo benchmark for a
Nairobi private laboratory, built in three tiers:

| Tier | Tests | Source |
|---|---|---|
| A published private price for the same test | 76 | [Nutri Health Solutions, Nairobi: laboratory service prices](https://gonutrihealth.org/transparent-affordable-laboratory-service-prices/) (© 2026), e.g. CBC 1,500, HbA1c 1,800, HIV viral load 8,000, GeneXpert 7,000, Pap smear 2,500 |
| Malaria, from a public and a private list | 2 | Blood smear 600: [Kenyatta National Hospital service charter, 2023](https://knh.or.ke/wp-content/uploads/2023/08/SDC-2023-English1.pdf) (private rate; general rate 400). Rapid test 900: [Labtest Zote](https://www.labtestzote.com/infectious-diseases/travel-medical-testing-in-kenya/) (KSh 890, rounded) |
| Scaled from the anchors by method | 169 | A rapid test 500–1,500; an ELISA 2,500–8,000; culture with sensitivity 2,000–3,500; a NAAT 6,000–15,000 (haemorrhagic fevers, Ebola included, at 15,000); histopathology 4,000–8,000; immunohistochemistry panels 20,000; sequencing and genetic tests 25,000–60,000 |

The KNH charter was used as the check on the low end: a full haemogram there
is 800 (general) or 1,400 (private), urea-electrolytes-creatinine 900 or
1,400, and liver function 700 or 1,800.

## 2. Business justification

A doctor's order is built from this list, and its total is the sum of these
prices. Payment (cash, or an insurer and member number) follows with the
ordering workflow. Malaria and Ebola, the two diseases the demo is built
around, are both in the Ministry's list as ordinary orderable tests.

## 3. Scope

**In scope:** everything in §1.

**Explicitly out of scope:**
- the Freezed models, the helper that reads the assets, the order screen and
  payment, which come with the doctor's ordering workflow;
- `confirmsDisease` and `reportingCategory`, which the outbreak engine reads
  ([outbreak_alert_engine.md §2](../../architecture/reports/outbreak_alert_engine.md#2-tag)).
  They are clinical facts, added with that work and verified, not guessed
  from a test's name.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| App bundle | Affected | About 60 KB of JSON |
| Cloud Functions | Affected | Two more data files, checked byte for byte; no code reads them yet |
| App code | None | Nothing reads the assets yet |
| Clinical safety | None today | A price and a name only; no result, report or alert |

## 5. Risk & rollback plan

- **The prices are estimates.** Every test says so (`isPriceEstimate`), so
  the order screen can say so too. A lab's own tariff would replace a price
  and clear the flag.
- **The turnaround unit is not stated in the export.** The fields keep the
  export's names, without a unit, until it is confirmed; the screen that shows
  them converts once, in one place. Some values read oddly for their method
  (a rapid malaria test 612, genome sequencing 841), so they are shown to a
  patient as an expected time, not a promise, and a lab's measured times
  replace them.
- **The ids are the export's.** They are stable across re-exports of the same
  list, and an order will store the test's id with its name and price as
  ordered, so a later rename or price change does not rewrite past orders.

**Rollback plan:** delete the two assets and their copies; nothing reads
them yet.

## 6. Implementation plan

1. Read the export: count types and tests, list nulls, repeats, data-entry
   rows and broken names.
2. The sanitiser and its tests, following `scripts/facilities/`.
3. Prices: published figures first, then the scaled benchmark.
4. Generate, copy to `functions/data/`, and extend the byte-identical check.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `lab_test_sanitizer_test.dart` | Name mending; the type carried on each test; empty types, data-entry rows and repeats dropped; turnaround times carried, and a missing, negative or non-adding one stops the run; no price, a stale list entry, a description that says more, a repeated id, a misfiled test or a repeated name each stop the run |
| `make lab-tests` | 251 read; 11 types; 247 tests; 3 data-entry rows, 1 repeat and 1 empty type dropped; 13 names corrected |
| `make functions-test` | 40 passing; the five data files are byte-identical |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-10-29 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | — |

## 9. Post-implementation review

- When the ordering workflow lands: the order screen shows the estimate
  label, and the server computes the total from `functions/data/`.

## 10. Related records

- Previous CRQ: [CRQ-0032](./CRQ-0032-email-verification.md)
- The facility data this follows: [CRQ-0015](./CRQ-0015-nairobi-facility-data.md)
