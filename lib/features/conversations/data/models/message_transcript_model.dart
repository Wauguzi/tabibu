import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_transcript_model.freezed.dart';
part 'message_transcript_model.g.dart';

/// A `conversations/{c}/voiceTranscripts/{messageUid}_{kind}` document.
@freezed
abstract class MessageTranscriptModel with _$MessageTranscriptModel {
  const factory MessageTranscriptModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'conversationUid') @Default('') String conversationUid,
    @JsonKey(name: 'messageUid') @Default('') String messageUid,
    @JsonKey(name: 'senderUid') @Default('') String senderUid,
    @JsonKey(name: 'text') @Default('') String text,
    @JsonKey(name: 'language') @Default('') String language,
    @JsonKey(name: 'acceptedUnchanged') @Default(false) bool acceptedUnchanged,
    @JsonKey(name: 'editDistance') @Default(0.0) double editDistance,
    @JsonKey(name: 'models')
    @Default(<String, String>{})
    Map<String, String> models,
    @JsonKey(name: 'sharedAt') @Default('') String sharedAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _MessageTranscriptModel;

  factory MessageTranscriptModel.fromJson(Map<String, dynamic> json) =>
      _$MessageTranscriptModelFromJson(json);

  factory MessageTranscriptModel.empty() => const MessageTranscriptModel();
}
