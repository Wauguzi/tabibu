// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_draft_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportDraftHiveAdapter extends TypeAdapter<ReportDraftHive> {
  @override
  final typeId = 20;

  @override
  ReportDraftHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportDraftHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      pathologistUid: fields[2] as String,
      kind: fields[3] as String,
      status: fields[4] as String,
      baseReportUid: fields[5] as String,
      targetReportUid: fields[6] as String,
      prereadRunUid: fields[7] as String,
      templateKey: fields[8] as String,
      title: fields[9] as String,
      diagnosisType: fields[10] as String,
      diagnosis: fields[11] as String,
      comments: fields[12] as String,
      responses: (fields[13] as List).cast<ReportResponseHive>(),
      labelOverrides: (fields[14] as Map).cast<String, String>(),
      labelOverrideCount: (fields[15] as num).toInt(),
      isCritical: fields[16] as bool,
      addendumText: fields[17] as String,
      amendmentReason: fields[18] as String,
      diagnosisStartedAt: fields[19] as String,
      startedFromPreread: fields[20] as bool,
      startedAt: fields[21] as String,
      signedReportUid: fields[22] as String,
      notifiableFindings: (fields[23] as List).cast<NotifiableFindingHive>(),
      hintShownDiseaseIds: (fields[24] as List).cast<String>(),
      confirmatoryRequests: (fields[25] as List).cast<String>(),
      createdByUid: fields[26] as String,
      language: fields[27] as String,
      lastUpdatedAt: fields[28] as String,
      synced: fields[29] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReportDraftHive obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.pathologistUid)
      ..writeByte(3)
      ..write(obj.kind)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.baseReportUid)
      ..writeByte(6)
      ..write(obj.targetReportUid)
      ..writeByte(7)
      ..write(obj.prereadRunUid)
      ..writeByte(8)
      ..write(obj.templateKey)
      ..writeByte(9)
      ..write(obj.title)
      ..writeByte(10)
      ..write(obj.diagnosisType)
      ..writeByte(11)
      ..write(obj.diagnosis)
      ..writeByte(12)
      ..write(obj.comments)
      ..writeByte(13)
      ..write(obj.responses)
      ..writeByte(14)
      ..write(obj.labelOverrides)
      ..writeByte(15)
      ..write(obj.labelOverrideCount)
      ..writeByte(16)
      ..write(obj.isCritical)
      ..writeByte(17)
      ..write(obj.addendumText)
      ..writeByte(18)
      ..write(obj.amendmentReason)
      ..writeByte(19)
      ..write(obj.diagnosisStartedAt)
      ..writeByte(20)
      ..write(obj.startedFromPreread)
      ..writeByte(21)
      ..write(obj.startedAt)
      ..writeByte(22)
      ..write(obj.signedReportUid)
      ..writeByte(23)
      ..write(obj.notifiableFindings)
      ..writeByte(24)
      ..write(obj.hintShownDiseaseIds)
      ..writeByte(25)
      ..write(obj.confirmatoryRequests)
      ..writeByte(26)
      ..write(obj.createdByUid)
      ..writeByte(27)
      ..write(obj.language)
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
      other is ReportDraftHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
