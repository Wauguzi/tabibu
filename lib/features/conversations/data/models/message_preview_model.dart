import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_preview_model.freezed.dart';
part 'message_preview_model.g.dart';

/// A conversation's `lastMessage`: just enough to render the row.
@freezed
abstract class MessagePreviewModel with _$MessagePreviewModel {
  const factory MessagePreviewModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'senderUid') @Default('') String senderUid,
    @JsonKey(name: 'text') @Default('') String text,
    @JsonKey(name: 'hasAttachment') @Default(false) bool hasAttachment,
    @JsonKey(name: 'sentAt') @Default('') String sentAt,
  }) = _MessagePreviewModel;

  factory MessagePreviewModel.fromJson(Map<String, dynamic> json) =>
      _$MessagePreviewModelFromJson(json);

  factory MessagePreviewModel.empty() => const MessagePreviewModel();
}
