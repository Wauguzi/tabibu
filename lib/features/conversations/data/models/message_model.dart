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
    @JsonKey(name: 'inputMode') @Default('Typed') String inputMode,
    @JsonKey(name: 'attachmentPath') @Default('') String attachmentPath,
    @JsonKey(name: 'attachmentContentType')
    @Default('')
    String attachmentContentType,
    @JsonKey(name: 'attachmentDurationMs') @Default(0) int attachmentDurationMs,
    @JsonKey(name: 'voicePeaks') @Default(<int>[]) List<int> voicePeaks,
    @JsonKey(name: 'voiceWaveformId') @Default('') String voiceWaveformId,
    @JsonKey(name: 'replyToMessageUid') @Default('') String replyToMessageUid,
    @JsonKey(name: 'withheldReason') @Default('') String withheldReason,
    @JsonKey(name: 'status') @Default('') String status,
    @JsonKey(name: 'sentAt') @Default('') String sentAt,
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
