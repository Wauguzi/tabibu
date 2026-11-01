// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_check_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RiskCheckModel _$RiskCheckModelFromJson(Map<String, dynamic> json) =>
    _RiskCheckModel(
      uid: json['uid'] as String? ?? 'current',
      caseUid: json['caseUid'] as String? ?? '',
      status: json['status'] as String? ?? 'Queued',
      inputLanguage: json['inputLanguage'] as String? ?? '',
      suggestedLabTestIds:
          (json['suggestedLabTestIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      advisoryKey: json['advisoryKey'] as String? ?? '',
      advisoryEn: json['advisoryEn'] as String? ?? '',
      advisorySw: json['advisorySw'] as String? ?? '',
      models:
          (json['models'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      failureReason: json['failureReason'] as String? ?? '',
      requestedAt: json['requestedAt'] as String? ?? '',
      readyAt: json['readyAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$RiskCheckModelToJson(_RiskCheckModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'status': instance.status,
      'inputLanguage': instance.inputLanguage,
      'suggestedLabTestIds': instance.suggestedLabTestIds,
      'advisoryKey': instance.advisoryKey,
      'advisoryEn': instance.advisoryEn,
      'advisorySw': instance.advisorySw,
      'models': instance.models,
      'failureReason': instance.failureReason,
      'requestedAt': instance.requestedAt,
      'readyAt': instance.readyAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
