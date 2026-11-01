import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

part 'public_alert_hive.g.dart';

/// Cached [PublicAlertModel], in the same field order.
@HiveType(typeId: 46)
class PublicAlertHive {
  PublicAlertHive({
    required this.uid,
    required this.diseaseId,
    required this.diseaseNameEn,
    required this.diseaseNameSw,
    required this.countyId,
    required this.countyName,
    required this.clinicianCountyIds,
    required this.epiWeek,
    required this.category,
    required this.patientText,
    required this.patientGuidance,
    required this.sources,
    required this.issuedAt,
    required this.patientsReleased,
    required this.patientsReleasedAt,
    required this.synthetic,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory PublicAlertHive.fromModel(PublicAlertModel model) {
    return PublicAlertHive(
      uid: model.uid,
      diseaseId: model.diseaseId,
      diseaseNameEn: model.diseaseNameEn,
      diseaseNameSw: model.diseaseNameSw,
      countyId: model.countyId,
      countyName: model.countyName,
      clinicianCountyIds: List<int>.from(model.clinicianCountyIds),
      epiWeek: model.epiWeek,
      category: model.category,
      patientText: {
        for (final e in model.patientText.entries)
          e.key: AlertTextHive.fromModel(e.value),
      },
      patientGuidance: [
        for (final b in model.patientGuidance) GuidanceBulletHive.fromModel(b),
      ],
      sources: [for (final s in model.sources) GuidanceSourceHive.fromModel(s)],
      issuedAt: model.issuedAt,
      patientsReleased: model.patientsReleased,
      patientsReleasedAt: model.patientsReleasedAt,
      synthetic: model.synthetic,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  PublicAlertModel toModel() {
    return PublicAlertModel(
      uid: uid,
      diseaseId: diseaseId,
      diseaseNameEn: diseaseNameEn,
      diseaseNameSw: diseaseNameSw,
      countyId: countyId,
      countyName: countyName,
      clinicianCountyIds: List<int>.from(clinicianCountyIds),
      epiWeek: epiWeek,
      category: category,
      patientText: {
        for (final e in patientText.entries) e.key: e.value.toModel(),
      },
      patientGuidance: [for (final b in patientGuidance) b.toModel()],
      sources: [for (final s in sources) s.toModel()],
      issuedAt: issuedAt,
      patientsReleased: patientsReleased,
      patientsReleasedAt: patientsReleasedAt,
      synthetic: synthetic,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String diseaseId;
  @HiveField(2)
  final String diseaseNameEn;
  @HiveField(3)
  final String diseaseNameSw;
  @HiveField(4)
  final int countyId;
  @HiveField(5)
  final String countyName;
  @HiveField(6)
  final List<int> clinicianCountyIds;
  @HiveField(7)
  final String epiWeek;
  @HiveField(8)
  final String category;
  @HiveField(9)
  final Map<String, AlertTextHive> patientText;
  @HiveField(10)
  final List<GuidanceBulletHive> patientGuidance;
  @HiveField(11)
  final List<GuidanceSourceHive> sources;
  @HiveField(12)
  final String issuedAt;
  @HiveField(13)
  final bool patientsReleased;
  @HiveField(14)
  final String patientsReleasedAt;
  @HiveField(15)
  final bool synthetic;
  @HiveField(16)
  final String createdAt;
  @HiveField(17)
  final String lastUpdatedAt;
  @HiveField(18)
  final bool synced;
}
