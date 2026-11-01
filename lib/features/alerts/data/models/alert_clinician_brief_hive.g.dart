// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_clinician_brief_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertClinicianBriefHiveAdapter
    extends TypeAdapter<AlertClinicianBriefHive> {
  @override
  final typeId = 50;

  @override
  AlertClinicianBriefHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertClinicianBriefHive(
      uid: fields[0] as String,
      alertUid: fields[1] as String,
      countyId: (fields[2] as num).toInt(),
      clinicianText: (fields[3] as Map).cast<String, AlertTextHive>(),
      clinicianGuidance: (fields[4] as List).cast<GuidanceBulletHive>(),
      sources: (fields[5] as List).cast<GuidanceSourceHive>(),
      confirmedCount: (fields[6] as num).toInt(),
      weekStart: fields[7] as String,
      rule: fields[8] as String,
      categoryVerified: fields[9] as bool,
      lastUpdatedAt: fields[10] as String,
      synced: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AlertClinicianBriefHive obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.alertUid)
      ..writeByte(2)
      ..write(obj.countyId)
      ..writeByte(3)
      ..write(obj.clinicianText)
      ..writeByte(4)
      ..write(obj.clinicianGuidance)
      ..writeByte(5)
      ..write(obj.sources)
      ..writeByte(6)
      ..write(obj.confirmedCount)
      ..writeByte(7)
      ..write(obj.weekStart)
      ..writeByte(8)
      ..write(obj.rule)
      ..writeByte(9)
      ..write(obj.categoryVerified)
      ..writeByte(10)
      ..write(obj.lastUpdatedAt)
      ..writeByte(11)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertClinicianBriefHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
