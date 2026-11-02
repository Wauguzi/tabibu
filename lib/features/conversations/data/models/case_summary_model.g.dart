// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseSummaryModel _$CaseSummaryModelFromJson(Map<String, dynamic> json) =>
    _CaseSummaryModel(
      caseRef: json['caseRef'] as String? ?? '',
      ageBand: json['ageBand'] as String? ?? '',
      sex: json['sex'] as String? ?? '',
      testTypeNames:
          (json['testTypeNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      testNames:
          (json['testNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      reportStatus: json['reportStatus'] as String? ?? 'Pending',
      signedDiagnosisExcerpt: json['signedDiagnosisExcerpt'] as String? ?? '',
      signedAt: json['signedAt'] as String? ?? '',
      signedByName: json['signedByName'] as String? ?? '',
      reportLanguage: json['reportLanguage'] as String? ?? '',
      builtAt: json['builtAt'] as String? ?? '',
    );

Map<String, dynamic> _$CaseSummaryModelToJson(_CaseSummaryModel instance) =>
    <String, dynamic>{
      'caseRef': instance.caseRef,
      'ageBand': instance.ageBand,
      'sex': instance.sex,
      'testTypeNames': instance.testTypeNames,
      'testNames': instance.testNames,
      'reportStatus': instance.reportStatus,
      'signedDiagnosisExcerpt': instance.signedDiagnosisExcerpt,
      'signedAt': instance.signedAt,
      'signedByName': instance.signedByName,
      'reportLanguage': instance.reportLanguage,
      'builtAt': instance.builtAt,
    };
