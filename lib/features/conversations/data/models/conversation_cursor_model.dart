import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_cursor_model.freezed.dart';
part 'conversation_cursor_model.g.dart';

/// A `conversations/{c}/cursors/{uid}` document: one member's read position.
@freezed
abstract class ConversationCursorModel with _$ConversationCursorModel {
  const factory ConversationCursorModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'conversationUid') @Default('') String conversationUid,
    @JsonKey(name: 'lastReadAt') @Default('') String lastReadAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _ConversationCursorModel;

  factory ConversationCursorModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationCursorModelFromJson(json);

  factory ConversationCursorModel.empty() => const ConversationCursorModel();
}
