// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preread_score_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrereadScoreHiveAdapter extends TypeAdapter<PrereadScoreHive> {
  @override
  final typeId = 21;

  @override
  PrereadScoreHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrereadScoreHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      runUid: fields[2] as String,
      pathologistUid: fields[3] as String,
      profile: fields[4] as String,
      confidenceBand: fields[5] as String,
      urgency: fields[6] as String,
      overall: (fields[7] as num).toInt(),
      findingsVerdict: fields[8] as String,
      impressionVerdict: fields[9] as String,
      measurementsVerdict: fields[10] as String,
      segmentationVerdict: fields[11] as String,
      urgencyVerdict: fields[12] as String,
      comment: fields[13] as String,
      prereadShownAt: fields[14] as String,
      acceptedUnchanged: fields[15] as bool,
      scoredAt: fields[16] as String,
      createdByUid: fields[17] as String,
      lastUpdatedAt: fields[18] as String,
      synced: fields[19] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PrereadScoreHive obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.runUid)
      ..writeByte(3)
      ..write(obj.pathologistUid)
      ..writeByte(4)
      ..write(obj.profile)
      ..writeByte(5)
      ..write(obj.confidenceBand)
      ..writeByte(6)
      ..write(obj.urgency)
      ..writeByte(7)
      ..write(obj.overall)
      ..writeByte(8)
      ..write(obj.findingsVerdict)
      ..writeByte(9)
      ..write(obj.impressionVerdict)
      ..writeByte(10)
      ..write(obj.measurementsVerdict)
      ..writeByte(11)
      ..write(obj.segmentationVerdict)
      ..writeByte(12)
      ..write(obj.urgencyVerdict)
      ..writeByte(13)
      ..write(obj.comment)
      ..writeByte(14)
      ..write(obj.prereadShownAt)
      ..writeByte(15)
      ..write(obj.acceptedUnchanged)
      ..writeByte(16)
      ..write(obj.scoredAt)
      ..writeByte(17)
      ..write(obj.createdByUid)
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
      other is PrereadScoreHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
