import 'package:freezed_annotation/freezed_annotation.dart';

part 'preread_label_model.freezed.dart';
part 'preread_label_model.g.dart';

/// A label parsed from Storage `labels.json`. Never cached (S-1).
@freezed
abstract class PrereadLabelModel with _$PrereadLabelModel {
  const factory PrereadLabelModel({
    @JsonKey(name: 'id') @Default('') String id,
    @JsonKey(name: 'imageUid') @Default('') String imageUid,
    @JsonKey(name: 'label') @Default('') String label,
    @JsonKey(name: 'probability') @Default(0) double probability,
  }) = _PrereadLabelModel;

  const PrereadLabelModel._();

  factory PrereadLabelModel.fromJson(Map<String, dynamic> json) =>
      _$PrereadLabelModelFromJson(json);

  factory PrereadLabelModel.empty() => const PrereadLabelModel();
}
