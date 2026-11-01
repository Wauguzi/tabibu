// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guidance_source_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuidanceSourceModel _$GuidanceSourceModelFromJson(Map<String, dynamic> json) =>
    _GuidanceSourceModel(
      sourceId: json['sourceId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      url: json['url'] as String? ?? '',
      publishedOn: json['publishedOn'] as String? ?? '',
      accessedOn: json['accessedOn'] as String? ?? '',
    );

Map<String, dynamic> _$GuidanceSourceModelToJson(
  _GuidanceSourceModel instance,
) => <String, dynamic>{
  'sourceId': instance.sourceId,
  'title': instance.title,
  'publisher': instance.publisher,
  'url': instance.url,
  'publishedOn': instance.publishedOn,
  'accessedOn': instance.accessedOn,
};
