import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_model.dart';

part 'message_transcript_hive.g.dart';

/// Cached [MessageTranscriptModel], in the same field order.
@HiveType(typeId: 38)
class MessageTranscriptHive {
  MessageTranscriptHive({
    required this.uid,
    required this.conversationUid,
    required this.messageUid,
    required this.senderUid,
    required this.text,
    required this.language,
    required this.acceptedUnchanged,
    required this.editDistance,
    required this.models,
    required this.sharedAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory MessageTranscriptHive.fromModel(MessageTranscriptModel model) {
    return MessageTranscriptHive(
      uid: model.uid,
      conversationUid: model.conversationUid,
      messageUid: model.messageUid,
      senderUid: model.senderUid,
      text: model.text,
      language: model.language,
      acceptedUnchanged: model.acceptedUnchanged,
      editDistance: model.editDistance,
      models: model.models,
      sharedAt: model.sharedAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  MessageTranscriptModel toModel() {
    return MessageTranscriptModel(
      uid: uid,
      conversationUid: conversationUid,
      messageUid: messageUid,
      senderUid: senderUid,
      text: text,
      language: language,
      acceptedUnchanged: acceptedUnchanged,
      editDistance: editDistance,
      models: models,
      sharedAt: sharedAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String conversationUid;

  @HiveField(2)
  final String messageUid;

  @HiveField(3)
  final String senderUid;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final String language;

  @HiveField(6)
  final bool acceptedUnchanged;

  @HiveField(7)
  final double editDistance;

  @HiveField(8)
  final Map<String, String> models;

  @HiveField(9)
  final String sharedAt;

  @HiveField(10)
  final String lastUpdatedAt;

  @HiveField(11)
  final bool synced;
}
