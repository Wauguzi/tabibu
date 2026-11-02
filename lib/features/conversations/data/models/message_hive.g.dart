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
      transcriptShared: fields[19] as bool,
      transcriptLanguage: fields[20] == null ? '' : fields[20] as String,
      inputMode: fields[6] as String,
      identifierFlagged: fields[21] as bool,
      attachmentPath: fields[7] as String,
      attachmentType: fields[8] as String,
      attachmentSize: fields[22] == null ? 0 : (fields[22] as num).toInt(),
      voiceDurationMs: (fields[9] as num).toInt(),
      voicePeaks: (fields[10] as List).cast<int>(),
      withheldReason: fields[13] as String,
      status: fields[14] as String,
      sentAt: fields[15] as String,
      deliveredAt: fields[23] == null ? '' : fields[23] as String,
      localAttachmentPath: fields[16] as String,
      lastUpdatedAt: fields[17] as String,
      synced: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageHive obj) {
    writer
      ..writeByte(22)
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
      ..write(obj.attachmentType)
      ..writeByte(9)
      ..write(obj.voiceDurationMs)
      ..writeByte(10)
      ..write(obj.voicePeaks)
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
      ..write(obj.synced)
      ..writeByte(19)
      ..write(obj.transcriptShared)
      ..writeByte(20)
      ..write(obj.transcriptLanguage)
      ..writeByte(21)
      ..write(obj.identifierFlagged)
      ..writeByte(22)
      ..write(obj.attachmentSize)
      ..writeByte(23)
      ..write(obj.deliveredAt);
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
