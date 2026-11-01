import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_hive.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_model.dart';

Map<String, dynamic> addendumJson() => {
  'uid': 'add-1',
  'text': 'Clarified margins.',
  'reportVersion': 1,
  'signedByUid': 'path-1',
  'signedByName': 'Dr Path',
  'signedAt': '2026-11-01T10:00:00.000Z',
};

void main() {
  group('ReportAddendumModel', () {
    test('fromJson round-trips through toJson', () {
      final json = addendumJson();
      expect(ReportAddendumModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = ReportAddendumModel.fromJson({});
      expect(model.uid, '');
      expect(model.reportVersion, 0);
    });
  });

  group('ReportAddendumHive', () {
    test('fromModel maps every field and round-trips', () {
      final model = ReportAddendumModel.fromJson(addendumJson());
      expect(ReportAddendumHive.fromModel(model).toModel(), model);
    });
  });
}
