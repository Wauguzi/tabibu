import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';

part 'alert_clinician_brief_model.freezed.dart';
part 'alert_clinician_brief_model.g.dart';

/// Clinician brief under `publicAlerts/{a}/doctor/brief`.
@freezed
abstract class AlertClinicianBriefModel with _$AlertClinicianBriefModel {
  // Nested maps/lists must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory AlertClinicianBriefModel({
    @JsonKey(name: 'uid') @Default('brief') String uid,
    @JsonKey(name: 'alertUid') @Default('') String alertUid,
    @JsonKey(name: 'countyId') @Default(0) int countyId,
    @JsonKey(name: 'clinicianText')
    @Default(<String, AlertTextModel>{})
    Map<String, AlertTextModel> clinicianText,
    @JsonKey(name: 'clinicianGuidance')
    @Default(<GuidanceBulletModel>[])
    List<GuidanceBulletModel> clinicianGuidance,
    @JsonKey(name: 'sources')
    @Default(<GuidanceSourceModel>[])
    List<GuidanceSourceModel> sources,
    @JsonKey(name: 'confirmedCount') @Default(0) int confirmedCount,
    @JsonKey(name: 'weekStart') @Default('') String weekStart,
    @JsonKey(name: 'rule') @Default('Manual') String rule,
    @JsonKey(name: 'categoryVerified') @Default(false) bool categoryVerified,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _AlertClinicianBriefModel;

  const AlertClinicianBriefModel._();

  factory AlertClinicianBriefModel.fromJson(Map<String, dynamic> json) =>
      _$AlertClinicianBriefModelFromJson(json);

  factory AlertClinicianBriefModel.empty() => const AlertClinicianBriefModel();

  AlertRule get ruleValue => AlertRule.fromValue(rule);
}
