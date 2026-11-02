// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_health_guidance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicHealthGuidanceModel _$PublicHealthGuidanceModelFromJson(
  Map<String, dynamic> json,
) => _PublicHealthGuidanceModel(
  diseaseId: json['diseaseId'] as String? ?? '',
  reviewedOn: json['reviewedOn'] as String? ?? '',
  bullets:
      (json['bullets'] as List<dynamic>?)
          ?.map((e) => GuidanceBulletModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GuidanceBulletModel>[],
  sources:
      (json['sources'] as List<dynamic>?)
          ?.map((e) => GuidanceSourceModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GuidanceSourceModel>[],
);

Map<String, dynamic> _$PublicHealthGuidanceModelToJson(
  _PublicHealthGuidanceModel instance,
) => <String, dynamic>{
  'diseaseId': instance.diseaseId,
  'reviewedOn': instance.reviewedOn,
  'bullets': instance.bullets.map((e) => e.toJson()).toList(),
  'sources': instance.sources.map((e) => e.toJson()).toList(),
};
