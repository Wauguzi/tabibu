import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';

/// Puts slide bytes at `slides/{caseUid}/{imageUid}.jpg|png`. The limits
/// mirror `storage.rules`, so a bad file is refused here, before any bytes
/// leave the device.
@lazySingleton
class SlideStorage {
  SlideStorage({required this._storage});

  final FirebaseStorage _storage;
  final Logger _logger = Logger();

  static const int maxSlideBytes = 20 * 1024 * 1024;
  static const String jpeg = 'image/jpeg';
  static const String png = 'image/png';

  AppError _toAppError(Object e) => switch (e) {
    AppError() => e,
    FirebaseException(:final code) => AppError.fromFirebaseCode(code),
    _ => AppError.unknown,
  };

  /// The extension follows the content type, as the Storage rules bind them.
  static String? extensionFor(String contentType) => switch (contentType) {
    jpeg => 'jpg',
    png => 'png',
    _ => null,
  };

  Future<void> uploadSlide({
    required String caseUid,
    required String imageUid,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final extension = extensionFor(contentType);
    if (extension == null) throw AppError.invalidSlides;
    if (bytes.isEmpty) throw AppError.invalidSlides;
    if (bytes.length > maxSlideBytes) throw AppError.fileTooLarge;
    try {
      await _storage
          .ref('slides/$caseUid/$imageUid.$extension')
          .putData(bytes, SettableMetadata(contentType: contentType));
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('Upload slide failed: $e', stackTrace: stackTrace);
      }
      throw _toAppError(e);
    }
  }
}
