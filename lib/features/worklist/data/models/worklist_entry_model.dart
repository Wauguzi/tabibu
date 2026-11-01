import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'worklist_entry_model.freezed.dart';
part 'worklist_entry_model.g.dart';

/// A pathologist desk row (`worklist/{caseUid}`).
@freezed
abstract class WorklistEntryModel with _$WorklistEntryModel {
  const factory WorklistEntryModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'pathologistUid') @Default('') String pathologistUid,
    @JsonKey(name: 'orderNumber') @Default('') String orderNumber,
    @JsonKey(name: 'testName') @Default('') String testName,
    @JsonKey(name: 'profile') @Default('None') String profile,
    @JsonKey(name: 'status') @Default('Open') String status,
    @JsonKey(name: 'prereadStatus') @Default('') String prereadStatus,
    @JsonKey(name: 'urgency') @Default('Routine') String urgency,
    @JsonKey(name: 'confidenceBand') @Default('Low') String confidenceBand,
    @JsonKey(name: 'confidence') @Default(0) double confidence,
    @JsonKey(name: 'riskFlag') @Default(false) bool riskFlag,
    @JsonKey(name: 'severity') @Default('Routine') String severity,
    @JsonKey(name: 'basePriority') @Default(0) int basePriority,
    @JsonKey(name: 'waitingSince') @Default('') String waitingSince,
    @JsonKey(name: 'assignedAt') @Default('') String assignedAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _WorklistEntryModel;

  const WorklistEntryModel._();

  factory WorklistEntryModel.fromJson(Map<String, dynamic> json) =>
      _$WorklistEntryModelFromJson(json);

  factory WorklistEntryModel.empty() => const WorklistEntryModel();

  PrereadProfile get profileValue => PrereadProfile.fromValue(profile);

  WorklistStatus get statusValue => WorklistStatus.fromValue(status);

  JobStatus? get prereadStatusValue =>
      prereadStatus.isEmpty ? null : JobStatus.fromValue(prereadStatus);

  Urgency get urgencyValue => Urgency.fromValue(urgency);

  ConfidenceBand get confidenceBandValue =>
      ConfidenceBand.fromValue(confidenceBand);

  Urgency get severityValue => Urgency.fromValue(severity);

  /// True when the entry is still on the pathologist's desk.
  bool get isOpen =>
      statusValue == WorklistStatus.open ||
      statusValue == WorklistStatus.inProgress;
}
