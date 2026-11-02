// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_receipt_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertReceiptHiveAdapter extends TypeAdapter<AlertReceiptHive> {
  @override
  final typeId = 51;

  @override
  AlertReceiptHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertReceiptHive(
      alertUid: fields[0] as String,
      readAt: fields[1] as String,
      lastUpdatedAt: fields[2] as String,
      synced: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AlertReceiptHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.alertUid)
      ..writeByte(1)
      ..write(obj.readAt)
      ..writeByte(2)
      ..write(obj.lastUpdatedAt)
      ..writeByte(3)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertReceiptHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
