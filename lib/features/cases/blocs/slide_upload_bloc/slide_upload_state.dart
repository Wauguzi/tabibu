import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_item.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';

/// Slides on the device and, once an upload has synced, the case as the
/// server now holds it. Nothing here is a slide's pixels or a pre-read.
sealed class SlideUploadState extends Equatable {
  const SlideUploadState({
    this.caseUid = '',
    this.slides = const <SlideItem>[],
    this.caseModel,
    this.offline = false,
  });

  final String caseUid;
  final List<SlideItem> slides;

  /// Set after the post-upload sync; null before.
  final CaseModel? caseModel;
  final bool offline;

  @override
  List<Object?> get props => [caseUid, slides, caseModel, offline];
}

final class SlideUploadInitial extends SlideUploadState {
  const SlideUploadInitial();
}

/// Slides picked, edited or removed; nothing sent yet.
final class SlideUploadEditing extends SlideUploadState {
  const SlideUploadEditing({
    super.caseUid,
    super.slides,
    super.caseModel,
    super.offline,
  });
}

final class SlideUploadInProgress extends SlideUploadState {
  const SlideUploadInProgress({
    super.caseUid,
    super.slides,
    super.caseModel,
    super.offline,
  });
}

/// Every slide sent in this request was registered and the case re-read.
/// A slide that failed on its own stays [SlideUploadStatus.failed] in
/// [slides].
final class SlideUploadSuccess extends SlideUploadState {
  const SlideUploadSuccess({
    super.caseUid,
    super.slides,
    super.caseModel,
    super.offline,
  });
}

final class SlideUploadFailure extends SlideUploadState {
  const SlideUploadFailure({
    required this.error,
    super.caseUid,
    super.slides,
    super.caseModel,
    super.offline,
  });

  final AppError error;

  @override
  List<Object?> get props => [...super.props, error];
}
