// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_addendum_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportAddendumHiveAdapter extends TypeAdapter<ReportAddendumHive> {
  @override
  final typeId = 18;

  @override
  ReportAddendumHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportAddendumHive(
      uid: fields[0] as String,
      text: fields[1] as String,
      reportVersion: (fields[2] as num).toInt(),
      signedByUid: fields[3] as String,
      signedByName: fields[4] as String,
      signedAt: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReportAddendumHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.reportVersion)
      ..writeByte(3)
      ..write(obj.signedByUid)
      ..writeByte(4)
      ..write(obj.signedByName)
      ..writeByte(5)
      ..write(obj.signedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAddendumHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
