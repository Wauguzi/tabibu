// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseModel _$CaseModelFromJson(Map<String, dynamic> json) => _CaseModel(
  uid: json['uid'] as String? ?? '',
  orderNumber: json['orderNumber'] as String? ?? '',
  appointmentUid: json['appointmentUid'] as String? ?? '',
  createdByUid: json['createdByUid'] as String? ?? '',
  doctorUid: json['doctorUid'] as String? ?? '',
  doctorName: json['doctorName'] as String? ?? '',
  doctorFacilityName: json['doctorFacilityName'] as String? ?? '',
  patientId: json['patientId'] as String? ?? '',
  patientUid: json['patientUid'] as String? ?? '',
  patientName: json['patientName'] as String? ?? '',
  patientSex: json['patientSex'] as String? ?? '',
  patientAgeYears: (json['patientAgeYears'] as num?)?.toInt() ?? 0,
  requestedPathologistUid: json['requestedPathologistUid'] as String? ?? '',
  requestedPathologistName: json['requestedPathologistName'] as String? ?? '',
  pathologistRequestedAt: json['pathologistRequestedAt'] as String? ?? '',
  pathologistRequestExpiresAt:
      json['pathologistRequestExpiresAt'] as String? ?? '',
  declinedPathologistUids:
      (json['declinedPathologistUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  pathologistUid: json['pathologistUid'] as String? ?? '',
  pathologistName: json['pathologistName'] as String? ?? '',
  pathologistAcceptedAt: json['pathologistAcceptedAt'] as String? ?? '',
  viewerUids:
      (json['viewerUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  participantUids:
      (json['participantUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  tests:
      (json['tests'] as List<dynamic>?)
          ?.map((e) => OrderedTestModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OrderedTestModel>[],
  totalPriceKes: (json['totalPriceKes'] as num?)?.toInt() ?? 0,
  isPriceEstimate: json['isPriceEstimate'] as bool? ?? false,
  priority: json['priority'] as String? ?? 'Routine',
  clinicalNotes: json['clinicalNotes'] as String? ?? '',
  sampleNotes: json['sampleNotes'] as String? ?? '',
  notesLanguage: json['notesLanguage'] as String? ?? '',
  sampleCollectedAt: json['sampleCollectedAt'] as String? ?? '',
  sampleReceivedAt: json['sampleReceivedAt'] as String? ?? '',
  labAccessionNo: json['labAccessionNo'] as String? ?? '',
  requiresSlides: json['requiresSlides'] as bool? ?? false,
  slideUploadUids:
      (json['slideUploadUids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  slideImages:
      (json['slideImages'] as List<dynamic>?)
          ?.map((e) => SlideImageModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SlideImageModel>[],
  prereadRunUid: json['prereadRunUid'] as String? ?? '',
  currentReportUid: json['currentReportUid'] as String? ?? '',
  resultState: json['resultState'] as String? ?? 'Pending',
  discussionAppointmentUid: json['discussionAppointmentUid'] as String? ?? '',
  currentLocation: json['currentLocation'] as String? ?? 'Doctor',
  currentStage: json['currentStage'] as String? ?? 'OrderCreated',
  currentStep: json['currentStep'] as String? ?? '',
  stageSeq: (json['stageSeq'] as num?)?.toInt() ?? 0,
  stageEnteredAt: json['stageEnteredAt'] as String? ?? '',
  releasedToPatient: json['releasedToPatient'] as bool? ?? false,
  discussedAt: json['discussedAt'] as String? ?? '',
  releasedAt: json['releasedAt'] as String? ?? '',
  cancelReason: json['cancelReason'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$CaseModelToJson(_CaseModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'orderNumber': instance.orderNumber,
      'appointmentUid': instance.appointmentUid,
      'createdByUid': instance.createdByUid,
      'doctorUid': instance.doctorUid,
      'doctorName': instance.doctorName,
      'doctorFacilityName': instance.doctorFacilityName,
      'patientId': instance.patientId,
      'patientUid': instance.patientUid,
      'patientName': instance.patientName,
      'patientSex': instance.patientSex,
      'patientAgeYears': instance.patientAgeYears,
      'requestedPathologistUid': instance.requestedPathologistUid,
      'requestedPathologistName': instance.requestedPathologistName,
      'pathologistRequestedAt': instance.pathologistRequestedAt,
      'pathologistRequestExpiresAt': instance.pathologistRequestExpiresAt,
      'declinedPathologistUids': instance.declinedPathologistUids,
      'pathologistUid': instance.pathologistUid,
      'pathologistName': instance.pathologistName,
      'pathologistAcceptedAt': instance.pathologistAcceptedAt,
      'viewerUids': instance.viewerUids,
      'participantUids': instance.participantUids,
      'tests': instance.tests.map((e) => e.toJson()).toList(),
      'totalPriceKes': instance.totalPriceKes,
      'isPriceEstimate': instance.isPriceEstimate,
      'priority': instance.priority,
      'clinicalNotes': instance.clinicalNotes,
      'sampleNotes': instance.sampleNotes,
      'notesLanguage': instance.notesLanguage,
      'sampleCollectedAt': instance.sampleCollectedAt,
      'sampleReceivedAt': instance.sampleReceivedAt,
      'labAccessionNo': instance.labAccessionNo,
      'requiresSlides': instance.requiresSlides,
      'slideUploadUids': instance.slideUploadUids,
      'slideImages': instance.slideImages.map((e) => e.toJson()).toList(),
      'prereadRunUid': instance.prereadRunUid,
      'currentReportUid': instance.currentReportUid,
      'resultState': instance.resultState,
      'discussionAppointmentUid': instance.discussionAppointmentUid,
      'currentLocation': instance.currentLocation,
      'currentStage': instance.currentStage,
      'currentStep': instance.currentStep,
      'stageSeq': instance.stageSeq,
      'stageEnteredAt': instance.stageEnteredAt,
      'releasedToPatient': instance.releasedToPatient,
      'discussedAt': instance.discussedAt,
      'releasedAt': instance.releasedAt,
      'cancelReason': instance.cancelReason,
      'createdAt': instance.createdAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
