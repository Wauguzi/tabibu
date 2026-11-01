import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_hive.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';

Map<String, dynamic> reportJson() => {
  'uid': 'report-1',
  'caseUid': 'case-1',
  'version': 1,
  'stage': 'Initial',
  'status': 'Signed',
  'orderNumber': 'ODR-1',
  'testName': 'Histopathology',
  'sampleCollectedAt': '2026-10-01T08:00:00.000Z',
  'sampleReceivedAt': '2026-10-02T08:00:00.000Z',
  'labAccessionNo': 'LAB-1',
  'profile': 'Cancer',
  'templateKey': 'Cancer',
  'title': 'Skin biopsy',
  'diagnosisType': 'Final',
  'diagnosis': 'Benign',
  'comments': 'Clear margins.',
  'responses': [
    {
      'section': 'Macroscopic',
      'question': 'specimen',
      'answer': 'Ellipse',
      'order': 0,
    },
  ],
  'isCritical': false,
  'measurements': [
    {'key': 'size', 'unit': 'mm', 'value': 3.0, 'precision': 0},
  ],
  'addenda': <Object>[],
  'amendmentReason': '',
  'prereadRunUid': 'run-1',
  'doctorUid': 'doc-1',
  'pathologistUid': 'path-1',
  'readerUids': ['path-1', 'doc-1'],
  'signedByTitle': 'Dr.',
  'signedByName': 'Path One',
  'signedByKmpdcNumber': 'K-1',
  'signedByFacilityName': 'Lab One',
  'signaturePath': 'sig.png',
  'signatureSha256': 'signature_hash',
  'contentSha256': 'contenthash',
  'startedAt': '2026-10-03T08:00:00.000Z',
  'scoredAt': '2026-10-03T09:00:00.000Z',
  'signedAt': '2026-10-03T10:00:00.000Z',
  'doctorOpenedAt': '',
  'releasedToPatient': false,
  'releasedAt': '',
  'releasedByUid': '',
  'supersededAt': '',
  'supersededByUid': '',
  'notifiableFindings': [
    {'diseaseId': 'malaria', 'alertRequested': false},
  ],
  'confirmatoryRequests': <String>[],
  'createdByUid': 'path-1',
  'language': 'en',
  'lastUpdatedAt': '2026-10-03T10:00:00.000Z',
};

void main() {
  group('PathologyReportModel', () {
    test('fromJson of a full row round-trips through toJson', () {
      final json = reportJson();
      expect(PathologyReportModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = PathologyReportModel.fromJson({});
      expect(model.stage, 'Initial');
      expect(model.status, 'Signed');
      expect(model.profile, 'None');
      expect(model.templateKey, 'General');
      expect(model.diagnosisType, 'Final');
      expect(model.language, 'en');
      expect(model.responses, isEmpty);
      expect(model.synced, isTrue);
    });

    test('toJson never contains synced', () {
      final model = PathologyReportModel.fromJson(reportJson());
      expect(model.toJson().containsKey('synced'), isFalse);
    });

    test('typed getters and helpers', () {
      final model = PathologyReportModel.fromJson(reportJson());
      expect(model.stageValue, ReportStage.initial);
      expect(model.statusValue, ReportStatus.signed);
      expect(model.profileValue, PrereadProfile.cancer);
      expect(model.templateKeyValue, ReportTemplate.cancer);
      expect(model.diagnosisTypeValue, DiagnosisType.finalDiagnosis);
      expect(model.languageValue, ReportLanguage.en);
      expect(model.isCurrent, isTrue);
      expect(model.isReleasedToPatient, isFalse);
      expect(model.isReader('path-1'), isTrue);
      expect(model.isReader('other'), isFalse);
      expect(model.copyWith(status: 'Superseded').isCurrent, isFalse);
    });
  });

  group('PathologyReportHive', () {
    test('fromModel maps fields and round-trips unsynced', () {
      final model = PathologyReportModel.fromJson(
        reportJson(),
      ).copyWith(synced: false);
      final hive = PathologyReportHive.fromModel(model);
      expect(hive.uid, model.uid);
      expect(hive.responses, hasLength(1));
      expect(hive.notifiableFindings, hasLength(1));
      final round = hive.toModel();
      expect(round, model);
      expect(round.synced, isFalse);
    });
  });
}
