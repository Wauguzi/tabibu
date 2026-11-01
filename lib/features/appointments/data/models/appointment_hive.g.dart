// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentHiveAdapter extends TypeAdapter<AppointmentHive> {
  @override
  final typeId = 24;

  @override
  AppointmentHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentHive(
      uid: fields[0] as String,
      type: fields[1] as String,
      status: fields[2] as String,
      patientUid: fields[3] as String,
      patientId: fields[4] as String,
      patientName: fields[5] as String,
      doctorUid: fields[6] as String,
      doctorName: fields[7] as String,
      facilityName: fields[8] as String,
      createdByUid: fields[9] as String,
      scheduledStart: fields[10] as String,
      scheduledEnd: fields[11] as String,
      symptomText: fields[12] as String,
      inputMode: fields[13] as String,
      symptomLanguage: fields[14] as String,
      intakeStatus: fields[15] as String,
      discussedCaseUid: fields[16] as String,
      discussedOrderNumber: fields[17] as String,
      caseUids: (fields[18] as List).cast<String>(),
      expiresAt: fields[19] as String,
      respondedAt: fields[20] as String,
      acceptedAt: fields[21] as String,
      declineReason: fields[22] as String,
      declineNote: fields[23] as String,
      cancelledAt: fields[24] as String,
      cancelledByUid: fields[25] as String,
      cancelNote: fields[26] as String,
      completedAt: fields[27] as String,
      createdAt: fields[28] as String,
      lastUpdatedAt: fields[29] as String,
      synced: fields[30] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentHive obj) {
    writer
      ..writeByte(31)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.patientUid)
      ..writeByte(4)
      ..write(obj.patientId)
      ..writeByte(5)
      ..write(obj.patientName)
      ..writeByte(6)
      ..write(obj.doctorUid)
      ..writeByte(7)
      ..write(obj.doctorName)
      ..writeByte(8)
      ..write(obj.facilityName)
      ..writeByte(9)
      ..write(obj.createdByUid)
      ..writeByte(10)
      ..write(obj.scheduledStart)
      ..writeByte(11)
      ..write(obj.scheduledEnd)
      ..writeByte(12)
      ..write(obj.symptomText)
      ..writeByte(13)
      ..write(obj.inputMode)
      ..writeByte(14)
      ..write(obj.symptomLanguage)
      ..writeByte(15)
      ..write(obj.intakeStatus)
      ..writeByte(16)
      ..write(obj.discussedCaseUid)
      ..writeByte(17)
      ..write(obj.discussedOrderNumber)
      ..writeByte(18)
      ..write(obj.caseUids)
      ..writeByte(19)
      ..write(obj.expiresAt)
      ..writeByte(20)
      ..write(obj.respondedAt)
      ..writeByte(21)
      ..write(obj.acceptedAt)
      ..writeByte(22)
      ..write(obj.declineReason)
      ..writeByte(23)
      ..write(obj.declineNote)
      ..writeByte(24)
      ..write(obj.cancelledAt)
      ..writeByte(25)
      ..write(obj.cancelledByUid)
      ..writeByte(26)
      ..write(obj.cancelNote)
      ..writeByte(27)
      ..write(obj.completedAt)
      ..writeByte(28)
      ..write(obj.createdAt)
      ..writeByte(29)
      ..write(obj.lastUpdatedAt)
      ..writeByte(30)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
