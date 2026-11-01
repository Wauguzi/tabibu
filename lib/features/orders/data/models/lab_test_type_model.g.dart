// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_test_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LabTestTypeModel _$LabTestTypeModelFromJson(Map<String, dynamic> json) =>
    _LabTestTypeModel(
      testTypeId: json['testTypeId'] as String,
      name: json['name'] as String,
      testCount: (json['testCount'] as num).toInt(),
    );

Map<String, dynamic> _$LabTestTypeModelToJson(_LabTestTypeModel instance) =>
    <String, dynamic>{
      'testTypeId': instance.testTypeId,
      'name': instance.name,
      'testCount': instance.testCount,
    };
