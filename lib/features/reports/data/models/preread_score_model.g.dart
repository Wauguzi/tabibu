// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preread_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrereadScoreModel _$PrereadScoreModelFromJson(Map<String, dynamic> json) =>
    _PrereadScoreModel(
      uid: json['uid'] as String? ?? '',
      caseUid: json['caseUid'] as String? ?? '',
      runUid: json['runUid'] as String? ?? '',
      pathologistUid: json['pathologistUid'] as String? ?? '',
      profile: json['profile'] as String? ?? 'None',
      confidenceBand: json['confidenceBand'] as String? ?? 'Low',
      urgency: json['urgency'] as String? ?? 'Routine',
      overall: (json['overall'] as num?)?.toInt() ?? 0,
      findingsVerdict: json['findingsVerdict'] as String? ?? 'Agree',
      impressionVerdict: json['impressionVerdict'] as String? ?? 'Agree',
      measurementsVerdict:
          json['measurementsVerdict'] as String? ?? 'NotApplicable',
      segmentationVerdict:
          json['segmentationVerdict'] as String? ?? 'NotApplicable',
      urgencyVerdict: json['urgencyVerdict'] as String? ?? 'Agree',
      comment: json['comment'] as String? ?? '',
      prereadShownAt: json['prereadShownAt'] as String? ?? '',
      acceptedUnchanged: json['acceptedUnchanged'] as bool? ?? false,
      scoredAt: json['scoredAt'] as String? ?? '',
      createdByUid: json['createdByUid'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$PrereadScoreModelToJson(_PrereadScoreModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'runUid': instance.runUid,
      'pathologistUid': instance.pathologistUid,
      'profile': instance.profile,
      'confidenceBand': instance.confidenceBand,
      'urgency': instance.urgency,
      'overall': instance.overall,
      'findingsVerdict': instance.findingsVerdict,
      'impressionVerdict': instance.impressionVerdict,
      'measurementsVerdict': instance.measurementsVerdict,
      'segmentationVerdict': instance.segmentationVerdict,
      'urgencyVerdict': instance.urgencyVerdict,
      'comment': instance.comment,
      'prereadShownAt': instance.prereadShownAt,
      'acceptedUnchanged': instance.acceptedUnchanged,
      'scoredAt': instance.scoredAt,
      'createdByUid': instance.createdByUid,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
