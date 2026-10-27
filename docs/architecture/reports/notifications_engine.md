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
| Last reviewed | 2026-10-27 |
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

### Cloud scope — written by Cloud Functions

| Event | Recipient | Push copy (lock screen) |
|---|---|---|
| Patient connects; a doctor accepts the case | Patient | "A doctor has taken your case." |
| Doctor opens a case for a patient | Patient | "Your doctor opened a case for you." |
| Pathologist attached to an order | Pathologist | "A new case is waiting." |
| Pre-read ready | Pathologist | "A case is ready to review." |
| Pre-read failed | Pathologist | "A case needs a manual read." |
| Report signed | Ordering doctor | "A signed report is ready." |
| Result released to the patient | Patient | "Your result is ready in Tabibu." |
| Alert drafted | Alert approvers | "An alert is waiting for approval." |
| Alert delivered | Doctors, then patients (county audience) | Alert title only |

**Push copy never states a diagnosis.** A lock screen is visible to anyone
holding the phone, so every case push is generic and the detail opens only
inside the app after authentication. This matters most for cancer: the
result itself is not available to the patient until the doctor marks it
discussed.

### Local scope — cache only

Profile edited · county changed · language changed · draft edits saved ·
order submitted (the doctor's own confirmation) · offline queue flushed.

## 3. Data model

`NotificationModel` (Freezed) and `NotificationHive` (field order mirrored),
one document per recipient, never a recipients array:

| Group | Fields |
|---|---|
| Identity | `uid`, `threadUid`, `idempotencyKey`, `creationDate` |
| Addressing | `recipientUid`, `recipientRole`, `initiatorUid`, `initiatorRole` |
| Content | `title`, `message`, `templateKey`, `templateArgs` |
| Classification | `category` (`Case`, `Preread`, `Report`, `Result`, `Alert`, `Account`), `priority` |
| Delivery | `channel` (`InApp`, `Push`), `source`, `scope` (`Local`, `Cloud`) |
| State | `status` (`Unread`, `Read`, `Archived`), `readAt`, `pushSentAt`, `synced`, `lastUpdatedAt` |
| Payload | `resourceType` (`Case`, `Alert`), `resourceUid`, `deepLink` |

The enums `NotificationCategory`, `NotificationScope`, `NotificationStatus` and
`NotificationTemplate` live in `core/constants/enums.dart`. They are separate
from the app's role enum, so adding a notification kind never adds a role.

## 4. Idempotency — three separate guards

1. **The document id guards retries.** `notifications/{uid}_{recipientUid}`,
   where `uid` is minted once. Replaying a queue rewrites the same document.
2. **`idempotencyKey` guards duplicate events.** It is
   `{event}:{resourceUid}:{recipientUid}`: it names what happened, not who
   noticed, so two raisers of the same event compose the same key and the
   dispatching function writes once.
3. **`lastUpdatedAt` guards ordering.** Two devices marking the same row
   offline cannot let the older write win. `pushSentAt` makes the push
   fan-out safe to retry.

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

Required indexes: `(recipientUid, status, creationDate desc)` for the unread
badge and `(recipientUid, creationDate desc)` for the inbox.

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
| Push | App backgrounded or closed | FCM: tokens in `fcmTokens` on `patients/{patientId}` or `doctors/{uid}`; county topics for alerts |

Two Android channels: **Alerts** (high importance) and **Case updates**
(default). On iOS, foreground presentation options are set explicitly so
the messaging plugin does not suppress banners. The listener opens on the
role shell and on resume, and closes on background and sign-out (see
[`mobile_architecture.md` §9](./mobile_architecture.md#9-lifecycle)).

**Tapping** a banner or push hands the payload to one `NotificationTapHandler`,
which marks the row read and routes through the typed router. A cold-start
payload is read once, after the `DecisionRoute` resolves.

**Release builds keep the notification icon.** It is looked up by name, so
`res/raw/keep.xml` keeps it from the resource shrinker. Without it, the
plugin fails at its first `show()` call.

## 8. Retention

Read rows older than 30 days are pruned from Hive on open. Firestore uses a
TTL policy on a `expireAt` field set at creation. Unsynced rows are never
pruned.

## 9. Status

Nothing in this document is built yet. Order of work: model and Hive mirror,
rules and their tests, the dispatching function, the inbox bloc and screen,
push, and alert delivery last.

## 10. Change log

| Date | Change | Author |
|---|---|---|
| 2026-10-27 | §7: tokens live on the profile documents; there is no `users` collection (CRQ-0014). | Theo |
| 2026-10-27 | Initial version: the Local/Cloud rule, the event catalogue with lock-screen-safe push copy, the model, the three idempotency guards, server-only creation, localisation, delivery surfaces and retention. | Theo |
