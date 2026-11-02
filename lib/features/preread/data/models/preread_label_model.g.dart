// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preread_label_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrereadLabelModel _$PrereadLabelModelFromJson(Map<String, dynamic> json) =>
    _PrereadLabelModel(
      id: json['id'] as String? ?? '',
      imageUid: json['imageUid'] as String? ?? '',
      label: json['label'] as String? ?? '',
      probability: (json['probability'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$PrereadLabelModelToJson(_PrereadLabelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUid': instance.imageUid,
      'label': instance.label,
      'probability': instance.probability,
    };
