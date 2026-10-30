// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientHiveAdapter extends TypeAdapter<PatientHive> {
  @override
  final typeId = 0;

  @override
  PatientHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientHive(
      patientId: fields[0] as String,
      uid: fields[1] as String,
      isRegistered: fields[2] as bool,
      createdByUid: fields[3] as String,
      firstName: fields[4] as String,
      middleName: fields[5] as String,
      lastName: fields[6] as String,
      sex: fields[7] as String,
      dateOfBirth: fields[8] as String,
      phoneNumber: fields[9] as String,
      email: fields[10] as String,
      profilePictureUrl: fields[11] as String,
      county: fields[12] as String,
      subCounty: fields[13] as String,
      geohash: fields[14] as String,
      doctorUids: (fields[15] as List).cast<String>(),
      fcmTokens: (fields[16] as List).cast<String>(),
      language: fields[17] as String,
      receiveNotifications: fields[18] as bool,
      casesReported: (fields[19] as num).toInt(),
      appointmentsBooked: (fields[20] as num).toInt(),
      createdAt: fields[21] as String,
      lastUpdatedAt: fields[22] as String,
      synced: fields[23] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PatientHive obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.patientId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.isRegistered)
      ..writeByte(3)
      ..write(obj.createdByUid)
      ..writeByte(4)
      ..write(obj.firstName)
      ..writeByte(5)
      ..write(obj.middleName)
      ..writeByte(6)
      ..write(obj.lastName)
      ..writeByte(7)
      ..write(obj.sex)
      ..writeByte(8)
      ..write(obj.dateOfBirth)
      ..writeByte(9)
      ..write(obj.phoneNumber)
      ..writeByte(10)
      ..write(obj.email)
      ..writeByte(11)
      ..write(obj.profilePictureUrl)
      ..writeByte(12)
      ..write(obj.county)
      ..writeByte(13)
      ..write(obj.subCounty)
      ..writeByte(14)
      ..write(obj.geohash)
      ..writeByte(15)
      ..write(obj.doctorUids)
      ..writeByte(16)
      ..write(obj.fcmTokens)
      ..writeByte(17)
      ..write(obj.language)
      ..writeByte(18)
      ..write(obj.receiveNotifications)
      ..writeByte(19)
      ..write(obj.casesReported)
      ..writeByte(20)
      ..write(obj.appointmentsBooked)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.lastUpdatedAt)
      ..writeByte(23)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
