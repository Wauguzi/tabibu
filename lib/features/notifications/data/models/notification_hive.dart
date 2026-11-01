import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

part 'notification_hive.g.dart';

/// Cached [NotificationModel], in the same field order.
@HiveType(typeId: 40)
class NotificationHive {
  NotificationHive({
    required this.uid,
    required this.threadUid,
    required this.idempotencyKey,
    required this.creationDate,
    required this.recipientUid,
    required this.recipientRole,
    required this.initiatorUid,
    required this.initiatorRole,
    required this.initiatorName,
    required this.title,
    required this.message,
    required this.templateKey,
    required this.templateArgs,
    required this.category,
    required this.priority,
    required this.channel,
    required this.source,
    required this.scope,
    required this.status,
    required this.readAt,
    required this.resourceType,
    required this.resourceUid,
    required this.metadata,
    required this.pushRequestedAt,
    required this.pushSentAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory NotificationHive.fromModel(NotificationModel model) {
    return NotificationHive(
      uid: model.uid,
      threadUid: model.threadUid,
      idempotencyKey: model.idempotencyKey,
      creationDate: model.creationDate,
      recipientUid: model.recipientUid,
      recipientRole: model.recipientRole,
      initiatorUid: model.initiatorUid,
      initiatorRole: model.initiatorRole,
      initiatorName: model.initiatorName,
      title: model.title,
      message: model.message,
      templateKey: model.templateKey,
      templateArgs: model.templateArgs,
      category: model.category,
      priority: model.priority,
      channel: model.channel,
      source: model.source,
      scope: model.scope,
      status: model.status,
      readAt: model.readAt,
      resourceType: model.resourceType,
      resourceUid: model.resourceUid,
      metadata: NotificationMetadataHive.fromModel(model.metadata),
      pushRequestedAt: model.pushRequestedAt,
      pushSentAt: model.pushSentAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  NotificationModel toModel() {
    return NotificationModel(
      uid: uid,
      threadUid: threadUid,
      idempotencyKey: idempotencyKey,
      creationDate: creationDate,
      recipientUid: recipientUid,
      recipientRole: recipientRole,
      initiatorUid: initiatorUid,
      initiatorRole: initiatorRole,
      initiatorName: initiatorName,
      title: title,
      message: message,
      templateKey: templateKey,
      templateArgs: templateArgs,
      category: category,
      priority: priority,
      channel: channel,
      source: source,
      scope: scope,
      status: status,
      readAt: readAt,
      resourceType: resourceType,
      resourceUid: resourceUid,
      metadata: metadata.toModel(),
      pushRequestedAt: pushRequestedAt,
      pushSentAt: pushSentAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String threadUid;

  @HiveField(2)
  final String idempotencyKey;

  @HiveField(3)
  final String creationDate;

  @HiveField(4)
  final String recipientUid;

  @HiveField(5)
  final String recipientRole;

  @HiveField(6)
  final String initiatorUid;

  @HiveField(7)
  final String initiatorRole;

  @HiveField(8)
  final String initiatorName;

  @HiveField(9)
  final String title;

  @HiveField(10)
  final String message;

  @HiveField(11)
  final String templateKey;

  @HiveField(12)
  final Map<String, String> templateArgs;

  @HiveField(13)
  final String category;

  @HiveField(14)
  final String priority;

  @HiveField(15)
  final String channel;

  @HiveField(16)
  final String source;

  @HiveField(17)
  final String scope;

  @HiveField(18)
  final String status;

  @HiveField(19)
  final String readAt;

  @HiveField(20)
  final String resourceType;

  @HiveField(21)
  final String resourceUid;

  @HiveField(22)
  final NotificationMetadataHive metadata;

  @HiveField(23)
  final String pushRequestedAt;

  @HiveField(24)
  final String pushSentAt;

  @HiveField(25)
  final String lastUpdatedAt;

  @HiveField(26)
  final bool synced;
}
