import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_hive.dart';

part 'conversation_hive.g.dart';

/// Cached [ConversationModel], in the same field order.
@HiveType(typeId: 32)
class ConversationHive {
  ConversationHive({
    required this.uid,
    required this.type,
    required this.status,
    required this.createdByUid,
    required this.linkedResourceType,
    required this.linkedResourceUid,
    required this.specialty,
    required this.description,
    required this.participantUids,
    required this.members,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.caseSummary,
    required this.createdAt,
    required this.closedAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory ConversationHive.fromModel(ConversationModel model) {
    return ConversationHive(
      uid: model.uid,
      type: model.type,
      status: model.status,
      createdByUid: model.createdByUid,
      linkedResourceType: model.linkedResourceType,
      linkedResourceUid: model.linkedResourceUid,
      specialty: model.specialty,
      description: model.description,
      participantUids: model.participantUids,
      members: model.members.map(
        (key, member) =>
            MapEntry(key, ConversationMemberHive.fromModel(member)),
      ),
      lastMessage: MessagePreviewHive.fromModel(model.lastMessage),
      lastMessageAt: model.lastMessageAt,
      caseSummary: CaseSummaryHive.fromModel(model.caseSummary),
      createdAt: model.createdAt,
      closedAt: model.closedAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  ConversationModel toModel() {
    return ConversationModel(
      uid: uid,
      type: type,
      status: status,
      createdByUid: createdByUid,
      linkedResourceType: linkedResourceType,
      linkedResourceUid: linkedResourceUid,
      specialty: specialty,
      description: description,
      participantUids: participantUids,
      members: members.map((key, member) => MapEntry(key, member.toModel())),
      lastMessage: lastMessage.toModel(),
      lastMessageAt: lastMessageAt,
      caseSummary: caseSummary.toModel(),
      createdAt: createdAt,
      closedAt: closedAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final String createdByUid;

  @HiveField(4)
  final String linkedResourceType;

  @HiveField(5)
  final String linkedResourceUid;

  @HiveField(6)
  final String specialty;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final List<String> participantUids;

  @HiveField(9)
  final Map<String, ConversationMemberHive> members;

  @HiveField(10)
  final MessagePreviewHive lastMessage;

  @HiveField(11)
  final String lastMessageAt;

  @HiveField(12)
  final CaseSummaryHive caseSummary;

  @HiveField(13)
  final String createdAt;

  @HiveField(14)
  final String closedAt;

  @HiveField(15)
  final String lastUpdatedAt;

  @HiveField(16)
  final bool synced;
}
