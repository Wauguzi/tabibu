import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_model.dart';

part 'guidance_bullet_hive.g.dart';

/// Cached [GuidanceBulletModel], in the same field order.
@HiveType(typeId: 48)
class GuidanceBulletHive {
  GuidanceBulletHive({
    required this.bulletId,
    required this.audience,
    required this.textEn,
    required this.textSw,
    required this.swIsOfficial,
    required this.sourceId,
  });

  factory GuidanceBulletHive.fromModel(GuidanceBulletModel model) {
    return GuidanceBulletHive(
      bulletId: model.bulletId,
      audience: model.audience,
      textEn: model.textEn,
      textSw: model.textSw,
      swIsOfficial: model.swIsOfficial,
      sourceId: model.sourceId,
    );
  }

  GuidanceBulletModel toModel() {
    return GuidanceBulletModel(
      bulletId: bulletId,
      audience: audience,
      textEn: textEn,
      textSw: textSw,
      swIsOfficial: swIsOfficial,
      sourceId: sourceId,
    );
  }

  @HiveField(0)
  final String bulletId;
  @HiveField(1)
  final String audience;
  @HiveField(2)
  final String textEn;
  @HiveField(3)
  final String textSw;
  @HiveField(4)
  final bool swIsOfficial;
  @HiveField(5)
  final String sourceId;
}
