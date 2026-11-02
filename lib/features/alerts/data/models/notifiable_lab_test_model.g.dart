// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifiable_lab_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotifiableLabTestModel _$NotifiableLabTestModelFromJson(
  Map<String, dynamic> json,
) => _NotifiableLabTestModel(
  labTestId: json['labTestId'] as String? ?? '',
  name: json['name'] as String? ?? '',
  strength: json['strength'] as String? ?? 'Uncertain',
  mappingVerified: json['mappingVerified'] as bool? ?? false,
);

Map<String, dynamic> _$NotifiableLabTestModelToJson(
  _NotifiableLabTestModel instance,
) => <String, dynamic>{
  'labTestId': instance.labTestId,
  'name': instance.name,
  'strength': instance.strength,
  'mappingVerified': instance.mappingVerified,
};
