// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_translation_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotesTranslationHiveAdapter extends TypeAdapter<NotesTranslationHive> {
  @override
  final typeId = 11;

  @override
  NotesTranslationHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotesTranslationHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      status: fields[2] as String,
      sourceLanguage: fields[3] as String,
      language: fields[4] as String,
      sourceSha256: fields[5] as String,
      text: fields[6] as String,
      models: (fields[7] as Map).cast<String, String>(),
      failureReason: fields[8] as String,
      requestedAt: fields[9] as String,
      readyAt: fields[10] as String,
      lastUpdatedAt: fields[11] as String,
      synced: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotesTranslationHive obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.sourceLanguage)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.sourceSha256)
      ..writeByte(6)
      ..write(obj.text)
      ..writeByte(7)
      ..write(obj.models)
      ..writeByte(8)
      ..write(obj.failureReason)
      ..writeByte(9)
      ..write(obj.requestedAt)
      ..writeByte(10)
      ..write(obj.readyAt)
      ..writeByte(11)
      ..write(obj.lastUpdatedAt)
      ..writeByte(12)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesTranslationHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
