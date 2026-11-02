// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_metadata_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationMetadataModel _$NotificationMetadataModelFromJson(
  Map<String, dynamic> json,
) => _NotificationMetadataModel(
  actionType: json['actionType'] as String? ?? '',
  actionStatus: json['actionStatus'] as String? ?? '',
  actionedByUid: json['actionedByUid'] as String? ?? '',
  actionedAt: json['actionedAt'] as String? ?? '',
  expiresAt: json['expiresAt'] as String? ?? '',
  deepLink: json['deepLink'] as String? ?? '',
  shareCode: json['shareCode'] as String? ?? '',
  extras:
      (json['extras'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
);

Map<String, dynamic> _$NotificationMetadataModelToJson(
  _NotificationMetadataModel instance,
) => <String, dynamic>{
  'actionType': instance.actionType,
  'actionStatus': instance.actionStatus,
  'actionedByUid': instance.actionedByUid,
  'actionedAt': instance.actionedAt,
  'expiresAt': instance.expiresAt,
  'deepLink': instance.deepLink,
  'shareCode': instance.shareCode,
  'extras': instance.extras,
};
