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
    required this.transcriptShared,
    required this.transcriptLanguage,
    required this.inputMode,
    required this.identifierFlagged,
    required this.attachmentPath,
    required this.attachmentType,
    required this.attachmentSize,
    required this.voiceDurationMs,
    required this.voicePeaks,
    required this.withheldReason,
    required this.status,
    required this.sentAt,
    required this.deliveredAt,
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
      transcriptShared: model.transcriptShared,
      transcriptLanguage: model.transcriptLanguage,
      inputMode: model.inputMode,
      identifierFlagged: model.identifierFlagged,
      attachmentPath: model.attachmentPath,
      attachmentType: model.attachmentType,
      attachmentSize: model.attachmentSize,
      voiceDurationMs: model.voiceDurationMs,
      voicePeaks: model.voicePeaks,
      withheldReason: model.withheldReason,
      status: model.status,
      sentAt: model.sentAt,
      deliveredAt: model.deliveredAt,
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
      transcriptShared: transcriptShared,
      transcriptLanguage: transcriptLanguage,
      inputMode: inputMode,
      identifierFlagged: identifierFlagged,
      attachmentPath: attachmentPath,
      attachmentType: attachmentType,
      attachmentSize: attachmentSize,
      voiceDurationMs: voiceDurationMs,
      voicePeaks: voicePeaks,
      withheldReason: withheldReason,
      status: status,
      sentAt: sentAt,
      deliveredAt: deliveredAt,
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
  final String attachmentType;

  @HiveField(9)
  final int voiceDurationMs;

  @HiveField(10)
  final List<int> voicePeaks;

  // Field numbers 11-12 are retired (server-rejected fields); never reuse.
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

  @HiveField(19)
  final bool transcriptShared;

  @HiveField(20, defaultValue: '')
  final String transcriptLanguage;

  @HiveField(21)
  final bool identifierFlagged;

  @HiveField(22, defaultValue: 0)
  final int attachmentSize;

  @HiveField(23, defaultValue: '')
  final String deliveredAt;
}
