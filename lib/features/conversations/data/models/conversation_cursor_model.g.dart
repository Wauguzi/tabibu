// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_cursor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationCursorModel _$ConversationCursorModelFromJson(
  Map<String, dynamic> json,
) => _ConversationCursorModel(
  uid: json['uid'] as String? ?? '',
  conversationUid: json['conversationUid'] as String? ?? '',
  lastReadAt: json['lastReadAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$ConversationCursorModelToJson(
  _ConversationCursorModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'conversationUid': instance.conversationUid,
  'lastReadAt': instance.lastReadAt,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
