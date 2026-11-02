# Tabibu — Outbreak Alert Engine

> Every signed positive result for a notifiable disease is also a data point.
> When one disease's results call for a warning in a county, Tabibu drafts
> the warning, an authorised public-health officer approves it, and doctors
> and then patients in that area are told within minutes. The engine is
> driven by the **test**, not by one disease: any test that confirms a
> notifiable disease feeds it the same way, and malaria is the demo data.

| Field | Value |
|---|---|
| Owner | Theo — CTO, Mobile Engineer |
| Status | Built on `feat/infra` (CRQ-0049); blocs and screens pending |
| Last reviewed | 2026-11-01 |
| Collections | `notifiableEvents`, `notifiableEventLinks`, `epiCounts`, `alertSignals`, `alerts`, `publicAlerts`, `alertDeliveries`, `alertApprovers`, `demoAccounts` |
| Bundled data | `notifiable_diseases.json`, `public_health_guidance.json` (§2) |
| Related | [`notifications_engine.md`](./notifications_engine.md) (delivery), [`ai_preread_service.md`](./ai_preread_service.md) (drafting) |

## 1. Pipeline

```
Signed positive result ─► 1 Tag ─► 2 Record ─► 3 Detect ─► 4 Draft ─► 5 Approve ─► 6 Deliver
 (the pathologist marks    the bundle  anonymous    Rules A, B   Muse Spark   authorised     clinicians first,
  a confirmed finding)     says which  event        and M,       Open, en+sw, public-health  then patients by
                           disease                  in code      placeholders officer        county topic
```

**An in-app alert never replaces the facility's statutory notification.** A
suspected or confirmed case is still reported to the medical officer of
health by the facility and the lab: immediately for an immediately
reportable disease (form MOH 502, within 24 hours) and weekly on MOH 505
([IDSR Clinician's Handbook](http://web.archive.org/web/20260523034420/https://www.nphi.go.ke/sites/default/files/2024-02/IDSR%20Clinicians%20Handbook.pdf)).
The clinician brief and the pathologist's mark both say so.

## 2. Tag

The bundled `notifiable_diseases.json` (in `assets/data` and, byte-identical,
`functions/data`) lists **38 diseases**. Each entry has:

| Field | Meaning |
|---|---|
| `diseaseId`, `nameEn`, `nameSw` | A stable slug and the names. The Kiswahili names are ours |
| `ihrStatus` | IHR Annex 2 as in force since 19 September 2025: `AlwaysNotifiable` (smallpox, poliomyelitis due to polioviruses, influenza from a new subtype, SARS), `AlwaysAssessed` (cholera, pneumonic plague, yellow fever, the viral haemorrhagic fevers, West Nile fever, and diseases of special national or regional concern), `EventAssessed` (the rest), or `None` |
| `reportingCategory` | `Immediate`, `Weekly`, `Monthly`, or `NotListed` (not on Kenya's IDSR lists; no event is recorded) |
| `kenyaGroup` | Epidemic-prone, elimination, public-health importance, or not listed (the 2021 IDSR list) |
| `categorySourceId`, `categoryVerified` | Where the category came from, and whether it is verified (§2.1) |
| `caseDefinitionEn`, `caseDefinitionSw` | The standard case definition, summarised |
| `labTests` | Each catalogue test with its `strength` (`Confirms`, `Presumptive`, `Supportive`, `Uncertain`) and `mappingVerified`. Built by matching test names against `lab_tests.json`, with a test that each name resolves to exactly one entry |
| `publicAlertEligible` | Whether a public alert may be raised at all |
| `allowManualAlert` | Whether Rule M applies (`false` for malaria) |
| `preReadHint` | A code rule that may *suggest* a positive to the pathologist; nothing is pre-ticked |

What the fields decide:

- **A finding** needs a `Confirms` test for the disease on the case.
- **A presumptive-only case** cannot raise an alert. The pathologist
  recommends a confirmatory test instead, and the ordering doctor is notified.
- **An event** is recorded for `Immediate`, `Weekly` and `Monthly` diseases.
- **The detector** runs only for a `publicAlertEligible` disease.

**Public alerts cover epidemic-prone diseases only**: Ebola, Marburg, Lassa,
CCHF, Rift Valley fever, yellow fever, dengue, chikungunya, cholera, plague,
anthrax, typhoid, Shigella dysentery, meningococcal meningitis, measles,
polio, influenza from a new subtype, SARS and COVID-19, mpox and smallpox,
plus malaria by Rule B only (an epidemic, not single cases). HIV, STIs,
hepatitis, TB (drug-resistant TB included) and leprosy are **counted but
never alerted**, for privacy and stigma. Plague, new-subtype influenza and
smallpox are eligible, but the catalogue has no test that confirms them, so a
report cannot raise them.

### 2.1 Sources, and what is unverified

| Source | Used for |
|---|---|
| [IDSR Clinician's Handbook for Priority Diseases](http://web.archive.org/web/20260523034420/https://www.nphi.go.ke/sites/default/files/2024-02/IDSR%20Clinicians%20Handbook.pdf), MoH (2nd-edition era; archived copy) | Reporting categories, case definitions, forms MOH 502 and 505 |
| [IDSR Technical Guidelines for Kenya, 3rd edition](https://nphi.go.ke/sites/default/files/2024-02/IDSR%20Technical%20Guidelines%20for%20Kenya%2011.05.2022_9am.pdf), MoH and KNPHI | The current categories. **Not yet read**: the host serves an expired certificate |
| [Geteri et al., *BMC Research Notes* 17:309 (2024), Table 1](https://pmc.ncbi.nlm.nih.gov/articles/PMC11481684/) | Kenya's 2021 IDSR priority list and its groups |
| [Public Health Act, Cap. 242, s.17](https://www.sheriaplex.com/kenya-acts/5487-section-17-application-of-part) and [s.18](https://www.sheriaplex.com/kenya-acts/5488-section-18-notification-of-infectious-diseases) ([official text](https://new.kenyalaw.org/akn/ke/act/1921/38)) | The legal list, and notification to the medical officer of health |
| [IHR (2005), consolidated text](https://apps.who.int/gb/bd/pdf_files/IHR_2014-2022-2024-en.pdf), [WHA77.17](https://apps.who.int/gb/ebwha/pdf_files/WHA77/A77_R17-en.pdf), and the [UK IHR focal point protocol](https://www.gov.uk/government/publications/international-health-regulations-2005-uk-national-focal-point-communications-protocol/international-health-regulations-2005-uk-national-focal-point-communications-protocol) (Annex 2's right box) | `ihrStatus` |
| [WHO R&D Blueprint priority diseases](https://www.who.int/activities/prioritizing-diseases-for-research-and-development-in-emergency-contexts) | The global reference |

**Every category ships with `categoryVerified: false`** until the 3rd
edition's Table 1 is read, and the approver sees an "unverified category"
line on every draft. The categories for chikungunya, mpox, human African
trypanosomiasis, lymphatic filariasis and onchocerciasis are **inferred**,
not taken from a Kenyan list. A test mapping marked `mappingVerified: false`
(a cross-reacting antibody test, say) is shown to the approver the same way.

### 2.2 Guidance

`public_health_guidance.json` holds patient and clinician bullets for the 20
eligible diseases that have guidance (smallpox has none). Each bullet links
its source, and each source carries its title, publisher, https URL and dates.
Patient bullets paraphrase Ministry of Health and WHO guidance, for example:

- MoH Kenya: the [advisory on the Ebola outbreak in the DRC's Ituri Province, 18 May 2026](https://health.go.ke/sites/default/files/2026-05/PRESS%20RELEASE_EVD_DRC_Final.pdf),
  the [advisory on health risks in heavy rains](https://health.go.ke/sites/default/files/2023-11/PRESS%20RELEASE-%20ADVISORY%20ON%20HEALTH%20RISKS%20AMID%20ONGOING%20HEAVY%20RAINS%20.pdf),
  the [mpox key messages](https://health.go.ke/sites/default/files/MPOX%20SOCIAL%20MEDIA%20POSTS%202024%20FINAL.pdf)
  and the [mpox and Marburg preparedness update](https://www.health.go.ke/sites/default/files/2024-11/MPOX%20RESPONSE%20AND%20ENHANCED%20MARBURG%20VIRUS%20DISEASE%20PREPAREDNESS-31.10.2024.pdf);
- the WHO fact sheets, such as [cholera](https://www.who.int/news-room/fact-sheets/detail/cholera),
  [malaria](https://www.who.int/news-room/fact-sheets/detail/malaria) and
  [dengue](https://www.who.int/news-room/fact-sheets/detail/dengue-and-severe-dengue).

Clinician bullets are the case definition plus the statutory reminder: "Report
a suspected or confirmed case to the medical officer of health: immediately
for this disease, on form MOH 502", or weekly on MOH 505.

- **A bullet whose source is a scanned MoH release read by OCR** stays out of
  the shipped asset until it is checked against the PDF.
- **No official Kiswahili guidance exists.** Every Kiswahili bullet and name
  is our translation, and the app labels it "Kiswahili translation by Tabibu"
  ("Tafsiri ya Kiswahili na Tabibu"). A fluency review follows; it is not a
  gate.

## 3. Record

The pathologist marks a **notifiable finding** on the draft: a positive
confirmed by this report, for a disease with a `Confirms` test on the case,
at most five per report. For an eligible disease they may also tick "Raise an
alert" (`alertRequested`), which feeds Rule M. The pre-read may suggest a
finding, but nothing is pre-ticked; the pathologist decides.

`signReport` writes one `notifiableEvents/{uid}` document per new finding,
**in the signing transaction**, from the signed version only:

| Field | Value |
|---|---|
| `uid` | The event id |
| `diseaseId` | From the bundle, not free text |
| `countyId` | The patient's residence county from their record, never client input; signing is refused if it does not resolve |
| `date`, `epiWeek` | From the signing time, in Nairobi time; the epi-week runs Monday to Sunday |
| `ageBand` | `0-4`, `5-14`, `15-24`, `25-44`, `45-64`, `65+` |
| `category` | Copied from the bundle at signing time |
| `alertRequested` | The pathologist's Rule M request |
| `status` | `Active`, or `Retracted` when a later version drops the finding |
| `synthetic` | `true` for every demo event |
| `createdAt`, `lastUpdatedAt` | Stamps |

**No name, phone number, case id, exact location, exact date of birth or
facility leaves the case.** The link from an event back to its case, needed
for an audit, is kept in `notifiableEventLinks`, which no client can read. An
amendment that drops a finding retracts its event; one that keeps it changes
nothing.

## 4. Detect

A trigger on each event keeps a weekly count per disease and county
(`epiCounts`), counted once per event however often the trigger fires, then
runs three rules, in plain code and unit-tested on fixed fixtures, for
eligible diseases only:

- **Rule A — Immediate.** One confirmed event raises a signal for that
  disease and county.
- **Rule B — Baseline.** For a weekly disease, a signal is raised when a
  county's count this epi-week is above the mean of the previous 8 weeks plus
  2 standard deviations, **and** at least 5, so one case in a quiet county
  does not trip it. The window, the multiplier and the floor are
  provisional, and each signal records the values it was raised with.
- **Rule M — Manual.** For a weekly disease that allows it, a pathologist's
  "Raise an alert" raises a signal while the count is still below baseline.

A signal's id is the dedupe key,
`alertSignals/{diseaseId}_{countyId}_{epiWeek}`, so every path ends in the
same document, and one disease, county and week produce one draft however it
was triggered. A signal names no pathologist and no facility. If
retractions bring the count back to 0, the signal is withdrawn, and a draft
still awaiting approval with it.

## 5. Draft

The AI service drafts `alerts/{uid}`:

- **Doctor guidance and a patient notice**, both in **English and Swahili**.
- **Placeholders only.** The model receives no case data, and no count, date
  or age band; it writes `{disease}` and `{county}` (and, for clinicians,
  `{count}` and `{weekStart}`), and code fills them in from the approved
  evidence at delivery. A draft with a digit is refused.
- **Grounded in the bundled guidance**, which it receives as data and may
  not rewrite. The guidance is delivered verbatim beside the text.
- Wording that diagnoses, reassures or predicts is refused by the checks in
  the functions, not only in the service.
- **If the model fails**, or `alert_drafting_enabled` is off, a fixed
  template draft is used, so the approver always gets one.
- The **evidence** the approver needs: disease, county, the rule that fired,
  this week's count against the baseline, the age bands, the manual requests,
  and the category and mapping verification flags.

## 6. Approve

**An authorised public-health officer (MoH or a county health department)**
approves. In the system that is an `admin` holding the `alertApprover` claim
and listed in the approver registry; only a different, existing approver can
grant or revoke the claim, and a revoke takes effect at once.

`approveAlert` is the one callable, with three decisions:

- **Approve**, the primary action: one tap, the draft as is,
  `acceptedUnchanged: true`.
- **Approve edited**: the edits are stored **beside** the original draft,
  never over it, with which parts changed and by how much.
- **Reject**, with a reason. A rejected alert stays rejected for its week
  unless an approver redrafts it (at most three drafts).

The approver may send an alert to clinicians only. The function refuses an
approval if the draft or the evidence changed since the screen read it, and
**refuses the pathologist who raised it** (four eyes). A draft not decided in
time expires: 24 hours for an immediate disease, with a reminder after one,
and 72 hours for a weekly one. **Nothing is delivered without approval**, and
the rules make that structural: no client, approver included, can write an
alert.

## 7. Deliver

Delivery runs when an alert becomes `Approved`, in two phases:

1. **Clinicians first.** Verified practitioners whose county is the alert's
   get an inbox row and a push, so they can watch for cases before patients
   arrive asking. They also read `publicAlerts/{a}/doctor/brief`: the
   clinician text, the count and week, the rule, and the statutory-report
   reminder. Neighbouring counties join once a county adjacency table is
   sourced; until then the alert county only.
2. **Patients next.** The patient notice is written to `publicAlerts/{a}`
   and released to patients, then pushed to the county's topic in each
   language, `alerts_patient_{countyId}_{lang}`, with no row per patient.
   The app subscribes to its county's topic and moves it when the county or
   language changes (on the web, where topics are not supported, the inbox
   shows the county's alerts instead). The delay between the phases is a
   config value: zero in the demo.

The delivered alert reads "Approved for release by an authorised
public-health officer. Guidance: {source}", with the guidance verbatim and
the Kiswahili labelled as Tabibu's translation. It carries no count, age
band, date, facility or approver name.

**The kill switch fails closed.** `alerts_delivery_enabled` is checked before
every page and every topic send. When it is off, or the server template
cannot load, delivery is held and resumed by the sweep, and the approvers are
told after 15 minutes held. Before patients are reached, delivery checks
again that the switch is on, the evidence still stands and the approval is
under 24 hours old; otherwise the alert stays with clinicians only, and the
approvers are told. Each recipient's row follows the
[notifications engine](./notifications_engine.md)'s idempotency rules, and
each topic send is claimed once, so a retried delivery never notifies anyone
twice.

## 8. Privacy

- **Patients choose a county and sub-county; Tabibu never reads their
  location.** `geolocator` is in `pubspec.yaml` for a possible
  facility-finder feature, and it must never be called on the patient's
  behalf. The patient's geohash is the sub-county's centre (CRQ-0014), and
  it never enters a notifiable event. A rules
  test and a code-review rule in the threat model guard this. A patient's
  county changes only through `updatePatientArea`.
- Events are anonymous at creation; nothing is "anonymised later".
- The patient notice carries no count, age band or date; only the clinician
  brief carries the count.
- A patient's read state for public alerts stays on the device.

## 9. Firestore rules (target)

```
match /notifiableEvents/{id}     { allow read, write: if false; }   // Functions only
match /notifiableEventLinks/{id} { allow read, write: if false; }
match /epiCounts/{id}            { allow read, write: if false; }
match /alertSignals/{id}         { allow read: if isAlertApprover(); allow write: if false; }
match /alerts/{id}               { allow read: if isAlertApprover(); allow write: if false; }
match /publicAlerts/{id} {
  allow read: if isAlertApprover()
              || (clinical() && (role() != 'patient' || resource.data.patientsReleased == true));
  allow write: if false;
  match /doctor/{d} {
    allow read: if d == 'brief'
                && (isAlertApprover() || role() in ['doctor', 'pathologist']);
    allow write: if false;
  }
}
// alertDeliveries, alertApprovers, demoAccounts: closed to every client
```

`isAlertApprover()` is `isAdmin() && token.alertApprover == true`. A
patient's list query must filter `patientsReleased == true`.

## 10. Demo

Two cases show the rules, all synthetic:

1. A seeded burst of positive malaria smears in one county crosses its
   baseline (Rule B).
2. A single synthetic Ebola NAAT result, signed by the pathologist, raises a
   signal on its own (Rule A). Ebola is confirmed by a nucleic-acid test, not
   microscopy, so this needs no Ebola image dataset.

**Demo alerts are marked.** A synthetic alert uses the demo templates, whose
every headline and body begins "Demo:" ("Majaribio:"), carries a banner in the
app, and reaches only the seeded demo accounts and the demo topics
(`alerts_patient_demo_{countyId}_{lang}`).

Each produces a draft in both languages, an approval, and the alert arriving
on a doctor's phone and then a patient's.

## 11. Open questions

1. Which reporting category does Kenya's current IDSR guideline give each
   disease? Until the 3rd edition's Table 1 is read, every category is
   unverified (§2.1).
2. Which published dataset gives the county adjacency? Until one is checked,
   clinicians in the alert county only (§7).
3. Should a Rule A signal skip the patient phase until a second confirmation,
   to limit alarm from a single result? For now the approver decides per
   alert, and may choose clinicians only.

Before a pilot, the Ministry of Health or a county health department reviews
the alert scope, the guidance and the attribution.

## 12. Change log

| Date | Change | Author |
|---|---|---|
| 2026-11-01 | For the `feat/infra` data layer: §1 the statutory notification stays the facility's; §2 the bundled 38-disease list with its sources and unverified categories, and the guidance; §3 the pathologist's finding, the event allow-list, retraction; §4 Rule M and `epiCounts`; §5 placeholders, grounding and the template fallback; §6 approval by an authorised public-health officer (`admin` + `alertApprover`), four eyes, expiry; §7 two-phase delivery by rows and county topics, `publicAlerts`, the kill switch failing closed; §9 the rules; §10 demo alerts marked (CRQ-0049). | Theo |
| 2026-10-27 | §8: patients choose a sub-county too; the geohash is an area, never an event field (CRQ-0014). | Theo |
| 2026-10-27 | Initial version: the six-step pipeline, the event shape and what never leaves a case, Rules A and B, approval and two-phase delivery, the rules shape and the demo. | Theo |
