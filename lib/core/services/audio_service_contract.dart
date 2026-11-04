import 'dart:typed_data';

/// Result of asking for the microphone.
enum MicPermission { granted, denied, permanentlyDenied, unsupported }

/// A finished clip ready to upload or preview. Always AAC-LC in an `.m4a`
/// container (`audio/mp4`).
class RecordedAudio {
  const RecordedAudio({
    required this.bytes,
    required this.durationMs,
    required this.peaks,
    this.contentType = 'audio/mp4',
  });

  final Uint8List bytes;
  final int durationMs;

  /// 0..100, at most 64 buckets, evenly spread over the recording.
  final List<int> peaks;
  final String contentType;
}

/// Captures microphone audio for a voice note or symptom recording.
///
/// A cancelled recording is deleted and never uploaded. The web demo reports
/// [isSupported] false so the UI shows a plain line instead of a mic.
abstract class AudioRecorderService {
  bool get isSupported;
  bool get isRecording;
  Future<MicPermission> ensurePermission();

  /// Throws [StateError] if already recording. Stops itself at [maxDuration].
  Future<void> start();

  /// 0..1, about ten samples per second while recording.
  Stream<double> get levels;

  /// Null when shorter than 1 s or over [maxBytes] after the cap.
  Future<RecordedAudio?> stop();

  /// Drops the file without returning bytes.
  Future<void> cancel();
  Future<void> dispose();

  static const Duration maxDuration = Duration(seconds: 120);
  static const int maxBytes = 512 * 1024;
}

/// One clip's playback state on the single logical player.
class AudioPlayback {
  const AudioPlayback({
    required this.id,
    required this.playing,
    required this.position,
    required this.duration,
    required this.completed,
  });

  final String id;
  final bool playing;
  final Duration position;
  final Duration duration;
  final bool completed;
}

/// Plays one clip at a time: starting a new one stops the previous.
abstract class AudioPlayerService {
  Stream<AudioPlayback> get playback;
  Future<void> playBytes(Uint8List bytes, {required String id});
  Future<void> playUrl(Uri url, {required String id});
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}
