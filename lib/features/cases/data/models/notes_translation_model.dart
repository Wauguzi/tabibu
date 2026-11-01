import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'notes_translation_model.freezed.dart';
part 'notes_translation_model.g.dart';

/// A `notesTranslation/current` document: the translated clinical notes.
@freezed
abstract class NotesTranslationModel with _$NotesTranslationModel {
  const factory NotesTranslationModel({
    @JsonKey(name: 'uid') @Default('current') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'status') @Default('Queued') String status,
    @JsonKey(name: 'sourceLanguage') @Default('') String sourceLanguage,
    @JsonKey(name: 'language') @Default('') String language,
    @JsonKey(name: 'sourceSha256') @Default('') String sourceSha256,
    @JsonKey(name: 'text') @Default('') String text,
    @JsonKey(name: 'models')
    @Default(<String, String>{})
    Map<String, String> models,
    @JsonKey(name: 'failureReason') @Default('') String failureReason,
    @JsonKey(name: 'requestedAt') @Default('') String requestedAt,
    @JsonKey(name: 'readyAt') @Default('') String readyAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _NotesTranslationModel;

  const NotesTranslationModel._();

  factory NotesTranslationModel.fromJson(Map<String, dynamic> json) =>
      _$NotesTranslationModelFromJson(json);

  factory NotesTranslationModel.empty() => const NotesTranslationModel();

  JobStatus get statusValue => JobStatus.fromValue(status);

  FailureReason get failureReasonValue =>
      FailureReason.fromValue(failureReason);
}
