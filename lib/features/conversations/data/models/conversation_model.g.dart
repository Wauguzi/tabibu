// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    _ConversationModel(
      uid: json['uid'] as String? ?? '',
      type: json['type'] as String? ?? 'GroupConsult',
      status: json['status'] as String? ?? 'Open',
      createdByUid: json['createdByUid'] as String? ?? '',
      linkedResourceType: json['linkedResourceType'] as String? ?? 'Case',
      linkedResourceUid: json['linkedResourceUid'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      description: json['description'] as String? ?? '',
      participantUids:
          (json['participantUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      members:
          (json['members'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              ConversationMemberModel.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
          const <String, ConversationMemberModel>{},
      lastMessage: json['lastMessage'] == null
          ? const MessagePreviewModel()
          : MessagePreviewModel.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
      lastMessageAt: json['lastMessageAt'] as String? ?? '',
      caseSummary: json['caseSummary'] == null
          ? const CaseSummaryModel()
          : CaseSummaryModel.fromJson(
              json['caseSummary'] as Map<String, dynamic>,
            ),
      createdAt: json['createdAt'] as String? ?? '',
      closedAt: json['closedAt'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$ConversationModelToJson(_ConversationModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'type': instance.type,
      'status': instance.status,
      'createdByUid': instance.createdByUid,
      'linkedResourceType': instance.linkedResourceType,
      'linkedResourceUid': instance.linkedResourceUid,
      'specialty': instance.specialty,
      'description': instance.description,
      'participantUids': instance.participantUids,
      'members': instance.members.map((k, e) => MapEntry(k, e.toJson())),
      'lastMessage': instance.lastMessage.toJson(),
      'lastMessageAt': instance.lastMessageAt,
      'caseSummary': instance.caseSummary.toJson(),
      'createdAt': instance.createdAt,
      'closedAt': instance.closedAt,
      'lastUpdatedAt': instance.lastUpdatedAt,
    };
