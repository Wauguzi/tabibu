import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'report_response_model.freezed.dart';
part 'report_response_model.g.dart';

/// One answered template question on a report or draft.
@freezed
abstract class ReportResponseModel with _$ReportResponseModel {
  const factory ReportResponseModel({
    @JsonKey(name: 'section') @Default('') String section,
    @JsonKey(name: 'question') @Default('') String question,
    @JsonKey(name: 'answer') @Default('') String answer,
    @JsonKey(name: 'order') @Default(0) int order,
  }) = _ReportResponseModel;

  const ReportResponseModel._();

  factory ReportResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseModelFromJson(json);

  factory ReportResponseModel.empty() => const ReportResponseModel();

  ReportSection get sectionValue => ReportSection.fromValue(section);
}
