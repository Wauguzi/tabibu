// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_clinician_brief_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertClinicianBriefModel _$AlertClinicianBriefModelFromJson(
  Map<String, dynamic> json,
) => _AlertClinicianBriefModel(
  uid: json['uid'] as String? ?? 'brief',
  alertUid: json['alertUid'] as String? ?? '',
  countyId: (json['countyId'] as num?)?.toInt() ?? 0,
  clinicianText:
      (json['clinicianText'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AlertTextModel.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, AlertTextModel>{},
  clinicianGuidance:
      (json['clinicianGuidance'] as List<dynamic>?)
          ?.map((e) => GuidanceBulletModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GuidanceBulletModel>[],
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => GuidanceSourceModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GuidanceSourceModel>[],
  confirmedCount: (json['confirmedCount'] as num?)?.toInt() ?? 0,
  weekStart: json['weekStart'] as String? ?? '',
  rule: json['rule'] as String? ?? 'Manual',
  categoryVerified: json['categoryVerified'] as bool? ?? false,
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$AlertClinicianBriefModelToJson(
  _AlertClinicianBriefModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'alertUid': instance.alertUid,
  'countyId': instance.countyId,
  'clinicianText': instance.clinicianText.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'clinicianGuidance': instance.clinicianGuidance
      .map((e) => e.toJson())
      .toList(),
  'sources': instance.sources.map((e) => e.toJson()).toList(),
  'confirmedCount': instance.confirmedCount,
  'weekStart': instance.weekStart,
  'rule': instance.rule,
  'categoryVerified': instance.categoryVerified,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
