import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

/// An `appointments/{uid}` consultation or case discussion.
@freezed
abstract class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'type') @Default('Consultation') String type,
    @JsonKey(name: 'status') @Default('Requested') String status,
    @JsonKey(name: 'patientUid') @Default('') String patientUid,
    @JsonKey(name: 'patientId') @Default('') String patientId,
    @JsonKey(name: 'patientName') @Default('') String patientName,
    @JsonKey(name: 'doctorUid') @Default('') String doctorUid,
    @JsonKey(name: 'doctorName') @Default('') String doctorName,
    @JsonKey(name: 'facilityName') @Default('') String facilityName,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'scheduledStart') @Default('') String scheduledStart,
    @JsonKey(name: 'scheduledEnd') @Default('') String scheduledEnd,
    @JsonKey(name: 'symptomText') @Default('') String symptomText,
    @JsonKey(name: 'inputMode') @Default('Typed') String inputMode,
    @JsonKey(name: 'symptomLanguage') @Default('') String symptomLanguage,
    @JsonKey(name: 'intakeStatus') @Default('None') String intakeStatus,
    @JsonKey(name: 'discussedCaseUid') @Default('') String discussedCaseUid,
    @JsonKey(name: 'discussedOrderNumber')
    @Default('')
    String discussedOrderNumber,
    @JsonKey(name: 'caseUids') @Default(<String>[]) List<String> caseUids,
    @JsonKey(name: 'expiresAt') @Default('') String expiresAt,
    @JsonKey(name: 'respondedAt') @Default('') String respondedAt,
    @JsonKey(name: 'acceptedAt') @Default('') String acceptedAt,
    @JsonKey(name: 'declineReason') @Default('') String declineReason,
    @JsonKey(name: 'declineNote') @Default('') String declineNote,
    @JsonKey(name: 'cancelledAt') @Default('') String cancelledAt,
    @JsonKey(name: 'cancelledByUid') @Default('') String cancelledByUid,
    @JsonKey(name: 'cancelNote') @Default('') String cancelNote,
    @JsonKey(name: 'completedAt') @Default('') String completedAt,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _AppointmentModel;

  const AppointmentModel._();

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  factory AppointmentModel.empty() => const AppointmentModel();

  AppointmentType get typeValue => AppointmentType.fromValue(type);

  AppointmentStatus get statusValue => AppointmentStatus.fromValue(status);

  InputMode get inputModeValue => InputMode.fromValue(inputMode);

  IntakeStatus get intakeStatusValue => IntakeStatus.fromValue(intakeStatus);

  DeclineReason get declineReasonValue =>
      DeclineReason.fromValue(declineReason);

  /// True when the request is still waiting for the doctor.
  bool get isRequested => statusValue == AppointmentStatus.requested;

  /// True when [expiresAt] is a non-empty ISO string earlier than [now].
  bool isExpiredAt(DateTime now) {
    if (expiresAt.isEmpty) return false;
    final expires = DateTime.tryParse(expiresAt);
    if (expires == null) return false;
    return expires.isBefore(now);
  }
}
