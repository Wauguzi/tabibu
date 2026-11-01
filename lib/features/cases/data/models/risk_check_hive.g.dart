// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_check_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RiskCheckHiveAdapter extends TypeAdapter<RiskCheckHive> {
  @override
  final typeId = 10;

  @override
  RiskCheckHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiskCheckHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      status: fields[2] as String,
      inputLanguage: fields[3] as String,
      suggestedLabTestIds: (fields[4] as List).cast<String>(),
      advisoryKey: fields[5] as String,
      advisoryEn: fields[6] as String,
      advisorySw: fields[7] as String,
      models: (fields[8] as Map).cast<String, String>(),
      failureReason: fields[9] as String,
      requestedAt: fields[10] as String,
      readyAt: fields[11] as String,
      lastUpdatedAt: fields[12] as String,
      synced: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RiskCheckHive obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.inputLanguage)
      ..writeByte(4)
      ..write(obj.suggestedLabTestIds)
      ..writeByte(5)
      ..write(obj.advisoryKey)
      ..writeByte(6)
      ..write(obj.advisoryEn)
      ..writeByte(7)
      ..write(obj.advisorySw)
      ..writeByte(8)
      ..write(obj.models)
      ..writeByte(9)
      ..write(obj.failureReason)
      ..writeByte(10)
      ..write(obj.requestedAt)
      ..writeByte(11)
      ..write(obj.readyAt)
      ..writeByte(12)
      ..write(obj.lastUpdatedAt)
      ..writeByte(13)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskCheckHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
