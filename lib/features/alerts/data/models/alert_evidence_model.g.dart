// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_evidence_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertEvidenceModel _$AlertEvidenceModelFromJson(Map<String, dynamic> json) =>
    _AlertEvidenceModel(
      confirmedCount: (json['confirmedCount'] as num?)?.toInt() ?? 0,
      baselineMean: (json['baselineMean'] as num?)?.toDouble() ?? 0,
      baselineSd: (json['baselineSd'] as num?)?.toDouble() ?? 0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0,
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      windowWeeks: (json['windowWeeks'] as num?)?.toInt() ?? 0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 0,
      ageBandCounts:
          (json['ageBandCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      manualRequests: (json['manualRequests'] as num?)?.toInt() ?? 0,
      categoryVerified: json['categoryVerified'] as bool? ?? false,
      mappingVerified: json['mappingVerified'] as bool? ?? false,
      categorySourceId: json['categorySourceId'] as String? ?? '',
      weekStart: json['weekStart'] as String? ?? '',
    );

Map<String, dynamic> _$AlertEvidenceModelToJson(_AlertEvidenceModel instance) =>
    <String, dynamic>{
      'confirmedCount': instance.confirmedCount,
      'baselineMean': instance.baselineMean,
      'baselineSd': instance.baselineSd,
      'threshold': instance.threshold,
      'floor': instance.floor,
      'windowWeeks': instance.windowWeeks,
      'multiplier': instance.multiplier,
      'ageBandCounts': instance.ageBandCounts,
      'manualRequests': instance.manualRequests,
      'categoryVerified': instance.categoryVerified,
      'mappingVerified': instance.mappingVerified,
      'categorySourceId': instance.categorySourceId,
      'weekStart': instance.weekStart,
    };
