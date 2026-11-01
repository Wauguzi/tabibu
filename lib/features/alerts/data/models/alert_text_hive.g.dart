// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_text_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertTextHiveAdapter extends TypeAdapter<AlertTextHive> {
  @override
  final typeId = 47;

  @override
  AlertTextHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertTextHive(
      headline: fields[0] as String,
      body: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AlertTextHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.headline)
      ..writeByte(1)
      ..write(obj.body);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertTextHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
