import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';

/// Thin seam over the `record` package so the service logic is unit-testable.
abstract class AudioRecorderPlatform {
  bool get isSupported;

  Future<MicPermission> ensurePermission();

  /// Asks for the mic when the OS can still show its dialog; opens app
  /// settings when permanently denied. Returns the outcome.
  Future<MicPermission> requestOrOpenSettings();

  Future<String> createTempPath({required AudioFormat format});

  Future<void> start(String path, {required AudioFormat format});

  /// 0..1 while recording.
  Stream<double> get levels;

  Future<String?> stop();

  Future<void> cancel();

  Future<Uint8List?> readBytes(String path);

  Future<int> byteLength(String path);

  Future<void> delete(String path);

  Future<void> dispose();
}

/// Device-backed recorder: AAC-LC mono at 16 kHz / 32 kbps (≈ 240 KB/min),
/// or PCM16 mono at 16 kHz for symptom speech.
class DeviceAudioRecorderPlatform implements AudioRecorderPlatform {
  DeviceAudioRecorderPlatform({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<Amplitude>? _ampSub;
  final _levels = StreamController<double>.broadcast();

  /// AAC-LC, mono, 16 kHz, 32 kbps — one minute stays well under 512 KB.
  static const config = RecordConfig(
    bitRate: 32000,
    sampleRate: 16000,
    numChannels: 1,
  );

  /// PCM16 with headers, mono, 16 kHz — what the speech API takes.
  static const wavConfig = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
  );

  @override
  bool get isSupported => !kIsWeb;

  @override
  Future<MicPermission> ensurePermission() async {
    if (kIsWeb) return .unsupported;
    final status = await Permission.microphone.request();
    if (status.isGranted) return .granted;
    if (status.isPermanentlyDenied) return .permanentlyDenied;
    if (status.isDenied) return .denied;
    // Restricted / limited / provisional: treat as denied for the mic path.
    return .denied;
  }

  @override
  Future<MicPermission> requestOrOpenSettings() async {
    if (kIsWeb) return .unsupported;
    final status = await Permission.microphone.status;
    if (status.isGranted) return .granted;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      // iOS denies permanently on the first refusal.
      if (result.isGranted) return .granted;
      if (!result.isPermanentlyDenied) return .denied;
    }
    await openAppSettings();
    return .permanentlyDenied;
  }

  @override
  Future<String> createTempPath({required AudioFormat format}) async {
    final dir = await getTemporaryDirectory();
    final ext = format == .wav16k ? 'wav' : 'm4a';
    final name = 'tabibu_voice_${DateTime.now().microsecondsSinceEpoch}.$ext';
    return '${dir.path}${Platform.pathSeparator}$name';
  }

  @override
  Future<void> start(String path, {required AudioFormat format}) async {
    await _ampSub?.cancel();
    await _recorder.start(format == .wav16k ? wavConfig : config, path: path);
    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
          // `current` is dBFS (≤ 0). Map a quiet-to-loud window into 0..1.
          final db = amp.current;
          final linear = math.pow(10, db / 20).toDouble().clamp(0.0, 1.0);
          if (!_levels.isClosed) _levels.add(linear);
        });
  }

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<String?> stop() {
    unawaited(_ampSub?.cancel());
    _ampSub = null;
    return _recorder.stop();
  }

  @override
  Future<void> cancel() async {
    await _ampSub?.cancel();
    _ampSub = null;
    await _recorder.cancel();
  }

  @override
  Future<Uint8List?> readBytes(String path) {
    final file = File(path);
    if (!file.existsSync()) return Future<Uint8List?>.value();
    return file.readAsBytes();
  }

  @override
  Future<int> byteLength(String path) {
    final file = File(path);
    if (!file.existsSync()) return Future<int>.value(0);
    return file.length();
  }

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }

  @override
  Future<void> dispose() async {
    await _ampSub?.cancel();
    _ampSub = null;
    await _levels.close();
    await _recorder.dispose();
  }
}
