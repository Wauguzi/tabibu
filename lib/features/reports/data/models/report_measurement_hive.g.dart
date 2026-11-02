// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_measurement_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportMeasurementHiveAdapter extends TypeAdapter<ReportMeasurementHive> {
  @override
  final typeId = 19;

  @override
  ReportMeasurementHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportMeasurementHive(
      key: fields[0] as String,
      unit: fields[1] as String,
      value: (fields[2] as num).toDouble(),
      precision: (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ReportMeasurementHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.unit)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.precision);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportMeasurementHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
