// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_alert_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PublicAlertHiveAdapter extends TypeAdapter<PublicAlertHive> {
  @override
  final typeId = 46;

  @override
  PublicAlertHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PublicAlertHive(
      uid: fields[0] as String,
      diseaseId: fields[1] as String,
      diseaseNameEn: fields[2] as String,
      diseaseNameSw: fields[3] as String,
      countyId: (fields[4] as num).toInt(),
      countyName: fields[5] as String,
      clinicianCountyIds: (fields[6] as List).cast<int>(),
      epiWeek: fields[7] as String,
      category: fields[8] as String,
      patientText: (fields[9] as Map).cast<String, AlertTextHive>(),
      patientGuidance: (fields[10] as List).cast<GuidanceBulletHive>(),
      sources: (fields[11] as List).cast<GuidanceSourceHive>(),
      issuedAt: fields[12] as String,
      patientsReleased: fields[13] as bool,
      patientsReleasedAt: fields[14] as String,
      synthetic: fields[15] as bool,
      createdAt: fields[16] as String,
      lastUpdatedAt: fields[17] as String,
      synced: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PublicAlertHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.diseaseId)
      ..writeByte(2)
      ..write(obj.diseaseNameEn)
      ..writeByte(3)
      ..write(obj.diseaseNameSw)
      ..writeByte(4)
      ..write(obj.countyId)
      ..writeByte(5)
      ..write(obj.countyName)
      ..writeByte(6)
      ..write(obj.clinicianCountyIds)
      ..writeByte(7)
      ..write(obj.epiWeek)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.patientText)
      ..writeByte(10)
      ..write(obj.patientGuidance)
      ..writeByte(11)
      ..write(obj.sources)
      ..writeByte(12)
      ..write(obj.issuedAt)
      ..writeByte(13)
      ..write(obj.patientsReleased)
      ..writeByte(14)
      ..write(obj.patientsReleasedAt)
      ..writeByte(15)
      ..write(obj.synthetic)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.lastUpdatedAt)
      ..writeByte(18)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicAlertHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
