import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_model.dart';

part 'report_addendum_hive.g.dart';

/// Cached [ReportAddendumModel], in the same field order.
@HiveType(typeId: 18)
class ReportAddendumHive {
  ReportAddendumHive({
    required this.uid,
    required this.text,
    required this.reportVersion,
    required this.signedByUid,
    required this.signedByName,
    required this.signedAt,
  });

  factory ReportAddendumHive.fromModel(ReportAddendumModel model) {
    return ReportAddendumHive(
      uid: model.uid,
      text: model.text,
      reportVersion: model.reportVersion,
      signedByUid: model.signedByUid,
      signedByName: model.signedByName,
      signedAt: model.signedAt,
    );
  }

  ReportAddendumModel toModel() {
    return ReportAddendumModel(
      uid: uid,
      text: text,
      reportVersion: reportVersion,
      signedByUid: signedByUid,
      signedByName: signedByName,
      signedAt: signedAt,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int reportVersion;

  @HiveField(3)
  final String signedByUid;

  @HiveField(4)
  final String signedByName;

  @HiveField(5)
  final String signedAt;
}
