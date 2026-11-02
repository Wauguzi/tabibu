// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_text_approved_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportTextApprovedModel _$ReportTextApprovedModelFromJson(
  Map<String, dynamic> json,
) => _ReportTextApprovedModel(
  uid: json['uid'] as String? ?? '',
  caseUid: json['caseUid'] as String? ?? '',
  reportUid: json['reportUid'] as String? ?? '',
  reportVersion: (json['reportVersion'] as num?)?.toInt() ?? 0,
  kind: json['kind'] as String? ?? '',
  language: json['language'] as String? ?? '',
  sourceLanguage: json['sourceLanguage'] as String? ?? '',
  sourceSha256: json['sourceSha256'] as String? ?? '',
  approvedText:
      (json['approvedText'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  approverUid: json['approverUid'] as String? ?? '',
  approverName: json['approverName'] as String? ?? '',
  approvedAt: json['approvedAt'] as String? ?? '',
  acceptedUnchanged: json['acceptedUnchanged'] as bool? ?? false,
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$ReportTextApprovedModelToJson(
  _ReportTextApprovedModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'caseUid': instance.caseUid,
  'reportUid': instance.reportUid,
  'reportVersion': instance.reportVersion,
  'kind': instance.kind,
  'language': instance.language,
  'sourceLanguage': instance.sourceLanguage,
  'sourceSha256': instance.sourceSha256,
  'approvedText': instance.approvedText,
  'approverUid': instance.approverUid,
  'approverName': instance.approverName,
  'approvedAt': instance.approvedAt,
  'acceptedUnchanged': instance.acceptedUnchanged,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
