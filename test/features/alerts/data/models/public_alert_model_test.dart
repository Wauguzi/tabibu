import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

Map<String, dynamic> publicAlertJson() => {
  'uid': 'alert-1',
  'diseaseId': 'malaria',
  'diseaseNameEn': 'Malaria',
  'diseaseNameSw': 'Malaria',
  'countyId': 1,
  'countyName': 'Nairobi',
  'clinicianCountyIds': <int>[1, 2],
  'epiWeek': '2026-W44',
  'category': 'Weekly',
  'patientText': {
    'en': {'headline': 'Alert', 'body': 'Take care.'},
    'sw': {'headline': 'Alert', 'body': 'Take care.'},
  },
  'patientGuidance': [
    {
      'bulletId': 'b1',
      'audience': 'Patient',
      'textEn': 'Use a net.',
      'textSw': 'Use a net.',
      'swIsOfficial': false,
      'sourceId': 'S17',
    },
  ],
  'sources': [
    {
      'sourceId': 'S17',
      'title': 'Malaria guidance',
      'publisher': 'MoH',
      'url': 'https://example.com/s17',
      'publishedOn': '2025-03-08',
      'accessedOn': '2026-01-01',
    },
  ],
  'issuedAt': '2026-11-01T10:00:00.000Z',
  'patientsReleased': true,
  'patientsReleasedAt': '2026-11-01T12:00:00.000Z',
  'synthetic': false,
  'createdAt': '2026-11-01T10:00:00.000Z',
  'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
};

void main() {
  group('PublicAlertModel', () {
    test('fromJson round-trips through toJson', () {
      final json = publicAlertJson();
      expect(PublicAlertModel.fromJson(json).toJson(), json);
    });

    test('missing keys read defaults', () {
      final model = PublicAlertModel.fromJson({});
      expect(model.category, 'Immediate');
      expect(model.patientsReleased, isFalse);
      expect(model.patientText, isEmpty);
      expect(model.synced, isTrue);
    });

    test('toJson never contains synced', () {
      expect(
        PublicAlertModel.fromJson(
          publicAlertJson(),
        ).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters and isReleasedToPatients', () {
      final released = PublicAlertModel.fromJson(publicAlertJson());
      expect(released.categoryValue, ReportingCategory.weekly);
      expect(released.isReleasedToPatients, isTrue);
      expect(PublicAlertModel.fromJson({}).isReleasedToPatients, isFalse);
    });
  });

  group('PublicAlertHive', () {
    test('fromModel maps nested fields and round-trips unsynced', () {
      final model = PublicAlertModel.fromJson(
        publicAlertJson(),
      ).copyWith(synced: false);
      final hive = PublicAlertHive.fromModel(model);
      expect(hive.patientText.keys, containsAll(['en', 'sw']));
      expect(hive.patientGuidance, hasLength(1));
      expect(hive.toModel(), model);
    });
  });
}
