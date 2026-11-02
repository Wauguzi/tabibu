import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'case_log_entry_model.freezed.dart';
part 'case_log_entry_model.g.dart';

/// A `cases/{caseUid}/log/{seq}` document: one stage transition.
@freezed
abstract class CaseLogEntryModel with _$CaseLogEntryModel {
  const factory CaseLogEntryModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'seq') @Default(0) int seq,
    @JsonKey(name: 'fromLocation') @Default('') String fromLocation,
    @JsonKey(name: 'fromStage') @Default('') String fromStage,
    @JsonKey(name: 'fromStep') @Default('') String fromStep,
    @JsonKey(name: 'toLocation') @Default('') String toLocation,
    @JsonKey(name: 'toStage') @Default('') String toStage,
    @JsonKey(name: 'toStep') @Default('') String toStep,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'actorRole') @Default('System') String actorRole,
    @JsonKey(name: 'actionType') @Default('') String actionType,
    @JsonKey(name: 'actionReason') @Default('') String actionReason,
    @JsonKey(name: 'patientVisible') @Default(false) bool patientVisible,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _CaseLogEntryModel;

  const CaseLogEntryModel._();

  factory CaseLogEntryModel.fromJson(Map<String, dynamic> json) =>
      _$CaseLogEntryModelFromJson(json);

  factory CaseLogEntryModel.empty() => const CaseLogEntryModel();

  CaseLocation get fromLocationValue => CaseLocation.fromValue(fromLocation);

  CaseStage get fromStageValue => CaseStage.fromValue(fromStage);

  CaseStep get fromStepValue => CaseStep.fromValue(fromStep);

  CaseLocation get toLocationValue => CaseLocation.fromValue(toLocation);

  CaseStage get toStageValue => CaseStage.fromValue(toStage);

  CaseStep get toStepValue => CaseStep.fromValue(toStep);

  ActorRole get actorRoleValue => ActorRole.fromValue(actorRole);

  CaseAction get actionTypeValue => CaseAction.fromValue(actionType);
}
