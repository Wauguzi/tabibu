// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      uid: json['uid'] as String? ?? '',
      threadUid: json['threadUid'] as String? ?? '',
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      creationDate: json['creationDate'] as String? ?? '',
      recipientUid: json['recipientUid'] as String? ?? '',
      recipientRole: json['recipientRole'] as String? ?? '',
      initiatorUid: json['initiatorUid'] as String? ?? '',
      initiatorRole: json['initiatorRole'] as String? ?? '',
      initiatorName: json['initiatorName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      templateKey: json['templateKey'] as String? ?? '',
      templateArgs:
          (json['templateArgs'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      category: json['category'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      source: json['source'] as String? ?? '',
      scope: json['scope'] as String? ?? '',
      status: json['status'] as String? ?? 'Unread',
      readAt: json['readAt'] as String? ?? '',
      resourceType: json['resourceType'] as String? ?? '',
      resourceUid: json['resourceUid'] as String? ?? '',
      metadata: json['metadata'] == null
          ? const NotificationMetadataModel()
          : NotificationMetadataModel.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
      pushRequestedAt: json['pushRequestedAt'] as String? ?? '',
      pushSentAt: json['pushSentAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'threadUid': instance.threadUid,
      'idempotencyKey': instance.idempotencyKey,
      'creationDate': instance.creationDate,
      'recipientUid': instance.recipientUid,
      'recipientRole': instance.recipientRole,
      'initiatorUid': instance.initiatorUid,
      'initiatorRole': instance.initiatorRole,
      'initiatorName': instance.initiatorName,
      'title': instance.title,
      'message': instance.message,
      'templateKey': instance.templateKey,
      'templateArgs': instance.templateArgs,
      'category': instance.category,
      'priority': instance.priority,
      'channel': instance.channel,
      'source': instance.source,
      'scope': instance.scope,
      'status': instance.status,
      'readAt': instance.readAt,
      'resourceType': instance.resourceType,
      'resourceUid': instance.resourceUid,
      'metadata': instance.metadata.toJson(),
      'pushRequestedAt': instance.pushRequestedAt,
      'pushSentAt': instance.pushSentAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
