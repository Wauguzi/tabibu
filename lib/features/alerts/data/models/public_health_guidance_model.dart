import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';

part 'public_health_guidance_model.freezed.dart';
part 'public_health_guidance_model.g.dart';

/// One row of the bundled `public_health_guidance.json` register.
@freezed
abstract class PublicHealthGuidanceModel with _$PublicHealthGuidanceModel {
  // Nested bullets/sources must call toJson(); freezed puts this on the factory.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory PublicHealthGuidanceModel({
    @JsonKey(name: 'diseaseId') @Default('') String diseaseId,
    @JsonKey(name: 'reviewedOn') @Default('') String reviewedOn,
    @JsonKey(name: 'bullets')
    @Default(<GuidanceBulletModel>[])
    List<GuidanceBulletModel> bullets,
    @JsonKey(name: 'sources')
    @Default(<GuidanceSourceModel>[])
    List<GuidanceSourceModel> sources,
  }) = _PublicHealthGuidanceModel;

  const PublicHealthGuidanceModel._();

  factory PublicHealthGuidanceModel.fromJson(Map<String, dynamic> json) =>
      _$PublicHealthGuidanceModelFromJson(json);

  factory PublicHealthGuidanceModel.empty() =>
      const PublicHealthGuidanceModel();
}
