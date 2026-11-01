// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_log_entry_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaseLogEntryHiveAdapter extends TypeAdapter<CaseLogEntryHive> {
  @override
  final typeId = 7;

  @override
  CaseLogEntryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaseLogEntryHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      seq: (fields[2] as num).toInt(),
      fromLocation: fields[3] as String,
      fromStage: fields[4] as String,
      fromStep: fields[5] as String,
      toLocation: fields[6] as String,
      toStage: fields[7] as String,
      toStep: fields[8] as String,
      createdByUid: fields[9] as String,
      actorRole: fields[10] as String,
      actionType: fields[11] as String,
      actionReason: fields[12] as String,
      patientVisible: fields[13] as bool,
      createdAt: fields[14] as String,
      lastUpdatedAt: fields[15] as String,
      synced: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CaseLogEntryHive obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.seq)
      ..writeByte(3)
      ..write(obj.fromLocation)
      ..writeByte(4)
      ..write(obj.fromStage)
      ..writeByte(5)
      ..write(obj.fromStep)
      ..writeByte(6)
      ..write(obj.toLocation)
      ..writeByte(7)
      ..write(obj.toStage)
      ..writeByte(8)
      ..write(obj.toStep)
      ..writeByte(9)
      ..write(obj.createdByUid)
      ..writeByte(10)
      ..write(obj.actorRole)
      ..writeByte(11)
      ..write(obj.actionType)
      ..writeByte(12)
      ..write(obj.actionReason)
      ..writeByte(13)
      ..write(obj.patientVisible)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.lastUpdatedAt)
      ..writeByte(16)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseLogEntryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
