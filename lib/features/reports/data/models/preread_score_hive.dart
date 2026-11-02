import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';

part 'preread_score_hive.g.dart';

/// Cached [PrereadScoreModel], in the same field order.
@HiveType(typeId: 21)
class PrereadScoreHive {
  PrereadScoreHive({
    required this.uid,
    required this.caseUid,
    required this.runUid,
    required this.pathologistUid,
    required this.profile,
    required this.confidenceBand,
    required this.urgency,
    required this.overall,
    required this.findingsVerdict,
    required this.impressionVerdict,
    required this.measurementsVerdict,
    required this.segmentationVerdict,
    required this.urgencyVerdict,
    required this.comment,
    required this.prereadShownAt,
    required this.acceptedUnchanged,
    required this.scoredAt,
    required this.createdByUid,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory PrereadScoreHive.fromModel(PrereadScoreModel model) {
    return PrereadScoreHive(
      uid: model.uid,
      caseUid: model.caseUid,
      runUid: model.runUid,
      pathologistUid: model.pathologistUid,
      profile: model.profile,
      confidenceBand: model.confidenceBand,
      urgency: model.urgency,
      overall: model.overall,
      findingsVerdict: model.findingsVerdict,
      impressionVerdict: model.impressionVerdict,
      measurementsVerdict: model.measurementsVerdict,
      segmentationVerdict: model.segmentationVerdict,
      urgencyVerdict: model.urgencyVerdict,
      comment: model.comment,
      prereadShownAt: model.prereadShownAt,
      acceptedUnchanged: model.acceptedUnchanged,
      scoredAt: model.scoredAt,
      createdByUid: model.createdByUid,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  PrereadScoreModel toModel() {
    return PrereadScoreModel(
      uid: uid,
      caseUid: caseUid,
      runUid: runUid,
      pathologistUid: pathologistUid,
      profile: profile,
      confidenceBand: confidenceBand,
      urgency: urgency,
      overall: overall,
      findingsVerdict: findingsVerdict,
      impressionVerdict: impressionVerdict,
      measurementsVerdict: measurementsVerdict,
      segmentationVerdict: segmentationVerdict,
      urgencyVerdict: urgencyVerdict,
      comment: comment,
      prereadShownAt: prereadShownAt,
      acceptedUnchanged: acceptedUnchanged,
      scoredAt: scoredAt,
      createdByUid: createdByUid,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String caseUid;
  @HiveField(2)
  final String runUid;
  @HiveField(3)
  final String pathologistUid;
  @HiveField(4)
  final String profile;
  @HiveField(5)
  final String confidenceBand;
  @HiveField(6)
  final String urgency;
  @HiveField(7)
  final int overall;
  @HiveField(8)
  final String findingsVerdict;
  @HiveField(9)
  final String impressionVerdict;
  @HiveField(10)
  final String measurementsVerdict;
  @HiveField(11)
  final String segmentationVerdict;
  @HiveField(12)
  final String urgencyVerdict;
  @HiveField(13)
  final String comment;
  @HiveField(14)
  final String prereadShownAt;
  @HiveField(15)
  final bool acceptedUnchanged;
  @HiveField(16)
  final String scoredAt;
  @HiveField(17)
  final String createdByUid;
  @HiveField(18)
  final String lastUpdatedAt;
  @HiveField(19)
  final bool synced;
}
