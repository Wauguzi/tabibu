import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';

part 'message_hive.g.dart';

/// Cached [MessageModel], in the same field order.
@HiveType(typeId: 35)
class MessageHive {
  MessageHive({
    required this.uid,
    required this.conversationUid,
    required this.senderUid,
    required this.kind,
    required this.text,
    required this.transcriptStatus,
    required this.inputMode,
    required this.attachmentPath,
    required this.attachmentContentType,
    required this.attachmentDurationMs,
    required this.voicePeaks,
    required this.voiceWaveformId,
    required this.replyToMessageUid,
    required this.withheldReason,
    required this.status,
    required this.sentAt,
    required this.localAttachmentPath,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory MessageHive.fromModel(MessageModel model) {
    return MessageHive(
      uid: model.uid,
      conversationUid: model.conversationUid,
      senderUid: model.senderUid,
      kind: model.kind,
      text: model.text,
      transcriptStatus: model.transcriptStatus,
      inputMode: model.inputMode,
      attachmentPath: model.attachmentPath,
      attachmentContentType: model.attachmentContentType,
      attachmentDurationMs: model.attachmentDurationMs,
      voicePeaks: model.voicePeaks,
      voiceWaveformId: model.voiceWaveformId,
      replyToMessageUid: model.replyToMessageUid,
      withheldReason: model.withheldReason,
      status: model.status,
      sentAt: model.sentAt,
      localAttachmentPath: model.localAttachmentPath,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  MessageModel toModel() {
    return MessageModel(
      uid: uid,
      conversationUid: conversationUid,
      senderUid: senderUid,
      kind: kind,
      text: text,
      transcriptStatus: transcriptStatus,
      inputMode: inputMode,
      attachmentPath: attachmentPath,
      attachmentContentType: attachmentContentType,
      attachmentDurationMs: attachmentDurationMs,
      voicePeaks: voicePeaks,
      voiceWaveformId: voiceWaveformId,
      replyToMessageUid: replyToMessageUid,
      withheldReason: withheldReason,
      status: status,
      sentAt: sentAt,
      localAttachmentPath: localAttachmentPath,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String conversationUid;

  @HiveField(2)
  final String senderUid;

  @HiveField(3)
  final String kind;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final String transcriptStatus;

  @HiveField(6)
  final String inputMode;

  @HiveField(7)
  final String attachmentPath;

  @HiveField(8)
  final String attachmentContentType;

  @HiveField(9)
  final int attachmentDurationMs;

  @HiveField(10)
  final List<int> voicePeaks;

  @HiveField(11)
  final String voiceWaveformId;

  @HiveField(12)
  final String replyToMessageUid;

  @HiveField(13)
  final String withheldReason;

  @HiveField(14)
  final String status;

  @HiveField(15)
  final String sentAt;

  @HiveField(16)
  final String localAttachmentPath;

  @HiveField(17)
  final String lastUpdatedAt;

  @HiveField(18)
  final bool synced;
}
