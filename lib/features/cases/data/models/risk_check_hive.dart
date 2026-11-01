import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';

part 'risk_check_hive.g.dart';

/// Cached [RiskCheckModel], in the same field order.
@HiveType(typeId: 10)
class RiskCheckHive {
  RiskCheckHive({
    required this.uid,
    required this.caseUid,
    required this.status,
    required this.inputLanguage,
    required this.suggestedLabTestIds,
    required this.advisoryKey,
    required this.advisoryEn,
    required this.advisorySw,
    required this.models,
    required this.failureReason,
    required this.requestedAt,
    required this.readyAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory RiskCheckHive.fromModel(RiskCheckModel model) {
    return RiskCheckHive(
      uid: model.uid,
      caseUid: model.caseUid,
      status: model.status,
      inputLanguage: model.inputLanguage,
      suggestedLabTestIds: model.suggestedLabTestIds,
      advisoryKey: model.advisoryKey,
      advisoryEn: model.advisoryEn,
      advisorySw: model.advisorySw,
      models: model.models,
      failureReason: model.failureReason,
      requestedAt: model.requestedAt,
      readyAt: model.readyAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  RiskCheckModel toModel() {
    return RiskCheckModel(
      uid: uid,
      caseUid: caseUid,
      status: status,
      inputLanguage: inputLanguage,
      suggestedLabTestIds: suggestedLabTestIds,
      advisoryKey: advisoryKey,
      advisoryEn: advisoryEn,
      advisorySw: advisorySw,
      models: models,
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
  final String caseUid;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final String inputLanguage;

  @HiveField(4)
  final List<String> suggestedLabTestIds;

  @HiveField(5)
  final String advisoryKey;

  @HiveField(6)
  final String advisoryEn;

  @HiveField(7)
  final String advisorySw;

  @HiveField(8)
  final Map<String, String> models;

  @HiveField(9)
  final String failureReason;

  @HiveField(10)
  final String requestedAt;

  @HiveField(11)
  final String readyAt;

  @HiveField(12)
  final String lastUpdatedAt;

  @HiveField(13)
  final bool synced;
}
