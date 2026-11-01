// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_draft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportDraftModel _$ReportDraftModelFromJson(Map<String, dynamic> json) =>
    _ReportDraftModel(
      uid: json['uid'] as String? ?? '',
      caseUid: json['caseUid'] as String? ?? '',
      pathologistUid: json['pathologistUid'] as String? ?? '',
      kind: json['kind'] as String? ?? 'Initial',
      status: json['status'] as String? ?? 'Editing',
      baseReportUid: json['baseReportUid'] as String? ?? '',
      targetReportUid: json['targetReportUid'] as String? ?? '',
      prereadRunUid: json['prereadRunUid'] as String? ?? '',
      templateKey: json['templateKey'] as String? ?? 'General',
      title: json['title'] as String? ?? '',
      diagnosisType: json['diagnosisType'] as String? ?? 'Final',
      diagnosis: json['diagnosis'] as String? ?? '',
      comments: json['comments'] as String? ?? '',
      responses:
          (json['responses'] as List<dynamic>?)
              ?.map(
                (e) => ReportResponseModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ReportResponseModel>[],
      labelOverrides:
          (json['labelOverrides'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      labelOverrideCount: (json['labelOverrideCount'] as num?)?.toInt() ?? 0,
      isCritical: json['isCritical'] as bool? ?? false,
      addendumText: json['addendumText'] as String? ?? '',
      amendmentReason: json['amendmentReason'] as String? ?? '',
      diagnosisStartedAt: json['diagnosisStartedAt'] as String? ?? '',
      startedFromPreread: json['startedFromPreread'] as bool? ?? false,
      startedAt: json['startedAt'] as String? ?? '',
      signedReportUid: json['signedReportUid'] as String? ?? '',
      notifiableFindings:
          (json['notifiableFindings'] as List<dynamic>?)
              ?.map(
                (e) =>
                    NotifiableFindingModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <NotifiableFindingModel>[],
      hintShownDiseaseIds:
          (json['hintShownDiseaseIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      confirmatoryRequests:
          (json['confirmatoryRequests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdByUid: json['createdByUid'] as String? ?? '',
      language: json['language'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$ReportDraftModelToJson(_ReportDraftModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'pathologistUid': instance.pathologistUid,
      'kind': instance.kind,
      'status': instance.status,
      'baseReportUid': instance.baseReportUid,
      'targetReportUid': instance.targetReportUid,
      'prereadRunUid': instance.prereadRunUid,
      'templateKey': instance.templateKey,
      'title': instance.title,
      'diagnosisType': instance.diagnosisType,
      'diagnosis': instance.diagnosis,
      'comments': instance.comments,
      'responses': instance.responses.map((e) => e.toJson()).toList(),
      'labelOverrides': instance.labelOverrides,
      'labelOverrideCount': instance.labelOverrideCount,
      'isCritical': instance.isCritical,
      'addendumText': instance.addendumText,
      'amendmentReason': instance.amendmentReason,
      'diagnosisStartedAt': instance.diagnosisStartedAt,
      'startedFromPreread': instance.startedFromPreread,
      'startedAt': instance.startedAt,
      'signedReportUid': instance.signedReportUid,
      'notifiableFindings': instance.notifiableFindings
          .map((e) => e.toJson())
          .toList(),
      'hintShownDiseaseIds': instance.hintShownDiseaseIds,
      'confirmatoryRequests': instance.confirmatoryRequests,
      'createdByUid': instance.createdByUid,
      'language': instance.language,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
