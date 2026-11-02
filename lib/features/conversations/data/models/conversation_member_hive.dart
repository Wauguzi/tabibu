import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';

part 'conversation_member_hive.g.dart';

/// Cached [ConversationMemberModel], in the same field order.
@HiveType(typeId: 33)
class ConversationMemberHive {
  ConversationMemberHive({
    required this.uid,
    required this.actorRole,
    required this.memberRole,
    required this.status,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.profilePictureUrl,
    required this.invitedByUid,
    required this.invitedAt,
    required this.inviteExpiresAt,
    required this.inviteRound,
    required this.respondedAt,
  });

  factory ConversationMemberHive.fromModel(ConversationMemberModel model) {
    return ConversationMemberHive(
      uid: model.uid,
      actorRole: model.actorRole,
      memberRole: model.memberRole,
      status: model.status,
      title: model.title,
      firstName: model.firstName,
      lastName: model.lastName,
      specialty: model.specialty,
      profilePictureUrl: model.profilePictureUrl,
      invitedByUid: model.invitedByUid,
      invitedAt: model.invitedAt,
      inviteExpiresAt: model.inviteExpiresAt,
      inviteRound: model.inviteRound,
      respondedAt: model.respondedAt,
    );
  }

  ConversationMemberModel toModel() {
    return ConversationMemberModel(
      uid: uid,
      actorRole: actorRole,
      memberRole: memberRole,
      status: status,
      title: title,
      firstName: firstName,
      lastName: lastName,
      specialty: specialty,
      profilePictureUrl: profilePictureUrl,
      invitedByUid: invitedByUid,
      invitedAt: invitedAt,
      inviteExpiresAt: inviteExpiresAt,
      inviteRound: inviteRound,
      respondedAt: respondedAt,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String actorRole;

  @HiveField(2)
  final String memberRole;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final String firstName;

  @HiveField(6)
  final String lastName;

  @HiveField(7)
  final String specialty;

  @HiveField(8)
  final String profilePictureUrl;

  @HiveField(9)
  final String invitedByUid;

  @HiveField(10)
  final String invitedAt;

  @HiveField(11)
  final String inviteExpiresAt;

  @HiveField(12)
  final int inviteRound;

  @HiveField(13)
  final String respondedAt;
}
