// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    _AppointmentModel(
      uid: json['uid'] as String? ?? '',
      type: json['type'] as String? ?? 'Consultation',
      status: json['status'] as String? ?? 'Requested',
      patientUid: json['patientUid'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      doctorUid: json['doctorUid'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      facilityName: json['facilityName'] as String? ?? '',
      createdByUid: json['createdByUid'] as String? ?? '',
      scheduledStart: json['scheduledStart'] as String? ?? '',
      scheduledEnd: json['scheduledEnd'] as String? ?? '',
      symptomText: json['symptomText'] as String? ?? '',
      inputMode: json['inputMode'] as String? ?? 'Typed',
      symptomLanguage: json['symptomLanguage'] as String? ?? '',
      intakeStatus: json['intakeStatus'] as String? ?? 'None',
      discussedCaseUid: json['discussedCaseUid'] as String? ?? '',
      discussedOrderNumber: json['discussedOrderNumber'] as String? ?? '',
      caseUids:
          (json['caseUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      expiresAt: json['expiresAt'] as String? ?? '',
      respondedAt: json['respondedAt'] as String? ?? '',
      acceptedAt: json['acceptedAt'] as String? ?? '',
      declineReason: json['declineReason'] as String? ?? '',
      declineNote: json['declineNote'] as String? ?? '',
      cancelledAt: json['cancelledAt'] as String? ?? '',
      cancelledByUid: json['cancelledByUid'] as String? ?? '',
      cancelNote: json['cancelNote'] as String? ?? '',
      completedAt: json['completedAt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$AppointmentModelToJson(_AppointmentModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'type': instance.type,
      'status': instance.status,
      'patientUid': instance.patientUid,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'doctorUid': instance.doctorUid,
      'doctorName': instance.doctorName,
      'facilityName': instance.facilityName,
      'createdByUid': instance.createdByUid,
      'scheduledStart': instance.scheduledStart,
      'scheduledEnd': instance.scheduledEnd,
      'symptomText': instance.symptomText,
      'inputMode': instance.inputMode,
      'symptomLanguage': instance.symptomLanguage,
      'intakeStatus': instance.intakeStatus,
      'discussedCaseUid': instance.discussedCaseUid,
      'discussedOrderNumber': instance.discussedOrderNumber,
      'caseUids': instance.caseUids,
      'expiresAt': instance.expiresAt,
      'respondedAt': instance.respondedAt,
      'acceptedAt': instance.acceptedAt,
      'declineReason': instance.declineReason,
      'declineNote': instance.declineNote,
      'cancelledAt': instance.cancelledAt,
      'cancelledByUid': instance.cancelledByUid,
      'cancelNote': instance.cancelNote,
      'completedAt': instance.completedAt,
      'createdAt': instance.createdAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
