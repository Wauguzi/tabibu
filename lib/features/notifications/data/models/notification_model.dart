import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_model.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// A `notifications/{uid}` document for one recipient. Written by Cloud
/// Functions; the app updates only `status`, `readAt` and `lastUpdatedAt`.
@freezed
abstract class NotificationModel with _$NotificationModel {
  // Nested metadata must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory NotificationModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'threadUid') @Default('') String threadUid,
    @JsonKey(name: 'idempotencyKey') @Default('') String idempotencyKey,
    @JsonKey(name: 'creationDate') @Default('') String creationDate,
    @JsonKey(name: 'recipientUid') @Default('') String recipientUid,
    @JsonKey(name: 'recipientRole') @Default('') String recipientRole,
    @JsonKey(name: 'initiatorUid') @Default('') String initiatorUid,
    @JsonKey(name: 'initiatorRole') @Default('') String initiatorRole,
    @JsonKey(name: 'initiatorName') @Default('') String initiatorName,
    @JsonKey(name: 'title') @Default('') String title,
    @JsonKey(name: 'message') @Default('') String message,
    @JsonKey(name: 'templateKey') @Default('') String templateKey,
    @JsonKey(name: 'templateArgs')
    @Default(<String, String>{})
    Map<String, String> templateArgs,
    @JsonKey(name: 'category') @Default('') String category,
    @JsonKey(name: 'priority') @Default('') String priority,
    @JsonKey(name: 'channel') @Default('') String channel,
    @JsonKey(name: 'source') @Default('') String source,
    @JsonKey(name: 'scope') @Default('') String scope,
    @JsonKey(name: 'status') @Default('Unread') String status,
    @JsonKey(name: 'readAt') @Default('') String readAt,
    @JsonKey(name: 'resourceType') @Default('') String resourceType,
    @JsonKey(name: 'resourceUid') @Default('') String resourceUid,
    @JsonKey(name: 'metadata')
    @Default(NotificationMetadataModel())
    NotificationMetadataModel metadata,
    @JsonKey(name: 'pushRequestedAt') @Default('') String pushRequestedAt,
    @JsonKey(name: 'pushSentAt') @Default('') String pushSentAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _NotificationModel;

  const NotificationModel._();

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.empty() => const NotificationModel();

  /// A device-only row that never goes to the cloud.
  factory NotificationModel.local({
    required String uid,
    required String recipientUid,
    required String templateKey,
    required Map<String, String> templateArgs,
    required String category,
    required String resourceType,
    required String resourceUid,
    required String creationDate,
    String title = '',
    String message = '',
  }) => NotificationModel(
    uid: uid,
    idempotencyKey: uid,
    recipientUid: recipientUid,
    templateKey: templateKey,
    templateArgs: templateArgs,
    category: category,
    resourceType: resourceType,
    resourceUid: resourceUid,
    creationDate: creationDate,
    title: title,
    message: message,
    scope: NotificationScope.local.value,
    source: NotificationSource.app.value,
    channel: NotificationChannel.inApp.value,
  );

  NotificationCategory get categoryValue =>
      NotificationCategory.fromValue(category);

  NotificationPriority get priorityValue =>
      NotificationPriority.fromValue(priority);

  NotificationChannel get channelValue =>
      NotificationChannel.fromValue(channel);

  NotificationSource get sourceValue => NotificationSource.fromValue(source);

  NotificationScope get scopeValue => NotificationScope.fromValue(scope);

  NotificationStatus get statusValue => NotificationStatus.fromValue(status);

  NotificationResourceType get resourceTypeValue =>
      NotificationResourceType.fromValue(resourceType);

  bool get isRead => statusValue != NotificationStatus.unread;

  bool get isLocalOnly => scopeValue == NotificationScope.local;

  bool get hasShareCode => metadata.shareCode.isNotEmpty;

  /// True when `metadata.expiresAt` is a non-empty ISO string earlier than
  /// `now`.
  bool isExpired(DateTime now) {
    if (metadata.expiresAt.isEmpty) return false;
    final expires = DateTime.tryParse(metadata.expiresAt);
    if (expires == null) return false;
    return expires.isBefore(now);
  }

  bool isActionable(DateTime now) =>
      metadata.actionTypeValue == NotificationActionType.approval &&
      metadata.actionStatusValue == NotificationActionStatus.pending &&
      !isExpired(now);
}
