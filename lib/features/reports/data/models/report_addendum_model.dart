import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_addendum_model.freezed.dart';
part 'report_addendum_model.g.dart';

/// A signed addendum attached to a pathology report.
@freezed
abstract class ReportAddendumModel with _$ReportAddendumModel {
  const factory ReportAddendumModel({
    @JsonKey(name: 'uid') @Default('') String uid,
    @JsonKey(name: 'text') @Default('') String text,
    @JsonKey(name: 'reportVersion') @Default(0) int reportVersion,
    @JsonKey(name: 'signedByUid') @Default('') String signedByUid,
    @JsonKey(name: 'signedByName') @Default('') String signedByName,
    @JsonKey(name: 'signedAt') @Default('') String signedAt,
  }) = _ReportAddendumModel;

  const ReportAddendumModel._();

  factory ReportAddendumModel.fromJson(Map<String, dynamic> json) =>
      _$ReportAddendumModelFromJson(json);

  factory ReportAddendumModel.empty() => const ReportAddendumModel();
}
