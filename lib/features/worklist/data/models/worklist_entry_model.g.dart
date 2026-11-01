// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worklist_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorklistEntryModel _$WorklistEntryModelFromJson(Map<String, dynamic> json) =>
    _WorklistEntryModel(
      uid: json['uid'] as String? ?? '',
      caseUid: json['caseUid'] as String? ?? '',
      pathologistUid: json['pathologistUid'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      testName: json['testName'] as String? ?? '',
      profile: json['profile'] as String? ?? 'None',
      status: json['status'] as String? ?? 'Open',
      prereadStatus: json['prereadStatus'] as String? ?? '',
      urgency: json['urgency'] as String? ?? 'Routine',
      confidenceBand: json['confidenceBand'] as String? ?? 'Low',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      riskFlag: json['riskFlag'] as bool? ?? false,
      severity: json['severity'] as String? ?? 'Routine',
      basePriority: (json['basePriority'] as num?)?.toInt() ?? 0,
      waitingSince: json['waitingSince'] as String? ?? '',
      assignedAt: json['assignedAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$WorklistEntryModelToJson(_WorklistEntryModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'pathologistUid': instance.pathologistUid,
      'orderNumber': instance.orderNumber,
      'testName': instance.testName,
      'profile': instance.profile,
      'status': instance.status,
      'prereadStatus': instance.prereadStatus,
      'urgency': instance.urgency,
      'confidenceBand': instance.confidenceBand,
      'confidence': instance.confidence,
      'riskFlag': instance.riskFlag,
      'severity': instance.severity,
      'basePriority': instance.basePriority,
      'waitingSince': instance.waitingSince,
      'assignedAt': instance.assignedAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
