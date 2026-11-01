// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InsurerModel _$InsurerModelFromJson(Map<String, dynamic> json) =>
    _InsurerModel(
      insurerId: json['insurerId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$InsurerModelToJson(_InsurerModel instance) =>
    <String, dynamic>{
      'insurerId': instance.insurerId,
      'name': instance.name,
      'type': instance.type,
    };
