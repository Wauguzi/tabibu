// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_member_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationMemberHiveAdapter
    extends TypeAdapter<ConversationMemberHive> {
  @override
  final typeId = 33;

  @override
  ConversationMemberHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationMemberHive(
      uid: fields[0] as String,
      actorRole: fields[1] as String,
      memberRole: fields[2] as String,
      status: fields[3] as String,
      title: fields[4] as String,
      firstName: fields[5] as String,
      lastName: fields[6] as String,
      specialty: fields[7] as String,
      profilePictureUrl: fields[8] as String,
      invitedByUid: fields[9] as String,
      invitedAt: fields[10] as String,
      inviteExpiresAt: fields[11] as String,
      inviteRound: (fields[12] as num).toInt(),
      respondedAt: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationMemberHive obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.actorRole)
      ..writeByte(2)
      ..write(obj.memberRole)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.firstName)
      ..writeByte(6)
      ..write(obj.lastName)
      ..writeByte(7)
      ..write(obj.specialty)
      ..writeByte(8)
      ..write(obj.profilePictureUrl)
      ..writeByte(9)
      ..write(obj.invitedByUid)
      ..writeByte(10)
      ..write(obj.invitedAt)
      ..writeByte(11)
      ..write(obj.inviteExpiresAt)
      ..writeByte(12)
      ..write(obj.inviteRound)
      ..writeByte(13)
      ..write(obj.respondedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMemberHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
