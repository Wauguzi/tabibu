// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_intake_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppointmentIntakeModel _$AppointmentIntakeModelFromJson(
  Map<String, dynamic> json,
) => _AppointmentIntakeModel(
  uid: json['uid'] as String? ?? 'summary',
  appointmentUid: json['appointmentUid'] as String? ?? '',
  doctorUid: json['doctorUid'] as String? ?? '',
  status: json['status'] as String? ?? 'Queued',
  inputText: json['inputText'] as String? ?? '',
  inputMode: json['inputMode'] as String? ?? 'Typed',
  inputLanguage: json['inputLanguage'] as String? ?? '',
  transcriptLanguage: json['transcriptLanguage'] as String? ?? '',
  transcriptAcceptedUnchanged:
      json['transcriptAcceptedUnchanged'] as bool? ?? false,
  transcriptEditDistance:
      (json['transcriptEditDistance'] as num?)?.toDouble() ?? 0,
  drafts:
      (json['drafts'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, IntakeDraftModel.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, IntakeDraftModel>{},
  modelVersion: json['modelVersion'] as String? ?? '',
  promptVersion: json['promptVersion'] as String? ?? '',
  failureReason: json['failureReason'] as String? ?? '',
  requestedAt: json['requestedAt'] as String? ?? '',
  readyAt: json['readyAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$AppointmentIntakeModelToJson(
  _AppointmentIntakeModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'appointmentUid': instance.appointmentUid,
  'doctorUid': instance.doctorUid,
  'status': instance.status,
  'inputText': instance.inputText,
  'inputMode': instance.inputMode,
  'inputLanguage': instance.inputLanguage,
  'transcriptLanguage': instance.transcriptLanguage,
  'transcriptAcceptedUnchanged': instance.transcriptAcceptedUnchanged,
  'transcriptEditDistance': instance.transcriptEditDistance,
  'drafts': instance.drafts.map((k, e) => MapEntry(k, e.toJson())),
  'modelVersion': instance.modelVersion,
  'promptVersion': instance.promptVersion,
  'failureReason': instance.failureReason,
  'requestedAt': instance.requestedAt,
  'readyAt': instance.readyAt,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
