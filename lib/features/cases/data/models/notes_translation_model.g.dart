// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_translation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotesTranslationModel _$NotesTranslationModelFromJson(
  Map<String, dynamic> json,
) => _NotesTranslationModel(
  uid: json['uid'] as String? ?? 'current',
  caseUid: json['caseUid'] as String? ?? '',
  status: json['status'] as String? ?? 'Queued',
  sourceLanguage: json['sourceLanguage'] as String? ?? '',
  language: json['language'] as String? ?? '',
  sourceSha256: json['sourceSha256'] as String? ?? '',
  text: json['text'] as String? ?? '',
  models:
      (json['models'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  failureReason: json['failureReason'] as String? ?? '',
  requestedAt: json['requestedAt'] as String? ?? '',
  readyAt: json['readyAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$NotesTranslationModelToJson(
  _NotesTranslationModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'caseUid': instance.caseUid,
  'status': instance.status,
  'sourceLanguage': instance.sourceLanguage,
  'language': instance.language,
  'sourceSha256': instance.sourceSha256,
  'text': instance.text,
  'models': instance.models,
  'failureReason': instance.failureReason,
  'requestedAt': instance.requestedAt,
  'readyAt': instance.readyAt,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
