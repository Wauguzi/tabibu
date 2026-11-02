import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_model.dart';

Map<String, dynamic> messagePreviewJson() => {
  'uid': 'uid-message-1',
  'senderUid': 'uid-doctor-1',
  'text': 'Test preview',
  'hasAttachment': true,
  'sentAt': '2030-05-01T10:00:00.000Z',
};

void main() {
  group('MessagePreviewModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = messagePreviewJson();
      final model = MessagePreviewModel.fromJson(json);
      expect(model.text, 'Test preview');
      expect(model.hasAttachment, isTrue);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = MessagePreviewModel.fromJson({});
      expect(model, MessagePreviewModel.empty());
    });
  });

  group('MessagePreviewHive', () {
    test('fromModel maps every field', () {
      final hive = MessagePreviewHive.fromModel(
        MessagePreviewModel.fromJson(messagePreviewJson()),
      );
      expect(hive.uid, 'uid-message-1');
      expect(hive.senderUid, 'uid-doctor-1');
      expect(hive.text, 'Test preview');
      expect(hive.hasAttachment, isTrue);
      expect(hive.sentAt, '2030-05-01T10:00:00.000Z');
    });

    test('toModel round-trips', () {
      final model = MessagePreviewModel.fromJson(messagePreviewJson());
      expect(MessagePreviewHive.fromModel(model).toModel(), model);
    });
  });
}
