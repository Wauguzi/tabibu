// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_template_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportTemplateQuestionModel _$ReportTemplateQuestionModelFromJson(
  Map<String, dynamic> json,
) => _ReportTemplateQuestionModel(
  questionKey: json['questionKey'] as String? ?? '',
  order: (json['order'] as num?)?.toInt() ?? 0,
  required: json['required'] as bool? ?? false,
);

Map<String, dynamic> _$ReportTemplateQuestionModelToJson(
  _ReportTemplateQuestionModel instance,
) => <String, dynamic>{
  'questionKey': instance.questionKey,
  'order': instance.order,
  'required': instance.required,
};
