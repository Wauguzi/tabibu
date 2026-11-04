import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/cases/data/models/slide_image_model.dart';

part 'case_model.freezed.dart';
part 'case_model.g.dart';

/// A `cases/{caseUid}` document: one pathology order and its state.
@freezed
abstract class CaseModel with _$CaseModel {
  // Nested models must call toJson(); this goes on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory CaseModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'orderNumber') @Default('') String orderNumber,
    @JsonKey(name: 'appointmentUid') @Default('') String appointmentUid,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'doctorUid') @Default('') String doctorUid,
    @JsonKey(name: 'doctorName') @Default('') String doctorName,
    @JsonKey(name: 'doctorFacilityName') @Default('') String doctorFacilityName,
    @JsonKey(name: 'patientId') @Default('') String patientId,
    @JsonKey(name: 'patientUid') @Default('') String patientUid,
    @JsonKey(name: 'patientName') @Default('') String patientName,
    @JsonKey(name: 'patientSex') @Default('') String patientSex,
    @JsonKey(name: 'patientAgeYears') @Default(0) int patientAgeYears,
    @JsonKey(name: 'requestedPathologistUid')
    @Default('')
    String requestedPathologistUid,
    @JsonKey(name: 'requestedPathologistName')
    @Default('')
    String requestedPathologistName,
    @JsonKey(name: 'pathologistRequestedAt')
    @Default('')
    String pathologistRequestedAt,
    @JsonKey(name: 'pathologistRequestExpiresAt')
    @Default('')
    String pathologistRequestExpiresAt,
    @JsonKey(name: 'declinedPathologistUids')
    @Default(<String>[])
    List<String> declinedPathologistUids,
    @JsonKey(name: 'pathologistUid') @Default('') String pathologistUid,
    @JsonKey(name: 'pathologistName') @Default('') String pathologistName,
    @JsonKey(name: 'pathologistAcceptedAt')
    @Default('')
    String pathologistAcceptedAt,
    @JsonKey(name: 'viewerUids') @Default(<String>[]) List<String> viewerUids,
    @JsonKey(name: 'participantUids')
    @Default(<String>[])
    List<String> participantUids,
    @JsonKey(name: 'tests')
    @Default(<OrderedTestModel>[])
    List<OrderedTestModel> tests,
    @JsonKey(name: 'totalPriceKes') @Default(0) int totalPriceKes,
    @JsonKey(name: 'isPriceEstimate') @Default(false) bool isPriceEstimate,
    @JsonKey(name: 'priority') @Default('Routine') String priority,
    @JsonKey(name: 'clinicalNotes') @Default('') String clinicalNotes,
    @JsonKey(name: 'sampleNotes') @Default('') String sampleNotes,
    @JsonKey(name: 'notesLanguage') @Default('') String notesLanguage,
    @JsonKey(name: 'sampleCollectedAt') @Default('') String sampleCollectedAt,
    @JsonKey(name: 'sampleReceivedAt') @Default('') String sampleReceivedAt,
    @JsonKey(name: 'labAccessionNo') @Default('') String labAccessionNo,
    @JsonKey(name: 'requiresSlides') @Default(false) bool requiresSlides,
    @JsonKey(name: 'slideUploadUids')
    @Default(<String>[])
    List<String> slideUploadUids,
    @JsonKey(name: 'slideImages')
    @Default(<SlideImageModel>[])
    List<SlideImageModel> slideImages,
    @JsonKey(name: 'prereadRunUid') @Default('') String prereadRunUid,
    @JsonKey(name: 'currentReportUid') @Default('') String currentReportUid,
    @JsonKey(name: 'resultState') @Default('Pending') String resultState,
    @JsonKey(name: 'discussionAppointmentUid')
    @Default('')
    String discussionAppointmentUid,
    @JsonKey(name: 'currentLocation') @Default('Doctor') String currentLocation,
    @JsonKey(name: 'currentStage') @Default('OrderCreated') String currentStage,
    @JsonKey(name: 'currentStep') @Default('') String currentStep,
    @JsonKey(name: 'stageSeq') @Default(0) int stageSeq,
    @JsonKey(name: 'stageEnteredAt') @Default('') String stageEnteredAt,
    @JsonKey(name: 'releasedToPatient') @Default(false) bool releasedToPatient,
    @JsonKey(name: 'discussedAt') @Default('') String discussedAt,
    @JsonKey(name: 'releasedAt') @Default('') String releasedAt,
    @JsonKey(name: 'cancelReason') @Default('') String cancelReason,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _CaseModel;

  const CaseModel._();

  factory CaseModel.fromJson(Map<String, dynamic> json) =>
      _$CaseModelFromJson(json);

  factory CaseModel.empty() => const CaseModel();

  Sex? get patientSexValue => Sex.fromValue(patientSex);

  Urgency get priorityValue => Urgency.fromValue(priority);

  ResultState get resultStateValue => ResultState.fromValue(resultState);

  CaseLocation get currentLocationValue =>
      CaseLocation.fromValue(currentLocation);

  CaseStage get currentStageValue => CaseStage.fromValue(currentStage);

  CaseStep get currentStepValue => CaseStep.fromValue(currentStep);

  CancelReason get cancelReasonValue => CancelReason.fromValue(cancelReason);

  /// True when [uid] is in the server-maintained participant list.
  bool isParticipant(String uid) =>
      uid.isNotEmpty && participantUids.contains(uid);

  /// True when [uid] is the accepted pathologist (not a requested one).
  bool isPathologistOf(String uid) => uid.isNotEmpty && uid == pathologistUid;

  /// True when [uid] is the doctor or the accepted pathologist.
  bool canSeeFullLog(String uid) =>
      uid.isNotEmpty && (uid == doctorUid || uid == pathologistUid);

  /// The stage a patient sees: requests read as order-created, lab work and
  /// reporting as pathologist-accepted, the rest as themselves.
  CaseStage get patientStage => switch (currentStageValue) {
    .pathologistRequested || .pathologistRejected => .orderCreated,
    .sampleReceived ||
    .slidesUploaded ||
    .prereadQueued ||
    .prereadReady ||
    .prereadFailed ||
    .reportInProgress => .pathologistAccepted,
    final stage => stage,
  };

  /// Where the case is on the doctor's five steps (seen, ordered,
  /// pathologist, signed, discussed): the index of the current step, or 5
  /// once all are done. A cancelled case reads as ordered; lists show it
  /// as done ([isDone]).
  int get doctorStep => switch (currentStageValue) {
    .orderCreated || .pathologistRejected => 1,
    // Asked a pathologist: the case is with them, even before they accept.
    .pathologistRequested ||
    .pathologistAccepted ||
    .sampleReceived ||
    .slidesUploaded ||
    .prereadQueued ||
    .prereadReady ||
    .prereadFailed ||
    .reportInProgress => 2,
    .reportSigned || .discussionRequested || .discussionBooked => 3,
    .resultReleased || .completed => 5,
    .cancelled => 1,
  };

  /// Taken by a pathologist who has not yet recorded the sample's lab
  /// accession number, which the server needs before a report can start.
  bool get awaitsSample =>
      pathologistUid.isNotEmpty &&
      labAccessionNo.isEmpty &&
      currentReportUid.isEmpty &&
      switch (currentStageValue) {
        .pathologistAccepted ||
        .slidesUploaded ||
        .prereadQueued ||
        .prereadReady ||
        .prereadFailed => true,
        _ => false,
      };

  /// Signed and waiting for the doctor to discuss it with the patient.
  bool get needsDoctor =>
      resultStateValue == .withDoctor || resultStateValue == .updateWithDoctor;

  /// Discussed, completed or cancelled: nothing left for the doctor.
  bool get isDone =>
      currentStageValue == .resultReleased ||
      currentStageValue == .completed ||
      currentStageValue == .cancelled;
}
