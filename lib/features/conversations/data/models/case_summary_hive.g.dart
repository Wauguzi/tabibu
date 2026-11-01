// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_summary_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaseSummaryHiveAdapter extends TypeAdapter<CaseSummaryHive> {
  @override
  final typeId = 34;

  @override
  CaseSummaryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaseSummaryHive(
      caseRef: fields[0] as String,
      ageBand: fields[1] as String,
      sex: fields[2] as String,
      testTypeNames: (fields[3] as List).cast<String>(),
      testNames: (fields[4] as List).cast<String>(),
      reportStatus: fields[5] as String,
      signedDiagnosisExcerpt: fields[6] as String,
      signedAt: fields[7] as String,
      signedByName: fields[8] as String,
      reportLanguage: fields[9] as String,
      builtAt: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CaseSummaryHive obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.caseRef)
      ..writeByte(1)
      ..write(obj.ageBand)
      ..writeByte(2)
      ..write(obj.sex)
      ..writeByte(3)
      ..write(obj.testTypeNames)
      ..writeByte(4)
      ..write(obj.testNames)
      ..writeByte(5)
      ..write(obj.reportStatus)
      ..writeByte(6)
      ..write(obj.signedDiagnosisExcerpt)
      ..writeByte(7)
      ..write(obj.signedAt)
      ..writeByte(8)
      ..write(obj.signedByName)
      ..writeByte(9)
      ..write(obj.reportLanguage)
      ..writeByte(10)
      ..write(obj.builtAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseSummaryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
