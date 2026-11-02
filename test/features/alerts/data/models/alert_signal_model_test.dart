import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_signal_model.dart';

Map<String, dynamic> signalJson() => {
  'uid': 'sig-1',
  'diseaseId': 'cholera',
  'countyId': 1,
  'countyName': 'Nairobi',
  'epiWeek': '2026-W44',
  'category': 'Immediate',
  'rule': 'Immediate',
  'status': 'Raised',
  'evidence': {
    'confirmedCount': 4,
    'baselineMean': 0.0,
    'baselineSd': 0.0,
    'threshold': 0.0,
    'floor': 0,
    'windowWeeks': 0,
    'multiplier': 0.0,
    'ageBandCounts': <String, int>{},
    'manualRequests': 0,
    'categoryVerified': false,
    'mappingVerified': false,
    'categorySourceId': '',
    'weekStart': '2026-10-26',
  },
  'alertUid': 'alert-1',
  'synthetic': false,
  'raisedAt': '2026-11-01T08:00:00.000Z',
  'lastUpdatedAt': '2026-11-01T08:00:00.000Z',
};

void main() {
  group('AlertSignalModel', () {
    test('fromJson round-trips through toJson', () {
      final json = signalJson();
      expect(AlertSignalModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AlertSignalModel.fromJson({});
      expect(model.status, 'Withdrawn');
      expect(model.evidence.confirmedCount, 0);
    });

    test('typed getters and isRaised', () {
      final raised = AlertSignalModel.fromJson(signalJson());
      expect(raised.categoryValue, ReportingCategory.immediate);
      expect(raised.ruleValue, AlertRule.immediate);
      expect(raised.isRaised, isTrue);
      expect(AlertSignalModel.fromJson({}).isRaised, isFalse);
    });
  });
}
