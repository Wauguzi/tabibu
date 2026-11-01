// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportTemplateModel _$ReportTemplateModelFromJson(Map<String, dynamic> json) =>
    _ReportTemplateModel(
      templateKey: json['templateKey'] as String? ?? '',
      testTypeIds:
          (json['testTypeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map(
                (e) => ReportTemplateSectionModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <ReportTemplateSectionModel>[],
    );

Map<String, dynamic> _$ReportTemplateModelToJson(
  _ReportTemplateModel instance,
) => <String, dynamic>{
  'templateKey': instance.templateKey,
  'testTypeIds': instance.testTypeIds,
  'sections': instance.sections.map((e) => e.toJson()).toList(),
};
