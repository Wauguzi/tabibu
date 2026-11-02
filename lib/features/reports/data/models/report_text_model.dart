import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'report_text_model.freezed.dart';
part 'report_text_model.g.dart';

/// Working report text with machine output. Approver-only; never cached (F-1).
@freezed
abstract class ReportTextModel with _$ReportTextModel {
  const factory ReportTextModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'reportUid') @Default('') String reportUid,
    @JsonKey(name: 'reportVersion') @Default(0) int reportVersion,
    @JsonKey(name: 'kind') @Default('Translation') String kind,
    @JsonKey(name: 'language') @Default('sw') String language,
    @JsonKey(name: 'sourceLanguage') @Default('en') String sourceLanguage,
    @JsonKey(name: 'detectedSourceLanguage')
    @Default('')
    String detectedSourceLanguage,
    @JsonKey(name: 'languageMismatch') @Default(false) bool languageMismatch,
    @JsonKey(name: 'sourceSha256') @Default('') String sourceSha256,
    @JsonKey(name: 'status') @Default('Queued') String status,
    @JsonKey(name: 'machineText')
    @Default(<String, String>{})
    Map<String, String> machineText,
    @JsonKey(name: 'models')
    @Default(<String, String>{})
    Map<String, String> models,
    @JsonKey(name: 'approverUid') @Default('') String approverUid,
    @JsonKey(name: 'requestCount') @Default(0) int requestCount,
    @JsonKey(name: 'acceptedUnchanged') @Default(false) bool acceptedUnchanged,
    @JsonKey(name: 'editedSegmentKeys')
    @Default(<String>[])
    List<String> editedSegmentKeys,
    @JsonKey(name: 'editDistance') @Default(0) double editDistance,
    @JsonKey(name: 'failureReason') @Default('') String failureReason,
    @JsonKey(name: 'requestedAt') @Default('') String requestedAt,
    @JsonKey(name: 'readyAt') @Default('') String readyAt,
    @JsonKey(name: 'approvedAt') @Default('') String approvedAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
  }) = _ReportTextModel;

  const ReportTextModel._();

  factory ReportTextModel.fromJson(Map<String, dynamic> json) =>
      _$ReportTextModelFromJson(json);

  factory ReportTextModel.empty() => const ReportTextModel();

  ReportTextKind get kindValue => ReportTextKind.fromValue(kind);

  ReportLanguage get languageValue => ReportLanguage.fromValue(language);

  ReportLanguage get sourceLanguageValue =>
      ReportLanguage.fromValue(sourceLanguage);

  ReportTextStatus get statusValue => ReportTextStatus.fromValue(status);

  FailureReason get failureReasonValue =>
      FailureReason.fromValue(failureReason);
}
