// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_payment_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CasePaymentHiveAdapter extends TypeAdapter<CasePaymentHive> {
  @override
  final typeId = 8;

  @override
  CasePaymentHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CasePaymentHive(
      caseUid: fields[0] as String,
      method: fields[1] as String,
      insurerId: fields[2] as String,
      insurerName: fields[3] as String,
      policyNumber: fields[4] as String,
      createdByUid: fields[5] as String,
      createdAt: fields[6] as String,
      lastUpdatedAt: fields[7] as String,
      synced: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CasePaymentHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.caseUid)
      ..writeByte(1)
      ..write(obj.method)
      ..writeByte(2)
      ..write(obj.insurerId)
      ..writeByte(3)
      ..write(obj.insurerName)
      ..writeByte(4)
      ..write(obj.policyNumber)
      ..writeByte(5)
      ..write(obj.createdByUid)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastUpdatedAt)
      ..writeByte(8)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CasePaymentHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
