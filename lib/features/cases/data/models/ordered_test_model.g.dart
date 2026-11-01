// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordered_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderedTestModel _$OrderedTestModelFromJson(Map<String, dynamic> json) =>
    _OrderedTestModel(
      labTestId: json['labTestId'] as String? ?? '',
      testTypeId: json['testTypeId'] as String? ?? '',
      testTypeName: json['testTypeName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      priceKes: (json['priceKes'] as num?)?.toInt() ?? 0,
      isPriceEstimate: json['isPriceEstimate'] as bool? ?? false,
    );

Map<String, dynamic> _$OrderedTestModelToJson(_OrderedTestModel instance) =>
    <String, dynamic>{
      'labTestId': instance.labTestId,
      'testTypeId': instance.testTypeId,
      'testTypeName': instance.testTypeName,
      'name': instance.name,
      'priceKes': instance.priceKes,
      'isPriceEstimate': instance.isPriceEstimate,
    };
