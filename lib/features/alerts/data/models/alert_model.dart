import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_evidence_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

/// Working alert for approvers (`alerts/{uid}`); never cached.
@freezed
abstract class AlertModel with _$AlertModel {
  // Nested maps/evidence must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory AlertModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'signalUid') @Default('') String signalUid,
    @JsonKey(name: 'diseaseId') @Default('') String diseaseId,
    @JsonKey(name: 'countyId') @Default(0) int countyId,
    @JsonKey(name: 'countyName') @Default('') String countyName,
    @JsonKey(name: 'epiWeek') @Default('') String epiWeek,
    @JsonKey(name: 'category') @Default('') String category,
    @JsonKey(name: 'rule') @Default('') String rule,
    @JsonKey(name: 'status') @Default('Drafting') String status,
    @JsonKey(name: 'draftRevision') @Default(0) int draftRevision,
    @JsonKey(name: 'requestCount') @Default(0) int requestCount,
    @JsonKey(name: 'evidenceRevision') @Default(0) int evidenceRevision,
    @JsonKey(name: 'draftSource') @Default('Template') String draftSource,
    @JsonKey(name: 'machineText')
    @Default(<String, AlertTextModel>{})
    Map<String, AlertTextModel> machineText,
    @JsonKey(name: 'models')
    @Default(<String, String>{})
    Map<String, String> models,
    @JsonKey(name: 'failureReason') @Default('') String failureReason,
    @JsonKey(name: 'evidence')
    @Default(AlertEvidenceModel())
    AlertEvidenceModel evidence,
    @JsonKey(name: 'audience')
    @Default('CliniciansThenPatients')
    String audience,
    @JsonKey(name: 'decision') @Default('') String decision,
    @JsonKey(name: 'decidedByUid') @Default('') String decidedByUid,
    @JsonKey(name: 'decidedByName') @Default('') String decidedByName,
    @JsonKey(name: 'decidedAt') @Default('') String decidedAt,
    @JsonKey(name: 'rejectReason') @Default('') String rejectReason,
    @JsonKey(name: 'approvedText')
    @Default(<String, AlertTextModel>{})
    Map<String, AlertTextModel> approvedText,
    @JsonKey(name: 'approvedEvidence')
    @Default(AlertEvidenceModel())
    AlertEvidenceModel approvedEvidence,
    @JsonKey(name: 'acceptedUnchanged') @Default(false) bool acceptedUnchanged,
    @JsonKey(name: 'editedKeys') @Default(<String>[]) List<String> editedKeys,
    @JsonKey(name: 'editDistance') @Default(0) double editDistance,
    @JsonKey(name: 'evidenceRetracted') @Default(false) bool evidenceRetracted,
    @JsonKey(name: 'deliveredTo') @Default('') String deliveredTo,
    @JsonKey(name: 'deliveredAt') @Default('') String deliveredAt,
    @JsonKey(name: 'requestedAt') @Default('') String requestedAt,
    @JsonKey(name: 'draftedAt') @Default('') String draftedAt,
    @JsonKey(name: 'expiresAt') @Default('') String expiresAt,
    @JsonKey(name: 'reminderSentAt') @Default('') String reminderSentAt,
    @JsonKey(name: 'synthetic') @Default(false) bool synthetic,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
  }) = _AlertModel;

  const AlertModel._();

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);

  factory AlertModel.empty() => const AlertModel();

  ReportingCategory get categoryValue => ReportingCategory.fromValue(category);

  AlertRule get ruleValue => AlertRule.fromValue(rule);

  AlertStatus get statusValue => AlertStatus.fromValue(status);

  AlertDraftSource get draftSourceValue =>
      AlertDraftSource.fromValue(draftSource);

  FailureReason get failureReasonValue =>
      FailureReason.fromValue(failureReason);

  AlertAudience get audienceValue => AlertAudience.fromValue(audience);

  ApprovalDecision? get decisionValue =>
      decision.isEmpty ? null : ApprovalDecision.fromValue(decision);

  /// True when the draft is waiting for an approver.
  bool get isAwaitingDecision => statusValue == AlertStatus.draft;

  /// True when the alert has been approved or delivered.
  bool get isApprovedOrDelivered =>
      statusValue == AlertStatus.approved ||
      statusValue == AlertStatus.delivered;
}
