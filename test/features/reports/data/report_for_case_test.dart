import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/report_for_case.dart';

PathologyReportModel _r({
  required String caseUid,
  required String uid,
  required int version,
  bool released = false,
  String status = 'Signed',
  String diagnosis = '',
}) => PathologyReportModel(
  uid: uid,
  caseUid: caseUid,
  version: version,
  status: status,
  releasedToPatient: released,
  diagnosis: diagnosis,
);

void main() {
  group('reportMatching', () {
    test('two cases with the same report uid each keep their own', () {
      final reports = [
        _r(
          caseUid: 'c1',
          uid: 'v1',
          version: 1,
          diagnosis: 'A',
          released: true,
        ),
        _r(
          caseUid: 'c2',
          uid: 'v1',
          version: 1,
          diagnosis: 'B',
          released: true,
        ),
      ];
      expect(
        reportMatching(
          reports: reports,
          caseUid: 'c1',
          reportUid: 'v1',
        )?.diagnosis,
        'A',
      );
      expect(
        reportMatching(
          reports: reports,
          caseUid: 'c2',
          reportUid: 'v1',
        )?.diagnosis,
        'B',
      );
    });
  });

  group('reportForCase', () {
    test('a patient keeps the last released when the current is not', () {
      final reports = [
        _r(
          caseUid: 'c1',
          uid: 'v1',
          version: 1,
          released: true,
          status: 'Superseded',
          diagnosis: 'Released',
        ),
        _r(
          caseUid: 'c1',
          uid: 'v2',
          version: 2,
          diagnosis: 'Unreleased current',
        ),
      ];
      expect(
        reportForCase(
          reports: reports,
          caseUid: 'c1',
          role: .patient,
        )?.diagnosis,
        'Released',
      );
      expect(
        reportForCase(
          reports: reports,
          caseUid: 'c1',
          role: .doctor,
        )?.diagnosis,
        'Unreleased current',
      );
    });

    test('a patient never sees an unreleased version alone', () {
      final reports = [_r(caseUid: 'c1', uid: 'v2', version: 2)];
      expect(
        reportForCase(reports: reports, caseUid: 'c1', role: .patient),
        isNull,
      );
    });

    test('a patient takes the current when it is released', () {
      final reports = [
        _r(
          caseUid: 'c1',
          uid: 'v1',
          version: 1,
          released: true,
          status: 'Superseded',
          diagnosis: 'Old',
        ),
        _r(
          caseUid: 'c1',
          uid: 'v2',
          version: 2,
          released: true,
          diagnosis: 'New',
        ),
      ];
      expect(
        reportForCase(
          reports: reports,
          caseUid: 'c1',
          role: .patient,
        )?.diagnosis,
        'New',
      );
    });
  });
}
