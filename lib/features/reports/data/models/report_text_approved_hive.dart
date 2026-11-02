import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';

part 'report_text_approved_hive.g.dart';

/// Cached [ReportTextApprovedModel], in the same field order.
@HiveType(typeId: 23)
class ReportTextApprovedHive {
  ReportTextApprovedHive({
    required this.uid,
    required this.caseUid,
    required this.reportUid,
    required this.reportVersion,
    required this.kind,
    required this.language,
    required this.sourceLanguage,
    required this.sourceSha256,
    required this.approvedText,
    required this.approverUid,
    required this.approverName,
    required this.approvedAt,
    required this.acceptedUnchanged,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory ReportTextApprovedHive.fromModel(ReportTextApprovedModel model) {
    return ReportTextApprovedHive(
      uid: model.uid,
      caseUid: model.caseUid,
      reportUid: model.reportUid,
      reportVersion: model.reportVersion,
      kind: model.kind,
      language: model.language,
      sourceLanguage: model.sourceLanguage,
      sourceSha256: model.sourceSha256,
      approvedText: model.approvedText,
      approverUid: model.approverUid,
      approverName: model.approverName,
      approvedAt: model.approvedAt,
      acceptedUnchanged: model.acceptedUnchanged,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  ReportTextApprovedModel toModel() {
    return ReportTextApprovedModel(
      uid: uid,
      caseUid: caseUid,
      reportUid: reportUid,
      reportVersion: reportVersion,
      kind: kind,
      language: language,
      sourceLanguage: sourceLanguage,
      sourceSha256: sourceSha256,
      approvedText: approvedText,
      approverUid: approverUid,
      approverName: approverName,
      approvedAt: approvedAt,
      acceptedUnchanged: acceptedUnchanged,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String caseUid;
  @HiveField(2)
  final String reportUid;
  @HiveField(3)
  final int reportVersion;
  @HiveField(4)
  final String kind;
  @HiveField(5)
  final String language;
  @HiveField(6)
  final String sourceLanguage;
  @HiveField(7)
  final String sourceSha256;
  @HiveField(8)
  final Map<String, String> approvedText;
  @HiveField(9)
  final String approverUid;
  @HiveField(10)
  final String approverName;
  @HiveField(11)
  final String approvedAt;
  @HiveField(12)
  final bool acceptedUnchanged;
  @HiveField(13)
  final String lastUpdatedAt;
  @HiveField(14)
  final bool synced;
}
