// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathology_report_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PathologyReportHiveAdapter extends TypeAdapter<PathologyReportHive> {
  @override
  final typeId = 16;

  @override
  PathologyReportHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PathologyReportHive(
      uid: fields[0] as String,
      caseUid: fields[1] as String,
      version: (fields[2] as num).toInt(),
      stage: fields[3] as String,
      status: fields[4] as String,
      orderNumber: fields[5] as String,
      testName: fields[6] as String,
      sampleCollectedAt: fields[7] as String,
      sampleReceivedAt: fields[8] as String,
      labAccessionNo: fields[9] as String,
      profile: fields[10] as String,
      templateKey: fields[11] as String,
      title: fields[12] as String,
      diagnosisType: fields[13] as String,
      diagnosis: fields[14] as String,
      comments: fields[15] as String,
      responses: (fields[16] as List).cast<ReportResponseHive>(),
      isCritical: fields[17] as bool,
      measurements: (fields[18] as List).cast<ReportMeasurementHive>(),
      addenda: (fields[19] as List).cast<ReportAddendumHive>(),
      amendmentReason: fields[20] as String,
      prereadRunUid: fields[21] as String,
      doctorUid: fields[22] as String,
      pathologistUid: fields[23] as String,
      readerUids: (fields[24] as List).cast<String>(),
      signedByTitle: fields[25] as String,
      signedByName: fields[26] as String,
      signedByKmpdcNumber: fields[27] as String,
      signedByFacilityName: fields[28] as String,
      signaturePath: fields[29] as String,
      signatureSha256: fields[30] as String,
      contentSha256: fields[31] as String,
      startedAt: fields[32] as String,
      scoredAt: fields[33] as String,
      signedAt: fields[34] as String,
      doctorOpenedAt: fields[35] as String,
      releasedToPatient: fields[36] as bool,
      releasedAt: fields[37] as String,
      releasedByUid: fields[38] as String,
      supersededAt: fields[39] as String,
      supersededByUid: fields[40] as String,
      notifiableFindings: (fields[41] as List).cast<NotifiableFindingHive>(),
      confirmatoryRequests: (fields[42] as List).cast<String>(),
      createdByUid: fields[43] as String,
      language: fields[44] as String,
      lastUpdatedAt: fields[45] as String,
      synced: fields[46] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PathologyReportHive obj) {
    writer
      ..writeByte(47)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.caseUid)
      ..writeByte(2)
      ..write(obj.version)
      ..writeByte(3)
      ..write(obj.stage)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.orderNumber)
      ..writeByte(6)
      ..write(obj.testName)
      ..writeByte(7)
      ..write(obj.sampleCollectedAt)
      ..writeByte(8)
      ..write(obj.sampleReceivedAt)
      ..writeByte(9)
      ..write(obj.labAccessionNo)
      ..writeByte(10)
      ..write(obj.profile)
      ..writeByte(11)
      ..write(obj.templateKey)
      ..writeByte(12)
      ..write(obj.title)
      ..writeByte(13)
      ..write(obj.diagnosisType)
      ..writeByte(14)
      ..write(obj.diagnosis)
      ..writeByte(15)
      ..write(obj.comments)
      ..writeByte(16)
      ..write(obj.responses)
      ..writeByte(17)
      ..write(obj.isCritical)
      ..writeByte(18)
      ..write(obj.measurements)
      ..writeByte(19)
      ..write(obj.addenda)
      ..writeByte(20)
      ..write(obj.amendmentReason)
      ..writeByte(21)
      ..write(obj.prereadRunUid)
      ..writeByte(22)
      ..write(obj.doctorUid)
      ..writeByte(23)
      ..write(obj.pathologistUid)
      ..writeByte(24)
      ..write(obj.readerUids)
      ..writeByte(25)
      ..write(obj.signedByTitle)
      ..writeByte(26)
      ..write(obj.signedByName)
      ..writeByte(27)
      ..write(obj.signedByKmpdcNumber)
      ..writeByte(28)
      ..write(obj.signedByFacilityName)
      ..writeByte(29)
      ..write(obj.signaturePath)
      ..writeByte(30)
      ..write(obj.signatureSha256)
      ..writeByte(31)
      ..write(obj.contentSha256)
      ..writeByte(32)
      ..write(obj.startedAt)
      ..writeByte(33)
      ..write(obj.scoredAt)
      ..writeByte(34)
      ..write(obj.signedAt)
      ..writeByte(35)
      ..write(obj.doctorOpenedAt)
      ..writeByte(36)
      ..write(obj.releasedToPatient)
      ..writeByte(37)
      ..write(obj.releasedAt)
      ..writeByte(38)
      ..write(obj.releasedByUid)
      ..writeByte(39)
      ..write(obj.supersededAt)
      ..writeByte(40)
      ..write(obj.supersededByUid)
      ..writeByte(41)
      ..write(obj.notifiableFindings)
      ..writeByte(42)
      ..write(obj.confirmatoryRequests)
      ..writeByte(43)
      ..write(obj.createdByUid)
      ..writeByte(44)
      ..write(obj.language)
      ..writeByte(45)
      ..write(obj.lastUpdatedAt)
      ..writeByte(46)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathologyReportHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
