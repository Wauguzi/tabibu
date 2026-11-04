import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/services/audio_recorder_platform.dart';
import 'package:tabibu/core/services/audio_recorder_service.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';

class _FakePlatform implements AudioRecorderPlatform {
  bool supported = true;
  MicPermission permission = MicPermission.granted;
  List<int> bytes = const [1, 2, 3, 4];
  int? byteCapOverride;

  final deleted = <String>[];
  final _levels = StreamController<double>.broadcast();
  int pathCount = 0;
  String? activePath;
  AudioFormat? lastFormat;
  bool started = false;
  bool cancelled = false;
  bool disposed = false;

  @override
  bool get isSupported => supported;

  @override
  Future<MicPermission> ensurePermission() async => permission;

  @override
  Future<String> createTempPath({required AudioFormat format}) async {
    pathCount += 1;
    final ext = format == .wav16k ? 'wav' : 'm4a';
    activePath = 'tmp/voice_$pathCount.$ext';
    return activePath!;
  }

  @override
  Future<void> start(String path, {required AudioFormat format}) async {
    started = true;
    activePath = path;
    lastFormat = format;
    _levels
      ..add(0.25)
      ..add(0.75);
  }

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<String?> stop() async {
    started = false;
    return activePath;
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
    started = false;
  }

  @override
  Future<Uint8List?> readBytes(String path) async => Uint8List.fromList(bytes);

  @override
  Future<int> byteLength(String path) async => byteCapOverride ?? bytes.length;

  @override
  Future<void> delete(String path) async {
    deleted.add(path);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _levels.close();
  }
}

class _ControllableTimer implements Timer {
  _ControllableTimer(this.callback);

  final void Function() callback;
  bool cancelled = false;

  @override
  void cancel() => cancelled = true;

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;

  void fire() {
    if (!cancelled) callback();
  }
}

void main() {
  late _FakePlatform platform;
  late DateTime now;
  _ControllableTimer? pending;

  DeviceAudioRecorderService build() => DeviceAudioRecorderService(
    platform: platform,
    clock: () => now,
    timerFactory: (duration, callback) {
      pending = _ControllableTimer(callback);
      return pending!;
    },
  );

  setUp(() {
    platform = _FakePlatform();
    now = DateTime.utc(2026, 1, 1, 12);
    pending = null;
  });

  group('permission', () {
    test('maps each MicPermission result through', () async {
      for (final value in MicPermission.values) {
        platform.permission = value;
        expect(await build().ensurePermission(), value);
      }
    });
  });

  group('support', () {
    test('reports unsupported on the web adapter', () {
      platform.supported = false;
      expect(build().isSupported, isFalse);
    });
  });

  group('start/stop', () {
    test('returns canned shape with peaks 0..100', () async {
      final service = build();
      await service.start();
      now = now.add(const Duration(seconds: 2));
      final clip = await service.stop();
      expect(clip, isNotNull);
      expect(clip!.durationMs, 2000);
      expect(clip.contentType, 'audio/mp4');
      expect(clip.bytes, isNotEmpty);
      expect(clip.peaks, isNotEmpty);
      expect(clip.peaks.every((p) => p >= 0 && p <= 100), isTrue);
      expect(platform.deleted, contains(platform.activePath));
    });

    test('under 1 s is null and deletes the file', () async {
      final service = build();
      await service.start();
      now = now.add(const Duration(milliseconds: 500));
      expect(await service.stop(), isNull);
      expect(platform.deleted, isNotEmpty);
    });

    test('over the byte cap is null and deletes the file', () async {
      platform.byteCapOverride = AudioRecorderService.maxBytes + 1;
      final service = build();
      await service.start();
      now = now.add(const Duration(seconds: 2));
      expect(await service.stop(), isNull);
      expect(platform.deleted, isNotEmpty);
    });

    test('second start while recording throws', () async {
      final service = build();
      await service.start();
      expect(service.start, throwsStateError);
    });

    test('auto-stop at 120 s via the fake clock timer', () async {
      final service = build();
      await service.start();
      now = now.add(AudioRecorderService.maxDuration);
      pending!.fire();
      await Future<void>.delayed(Duration.zero);
      expect(service.isRecording, isFalse);
      expect(platform.deleted, isNotEmpty);
    });

    test(
      'a recording ended by the limit is handed over by the next stop',
      () async {
        final service = build();
        await service.start();
        now = now.add(AudioRecorderService.maxDuration);
        pending!.fire();
        await Future<void>.delayed(Duration.zero);

        final audio = await service.stop();
        expect(audio, isNotNull);
        expect(
          audio!.durationMs,
          AudioRecorderService.maxDuration.inMilliseconds,
        );
        // Handed over once.
        expect(await service.stop(), isNull);
      },
    );
  });

  group('wav16k', () {
    test(
      'a WAV take opens WAV, stamps audio/wav and deletes the file',
      () async {
        final service = build();
        await service.start(format: .wav16k);
        expect(platform.lastFormat, AudioFormat.wav16k);
        expect(platform.activePath, endsWith('.wav'));
        now = now.add(const Duration(seconds: 2));
        final clip = await service.stop();
        expect(clip, isNotNull);
        expect(clip!.contentType, 'audio/wav');
        expect(clip.durationMs, 2000);
        expect(platform.deleted, contains(platform.activePath));
      },
    );

    test('an AAC take still opens AAC and stamps audio/mp4', () async {
      final service = build();
      await service.start();
      expect(platform.lastFormat, AudioFormat.aacM4a);
      expect(platform.activePath, endsWith('.m4a'));
      now = now.add(const Duration(seconds: 2));
      final clip = await service.stop();
      expect(clip!.contentType, 'audio/mp4');
    });

    test(
      'a WAV take over 1,572,864 bytes is null and deletes the file',
      () async {
        platform.byteCapOverride = 1572864 + 1;
        final service = build();
        await service.start(format: .wav16k);
        now = now.add(const Duration(seconds: 2));
        expect(await service.stop(), isNull);
        expect(platform.deleted, isNotEmpty);
      },
    );

    test('a WAV take at exactly the cap is kept', () async {
      platform.byteCapOverride = 1572864;
      final service = build();
      await service.start(format: .wav16k);
      now = now.add(const Duration(seconds: 2));
      expect(await service.stop(), isNotNull);
    });

    test('auto-stop fires at 45 s for WAV and 120 s for AAC', () async {
      final durations = <Duration>[];
      DeviceAudioRecorderService timed() => DeviceAudioRecorderService(
        platform: platform,
        clock: () => now,
        timerFactory: (duration, callback) {
          durations.add(duration);
          pending = _ControllableTimer(callback);
          return pending!;
        },
      );
      final service = timed();
      await service.start(format: .wav16k);
      await service.cancel();
      await service.start();
      expect(durations, [
        const Duration(seconds: 45),
        const Duration(seconds: 120),
      ]);
    });

    test('under 1 s of WAV is null and deletes the file', () async {
      final service = build();
      await service.start(format: .wav16k);
      now = now.add(const Duration(milliseconds: 500));
      expect(await service.stop(), isNull);
      expect(platform.deleted, isNotEmpty);
    });
  });

  group('cancel and dispose', () {
    test('cancel deletes the file', () async {
      final service = build();
      await service.start();
      final path = platform.activePath;
      await service.cancel();
      expect(platform.cancelled, isTrue);
      expect(platform.deleted, contains(path));
      expect(service.isRecording, isFalse);
    });

    test('dispose deletes and tears the platform down', () async {
      final service = build();
      await service.start();
      await service.dispose();
      expect(platform.disposed, isTrue);
      expect(platform.deleted, isNotEmpty);
    });
  });
}
