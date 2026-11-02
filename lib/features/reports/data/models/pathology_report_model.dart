import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_model.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';

part 'pathology_report_model.freezed.dart';
part 'pathology_report_model.g.dart';

/// A signed `reports/{v}` version. Reader-facing; never carries machine text.
@freezed
abstract class PathologyReportModel with _$PathologyReportModel {
  // Nested lists must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PathologyReportModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'version') @Default(0) int version,
    @JsonKey(name: 'stage') @Default('Initial') String stage,
    @JsonKey(name: 'status') @Default('Signed') String status,
    @JsonKey(name: 'orderNumber') @Default('') String orderNumber,
    @JsonKey(name: 'testName') @Default('') String testName,
    @JsonKey(name: 'sampleCollectedAt') @Default('') String sampleCollectedAt,
    @JsonKey(name: 'sampleReceivedAt') @Default('') String sampleReceivedAt,
    @JsonKey(name: 'labAccessionNo') @Default('') String labAccessionNo,
    @JsonKey(name: 'profile') @Default('None') String profile,
    @JsonKey(name: 'templateKey') @Default('General') String templateKey,
    @JsonKey(name: 'title') @Default('') String title,
    @JsonKey(name: 'diagnosisType') @Default('Final') String diagnosisType,
    @JsonKey(name: 'diagnosis') @Default('') String diagnosis,
    @JsonKey(name: 'comments') @Default('') String comments,
    @JsonKey(name: 'responses')
    @Default(<ReportResponseModel>[])
    List<ReportResponseModel> responses,
    @JsonKey(name: 'isCritical') @Default(false) bool isCritical,
    @JsonKey(name: 'measurements')
    @Default(<ReportMeasurementModel>[])
    List<ReportMeasurementModel> measurements,
    @JsonKey(name: 'addenda')
    @Default(<ReportAddendumModel>[])
    List<ReportAddendumModel> addenda,
    @JsonKey(name: 'amendmentReason') @Default('') String amendmentReason,
    @JsonKey(name: 'prereadRunUid') @Default('') String prereadRunUid,
    @JsonKey(name: 'doctorUid') @Default('') String doctorUid,
    @JsonKey(name: 'pathologistUid') @Default('') String pathologistUid,
    @JsonKey(name: 'readerUids') @Default(<String>[]) List<String> readerUids,
    @JsonKey(name: 'signedByTitle') @Default('') String signedByTitle,
    @JsonKey(name: 'signedByName') @Default('') String signedByName,
    @JsonKey(name: 'signedByKmpdcNumber')
    @Default('')
    String signedByKmpdcNumber,
    @JsonKey(name: 'signedByFacilityName')
    @Default('')
    String signedByFacilityName,
    @JsonKey(name: 'signaturePath') @Default('') String signaturePath,
    @JsonKey(name: 'signatureSha256') @Default('') String signatureSha256,
    @JsonKey(name: 'contentSha256') @Default('') String contentSha256,
    @JsonKey(name: 'startedAt') @Default('') String startedAt,
    @JsonKey(name: 'scoredAt') @Default('') String scoredAt,
    @JsonKey(name: 'signedAt') @Default('') String signedAt,
    @JsonKey(name: 'doctorOpenedAt') @Default('') String doctorOpenedAt,
    @JsonKey(name: 'releasedToPatient') @Default(false) bool releasedToPatient,
    @JsonKey(name: 'releasedAt') @Default('') String releasedAt,
    @JsonKey(name: 'releasedByUid') @Default('') String releasedByUid,
    @JsonKey(name: 'supersededAt') @Default('') String supersededAt,
    @JsonKey(name: 'supersededByUid') @Default('') String supersededByUid,
    @JsonKey(name: 'notifiableFindings')
    @Default(<NotifiableFindingModel>[])
    List<NotifiableFindingModel> notifiableFindings,
    @JsonKey(name: 'confirmatoryRequests')
    @Default(<String>[])
    List<String> confirmatoryRequests,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'language') @Default('en') String language,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _PathologyReportModel;

  const PathologyReportModel._();

  factory PathologyReportModel.fromJson(Map<String, dynamic> json) =>
      _$PathologyReportModelFromJson(json);

  factory PathologyReportModel.empty() => const PathologyReportModel();

  ReportStage get stageValue => ReportStage.fromValue(stage);

  ReportStatus get statusValue => ReportStatus.fromValue(status);

  PrereadProfile get profileValue => PrereadProfile.fromValue(profile);

  ReportTemplate get templateKeyValue => ReportTemplate.fromValue(templateKey);

  DiagnosisType get diagnosisTypeValue =>
      DiagnosisType.fromValue(diagnosisType);

  ReportLanguage get languageValue => ReportLanguage.fromValue(language);

  /// True when this version is the current signed one.
  bool get isCurrent => statusValue == ReportStatus.signed;

  /// True when a patient may see this version.
  bool get isReleasedToPatient => releasedToPatient;

  /// True when [uid] is in [readerUids].
  bool isReader(String uid) => readerUids.contains(uid);
}
