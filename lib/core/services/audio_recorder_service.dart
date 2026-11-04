import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:tabibu/core/services/audio_peaks.dart';
import 'package:tabibu/core/services/audio_recorder_platform.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';

/// Production [AudioRecorderService]: AAC-LC `.m4a`, auto-stop at 120 s,
/// null under 1 s or over 512 KB, temp file always deleted.
@LazySingleton(as: AudioRecorderService)
class DeviceAudioRecorderService implements AudioRecorderService {
  DeviceAudioRecorderService({
    @ignoreParam AudioRecorderPlatform? platform,
    @ignoreParam
    Timer Function(Duration duration, void Function() callback)? timerFactory,
    @ignoreParam DateTime Function()? clock,
  }) : _platform = platform ?? DeviceAudioRecorderPlatform(),
       _timerFactory = timerFactory ?? Timer.new,
       _clock = clock ?? DateTime.now;

  final AudioRecorderPlatform _platform;
  final Timer Function(Duration duration, void Function() callback)
  _timerFactory;
  final DateTime Function() _clock;

  final _levelSamples = <double>[];
  StreamSubscription<double>? _levelSub;
  Timer? _maxTimer;
  String? _path;
  DateTime? _startedAt;
  var _recording = false;
  var _stopping = false;

  /// The recording the length limit ended: the next [stop] hands it over, so
  /// a note that ran to the limit is not lost.
  Future<RecordedAudio?>? _limitStopped;

  @override
  bool get isSupported => _platform.isSupported;

  @override
  bool get isRecording => _recording;

  @override
  Stream<double> get levels => _platform.levels;

  @override
  Future<MicPermission> ensurePermission() => _platform.ensurePermission();

  @override
  Future<void> start() async {
    if (_recording) throw StateError('already recording');
    if (!isSupported) throw StateError('recorder unsupported');

    final permission = await ensurePermission();
    if (permission != .granted) {
      throw StateError('microphone permission $permission');
    }

    _limitStopped = null;
    _levelSamples.clear();
    _path = await _platform.createTempPath();
    _startedAt = _clock();
    // Subscribe before start so the first amplitude burst is not dropped.
    await _levelSub?.cancel();
    _levelSub = _platform.levels.listen(_levelSamples.add);
    await _platform.start(_path!);
    _recording = true;
    _maxTimer?.cancel();
    _maxTimer = _timerFactory(AudioRecorderService.maxDuration, () {
      if (_recording && !_stopping) {
        _limitStopped = stop();
      }
    });
  }

  @override
  Future<RecordedAudio?> stop() async {
    if (!_recording) {
      final held = _limitStopped;
      _limitStopped = null;
      return held == null ? null : await held;
    }
    if (_stopping) return null;
    _stopping = true;
    _maxTimer?.cancel();
    _maxTimer = null;
    await _levelSub?.cancel();
    _levelSub = null;

    final path = _path;
    final started = _startedAt;
    _path = null;
    _startedAt = null;
    _recording = false;

    String? stoppedPath;
    try {
      stoppedPath = await _platform.stop() ?? path;
    } on Object catch (_) {
      stoppedPath = path;
    }

    final durationMs = started == null
        ? 0
        : _clock().difference(started).inMilliseconds;

    if (stoppedPath == null) {
      _stopping = false;
      return null;
    }

    try {
      if (durationMs < 1000) {
        await _platform.delete(stoppedPath);
        return null;
      }
      final length = await _platform.byteLength(stoppedPath);
      if (length <= 0 || length > AudioRecorderService.maxBytes) {
        await _platform.delete(stoppedPath);
        return null;
      }
      final bytes = await _platform.readBytes(stoppedPath);
      await _platform.delete(stoppedPath);
      if (bytes == null || bytes.isEmpty) return null;
      return RecordedAudio(
        bytes: bytes,
        durationMs: durationMs,
        peaks: downsamplePeaks(_levelSamples),
      );
    } finally {
      _stopping = false;
      _levelSamples.clear();
    }
  }

  @override
  Future<void> cancel() async {
    _limitStopped = null;
    _maxTimer?.cancel();
    _maxTimer = null;
    await _levelSub?.cancel();
    _levelSub = null;
    final path = _path;
    _path = null;
    _startedAt = null;
    _recording = false;
    _stopping = false;
    _levelSamples.clear();
    try {
      await _platform.cancel();
    } on Object catch (_) {
      // Still delete whatever path we opened.
    }
    if (path != null) await _platform.delete(path);
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _platform.dispose();
  }
}
