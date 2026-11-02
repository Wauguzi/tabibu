// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportResponseHiveAdapter extends TypeAdapter<ReportResponseHive> {
  @override
  final typeId = 17;

  @override
  ReportResponseHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportResponseHive(
      section: fields[0] as String,
      question: fields[1] as String,
      answer: fields[2] as String,
      order: (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ReportResponseHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.section)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportResponseHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
