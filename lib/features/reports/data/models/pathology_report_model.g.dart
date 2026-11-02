// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathology_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PathologyReportModel _$PathologyReportModelFromJson(
  Map<String, dynamic> json,
) => _PathologyReportModel(
  uid: json['uid'] as String? ?? '',
  caseUid: json['caseUid'] as String? ?? '',
  version: (json['version'] as num?)?.toInt() ?? 0,
  stage: json['stage'] as String? ?? 'Initial',
  status: json['status'] as String? ?? 'Signed',
  orderNumber: json['orderNumber'] as String? ?? '',
  testName: json['testName'] as String? ?? '',
  sampleCollectedAt: json['sampleCollectedAt'] as String? ?? '',
  sampleReceivedAt: json['sampleReceivedAt'] as String? ?? '',
  labAccessionNo: json['labAccessionNo'] as String? ?? '',
  profile: json['profile'] as String? ?? 'None',
  templateKey: json['templateKey'] as String? ?? 'General',
  title: json['title'] as String? ?? '',
  diagnosisType: json['diagnosisType'] as String? ?? 'Final',
  diagnosis: json['diagnosis'] as String? ?? '',
  comments: json['comments'] as String? ?? '',
  responses:
      (json['responses'] as List<dynamic>?)
          ?.map((e) => ReportResponseModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ReportResponseModel>[],
  isCritical: json['isCritical'] as bool? ?? false,
  measurements:
      (json['measurements'] as List<dynamic>?)
          ?.map(
            (e) => ReportMeasurementModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ReportMeasurementModel>[],
  addenda:
      (json['addenda'] as List<dynamic>?)
          ?.map((e) => ReportAddendumModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ReportAddendumModel>[],
  amendmentReason: json['amendmentReason'] as String? ?? '',
  prereadRunUid: json['prereadRunUid'] as String? ?? '',
  doctorUid: json['doctorUid'] as String? ?? '',
  pathologistUid: json['pathologistUid'] as String? ?? '',
  readerUids:
      (json['readerUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  signedByTitle: json['signedByTitle'] as String? ?? '',
  signedByName: json['signedByName'] as String? ?? '',
  signedByKmpdcNumber: json['signedByKmpdcNumber'] as String? ?? '',
  signedByFacilityName: json['signedByFacilityName'] as String? ?? '',
  signaturePath: json['signaturePath'] as String? ?? '',
  signatureSha256: json['signatureSha256'] as String? ?? '',
  contentSha256: json['contentSha256'] as String? ?? '',
  startedAt: json['startedAt'] as String? ?? '',
  scoredAt: json['scoredAt'] as String? ?? '',
  signedAt: json['signedAt'] as String? ?? '',
  doctorOpenedAt: json['doctorOpenedAt'] as String? ?? '',
  releasedToPatient: json['releasedToPatient'] as bool? ?? false,
  releasedAt: json['releasedAt'] as String? ?? '',
  releasedByUid: json['releasedByUid'] as String? ?? '',
  supersededAt: json['supersededAt'] as String? ?? '',
  supersededByUid: json['supersededByUid'] as String? ?? '',
  notifiableFindings:
      (json['notifiableFindings'] as List<dynamic>?)
          ?.map(
            (e) => NotifiableFindingModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <NotifiableFindingModel>[],
  confirmatoryRequests:
      (json['confirmatoryRequests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdByUid: json['createdByUid'] as String? ?? '',
  language: json['language'] as String? ?? 'en',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$PathologyReportModelToJson(
  _PathologyReportModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'caseUid': instance.caseUid,
  'version': instance.version,
  'stage': instance.stage,
  'status': instance.status,
  'orderNumber': instance.orderNumber,
  'testName': instance.testName,
  'sampleCollectedAt': instance.sampleCollectedAt,
  'sampleReceivedAt': instance.sampleReceivedAt,
  'labAccessionNo': instance.labAccessionNo,
  'profile': instance.profile,
  'templateKey': instance.templateKey,
  'title': instance.title,
  'diagnosisType': instance.diagnosisType,
  'diagnosis': instance.diagnosis,
  'comments': instance.comments,
  'responses': instance.responses.map((e) => e.toJson()).toList(),
  'isCritical': instance.isCritical,
  'measurements': instance.measurements.map((e) => e.toJson()).toList(),
  'addenda': instance.addenda.map((e) => e.toJson()).toList(),
  'amendmentReason': instance.amendmentReason,
  'prereadRunUid': instance.prereadRunUid,
  'doctorUid': instance.doctorUid,
  'pathologistUid': instance.pathologistUid,
  'readerUids': instance.readerUids,
  'signedByTitle': instance.signedByTitle,
  'signedByName': instance.signedByName,
  'signedByKmpdcNumber': instance.signedByKmpdcNumber,
  'signedByFacilityName': instance.signedByFacilityName,
  'signaturePath': instance.signaturePath,
  'signatureSha256': instance.signatureSha256,
  'contentSha256': instance.contentSha256,
  'startedAt': instance.startedAt,
  'scoredAt': instance.scoredAt,
  'signedAt': instance.signedAt,
  'doctorOpenedAt': instance.doctorOpenedAt,
  'releasedToPatient': instance.releasedToPatient,
  'releasedAt': instance.releasedAt,
  'releasedByUid': instance.releasedByUid,
  'supersededAt': instance.supersededAt,
  'supersededByUid': instance.supersededByUid,
  'notifiableFindings': instance.notifiableFindings
      .map((e) => e.toJson())
      .toList(),
  'confirmatoryRequests': instance.confirmatoryRequests,
  'createdByUid': instance.createdByUid,
  'language': instance.language,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
