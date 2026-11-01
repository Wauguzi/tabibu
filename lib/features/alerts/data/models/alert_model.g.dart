// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertModel _$AlertModelFromJson(Map<String, dynamic> json) => _AlertModel(
  uid: json['uid'] as String? ?? '',
  signalUid: json['signalUid'] as String? ?? '',
  diseaseId: json['diseaseId'] as String? ?? '',
  countyId: (json['countyId'] as num?)?.toInt() ?? 0,
  countyName: json['countyName'] as String? ?? '',
  epiWeek: json['epiWeek'] as String? ?? '',
  category: json['category'] as String? ?? '',
  rule: json['rule'] as String? ?? '',
  status: json['status'] as String? ?? 'Drafting',
  draftRevision: (json['draftRevision'] as num?)?.toInt() ?? 0,
  requestCount: (json['requestCount'] as num?)?.toInt() ?? 0,
  evidenceRevision: (json['evidenceRevision'] as num?)?.toInt() ?? 0,
  draftSource: json['draftSource'] as String? ?? 'Template',
  machineText:
      (json['machineText'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AlertTextModel.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, AlertTextModel>{},
  models:
      (json['models'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  failureReason: json['failureReason'] as String? ?? '',
  evidence: json['evidence'] == null
      ? const AlertEvidenceModel()
      : AlertEvidenceModel.fromJson(json['evidence'] as Map<String, dynamic>),
  audience: json['audience'] as String? ?? 'CliniciansThenPatients',
  decision: json['decision'] as String? ?? '',
  decidedByUid: json['decidedByUid'] as String? ?? '',
  decidedByName: json['decidedByName'] as String? ?? '',
  decidedAt: json['decidedAt'] as String? ?? '',
  rejectReason: json['rejectReason'] as String? ?? '',
  approvedText:
      (json['approvedText'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, AlertTextModel.fromJson(e as Map<String, dynamic>)),
      ) ??
      const <String, AlertTextModel>{},
  approvedEvidence: json['approvedEvidence'] == null
      ? const AlertEvidenceModel()
      : AlertEvidenceModel.fromJson(
          json['approvedEvidence'] as Map<String, dynamic>,
        ),
  acceptedUnchanged: json['acceptedUnchanged'] as bool? ?? false,
  editedKeys:
      (json['editedKeys'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  editDistance: (json['editDistance'] as num?)?.toDouble() ?? 0,
  evidenceRetracted: json['evidenceRetracted'] as bool? ?? false,
  deliveredTo: json['deliveredTo'] as String? ?? '',
  deliveredAt: json['deliveredAt'] as String? ?? '',
  requestedAt: json['requestedAt'] as String? ?? '',
  draftedAt: json['draftedAt'] as String? ?? '',
  expiresAt: json['expiresAt'] as String? ?? '',
  reminderSentAt: json['reminderSentAt'] as String? ?? '',
  synthetic: json['synthetic'] as bool? ?? false,
  createdAt: json['createdAt'] as String? ?? '',
  lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
);

Map<String, dynamic> _$AlertModelToJson(
  _AlertModel instance,
) => <String, dynamic>{
  'uid': instance.uid,
  'signalUid': instance.signalUid,
  'diseaseId': instance.diseaseId,
  'countyId': instance.countyId,
  'countyName': instance.countyName,
  'epiWeek': instance.epiWeek,
  'category': instance.category,
  'rule': instance.rule,
  'status': instance.status,
  'draftRevision': instance.draftRevision,
  'requestCount': instance.requestCount,
  'evidenceRevision': instance.evidenceRevision,
  'draftSource': instance.draftSource,
  'machineText': instance.machineText.map((k, e) => MapEntry(k, e.toJson())),
  'models': instance.models,
  'failureReason': instance.failureReason,
  'evidence': instance.evidence.toJson(),
  'audience': instance.audience,
  'decision': instance.decision,
  'decidedByUid': instance.decidedByUid,
  'decidedByName': instance.decidedByName,
  'decidedAt': instance.decidedAt,
  'rejectReason': instance.rejectReason,
  'approvedText': instance.approvedText.map((k, e) => MapEntry(k, e.toJson())),
  'approvedEvidence': instance.approvedEvidence.toJson(),
  'acceptedUnchanged': instance.acceptedUnchanged,
  'editedKeys': instance.editedKeys,
  'editDistance': instance.editDistance,
  'evidenceRetracted': instance.evidenceRetracted,
  'deliveredTo': instance.deliveredTo,
  'deliveredAt': instance.deliveredAt,
  'requestedAt': instance.requestedAt,
  'draftedAt': instance.draftedAt,
  'expiresAt': instance.expiresAt,
  'reminderSentAt': instance.reminderSentAt,
  'synthetic': instance.synthetic,
  'createdAt': instance.createdAt,
  'lastUpdatedAt': instance.lastUpdatedAt,
};
