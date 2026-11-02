import 'package:freezed_annotation/freezed_annotation.dart';

part 'guidance_source_model.freezed.dart';
part 'guidance_source_model.g.dart';

/// A cited source for guidance bullets (alerts + reference bundle).
@freezed
abstract class GuidanceSourceModel with _$GuidanceSourceModel {
  const factory GuidanceSourceModel({
    @JsonKey(name: 'sourceId') @Default('') String sourceId,
    @JsonKey(name: 'title') @Default('') String title,
    @JsonKey(name: 'publisher') @Default('') String publisher,
    @JsonKey(name: 'url') @Default('') String url,
    @JsonKey(name: 'publishedOn') @Default('') String publishedOn,
    @JsonKey(name: 'accessedOn') @Default('') String accessedOn,
  }) = _GuidanceSourceModel;

  const GuidanceSourceModel._();

  factory GuidanceSourceModel.fromJson(Map<String, dynamic> json) =>
      _$GuidanceSourceModelFromJson(json);

  factory GuidanceSourceModel.empty() => const GuidanceSourceModel();
}
