import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'report_text_approved_model.freezed.dart';
part 'report_text_approved_model.g.dart';

/// Reader-facing approved report text. Never carries machine text (F-1).
@freezed
abstract class ReportTextApprovedModel with _$ReportTextApprovedModel {
  const factory ReportTextApprovedModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'reportUid') @Default('') String reportUid,
    @JsonKey(name: 'reportVersion') @Default(0) int reportVersion,
    @JsonKey(name: 'kind') @Default('') String kind,
    @JsonKey(name: 'language') @Default('') String language,
    @JsonKey(name: 'sourceLanguage') @Default('') String sourceLanguage,
    @JsonKey(name: 'sourceSha256') @Default('') String sourceSha256,
    @JsonKey(name: 'approvedText')
    @Default(<String, String>{})
    Map<String, String> approvedText,
    @JsonKey(name: 'approverUid') @Default('') String approverUid,
    @JsonKey(name: 'approverName') @Default('') String approverName,
    @JsonKey(name: 'approvedAt') @Default('') String approvedAt,
    @JsonKey(name: 'acceptedUnchanged') @Default(false) bool acceptedUnchanged,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _ReportTextApprovedModel;

  const ReportTextApprovedModel._();

  factory ReportTextApprovedModel.fromJson(Map<String, dynamic> json) =>
      _$ReportTextApprovedModelFromJson(json);

  factory ReportTextApprovedModel.empty() => const ReportTextApprovedModel();

  ReportTextKind get kindValue => ReportTextKind.fromValue(kind);

  ReportLanguage get languageValue => ReportLanguage.fromValue(language);

  ReportLanguage get sourceLanguageValue =>
      ReportLanguage.fromValue(sourceLanguage);
}
