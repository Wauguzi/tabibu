import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_model.dart';

Map<String, dynamic> conversationCursorJson() => {
  'uid': 'uid-doctor-1',
  'conversationUid': 'uid-conversation-1',
  'lastReadAt': '2030-05-01T10:00:00.000Z',
  'lastUpdatedAt': '2030-05-01T10:00:00.000Z',
};

void main() {
  group('ConversationCursorModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = conversationCursorJson();
      final model = ConversationCursorModel.fromJson(json);
      expect(model.lastReadAt, '2030-05-01T10:00:00.000Z');
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = ConversationCursorModel.fromJson({});
      expect(model, ConversationCursorModel.empty());
    });

    test('toJson never contains synced', () {
      final model = ConversationCursorModel.fromJson(conversationCursorJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });
  });

  group('ConversationCursorHive', () {
    test('fromModel maps every field', () {
      final hive = ConversationCursorHive.fromModel(
        ConversationCursorModel.fromJson(conversationCursorJson()),
      );
      expect(hive.uid, 'uid-doctor-1');
      expect(hive.conversationUid, 'uid-conversation-1');
      expect(hive.lastReadAt, '2030-05-01T10:00:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = ConversationCursorModel.fromJson(conversationCursorJson());
      expect(ConversationCursorHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = ConversationCursorModel.fromJson(
        conversationCursorJson(),
      ).copyWith(synced: false);
      expect(ConversationCursorHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
