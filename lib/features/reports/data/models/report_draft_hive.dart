import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_hive.dart';

part 'report_draft_hive.g.dart';

/// Cached [ReportDraftModel], in the same field order.
@HiveType(typeId: 20)
class ReportDraftHive {
  ReportDraftHive({
    required this.uid,
    required this.caseUid,
    required this.pathologistUid,
    required this.kind,
    required this.status,
    required this.baseReportUid,
    required this.targetReportUid,
    required this.prereadRunUid,
    required this.templateKey,
    required this.title,
    required this.diagnosisType,
    required this.diagnosis,
    required this.comments,
    required this.responses,
    required this.labelOverrides,
    required this.labelOverrideCount,
    required this.isCritical,
    required this.addendumText,
    required this.amendmentReason,
    required this.diagnosisStartedAt,
    required this.startedFromPreread,
    required this.startedAt,
    required this.signedReportUid,
    required this.notifiableFindings,
    required this.hintShownDiseaseIds,
    required this.confirmatoryRequests,
    required this.createdByUid,
    required this.language,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory ReportDraftHive.fromModel(ReportDraftModel model) {
    return ReportDraftHive(
      uid: model.uid,
      caseUid: model.caseUid,
      pathologistUid: model.pathologistUid,
      kind: model.kind,
      status: model.status,
      baseReportUid: model.baseReportUid,
      targetReportUid: model.targetReportUid,
      prereadRunUid: model.prereadRunUid,
      templateKey: model.templateKey,
      title: model.title,
      diagnosisType: model.diagnosisType,
      diagnosis: model.diagnosis,
      comments: model.comments,
      responses: model.responses.map(ReportResponseHive.fromModel).toList(),
      labelOverrides: model.labelOverrides,
      labelOverrideCount: model.labelOverrideCount,
      isCritical: model.isCritical,
      addendumText: model.addendumText,
      amendmentReason: model.amendmentReason,
      diagnosisStartedAt: model.diagnosisStartedAt,
      startedFromPreread: model.startedFromPreread,
      startedAt: model.startedAt,
      signedReportUid: model.signedReportUid,
      notifiableFindings: model.notifiableFindings
          .map(NotifiableFindingHive.fromModel)
          .toList(),
      hintShownDiseaseIds: model.hintShownDiseaseIds,
      confirmatoryRequests: model.confirmatoryRequests,
      createdByUid: model.createdByUid,
      language: model.language,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  ReportDraftModel toModel() {
    return ReportDraftModel(
      uid: uid,
      caseUid: caseUid,
      pathologistUid: pathologistUid,
      kind: kind,
      status: status,
      baseReportUid: baseReportUid,
      targetReportUid: targetReportUid,
      prereadRunUid: prereadRunUid,
      templateKey: templateKey,
      title: title,
      diagnosisType: diagnosisType,
      diagnosis: diagnosis,
      comments: comments,
      responses: responses.map((e) => e.toModel()).toList(),
      labelOverrides: labelOverrides,
      labelOverrideCount: labelOverrideCount,
      isCritical: isCritical,
      addendumText: addendumText,
      amendmentReason: amendmentReason,
      diagnosisStartedAt: diagnosisStartedAt,
      startedFromPreread: startedFromPreread,
      startedAt: startedAt,
      signedReportUid: signedReportUid,
      notifiableFindings: notifiableFindings.map((e) => e.toModel()).toList(),
      hintShownDiseaseIds: hintShownDiseaseIds,
      confirmatoryRequests: confirmatoryRequests,
      createdByUid: createdByUid,
      language: language,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String caseUid;
  @HiveField(2)
  final String pathologistUid;
  @HiveField(3)
  final String kind;
  @HiveField(4)
  final String status;
  @HiveField(5)
  final String baseReportUid;
  @HiveField(6)
  final String targetReportUid;
  @HiveField(7)
  final String prereadRunUid;
  @HiveField(8)
  final String templateKey;
  @HiveField(9)
  final String title;
  @HiveField(10)
  final String diagnosisType;
  @HiveField(11)
  final String diagnosis;
  @HiveField(12)
  final String comments;
  @HiveField(13)
  final List<ReportResponseHive> responses;
  @HiveField(14)
  final Map<String, String> labelOverrides;
  @HiveField(15)
  final int labelOverrideCount;
  @HiveField(16)
  final bool isCritical;
  @HiveField(17)
  final String addendumText;
  @HiveField(18)
  final String amendmentReason;
  @HiveField(19)
  final String diagnosisStartedAt;
  @HiveField(20)
  final bool startedFromPreread;
  @HiveField(21)
  final String startedAt;
  @HiveField(22)
  final String signedReportUid;
  @HiveField(23)
  final List<NotifiableFindingHive> notifiableFindings;
  @HiveField(24)
  final List<String> hintShownDiseaseIds;
  @HiveField(25)
  final List<String> confirmatoryRequests;
  @HiveField(26)
  final String createdByUid;
  @HiveField(27)
  final String language;
  @HiveField(28)
  final String lastUpdatedAt;
  @HiveField(29)
  final bool synced;
}
