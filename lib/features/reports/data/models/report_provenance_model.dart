import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_field_diff_model.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_model.dart';

part 'report_provenance_model.freezed.dart';
part 'report_provenance_model.g.dart';

/// Untouched AI draft, diff and edit rate for audit (S-1). Never cached.
@freezed
abstract class ReportProvenanceModel with _$ReportProvenanceModel {
  // Nested lists must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ReportProvenanceModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'caseUid') @Default('') String caseUid,
    @JsonKey(name: 'reportUid') @Default('') String reportUid,
    @JsonKey(name: 'pathologistUid') @Default('') String pathologistUid,
    @JsonKey(name: 'prereadRunUid') @Default('') String prereadRunUid,
    @JsonKey(name: 'diffBase') @Default('None') String diffBase,
    @JsonKey(name: 'aiDraft')
    @Default(<String, dynamic>{})
    Map<String, dynamic> aiDraft,
    @JsonKey(name: 'aiModels')
    @Default(<String, String>{})
    Map<String, String> aiModels,
    @JsonKey(name: 'aiMeasurements')
    @Default(<ReportMeasurementModel>[])
    List<ReportMeasurementModel> aiMeasurements,
    @JsonKey(name: 'finalMeasurements')
    @Default(<ReportMeasurementModel>[])
    List<ReportMeasurementModel> finalMeasurements,
    @JsonKey(name: 'labelOverrideCount') @Default(0) int labelOverrideCount,
    @JsonKey(name: 'diff')
    @Default(<ReportFieldDiffModel>[])
    List<ReportFieldDiffModel> diff,
    @JsonKey(name: 'editRate') @Default(0) double editRate,
    @JsonKey(name: 'acceptedUnchanged') @Default(false) bool acceptedUnchanged,
    @JsonKey(name: 'hintShownDiseaseIds')
    @Default(<String>[])
    List<String> hintShownDiseaseIds,
    @JsonKey(name: 'createdAt') @Default('') String createdAt,
    @JsonKey(name: 'lastUpdatedAt') @Default('') String lastUpdatedAt,
  }) = _ReportProvenanceModel;

  const ReportProvenanceModel._();

  factory ReportProvenanceModel.fromJson(Map<String, dynamic> json) =>
      _$ReportProvenanceModelFromJson(json);

  factory ReportProvenanceModel.empty() => const ReportProvenanceModel();

  DiffBase get diffBaseValue => DiffBase.fromValue(diffBase);

  /// True when [editRate] is zero against the AI draft.
  bool get computesAcceptedUnchanged => editRate == 0;
}
