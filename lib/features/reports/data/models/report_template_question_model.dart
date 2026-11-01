import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_template_question_model.freezed.dart';
part 'report_template_question_model.g.dart';

/// One question in a bundled report template section.
@freezed
abstract class ReportTemplateQuestionModel with _$ReportTemplateQuestionModel {
  const factory ReportTemplateQuestionModel({
    @JsonKey(name: 'questionKey') @Default('') String questionKey,
    @JsonKey(name: 'order') @Default(0) int order,
    @JsonKey(name: 'required') @Default(false) bool required,
  }) = _ReportTemplateQuestionModel;

  const ReportTemplateQuestionModel._();

  factory ReportTemplateQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$ReportTemplateQuestionModelFromJson(json);

  factory ReportTemplateQuestionModel.empty() =>
      const ReportTemplateQuestionModel();
}
