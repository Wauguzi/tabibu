// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_signal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertSignalModel _$AlertSignalModelFromJson(Map<String, dynamic> json) =>
    _AlertSignalModel(
      uid: json['uid'] as String? ?? '',
      diseaseId: json['diseaseId'] as String? ?? '',
      countyId: (json['countyId'] as num?)?.toInt() ?? 0,
      countyName: json['countyName'] as String? ?? '',
      epiWeek: json['epiWeek'] as String? ?? '',
      category: json['category'] as String? ?? '',
      rule: json['rule'] as String? ?? '',
      status: json['status'] as String? ?? 'Withdrawn',
      evidence: json['evidence'] == null
          ? const AlertEvidenceModel()
          : AlertEvidenceModel.fromJson(
              json['evidence'] as Map<String, dynamic>,
            ),
      alertUid: json['alertUid'] as String? ?? '',
      synthetic: json['synthetic'] as bool? ?? false,
      raisedAt: json['raisedAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$AlertSignalModelToJson(_AlertSignalModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'diseaseId': instance.diseaseId,
      'countyId': instance.countyId,
      'countyName': instance.countyName,
      'epiWeek': instance.epiWeek,
      'category': instance.category,
      'rule': instance.rule,
      'status': instance.status,
      'evidence': instance.evidence.toJson(),
      'alertUid': instance.alertUid,
      'synthetic': instance.synthetic,
      'raisedAt': instance.raisedAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
