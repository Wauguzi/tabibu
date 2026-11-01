import 'package:freezed_annotation/freezed_annotation.dart';

part 'insurer_model.freezed.dart';
part 'insurer_model.g.dart';

/// One insurer: a public scheme, a private insurer, or another payer.
@freezed
abstract class InsurerModel with _$InsurerModel {
  const factory InsurerModel({
    @JsonKey(name: 'insurerId') required String insurerId,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'type') required String type,
  }) = _InsurerModel;

  factory InsurerModel.empty() =>
      const InsurerModel(insurerId: '', name: '', type: '');

  factory InsurerModel.fromJson(Map<String, dynamic> json) =>
      _$InsurerModelFromJson(json);
}
