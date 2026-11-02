// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preread_finding_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrereadFindingModel _$PrereadFindingModelFromJson(Map<String, dynamic> json) =>
    _PrereadFindingModel(
      text: json['text'] as String? ?? '',
      evidenceIds:
          (json['evidenceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$PrereadFindingModelToJson(
  _PrereadFindingModel instance,
) => <String, dynamic>{
  'text': instance.text,
  'evidenceIds': instance.evidenceIds,
};
