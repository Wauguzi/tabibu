/**
 * Daily model-performance aggregates. Counts and rates only — never a uid or text.
 */
import { FieldValue, type Firestore, type Transaction } from 'firebase-admin/firestore';

import { refuse, nairobiDayKey, timestamp } from './common';

/** Allow-listed §3.9 signal field names. */
export const MODEL_SIGNAL_FIELDS = new Set([
  'prereadReadyCount',
  'prereadFailedCount',
  'prereadAcceptedUnchanged',
  'prereadScored',
  'translationReadyCount',
  'translationAcceptedUnchanged',
  'explanationReadyCount',
  'explanationAcceptedUnchanged',
  'intakeReadyCount',
  'intakeFailedCount',
  'symptomTranscriptAcceptedUnchanged',
  'voiceTranscriptReady',
  'voiceTranscriptFailed',
  'voiceTranscriptShared',
  'voiceTranscriptSharedUnchanged',
  'riskCheckFailed',
  'notesTranslationFailed',
  'alertDraftReady',
  'alertDraftTemplateFallback',
  'alertAcceptedUnchanged',
  'hintShownMarked',
  'transcriptionCount',
]);

/** Bump one numeric field on `modelSignals/{YYYYMMDD}` (Nairobi day). */
export function bumpModelSignal(
  tx: Transaction,
  db: Firestore,
  field: string,
  now: Date,
  by = 1,
): void {
  if (!MODEL_SIGNAL_FIELDS.has(field)) throw refuse('invalid-argument', 'invalidSignalField');
  const day = nairobiDayKey(now);
  const ref = db.collection('modelSignals').doc(day);
  tx.set(
    ref,
    {
      day,
      [field]: FieldValue.increment(by),
      lastUpdatedAt: timestamp(now),
    },
    { merge: true },
  );
}
