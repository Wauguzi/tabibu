// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guidance_bullet_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuidanceBulletHiveAdapter extends TypeAdapter<GuidanceBulletHive> {
  @override
  final typeId = 48;

  @override
  GuidanceBulletHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuidanceBulletHive(
      bulletId: fields[0] as String,
      audience: fields[1] as String,
      textEn: fields[2] as String,
      textSw: fields[3] as String,
      swIsOfficial: fields[4] as bool,
      sourceId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GuidanceBulletHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.bulletId)
      ..writeByte(1)
      ..write(obj.audience)
      ..writeByte(2)
      ..write(obj.textEn)
      ..writeByte(3)
      ..write(obj.textSw)
      ..writeByte(4)
      ..write(obj.swIsOfficial)
      ..writeByte(5)
      ..write(obj.sourceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuidanceBulletHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
