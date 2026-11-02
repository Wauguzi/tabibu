// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportResponseModel _$ReportResponseModelFromJson(Map<String, dynamic> json) =>
    _ReportResponseModel(
      section: json['section'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReportResponseModelToJson(
  _ReportResponseModel instance,
) => <String, dynamic>{
  'section': instance.section,
  'question': instance.question,
  'answer': instance.answer,
  'order': instance.order,
};
