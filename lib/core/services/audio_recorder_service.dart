import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:tabibu/core/services/audio_peaks.dart';
import 'package:tabibu/core/services/audio_recorder_platform.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';

/// Production [AudioRecorderService]: AAC-LC `.m4a` for notes, PCM16 `.wav`
/// for symptom speech; auto-stop at the format's limit, null under 1 s or
/// over the format's byte cap, temp file always deleted.
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
  AudioFormat _format = .aacM4a;
  var _recording = false;
  var _stopping = false;

  /// Bumped by [cancel] and [stop] so a late [start] that outlives them does
  /// not mark itself recording or arm the limit timer with no owner.
  var _startGeneration = 0;

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
  Future<void> start({AudioFormat format = .aacM4a}) async {
    if (_recording) throw StateError('already recording');
    if (!isSupported) throw StateError('recorder unsupported');

    final generation = _startGeneration;
    final permission = await ensurePermission();
    if (generation != _startGeneration) return;
    if (permission != .granted) {
      throw StateError('microphone permission $permission');
    }

    _limitStopped = null;
    _levelSamples.clear();
    _format = format;
    final path = await _platform.createTempPath(format: format);
    if (generation != _startGeneration) {
      await _platform.delete(path);
      return;
    }
    _path = path;
    _startedAt = _clock();
    // Subscribe before start so the first amplitude burst is not dropped.
    await _levelSub?.cancel();
    _levelSub = _platform.levels.listen(_levelSamples.add);
    await _platform.start(path, format: format);
    // cancel()/stop() won the race during the platform start: drop the mic
    // and the file, and do not arm the limit timer.
    if (generation != _startGeneration) {
      await _abandonStart(path);
      return;
    }
    _recording = true;
    _maxTimer?.cancel();
    _maxTimer = _timerFactory(format.maxDuration, () {
      if (_recording && !_stopping) {
        _limitStopped = stop();
      }
    });
  }

  /// Tears down a start that finished after [cancel] or [stop] already ran.
  Future<void> _abandonStart(String path) async {
    await _levelSub?.cancel();
    _levelSub = null;
    if (_path == path) {
      _path = null;
      _startedAt = null;
    }
    try {
      await _platform.cancel();
    } on Object catch (_) {
      // Still delete the path we opened.
    }
    await _platform.delete(path);
  }

  @override
  Future<RecordedAudio?> stop() async {
    _startGeneration += 1;
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
    final format = _format;
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
      if (length <= 0 || length > format.maxBytes) {
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
        contentType: format.contentType,
      );
    } finally {
      _stopping = false;
      _levelSamples.clear();
    }
  }

  @override
  Future<void> cancel() async {
    _startGeneration += 1;
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
