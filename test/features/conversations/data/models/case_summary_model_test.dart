import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_hive.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_model.dart';

Map<String, dynamic> caseSummaryJson() => {
  'caseRef': 'ODR-TEST-001',
  'ageBand': '40-49',
  'sex': 'Female',
  'testTypeNames': ['Test Type'],
  'testNames': ['Test Name'],
  'reportStatus': 'Signed',
  'signedDiagnosisExcerpt': 'Test excerpt',
  'signedAt': '2030-05-04T10:00:00.000Z',
  'signedByName': 'Test Pathologist',
  'reportLanguage': 'en',
  'builtAt': '2030-05-04T10:00:00.000Z',
};

void main() {
  group('CaseSummaryModel', () {
    test('fromJson parses a full row and round-trips through toJson', () {
      final json = caseSummaryJson();
      final model = CaseSummaryModel.fromJson(json);
      expect(model.reportStatus, 'Signed');
      expect(model.testNames, ['Test Name']);
      expect(model.toJson(), json);
    });

    test('a row missing every key reads the defaults', () {
      final model = CaseSummaryModel.fromJson({});
      expect(model, CaseSummaryModel.empty());
      expect(model.reportStatus, 'Pending');
    });

    test('typed getters read their values and fall back', () {
      final model = CaseSummaryModel.fromJson(caseSummaryJson());
      expect(model.sexValue, Sex.female);
      expect(model.reportStatusValue, SummaryReportStatus.signed);
      expect(model.reportLanguageValue, ReportLanguage.en);
      expect(CaseSummaryModel.fromJson({'sex': 'Bogus'}).sexValue, isNull);
      expect(
        CaseSummaryModel.fromJson({'reportStatus': 'Bogus'}).reportStatusValue,
        SummaryReportStatus.pending,
      );
      expect(
        CaseSummaryModel.fromJson({
          'reportLanguage': 'Bogus',
        }).reportLanguageValue,
        ReportLanguage.en,
      );
    });
  });

  group('CaseSummaryHive', () {
    test('fromModel maps every field', () {
      final hive = CaseSummaryHive.fromModel(
        CaseSummaryModel.fromJson(caseSummaryJson()),
      );
      expect(hive.caseRef, 'ODR-TEST-001');
      expect(hive.ageBand, '40-49');
      expect(hive.sex, 'Female');
      expect(hive.testTypeNames, ['Test Type']);
      expect(hive.testNames, ['Test Name']);
      expect(hive.reportStatus, 'Signed');
      expect(hive.signedDiagnosisExcerpt, 'Test excerpt');
      expect(hive.signedAt, '2030-05-04T10:00:00.000Z');
      expect(hive.signedByName, 'Test Pathologist');
      expect(hive.reportLanguage, 'en');
      expect(hive.builtAt, '2030-05-04T10:00:00.000Z');
    });

    test('toModel round-trips', () {
      final model = CaseSummaryModel.fromJson(caseSummaryJson());
      expect(CaseSummaryHive.fromModel(model).toModel(), model);
    });
  });
}
