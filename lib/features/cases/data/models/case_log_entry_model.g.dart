// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_log_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseLogEntryModel _$CaseLogEntryModelFromJson(Map<String, dynamic> json) =>
    _CaseLogEntryModel(
      uid: json['uid'] as String? ?? '',
      caseUid: json['caseUid'] as String? ?? '',
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      fromLocation: json['fromLocation'] as String? ?? '',
      fromStage: json['fromStage'] as String? ?? '',
      fromStep: json['fromStep'] as String? ?? '',
      toLocation: json['toLocation'] as String? ?? '',
      toStage: json['toStage'] as String? ?? '',
      toStep: json['toStep'] as String? ?? '',
      createdByUid: json['createdByUid'] as String? ?? '',
      actorRole: json['actorRole'] as String? ?? 'System',
      actionType: json['actionType'] as String? ?? '',
      actionReason: json['actionReason'] as String? ?? '',
      patientVisible: json['patientVisible'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$CaseLogEntryModelToJson(_CaseLogEntryModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'caseUid': instance.caseUid,
      'seq': instance.seq,
      'fromLocation': instance.fromLocation,
      'fromStage': instance.fromStage,
      'fromStep': instance.fromStep,
      'toLocation': instance.toLocation,
      'toStage': instance.toStage,
      'toStep': instance.toStep,
      'createdByUid': instance.createdByUid,
      'actorRole': instance.actorRole,
      'actionType': instance.actionType,
      'actionReason': instance.actionReason,
      'patientVisible': instance.patientVisible,
      'createdAt': instance.createdAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
