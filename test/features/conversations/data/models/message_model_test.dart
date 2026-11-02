import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/models/message_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';

Map<String, dynamic> messageJson() => {
  'uid': 'uid-message-1',
  'conversationUid': 'uid-conversation-1',
  'senderUid': 'uid-doctor-1',
  'kind': 'Voice',
  'text': 'Test message',
  'transcriptStatus': 'Ready',
  'transcriptShared': false,
  'transcriptLanguage': 'sw',
  'inputMode': 'Voice',
  'identifierFlagged': false,
  'attachmentPath': 'conversations/uid-conversation-1/uid-message-1.m4a',
  'attachmentType': 'audio/mp4',
  'attachmentSize': 42000,
  'voiceDurationMs': 5000,
  'voicePeaks': [1, 2, 3],
  'withheldReason': '',
  'status': 'Sent',
  'sentAt': '2030-05-01T10:00:00.000Z',
  'deliveredAt': '',
  'lastUpdatedAt': '2030-05-01T10:00:00.000Z',
};

void main() {
  group('MessageModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = messageJson();
      final model = MessageModel.fromJson(json);
      expect(model.kind, 'Voice');
      expect(model.voicePeaks, [1, 2, 3]);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = MessageModel.fromJson({});
      expect(model, MessageModel.empty());
      expect(model.kind, 'Text');
      expect(model.transcriptStatus, 'None');
      expect(model.inputMode, 'Typed');
    });

    test('toJson never contains synced or the local attachment path', () {
      final model = MessageModel.fromJson(
        messageJson(),
      ).copyWith(localAttachmentPath: '/tmp/test.m4a');
      expect(model.toJson().containsKey('synced'), isFalse);
      expect(model.toJson().containsKey('localAttachmentPath'), isFalse);
    });

    test('typed getters read their values and fall back', () {
      final model = MessageModel.fromJson(messageJson());
      expect(model.kindValue, MessageKind.voice);
      expect(model.transcriptStatusValue, TranscriptStatus.ready);
      expect(model.inputModeValue, InputMode.voice);
      expect(model.statusValue, MessageStatus.sent);
      expect(
        MessageModel.fromJson({'kind': 'Bogus'}).kindValue,
        MessageKind.text,
      );
      expect(
        MessageModel.fromJson({
          'transcriptStatus': 'Bogus',
        }).transcriptStatusValue,
        TranscriptStatus.noTranscript,
      );
      expect(
        MessageModel.fromJson({'inputMode': 'Bogus'}).inputModeValue,
        InputMode.typed,
      );
      expect(
        MessageModel.fromJson({'status': 'Bogus'}).statusValue,
        MessageStatus.withheld,
      );
    });
  });

  group('MessageHive', () {
    test('fromModel maps every field', () {
      final hive = MessageHive.fromModel(
        MessageModel.fromJson(
          messageJson(),
        ).copyWith(localAttachmentPath: '/tmp/test.m4a'),
      );
      expect(hive.uid, 'uid-message-1');
      expect(hive.conversationUid, 'uid-conversation-1');
      expect(hive.senderUid, 'uid-doctor-1');
      expect(hive.kind, 'Voice');
      expect(hive.text, 'Test message');
      expect(hive.transcriptStatus, 'Ready');
      expect(hive.transcriptShared, isFalse);
      expect(hive.transcriptLanguage, 'sw');
      expect(hive.inputMode, 'Voice');
      expect(hive.identifierFlagged, isFalse);
      expect(
        hive.attachmentPath,
        'conversations/uid-conversation-1/uid-message-1.m4a',
      );
      expect(hive.attachmentType, 'audio/mp4');
      expect(hive.attachmentSize, 42000);
      expect(hive.voiceDurationMs, 5000);
      expect(hive.voicePeaks, [1, 2, 3]);
      expect(hive.withheldReason, '');
      expect(hive.status, 'Sent');
      expect(hive.sentAt, '2030-05-01T10:00:00.000Z');
      expect(hive.deliveredAt, '');
      expect(hive.localAttachmentPath, '/tmp/test.m4a');
      expect(hive.lastUpdatedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = MessageModel.fromJson(messageJson());
      expect(MessageHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = MessageModel.fromJson(
        messageJson(),
      ).copyWith(synced: false);
      expect(MessageHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
