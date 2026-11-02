// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaseHiveAdapter extends TypeAdapter<CaseHive> {
  @override
  final typeId = 4;

  @override
  CaseHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaseHive(
      uid: fields[0] as String,
      orderNumber: fields[1] as String,
      appointmentUid: fields[2] as String,
      createdByUid: fields[3] as String,
      doctorUid: fields[4] as String,
      doctorName: fields[5] as String,
      doctorFacilityName: fields[6] as String,
      patientId: fields[7] as String,
      patientUid: fields[8] as String,
      patientName: fields[9] as String,
      patientSex: fields[10] as String,
      patientAgeYears: (fields[11] as num).toInt(),
      requestedPathologistUid: fields[12] as String,
      requestedPathologistName: fields[13] as String,
      pathologistRequestedAt: fields[14] as String,
      pathologistRequestExpiresAt: fields[15] as String,
      declinedPathologistUids: (fields[16] as List).cast<String>(),
      pathologistUid: fields[17] as String,
      pathologistName: fields[18] as String,
      pathologistAcceptedAt: fields[19] as String,
      viewerUids: (fields[20] as List).cast<String>(),
      participantUids: (fields[21] as List).cast<String>(),
      tests: (fields[22] as List).cast<OrderedTestHive>(),
      totalPriceKes: (fields[23] as num).toInt(),
      isPriceEstimate: fields[24] as bool,
      priority: fields[25] as String,
      clinicalNotes: fields[26] as String,
      sampleNotes: fields[27] as String,
      notesLanguage: fields[28] as String,
      sampleCollectedAt: fields[29] as String,
      sampleReceivedAt: fields[30] as String,
      labAccessionNo: fields[31] as String,
      requiresSlides: fields[32] as bool,
      slideUploadUids: (fields[33] as List).cast<String>(),
      slideImages: (fields[34] as List).cast<SlideImageHive>(),
      prereadRunUid: fields[35] as String,
      currentReportUid: fields[36] as String,
      resultState: fields[37] as String,
      discussionAppointmentUid: fields[38] as String,
      currentLocation: fields[39] as String,
      currentStage: fields[40] as String,
      currentStep: fields[41] as String,
      stageSeq: (fields[42] as num).toInt(),
      stageEnteredAt: fields[43] as String,
      releasedToPatient: fields[44] as bool,
      discussedAt: fields[45] as String,
      releasedAt: fields[46] as String,
      cancelReason: fields[47] as String,
      createdAt: fields[48] as String,
      lastUpdatedAt: fields[49] as String,
      synced: fields[50] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CaseHive obj) {
    writer
      ..writeByte(51)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.appointmentUid)
      ..writeByte(3)
      ..write(obj.createdByUid)
      ..writeByte(4)
      ..write(obj.doctorUid)
      ..writeByte(5)
      ..write(obj.doctorName)
      ..writeByte(6)
      ..write(obj.doctorFacilityName)
      ..writeByte(7)
      ..write(obj.patientId)
      ..writeByte(8)
      ..write(obj.patientUid)
      ..writeByte(9)
      ..write(obj.patientName)
      ..writeByte(10)
      ..write(obj.patientSex)
      ..writeByte(11)
      ..write(obj.patientAgeYears)
      ..writeByte(12)
      ..write(obj.requestedPathologistUid)
      ..writeByte(13)
      ..write(obj.requestedPathologistName)
      ..writeByte(14)
      ..write(obj.pathologistRequestedAt)
      ..writeByte(15)
      ..write(obj.pathologistRequestExpiresAt)
      ..writeByte(16)
      ..write(obj.declinedPathologistUids)
      ..writeByte(17)
      ..write(obj.pathologistUid)
      ..writeByte(18)
      ..write(obj.pathologistName)
      ..writeByte(19)
      ..write(obj.pathologistAcceptedAt)
      ..writeByte(20)
      ..write(obj.viewerUids)
      ..writeByte(21)
      ..write(obj.participantUids)
      ..writeByte(22)
      ..write(obj.tests)
      ..writeByte(23)
      ..write(obj.totalPriceKes)
      ..writeByte(24)
      ..write(obj.isPriceEstimate)
      ..writeByte(25)
      ..write(obj.priority)
      ..writeByte(26)
      ..write(obj.clinicalNotes)
      ..writeByte(27)
      ..write(obj.sampleNotes)
      ..writeByte(28)
      ..write(obj.notesLanguage)
      ..writeByte(29)
      ..write(obj.sampleCollectedAt)
      ..writeByte(30)
      ..write(obj.sampleReceivedAt)
      ..writeByte(31)
      ..write(obj.labAccessionNo)
      ..writeByte(32)
      ..write(obj.requiresSlides)
      ..writeByte(33)
      ..write(obj.slideUploadUids)
      ..writeByte(34)
      ..write(obj.slideImages)
      ..writeByte(35)
      ..write(obj.prereadRunUid)
      ..writeByte(36)
      ..write(obj.currentReportUid)
      ..writeByte(37)
      ..write(obj.resultState)
      ..writeByte(38)
      ..write(obj.discussionAppointmentUid)
      ..writeByte(39)
      ..write(obj.currentLocation)
      ..writeByte(40)
      ..write(obj.currentStage)
      ..writeByte(41)
      ..write(obj.currentStep)
      ..writeByte(42)
      ..write(obj.stageSeq)
      ..writeByte(43)
      ..write(obj.stageEnteredAt)
      ..writeByte(44)
      ..write(obj.releasedToPatient)
      ..writeByte(45)
      ..write(obj.discussedAt)
      ..writeByte(46)
      ..write(obj.releasedAt)
      ..writeByte(47)
      ..write(obj.cancelReason)
      ..writeByte(48)
      ..write(obj.createdAt)
      ..writeByte(49)
      ..write(obj.lastUpdatedAt)
      ..writeByte(50)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
