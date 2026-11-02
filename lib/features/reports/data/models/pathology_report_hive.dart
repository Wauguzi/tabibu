import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_hive.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_hive.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_hive.dart';
import 'package:tabibu/features/reports/data/models/report_response_hive.dart';

part 'pathology_report_hive.g.dart';

/// Cached [PathologyReportModel], in the same field order.
@HiveType(typeId: 16)
class PathologyReportHive {
  PathologyReportHive({
    required this.uid,
    required this.caseUid,
    required this.version,
    required this.stage,
    required this.status,
    required this.orderNumber,
    required this.testName,
    required this.sampleCollectedAt,
    required this.sampleReceivedAt,
    required this.labAccessionNo,
    required this.profile,
    required this.templateKey,
    required this.title,
    required this.diagnosisType,
    required this.diagnosis,
    required this.comments,
    required this.responses,
    required this.isCritical,
    required this.measurements,
    required this.addenda,
    required this.amendmentReason,
    required this.prereadRunUid,
    required this.doctorUid,
    required this.pathologistUid,
    required this.readerUids,
    required this.signedByTitle,
    required this.signedByName,
    required this.signedByKmpdcNumber,
    required this.signedByFacilityName,
    required this.signaturePath,
    required this.signatureSha256,
    required this.contentSha256,
    required this.startedAt,
    required this.scoredAt,
    required this.signedAt,
    required this.doctorOpenedAt,
    required this.releasedToPatient,
    required this.releasedAt,
    required this.releasedByUid,
    required this.supersededAt,
    required this.supersededByUid,
    required this.notifiableFindings,
    required this.confirmatoryRequests,
    required this.createdByUid,
    required this.language,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory PathologyReportHive.fromModel(PathologyReportModel model) {
    return PathologyReportHive(
      uid: model.uid,
      caseUid: model.caseUid,
      version: model.version,
      stage: model.stage,
      status: model.status,
      orderNumber: model.orderNumber,
      testName: model.testName,
      sampleCollectedAt: model.sampleCollectedAt,
      sampleReceivedAt: model.sampleReceivedAt,
      labAccessionNo: model.labAccessionNo,
      profile: model.profile,
      templateKey: model.templateKey,
      title: model.title,
      diagnosisType: model.diagnosisType,
      diagnosis: model.diagnosis,
      comments: model.comments,
      responses: model.responses.map(ReportResponseHive.fromModel).toList(),
      isCritical: model.isCritical,
      measurements: model.measurements
          .map(ReportMeasurementHive.fromModel)
          .toList(),
      addenda: model.addenda.map(ReportAddendumHive.fromModel).toList(),
      amendmentReason: model.amendmentReason,
      prereadRunUid: model.prereadRunUid,
      doctorUid: model.doctorUid,
      pathologistUid: model.pathologistUid,
      readerUids: model.readerUids,
      signedByTitle: model.signedByTitle,
      signedByName: model.signedByName,
      signedByKmpdcNumber: model.signedByKmpdcNumber,
      signedByFacilityName: model.signedByFacilityName,
      signaturePath: model.signaturePath,
      signatureSha256: model.signatureSha256,
      contentSha256: model.contentSha256,
      startedAt: model.startedAt,
      scoredAt: model.scoredAt,
      signedAt: model.signedAt,
      doctorOpenedAt: model.doctorOpenedAt,
      releasedToPatient: model.releasedToPatient,
      releasedAt: model.releasedAt,
      releasedByUid: model.releasedByUid,
      supersededAt: model.supersededAt,
      supersededByUid: model.supersededByUid,
      notifiableFindings: model.notifiableFindings
          .map(NotifiableFindingHive.fromModel)
          .toList(),
      confirmatoryRequests: model.confirmatoryRequests,
      createdByUid: model.createdByUid,
      language: model.language,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  PathologyReportModel toModel() {
    return PathologyReportModel(
      uid: uid,
      caseUid: caseUid,
      version: version,
      stage: stage,
      status: status,
      orderNumber: orderNumber,
      testName: testName,
      sampleCollectedAt: sampleCollectedAt,
      sampleReceivedAt: sampleReceivedAt,
      labAccessionNo: labAccessionNo,
      profile: profile,
      templateKey: templateKey,
      title: title,
      diagnosisType: diagnosisType,
      diagnosis: diagnosis,
      comments: comments,
      responses: responses.map((e) => e.toModel()).toList(),
      isCritical: isCritical,
      measurements: measurements.map((e) => e.toModel()).toList(),
      addenda: addenda.map((e) => e.toModel()).toList(),
      amendmentReason: amendmentReason,
      prereadRunUid: prereadRunUid,
      doctorUid: doctorUid,
      pathologistUid: pathologistUid,
      readerUids: readerUids,
      signedByTitle: signedByTitle,
      signedByName: signedByName,
      signedByKmpdcNumber: signedByKmpdcNumber,
      signedByFacilityName: signedByFacilityName,
      signaturePath: signaturePath,
      signatureSha256: signatureSha256,
      contentSha256: contentSha256,
      startedAt: startedAt,
      scoredAt: scoredAt,
      signedAt: signedAt,
      doctorOpenedAt: doctorOpenedAt,
      releasedToPatient: releasedToPatient,
      releasedAt: releasedAt,
      releasedByUid: releasedByUid,
      supersededAt: supersededAt,
      supersededByUid: supersededByUid,
      notifiableFindings: notifiableFindings.map((e) => e.toModel()).toList(),
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
  final int version;
  @HiveField(3)
  final String stage;
  @HiveField(4)
  final String status;
  @HiveField(5)
  final String orderNumber;
  @HiveField(6)
  final String testName;
  @HiveField(7)
  final String sampleCollectedAt;
  @HiveField(8)
  final String sampleReceivedAt;
  @HiveField(9)
  final String labAccessionNo;
  @HiveField(10)
  final String profile;
  @HiveField(11)
  final String templateKey;
  @HiveField(12)
  final String title;
  @HiveField(13)
  final String diagnosisType;
  @HiveField(14)
  final String diagnosis;
  @HiveField(15)
  final String comments;
  @HiveField(16)
  final List<ReportResponseHive> responses;
  @HiveField(17)
  final bool isCritical;
  @HiveField(18)
  final List<ReportMeasurementHive> measurements;
  @HiveField(19)
  final List<ReportAddendumHive> addenda;
  @HiveField(20)
  final String amendmentReason;
  @HiveField(21)
  final String prereadRunUid;
  @HiveField(22)
  final String doctorUid;
  @HiveField(23)
  final String pathologistUid;
  @HiveField(24)
  final List<String> readerUids;
  @HiveField(25)
  final String signedByTitle;
  @HiveField(26)
  final String signedByName;
  @HiveField(27)
  final String signedByKmpdcNumber;
  @HiveField(28)
  final String signedByFacilityName;
  @HiveField(29)
  final String signaturePath;
  @HiveField(30)
  final String signatureSha256;
  @HiveField(31)
  final String contentSha256;
  @HiveField(32)
  final String startedAt;
  @HiveField(33)
  final String scoredAt;
  @HiveField(34)
  final String signedAt;
  @HiveField(35)
  final String doctorOpenedAt;
  @HiveField(36)
  final bool releasedToPatient;
  @HiveField(37)
  final String releasedAt;
  @HiveField(38)
  final String releasedByUid;
  @HiveField(39)
  final String supersededAt;
  @HiveField(40)
  final String supersededByUid;
  @HiveField(41)
  final List<NotifiableFindingHive> notifiableFindings;
  @HiveField(42)
  final List<String> confirmatoryRequests;
  @HiveField(43)
  final String createdByUid;
  @HiveField(44)
  final String language;
  @HiveField(45)
  final String lastUpdatedAt;
  @HiveField(46)
  final bool synced;
}
