// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_draft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IntakeDraftModel _$IntakeDraftModelFromJson(
  Map<String, dynamic> json,
) => _IntakeDraftModel(
  chiefComplaint: json['chiefComplaint'] as String? ?? '',
  symptoms:
      (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  duration: json['duration'] as String? ?? '',
  redFlags:
      (json['redFlags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  summary: json['summary'] as String? ?? '',
  isTranslation: json['isTranslation'] as bool? ?? false,
);

Map<String, dynamic> _$IntakeDraftModelToJson(_IntakeDraftModel instance) =>
    <String, dynamic>{
      'chiefComplaint': instance.chiefComplaint,
      'symptoms': instance.symptoms,
      'duration': instance.duration,
      'redFlags': instance.redFlags,
      'summary': instance.summary,
      'isTranslation': instance.isTranslation,
    };
