# Tabibu — Notifications Engine

> How a person learns something happened: the inbox, the foreground banner,
> and push. It sits above every feature: case handoffs between the three
> roles, a pre-read becoming ready, a signed report, a released result, and
> outbreak alerts. This document is the contract the app and the Cloud
> Functions both build against.

| Field | Value |
|---|---|
| Owner | Theo — CTO, Mobile Engineer |
| Status | Draft |
| Last reviewed | 2026-11-01 |
| Collection | `notifications` (top level) |
| Packages | `firebase_messaging`, `flutter_local_notifications` |

## 1. The one rule that decides everything

> **A notification is `Cloud` scope if and only if its recipient is not the
> person who caused it. Otherwise it is `Local`.**

The rule is about *audience*, not importance. "Draft saved" is for the
person who saved it, on the device they saved it on, and never leaves the
Hive inbox box. "A report is ready for you" has a recipient who was not
there when it happened, so it must be a Firestore document.

`Local` rows are born `synced: true` and cost one Hive write and no
Firestore reads. Marking a `Cloud` row read **does** sync (three fields:
`status`, `readAt`, `lastUpdatedAt`), because the same person may open the
web demo next and should not see it as unread again.

## 2. Event catalogue

Version 2, for the `feat/infra` data layer (CRQ-0046). Each Cloud event names
the function that raises it; the template name is also the
`NotificationTemplate` value, so the copy `switch` stays exhaustive. Every
string is bilingual: the Kiswahili copy lives beside the English in the
functions' copy files and the ARB bundle. An empty Action means the row only
informs; `Approval` and `Acknowledge` rows carry an action, settled by the
function that resolves it. In the push copy, `·` separates the title from the
body, and a second sentence after `·` on rows 33-34 is the collapsed form.

### Cloud scope: 46 events, written by Cloud Functions

| # | Template | Raised by | Recipient | Category | Action | Push (en) |
|---|---|---|---|---|---|---|
| 1 | `orderCreated` | `createOrder` | patient (if linked) | Case |  | Your doctor has ordered tests for you. |
| 2 | `pathologistRequested` | `createOrder`, `requestPathologist`, `reassignPathologist` | pathologist | Case | Approval (request expiry) | A new case is waiting. |
| 3 | `pathologistAccepted` | `acceptCase` | doctor | Case |  | A pathologist accepted your case. |
| 4 | `pathologistAcceptedPatient` | `acceptCase` | patient | Case |  | A pathologist is working on your tests. |
| 5 | `pathologistRejected` | `rejectCase` | doctor | Case | Acknowledge → picker | A pathologist could not take your case. |
| 6 | `pathologistRequestExpired` | `expirePathologistRequest` (sweep, `acceptCase`) | doctor | Case | Acknowledge → picker | A pathologist could not take your case. |
| 7 | `caseWithdrawn` | `reassignPathologist` | old pathologist | Case |  | A case was reassigned. |
| 8 | `prereadReady` | `onPrereadWritten` | pathologist | Preread |  | A case is ready to review. |
| 9 | `prereadFailed` | `onPrereadWritten` | pathologist | Preread |  | A case needs a manual read. |
| 10 | `orderCancelled` | `cancelOrder` | patient; requested or accepted pathologist | Case |  | An order was cancelled. |
| 11 | `caseShared` | `createShareCode` | recipient | Case | Acknowledge + `shareCode` (24 h) | A case was shared with you. Open Tabibu to see your access code. |
| 12 | `shareRedeemed` | `redeemShareCode` | sharer | Case |  | Your shared case was opened. |
| 13 | `reportSigned` | `signReport` v1 | doctor | Report | Acknowledge + `shareCode` (7 d); High if `isCritical` | A signed report is ready. |
| 14 | `reportUpdated` | `signReport` v2+ | doctor | Report | Acknowledge + `shareCode` | A report has been updated. |
| 15 | `shareCodeReissued` | `reissueShareCode` | doctor | Report | Acknowledge + `shareCode` | A new code is ready for a report. |
| 16 | `criticalReportUnopened` | `sweepCases` (daily, until opened) | doctor | Report | (High) | A signed report is still waiting for you. |
| 17 | `criticalReportUnopenedSigner` | `sweepCases` | signer | Report |  | A report you signed has not been opened yet. |
| 18 | `resultsWithDoctor` | `signReport` v1 | patient | Result | Acknowledge → book-discussion | Your results are with your doctor. Book a time to discuss them. |
| 19 | `resultUpdateWithDoctor` | `signReport` v2+ after a release | patient | Result | Acknowledge → book-discussion | There is an update to your results with your doctor. |
| 20 | `resultReleased` | `markDiscussed` | patient | Result |  | Your result is ready in Tabibu. |
| 21 | `translationReady` | `onReportTextWritten` | signer | Report | → text | A translation is ready to review. |
| 22 | `explanationReady` | `onReportTextWritten` | doctor | Report | → text | An explanation is ready to review. |
| 23 | `appointmentRequested` | `requestAppointment` | doctor | Appointment | Approval | New appointment request · A patient has asked to see you. Reply before the request expires. |
| 24 | `caseDiscussionRequested` | `requestAppointment` | doctor | Appointment | Approval | New discussion request · A patient has asked for time to discuss a result. |
| 25 | `appointmentAccepted` | `respondToAppointment` | patient | Appointment |  | Appointment confirmed · Your appointment request was accepted. |
| 26 | `appointmentDeclined` | `respondToAppointment` | patient | Appointment | Acknowledge → rebook | Appointment request declined · You can choose another time or another doctor. |
| 27 | `appointmentExpired` | `expireAppointments`, `respondToAppointment` | patient | Appointment | Acknowledge → rebook | Appointment request expired · Your request had no reply in time. You can choose another time. |
| 28 | `appointmentCancelledByPatient` | `cancelAppointment` | doctor | Appointment |  | Appointment cancelled · A patient cancelled an appointment. |
| 29 | `appointmentCancelledByDoctor` | `cancelAppointment` | patient | Appointment | Acknowledge → rebook | Appointment cancelled · Your doctor cancelled your appointment. You can book another time. |
| 30 | `mdtInvited` | `openMdt`, `inviteToMdt` | invitee | Mdt | Approval (7 d) | You have been invited to an MDT discussion. |
| 31 | `mdtInviteAccepted` | `respondToMdtInvite` | owner | Mdt |  | A colleague has joined your MDT discussion. |
| 32 | `mdtInviteDeclined` | `respondToMdtInvite` | owner | Mdt |  | (inbox only) A colleague declined your MDT invitation. |
| 33 | `messageReceived` | `onMessageCreated` | the other direct participant | Message | (collapsed; push ≤ 1 per 60 s) | You have a new message in Tabibu. · You have {newCount} new messages in Tabibu. |
| 34 | `mdtMessageReceived` | `onMessageCreated` | other accepted MDT members | Message | (collapsed) | There is a new message in an MDT discussion. · {newCount} new messages in an MDT discussion. |
| 35 | `alertDrafted` | `onAlertWritten` | each approver | Alert | Approval (the alert's `expiresAt`) | An alert is waiting for approval. |
| 36 | `alertDraftReminder` | `sweepCases` | each approver | Alert | (High) | An urgent alert is still waiting for approval. |
| 37 | `alertExpired` | `sweepCases`, `approveAlert` | each approver | Alert |  | An alert expired without a decision. |
| 38 | `alertWithdrawn` | `onNotifiableEventWritten` | each approver | Alert |  | An alert draft was withdrawn after a report was amended. |
| 39 | `alertEvidenceChanged` | `onNotifiableEventWritten` | each approver | Alert |  | The results behind an approved alert have changed. Review it in Tabibu. |
| 40 | `alertDeliveredClinician` | `deliverAlert` | verified practitioners in the county (and neighbours, once sourced) | Alert | (High) | Health alert: {disease} in {county} County. Open Tabibu for guidance. |
| 41 | `alertDeliveredPatient` | `deliverAlert` | **a topic, no row** (`alerts_patient_{countyId}_{lang}`) | Alert | n/a | Health alert: {disease} in {county} County. Open Tabibu for guidance. |
| 42 | `confirmatoryTestRequested` | `signReport` | ordering doctor | Report | → the report | A pathologist recommends a further test for a case. |
| 43 | `alertDeliveryHeld` | `sweepCases` (held > 15 min) | each approver | Alert | (High) | Alert delivery is paused. Open Tabibu to review. |
| 44 | `alertDeliveryStopped` | `deliverAlert` (retracted or stale before release) | each approver | Alert |  | An alert went to clinicians only and was not released to patients. |
| 45 | `alertDeliveredClinicianDemo` | `deliverAlert` (synthetic) | `demoAccounts` clinicians in the county | Alert |  | Demo: Health alert: {disease} in {county} County. This is a test, not a real alert. |
| 46 | `alertDeliveredPatientDemo` | `deliverAlert` (synthetic) | **topic** `alerts_patient_demo_{countyId}_{lang}` | Alert | n/a | Demo: Health alert: {disease} in {county} County. This is a test, not a real alert. |

The two rows the first version had for a case opening ("Your doctor opened a
case for you." and "A doctor has taken your case.") are replaced by rows 1
and 25, because the order is now the case.

**Push copy never states a diagnosis.** A lock screen is visible to anyone
holding the phone, so every case push is generic and the detail opens only
inside the app after authentication. No row carries an order number, a
patient identifier, a test, a diagnosis, a practitioner's name, a share code,
or the word "critical" in push. `templateArgs` holds only `newCount` on the
message rows. This matters most for cancer: the result itself is not
available to the patient until the doctor marks it discussed (S-3).

**The one exception is a public alert** (rows 40-41, and their demo rows
45-46). It is addressed to an area, not a person, so its push may name the
disease and the county, and nothing else: never a count, a date, a facility
or a person. The row carries only `diseaseId` and `countyId`, and `sendPush`
resolves each to the bundled name in the recipient's language. A synthetic
alert's copy always begins "Demo:" and reaches only the demo accounts and
the demo topics.

### Local scope: 12 events, cache only

`appointmentRequestSent` · `appointmentCompleted` · `orderSubmitted` ·
`draftSaved` · `prereadScored` · `reportSignedSelf` · `shareCodeSent` ·
`mdtOpened` · `messagesQueued` · `queuedMessagesSent` · `notifiableRecorded` ·
`alertDecisionSaved`. Their key is
`local:{template}:{resourceUid}:{uid}:{yyyyMMddHHmm}`, so two rows of one kind
for one resource in the same minute collapse into one.

## 3. Data model

`NotificationModel` (Freezed) and `NotificationHive` (typeId 40, field order
mirrored), one document per recipient, never a recipients array. The nested
`NotificationMetadataModel` is typeId 41.

| Group | Fields |
|---|---|
| Identity | `uid` (= `idempotencyKey` = the document id), `threadUid` (the case, appointment, conversation or alert), `idempotencyKey`, `creationDate` |
| Addressing | `recipientUid`, `recipientRole`, `initiatorUid`, `initiatorRole`, `initiatorName` (shown in the inbox, never in push) |
| Content | `title`, `message`, `templateKey`, `templateArgs` |
| Classification | `category` (`Case`, `Preread`, `Report`, `Result`, `Alert`, `Account`, `Appointment`, `Mdt`, `Message`), `priority` |
| Delivery | `channel` (`InApp`, `Push`), `source`, `scope` (`Local`, `Cloud`) |
| State | `status` (`Unread`, `Read`, `Archived`), `readAt`, `pushRequestedAt`, `pushSentAt`, `synced`, `lastUpdatedAt` |
| Payload | `resourceType` (`Case`, `Alert`, `Report`, `Appointment`, `Conversation`), `resourceUid`, `metadata` |

`metadata` holds `actionType`, `actionStatus`, `actionedByUid`, `actionedAt`,
`expiresAt`, `deepLink`, `shareCode` and `extras`. **`deepLink` lives here**,
apart from the action, because what a row does and where it goes are
separate. `shareCode` is set only on the recipient's own row, and the
model's `toString` redacts it. A server-only `expireAt` (a Firestore
Timestamp) drives TTL and is never in the Dart model.

**Collapsed message rows.** New messages in one conversation update a single
row per recipient, keyed by the conversation, with the running count in
`templateArgs.newCount`. On such a row `creationDate` means "last activity":
every upsert moves it and refreshes `expireAt`. A direct thread's row
(row 33) pushes at most once a minute.

The enums `NotificationCategory`, `NotificationScope`, `NotificationStatus` and
`NotificationTemplate` live in `core/constants/enums.dart`. They are separate
from the app's role enum, so adding a notification kind never adds a role.

## 4. Idempotency — three separate guards

1. **The document id is the `idempotencyKey`**:
   `{template}:{resourceKey}:{recipientUid}`. It names what happened, not who
   noticed, so a retry and a second raiser of the same event both compose the
   same id, and the row is written once. The `resourceKey` is the case
   transition (`{caseUid}-r{seq}`), the report version, the share (with a
   reissue round), the appointment, the MDT invite round, the conversation
   (for the collapsed row), the text's request round, or the alert (with its
   draft round on approver rows).
2. **Reads come before writes.** Every helper has a read half and a write
   half, and a function does all its reads first, because the Admin SDK
   aborts a transaction that reads after writing. Every server write moves
   `lastUpdatedAt`, settling an action included.
3. **`lastUpdatedAt` guards ordering, and a claim guards push.** Two devices
   marking the same row offline cannot let the older write win. `sendPush`
   claims a row by setting `pushSentAt` before it sends, and a transient
   failure clears the claim only if `pushSentAt` still holds the value it
   wrote, so a retry never undoes a newer send. It looks up the recipient's
   tokens first, and for an alert approver (`recipientRole == 'admin'`) the
   tokens and language come from the approver registry.

## 5. Security — the collection is not client-writable

A notification carries a recipient, a message and a tappable deep link. If a
client could create one with any `recipientUid`, any signed-in user could
plant a message in a patient's inbox with Tabibu's own branding around it.
Tabibu has Cloud Functions from day one, so creation is server-only:

```
match /notifications/{id} {
  allow read:   if isSignedIn() && resource.data.recipientUid == request.auth.uid;
  allow create: if false;   // Cloud Functions (Admin SDK) only
  allow update: if isSignedIn()
    && resource.data.recipientUid == request.auth.uid
    && request.resource.data.diff(resource.data).affectedKeys()
         .hasOnly(['status', 'readAt', 'lastUpdatedAt']);
  allow delete: if false;
}
```

Required indexes: `(recipientUid, creationDate desc)` for the inbox,
`(recipientUid, status, creationDate desc)` for the unread badge, and
`(recipientUid, lastUpdatedAt)` for the live delta. `templateArgs` and
`metadata.extras` are exempt from indexing.

## 6. Localisation

`title` and `message` always hold resolved text, so a push payload or the
web demo can render without the ARB bundle. Rows also carry `templateKey` and
`templateArgs`, and the inbox re-renders from the ARB bundle in the person's
**current** language, so switching to Swahili does not leave an English
inbox behind. `NotificationTemplate` is an enum and the copy function's
`switch` is exhaustive, so adding a kind without its copy is a compile error.
Cloud Functions compose push text in the recipient's stored language.

## 7. Delivery surfaces

| Surface | When | Mechanism |
|---|---|---|
| Inbox | Always | Hive box, delta-pulled; a Firestore listener while in the foreground |
| Foreground banner | A new row addressed to the signed-in person arrives through the listener | `flutter_local_notifications`, with the row `uid` as payload |
| Push | App backgrounded or closed | FCM: tokens in `fcmTokens` on `patients/{patientId}` or `doctors/{uid}`, or on the approver registry for alert approvers; for patients, one topic per county and language for public alerts (`alerts_patient_{countyId}_{lang}`), with no row |

Three Android channels, each mutable separately in system settings, so a
kind of message never changes channel once shipped (CRQ-0022):

| Channel | Importance | Carries |
|---|---|---|
| **Account and security** (category `Account`) | High | Sign-in, sign-up and password-reset confirmations; security notices from the runtime protection (RASP) |
| **Alerts** (category `Alert`) | High | Approved outbreak alerts, and the approvers' rows |
| **Case updates** | Default | Every other category: cases, pre-reads, reports, results, appointments, MDT invitations and messages |

Channel names come from the ARB files in the device's language, because they
are created before any screen exists. On iOS, the app delegate sets the
notification-centre delegate and each notification asks for a banner, so
foreground notifications are not suppressed. `UIBackgroundModes` declares
`remote-notification` for FCM; the Push Notifications capability waits for
the Apple Developer account.

`NotificationService.showNotification` never throws. A notification is a
side effect, and a plugin exception on a sign-in path would otherwise
stop the sign-in. Failures are recorded to Crashlytics as
non-fatal. The listener opens on the
role shell and on resume, and closes on background and sign-out (see
[`mobile_architecture.md` §9](./mobile_architecture.md#9-lifecycle)).

**Tapping** a banner or push hands the payload, the row's `uid`, to one
`NotificationTapHandler`, which marks the row read and routes to its
`metadata.deepLink` through the typed router, which validates the path. A cold-start
payload is read once, after the `DecisionRoute` resolves.

**Release builds keep the notification icon.** It is looked up by name, so
`res/raw/keep.xml` keeps it from the resource shrinker. Without it, the
plugin fails at its first `show()` call.

## 8. Retention

Read rows older than 30 days are pruned from Hive on open. Firestore deletes a
row 90 days after it is created, through a TTL policy on the server-only
`expireAt`. It is a Firestore Timestamp, because TTL ignores strings, and a
collapsed message row refreshes it on every upsert. Unsynced rows are never
pruned.

## 9. Status

Nothing in this document is built yet. The `feat/infra` data layer builds the
model and Hive mirror, the rules and their tests, the shared write helper,
`sendPush`, and the cache helper and data source; the inbox bloc and screen
follow in a feature branch.

## 10. Change log

| Date | Change | Author |
|---|---|---|
| 2026-11-01 | Version 2 for the `feat/infra` data layer: §2 the 46 Cloud and 12 Local events, and the public-alert push exception; §3 the id is the `idempotencyKey`, `deepLink` in `metadata`, the new categories and resource types, collapsed message rows; §4 read-before-write and the push claim; §5 the delta index; §7 the alert topics and the tap route; §8 the 90-day TTL on a Timestamp (CRQ-0046). | Theo |
| 2026-10-27 | §7: three channels and what each carries; iOS presentation and background mode; the never-throwing show (CRQ-0022). | Theo |
| 2026-10-27 | §7: tokens live on the profile documents; there is no `users` collection (CRQ-0014). | Theo |
| 2026-10-27 | Initial version: the Local/Cloud rule, the event catalogue with lock-screen-safe push copy, the model, the three idempotency guards, server-only creation, localisation, delivery surfaces and retention. | Theo |
