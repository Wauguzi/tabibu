import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// A `conversations/{c}/messages/{uid}` document: one message.
@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'conversationUid') @Default('') String conversationUid,
    @JsonKey(name: 'senderUid') @Default('') String senderUid,
    @JsonKey(name: 'kind') @Default('Text') String kind,
    @JsonKey(name: 'text') @Default('') String text,
    @JsonKey(name: 'transcriptStatus') @Default('None') String transcriptStatus,
    @JsonKey(name: 'transcriptShared') @Default(false) bool transcriptShared,
    @JsonKey(name: 'transcriptLanguage') @Default('') String transcriptLanguage,
    @JsonKey(name: 'inputMode') @Default('Typed') String inputMode,
    @JsonKey(name: 'identifierFlagged') @Default(false) bool identifierFlagged,
    @JsonKey(name: 'attachmentPath') @Default('') String attachmentPath,
    @JsonKey(name: 'attachmentType') @Default('') String attachmentType,
    @JsonKey(name: 'attachmentSize') @Default(0) int attachmentSize,
    @JsonKey(name: 'voiceDurationMs') @Default(0) int voiceDurationMs,
    @JsonKey(name: 'voicePeaks') @Default(<int>[]) List<int> voicePeaks,
    @JsonKey(name: 'withheldReason') @Default('') String withheldReason,
    @JsonKey(name: 'status') @Default('') String status,
    @JsonKey(name: 'sentAt') @Default('') String sentAt,
    @JsonKey(name: 'deliveredAt') @Default('') String deliveredAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default('')
    String localAttachmentPath,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _MessageModel;

  const MessageModel._();

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.empty() => const MessageModel();

  MessageKind get kindValue => MessageKind.fromValue(kind);

  TranscriptStatus get transcriptStatusValue =>
      TranscriptStatus.fromValue(transcriptStatus);

  InputMode get inputModeValue => InputMode.fromValue(inputMode);

  MessageStatus get statusValue => MessageStatus.fromValue(status);
}
