import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/case_payment_model.dart';

part 'case_payment_hive.g.dart';

/// Cached [CasePaymentModel], in the same field order.
@HiveType(typeId: 8)
class CasePaymentHive {
  CasePaymentHive({
    required this.caseUid,
    required this.method,
    required this.insurerId,
    required this.insurerName,
    required this.policyNumber,
    required this.createdByUid,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory CasePaymentHive.fromModel(CasePaymentModel model) {
    return CasePaymentHive(
      caseUid: model.caseUid,
      method: model.method,
      insurerId: model.insurerId,
      insurerName: model.insurerName,
      policyNumber: model.policyNumber,
      createdByUid: model.createdByUid,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  CasePaymentModel toModel() {
    return CasePaymentModel(
      caseUid: caseUid,
      method: method,
      insurerId: insurerId,
      insurerName: insurerName,
      policyNumber: policyNumber,
      createdByUid: createdByUid,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String caseUid;

  @HiveField(1)
  final String method;

  @HiveField(2)
  final String insurerId;

  @HiveField(3)
  final String insurerName;

  @HiveField(4)
  final String policyNumber;

  @HiveField(5)
  final String createdByUid;

  @HiveField(6)
  final String createdAt;

  @HiveField(7)
  final String lastUpdatedAt;

  @HiveField(8)
  final bool synced;
}
