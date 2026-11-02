import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/preread/data/models/preread_draft_model.dart';

part 'preread_model.freezed.dart';
part 'preread_model.g.dart';

/// An AI pre-read run. Read live, never cached (S-1).
@freezed
abstract class PrereadModel with _$PrereadModel {
  // Nested draft must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PrereadModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'profile') @Default('') String profile,
    @JsonKey(name: 'status') @Default('Queued') String status,
    @JsonKey(name: 'imagePaths') @Default(<String>[]) List<String> imagePaths,
    @JsonKey(name: 'micronsPerPixel') @Default(0) double micronsPerPixel,
    @JsonKey(name: 'segmentationPath') @Default('') String segmentationPath,
    @JsonKey(name: 'labelsPath') @Default('') String labelsPath,
    @JsonKey(name: 'labelCounts')
    @Default(<String, int>{})
    Map<String, int> labelCounts,
    @JsonKey(name: 'measurements')
    @Default(<String, double>{})
    Map<String, double> measurements,
    @JsonKey(name: 'draft')
    @Default(PrereadDraftModel())
    PrereadDraftModel draft,
    @JsonKey(name: 'models')
    @Default(<String, String>{})
    Map<String, String> models,
    @JsonKey(name: 'inputLanguage') @Default('') String inputLanguage,
    @JsonKey(name: 'failureReason') @Default('') String failureReason,
    @JsonKey(name: 'requestedAt') @Default('') String requestedAt,
    @JsonKey(name: 'startedAt') @Default('') String startedAt,
    @JsonKey(name: 'readyAt') @Default('') String readyAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
  }) = _PrereadModel;

  const PrereadModel._();

  factory PrereadModel.fromJson(Map<String, dynamic> json) =>
      _$PrereadModelFromJson(json);

  factory PrereadModel.empty() => const PrereadModel();

  PrereadProfile get profileValue => PrereadProfile.fromValue(profile);

  JobStatus get statusValue => JobStatus.fromValue(status);

  FailureReason get failureReasonValue =>
      FailureReason.fromValue(failureReason);

  /// True when the run is ready for the pathologist to score.
  bool get isReady => statusValue == JobStatus.ready;
}
