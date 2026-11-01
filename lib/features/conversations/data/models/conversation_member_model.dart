import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'conversation_member_model.freezed.dart';
part 'conversation_member_model.g.dart';

/// One value of a conversation's `members` map, keyed by uid.
@freezed
abstract class ConversationMemberModel with _$ConversationMemberModel {
  const factory ConversationMemberModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'actorRole') @Default('') String actorRole,
    @JsonKey(name: 'memberRole') @Default('Member') String memberRole,
    @JsonKey(name: 'status') @Default('Invited') String status,
    @JsonKey(name: 'title') @Default('') String title,
    @JsonKey(name: 'firstName') @Default('') String firstName,
    @JsonKey(name: 'lastName') @Default('') String lastName,
    @JsonKey(name: 'specialty') @Default('') String specialty,
    @JsonKey(name: 'profilePictureUrl') @Default('') String profilePictureUrl,
    @JsonKey(name: 'invitedByUid') @Default('') String invitedByUid,
    @JsonKey(name: 'invitedAt') @Default('') String invitedAt,
    @JsonKey(name: 'inviteExpiresAt') @Default('') String inviteExpiresAt,
    @JsonKey(name: 'inviteRound') @Default(0) int inviteRound,
    @JsonKey(name: 'respondedAt') @Default('') String respondedAt,
  }) = _ConversationMemberModel;

  const ConversationMemberModel._();

  factory ConversationMemberModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberModelFromJson(json);

  factory ConversationMemberModel.empty() => const ConversationMemberModel();

  MemberRole get memberRoleValue => MemberRole.fromValue(memberRole);

  MemberStatus get statusValue => MemberStatus.fromValue(status);
}
