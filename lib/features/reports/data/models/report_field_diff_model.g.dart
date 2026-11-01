// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_field_diff_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportFieldDiffModel _$ReportFieldDiffModelFromJson(
  Map<String, dynamic> json,
) => _ReportFieldDiffModel(
  field: json['field'] as String? ?? '',
  change: json['change'] as String? ?? '',
  baseValue: json['baseValue'] as String? ?? '',
  finalValue: json['finalValue'] as String? ?? '',
  similarity: (json['similarity'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$ReportFieldDiffModelToJson(
  _ReportFieldDiffModel instance,
) => <String, dynamic>{
  'field': instance.field,
  'change': instance.change,
  'baseValue': instance.baseValue,
  'finalValue': instance.finalValue,
  'similarity': instance.similarity,
};
