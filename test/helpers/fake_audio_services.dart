import 'dart:async';
import 'dart:typed_data';

import 'package:tabibu/core/services/audio_service_contract.dart';

/// Scriptable recorder for bundles 88 and 89.
class FakeAudioRecorderService implements AudioRecorderService {
  FakeAudioRecorderService({
    this.supported = true,
    this.permission = MicPermission.granted,
    this.recorded,
    this.levelValues = const [0.2, 0.5, 0.8],
    this.startError,
    this.startDelay = Duration.zero,
    this.stopDelay = Duration.zero,
  });

  bool supported;
  MicPermission permission;
  MicPermission requestOrOpenSettingsResult = MicPermission.granted;
  RecordedAudio? recorded;
  List<double> levelValues;

  /// When set, [start] throws this instead of opening the mic.
  Error? startError;

  /// Holds [start] open so dispose can cancel mid-open.
  Duration startDelay;

  /// Holds [stop] open so a second stop can race the first.
  Duration stopDelay;

  int startCount = 0;
  int stopCount = 0;
  int cancelCount = 0;
  int disposeCount = 0;
  AudioFormat? lastFormat;
  bool _recording = false;
  var _epoch = 0;
  StreamController<double>? _levels;

  @override
  bool get isSupported => supported;

  @override
  bool get isRecording => _recording;

  @override
  Future<MicPermission> ensurePermission() async => permission;

  @override
  Future<MicPermission> requestOrOpenSettings() async =>
      requestOrOpenSettingsResult;

  @override
  Stream<double> get levels => _levels?.stream ?? const Stream<double>.empty();

  @override
  Future<void> start({AudioFormat format = .aacM4a}) async {
    if (!supported) {
      throw StateError('recorder unsupported');
    }
    if (_recording) {
      throw StateError('already recording');
    }
    final error = startError;
    if (error != null) throw error;
    final epoch = _epoch;
    if (startDelay > Duration.zero) {
      await Future<void>.delayed(startDelay);
    }
    // A dispose cancel may have landed while we waited.
    if (epoch != _epoch) return;
    startCount += 1;
    lastFormat = format;
    _recording = true;
    final levels = StreamController<double>.broadcast();
    _levels = levels;
    levelValues.forEach(levels.add);
  }

  @override
  Future<RecordedAudio?> stop() async {
    stopCount += 1;
    if (stopDelay > Duration.zero) {
      await Future<void>.delayed(stopDelay);
    }
    if (!_recording) {
      _closeLevels();
      return null;
    }
    _recording = false;
    _closeLevels();
    final clip = recorded;
    if (clip == null) return null;
    final format = lastFormat;
    if (format == null || clip.contentType == format.contentType) {
      return clip;
    }
    // Stamp the requested format, as the device service stamps the take's.
    return RecordedAudio(
      bytes: clip.bytes,
      durationMs: clip.durationMs,
      peaks: clip.peaks,
      contentType: format.contentType,
    );
  }

  @override
  Future<void> cancel() async {
    cancelCount += 1;
    _epoch += 1;
    _recording = false;
    _closeLevels();
  }

  /// Drop the level stream without awaiting [StreamController.close], which
  /// waits for listeners and deadlocks a caller that cancels after [stop].
  void _closeLevels() {
    final levels = _levels;
    _levels = null;
    if (levels != null && !levels.isClosed) {
      unawaited(levels.close());
    }
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
    await cancel();
  }
}

/// Scriptable one-at-a-time player for bundles 88 and 89.
class FakeAudioPlayerService implements AudioPlayerService {
  FakeAudioPlayerService();

  final _controller = StreamController<AudioPlayback>.broadcast();
  final playedIds = <String>[];
  final playBytesCalls = <Uint8List>[];
  String? currentId;
  int pauseCount = 0;
  int resumeCount = 0;
  int stopCount = 0;
  int disposeCount = 0;
  Duration position = Duration.zero;
  Duration duration = const Duration(seconds: 1);

  @override
  Stream<AudioPlayback> get playback => _controller.stream;

  @override
  Future<void> playBytes(Uint8List bytes, {required String id}) {
    playBytesCalls.add(bytes);
    return _play(id);
  }

  @override
  Future<void> playUrl(Uri url, {required String id}) => _play(id);

  Future<void> _play(String id) async {
    if (currentId != null && currentId != id) {
      _controller.add(
        AudioPlayback(
          id: currentId!,
          playing: false,
          position: Duration.zero,
          duration: duration,
          completed: false,
        ),
      );
    }
    currentId = id;
    playedIds.add(id);
    position = Duration.zero;
    _controller.add(
      AudioPlayback(
        id: id,
        playing: true,
        position: position,
        duration: duration,
        completed: false,
      ),
    );
  }

  /// Test hook: place the playhead without loading again.
  void seekTo(Duration at, {bool? playing}) {
    position = at;
    final id = currentId;
    if (id == null) return;
    final isPlaying = playing ?? false;
    _controller.add(
      AudioPlayback(
        id: id,
        playing: isPlaying,
        position: position,
        duration: duration,
        completed: false,
      ),
    );
  }

  @override
  Future<bool> resume(String id) async {
    if (currentId != id) return false;
    resumeCount += 1;
    _controller.add(
      AudioPlayback(
        id: id,
        playing: true,
        position: position,
        duration: duration,
        completed: false,
      ),
    );
    return true;
  }

  /// Emits a completed event for the current clip (tests drive this).
  void completeCurrent() {
    final id = currentId;
    if (id == null) return;
    _controller.add(
      AudioPlayback(
        id: id,
        playing: false,
        position: const Duration(seconds: 1),
        duration: const Duration(seconds: 1),
        completed: true,
      ),
    );
  }

  @override
  Future<void> pause() async {
    pauseCount += 1;
    final id = currentId;
    if (id == null) return;
    _controller.add(
      AudioPlayback(
        id: id,
        playing: false,
        position: position,
        duration: duration,
        completed: false,
      ),
    );
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    final id = currentId;
    currentId = null;
    if (id == null) return;
    _controller.add(
      AudioPlayback(
        id: id,
        playing: false,
        position: Duration.zero,
        duration: Duration.zero,
        completed: false,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
    await stop();
    await _controller.close();
  }
}

/// Tiny fixture for previews and uploads in tests.
RecordedAudio fakeRecordedAudio({
  int durationMs = 1500,
  int byteLength = 2048,
  List<int> peaks = const [10, 40, 70, 40, 10],
  String contentType = 'audio/mp4',
}) => RecordedAudio(
  bytes: Uint8List(byteLength),
  durationMs: durationMs,
  peaks: peaks,
  contentType: contentType,
);
