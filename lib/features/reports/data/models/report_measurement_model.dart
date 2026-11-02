import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_measurement_model.freezed.dart';
part 'report_measurement_model.g.dart';

/// A numeric measurement on a report, always computed in code (S-6).
@freezed
abstract class ReportMeasurementModel with _$ReportMeasurementModel {
  const factory ReportMeasurementModel({
    @JsonKey(name: 'key') @Default('') String key,
    @JsonKey(name: 'unit') @Default('') String unit,
    @JsonKey(name: 'value') @Default(0) double value,
    @JsonKey(name: 'precision') @Default(0) int precision,
  }) = _ReportMeasurementModel;

  const ReportMeasurementModel._();

  factory ReportMeasurementModel.fromJson(Map<String, dynamic> json) =>
      _$ReportMeasurementModelFromJson(json);

  factory ReportMeasurementModel.empty() => const ReportMeasurementModel();

  /// Formats [value] to [precision] decimal places with [unit].
  String get formatted {
    final number = value.toStringAsFixed(precision);
    if (unit.isEmpty) return number;
    return '$number $unit';
  }
}
