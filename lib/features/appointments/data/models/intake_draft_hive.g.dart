// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_draft_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntakeDraftHiveAdapter extends TypeAdapter<IntakeDraftHive> {
  @override
  final typeId = 26;

  @override
  IntakeDraftHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntakeDraftHive(
      chiefComplaint: fields[0] as String,
      symptoms: (fields[1] as List).cast<String>(),
      duration: fields[2] as String,
      redFlags: (fields[3] as List).cast<String>(),
      summary: fields[4] as String,
      isTranslation: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, IntakeDraftHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.chiefComplaint)
      ..writeByte(1)
      ..write(obj.symptoms)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.redFlags)
      ..writeByte(4)
      ..write(obj.summary)
      ..writeByte(5)
      ..write(obj.isTranslation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntakeDraftHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
