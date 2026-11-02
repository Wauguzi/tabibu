import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

part 'worklist_entry_hive.g.dart';

/// Cached [WorklistEntryModel], in the same field order.
@HiveType(typeId: 22)
class WorklistEntryHive {
  WorklistEntryHive({
    required this.uid,
    required this.caseUid,
    required this.pathologistUid,
    required this.orderNumber,
    required this.testName,
    required this.profile,
    required this.status,
    required this.prereadStatus,
    required this.urgency,
    required this.confidenceBand,
    required this.confidence,
    required this.riskFlag,
    required this.severity,
    required this.basePriority,
    required this.waitingSince,
    required this.assignedAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory WorklistEntryHive.fromModel(WorklistEntryModel model) {
    return WorklistEntryHive(
      uid: model.uid,
      caseUid: model.caseUid,
      pathologistUid: model.pathologistUid,
      orderNumber: model.orderNumber,
      testName: model.testName,
      profile: model.profile,
      status: model.status,
      prereadStatus: model.prereadStatus,
      urgency: model.urgency,
      confidenceBand: model.confidenceBand,
      confidence: model.confidence,
      riskFlag: model.riskFlag,
      severity: model.severity,
      basePriority: model.basePriority,
      waitingSince: model.waitingSince,
      assignedAt: model.assignedAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  WorklistEntryModel toModel() {
    return WorklistEntryModel(
      uid: uid,
      caseUid: caseUid,
      pathologistUid: pathologistUid,
      orderNumber: orderNumber,
      testName: testName,
      profile: profile,
      status: status,
      prereadStatus: prereadStatus,
      urgency: urgency,
      confidenceBand: confidenceBand,
      confidence: confidence,
      riskFlag: riskFlag,
      severity: severity,
      basePriority: basePriority,
      waitingSince: waitingSince,
      assignedAt: assignedAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String caseUid;
  @HiveField(2)
  final String pathologistUid;
  @HiveField(3)
  final String orderNumber;
  @HiveField(4)
  final String testName;
  @HiveField(5)
  final String profile;
  @HiveField(6)
  final String status;
  @HiveField(7)
  final String prereadStatus;
  @HiveField(8)
  final String urgency;
  @HiveField(9)
  final String confidenceBand;
  @HiveField(10)
  final double confidence;
  @HiveField(11)
  final bool riskFlag;
  @HiveField(12)
  final String severity;
  @HiveField(13)
  final int basePriority;
  @HiveField(14)
  final String waitingSince;
  @HiveField(15)
  final String assignedAt;
  @HiveField(16)
  final String lastUpdatedAt;
  @HiveField(17)
  final bool synced;
}
