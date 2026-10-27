import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A file the person picked, held in memory until sign-up uploads it.
class UploadFile extends Equatable {
  const UploadFile({required this.bytes, required this.contentType});

  final Uint8List bytes;

  /// `image/jpeg`, `image/png` or `application/pdf`; the Storage rules check
  /// it again.
  final String contentType;

  bool get isImage => contentType.startsWith('image/');
  bool get isPdf => contentType == 'application/pdf';

  String get extension => switch (contentType) {
    'application/pdf' => 'pdf',
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/heic' => 'heic',
    _ => 'jpg',
  };

  @override
  List<Object?> get props => [bytes, contentType];
}
