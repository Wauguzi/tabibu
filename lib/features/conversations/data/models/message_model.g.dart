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
      transcriptShared: json['transcriptShared'] as bool? ?? false,
      transcriptLanguage: json['transcriptLanguage'] as String? ?? '',
      inputMode: json['inputMode'] as String? ?? 'Typed',
      identifierFlagged: json['identifierFlagged'] as bool? ?? false,
      attachmentPath: json['attachmentPath'] as String? ?? '',
      attachmentType: json['attachmentType'] as String? ?? '',
      attachmentSize: (json['attachmentSize'] as num?)?.toInt() ?? 0,
      voiceDurationMs: (json['voiceDurationMs'] as num?)?.toInt() ?? 0,
      voicePeaks:
          (json['voicePeaks'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      withheldReason: json['withheldReason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      sentAt: json['sentAt'] as String? ?? '',
      deliveredAt: json['deliveredAt'] as String? ?? '',
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
      'transcriptShared': instance.transcriptShared,
      'transcriptLanguage': instance.transcriptLanguage,
      'inputMode': instance.inputMode,
      'identifierFlagged': instance.identifierFlagged,
      'attachmentPath': instance.attachmentPath,
      'attachmentType': instance.attachmentType,
      'attachmentSize': instance.attachmentSize,
      'voiceDurationMs': instance.voiceDurationMs,
      'voicePeaks': instance.voicePeaks,
      'withheldReason': instance.withheldReason,
      'status': instance.status,
      'sentAt': instance.sentAt,
      'deliveredAt': instance.deliveredAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
