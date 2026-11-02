import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_model.dart';
import 'package:tabibu/features/appointments/data/models/intake_draft_hive.dart';

part 'appointment_intake_hive.g.dart';

/// Cached [AppointmentIntakeModel], in the same field order.
@HiveType(typeId: 25)
class AppointmentIntakeHive {
  AppointmentIntakeHive({
    required this.uid,
    required this.appointmentUid,
    required this.doctorUid,
    required this.status,
    required this.inputText,
    required this.inputMode,
    required this.inputLanguage,
    required this.transcriptLanguage,
    required this.transcriptAcceptedUnchanged,
    required this.transcriptEditDistance,
    required this.drafts,
    required this.modelVersion,
    required this.promptVersion,
    required this.failureReason,
    required this.requestedAt,
    required this.readyAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory AppointmentIntakeHive.fromModel(AppointmentIntakeModel model) {
    return AppointmentIntakeHive(
      uid: model.uid,
      appointmentUid: model.appointmentUid,
      doctorUid: model.doctorUid,
      status: model.status,
      inputText: model.inputText,
      inputMode: model.inputMode,
      inputLanguage: model.inputLanguage,
      transcriptLanguage: model.transcriptLanguage,
      transcriptAcceptedUnchanged: model.transcriptAcceptedUnchanged,
      transcriptEditDistance: model.transcriptEditDistance,
      drafts: {
        for (final e in model.drafts.entries)
          e.key: IntakeDraftHive.fromModel(e.value),
      },
      modelVersion: model.modelVersion,
      promptVersion: model.promptVersion,
      failureReason: model.failureReason,
      requestedAt: model.requestedAt,
      readyAt: model.readyAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  AppointmentIntakeModel toModel() {
    return AppointmentIntakeModel(
      uid: uid,
      appointmentUid: appointmentUid,
      doctorUid: doctorUid,
      status: status,
      inputText: inputText,
      inputMode: inputMode,
      inputLanguage: inputLanguage,
      transcriptLanguage: transcriptLanguage,
      transcriptAcceptedUnchanged: transcriptAcceptedUnchanged,
      transcriptEditDistance: transcriptEditDistance,
      drafts: {for (final e in drafts.entries) e.key: e.value.toModel()},
      modelVersion: modelVersion,
      promptVersion: promptVersion,
      failureReason: failureReason,
      requestedAt: requestedAt,
      readyAt: readyAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String appointmentUid;
  @HiveField(2)
  final String doctorUid;
  @HiveField(3)
  final String status;
  @HiveField(4)
  final String inputText;
  @HiveField(5)
  final String inputMode;
  @HiveField(6)
  final String inputLanguage;
  @HiveField(7)
  final String transcriptLanguage;
  @HiveField(8)
  final bool transcriptAcceptedUnchanged;
  @HiveField(9)
  final double transcriptEditDistance;
  @HiveField(10)
  final Map<String, IntakeDraftHive> drafts;
  @HiveField(11)
  final String modelVersion;
  @HiveField(12)
  final String promptVersion;
  @HiveField(13)
  final String failureReason;
  @HiveField(14)
  final String requestedAt;
  @HiveField(15)
  final String readyAt;
  @HiveField(16)
  final String lastUpdatedAt;
  @HiveField(17)
  final bool synced;
}
