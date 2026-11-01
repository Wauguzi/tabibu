import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';

part 'public_alert_model.freezed.dart';
part 'public_alert_model.g.dart';

/// Reader-facing public alert (`publicAlerts/{uid}`).
@freezed
abstract class PublicAlertModel with _$PublicAlertModel {
  // Nested maps/lists must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PublicAlertModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'diseaseId') @Default('') String diseaseId,
    @JsonKey(name: 'diseaseNameEn') @Default('') String diseaseNameEn,
    @JsonKey(name: 'diseaseNameSw') @Default('') String diseaseNameSw,
    @JsonKey(name: 'countyId') @Default(0) int countyId,
    @JsonKey(name: 'countyName') @Default('') String countyName,
    @JsonKey(name: 'clinicianCountyIds')
    @Default(<int>[])
    List<int> clinicianCountyIds,
    @JsonKey(name: 'epiWeek') @Default('') String epiWeek,
    @JsonKey(name: 'category') @Default('Immediate') String category,
    @JsonKey(name: 'patientText')
    @Default(<String, AlertTextModel>{})
    Map<String, AlertTextModel> patientText,
    @JsonKey(name: 'patientGuidance')
    @Default(<GuidanceBulletModel>[])
    List<GuidanceBulletModel> patientGuidance,
    @JsonKey(name: 'sources')
    @Default(<GuidanceSourceModel>[])
    List<GuidanceSourceModel> sources,
    @JsonKey(name: 'issuedAt') @Default('') String issuedAt,
    @JsonKey(name: 'patientsReleased') @Default(false) bool patientsReleased,
    @JsonKey(name: 'patientsReleasedAt') @Default('') String patientsReleasedAt,
    @JsonKey(name: 'synthetic') @Default(false) bool synthetic,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _PublicAlertModel;

  const PublicAlertModel._();

  factory PublicAlertModel.fromJson(Map<String, dynamic> json) =>
      _$PublicAlertModelFromJson(json);

  factory PublicAlertModel.empty() => const PublicAlertModel();

  ReportingCategory get categoryValue => ReportingCategory.fromValue(category);

  /// True when patients may read this alert.
  bool get isReleasedToPatients => patientsReleased;
}
