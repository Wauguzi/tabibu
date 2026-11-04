# Change Request (CRQ) — Tabibu

| Field | Value |
|---|---|
| CRQ number | CRQ-0052 |
| Title | Voice: speak your symptoms (English) through the Meta speech model, and voice notes in the chats |
| Requested by | Theo — CTO, Mobile Engineer |
| Date raised | 2026-11-04 |
| Date implemented | Pending — completed on `main` after the merge (CRQ-0038) |
| Priority | P2 High — see [`mobile_workflow.md` §7](../../workflow/reports/mobile_workflow.md#7-escalation--severity) |
| Change type | Normal |
| Commit(s) / PR | `feat/voice`: d8deae0, 14231b5, fef5aef, 0238cf2, 74594df, 853b594, 6045a85, 33188ed, and the keyboard sweep; the PR link is added after the merge |

## 1. Description of change

CRQ-0051 left speech out. The data layer for it already existed on `main` (the
upload paths, the rules, the `transcribeSymptoms` callable, the voice-note
message kind, all behind the switch `voice_input_enabled`); nothing in the app
could record or play a sound, and nothing on the server could call a speech
model. This change builds the missing pieces.

1. **A recorder and a player in the app** (fef5aef, 6045a85). Two services
   behind interfaces, with fakes for tests: AAC in an `.m4a` for chat notes
   (up to 120 s and 512 KB) and 16-bit PCM WAV at 16 kHz for symptoms (up to
   45 s and 1.5 MiB). The microphone permission is asked once, with a plain
   line for a denial. The web demo has no recording and says so. Two packages
   are added, `record` (BSD-3-Clause) and `just_audio` (MIT).
2. **The Meta speech model behind the existing seam** (14231b5, 853b594).
   `muse-voice-transcribe-1.0` through `POST /v1/asr/transcribe`, with the same
   secret, timeout and retry as the other calls. The server parses the
   recording's header, refuses anything that is not mono 16-bit PCM at 16 or
   24 kHz and 1 to 46 seconds, and sends Meta a clean rebuilt file, whatever
   the recorder added. The audio object is deleted after the call, whether it
   worked or not.
3. **Speak your symptoms** (0238cf2, 74594df, 6045a85). A microphone beside the
   symptoms field on the booking form. The patient records up to 45 seconds,
   presses Transcribe, and the text appears in the field as ordinary editable
   text under a notice that it was prepared with AI. A transcript is added to
   what they already typed, not over it, and is cut at the field's 500
   characters with a notice. The request is sent as voice only if the sent
   text came from a transcript; clearing the field and typing sends it as
   typed. Typing always still works.
4. **Voice notes in the chats** (33188ed). A microphone in the composer of the
   appointment chat and the multidisciplinary consult, a preview before
   sending, and a bubble that plays the note with the designer's 16-bar wave
   filling as it plays. A note recorded offline waits in the app's support
   folder until it uploads and is deleted afterwards. The bubble says
   "Transcript not available for voice notes."
5. **A short vibration and a beep** when recording starts and stops (33188ed):
   the beep finishes before the microphone opens and starts after it closes, so
   it is never in the recording.
6. **Taps outside any text field or search bar dismiss the keyboard**, in the
   two shared fields and every screen that has its own input (the keyboard
   sweep).

**Two limits found in the docs and kept in the open.** The speech API takes WAV
only and does not support Kiswahili (it lists 25 languages without it).
So the symptom recording is WAV and **voice works in English only**; the form
says so in both languages and typing works in both. Chat notes stay AAC and are
**not transcribed** (the API would refuse them); the server marks their
transcript `Failed` with the reason `UnsupportedFormat` and makes no model call.

## 2. Business justification

The hackathon rewards using the Meta platform; the speech model is the part of it
this product had not touched. It also fits the people Tabibu is for: a patient who
finds typing slow can say what is wrong, and a doctor and a pathologist can send
each other a voice note without leaving the case. It is built as a draft for a
person to check, like everything else here.

## 3. Scope

**In scope:** §1.

**Explicitly out of scope:**

- Kiswahili speech recognition (the API does not offer it), and any claim of it.
- A transcript of a chat voice note, a streaming (live) transcription, speaker
  separation, and playing the speech back as text-to-speech.
- Recording on the web demo.

## 4. Impact assessment

| Area | Impact | Notes |
|---|---|---|
| Data model (Firestore, Hive) | Affected, additive | A voice message may carry `failureReason`; the app's model ignores unknown keys |
| Roles & case scoping | None | Only a patient may upload speech audio, into their own folder |
| Clinical safety | **Affected** | See below |
| AI service (prompts, models, thresholds) | **Affected** | One more model call, `muse-voice-transcribe-1.0`, no prompt; the transcript is machine text |
| Security (rules, App Check, RASP, secrets) | **Affected** | `storage.rules` changes the `speechAudio` path to `.wav`, `audio/wav`, 1.5 MB; the secret `META_API_KEY` is bound to `transcribeSymptoms` and the message trigger; the microphone permission is new |
| Data protection (PHI, de-identification, model endpoints) | **Affected** | See below |
| Design system / UI consistency | Affected | The wave follows the designer's `audio_wave.svg`; the icons are the designer's |
| Localisation (en, sw) | Affected | Every string in both languages; speech is English only and says so |
| Existing data | None | Existing `.m4a` speech objects are never read: the path pattern changed and the rule denies reads |

**Clinical safety.** The model's text never reaches a person unchecked. A
symptom transcript lands in the patient's own field, labelled as AI, and the
patient reads and edits it before anything is sent; the doctor receives the
patient's text, and the server records whether it was edited (an edit distance,
not the text). A chat note's audio is the person's own voice, not a model's
output, and is not transcribed. Nothing here changes a clinical record, a
result or an alert.

**Data protection.** Audio leaves the system in one case only: a patient presses
Transcribe on a symptom recording. The server checks it, rebuilds a plain WAV
and sends only the audio and fixed settings (the model, the encoding, the mode);
no name, id or text travels with it. The object is deleted in a `finally`,
including when the call fails or times out (a test for each path). The model is
not asked to store anything. The app asks for consent once, in plain words,
before the first recording. A voice note stays in the conversation's storage
under the existing rules and is never sent to a model. No audio, transcript or
file path is put in a log, an error or an analytics event; the events carry a
duration bucket and a language flag.

## 5. Risk & rollback plan

**Risk level:** Medium. It touches a storage rule and patient audio, but the
failure of every part leaves typing, which works.

**Rollback plan:** the switch `voice_input_enabled` is off until the first live
call passes; if it misbehaves, turning it off returns the form to typing and
leaves chat notes as they are (they use no model). The whole change reverts with
the merge commit, a rules deploy and a functions deploy. The old `.m4a` rule is
not kept: nothing uses it.

## 6. Implementation plan

1. Read the speech API's own documentation, and stop where it disagreed with the
   plan: WAV only, no Kiswahili.
2. The recorder, the player and their fakes behind interfaces; then the server
   client and its guards; then the screens that use them.
3. Move the symptom path to WAV: the rule and the server first (a rules test for
   each guard), then the recorder's format, then the screen.
4. Deploy rules, then functions, from the merge; one live call by hand before
   the switch goes on.

## 7. Testing & verification evidence

| Check | Result |
|---|---|
| `make rules-test` | To be filled from the final gate run (248 passing at 853b594) |
| `make functions-test` | To be filled from the final gate run (668 passing at 853b594) |
| `flutter test` | To be filled from the final gate run |
| `make analyze`, `make bloc-lint`, `make spell`, `make licenses`, `make release-check` | To be filled from the final gate run |
| Licences of the two new packages | `record` BSD-3-Clause, `just_audio` MIT; `make licenses` passed on 287 licences from 280 packages |
| Size of a recording | AAC about 240 KB a minute; WAV 45 s about 1.44 MB (32,000 bytes a second plus a 44-byte header) |
| Server header validation | Refused before any call and deleted: 44.1 kHz, stereo, 8-bit, a lying length, a truncated file, 47 s, 0.5 s, non-audio, `audio/mp4`; accepted and rebuilt: a padding chunk, a trailing chunk, a streaming header |
| Storage rule | Denied: 1.6 MB, `audio/mp4`, an `.m4a` name, another user's folder, a doctor, a role-less account, any read |
| Live call to the Meta speech API | **Not yet made**; the one-line command is in the AI service note; this row is filled with its result before `voice_input_enabled` is switched on |
| A real recording from an iPhone and an Android phone | **Not yet made**; only a device proves the recorder's WAV header against the server's check |
| Manual run | The device pass in CRQ-0050 gains a voice section |

## 8. Approval

| Role | Required when | Name | Date | Decision |
|---|---|---|---|---|
| Author | Always | Theo | 2026-11-04 | — |
| Engineering reviewer | Always, on the pull request | Greptile | — | Pending — rounds recorded on `main` after the merge (CRQ-0038) |
| Clinical Reviewer | §4 flags clinical-safety impact or changes clinical wording | Pending | — | The consent line and the English-only line are read by a clinician after the demo build |
| Security Analyst | §4 flags security impact | Covered by CTO | Pending | A storage rule, a secret binding and a new permission; read line by line |
| Compliance Officer | §4 flags data protection impact | Covered by CTO | Pending | Patient audio leaves only on an explicit press, is validated, rebuilt and deleted |
| Lead Designer | §4 flags design-system impact | Pending | — | The wave and the playing state are confirmed in the afternoon session |

## 9. Post-implementation review

- The plan assumed one audio format end to end. The speech API's documentation
  said otherwise, and the server client was written to refuse what the API would
  refuse, so no audio left on a call that could not work. That is why there are
  two formats and why speech is English only.
- A review before the pull request found that the recorder dropped a clip that
  ran to its time limit, that a transcript replaced what a patient had typed, that
  a double tap on stop could lose a clip, and that a voice note waiting to upload
  was kept in a folder the system may clear. Each is fixed with a test shown
  failing first.
- Left for after the merge: a second device-level check of the recorder's header on
  several phones; the unreachable WAV branch in the chat transcription is kept for
  when a WAV note can arrive; the playing bars' full opacity is a choice to confirm
  with the designer; the cues are skipped when the phone's reduce-motion setting is
  on, which is not strictly a sound preference.
- Greptile's rounds after the merge.

## 10. Related records

- The data layer and the rules: [CRQ-0044](./CRQ-0044-appointments-availability-and-voice-input.md), [CRQ-0045](./CRQ-0045-conversations-mdt-and-voice-notes.md)
- The other Meta calls: [CRQ-0051](./CRQ-0051-live-ai-on-the-meta-model-api.md)
- The screens: [CRQ-0050](./CRQ-0050-role-screens-and-flows.md)
- Secrets: [CRQ-0007](./CRQ-0007-secrets-handling-for-model-api-keys.md)
- Records after the merge: [CRQ-0038](./CRQ-0038-merge-commits-and-kept-branches.md)
- The speech API's pages: [speech to text](https://dev.meta.ai/docs/speech-to-text), [transcribe reference](https://dev.meta.ai/docs/api-reference/voice/transcribe), [schemas](https://dev.meta.ai/docs/api-reference/voice/schemas)
