import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/features/reports/data/models/report_template_section_model.dart';

part 'report_template_model.freezed.dart';
part 'report_template_model.g.dart';

/// One row of the bundled `report_templates.json` register.
@freezed
abstract class ReportTemplateModel with _$ReportTemplateModel {
  // Nested sections must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ReportTemplateModel({
    @JsonKey(name: 'templateKey') @Default('') String templateKey,
    @JsonKey(name: 'testTypeIds') @Default(<String>[]) List<String> testTypeIds,
    @JsonKey(name: 'sections')
    @Default(<ReportTemplateSectionModel>[])
    List<ReportTemplateSectionModel> sections,
  }) = _ReportTemplateModel;

  const ReportTemplateModel._();

  factory ReportTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$ReportTemplateModelFromJson(json);

  factory ReportTemplateModel.empty() => const ReportTemplateModel();
}
