import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';

part 'appointment_hive.g.dart';

/// Cached [AppointmentModel], in the same field order.
@HiveType(typeId: 24)
class AppointmentHive {
  AppointmentHive({
    required this.uid,
    required this.type,
    required this.status,
    required this.patientUid,
    required this.patientId,
    required this.patientName,
    required this.doctorUid,
    required this.doctorName,
    required this.facilityName,
    required this.createdByUid,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.symptomText,
    required this.inputMode,
    required this.symptomLanguage,
    required this.intakeStatus,
    required this.discussedCaseUid,
    required this.discussedOrderNumber,
    required this.caseUids,
    required this.expiresAt,
    required this.respondedAt,
    required this.acceptedAt,
    required this.declineReason,
    required this.declineNote,
    required this.cancelledAt,
    required this.cancelledByUid,
    required this.cancelNote,
    required this.completedAt,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory AppointmentHive.fromModel(AppointmentModel model) {
    return AppointmentHive(
      uid: model.uid,
      type: model.type,
      status: model.status,
      patientUid: model.patientUid,
      patientId: model.patientId,
      patientName: model.patientName,
      doctorUid: model.doctorUid,
      doctorName: model.doctorName,
      facilityName: model.facilityName,
      createdByUid: model.createdByUid,
      scheduledStart: model.scheduledStart,
      scheduledEnd: model.scheduledEnd,
      symptomText: model.symptomText,
      inputMode: model.inputMode,
      symptomLanguage: model.symptomLanguage,
      intakeStatus: model.intakeStatus,
      discussedCaseUid: model.discussedCaseUid,
      discussedOrderNumber: model.discussedOrderNumber,
      caseUids: model.caseUids,
      expiresAt: model.expiresAt,
      respondedAt: model.respondedAt,
      acceptedAt: model.acceptedAt,
      declineReason: model.declineReason,
      declineNote: model.declineNote,
      cancelledAt: model.cancelledAt,
      cancelledByUid: model.cancelledByUid,
      cancelNote: model.cancelNote,
      completedAt: model.completedAt,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  AppointmentModel toModel() {
    return AppointmentModel(
      uid: uid,
      type: type,
      status: status,
      patientUid: patientUid,
      patientId: patientId,
      patientName: patientName,
      doctorUid: doctorUid,
      doctorName: doctorName,
      facilityName: facilityName,
      createdByUid: createdByUid,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      symptomText: symptomText,
      inputMode: inputMode,
      symptomLanguage: symptomLanguage,
      intakeStatus: intakeStatus,
      discussedCaseUid: discussedCaseUid,
      discussedOrderNumber: discussedOrderNumber,
      caseUids: caseUids,
      expiresAt: expiresAt,
      respondedAt: respondedAt,
      acceptedAt: acceptedAt,
      declineReason: declineReason,
      declineNote: declineNote,
      cancelledAt: cancelledAt,
      cancelledByUid: cancelledByUid,
      cancelNote: cancelNote,
      completedAt: completedAt,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String type;
  @HiveField(2)
  final String status;
  @HiveField(3)
  final String patientUid;
  @HiveField(4)
  final String patientId;
  @HiveField(5)
  final String patientName;
  @HiveField(6)
  final String doctorUid;
  @HiveField(7)
  final String doctorName;
  @HiveField(8)
  final String facilityName;
  @HiveField(9)
  final String createdByUid;
  @HiveField(10)
  final String scheduledStart;
  @HiveField(11)
  final String scheduledEnd;
  @HiveField(12)
  final String symptomText;
  @HiveField(13)
  final String inputMode;
  @HiveField(14)
  final String symptomLanguage;
  @HiveField(15)
  final String intakeStatus;
  @HiveField(16)
  final String discussedCaseUid;
  @HiveField(17)
  final String discussedOrderNumber;
  @HiveField(18)
  final List<String> caseUids;
  @HiveField(19)
  final String expiresAt;
  @HiveField(20)
  final String respondedAt;
  @HiveField(21)
  final String acceptedAt;
  @HiveField(22)
  final String declineReason;
  @HiveField(23)
  final String declineNote;
  @HiveField(24)
  final String cancelledAt;
  @HiveField(25)
  final String cancelledByUid;
  @HiveField(26)
  final String cancelNote;
  @HiveField(27)
  final String completedAt;
  @HiveField(28)
  final String createdAt;
  @HiveField(29)
  final String lastUpdatedAt;
  @HiveField(30)
  final bool synced;
}
