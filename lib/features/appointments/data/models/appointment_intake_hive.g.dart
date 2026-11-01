// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_intake_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentIntakeHiveAdapter extends TypeAdapter<AppointmentIntakeHive> {
  @override
  final typeId = 25;

  @override
  AppointmentIntakeHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentIntakeHive(
      uid: fields[0] as String,
      appointmentUid: fields[1] as String,
      doctorUid: fields[2] as String,
      status: fields[3] as String,
      inputText: fields[4] as String,
      inputMode: fields[5] as String,
      inputLanguage: fields[6] as String,
      transcriptLanguage: fields[7] as String,
      transcriptAcceptedUnchanged: fields[8] as bool,
      transcriptEditDistance: (fields[9] as num).toDouble(),
      drafts: (fields[10] as Map).cast<String, IntakeDraftHive>(),
      modelVersion: fields[11] as String,
      promptVersion: fields[12] as String,
      failureReason: fields[13] as String,
      requestedAt: fields[14] as String,
      readyAt: fields[15] as String,
      lastUpdatedAt: fields[16] as String,
      synced: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentIntakeHive obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.appointmentUid)
      ..writeByte(2)
      ..write(obj.doctorUid)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.inputText)
      ..writeByte(5)
      ..write(obj.inputMode)
      ..writeByte(6)
      ..write(obj.inputLanguage)
      ..writeByte(7)
      ..write(obj.transcriptLanguage)
      ..writeByte(8)
      ..write(obj.transcriptAcceptedUnchanged)
      ..writeByte(9)
      ..write(obj.transcriptEditDistance)
      ..writeByte(10)
      ..write(obj.drafts)
      ..writeByte(11)
      ..write(obj.modelVersion)
      ..writeByte(12)
      ..write(obj.promptVersion)
      ..writeByte(13)
      ..write(obj.failureReason)
      ..writeByte(14)
      ..write(obj.requestedAt)
      ..writeByte(15)
      ..write(obj.readyAt)
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
      other is AppointmentIntakeHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
