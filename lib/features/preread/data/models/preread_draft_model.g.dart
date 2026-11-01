// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preread_draft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrereadDraftModel _$PrereadDraftModelFromJson(
  Map<String, dynamic> json,
) => _PrereadDraftModel(
  findings:
      (json['findings'] as List<dynamic>?)
          ?.map((e) => PrereadFindingModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PrereadFindingModel>[],
  impression: json['impression'] as String? ?? '',
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
  confidenceBand: json['confidenceBand'] as String? ?? '',
  urgency: json['urgency'] as String? ?? '',
  nextSteps:
      (json['nextSteps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$PrereadDraftModelToJson(_PrereadDraftModel instance) =>
    <String, dynamic>{
      'findings': instance.findings.map((e) => e.toJson()).toList(),
      'impression': instance.impression,
      'confidence': instance.confidence,
      'confidenceBand': instance.confidenceBand,
      'urgency': instance.urgency,
      'nextSteps': instance.nextSteps,
    };
