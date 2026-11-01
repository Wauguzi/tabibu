import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_hive.dart';

part 'alert_clinician_brief_hive.g.dart';

/// Cached [AlertClinicianBriefModel], in the same field order.
@HiveType(typeId: 50)
class AlertClinicianBriefHive {
  AlertClinicianBriefHive({
    required this.uid,
    required this.alertUid,
    required this.countyId,
    required this.clinicianText,
    required this.clinicianGuidance,
    required this.sources,
    required this.confirmedCount,
    required this.weekStart,
    required this.rule,
    required this.categoryVerified,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory AlertClinicianBriefHive.fromModel(AlertClinicianBriefModel model) {
    return AlertClinicianBriefHive(
      uid: model.uid,
      alertUid: model.alertUid,
      countyId: model.countyId,
      clinicianText: {
        for (final e in model.clinicianText.entries)
          e.key: AlertTextHive.fromModel(e.value),
      },
      clinicianGuidance: [
        for (final b in model.clinicianGuidance)
          GuidanceBulletHive.fromModel(b),
      ],
      sources: [for (final s in model.sources) GuidanceSourceHive.fromModel(s)],
      confirmedCount: model.confirmedCount,
      weekStart: model.weekStart,
      rule: model.rule,
      categoryVerified: model.categoryVerified,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  AlertClinicianBriefModel toModel() {
    return AlertClinicianBriefModel(
      uid: uid,
      alertUid: alertUid,
      countyId: countyId,
      clinicianText: {
        for (final e in clinicianText.entries) e.key: e.value.toModel(),
      },
      clinicianGuidance: [for (final b in clinicianGuidance) b.toModel()],
      sources: [for (final s in sources) s.toModel()],
      confirmedCount: confirmedCount,
      weekStart: weekStart,
      rule: rule,
      categoryVerified: categoryVerified,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String alertUid;
  @HiveField(2)
  final int countyId;
  @HiveField(3)
  final Map<String, AlertTextHive> clinicianText;
  @HiveField(4)
  final List<GuidanceBulletHive> clinicianGuidance;
  @HiveField(5)
  final List<GuidanceSourceHive> sources;
  @HiveField(6)
  final int confirmedCount;
  @HiveField(7)
  final String weekStart;
  @HiveField(8)
  final String rule;
  @HiveField(9)
  final bool categoryVerified;
  @HiveField(10)
  final String lastUpdatedAt;
  @HiveField(11)
  final bool synced;
}
