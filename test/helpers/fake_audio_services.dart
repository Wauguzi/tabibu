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
    this.stopDelay = Duration.zero,
  });

  bool supported;
  MicPermission permission;
  RecordedAudio? recorded;
  List<double> levelValues;

  /// When set, [start] throws this instead of opening the mic.
  Error? startError;

  /// Holds [stop] open so a second stop can race the first.
  Duration stopDelay;

  int startCount = 0;
  int stopCount = 0;
  int cancelCount = 0;
  int disposeCount = 0;
  bool _recording = false;
  StreamController<double>? _levels;

  @override
  bool get isSupported => supported;

  @override
  bool get isRecording => _recording;

  @override
  Future<MicPermission> ensurePermission() async => permission;

  @override
  Stream<double> get levels => _levels?.stream ?? const Stream<double>.empty();

  @override
  Future<void> start() async {
    if (!supported) {
      throw StateError('recorder unsupported');
    }
    if (_recording) {
      throw StateError('already recording');
    }
    final error = startError;
    if (error != null) throw error;
    startCount += 1;
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
    return recorded;
  }

  @override
  Future<void> cancel() async {
    cancelCount += 1;
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
  String? currentId;
  int pauseCount = 0;
  int stopCount = 0;
  int disposeCount = 0;

  @override
  Stream<AudioPlayback> get playback => _controller.stream;

  @override
  Future<void> playBytes(Uint8List bytes, {required String id}) => _play(id);

  @override
  Future<void> playUrl(Uri url, {required String id}) => _play(id);

  Future<void> _play(String id) async {
    if (currentId != null && currentId != id) {
      _controller.add(
        AudioPlayback(
          id: currentId!,
          playing: false,
          position: Duration.zero,
          duration: const Duration(seconds: 1),
          completed: false,
        ),
      );
    }
    currentId = id;
    playedIds.add(id);
    _controller.add(
      AudioPlayback(
        id: id,
        playing: true,
        position: Duration.zero,
        duration: const Duration(seconds: 1),
        completed: false,
      ),
    );
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
        position: Duration.zero,
        duration: const Duration(seconds: 1),
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

/// Tiny AAC-shaped fixture for previews and uploads in tests.
RecordedAudio fakeRecordedAudio({
  int durationMs = 1500,
  int byteLength = 2048,
  List<int> peaks = const [10, 40, 70, 40, 10],
}) => RecordedAudio(
  bytes: Uint8List(byteLength),
  durationMs: durationMs,
  peaks: peaks,
);
