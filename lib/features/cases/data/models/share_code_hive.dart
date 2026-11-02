import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';

part 'share_code_hive.g.dart';

/// Cached [ShareCodeModel], in the same field order.
@HiveType(typeId: 9)
class ShareCodeHive {
  ShareCodeHive({
    required this.uid,
    required this.caseUid,
    required this.reportUid,
    required this.purpose,
    required this.createdByUid,
    required this.createdByRole,
    required this.recipientUid,
    required this.status,
    required this.attempts,
    required this.reissueCount,
    required this.expiresAt,
    required this.redeemedAt,
    required this.notificationUid,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory ShareCodeHive.fromModel(ShareCodeModel model) {
    return ShareCodeHive(
      uid: model.uid,
      caseUid: model.caseUid,
      reportUid: model.reportUid,
      purpose: model.purpose,
      createdByUid: model.createdByUid,
      createdByRole: model.createdByRole,
      recipientUid: model.recipientUid,
      status: model.status,
      attempts: model.attempts,
      reissueCount: model.reissueCount,
      expiresAt: model.expiresAt,
      redeemedAt: model.redeemedAt,
      notificationUid: model.notificationUid,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  ShareCodeModel toModel() {
    return ShareCodeModel(
      uid: uid,
      caseUid: caseUid,
      reportUid: reportUid,
      purpose: purpose,
      createdByUid: createdByUid,
      createdByRole: createdByRole,
      recipientUid: recipientUid,
      status: status,
      attempts: attempts,
      reissueCount: reissueCount,
      expiresAt: expiresAt,
      redeemedAt: redeemedAt,
      notificationUid: notificationUid,
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
  final String reportUid;

  @HiveField(3)
  final String purpose;

  @HiveField(4)
  final String createdByUid;

  @HiveField(5)
  final String createdByRole;

  @HiveField(6)
  final String recipientUid;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final int attempts;

  @HiveField(9)
  final int reissueCount;

  @HiveField(10)
  final String expiresAt;

  @HiveField(11)
  final String redeemedAt;

  @HiveField(12)
  final String notificationUid;

  @HiveField(13)
  final String createdAt;

  @HiveField(14)
  final String lastUpdatedAt;

  @HiveField(15)
  final bool synced;
}
