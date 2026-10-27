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
      specialization: fields[6] as String,
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
    );
  }

  @override
  void write(BinaryWriter writer, PractitionerHive obj) {
    writer
      ..writeByte(20)
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
      ..write(obj.specialization)
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
      ..write(obj.synced);
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
