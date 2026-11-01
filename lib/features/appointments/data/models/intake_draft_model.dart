import 'package:freezed_annotation/freezed_annotation.dart';

part 'intake_draft_model.freezed.dart';
part 'intake_draft_model.g.dart';

/// One language's AI intake draft nested under an appointment intake.
@freezed
abstract class IntakeDraftModel with _$IntakeDraftModel {
  const factory IntakeDraftModel({
    @JsonKey(name: 'chiefComplaint') @Default('') String chiefComplaint,
    @JsonKey(name: 'symptoms') @Default(<String>[]) List<String> symptoms,
    @JsonKey(name: 'duration') @Default('') String duration,
    @JsonKey(name: 'redFlags') @Default(<String>[]) List<String> redFlags,
    @JsonKey(name: 'summary') @Default('') String summary,
    @JsonKey(name: 'isTranslation') @Default(false) bool isTranslation,
  }) = _IntakeDraftModel;

  const IntakeDraftModel._();

  factory IntakeDraftModel.fromJson(Map<String, dynamic> json) =>
      _$IntakeDraftModelFromJson(json);

  factory IntakeDraftModel.empty() => const IntakeDraftModel();
}
