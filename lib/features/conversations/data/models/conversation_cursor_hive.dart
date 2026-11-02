import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_model.dart';

part 'conversation_cursor_hive.g.dart';

/// Cached [ConversationCursorModel], in the same field order.
@HiveType(typeId: 37)
class ConversationCursorHive {
  ConversationCursorHive({
    required this.uid,
    required this.conversationUid,
    required this.lastReadAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory ConversationCursorHive.fromModel(ConversationCursorModel model) {
    return ConversationCursorHive(
      uid: model.uid,
      conversationUid: model.conversationUid,
      lastReadAt: model.lastReadAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  ConversationCursorModel toModel() {
    return ConversationCursorModel(
      uid: uid,
      conversationUid: conversationUid,
      lastReadAt: lastReadAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String conversationUid;

  @HiveField(2)
  final String lastReadAt;

  @HiveField(3)
  final String lastUpdatedAt;

  @HiveField(4)
  final bool synced;
}
