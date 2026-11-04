import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:vibration/vibration.dart';

/// Short vibration + beep so the user knows the mic opened or closed.
abstract class RecordingCueService {
  /// Play before the recorder starts so the beep is not captured.
  Future<void> started();

  /// Play after the recorder has stopped and returned its clip.
  Future<void> finished();
}

typedef CueVibrator = Future<void> Function();
typedef CueAssetLoader = Future<Uint8List> Function(String asset);
typedef CueQuietCheck = bool Function();

@LazySingleton(as: RecordingCueService)
class DeviceRecordingCueService implements RecordingCueService {
  DeviceRecordingCueService(
    this._player, {
    @ignoreParam CueVibrator? vibrate,
    @ignoreParam CueAssetLoader? loadAsset,
    @ignoreParam CueQuietCheck? cuesDisabled,
  }) : _vibrate = vibrate ?? _platformVibrate,
       _loadAsset = loadAsset ?? _bundleLoad,
       _cuesDisabled = cuesDisabled ?? _platformQuiet;

  /// Generated paths, so a sound rename breaks the build instead of
  /// failing silently at runtime. Loaded through the bundle (full path),
  /// not `AssetSource`, so no prefix is stripped.
  static String get startAsset => Assets.sounds.recordStart;
  static String get stopAsset => Assets.sounds.recordStop;
  static const cueId = 'recording-cue';
  static const beepHold = Duration(milliseconds: 120);
  static const vibrateMs = 40;

  final AudioPlayerService _player;
  final CueVibrator _vibrate;
  final CueAssetLoader _loadAsset;
  final CueQuietCheck _cuesDisabled;

  @override
  Future<void> started() => _cue(startAsset);

  @override
  Future<void> finished() => _cue(stopAsset);

  Future<void> _cue(String asset) async {
    if (_cuesDisabled()) return;
    // Vibration may overlap the beep; neither failure blocks recording.
    unawaited(_safeVibrate());
    await _safeBeep(asset);
  }

  Future<void> _safeVibrate() async {
    try {
      await _vibrate();
    } on Object catch (_) {
      // Best-effort.
    }
  }

  Future<void> _safeBeep(String asset) async {
    try {
      final bytes = await _loadAsset(asset);
      await _player.playBytes(bytes, id: cueId);
      await Future<void>.delayed(beepHold);
      await _player.stop();
    } on Object catch (_) {
      // Best-effort; recording proceeds either way.
    }
  }

  static Future<void> _platformVibrate() async {
    if (kIsWeb) return;
    if (!await Vibration.hasVibrator()) return;
    await Vibration.vibrate(duration: vibrateMs);
  }

  static Future<Uint8List> _bundleLoad(String asset) async {
    final data = await rootBundle.load(asset);
    return data.buffer.asUint8List();
  }

  /// Flutter exposes reduce-motion / disable-animations; there is no simple
  /// "no sounds" accessibility flag, so quiet means motion-reduced only.
  static bool _platformQuiet() {
    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    return features.disableAnimations || features.reduceMotion;
  }
}
