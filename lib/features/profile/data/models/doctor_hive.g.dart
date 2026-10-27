// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoctorHiveAdapter extends TypeAdapter<DoctorHive> {
  @override
  final typeId = 1;

  @override
  DoctorHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoctorHive(
      uid: fields[0] as String,
      title: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      email: fields[4] as String,
      phoneNumber: fields[5] as String,
      profilePictureUrl: fields[6] as String,
      isPathologist: fields[7] as bool,
      specialties: (fields[8] as List).cast<String>(),
      bio: fields[9] as String,
      kmpdcNumber: fields[10] as String,
      licenseUrls: (fields[11] as List).cast<String>(),
      verificationStatus: fields[12] as String,
      facilityId: fields[13] as String,
      facilityMflCode: fields[14] as String,
      facilityName: fields[15] as String,
      county: fields[16] as String,
      subCounty: fields[17] as String,
      geohash: fields[18] as String,
      isAvailable: fields[19] as bool,
      fcmTokens: (fields[20] as List).cast<String>(),
      language: fields[21] as String,
      receiveNotifications: fields[22] as bool,
      appointmentsHandled: (fields[23] as num).toInt(),
      ordersCreated: (fields[24] as num).toInt(),
      reportsSigned: (fields[25] as num).toInt(),
      termsAcceptedAt: fields[26] as String,
      createdAt: fields[27] as String,
      lastUpdatedAt: fields[28] as String,
      synced: fields[29] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DoctorHive obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.profilePictureUrl)
      ..writeByte(7)
      ..write(obj.isPathologist)
      ..writeByte(8)
      ..write(obj.specialties)
      ..writeByte(9)
      ..write(obj.bio)
      ..writeByte(10)
      ..write(obj.kmpdcNumber)
      ..writeByte(11)
      ..write(obj.licenseUrls)
      ..writeByte(12)
      ..write(obj.verificationStatus)
      ..writeByte(13)
      ..write(obj.facilityId)
      ..writeByte(14)
      ..write(obj.facilityMflCode)
      ..writeByte(15)
      ..write(obj.facilityName)
      ..writeByte(16)
      ..write(obj.county)
      ..writeByte(17)
      ..write(obj.subCounty)
      ..writeByte(18)
      ..write(obj.geohash)
      ..writeByte(19)
      ..write(obj.isAvailable)
      ..writeByte(20)
      ..write(obj.fcmTokens)
      ..writeByte(21)
      ..write(obj.language)
      ..writeByte(22)
      ..write(obj.receiveNotifications)
      ..writeByte(23)
      ..write(obj.appointmentsHandled)
      ..writeByte(24)
      ..write(obj.ordersCreated)
      ..writeByte(25)
      ..write(obj.reportsSigned)
      ..writeByte(26)
      ..write(obj.termsAcceptedAt)
      ..writeByte(27)
      ..write(obj.createdAt)
      ..writeByte(28)
      ..write(obj.lastUpdatedAt)
      ..writeByte(29)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
