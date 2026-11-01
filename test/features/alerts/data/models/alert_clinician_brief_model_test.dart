import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';

Map<String, dynamic> briefJson() => {
  'uid': 'brief',
  'alertUid': 'alert-1',
  'countyId': 1,
  'clinicianText': {
    'en': {'headline': 'Brief', 'body': 'Three cases.'},
  },
  'clinicianGuidance': [
    {
      'bulletId': 'stat',
      'audience': 'Clinician',
      'textEn': 'Report weekly on MOH 505.',
      'textSw': '',
      'swIsOfficial': false,
      'sourceId': 'S1',
    },
  ],
  'sources': <Object>[],
  'confirmedCount': 3,
  'weekStart': '2026-10-26',
  'rule': 'Baseline',
  'categoryVerified': false,
  'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
};

void main() {
  group('AlertClinicianBriefModel', () {
    test('fromJson round-trips through toJson', () {
      final json = briefJson();
      expect(AlertClinicianBriefModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = AlertClinicianBriefModel.fromJson({});
      expect(model.uid, 'brief');
      expect(model.rule, 'Manual');
      expect(model.confirmedCount, 0);
      expect(model.categoryVerified, isFalse);
    });

    test('toJson never contains synced', () {
      expect(
        AlertClinicianBriefModel.fromJson(
          briefJson(),
        ).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters', () {
      expect(
        AlertClinicianBriefModel.fromJson(briefJson()).ruleValue,
        AlertRule.baseline,
      );
      expect(const AlertClinicianBriefModel().ruleValue, AlertRule.manual);
    });
  });

  group('AlertClinicianBriefHive', () {
    test('fromModel maps and round-trips unsynced', () {
      final model = AlertClinicianBriefModel.fromJson(
        briefJson(),
      ).copyWith(synced: false);
      expect(AlertClinicianBriefHive.fromModel(model).toModel(), model);
    });
  });
}
