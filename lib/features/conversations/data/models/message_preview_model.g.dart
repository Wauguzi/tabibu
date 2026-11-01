// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_preview_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessagePreviewModel _$MessagePreviewModelFromJson(Map<String, dynamic> json) =>
    _MessagePreviewModel(
      uid: json['uid'] as String? ?? '',
      senderUid: json['senderUid'] as String? ?? '',
      text: json['text'] as String? ?? '',
      hasAttachment: json['hasAttachment'] as bool? ?? false,
      sentAt: json['sentAt'] as String? ?? '',
    );

Map<String, dynamic> _$MessagePreviewModelToJson(
  _MessagePreviewModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'senderUid': instance.senderUid,
  'text': instance.text,
  'hasAttachment': instance.hasAttachment,
  'sentAt': instance.sentAt,
};
