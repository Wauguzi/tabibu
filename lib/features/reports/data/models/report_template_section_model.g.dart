// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_template_section_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportTemplateSectionModel _$ReportTemplateSectionModelFromJson(
  Map<String, dynamic> json,
) => _ReportTemplateSectionModel(
  sectionKey: json['sectionKey'] as String? ?? '',
  order: (json['order'] as num?)?.toInt() ?? 0,
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map(
            (e) =>
                ReportTemplateQuestionModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <ReportTemplateQuestionModel>[],
);

Map<String, dynamic> _$ReportTemplateSectionModelToJson(
  _ReportTemplateSectionModel instance,
) => <String, dynamic>{
  'sectionKey': instance.sectionKey,
  'order': instance.order,
  'questions': instance.questions.map((e) => e.toJson()).toList(),
};
