import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_hive.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';

Map<String, dynamic> approvedJson() => {
  'uid': 'text-1',
  'caseUid': 'case-1',
  'reportUid': 'report-1',
  'reportVersion': 1,
  'kind': 'Translation',
  'language': 'sw',
  'sourceLanguage': 'en',
  'sourceSha256': 'contenthash',
  'approvedText': {'body': 'Approved body'},
  'approverUid': 'path-1',
  'approverName': 'Path One',
  'approvedAt': '2026-11-01T11:00:00.000Z',
  'acceptedUnchanged': true,
  'lastUpdatedAt': '2026-11-01T11:00:00.000Z',
};

void main() {
  group('ReportTextApprovedModel', () {
    test('fromJson round-trips through toJson', () {
      final json = approvedJson();
      expect(ReportTextApprovedModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportTextApprovedModel.fromJson({});
      expect(model.approvedText, isEmpty);
      expect(model.acceptedUnchanged, isFalse);
    });

    test('toJson never contains synced', () {
      expect(
        ReportTextApprovedModel.fromJson(
          approvedJson(),
        ).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters', () {
      final model = ReportTextApprovedModel.fromJson(approvedJson());
      expect(model.kindValue, ReportTextKind.translation);
      expect(model.languageValue, ReportLanguage.sw);
      expect(model.sourceLanguageValue, ReportLanguage.en);
    });
  });

  group('ReportTextApprovedHive', () {
    test('fromModel maps and round-trips unsynced', () {
      final model = ReportTextApprovedModel.fromJson(
        approvedJson(),
      ).copyWith(synced: false);
      expect(ReportTextApprovedHive.fromModel(model).toModel(), model);
    });
  });
}
