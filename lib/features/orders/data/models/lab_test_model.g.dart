// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LabTestModel _$LabTestModelFromJson(Map<String, dynamic> json) =>
    _LabTestModel(
      labTestId: json['labTestId'] as String,
      testTypeId: json['testTypeId'] as String,
      testTypeName: json['testTypeName'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool,
      testPriceKes: (json['testPriceKes'] as num).toInt(),
      isPriceEstimate: json['isPriceEstimate'] as bool,
      tatCollectionToDelivery: (json['tatCollectionToDelivery'] as num).toInt(),
      tatDeliveryToResults: (json['tatDeliveryToResults'] as num).toInt(),
      totalTurnaroundTime: (json['totalTurnaroundTime'] as num).toInt(),
    );

Map<String, dynamic> _$LabTestModelToJson(_LabTestModel instance) =>
    <String, dynamic>{
      'labTestId': instance.labTestId,
      'testTypeId': instance.testTypeId,
      'testTypeName': instance.testTypeName,
      'name': instance.name,
      'isActive': instance.isActive,
      'testPriceKes': instance.testPriceKes,
      'isPriceEstimate': instance.isPriceEstimate,
      'tatCollectionToDelivery': instance.tatCollectionToDelivery,
      'tatDeliveryToResults': instance.tatDeliveryToResults,
      'totalTurnaroundTime': instance.totalTurnaroundTime,
    };
