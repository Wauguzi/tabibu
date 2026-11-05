import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Writes queued voice notes under the app support directory (not temp) so an
/// offline note survives until upload; callers delete after a good upload or a
/// permanent refuse.
class VoicePendingStore {
  VoicePendingStore({this.supportRoot});

  /// Injected in tests; production uses [getApplicationSupportDirectory].
  final Directory? Function()? supportRoot;
  var _seq = 0;

  Future<Directory> _dir() async {
    final injected = supportRoot?.call();
    final base = injected ?? await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/voice_pending');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Persists [bytes] and returns the absolute path.
  Future<String> write(Uint8List bytes, {String extension = 'm4a'}) async {
    final dir = await _dir();
    _seq += 1;
    final path =
        '${dir.path}/voice_${DateTime.now().microsecondsSinceEpoch}_$_seq.$extension';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Best-effort delete; missing files are fine.
  Future<void> delete(String path) async {
    if (path.isEmpty) return;
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  /// Wipes every queued recording. Best effort for sign-out / account change.
  Future<void> clear() async {
    try {
      final injected = supportRoot?.call();
      final base = injected ?? await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/voice_pending');
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } on Object catch (_) {
      // Never block sign-out.
    }
  }
}
