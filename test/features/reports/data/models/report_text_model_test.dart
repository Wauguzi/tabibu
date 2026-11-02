import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';

Map<String, dynamic> workingTextJson() => {
  'uid': 'text-1',
  'caseUid': 'case-1',
  'reportUid': 'report-1',
  'reportVersion': 1,
  'kind': 'Translation',
  'language': 'sw',
  'sourceLanguage': 'en',
  'detectedSourceLanguage': 'en',
  'languageMismatch': false,
  'sourceSha256': 'contenthash',
  'status': 'Ready',
  'machineText': {'body': 'Machine body'},
  'models': {'translate': 'v1'},
  'approverUid': 'path-1',
  'requestCount': 1,
  'acceptedUnchanged': false,
  'editedSegmentKeys': <String>[],
  'editDistance': 0.0,
  'failureReason': '',
  'requestedAt': '2026-11-01T10:00:00.000Z',
  'readyAt': '2026-11-01T10:05:00.000Z',
  'approvedAt': '',
  'lastUpdatedAt': '2026-11-01T10:05:00.000Z',
};

void main() {
  group('ReportTextModel', () {
    test('fromJson round-trips through toJson', () {
      final json = workingTextJson();
      expect(ReportTextModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportTextModel.fromJson({});
      expect(model.kind, 'Translation');
      expect(model.language, 'sw');
      expect(model.sourceLanguage, 'en');
      expect(model.status, 'Queued');
      expect(model.machineText, isEmpty);
    });

    test('typed getters', () {
      final model = ReportTextModel.fromJson(workingTextJson());
      expect(model.kindValue, ReportTextKind.translation);
      expect(model.statusValue, ReportTextStatus.ready);
      expect(model.failureReasonValue, FailureReason.none);
    });
  });
}
