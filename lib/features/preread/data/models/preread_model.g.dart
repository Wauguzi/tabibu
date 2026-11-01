// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preread_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrereadModel _$PrereadModelFromJson(Map<String, dynamic> json) =>
    _PrereadModel(
      uid: json['uid'] as String? ?? '',
      caseUid: json['caseUid'] as String? ?? '',
      profile: json['profile'] as String? ?? '',
      status: json['status'] as String? ?? 'Queued',
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      micronsPerPixel: (json['micronsPerPixel'] as num?)?.toDouble() ?? 0,
      segmentationPath: json['segmentationPath'] as String? ?? '',
      labelsPath: json['labelsPath'] as String? ?? '',
      labelCounts:
          (json['labelCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      measurements:
          (json['measurements'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const <String, double>{},
      draft: json['draft'] == null
          ? const PrereadDraftModel()
          : PrereadDraftModel.fromJson(json['draft'] as Map<String, dynamic>),
      models:
          (json['models'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      inputLanguage: json['inputLanguage'] as String? ?? '',
      failureReason: json['failureReason'] as String? ?? '',
      requestedAt: json['requestedAt'] as String? ?? '',
      startedAt: json['startedAt'] as String? ?? '',
      readyAt: json['readyAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$PrereadModelToJson(_PrereadModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'profile': instance.profile,
      'status': instance.status,
      'imagePaths': instance.imagePaths,
      'micronsPerPixel': instance.micronsPerPixel,
      'segmentationPath': instance.segmentationPath,
      'labelsPath': instance.labelsPath,
      'labelCounts': instance.labelCounts,
      'measurements': instance.measurements,
      'draft': instance.draft.toJson(),
      'models': instance.models,
      'inputLanguage': instance.inputLanguage,
      'failureReason': instance.failureReason,
      'requestedAt': instance.requestedAt,
      'startedAt': instance.startedAt,
      'readyAt': instance.readyAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
