import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_evidence_model.freezed.dart';
part 'alert_evidence_model.g.dart';

/// Detector evidence attached to a signal or alert (never cached).
@freezed
abstract class AlertEvidenceModel with _$AlertEvidenceModel {
  const factory AlertEvidenceModel({
    @JsonKey(name: 'confirmedCount') @Default(0) int confirmedCount,
    @JsonKey(name: 'baselineMean') @Default(0) double baselineMean,
    @JsonKey(name: 'baselineSd') @Default(0) double baselineSd,
    @JsonKey(name: 'threshold') @Default(0) double threshold,
    @JsonKey(name: 'floor') @Default(0) int floor,
    @JsonKey(name: 'windowWeeks') @Default(0) int windowWeeks,
    @JsonKey(name: 'multiplier') @Default(0) double multiplier,
    @JsonKey(name: 'ageBandCounts')
    @Default(<String, int>{})
    Map<String, int> ageBandCounts,
    @JsonKey(name: 'manualRequests') @Default(0) int manualRequests,
    @JsonKey(name: 'categoryVerified') @Default(false) bool categoryVerified,
    @JsonKey(name: 'mappingVerified') @Default(false) bool mappingVerified,
    @JsonKey(name: 'categorySourceId') @Default('') String categorySourceId,
    @JsonKey(name: 'weekStart') @Default('') String weekStart,
  }) = _AlertEvidenceModel;

  const AlertEvidenceModel._();

  factory AlertEvidenceModel.fromJson(Map<String, dynamic> json) =>
      _$AlertEvidenceModelFromJson(json);

  factory AlertEvidenceModel.empty() => const AlertEvidenceModel();
}
