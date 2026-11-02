// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifiable_disease_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotifiableDiseaseModel _$NotifiableDiseaseModelFromJson(
  Map<String, dynamic> json,
) => _NotifiableDiseaseModel(
  diseaseId: json['diseaseId'] as String? ?? '',
  nameEn: json['nameEn'] as String? ?? '',
  nameSw: json['nameSw'] as String? ?? '',
  ihrStatus: json['ihrStatus'] as String? ?? 'None',
  reportingCategory: json['reportingCategory'] as String? ?? 'NotListed',
  kenyaGroup: json['kenyaGroup'] as String? ?? 'NotListed',
  categorySourceId: json['categorySourceId'] as String? ?? '',
  categoryVerified: json['categoryVerified'] as bool? ?? false,
  caseDefinitionEn: json['caseDefinitionEn'] as String? ?? '',
  caseDefinitionSw: json['caseDefinitionSw'] as String? ?? '',
  labTests:
      (json['labTests'] as List<dynamic>?)
          ?.map(
            (e) => NotifiableLabTestModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <NotifiableLabTestModel>[],
  publicAlertEligible: json['publicAlertEligible'] as bool? ?? false,
  allowManualAlert: json['allowManualAlert'] as bool? ?? false,
  preReadHint: json['preReadHint'] as String? ?? '',
  sourceIds:
      (json['sourceIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$NotifiableDiseaseModelToJson(
  _NotifiableDiseaseModel instance,
) => <String, dynamic>{
  'diseaseId': instance.diseaseId,
  'nameEn': instance.nameEn,
  'nameSw': instance.nameSw,
  'ihrStatus': instance.ihrStatus,
  'reportingCategory': instance.reportingCategory,
  'kenyaGroup': instance.kenyaGroup,
  'categorySourceId': instance.categorySourceId,
  'categoryVerified': instance.categoryVerified,
  'caseDefinitionEn': instance.caseDefinitionEn,
  'caseDefinitionSw': instance.caseDefinitionSw,
  'labTests': instance.labTests.map((e) => e.toJson()).toList(),
  'publicAlertEligible': instance.publicAlertEligible,
  'allowManualAlert': instance.allowManualAlert,
  'preReadHint': instance.preReadHint,
  'sourceIds': instance.sourceIds,
};
