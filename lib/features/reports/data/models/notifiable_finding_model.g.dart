// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifiable_finding_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotifiableFindingModel _$NotifiableFindingModelFromJson(
  Map<String, dynamic> json,
) => _NotifiableFindingModel(
  diseaseId: json['diseaseId'] as String? ?? '',
  alertRequested: json['alertRequested'] as bool? ?? false,
);

Map<String, dynamic> _$NotifiableFindingModelToJson(
  _NotifiableFindingModel instance,
) => <String, dynamic>{
  'diseaseId': instance.diseaseId,
  'alertRequested': instance.alertRequested,
};
