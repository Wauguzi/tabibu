import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/report_for_case.dart';

/// Bundle 82: behaviour that used to be a source-grep gate — an unreleased
/// version is denied, and the last released one is preserved for the patient.
void main() {
  group('patient revision gate', () {
    test('an unreleased current version is denied', () {
      final reports = [
        const PathologyReportModel(
          uid: 'v2',
          caseUid: 'c1',
          version: 2,
          diagnosis: 'Not for the patient yet',
        ),
      ];
      expect(
        reportForCase(reports: reports, caseUid: 'c1', role: .patient),
        isNull,
      );
    });

    test('the last released version is preserved while an update waits', () {
      final reports = [
        const PathologyReportModel(
          uid: 'v1',
          caseUid: 'c1',
          version: 1,
          status: 'Superseded',
          releasedToPatient: true,
          diagnosis: 'Kept',
        ),
        const PathologyReportModel(
          uid: 'v2',
          caseUid: 'c1',
          version: 2,
          diagnosis: 'Hidden',
        ),
      ];
      final shown = reportForCase(
        reports: reports,
        caseUid: 'c1',
        role: .patient,
      );
      expect(shown?.diagnosis, 'Kept');
      expect(shown?.uid, 'v1');
    });
  });
}
