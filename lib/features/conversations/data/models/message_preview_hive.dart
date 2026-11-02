import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_model.dart';

part 'message_preview_hive.g.dart';

/// Cached [MessagePreviewModel], in the same field order.
@HiveType(typeId: 36)
class MessagePreviewHive {
  MessagePreviewHive({
    required this.uid,
    required this.senderUid,
    required this.text,
    required this.hasAttachment,
    required this.sentAt,
  });

  factory MessagePreviewHive.fromModel(MessagePreviewModel model) {
    return MessagePreviewHive(
      uid: model.uid,
      senderUid: model.senderUid,
      text: model.text,
      hasAttachment: model.hasAttachment,
      sentAt: model.sentAt,
    );
  }

  MessagePreviewModel toModel() {
    return MessagePreviewModel(
      uid: uid,
      senderUid: senderUid,
      text: text,
      hasAttachment: hasAttachment,
      sentAt: sentAt,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String senderUid;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final bool hasAttachment;

  @HiveField(4)
  final String sentAt;
}
