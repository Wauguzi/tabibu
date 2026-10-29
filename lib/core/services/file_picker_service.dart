import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/auth/data/datasources/profile_storage.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';

/// Picks the files sign-up uploads, as bytes, so one path serves mobile and
/// the web demo (where a picked file has no path). Null means the person
/// cancelled; a file over the Storage limit is refused before it is read.
@lazySingleton
class FilePickerService {
  FilePickerService({@ignoreParam ImagePicker? imagePicker})
    : _images = imagePicker ?? ImagePicker();

  final ImagePicker _images;

  /// Resized on the device, so a camera photo lands well under the 3 MB
  /// profile-picture limit.
  static const double photoMaxSide = 1024;
  static const int photoQuality = 85;
  static const licenceExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  Future<UploadFile?> pickPhoto({required bool fromCamera}) async {
    final XFile? picked;
    try {
      picked = await _images.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: photoMaxSide,
        maxHeight: photoMaxSide,
        imageQuality: photoQuality,
        requestFullMetadata: false,
      );
    } on PlatformException catch (_) {
      // Camera or photo access refused in system settings.
      throw AppError.permissionDenied;
    }
    if (picked == null) return null;
    // With imageQuality set, the picker re-encodes to JPEG on a phone; the
    // web hands the original back, which the Storage rules take only as JPEG
    // or PNG.
    final mimeType = picked.mimeType;
    final contentType =
        contentTypeFor(picked.name, mimeType) ??
        (mimeType == null || mimeType.isEmpty ? 'image/jpeg' : null);
    if (contentType == null ||
        (contentType != 'image/jpeg' && contentType != 'image/png')) {
      throw AppError.invalidPicture;
    }
    final bytes = await picked.readAsBytes();
    if (bytes.length >= ProfileStorage.maxPictureBytes) {
      throw AppError.fileTooLarge;
    }
    return UploadFile(
      bytes: bytes,
      contentType: contentType,
      name: picked.name,
    );
  }

  /// A practising licence or certificate: PDF, JPG or PNG.
  Future<UploadFile?> pickLicence() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: licenceExtensions,
    );
    if (file == null) return null;
    return await licenceFrom(
      name: file.name,
      size: file.lengthSync() ?? await file.length() ?? 0,
      readBytes: file.readAsBytes,
    );
  }

  /// The checks on a picked licence, before its bytes are read.
  @visibleForTesting
  static Future<UploadFile> licenceFrom({
    required String name,
    required int size,
    required Future<Uint8List> Function() readBytes,
  }) async {
    if (size >= ProfileStorage.maxLicenseBytes) throw AppError.fileTooLarge;
    final contentType = contentTypeFor(name, null);
    if (contentType == null) throw AppError.invalidLicense;
    return UploadFile(
      bytes: await readBytes(),
      contentType: contentType,
      name: name,
    );
  }

  /// From the picker's MIME type when it gives one, else the extension. Null
  /// for anything the Storage rules would refuse: they take JPEG, PNG and PDF.
  static String? contentTypeFor(String name, String? mimeType) {
    final type = mimeType != null && mimeType.isNotEmpty
        ? mimeType.toLowerCase()
        : switch (name.split('.').last.toLowerCase()) {
            'pdf' => 'application/pdf',
            'png' => 'image/png',
            'jpg' || 'jpeg' => 'image/jpeg',
            _ => null,
          };
    return switch (type) {
      'image/jpeg' || 'image/jpg' => 'image/jpeg',
      'image/png' => 'image/png',
      'application/pdf' => 'application/pdf',
      _ => null,
    };
  }
}

/// `2.1 MB`, as the document tile shows it.
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB'];
  var size = bytes / 1024;
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  return '${size.toStringAsFixed(1)} ${units[unit]}';
}
