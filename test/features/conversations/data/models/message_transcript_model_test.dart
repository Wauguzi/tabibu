import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_model.dart';

Map<String, dynamic> messageTranscriptJson() => {
  'uid': 'uid-message-1_Voice',
  'conversationUid': 'uid-conversation-1',
  'messageUid': 'uid-message-1',
  'senderUid': 'uid-doctor-1',
  'text': 'Test transcript',
  'language': 'en',
  'acceptedUnchanged': true,
  'editDistance': 0.0,
  'models': {'transcribe': 'test-model-1'},
  'sharedAt': '2030-05-01T10:00:00.000Z',
  'lastUpdatedAt': '2030-05-01T10:00:00.000Z',
};

void main() {
  group('MessageTranscriptModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = messageTranscriptJson();
      final model = MessageTranscriptModel.fromJson(json);
      expect(model.text, 'Test transcript');
      expect(model.acceptedUnchanged, isTrue);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = MessageTranscriptModel.fromJson({});
      expect(model, MessageTranscriptModel.empty());
    });

    test('toJson never contains synced', () {
      final model = MessageTranscriptModel.fromJson(messageTranscriptJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });
  });

  group('MessageTranscriptHive', () {
    test('fromModel maps every field', () {
      final hive = MessageTranscriptHive.fromModel(
        MessageTranscriptModel.fromJson(messageTranscriptJson()),
      );
      expect(hive.uid, 'uid-message-1_Voice');
      expect(hive.conversationUid, 'uid-conversation-1');
      expect(hive.messageUid, 'uid-message-1');
      expect(hive.senderUid, 'uid-doctor-1');
      expect(hive.text, 'Test transcript');
      expect(hive.language, 'en');
      expect(hive.acceptedUnchanged, isTrue);
      expect(hive.editDistance, 0.0);
      expect(hive.models, {'transcribe': 'test-model-1'});
      expect(hive.sharedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.lastUpdatedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = MessageTranscriptModel.fromJson(messageTranscriptJson());
      expect(MessageTranscriptHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = MessageTranscriptModel.fromJson(
        messageTranscriptJson(),
      ).copyWith(synced: false);
      expect(MessageTranscriptHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
