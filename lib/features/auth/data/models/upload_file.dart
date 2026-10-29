import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A file the person picked, held in memory until sign-up uploads it.
class UploadFile extends Equatable {
  const UploadFile({
    required this.bytes,
    required this.contentType,
    this.name = '',
  });

  final Uint8List bytes;

  /// `image/jpeg`, `image/png` or `application/pdf`; the Storage rules check
  /// it again.
  final String contentType;

  /// As picked, for the document tile; never used as the stored name.
  final String name;

  bool get isImage => contentType.startsWith('image/');
  bool get isPdf => contentType == 'application/pdf';

  /// The only types `storage.rules` takes, each under its own extension.
  bool get isUploadableImage =>
      contentType == 'image/jpeg' || contentType == 'image/png';

  String get extension => switch (contentType) {
    'application/pdf' => 'pdf',
    'image/png' => 'png',
    _ => 'jpg',
  };

  @override
  List<Object?> get props => [bytes, contentType, name];
}
