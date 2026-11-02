// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slide_image_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SlideImageHiveAdapter extends TypeAdapter<SlideImageHive> {
  @override
  final typeId = 6;

  @override
  SlideImageHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SlideImageHive(
      imageUid: fields[0] as String,
      path: fields[1] as String,
      contentType: fields[2] as String,
      micronsPerPixel: (fields[3] as num).toDouble(),
      uploadedByUid: fields[4] as String,
      uploadedAt: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SlideImageHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.imageUid)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.contentType)
      ..writeByte(3)
      ..write(obj.micronsPerPixel)
      ..writeByte(4)
      ..write(obj.uploadedByUid)
      ..writeByte(5)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlideImageHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
