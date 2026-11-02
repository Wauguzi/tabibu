// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guidance_bullet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuidanceBulletModel _$GuidanceBulletModelFromJson(Map<String, dynamic> json) =>
    _GuidanceBulletModel(
      bulletId: json['bulletId'] as String? ?? '',
      audience: json['audience'] as String? ?? 'Patient',
      textEn: json['textEn'] as String? ?? '',
      textSw: json['textSw'] as String? ?? '',
      swIsOfficial: json['swIsOfficial'] as bool? ?? false,
      sourceId: json['sourceId'] as String? ?? '',
    );

Map<String, dynamic> _$GuidanceBulletModelToJson(
  _GuidanceBulletModel instance,
) => <String, dynamic>{
  'bulletId': instance.bulletId,
  'audience': instance.audience,
  'textEn': instance.textEn,
  'textSw': instance.textSw,
  'swIsOfficial': instance.swIsOfficial,
  'sourceId': instance.sourceId,
};
