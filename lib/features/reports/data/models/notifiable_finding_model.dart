import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifiable_finding_model.freezed.dart';
part 'notifiable_finding_model.g.dart';

/// A confirmed notifiable disease finding on a signed report.
@freezed
abstract class NotifiableFindingModel with _$NotifiableFindingModel {
  const factory NotifiableFindingModel({
    @JsonKey(name: 'diseaseId') @Default('') String diseaseId,
    @JsonKey(name: 'alertRequested') @Default(false) bool alertRequested,
  }) = _NotifiableFindingModel;

  const NotifiableFindingModel._();

  factory NotifiableFindingModel.fromJson(Map<String, dynamic> json) =>
      _$NotifiableFindingModelFromJson(json);

  factory NotifiableFindingModel.empty() => const NotifiableFindingModel();
}
