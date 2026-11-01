// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_preview_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessagePreviewHiveAdapter extends TypeAdapter<MessagePreviewHive> {
  @override
  final typeId = 36;

  @override
  MessagePreviewHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessagePreviewHive(
      uid: fields[0] as String,
      senderUid: fields[1] as String,
      text: fields[2] as String,
      hasAttachment: fields[3] as bool,
      sentAt: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MessagePreviewHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.senderUid)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.hasAttachment)
      ..writeByte(4)
      ..write(obj.sentAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagePreviewHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
