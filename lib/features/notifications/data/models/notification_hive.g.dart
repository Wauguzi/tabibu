// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationHiveAdapter extends TypeAdapter<NotificationHive> {
  @override
  final typeId = 40;

  @override
  NotificationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationHive(
      uid: fields[0] as String,
      threadUid: fields[1] as String,
      idempotencyKey: fields[2] as String,
      creationDate: fields[3] as String,
      recipientUid: fields[4] as String,
      recipientRole: fields[5] as String,
      initiatorUid: fields[6] as String,
      initiatorRole: fields[7] as String,
      initiatorName: fields[8] as String,
      title: fields[9] as String,
      message: fields[10] as String,
      templateKey: fields[11] as String,
      templateArgs: (fields[12] as Map).cast<String, String>(),
      category: fields[13] as String,
      priority: fields[14] as String,
      channel: fields[15] as String,
      source: fields[16] as String,
      scope: fields[17] as String,
      status: fields[18] as String,
      readAt: fields[19] as String,
      resourceType: fields[20] as String,
      resourceUid: fields[21] as String,
      metadata: fields[22] as NotificationMetadataHive,
      pushRequestedAt: fields[23] as String,
      pushSentAt: fields[24] as String,
      lastUpdatedAt: fields[25] as String,
      synced: fields[26] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationHive obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.threadUid)
      ..writeByte(2)
      ..write(obj.idempotencyKey)
      ..writeByte(3)
      ..write(obj.creationDate)
      ..writeByte(4)
      ..write(obj.recipientUid)
      ..writeByte(5)
      ..write(obj.recipientRole)
      ..writeByte(6)
      ..write(obj.initiatorUid)
      ..writeByte(7)
      ..write(obj.initiatorRole)
      ..writeByte(8)
      ..write(obj.initiatorName)
      ..writeByte(9)
      ..write(obj.title)
      ..writeByte(10)
      ..write(obj.message)
      ..writeByte(11)
      ..write(obj.templateKey)
      ..writeByte(12)
      ..write(obj.templateArgs)
      ..writeByte(13)
      ..write(obj.category)
      ..writeByte(14)
      ..write(obj.priority)
      ..writeByte(15)
      ..write(obj.channel)
      ..writeByte(16)
      ..write(obj.source)
      ..writeByte(17)
      ..write(obj.scope)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(19)
      ..write(obj.readAt)
      ..writeByte(20)
      ..write(obj.resourceType)
      ..writeByte(21)
      ..write(obj.resourceUid)
      ..writeByte(22)
      ..write(obj.metadata)
      ..writeByte(23)
      ..write(obj.pushRequestedAt)
      ..writeByte(24)
      ..write(obj.pushSentAt)
      ..writeByte(25)
      ..write(obj.lastUpdatedAt)
      ..writeByte(26)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
