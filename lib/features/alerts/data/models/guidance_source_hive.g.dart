// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guidance_source_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuidanceSourceHiveAdapter extends TypeAdapter<GuidanceSourceHive> {
  @override
  final typeId = 49;

  @override
  GuidanceSourceHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GuidanceSourceHive(
      sourceId: fields[0] as String,
      title: fields[1] as String,
      publisher: fields[2] as String,
      url: fields[3] as String,
      publishedOn: fields[4] as String,
      accessedOn: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GuidanceSourceHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sourceId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.publisher)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.publishedOn)
      ..writeByte(5)
      ..write(obj.accessedOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuidanceSourceHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
