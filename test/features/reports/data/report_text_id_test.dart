import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/report_text_id.dart';

void main() {
  // Mirrors functions/src/reports.ts `textId(reportUid, kind, language)`.
  group('reportTextId', () {
    test('matches the server for both kinds and both languages', () {
      expect(
        reportTextId('rep1', ReportTextKind.explanation, 'en'),
        'rep1_Explanation_en',
      );
      expect(
        reportTextId('rep1', ReportTextKind.explanation, 'sw'),
        'rep1_Explanation_sw',
      );
      expect(
        reportTextId('rep1', ReportTextKind.translation, 'en'),
        'rep1_Translation_en',
      );
      expect(
        reportTextId('rep1', ReportTextKind.translation, 'sw'),
        'rep1_Translation_sw',
      );
    });
  });
}
