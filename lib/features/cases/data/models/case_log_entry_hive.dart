import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';

part 'case_log_entry_hive.g.dart';

/// Cached [CaseLogEntryModel], in the same field order.
@HiveType(typeId: 7)
class CaseLogEntryHive {
  CaseLogEntryHive({
    required this.uid,
    required this.caseUid,
    required this.seq,
    required this.fromLocation,
    required this.fromStage,
    required this.fromStep,
    required this.toLocation,
    required this.toStage,
    required this.toStep,
    required this.createdByUid,
    required this.actorRole,
    required this.actionType,
    required this.actionReason,
    required this.patientVisible,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory CaseLogEntryHive.fromModel(CaseLogEntryModel model) {
    return CaseLogEntryHive(
      uid: model.uid,
      caseUid: model.caseUid,
      seq: model.seq,
      fromLocation: model.fromLocation,
      fromStage: model.fromStage,
      fromStep: model.fromStep,
      toLocation: model.toLocation,
      toStage: model.toStage,
      toStep: model.toStep,
      createdByUid: model.createdByUid,
      actorRole: model.actorRole,
      actionType: model.actionType,
      actionReason: model.actionReason,
      patientVisible: model.patientVisible,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  CaseLogEntryModel toModel() {
    return CaseLogEntryModel(
      uid: uid,
      caseUid: caseUid,
      seq: seq,
      fromLocation: fromLocation,
      fromStage: fromStage,
      fromStep: fromStep,
      toLocation: toLocation,
      toStage: toStage,
      toStep: toStep,
      createdByUid: createdByUid,
      actorRole: actorRole,
      actionType: actionType,
      actionReason: actionReason,
      patientVisible: patientVisible,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String caseUid;

  @HiveField(2)
  final int seq;

  @HiveField(3)
  final String fromLocation;

  @HiveField(4)
  final String fromStage;

  @HiveField(5)
  final String fromStep;

  @HiveField(6)
  final String toLocation;

  @HiveField(7)
  final String toStage;

  @HiveField(8)
  final String toStep;

  @HiveField(9)
  final String createdByUid;

  @HiveField(10)
  final String actorRole;

  @HiveField(11)
  final String actionType;

  @HiveField(12)
  final String actionReason;

  @HiveField(13)
  final bool patientVisible;

  @HiveField(14)
  final String createdAt;

  @HiveField(15)
  final String lastUpdatedAt;

  @HiveField(16)
  final bool synced;
}
