import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_hive.dart';
import 'package:tabibu/features/cases/data/models/slide_image_hive.dart';

part 'case_hive.g.dart';

/// Cached [CaseModel], in the same field order.
@HiveType(typeId: 4)
class CaseHive {
  CaseHive({
    required this.uid,
    required this.orderNumber,
    required this.appointmentUid,
    required this.createdByUid,
    required this.doctorUid,
    required this.doctorName,
    required this.doctorFacilityName,
    required this.patientId,
    required this.patientUid,
    required this.patientName,
    required this.patientSex,
    required this.patientAgeYears,
    required this.requestedPathologistUid,
    required this.requestedPathologistName,
    required this.pathologistRequestedAt,
    required this.pathologistRequestExpiresAt,
    required this.declinedPathologistUids,
    required this.pathologistUid,
    required this.pathologistName,
    required this.pathologistAcceptedAt,
    required this.viewerUids,
    required this.participantUids,
    required this.tests,
    required this.totalPriceKes,
    required this.isPriceEstimate,
    required this.priority,
    required this.clinicalNotes,
    required this.sampleNotes,
    required this.notesLanguage,
    required this.sampleCollectedAt,
    required this.sampleReceivedAt,
    required this.labAccessionNo,
    required this.requiresSlides,
    required this.slideUploadUids,
    required this.slideImages,
    required this.prereadRunUid,
    required this.currentReportUid,
    required this.resultState,
    required this.discussionAppointmentUid,
    required this.currentLocation,
    required this.currentStage,
    required this.currentStep,
    required this.stageSeq,
    required this.stageEnteredAt,
    required this.releasedToPatient,
    required this.discussedAt,
    required this.releasedAt,
    required this.cancelReason,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory CaseHive.fromModel(CaseModel model) {
    return CaseHive(
      uid: model.uid,
      orderNumber: model.orderNumber,
      appointmentUid: model.appointmentUid,
      createdByUid: model.createdByUid,
      doctorUid: model.doctorUid,
      doctorName: model.doctorName,
      doctorFacilityName: model.doctorFacilityName,
      patientId: model.patientId,
      patientUid: model.patientUid,
      patientName: model.patientName,
      patientSex: model.patientSex,
      patientAgeYears: model.patientAgeYears,
      requestedPathologistUid: model.requestedPathologistUid,
      requestedPathologistName: model.requestedPathologistName,
      pathologistRequestedAt: model.pathologistRequestedAt,
      pathologistRequestExpiresAt: model.pathologistRequestExpiresAt,
      declinedPathologistUids: model.declinedPathologistUids,
      pathologistUid: model.pathologistUid,
      pathologistName: model.pathologistName,
      pathologistAcceptedAt: model.pathologistAcceptedAt,
      viewerUids: model.viewerUids,
      participantUids: model.participantUids,
      tests: model.tests.map(OrderedTestHive.fromModel).toList(),
      totalPriceKes: model.totalPriceKes,
      isPriceEstimate: model.isPriceEstimate,
      priority: model.priority,
      clinicalNotes: model.clinicalNotes,
      sampleNotes: model.sampleNotes,
      notesLanguage: model.notesLanguage,
      sampleCollectedAt: model.sampleCollectedAt,
      sampleReceivedAt: model.sampleReceivedAt,
      labAccessionNo: model.labAccessionNo,
      requiresSlides: model.requiresSlides,
      slideUploadUids: model.slideUploadUids,
      slideImages: model.slideImages.map(SlideImageHive.fromModel).toList(),
      prereadRunUid: model.prereadRunUid,
      currentReportUid: model.currentReportUid,
      resultState: model.resultState,
      discussionAppointmentUid: model.discussionAppointmentUid,
      currentLocation: model.currentLocation,
      currentStage: model.currentStage,
      currentStep: model.currentStep,
      stageSeq: model.stageSeq,
      stageEnteredAt: model.stageEnteredAt,
      releasedToPatient: model.releasedToPatient,
      discussedAt: model.discussedAt,
      releasedAt: model.releasedAt,
      cancelReason: model.cancelReason,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  CaseModel toModel() {
    return CaseModel(
      uid: uid,
      orderNumber: orderNumber,
      appointmentUid: appointmentUid,
      createdByUid: createdByUid,
      doctorUid: doctorUid,
      doctorName: doctorName,
      doctorFacilityName: doctorFacilityName,
      patientId: patientId,
      patientUid: patientUid,
      patientName: patientName,
      patientSex: patientSex,
      patientAgeYears: patientAgeYears,
      requestedPathologistUid: requestedPathologistUid,
      requestedPathologistName: requestedPathologistName,
      pathologistRequestedAt: pathologistRequestedAt,
      pathologistRequestExpiresAt: pathologistRequestExpiresAt,
      declinedPathologistUids: declinedPathologistUids,
      pathologistUid: pathologistUid,
      pathologistName: pathologistName,
      pathologistAcceptedAt: pathologistAcceptedAt,
      viewerUids: viewerUids,
      participantUids: participantUids,
      tests: tests.map((test) => test.toModel()).toList(),
      totalPriceKes: totalPriceKes,
      isPriceEstimate: isPriceEstimate,
      priority: priority,
      clinicalNotes: clinicalNotes,
      sampleNotes: sampleNotes,
      notesLanguage: notesLanguage,
      sampleCollectedAt: sampleCollectedAt,
      sampleReceivedAt: sampleReceivedAt,
      labAccessionNo: labAccessionNo,
      requiresSlides: requiresSlides,
      slideUploadUids: slideUploadUids,
      slideImages: slideImages.map((image) => image.toModel()).toList(),
      prereadRunUid: prereadRunUid,
      currentReportUid: currentReportUid,
      resultState: resultState,
      discussionAppointmentUid: discussionAppointmentUid,
      currentLocation: currentLocation,
      currentStage: currentStage,
      currentStep: currentStep,
      stageSeq: stageSeq,
      stageEnteredAt: stageEnteredAt,
      releasedToPatient: releasedToPatient,
      discussedAt: discussedAt,
      releasedAt: releasedAt,
      cancelReason: cancelReason,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String orderNumber;

  @HiveField(2)
  final String appointmentUid;

  @HiveField(3)
  final String createdByUid;

  @HiveField(4)
  final String doctorUid;

  @HiveField(5)
  final String doctorName;

  @HiveField(6)
  final String doctorFacilityName;

  @HiveField(7)
  final String patientId;

  @HiveField(8)
  final String patientUid;

  @HiveField(9)
  final String patientName;

  @HiveField(10)
  final String patientSex;

  @HiveField(11)
  final int patientAgeYears;

  @HiveField(12)
  final String requestedPathologistUid;

  @HiveField(13)
  final String requestedPathologistName;

  @HiveField(14)
  final String pathologistRequestedAt;

  @HiveField(15)
  final String pathologistRequestExpiresAt;

  @HiveField(16)
  final List<String> declinedPathologistUids;

  @HiveField(17)
  final String pathologistUid;

  @HiveField(18)
  final String pathologistName;

  @HiveField(19)
  final String pathologistAcceptedAt;

  @HiveField(20)
  final List<String> viewerUids;

  @HiveField(21)
  final List<String> participantUids;

  @HiveField(22)
  final List<OrderedTestHive> tests;

  @HiveField(23)
  final int totalPriceKes;

  @HiveField(24)
  final bool isPriceEstimate;

  @HiveField(25)
  final String priority;

  @HiveField(26)
  final String clinicalNotes;

  @HiveField(27)
  final String sampleNotes;

  @HiveField(28)
  final String notesLanguage;

  @HiveField(29)
  final String sampleCollectedAt;

  @HiveField(30)
  final String sampleReceivedAt;

  @HiveField(31)
  final String labAccessionNo;

  @HiveField(32)
  final bool requiresSlides;

  @HiveField(33)
  final List<String> slideUploadUids;

  @HiveField(34)
  final List<SlideImageHive> slideImages;

  @HiveField(35)
  final String prereadRunUid;

  @HiveField(36)
  final String currentReportUid;

  @HiveField(37)
  final String resultState;

  @HiveField(38)
  final String discussionAppointmentUid;

  @HiveField(39)
  final String currentLocation;

  @HiveField(40)
  final String currentStage;

  @HiveField(41)
  final String currentStep;

  @HiveField(42)
  final int stageSeq;

  @HiveField(43)
  final String stageEnteredAt;

  @HiveField(44)
  final bool releasedToPatient;

  @HiveField(45)
  final String discussedAt;

  @HiveField(46)
  final String releasedAt;

  @HiveField(47)
  final String cancelReason;

  @HiveField(48)
  final String createdAt;

  @HiveField(49)
  final String lastUpdatedAt;

  @HiveField(50)
  final bool synced;
}
