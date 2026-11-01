import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'risk_check_model.freezed.dart';
part 'risk_check_model.g.dart';

/// A `riskCheck/current` document: the order's risk screening.
@freezed
abstract class RiskCheckModel with _$RiskCheckModel {
  const factory RiskCheckModel({
    @JsonKey(name: 'uid') @Default('current') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'status') @Default('Queued') String status,
    @JsonKey(name: 'inputLanguage') @Default('') String inputLanguage,
    @JsonKey(name: 'suggestedLabTestIds')
    @Default(<String>[])
    List<String> suggestedLabTestIds,
    @JsonKey(name: 'advisoryKey') @Default('') String advisoryKey,
    @JsonKey(name: 'advisoryEn') @Default('') String advisoryEn,
    @JsonKey(name: 'advisorySw') @Default('') String advisorySw,
    @JsonKey(name: 'models')
    @Default(<String, String>{})
    Map<String, String> models,
    @JsonKey(name: 'failureReason') @Default('') String failureReason,
    @JsonKey(name: 'requestedAt') @Default('') String requestedAt,
    @JsonKey(name: 'readyAt') @Default('') String readyAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _RiskCheckModel;

  const RiskCheckModel._();

  factory RiskCheckModel.fromJson(Map<String, dynamic> json) =>
      _$RiskCheckModelFromJson(json);

  factory RiskCheckModel.empty() => const RiskCheckModel();

  JobStatus get statusValue => JobStatus.fromValue(status);

  FailureReason get failureReasonValue =>
      FailureReason.fromValue(failureReason);
}
