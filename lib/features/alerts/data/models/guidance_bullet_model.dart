import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'guidance_bullet_model.freezed.dart';
part 'guidance_bullet_model.g.dart';

/// One public-health guidance bullet (alerts + reference bundle).
@freezed
abstract class GuidanceBulletModel with _$GuidanceBulletModel {
  const factory GuidanceBulletModel({
    @JsonKey(name: 'bulletId') @Default('') String bulletId,
    @JsonKey(name: 'audience') @Default('Patient') String audience,
    @JsonKey(name: 'textEn') @Default('') String textEn,
    @JsonKey(name: 'textSw') @Default('') String textSw,
    @JsonKey(name: 'swIsOfficial') @Default(false) bool swIsOfficial,
    @JsonKey(name: 'sourceId') @Default('') String sourceId,
  }) = _GuidanceBulletModel;

  const GuidanceBulletModel._();

  factory GuidanceBulletModel.fromJson(Map<String, dynamic> json) =>
      _$GuidanceBulletModelFromJson(json);

  factory GuidanceBulletModel.empty() => const GuidanceBulletModel();

  GuidanceAudience get audienceValue => GuidanceAudience.fromValue(audience);
}
