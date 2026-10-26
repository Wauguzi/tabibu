# Tabibu — Outbreak Alert Engine

> Every signed positive result for a notifiable disease is also a data point.
> When one disease's results call for a warning in a county, Tabibu drafts
> the warning, a clinician approves it, and doctors and then patients in that
> area are told within minutes. The engine is driven by the **test**, not by
> one disease: Ebola is why it exists, malaria is the demo data, and any test
> whose disease is notifiable raises alerts the same way.

| Field | Value |
|---|---|
| Owner | Theo — CTO, Mobile Engineer |
| Status | Draft — built on day 8 of the plan (2 November) |
| Last reviewed | 2026-10-27 |
| Collections | `testCatalogue`, `notifiableEvents`, `alertSignals`, `alerts` |
| Related | [`notifications_engine.md`](./notifications_engine.md) (delivery), [`ai_preread_service.md`](./ai_preread_service.md) (drafting) |

## 1. Pipeline

```
Signed positive result ─► 1 Tag ─► 2 Record ─► 3 Detect ─► 4 Draft ─► 5 Approve ─► 6 Deliver
 (pathologist marks         catalogue   anonymous    two rules    Muse Spark   alert        doctors first,
  it notifiable)            says which  event        in code      Open, en+sw  approver     then patients
                            disease
```

## 2. Tag

Each `testCatalogue` entry names `confirmsDisease` and `reportingCategory`:

| Category | Meaning | Detector rule |
|---|---|---|
| `Immediate` | Reported on a single case (e.g. Ebola and other viral hemorrhagic fevers) | Rule A |
| `Weekly` | Reported in aggregate (e.g. malaria) | Rule B |
| `NotNotifiable` | Not reported | None |

The category comes from the Ministry of Health's Integrated Disease
Surveillance and Response (IDSR) list, with WHO's International Health
Regulations list as the global reference. **Provisional:** I have not yet
found the current official Kenyan list, so each entry carries
`categorySource` and `categoryVerified: false` until it is checked. The
approver sees that flag on every draft.

## 3. Record

The `signReport` Cloud Function, when the result is positive for a disease
whose category is not `NotNotifiable`, writes one `notifiableEvents/{uid}`
document in the same batch as the signature:

| Field | Value |
|---|---|
| `disease` | From the catalogue, not free text |
| `county` | The case's county (one of Kenya's 47) |
| `date` | Date only, UTC, no time |
| `epiWeek` | ISO week, for Rule B |
| `ageBand` | `0-4`, `5-14`, `15-24`, `25-44`, `45-64`, `65+` |
| `category` | Copied from the catalogue at signing time |
| `synthetic` | `true` for every demo event |

**No name, phone number, case id, exact location, exact date of birth or
facility leaves the case.** The link from an event back to its case, needed
for an audit, is kept in a separate `notifiableEventLinks` collection that no
client can read.

## 4. Detect

Two rules, in plain code, unit-tested on fixed fixtures:

- **Rule A — Immediate.** One confirmed event raises a signal for that
  disease and county.
- **Rule B — Baseline.** For a weekly disease, a signal is raised when a
  county's count this epi-week is well above its own recent baseline: above
  the mean of the previous 8 weeks plus 2 standard deviations, **and** at
  least a minimum count, so one case in a quiet county does not trip it. The
  window, the multiplier and the floor are provisional, live in a config
  document, and each signal records the values it was raised with.

A signal is a document whose id is the dedupe key,
`alertSignals/{disease}_{county}_{epiWeek}`, so repeated events in the same
week update one signal (its count and evidence) rather than raising many.

## 5. Draft

The AI service writes `alerts/{uid}` with status `Draft`:

- **Doctor guidance**: what to watch for and which precautions to take,
  pointing to the relevant Ministry of Health guidance.
- **Patient notice**: short and plain, telling people what to do and where
  to find official guidance.
- Both in **English and Swahili**.
- The **evidence** the approver needs: disease, county, the rule that
  fired, this week's count against the baseline, and the category's
  verification flag.

Drafts never give their own medical advice; each one links to official
guidance. Wording that diagnoses, reassures or predicts is out of bounds for
the prompt and is checked for in the service before the draft is stored.

## 6. Approve

`approveAlert` is a callable Cloud Function. It requires the
`alertApprover` claim. It stores the approver's edits **beside** the
original draft, never over it, stamps `approvedBy` and `approvedAt`, and
moves the alert to `Approved`. `rejectAlert` records a reason. **Nothing is
delivered without approval**, and the rules make that structural: no
client, approver included, can write `status: 'Delivered'`.

## 7. Deliver

The `deliverAlert` function runs when an alert becomes `Approved` and
`alerts_delivery_enabled` is on:

1. **Doctors first.** Doctors whose practice county is the alert's county or
   a neighboring one (from a static adjacency table of the 47 counties) get
   a push and an inbox row, so they can watch for cases before patients
   arrive asking.
2. **Patients next.** Patients who chose that county in their profile get a
   push notification and an in-app banner. The delay between the phases is a
   config value (zero in the demo).

Delivery uses FCM topics per county and role
(`alerts_doctor_{county}`, `alerts_patient_{county}`). The app subscribes
when a county is chosen and unsubscribes when it changes. Each recipient's
inbox row follows the
[notifications engine](./notifications_engine.md)'s idempotency rules, so
a retried delivery never notifies anyone twice.

## 8. Privacy

- **Patients choose a county; Tabibu never reads their location.**
  `geolocator` is in `pubspec.yaml` for a possible facility-finder feature,
  and it must never be called on the patient's behalf for alerts. A rules
  test and a code-review rule in the threat model guard this.
- Events are anonymous at creation; nothing is "anonymised later".
- Counts shown to patients are never shown below the minimum floor.

## 9. Firestore rules (target)

```
match /notifiableEvents/{id}     { allow read, write: if false; }   // Functions only
match /notifiableEventLinks/{id} { allow read, write: if false; }
match /alertSignals/{id}         { allow read: if isAlertApprover(); allow write: if false; }
match /alerts/{id} {
  allow read: if isAlertApprover()
              || (resource.data.status == 'Delivered' && inAudience(resource.data));
  allow write: if false;                                             // approve/reject are callables
}
```

## 10. Demo

Two cases show both rules, all synthetic:

1. A seeded burst of positive malaria smears in one county crosses its
   baseline (Rule B).
2. A single synthetic Ebola PCR result, signed by the pathologist, raises a
   signal on its own (Rule A). Ebola is confirmed by PCR, not microscopy, so
   this needs no Ebola image dataset.

Each produces a draft in both languages, an approval with an edit, and the
alert arriving on a doctor's phone and then a patient's.

## 11. Open questions

1. Which reporting category does Kenya's current IDSR guideline give each
   catalogue disease, malaria included? (§2)
2. Should a Rule A signal skip the patient phase until a second confirmation,
   to limit alarm from a single result? For now the approver decides per alert.

## 12. Change log

| Date | Change | Author |
|---|---|---|
| 2026-10-27 | Initial version: the six-step pipeline, the event shape and what never leaves a case, Rules A and B, approval and two-phase delivery, the rules shape and the demo. | Theo |
