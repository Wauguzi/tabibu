import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'case_summary_model.freezed.dart';
part 'case_summary_model.g.dart';

/// A conversation's `caseSummary`: the case at a glance, without the result.
@freezed
abstract class CaseSummaryModel with _$CaseSummaryModel {
  const factory CaseSummaryModel({
    @JsonKey(name: 'caseRef') @Default('') String caseRef,
    @JsonKey(name: 'ageBand') @Default('') String ageBand,
    @JsonKey(name: 'sex') @Default('') String sex,
    @JsonKey(name: 'testTypeNames')
    @Default(<String>[])
    List<String> testTypeNames,
    @JsonKey(name: 'testNames') @Default(<String>[]) List<String> testNames,
    @JsonKey(name: 'reportStatus') @Default('Pending') String reportStatus,
    @JsonKey(name: 'signedDiagnosisExcerpt')
    @Default('')
    String signedDiagnosisExcerpt,
    @JsonKey(name: 'signedAt') @Default('') String signedAt,
    @JsonKey(name: 'signedByName') @Default('') String signedByName,
    @JsonKey(name: 'reportLanguage') @Default('') String reportLanguage,
    @JsonKey(name: 'builtAt') @Default('') String builtAt,
  }) = _CaseSummaryModel;

  const CaseSummaryModel._();

  factory CaseSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$CaseSummaryModelFromJson(json);

  factory CaseSummaryModel.empty() => const CaseSummaryModel();

  Sex? get sexValue => Sex.fromValue(sex);

  SummaryReportStatus get reportStatusValue =>
      SummaryReportStatus.fromValue(reportStatus);

  ReportLanguage get reportLanguageValue =>
      ReportLanguage.fromValue(reportLanguage);
}
