import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_evidence_model.dart';

part 'alert_signal_model.freezed.dart';
part 'alert_signal_model.g.dart';

/// Working alert signal (`alertSignals/{uid}`); never cached.
@freezed
abstract class AlertSignalModel with _$AlertSignalModel {
  // Nested evidence must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory AlertSignalModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'diseaseId') @Default('') String diseaseId,
    @JsonKey(name: 'countyId') @Default(0) int countyId,
    @JsonKey(name: 'countyName') @Default('') String countyName,
    @JsonKey(name: 'epiWeek') @Default('') String epiWeek,
    @JsonKey(name: 'category') @Default('') String category,
    @JsonKey(name: 'rule') @Default('') String rule,
    @JsonKey(name: 'status') @Default('Withdrawn') String status,
    @JsonKey(name: 'evidence')
    @Default(AlertEvidenceModel())
    AlertEvidenceModel evidence,
    @JsonKey(name: 'alertUid') @Default('') String alertUid,
    @JsonKey(name: 'synthetic') @Default(false) bool synthetic,
    @JsonKey(name: 'raisedAt') @Default('') String raisedAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
  }) = _AlertSignalModel;

  const AlertSignalModel._();

  factory AlertSignalModel.fromJson(Map<String, dynamic> json) =>
      _$AlertSignalModelFromJson(json);

  factory AlertSignalModel.empty() => const AlertSignalModel();

  ReportingCategory get categoryValue => ReportingCategory.fromValue(category);

  AlertRule get ruleValue => AlertRule.fromValue(rule);

  /// True when the signal is still raised (unknown counts as withdrawn).
  bool get isRaised => status == 'Raised';
}
