import 'package:freezed_annotation/freezed_annotation.dart';

part 'preread_finding_model.freezed.dart';
part 'preread_finding_model.g.dart';

/// One finding in an AI pre-read draft.
@freezed
abstract class PrereadFindingModel with _$PrereadFindingModel {
  const factory PrereadFindingModel({
    @JsonKey(name: 'text') @Default('') String text,
    @JsonKey(name: 'evidenceIds') @Default(<String>[]) List<String> evidenceIds,
  }) = _PrereadFindingModel;

  const PrereadFindingModel._();

  factory PrereadFindingModel.fromJson(Map<String, dynamic> json) =>
      _$PrereadFindingModelFromJson(json);

  factory PrereadFindingModel.empty() => const PrereadFindingModel();
}
