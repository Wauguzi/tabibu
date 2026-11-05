import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';

/// Thin seam over `just_audio` for unit tests.
abstract class AudioPlayerPlatform {
  Stream<PlayerState> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  /// Fires when the OS interrupts playback (a call); the service pauses.
  Stream<void> get interruptionStream;
  Future<Duration?> setBytes(Uint8List bytes);
  Future<Duration?> setUrl(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();
}

class JustAudioPlayerPlatform implements AudioPlayerPlatform {
  JustAudioPlayerPlatform({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  final _interruptions = StreamController<void>.broadcast();
  String? _tempPath;

  /// Test hook: simulate a phone-call interruption.
  void signalInterruption() {
    if (!_interruptions.isClosed) _interruptions.add(null);
  }

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<void> get interruptionStream => _interruptions.stream;

  @override
  Future<Duration?> setBytes(Uint8List bytes) async {
    await _deleteTemp();
    // Web cannot write a temp file; a data URI loads in the browser player.
    if (kIsWeb) {
      return await _player.setAudioSource(
        AudioSource.uri(Uri.dataFromBytes(bytes, mimeType: 'audio/mp4')),
      );
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}${Platform.pathSeparator}'
        'tabibu_play_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await File(path).writeAsBytes(bytes, flush: true);
    _tempPath = path;
    return await _player.setFilePath(path);
  }

  /// Builds the web byte source without touching `dart:io` (unit-tested).
  static Uri webByteUri(Uint8List bytes, {String mimeType = 'audio/mp4'}) =>
      Uri.dataFromBytes(bytes, mimeType: mimeType);

  @override
  Future<Duration?> setUrl(String url) async {
    await _deleteTemp();
    return await _player.setUrl(url);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _deleteTemp();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _interruptions.close();
    await _player.dispose();
  }

  Future<void> _deleteTemp() async {
    final path = _tempPath;
    _tempPath = null;
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }
}

/// One logical player: starting a clip stops the previous and reports it idle.
@LazySingleton(as: AudioPlayerService)
class DeviceAudioPlayerService implements AudioPlayerService {
  DeviceAudioPlayerService({@ignoreParam AudioPlayerPlatform? platform})
    : _platform = platform ?? JustAudioPlayerPlatform() {
    _subs.add(
      _platform.playerStateStream.listen((state) {
        final id = _currentId;
        if (id == null) return;
        final completed = state.processingState == ProcessingState.completed;
        _emit(
          id: id,
          playing: state.playing && !completed,
          completed: completed,
        );
        if (completed) {
          unawaited(_platform.stop());
        }
      }),
    );
    _subs.add(
      _platform.positionStream.listen((position) {
        _position = position;
        final id = _currentId;
        if (id == null) return;
        _emit(id: id, playing: _playing, completed: false);
      }),
    );
    _subs.add(
      _platform.durationStream.listen((duration) {
        if (duration != null) _duration = duration;
      }),
    );
    _subs.add(
      _platform.interruptionStream.listen((_) {
        unawaited(pause());
      }),
    );
  }

  final AudioPlayerPlatform _platform;
  final StreamController<AudioPlayback> _controller =
      StreamController<AudioPlayback>.broadcast();
  final List<StreamSubscription<Object?>> _subs = [];

  String? _currentId;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  Stream<AudioPlayback> get playback => _controller.stream;

  @override
  Future<void> playBytes(Uint8List bytes, {required String id}) =>
      _play(id, () => _platform.setBytes(bytes));

  @override
  Future<void> playUrl(Uri url, {required String id}) =>
      _play(id, () => _platform.setUrl(url.toString()));

  Future<void> _play(String id, Future<Duration?> Function() load) async {
    final previous = _currentId;
    if (previous != null && previous != id) {
      _emit(id: previous, playing: false, completed: false);
    }
    await _platform.stop();
    _currentId = id;
    _position = Duration.zero;
    _duration = Duration.zero;
    final duration = await load();
    if (duration != null) _duration = duration;
    _playing = true;
    _emit(id: id, playing: true, completed: false);
    await _platform.play();
  }

  @override
  Future<bool> resume(String id) async {
    if (_currentId != id) return false;
    _playing = true;
    _emit(id: id, playing: true, completed: false);
    await _platform.play();
    return true;
  }

  @override
  Future<void> pause() async {
    await _platform.pause();
    _playing = false;
    final id = _currentId;
    if (id != null) {
      _emit(id: id, playing: false, completed: false);
    }
  }

  @override
  Future<void> stop() async {
    await _platform.stop();
    final id = _currentId;
    _playing = false;
    _position = Duration.zero;
    _currentId = null;
    if (id != null) {
      _emit(id: id, playing: false, completed: false);
    }
  }

  @override
  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    await stop();
    await _platform.dispose();
    await _controller.close();
  }

  void _emit({
    required String id,
    required bool playing,
    required bool completed,
  }) {
    if (_controller.isClosed) return;
    _playing = playing;
    _controller.add(
      AudioPlayback(
        id: id,
        playing: playing,
        position: _position,
        duration: _duration,
        completed: completed,
      ),
    );
  }
}
