// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_code_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShareCodeHiveAdapter extends TypeAdapter<ShareCodeHive> {
  @override
  final typeId = 9;

  @override
  ShareCodeHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShareCodeHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      reportUid: fields[2] as String,
      purpose: fields[3] as String,
      createdByUid: fields[4] as String,
      createdByRole: fields[5] as String,
      recipientUid: fields[6] as String,
      status: fields[7] as String,
      attempts: (fields[8] as num).toInt(),
      reissueCount: (fields[9] as num).toInt(),
      expiresAt: fields[10] as String,
      redeemedAt: fields[11] as String,
      notificationUid: fields[12] as String,
      createdAt: fields[13] as String,
      lastUpdatedAt: fields[14] as String,
      synced: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShareCodeHive obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.reportUid)
      ..writeByte(3)
      ..write(obj.purpose)
      ..writeByte(4)
      ..write(obj.createdByUid)
      ..writeByte(5)
      ..write(obj.createdByRole)
      ..writeByte(6)
      ..write(obj.recipientUid)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.attempts)
      ..writeByte(9)
      ..write(obj.reissueCount)
      ..writeByte(10)
      ..write(obj.expiresAt)
      ..writeByte(11)
      ..write(obj.redeemedAt)
      ..writeByte(12)
      ..write(obj.notificationUid)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.lastUpdatedAt)
      ..writeByte(15)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShareCodeHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
