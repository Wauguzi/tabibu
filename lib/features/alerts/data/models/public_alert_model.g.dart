// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicAlertModel _$PublicAlertModelFromJson(
  Map<String, dynamic> json,
) => _PublicAlertModel(
  uid: json['uid'] as String? ?? '',
  diseaseId: json['diseaseId'] as String? ?? '',
  diseaseNameEn: json['diseaseNameEn'] as String? ?? '',
  diseaseNameSw: json['diseaseNameSw'] as String? ?? '',
  countyId: (json['countyId'] as num?)?.toInt() ?? 0,
  countyName: json['countyName'] as String? ?? '',
  clinicianCountyIds:
      (json['clinicianCountyIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  epiWeek: json['epiWeek'] as String? ?? '',
  category: json['category'] as String? ?? 'Immediate',
  patientText:
      (json['patientText'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AlertTextModel.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, AlertTextModel>{},
  patientGuidance:
      (json['patientGuidance'] as List<dynamic>?)
          ?.map((e) => GuidanceBulletModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GuidanceBulletModel>[],
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => GuidanceSourceModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GuidanceSourceModel>[],
  issuedAt: json['issuedAt'] as String? ?? '',
  patientsReleased: json['patientsReleased'] as bool? ?? false,
  patientsReleasedAt: json['patientsReleasedAt'] as String? ?? '',
  synthetic: json['synthetic'] as bool? ?? false,
  createdAt: json['createdAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$PublicAlertModelToJson(
  _PublicAlertModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'diseaseId': instance.diseaseId,
  'diseaseNameEn': instance.diseaseNameEn,
  'diseaseNameSw': instance.diseaseNameSw,
  'countyId': instance.countyId,
  'countyName': instance.countyName,
  'clinicianCountyIds': instance.clinicianCountyIds,
  'epiWeek': instance.epiWeek,
  'category': instance.category,
  'patientText': instance.patientText.map((k, e) => MapEntry(k, e.toJson())),
  'patientGuidance': instance.patientGuidance.map((e) => e.toJson()).toList(),
  'sources': instance.sources.map((e) => e.toJson()).toList(),
  'issuedAt': instance.issuedAt,
  'patientsReleased': instance.patientsReleased,
  'patientsReleasedAt': instance.patientsReleasedAt,
  'synthetic': instance.synthetic,
  'createdAt': instance.createdAt,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
