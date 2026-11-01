// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worklist_entry_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorklistEntryHiveAdapter extends TypeAdapter<WorklistEntryHive> {
  @override
  final typeId = 22;

  @override
  WorklistEntryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorklistEntryHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      pathologistUid: fields[2] as String,
      orderNumber: fields[3] as String,
      testName: fields[4] as String,
      profile: fields[5] as String,
      status: fields[6] as String,
      prereadStatus: fields[7] as String,
      urgency: fields[8] as String,
      confidenceBand: fields[9] as String,
      confidence: (fields[10] as num).toDouble(),
      riskFlag: fields[11] as bool,
      severity: fields[12] as String,
      basePriority: (fields[13] as num).toInt(),
      waitingSince: fields[14] as String,
      assignedAt: fields[15] as String,
      lastUpdatedAt: fields[16] as String,
      synced: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorklistEntryHive obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.pathologistUid)
      ..writeByte(3)
      ..write(obj.orderNumber)
      ..writeByte(4)
      ..write(obj.testName)
      ..writeByte(5)
      ..write(obj.profile)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.prereadStatus)
      ..writeByte(8)
      ..write(obj.urgency)
      ..writeByte(9)
      ..write(obj.confidenceBand)
      ..writeByte(10)
      ..write(obj.confidence)
      ..writeByte(11)
      ..write(obj.riskFlag)
      ..writeByte(12)
      ..write(obj.severity)
      ..writeByte(13)
      ..write(obj.basePriority)
      ..writeByte(14)
      ..write(obj.waitingSince)
      ..writeByte(15)
      ..write(obj.assignedAt)
      ..writeByte(16)
      ..write(obj.lastUpdatedAt)
      ..writeByte(17)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorklistEntryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
