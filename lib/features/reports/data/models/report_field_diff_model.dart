import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'report_field_diff_model.freezed.dart';
part 'report_field_diff_model.g.dart';

/// One field change between an AI draft and the signed report.
@freezed
abstract class ReportFieldDiffModel with _$ReportFieldDiffModel {
  const factory ReportFieldDiffModel({
    @JsonKey(name: 'field') @Default('') String field,
    @JsonKey(name: 'change') @Default('') String change,
    @JsonKey(name: 'baseValue') @Default('') String baseValue,
    @JsonKey(name: 'finalValue') @Default('') String finalValue,
    @JsonKey(name: 'similarity') @Default(0) double similarity,
  }) = _ReportFieldDiffModel;

  const ReportFieldDiffModel._();

  factory ReportFieldDiffModel.fromJson(Map<String, dynamic> json) =>
      _$ReportFieldDiffModelFromJson(json);

  factory ReportFieldDiffModel.empty() => const ReportFieldDiffModel();

  FieldChange get changeValue => FieldChange.fromValue(change);
}
