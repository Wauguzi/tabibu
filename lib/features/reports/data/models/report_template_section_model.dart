import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_template_question_model.dart';

part 'report_template_section_model.freezed.dart';
part 'report_template_section_model.g.dart';

/// One section in a bundled report template.
@freezed
abstract class ReportTemplateSectionModel with _$ReportTemplateSectionModel {
  // Nested questions must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ReportTemplateSectionModel({
    @JsonKey(name: 'sectionKey') @Default('') String sectionKey,
    @JsonKey(name: 'order') @Default(0) int order,
    @JsonKey(name: 'questions')
    @Default(<ReportTemplateQuestionModel>[])
    List<ReportTemplateQuestionModel> questions,
  }) = _ReportTemplateSectionModel;

  const ReportTemplateSectionModel._();

  factory ReportTemplateSectionModel.fromJson(Map<String, dynamic> json) =>
      _$ReportTemplateSectionModelFromJson(json);

  factory ReportTemplateSectionModel.empty() =>
      const ReportTemplateSectionModel();

  ReportSection get sectionKeyValue => ReportSection.fromValue(sectionKey);
}
