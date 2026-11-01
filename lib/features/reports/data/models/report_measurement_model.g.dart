// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_measurement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportMeasurementModel _$ReportMeasurementModelFromJson(
  Map<String, dynamic> json,
) => _ReportMeasurementModel(
  key: json['key'] as String? ?? '',
  unit: json['unit'] as String? ?? '',
  value: (json['value'] as num?)?.toDouble() ?? 0,
  precision: (json['precision'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReportMeasurementModelToJson(
  _ReportMeasurementModel instance,
) => <String, dynamic>{
  'key': instance.key,
  'unit': instance.unit,
  'value': instance.value,
  'precision': instance.precision,
};
