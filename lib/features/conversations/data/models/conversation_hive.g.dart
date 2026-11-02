// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationHiveAdapter extends TypeAdapter<ConversationHive> {
  @override
  final typeId = 32;

  @override
  ConversationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationHive(
      uid: fields[0] as String,
      type: fields[1] as String,
      status: fields[2] as String,
      createdByUid: fields[3] as String,
      linkedResourceType: fields[4] as String,
      linkedResourceUid: fields[5] as String,
      specialty: fields[6] as String,
      description: fields[7] as String,
      participantUids: (fields[8] as List).cast<String>(),
      members: (fields[9] as Map).cast<String, ConversationMemberHive>(),
      lastMessage: fields[10] as MessagePreviewHive,
      lastMessageAt: fields[11] as String,
      caseSummary: fields[12] as CaseSummaryHive,
      createdAt: fields[13] as String,
      closedAt: fields[14] as String,
      lastUpdatedAt: fields[15] as String,
      synced: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationHive obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.createdByUid)
      ..writeByte(4)
      ..write(obj.linkedResourceType)
      ..writeByte(5)
      ..write(obj.linkedResourceUid)
      ..writeByte(6)
      ..write(obj.specialty)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.participantUids)
      ..writeByte(9)
      ..write(obj.members)
      ..writeByte(10)
      ..write(obj.lastMessage)
      ..writeByte(11)
      ..write(obj.lastMessageAt)
      ..writeByte(12)
      ..write(obj.caseSummary)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.closedAt)
      ..writeByte(15)
      ..write(obj.lastUpdatedAt)
      ..writeByte(16)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
