import 'package:freezed_annotation/freezed_annotation.dart';

part 'transcription_result_model.freezed.dart';
part 'transcription_result_model.g.dart';

/// Response from `transcribeSymptoms`. Never cached.
@freezed
abstract class TranscriptionResultModel with _$TranscriptionResultModel {
  const factory TranscriptionResultModel({
    @JsonKey(name: 'transcriptionUid') @Default('') String transcriptionUid,
    @JsonKey(name: 'transcript') @Default('') String transcript,
    @JsonKey(name: 'detectedLanguage') @Default('') String detectedLanguage,
    @JsonKey(name: 'models')
    @Default(<String, String>{})
    Map<String, String> models,
  }) = _TranscriptionResultModel;

  const TranscriptionResultModel._();

  factory TranscriptionResultModel.fromJson(Map<String, dynamic> json) =>
      _$TranscriptionResultModelFromJson(json);

  factory TranscriptionResultModel.empty() => const TranscriptionResultModel();
}
