import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'preread_score_model.freezed.dart';
part 'preread_score_model.g.dart';

/// A pathologist's score of an AI pre-read (`prereadScores/{runUid}`).
@freezed
abstract class PrereadScoreModel with _$PrereadScoreModel {
  const factory PrereadScoreModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'runUid') @Default('') String runUid,
    @JsonKey(name: 'pathologistUid') @Default('') String pathologistUid,
    @JsonKey(name: 'profile') @Default('None') String profile,
    @JsonKey(name: 'confidenceBand') @Default('Low') String confidenceBand,
    @JsonKey(name: 'urgency') @Default('Routine') String urgency,
    @JsonKey(name: 'overall') @Default(0) int overall,
    @JsonKey(name: 'findingsVerdict') @Default('Agree') String findingsVerdict,
    @JsonKey(name: 'impressionVerdict')
    @Default('Agree')
    String impressionVerdict,
    @JsonKey(name: 'measurementsVerdict')
    @Default('NotApplicable')
    String measurementsVerdict,
    @JsonKey(name: 'segmentationVerdict')
    @Default('NotApplicable')
    String segmentationVerdict,
    @JsonKey(name: 'urgencyVerdict') @Default('Agree') String urgencyVerdict,
    @JsonKey(name: 'comment') @Default('') String comment,
    @JsonKey(name: 'prereadShownAt') @Default('') String prereadShownAt,
    @JsonKey(name: 'acceptedUnchanged') @Default(false) bool acceptedUnchanged,
    @JsonKey(name: 'scoredAt') @Default('') String scoredAt,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _PrereadScoreModel;

  const PrereadScoreModel._();

  factory PrereadScoreModel.fromJson(Map<String, dynamic> json) =>
      _$PrereadScoreModelFromJson(json);

  factory PrereadScoreModel.empty() => const PrereadScoreModel();

  PrereadProfile get profileValue => PrereadProfile.fromValue(profile);

  ConfidenceBand get confidenceBandValue =>
      ConfidenceBand.fromValue(confidenceBand);

  Urgency get urgencyValue => Urgency.fromValue(urgency);

  ScoreVerdict get findingsVerdictValue =>
      ScoreVerdict.fromValue(findingsVerdict);

  ScoreVerdict get impressionVerdictValue =>
      ScoreVerdict.fromValue(impressionVerdict);

  MeasurementsVerdict get measurementsVerdictValue =>
      MeasurementsVerdict.fromValue(measurementsVerdict);

  SegmentationVerdict get segmentationVerdictValue =>
      SegmentationVerdict.fromValue(segmentationVerdict);

  ScoreVerdict get urgencyVerdictValue =>
      ScoreVerdict.fromValue(urgencyVerdict);

  /// True when every verdict is Agree, or NotApplicable for measurement and
  /// segmentation.
  bool get computesAcceptedUnchanged =>
      findingsVerdictValue == ScoreVerdict.agree &&
      impressionVerdictValue == ScoreVerdict.agree &&
      urgencyVerdictValue == ScoreVerdict.agree &&
      (measurementsVerdictValue == MeasurementsVerdict.accepted ||
          measurementsVerdictValue == MeasurementsVerdict.notApplicable) &&
      (segmentationVerdictValue == SegmentationVerdict.good ||
          segmentationVerdictValue == SegmentationVerdict.notApplicable);
}
