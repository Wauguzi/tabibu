import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

Map<String, dynamic> practitionerJson() => {
  'uid': 'doctor-1',
  'title': 'Dr.',
  'firstName': 'Brian',
  'lastName': 'Mwangi',
  'profilePictureUrl': 'https://example.com/brian.jpg',
  'isPathologist': true,
  'specialization': 'Histopathology',
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
  'lastUpdatedAt': '2026-10-21T10:00:00.000Z',
};

void main() {
  group('PractitionerModel', () {
    test('empty returns every field at its default', () {
      final model = PractitionerModel.empty();
      expect(model.uid, '');
      expect(model.isPathologist, isFalse);
      expect(model.reportsSigned, 0);
      expect(model.synced, isTrue);
    });

    test('fromJson parses a complete document', () {
      final model = PractitionerModel.fromJson(practitionerJson());
      expect(model.uid, 'doctor-1');
      expect(model.isPathologist, isTrue);
      expect(model.reportsSigned, 30);
      expect(model.synced, isTrue);
    });

    test('fromJson round-trips through toJson', () {
      final json = practitionerJson();
      expect(PractitionerModel.fromJson(json).toJson(), json);
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
        'licenseUrl',
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
