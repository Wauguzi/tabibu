import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';

part 'report_draft_model.freezed.dart';
part 'report_draft_model.g.dart';

/// A pathologist's working `reportDrafts/{pathologistUid}` row.
@freezed
abstract class ReportDraftModel with _$ReportDraftModel {
  // Nested lists must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ReportDraftModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'pathologistUid') @Default('') String pathologistUid,
    @JsonKey(name: 'kind') @Default('Initial') String kind,
    @JsonKey(name: 'status') @Default('Editing') String status,
    @JsonKey(name: 'baseReportUid') @Default('') String baseReportUid,
    @JsonKey(name: 'targetReportUid') @Default('') String targetReportUid,
    @JsonKey(name: 'prereadRunUid') @Default('') String prereadRunUid,
    @JsonKey(name: 'templateKey') @Default('General') String templateKey,
    @JsonKey(name: 'title') @Default('') String title,
    @JsonKey(name: 'diagnosisType') @Default('Final') String diagnosisType,
    @JsonKey(name: 'diagnosis') @Default('') String diagnosis,
    @JsonKey(name: 'comments') @Default('') String comments,
    @JsonKey(name: 'responses')
    @Default(<ReportResponseModel>[])
    List<ReportResponseModel> responses,
    @JsonKey(name: 'labelOverrides')
    @Default(<String, String>{})
    Map<String, String> labelOverrides,
    @JsonKey(name: 'labelOverrideCount') @Default(0) int labelOverrideCount,
    @JsonKey(name: 'isCritical') @Default(false) bool isCritical,
    @JsonKey(name: 'addendumText') @Default('') String addendumText,
    @JsonKey(name: 'amendmentReason') @Default('') String amendmentReason,
    @JsonKey(name: 'diagnosisStartedAt') @Default('') String diagnosisStartedAt,
    @JsonKey(name: 'startedFromPreread')
    @Default(false)
    bool startedFromPreread,
    @JsonKey(name: 'startedAt') @Default('') String startedAt,
    @JsonKey(name: 'signedReportUid') @Default('') String signedReportUid,
    @JsonKey(name: 'notifiableFindings')
    @Default(<NotifiableFindingModel>[])
    List<NotifiableFindingModel> notifiableFindings,
    @JsonKey(name: 'hintShownDiseaseIds')
    @Default(<String>[])
    List<String> hintShownDiseaseIds,
    @JsonKey(name: 'confirmatoryRequests')
    @Default(<String>[])
    List<String> confirmatoryRequests,
    @JsonKey(name: 'createdByUid') @Default('') String createdByUid,
    @JsonKey(name: 'language') @Default('') String language,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _ReportDraftModel;

  const ReportDraftModel._();

  factory ReportDraftModel.fromJson(Map<String, dynamic> json) =>
      _$ReportDraftModelFromJson(json);

  factory ReportDraftModel.empty() => const ReportDraftModel();

  DraftKind get kindValue => DraftKind.fromValue(kind);

  DraftStatus get statusValue => DraftStatus.fromValue(status);

  ReportTemplate get templateKeyValue => ReportTemplate.fromValue(templateKey);

  DiagnosisType get diagnosisTypeValue =>
      DiagnosisType.fromValue(diagnosisType);

  ReportLanguage get languageValue => ReportLanguage.fromValue(language);

  /// True when [labelOverrideCount] matches [labelOverrides] size.
  bool get labelOverrideCountMatches =>
      labelOverrideCount == labelOverrides.length;
}
