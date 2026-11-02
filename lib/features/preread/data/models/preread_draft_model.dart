import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/preread/data/models/preread_finding_model.dart';

part 'preread_draft_model.freezed.dart';
part 'preread_draft_model.g.dart';

/// Nested AI draft on a pre-read run. Never cached (S-1).
@freezed
abstract class PrereadDraftModel with _$PrereadDraftModel {
  // Nested lists must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PrereadDraftModel({
    @JsonKey(name: 'findings')
    @Default(<PrereadFindingModel>[])
    List<PrereadFindingModel> findings,
    @JsonKey(name: 'impression') @Default('') String impression,
    @JsonKey(name: 'confidence') @Default(0) double confidence,
    @JsonKey(name: 'confidenceBand') @Default('') String confidenceBand,
    @JsonKey(name: 'urgency') @Default('') String urgency,
    @JsonKey(name: 'nextSteps') @Default(<String>[]) List<String> nextSteps,
  }) = _PrereadDraftModel;

  const PrereadDraftModel._();

  factory PrereadDraftModel.fromJson(Map<String, dynamic> json) =>
      _$PrereadDraftModelFromJson(json);

  factory PrereadDraftModel.empty() => const PrereadDraftModel();

  ConfidenceBand get confidenceBandValue =>
      ConfidenceBand.fromValue(confidenceBand);

  Urgency get urgencyValue => Urgency.fromValue(urgency);
}
