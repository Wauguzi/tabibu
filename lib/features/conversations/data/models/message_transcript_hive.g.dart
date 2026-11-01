// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_transcript_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageTranscriptHiveAdapter extends TypeAdapter<MessageTranscriptHive> {
  @override
  final typeId = 38;

  @override
  MessageTranscriptHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageTranscriptHive(
      uid: fields[0] as String,
      conversationUid: fields[1] as String,
      messageUid: fields[2] as String,
      senderUid: fields[3] as String,
      text: fields[4] as String,
      language: fields[5] as String,
      acceptedUnchanged: fields[6] as bool,
      editDistance: (fields[7] as num).toDouble(),
      models: (fields[8] as Map).cast<String, String>(),
      sharedAt: fields[9] as String,
      lastUpdatedAt: fields[10] as String,
      synced: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageTranscriptHive obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.conversationUid)
      ..writeByte(2)
      ..write(obj.messageUid)
      ..writeByte(3)
      ..write(obj.senderUid)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.acceptedUnchanged)
      ..writeByte(7)
      ..write(obj.editDistance)
      ..writeByte(8)
      ..write(obj.models)
      ..writeByte(9)
      ..write(obj.sharedAt)
      ..writeByte(10)
      ..write(obj.lastUpdatedAt)
      ..writeByte(11)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTranscriptHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
