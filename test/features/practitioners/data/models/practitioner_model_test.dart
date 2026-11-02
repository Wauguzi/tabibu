import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

Map<String, dynamic> practitionerJson() => {
  'uid': 'doctor-1',
  'title': 'Dr.',
  'firstName': 'Brian',
  'lastName': 'Mwangi',
  'profilePictureUrl': 'https://example.com/brian.jpg',
  'isPathologist': true,
  'specialties': ['Histopathology', 'Cytology'],
  'bio': 'Pathologist in Nairobi.',
  'facilityId': 'facility-1',
  'facilityMflCode': '13043',
  'facilityName': 'Example Health Centre',
  'county': 'Nairobi',
  'subCounty': 'Kibra',
  'geohash': 'kzf0eg70h',
  'isAvailable': true,
  'appointmentsHandled': 10,
  'ordersCreated': 20,
  'reportsSigned': 30,
  'workingDays': [1, 2, 3, 6],
  'dayStartMinute': 540,
  'dayEndMinute': 960,
  'busySlots': ['2026-11-01T08:00:00.000Z'],
  'lastUpdatedAt': '2026-10-21T10:00:00.000Z',
};

/// Today's shape before the working-hours fields existed.
Map<String, dynamic> legacyPractitionerJson() {
  final json = practitionerJson()
    ..remove('workingDays')
    ..remove('dayStartMinute')
    ..remove('dayEndMinute')
    ..remove('busySlots');
  return json;
}

void main() {
  group('PractitionerModel', () {
    test('empty returns every field at its default', () {
      final model = PractitionerModel.empty();
      expect(model.uid, '');
      expect(model.isPathologist, isFalse);
      expect(model.reportsSigned, 0);
      expect(model.workingDays, [1, 2, 3, 4, 5]);
      expect(model.dayStartMinute, 480);
      expect(model.dayEndMinute, 1020);
      expect(model.busySlots, isEmpty);
      expect(model.synced, isTrue);
    });

    test('fromJson parses a complete document', () {
      final model = PractitionerModel.fromJson(practitionerJson());
      expect(model.uid, 'doctor-1');
      expect(model.isPathologist, isTrue);
      expect(model.reportsSigned, 30);
      expect(model.workingDays, [1, 2, 3, 6]);
      expect(model.dayStartMinute, 540);
      expect(model.dayEndMinute, 960);
      expect(model.busySlots, ['2026-11-01T08:00:00.000Z']);
      expect(model.synced, isTrue);
    });

    test(
      'fromJson fills working-hours defaults when the fields are absent',
      () {
        final model = PractitionerModel.fromJson(legacyPractitionerJson());
        expect(model.workingDays, [1, 2, 3, 4, 5]);
        expect(model.dayStartMinute, 480);
        expect(model.dayEndMinute, 1020);
        expect(model.busySlots, isEmpty);
        expect(model.uid, 'doctor-1');
      },
    );

    test('fromJson round-trips through toJson', () {
      final json = practitionerJson();
      expect(PractitionerModel.fromJson(json).toJson(), json);
    });

    test('toJson writes the four working-hours fields', () {
      final json = PractitionerModel.fromJson(practitionerJson()).toJson();
      expect(json['workingDays'], [1, 2, 3, 6]);
      expect(json['dayStartMinute'], 540);
      expect(json['dayEndMinute'], 960);
      expect(json['busySlots'], ['2026-11-01T08:00:00.000Z']);
    });

    test('toJson never emits synced', () {
      final model = PractitionerModel.fromJson(practitionerJson());
      expect(model.toJson().containsKey('synced'), isFalse);
      expect(
        model.copyWith(synced: false).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('carries no private fields', () {
      final json = PractitionerModel.fromJson(practitionerJson()).toJson();
      for (final key in [
        'email',
        'phoneNumber',
        'kmpdcNumber',
        'licenseUrls',
        'fcmTokens',
      ]) {
        expect(json.containsKey(key), isFalse, reason: key);
      }
    });

    test('fullName puts the title first', () {
      final model = PractitionerModel.fromJson(practitionerJson());
      expect(model.fullName, 'Dr. Brian Mwangi');
      expect(model.copyWith(title: '').fullName, 'Brian Mwangi');
      expect(PractitionerModel.empty().fullName, '');
    });
  });
}
