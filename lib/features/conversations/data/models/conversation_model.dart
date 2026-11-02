import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_model.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_model.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

/// A `conversations/{uid}` document: a group consult or a direct thread.
@freezed
abstract class ConversationModel with _$ConversationModel {
  // Nested members, preview and summary must call toJson(); freezed puts
  // this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ConversationModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'type') @Default('GroupConsult') String type,
    @JsonKey(name: 'status') @Default('Open') String status,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'linkedResourceType')
    @Default('Case')
    String linkedResourceType,
    @JsonKey(name: 'linkedResourceUid') @Default('') String linkedResourceUid,
    @JsonKey(name: 'specialty') @Default('') String specialty,
    @JsonKey(name: 'description') @Default('') String description,
    @JsonKey(name: 'participantUids')
    @Default(<String>[])
    List<String> participantUids,
    @JsonKey(name: 'members')
    @Default(<String, ConversationMemberModel>{})
    Map<String, ConversationMemberModel> members,
    @JsonKey(name: 'lastMessage')
    @Default(MessagePreviewModel())
    MessagePreviewModel lastMessage,
    @JsonKey(name: 'lastMessageAt') @Default('') String lastMessageAt,
    @JsonKey(name: 'caseSummary')
    @Default(CaseSummaryModel())
    CaseSummaryModel caseSummary,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'closedAt') @Default('') String closedAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _ConversationModel;

  const ConversationModel._();

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  factory ConversationModel.empty() => const ConversationModel();

  ConversationType get typeValue => ConversationType.fromValue(type);

  ConversationStatus get statusValue => ConversationStatus.fromValue(status);

  LinkedResourceType get linkedResourceTypeValue =>
      LinkedResourceType.fromValue(linkedResourceType);
}
