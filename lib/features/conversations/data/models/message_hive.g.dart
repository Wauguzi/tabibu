// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageHiveAdapter extends TypeAdapter<MessageHive> {
  @override
  final typeId = 35;

  @override
  MessageHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageHive(
      uid: fields[0] as String,
      conversationUid: fields[1] as String,
      senderUid: fields[2] as String,
      kind: fields[3] as String,
      text: fields[4] as String,
      transcriptStatus: fields[5] as String,
      inputMode: fields[6] as String,
      attachmentPath: fields[7] as String,
      attachmentContentType: fields[8] as String,
      attachmentDurationMs: (fields[9] as num).toInt(),
      voicePeaks: (fields[10] as List).cast<int>(),
      voiceWaveformId: fields[11] as String,
      replyToMessageUid: fields[12] as String,
      withheldReason: fields[13] as String,
      status: fields[14] as String,
      sentAt: fields[15] as String,
      localAttachmentPath: fields[16] as String,
      lastUpdatedAt: fields[17] as String,
      synced: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.conversationUid)
      ..writeByte(2)
      ..write(obj.senderUid)
      ..writeByte(3)
      ..write(obj.kind)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(5)
      ..write(obj.transcriptStatus)
      ..writeByte(6)
      ..write(obj.inputMode)
      ..writeByte(7)
      ..write(obj.attachmentPath)
      ..writeByte(8)
      ..write(obj.attachmentContentType)
      ..writeByte(9)
      ..write(obj.attachmentDurationMs)
      ..writeByte(10)
      ..write(obj.voicePeaks)
      ..writeByte(11)
      ..write(obj.voiceWaveformId)
      ..writeByte(12)
      ..write(obj.replyToMessageUid)
      ..writeByte(13)
      ..write(obj.withheldReason)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.sentAt)
      ..writeByte(16)
      ..write(obj.localAttachmentPath)
      ..writeByte(17)
      ..write(obj.lastUpdatedAt)
      ..writeByte(18)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
