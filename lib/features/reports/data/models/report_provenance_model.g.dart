// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provenance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportProvenanceModel _$ReportProvenanceModelFromJson(
  Map<String, dynamic> json,
) => _ReportProvenanceModel(
  uid: json['uid'] as String? ?? '',
  caseUid: json['caseUid'] as String? ?? '',
  reportUid: json['reportUid'] as String? ?? '',
  pathologistUid: json['pathologistUid'] as String? ?? '',
  prereadRunUid: json['prereadRunUid'] as String? ?? '',
  diffBase: json['diffBase'] as String? ?? 'None',
  aiDraft:
      json['aiDraft'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  aiModels:
      (json['aiModels'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  aiMeasurements:
      (json['aiMeasurements'] as List<dynamic>?)
          ?.map(
            (e) => ReportMeasurementModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ReportMeasurementModel>[],
  finalMeasurements:
      (json['finalMeasurements'] as List<dynamic>?)
          ?.map(
            (e) => ReportMeasurementModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ReportMeasurementModel>[],
  labelOverrideCount: (json['labelOverrideCount'] as num?)?.toInt() ?? 0,
  diff:
      (json['diff'] as List<dynamic>?)
          ?.map((e) => ReportFieldDiffModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ReportFieldDiffModel>[],
  editRate: (json['editRate'] as num?)?.toDouble() ?? 0,
  acceptedUnchanged: json['acceptedUnchanged'] as bool? ?? false,
  hintShownDiseaseIds:
      (json['hintShownDiseaseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdAt: json['createdAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$ReportProvenanceModelToJson(
  _ReportProvenanceModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'caseUid': instance.caseUid,
  'reportUid': instance.reportUid,
  'pathologistUid': instance.pathologistUid,
  'prereadRunUid': instance.prereadRunUid,
  'diffBase': instance.diffBase,
  'aiDraft': instance.aiDraft,
  'aiModels': instance.aiModels,
  'aiMeasurements': instance.aiMeasurements.map((e) => e.toJson()).toList(),
  'finalMeasurements': instance.finalMeasurements
      .map((e) => e.toJson())
      .toList(),
  'labelOverrideCount': instance.labelOverrideCount,
  'diff': instance.diff.map((e) => e.toJson()).toList(),
  'editRate': instance.editRate,
  'acceptedUnchanged': instance.acceptedUnchanged,
  'hintShownDiseaseIds': instance.hintShownDiseaseIds,
  'createdAt': instance.createdAt,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
