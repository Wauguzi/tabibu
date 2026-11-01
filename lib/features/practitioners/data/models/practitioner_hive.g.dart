// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practitioner_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PractitionerHiveAdapter extends TypeAdapter<PractitionerHive> {
  @override
  final typeId = 2;

  @override
  PractitionerHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PractitionerHive(
      uid: fields[0] as String,
      title: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      profilePictureUrl: fields[4] as String,
      isPathologist: fields[5] as bool,
      specialties: (fields[6] as List).cast<String>(),
      bio: fields[7] as String,
      facilityId: fields[8] as String,
      facilityMflCode: fields[9] as String,
      facilityName: fields[10] as String,
      county: fields[11] as String,
      subCounty: fields[12] as String,
      geohash: fields[13] as String,
      isAvailable: fields[14] as bool,
      appointmentsHandled: (fields[15] as num).toInt(),
      ordersCreated: (fields[16] as num).toInt(),
      reportsSigned: (fields[17] as num).toInt(),
      lastUpdatedAt: fields[18] as String,
      synced: fields[19] as bool,
      workingDays: fields[20] == null
          ? [1, 2, 3, 4, 5]
          : (fields[20] as List).cast<int>(),
      dayStartMinute: fields[21] == null ? 480 : (fields[21] as num).toInt(),
      dayEndMinute: fields[22] == null ? 1020 : (fields[22] as num).toInt(),
      busySlots: fields[23] == null ? [] : (fields[23] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PractitionerHive obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.profilePictureUrl)
      ..writeByte(5)
      ..write(obj.isPathologist)
      ..writeByte(6)
      ..write(obj.specialties)
      ..writeByte(7)
      ..write(obj.bio)
      ..writeByte(8)
      ..write(obj.facilityId)
      ..writeByte(9)
      ..write(obj.facilityMflCode)
      ..writeByte(10)
      ..write(obj.facilityName)
      ..writeByte(11)
      ..write(obj.county)
      ..writeByte(12)
      ..write(obj.subCounty)
      ..writeByte(13)
      ..write(obj.geohash)
      ..writeByte(14)
      ..write(obj.isAvailable)
      ..writeByte(15)
      ..write(obj.appointmentsHandled)
      ..writeByte(16)
      ..write(obj.ordersCreated)
      ..writeByte(17)
      ..write(obj.reportsSigned)
      ..writeByte(18)
      ..write(obj.lastUpdatedAt)
      ..writeByte(19)
      ..write(obj.synced)
      ..writeByte(20)
      ..write(obj.workingDays)
      ..writeByte(21)
      ..write(obj.dayStartMinute)
      ..writeByte(22)
      ..write(obj.dayEndMinute)
      ..writeByte(23)
      ..write(obj.busySlots);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PractitionerHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
