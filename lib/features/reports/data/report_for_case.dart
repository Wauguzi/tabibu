import 'package:collection/collection.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';

/// Match a report under [caseUid] by [reportUid]. Report ids (`v1`, `v2`)
/// repeat under every case, so [reportUid] alone is never enough.
PathologyReportModel? reportMatching({
  required Iterable<PathologyReportModel> reports,
  required String caseUid,
  required String reportUid,
}) {
  if (reportUid.isEmpty) {
    return reports.firstWhereOrNull((r) => r.caseUid == caseUid);
  }
  return reports.firstWhereOrNull(
    (r) => r.caseUid == caseUid && r.uid == reportUid,
  );
}

/// Which signed report a reader should see for [caseUid].
///
/// Doctors and pathologists always take the current version. A patient takes
/// the current version only when it is released; otherwise the latest
/// released version (highest [PathologyReportModel.version]), including a
/// superseded one, so an update waiting with the doctor does not hide what
/// they already had (CRQ-0050 §9).
PathologyReportModel? reportForCase({
  required Iterable<PathologyReportModel> reports,
  required String caseUid,
  required Role role,
}) {
  final ofCase = [
    for (final r in reports)
      if (r.caseUid == caseUid) r,
  ];
  if (ofCase.isEmpty) return null;

  final current = ofCase
      .where((r) => r.isCurrent)
      .sortedBy<num>((r) => r.version)
      .lastOrNull;

  if (role != .patient) return current;

  if (current != null && current.releasedToPatient) return current;
  return ofCase
      .where((r) => r.releasedToPatient)
      .sortedBy<num>((r) => r.version)
      .lastOrNull;
}
