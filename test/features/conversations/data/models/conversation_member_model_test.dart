import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';

Map<String, dynamic> conversationMemberJson() => {
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
};

void main() {
  group('ConversationMemberModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = conversationMemberJson();
      final model = ConversationMemberModel.fromJson(json);
      expect(model.memberRole, 'Owner');
      expect(model.inviteRound, 1);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = ConversationMemberModel.fromJson({});
      expect(model, ConversationMemberModel.empty());
      expect(model.memberRole, 'Member');
      expect(model.status, 'Invited');
    });

    test('typed getters read their values and fall back', () {
      final model = ConversationMemberModel.fromJson(conversationMemberJson());
      expect(model.memberRoleValue, MemberRole.owner);
      expect(model.statusValue, MemberStatus.accepted);
      expect(
        ConversationMemberModel.fromJson({
          'memberRole': 'Bogus',
        }).memberRoleValue,
        MemberRole.member,
      );
      expect(
        ConversationMemberModel.fromJson({'status': 'Bogus'}).statusValue,
        MemberStatus.removed,
      );
    });
  });

  group('ConversationMemberHive', () {
    test('fromModel maps every field', () {
      final hive = ConversationMemberHive.fromModel(
        ConversationMemberModel.fromJson(conversationMemberJson()),
      );
      expect(hive.uid, 'uid-doctor-1');
      expect(hive.actorRole, 'doctor');
      expect(hive.memberRole, 'Owner');
      expect(hive.status, 'Accepted');
      expect(hive.title, 'Dr.');
      expect(hive.firstName, 'Test');
      expect(hive.lastName, 'Doctor');
      expect(hive.specialty, 'Test Specialty');
      expect(hive.profilePictureUrl, '');
      expect(hive.invitedByUid, 'uid-doctor-1');
      expect(hive.invitedAt, '2030-05-01T10:00:00.000Z');
      expect(hive.inviteExpiresAt, '');
      expect(hive.inviteRound, 1);
      expect(hive.respondedAt, '2030-05-01T10:05:00.000Z');
    });

    test('toModel round-trips', () {
      final model = ConversationMemberModel.fromJson(conversationMemberJson());
      expect(ConversationMemberHive.fromModel(model).toModel(), model);
    });
  });
}
