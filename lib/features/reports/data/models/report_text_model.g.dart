// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_text_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportTextModel _$ReportTextModelFromJson(Map<String, dynamic> json) =>
    _ReportTextModel(
      uid: json['uid'] as String? ?? '',
      caseUid: json['caseUid'] as String? ?? '',
      reportUid: json['reportUid'] as String? ?? '',
      reportVersion: (json['reportVersion'] as num?)?.toInt() ?? 0,
      kind: json['kind'] as String? ?? 'Translation',
      language: json['language'] as String? ?? 'sw',
      sourceLanguage: json['sourceLanguage'] as String? ?? 'en',
      detectedSourceLanguage: json['detectedSourceLanguage'] as String? ?? '',
      languageMismatch: json['languageMismatch'] as bool? ?? false,
      sourceSha256: json['sourceSha256'] as String? ?? '',
      status: json['status'] as String? ?? 'Queued',
      machineText:
          (json['machineText'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      models:
          (json['models'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      approverUid: json['approverUid'] as String? ?? '',
      requestCount: (json['requestCount'] as num?)?.toInt() ?? 0,
      acceptedUnchanged: json['acceptedUnchanged'] as bool? ?? false,
      editedSegmentKeys:
          (json['editedSegmentKeys'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      editDistance: (json['editDistance'] as num?)?.toDouble() ?? 0,
      failureReason: json['failureReason'] as String? ?? '',
      requestedAt: json['requestedAt'] as String? ?? '',
      readyAt: json['readyAt'] as String? ?? '',
      approvedAt: json['approvedAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$ReportTextModelToJson(_ReportTextModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'reportUid': instance.reportUid,
      'reportVersion': instance.reportVersion,
      'kind': instance.kind,
      'language': instance.language,
      'sourceLanguage': instance.sourceLanguage,
      'detectedSourceLanguage': instance.detectedSourceLanguage,
      'languageMismatch': instance.languageMismatch,
      'sourceSha256': instance.sourceSha256,
      'status': instance.status,
      'machineText': instance.machineText,
      'models': instance.models,
      'approverUid': instance.approverUid,
      'requestCount': instance.requestCount,
      'acceptedUnchanged': instance.acceptedUnchanged,
      'editedSegmentKeys': instance.editedSegmentKeys,
      'editDistance': instance.editDistance,
      'failureReason': instance.failureReason,
      'requestedAt': instance.requestedAt,
      'readyAt': instance.readyAt,
      'approvedAt': instance.approvedAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
