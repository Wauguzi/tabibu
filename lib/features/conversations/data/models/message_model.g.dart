// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      uid: json['uid'] as String? ?? '',
      conversationUid: json['conversationUid'] as String? ?? '',
      senderUid: json['senderUid'] as String? ?? '',
      kind: json['kind'] as String? ?? 'Text',
      text: json['text'] as String? ?? '',
      transcriptStatus: json['transcriptStatus'] as String? ?? 'None',
      inputMode: json['inputMode'] as String? ?? 'Typed',
      attachmentPath: json['attachmentPath'] as String? ?? '',
      attachmentContentType: json['attachmentContentType'] as String? ?? '',
      attachmentDurationMs:
          (json['attachmentDurationMs'] as num?)?.toInt() ?? 0,
      voicePeaks:
          (json['voicePeaks'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      voiceWaveformId: json['voiceWaveformId'] as String? ?? '',
      replyToMessageUid: json['replyToMessageUid'] as String? ?? '',
      withheldReason: json['withheldReason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      sentAt: json['sentAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'conversationUid': instance.conversationUid,
      'senderUid': instance.senderUid,
      'kind': instance.kind,
      'text': instance.text,
      'transcriptStatus': instance.transcriptStatus,
      'inputMode': instance.inputMode,
      'attachmentPath': instance.attachmentPath,
      'attachmentContentType': instance.attachmentContentType,
      'attachmentDurationMs': instance.attachmentDurationMs,
      'voicePeaks': instance.voicePeaks,
      'voiceWaveformId': instance.voiceWaveformId,
      'replyToMessageUid': instance.replyToMessageUid,
      'withheldReason': instance.withheldReason,
      'status': instance.status,
      'sentAt': instance.sentAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
