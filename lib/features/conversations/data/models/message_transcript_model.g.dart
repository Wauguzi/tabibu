// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_transcript_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageTranscriptModel _$MessageTranscriptModelFromJson(
  Map<String, dynamic> json,
) => _MessageTranscriptModel(
  uid: json['uid'] as String? ?? '',
  conversationUid: json['conversationUid'] as String? ?? '',
  messageUid: json['messageUid'] as String? ?? '',
  senderUid: json['senderUid'] as String? ?? '',
  text: json['text'] as String? ?? '',
  language: json['language'] as String? ?? '',
  acceptedUnchanged: json['acceptedUnchanged'] as bool? ?? false,
  editDistance: (json['editDistance'] as num?)?.toDouble() ?? 0.0,
  models:
      (json['models'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  sharedAt: json['sharedAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$MessageTranscriptModelToJson(
  _MessageTranscriptModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'conversationUid': instance.conversationUid,
  'messageUid': instance.messageUid,
  'senderUid': instance.senderUid,
  'text': instance.text,
  'language': instance.language,
  'acceptedUnchanged': instance.acceptedUnchanged,
  'editDistance': instance.editDistance,
  'models': instance.models,
  'sharedAt': instance.sharedAt,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
