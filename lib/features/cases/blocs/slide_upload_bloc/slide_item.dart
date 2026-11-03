import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

enum SlideUploadStatus { picked, uploading, uploaded, failed }

/// One slide on the device, from pick to upload. [micronsPerPixel] is null
/// until the person sets it; nothing here ever supplies a default.
class SlideItem extends Equatable {
  const SlideItem({
    required this.localId,
    required this.fileName,
    required this.bytes,
    required this.contentType,
    this.micronsPerPixel,
    this.reservedImageUid,
    this.status = .picked,
    this.error,
  });

  final String localId;
  final String fileName;
  final Uint8List bytes;

  /// Sniffed from the bytes, never taken from the name or the picker's hint.
  final String contentType;
  final double? micronsPerPixel;

  /// Kept across a failed upload so a retry reuses the name.
  final String? reservedImageUid;
  final SlideUploadStatus status;
  final AppError? error;

  bool get hasValidPixelSize {
    final value = micronsPerPixel;
    return value != null && value.isFinite && value > 0 && value <= 100;
  }

  bool get isSettled => status == .uploading || status == .uploaded;

  SlideItem copyWith({
    double? micronsPerPixel,
    String? reservedImageUid,
    SlideUploadStatus? status,
    AppError? error,
    bool clearError = false,
  }) => SlideItem(
    localId: localId,
    fileName: fileName,
    bytes: bytes,
    contentType: contentType,
    micronsPerPixel: micronsPerPixel ?? this.micronsPerPixel,
    reservedImageUid: reservedImageUid ?? this.reservedImageUid,
    status: status ?? this.status,
    error: clearError ? null : error ?? this.error,
  );

  // Length, not the bytes: comparing 20 MB per emit would be wasted work and
  // the local id is already unique.
  @override
  List<Object?> get props => [
    localId,
    fileName,
    bytes.length,
    contentType,
    micronsPerPixel,
    reservedImageUid,
    status,
    error,
  ];
}
