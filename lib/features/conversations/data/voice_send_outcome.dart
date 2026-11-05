import 'dart:async';

/// How a voice-note send settled for the composer.
///
/// A wait timeout is treated as [queued] ("still pending"), never [refused].
enum VoiceSendOutcome {
  /// Upload landed; the cache owns deleting the local file.
  sent,

  /// Offline or still in flight; the pending store keeps the file.
  queued,

  /// Permanent refuse; the screen deletes the local file.
  refused,
}

/// Waits for [result] up to [timeout]. A timeout means still pending
/// ([VoiceSendOutcome.queued]): the preview may clear, and a late
/// [VoiceSendOutcome.refused] still deletes [path] so the file is not orphaned.
///
/// Returns whether the composer should treat the send as accepted (clear
/// preview). Only a prompt refuse returns false.
Future<bool> settleVoiceSend({
  required Completer<VoiceSendOutcome> result,
  required String path,
  required Future<void> Function(String path) delete,
  Duration timeout = const Duration(seconds: 60),
}) async {
  var timedOut = false;
  final outcome = await result.future.timeout(
    timeout,
    onTimeout: () {
      timedOut = true;
      return VoiceSendOutcome.queued;
    },
  );
  if (outcome == VoiceSendOutcome.refused) {
    await delete(path);
    return false;
  }
  if (timedOut) {
    // Preview already clears as "queued"; keep watching so a late refuse
    // does not leave an orphan under voice_pending until sign-out.
    unawaited(
      result.future.then((late) async {
        if (late == VoiceSendOutcome.refused) await delete(path);
      }),
    );
  }
  return true;
}
