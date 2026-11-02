// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_text_approved_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportTextApprovedHiveAdapter
    extends TypeAdapter<ReportTextApprovedHive> {
  @override
  final typeId = 23;

  @override
  ReportTextApprovedHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportTextApprovedHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      reportUid: fields[2] as String,
      reportVersion: (fields[3] as num).toInt(),
      kind: fields[4] as String,
      language: fields[5] as String,
      sourceLanguage: fields[6] as String,
      sourceSha256: fields[7] as String,
      approvedText: (fields[8] as Map).cast<String, String>(),
      approverUid: fields[9] as String,
      approverName: fields[10] as String,
      approvedAt: fields[11] as String,
      acceptedUnchanged: fields[12] as bool,
      lastUpdatedAt: fields[13] as String,
      synced: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReportTextApprovedHive obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.reportUid)
      ..writeByte(3)
      ..write(obj.reportVersion)
      ..writeByte(4)
      ..write(obj.kind)
      ..writeByte(5)
      ..write(obj.language)
      ..writeByte(6)
      ..write(obj.sourceLanguage)
      ..writeByte(7)
      ..write(obj.sourceSha256)
      ..writeByte(8)
      ..write(obj.approvedText)
      ..writeByte(9)
      ..write(obj.approverUid)
      ..writeByte(10)
      ..write(obj.approverName)
      ..writeByte(11)
      ..write(obj.approvedAt)
      ..writeByte(12)
      ..write(obj.acceptedUnchanged)
      ..writeByte(13)
      ..write(obj.lastUpdatedAt)
      ..writeByte(14)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTextApprovedHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
