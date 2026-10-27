import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';

/// Uploads into the caller's own Storage folders (architecture §6.1). The
/// limits mirror `storage.rules`, so an oversized file is refused here with a
/// clear message instead of as a permission error.
@lazySingleton
class ProfileStorage {
  ProfileStorage({FirebaseStorage? storage})
    : _storage = storage ?? getIt<FirebaseStorage>();

  final FirebaseStorage _storage;
  final Logger _logger = Logger();

  static const int maxPictureBytes = 3 * 1024 * 1024;
  static const int maxLicenseBytes = 10 * 1024 * 1024;

  /// One fixed name per owner, so a retried upload replaces the last one.
  Future<String> uploadProfilePicture({
    required String owner,
    required UploadFile file,
  }) {
    if (!file.isImage) throw AppError.invalidPicture;
    if (file.bytes.length >= maxPictureBytes) throw AppError.fileTooLarge;
    return _put('profilePictures/$owner/photo.${file.extension}', file);
  }

  /// [index] is 0 or 1: the practising license, then an optional second file.
  Future<String> uploadLicense({
    required String uid,
    required int index,
    required UploadFile file,
  }) {
    if (index < 0 || index > 1) throw AppError.invalidLicense;
    if (!file.isImage && !file.isPdf) throw AppError.invalidLicense;
    if (file.bytes.length >= maxLicenseBytes) throw AppError.fileTooLarge;
    return _put('licenses/$uid/license_${index + 1}.${file.extension}', file);
  }

  Future<String> _put(String path, UploadFile file) async {
    try {
      final ref = _storage.ref(path);
      await ref.putData(
        file.bytes,
        SettableMetadata(contentType: file.contentType),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (kDebugMode) _logger.e('Upload failed [${e.code}]');
      throw AppError.fromFirebaseCode(e.code);
    }
  }
}
