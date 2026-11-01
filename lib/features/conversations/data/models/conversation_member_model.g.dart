// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationMemberModel _$ConversationMemberModelFromJson(
  Map<String, dynamic> json,
) => _ConversationMemberModel(
  uid: json['uid'] as String? ?? '',
  actorRole: json['actorRole'] as String? ?? '',
  memberRole: json['memberRole'] as String? ?? 'Member',
  status: json['status'] as String? ?? 'Invited',
  title: json['title'] as String? ?? '',
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  specialty: json['specialty'] as String? ?? '',
  profilePictureUrl: json['profilePictureUrl'] as String? ?? '',
  invitedByUid: json['invitedByUid'] as String? ?? '',
  invitedAt: json['invitedAt'] as String? ?? '',
  inviteExpiresAt: json['inviteExpiresAt'] as String? ?? '',
  inviteRound: (json['inviteRound'] as num?)?.toInt() ?? 0,
  respondedAt: json['respondedAt'] as String? ?? '',
);

Map<String, dynamic> _$ConversationMemberModelToJson(
  _ConversationMemberModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'actorRole': instance.actorRole,
  'memberRole': instance.memberRole,
  'status': instance.status,
  'title': instance.title,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'specialty': instance.specialty,
  'profilePictureUrl': instance.profilePictureUrl,
  'invitedByUid': instance.invitedByUid,
  'invitedAt': instance.invitedAt,
  'inviteExpiresAt': instance.inviteExpiresAt,
  'inviteRound': instance.inviteRound,
  'respondedAt': instance.respondedAt,
};
