// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranscriptionResultModel _$TranscriptionResultModelFromJson(
  Map<String, dynamic> json,
) => _TranscriptionResultModel(
  transcriptionUid: json['transcriptionUid'] as String? ?? '',
  transcript: json['transcript'] as String? ?? '',
  detectedLanguage: json['detectedLanguage'] as String? ?? '',
  models:
      (json['models'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
);

Map<String, dynamic> _$TranscriptionResultModelToJson(
  _TranscriptionResultModel instance,
) => <String, dynamic>{
  'transcriptionUid': instance.transcriptionUid,
  'transcript': instance.transcript,
  'detectedLanguage': instance.detectedLanguage,
  'models': instance.models,
};
