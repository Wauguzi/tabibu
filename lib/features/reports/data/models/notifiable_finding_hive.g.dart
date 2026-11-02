// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifiable_finding_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotifiableFindingHiveAdapter extends TypeAdapter<NotifiableFindingHive> {
  @override
  final typeId = 52;

  @override
  NotifiableFindingHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotifiableFindingHive(
      diseaseId: fields[0] as String,
      alertRequested: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotifiableFindingHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.diseaseId)
      ..writeByte(1)
      ..write(obj.alertRequested);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotifiableFindingHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
