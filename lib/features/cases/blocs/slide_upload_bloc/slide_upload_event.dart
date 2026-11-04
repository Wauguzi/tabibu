import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A file as the picker hands it over. [contentType] is only a hint: the bloc
/// reads the real type from the bytes.
class SlidePick extends Equatable {
  const SlidePick({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;

  @override
  List<Object?> get props => [bytes.length, fileName, contentType];
}

sealed class SlideUploadEvent extends Equatable {
  const SlideUploadEvent();

  @override
  List<Object?> get props => [];
}

final class SlidesPicked extends SlideUploadEvent {
  const SlidesPicked({required this.picks});

  final List<SlidePick> picks;

  @override
  List<Object?> get props => [picks];
}

/// Refused once the slide is uploading or uploaded.
final class SlideRemoved extends SlideUploadEvent {
  const SlideRemoved({required this.localId});

  final String localId;

  @override
  List<Object?> get props => [localId];
}

final class SlidePixelSizeSet extends SlideUploadEvent {
  const SlidePixelSizeSet({
    required this.localId,
    required this.micronsPerPixel,
  });

  final String localId;
  final double micronsPerPixel;

  @override
  List<Object?> get props => [localId, micronsPerPixel];
}

/// The size field was emptied or no longer holds a valid number: the slide
/// has no size again, so it cannot upload with one the person no longer sees.
final class SlidePixelSizeCleared extends SlideUploadEvent {
  const SlidePixelSizeCleared({required this.localId});

  final String localId;

  @override
  List<Object?> get props => [localId];
}

/// Reserve, upload, register. Needs the network; dropped while one runs.
final class SlideUploadRequested extends SlideUploadEvent {
  const SlideUploadRequested({required this.uid, required this.caseUid});

  final String uid;
  final String caseUid;

  @override
  List<Object?> get props => [uid, caseUid];
}

final class SlideUploadReset extends SlideUploadEvent {
  const SlideUploadReset();
}
