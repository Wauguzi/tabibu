// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_metadata_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationMetadataHiveAdapter
    extends TypeAdapter<NotificationMetadataHive> {
  @override
  final typeId = 41;

  @override
  NotificationMetadataHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationMetadataHive(
      actionType: fields[0] as String,
      actionStatus: fields[1] as String,
      actionedByUid: fields[2] as String,
      actionedAt: fields[3] as String,
      expiresAt: fields[4] as String,
      deepLink: fields[5] as String,
      shareCode: fields[6] as String,
      extras: (fields[7] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationMetadataHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.actionType)
      ..writeByte(1)
      ..write(obj.actionStatus)
      ..writeByte(2)
      ..write(obj.actionedByUid)
      ..writeByte(3)
      ..write(obj.actionedAt)
      ..writeByte(4)
      ..write(obj.expiresAt)
      ..writeByte(5)
      ..write(obj.deepLink)
      ..writeByte(6)
      ..write(obj.shareCode)
      ..writeByte(7)
      ..write(obj.extras);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationMetadataHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
