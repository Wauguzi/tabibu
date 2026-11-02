import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/models/conversation_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';

Map<String, dynamic> conversationJson() => {
  'uid': 'uid-conversation-1',
  'type': 'GroupConsult',
  'status': 'Open',
  'createdByUid': 'uid-doctor-1',
  'linkedResourceType': 'Case',
  'linkedResourceUid': 'uid-case-1',
  'specialty': 'Test Specialty',
  'description': 'Test description',
  'participantUids': ['uid-doctor-1', 'uid-pathologist-1'],
  'members': {
    'uid-doctor-1': {
      'uid': 'uid-doctor-1',
      'actorRole': 'doctor',
      'memberRole': 'Owner',
      'status': 'Accepted',
      'title': 'Dr.',
      'firstName': 'Test',
      'lastName': 'Doctor',
      'specialty': 'Test Specialty',
      'profilePictureUrl': '',
      'invitedByUid': 'uid-doctor-1',
      'invitedAt': '2030-05-01T10:00:00.000Z',
      'inviteExpiresAt': '',
      'inviteRound': 1,
      'respondedAt': '2030-05-01T10:05:00.000Z',
    },
  },
  'lastMessage': {
    'uid': 'uid-message-1',
    'senderUid': 'uid-doctor-1',
    'text': 'Test preview',
    'hasAttachment': false,
    'sentAt': '2030-05-01T10:00:00.000Z',
  },
  'lastMessageAt': '2030-05-01T10:00:00.000Z',
  'caseSummary': {
    'caseRef': 'ODR-TEST-001',
    'ageBand': '40-49',
    'sex': 'Female',
    'testTypeNames': ['Test Type'],
    'testNames': ['Test Name'],
    'reportStatus': 'Pending',
    'signedDiagnosisExcerpt': '',
    'signedAt': '',
    'signedByName': '',
    'reportLanguage': 'en',
    'builtAt': '2030-05-01T10:00:00.000Z',
  },
  'createdAt': '2030-05-01T09:00:00.000Z',
  'closedAt': '',
  'lastUpdatedAt': '2030-05-01T10:00:00.000Z',
};

void main() {
  group('ConversationModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = conversationJson();
      final model = ConversationModel.fromJson(json);
      expect(model.type, 'GroupConsult');
      expect(model.members.keys, ['uid-doctor-1']);
      expect(model.members['uid-doctor-1']!.memberRole, 'Owner');
      expect(model.lastMessage.text, 'Test preview');
      expect(model.caseSummary.caseRef, 'ODR-TEST-001');
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = ConversationModel.fromJson({});
      expect(model, ConversationModel.empty());
      expect(model.type, 'GroupConsult');
      expect(model.status, 'Open');
      expect(model.linkedResourceType, 'Case');
      expect(model.members, isEmpty);
    });

    test('toJson never contains synced', () {
      final model = ConversationModel.fromJson(conversationJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('typed getters read their values and fall back', () {
      final model = ConversationModel.fromJson(conversationJson());
      expect(model.typeValue, ConversationType.groupConsult);
      expect(model.statusValue, ConversationStatus.open);
      expect(model.linkedResourceTypeValue, LinkedResourceType.patientCase);
      expect(
        ConversationModel.fromJson({'type': 'Bogus'}).typeValue,
        ConversationType.direct,
      );
      expect(
        ConversationModel.fromJson({'status': 'Bogus'}).statusValue,
        ConversationStatus.closed,
      );
      expect(
        ConversationModel.fromJson({
          'linkedResourceType': 'Bogus',
        }).linkedResourceTypeValue,
        LinkedResourceType.patientCase,
      );
    });
  });

  group('ConversationHive', () {
    test('fromModel maps every field', () {
      final hive = ConversationHive.fromModel(
        ConversationModel.fromJson(conversationJson()),
      );
      expect(hive.uid, 'uid-conversation-1');
      expect(hive.type, 'GroupConsult');
      expect(hive.status, 'Open');
      expect(hive.createdByUid, 'uid-doctor-1');
      expect(hive.linkedResourceType, 'Case');
      expect(hive.linkedResourceUid, 'uid-case-1');
      expect(hive.specialty, 'Test Specialty');
      expect(hive.description, 'Test description');
      expect(hive.participantUids, ['uid-doctor-1', 'uid-pathologist-1']);
      expect(hive.members.keys, ['uid-doctor-1']);
      expect(hive.members['uid-doctor-1']!.memberRole, 'Owner');
      expect(hive.lastMessage.text, 'Test preview');
      expect(hive.lastMessageAt, '2030-05-01T10:00:00.000Z');
      expect(hive.caseSummary.caseRef, 'ODR-TEST-001');
      expect(hive.createdAt, '2030-05-01T09:00:00.000Z');
      expect(hive.closedAt, '');
      expect(hive.lastUpdatedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.synced, isTrue);
    });

    test('toModel round-trips', () {
      final model = ConversationModel.fromJson(conversationJson());
      expect(ConversationHive.fromModel(model).toModel(), model);
    });

    test('an unsynced row stays unsynced', () {
      final model = ConversationModel.fromJson(
        conversationJson(),
      ).copyWith(synced: false);
      expect(ConversationHive.fromModel(model).toModel().synced, isFalse);
    });
  });
}
