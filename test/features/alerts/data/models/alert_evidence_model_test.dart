import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/data/models/alert_evidence_model.dart';

Map<String, dynamic> evidenceJson() => {
  'confirmedCount': 5,
  'baselineMean': 1.2,
  'baselineSd': 0.4,
  'threshold': 3.0,
  'floor': 2,
  'windowWeeks': 8,
  'multiplier': 2.5,
  'ageBandCounts': {'0-4': 1, '25-44': 4},
  'manualRequests': 1,
  'categoryVerified': false,
  'mappingVerified': true,
  'categorySourceId': 'S1',
  'weekStart': '2026-10-26',
};

void main() {
  group('AlertEvidenceModel', () {
    test('fromJson round-trips through toJson', () {
      final json = evidenceJson();
      expect(AlertEvidenceModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AlertEvidenceModel.fromJson({});
      expect(model.confirmedCount, 0);
      expect(model.ageBandCounts, isEmpty);
      expect(model.mappingVerified, isFalse);
      expect(model.weekStart, '');
    });
  });
}
