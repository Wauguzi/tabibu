import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Resolves Storage paths for AI pre-read slide images. A missing or
/// unreachable object returns null so the workspace can keep going.
@lazySingleton
class PrereadStorage {
  PrereadStorage({required this._storage});

  final FirebaseStorage _storage;
  final Logger _logger = Logger();

  Future<String?> downloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } on Object catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('Preread download URL failed [$e]', stackTrace: stackTrace);
      }
      return null;
    }
  }
}
