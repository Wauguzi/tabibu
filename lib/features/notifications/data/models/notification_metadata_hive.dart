import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_model.dart';

part 'notification_metadata_hive.g.dart';

/// Cached [NotificationMetadataModel], in the same field order.
@HiveType(typeId: 41)
class NotificationMetadataHive {
  NotificationMetadataHive({
    required this.actionType,
    required this.actionStatus,
    required this.actionedByUid,
    required this.actionedAt,
    required this.expiresAt,
    required this.deepLink,
    required this.shareCode,
    required this.extras,
  });

  factory NotificationMetadataHive.fromModel(NotificationMetadataModel model) {
    return NotificationMetadataHive(
      actionType: model.actionType,
      actionStatus: model.actionStatus,
      actionedByUid: model.actionedByUid,
      actionedAt: model.actionedAt,
      expiresAt: model.expiresAt,
      deepLink: model.deepLink,
      shareCode: model.shareCode,
      extras: model.extras,
    );
  }

  NotificationMetadataModel toModel() {
    return NotificationMetadataModel(
      actionType: actionType,
      actionStatus: actionStatus,
      actionedByUid: actionedByUid,
      actionedAt: actionedAt,
      expiresAt: expiresAt,
      deepLink: deepLink,
      shareCode: shareCode,
      extras: extras,
    );
  }

  @HiveField(0)
  final String actionType;

  @HiveField(1)
  final String actionStatus;

  @HiveField(2)
  final String actionedByUid;

  @HiveField(3)
  final String actionedAt;

  @HiveField(4)
  final String expiresAt;

  @HiveField(5)
  final String deepLink;

  @HiveField(6)
  final String shareCode;

  @HiveField(7)
  final Map<String, String> extras;
}
