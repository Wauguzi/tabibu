// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_cursor_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationCursorHiveAdapter
    extends TypeAdapter<ConversationCursorHive> {
  @override
  final typeId = 37;

  @override
  ConversationCursorHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationCursorHive(
      uid: fields[0] as String,
      conversationUid: fields[1] as String,
      lastReadAt: fields[2] as String,
      lastUpdatedAt: fields[3] as String,
      synced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationCursorHive obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.conversationUid)
      ..writeByte(2)
      ..write(obj.lastReadAt)
      ..writeByte(3)
      ..write(obj.lastUpdatedAt)
      ..writeByte(4)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationCursorHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
