import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

Map<String, dynamic> doctorJson() => {
  'uid': 'doctor-1',
  'title': 'Dr.',
  'firstName': 'Brian',
  'lastName': 'Mwangi',
  'email': 'brian@example.com',
  'phoneNumber': '+254722345678',
  'profilePictureUrl': 'https://example.com/brian.jpg',
  'isPathologist': false,
  'specialties': ['Histopathology', 'Cytology'],
  'bio': 'Pathologist in Nairobi.',
  'kmpdcNumber': 'KMPDC-12345',
  'licenseUrls': ['https://example.com/license.pdf'],
  'verificationStatus': 'Verified',
  'facilityId': 'facility-1',
  'facilityMflCode': '13043',
  'facilityName': 'Example Health Centre',
  'county': 'Nairobi',
  'subCounty': 'Kibra',
  'geohash': 'kzf0eg70h',
  'isAvailable': true,
  'fcmTokens': ['token-1'],
  'language': 'en',
  'receiveNotifications': true,
  'appointmentsHandled': 10,
  'ordersCreated': 20,
  'reportsSigned': 0,
  'termsAcceptedAt': '2026-10-20T10:00:00.000Z',
  'createdAt': '2026-10-20T10:00:00.000Z',
  'workingDays': [1, 2, 3, 6],
  'dayStartMinute': 540,
  'dayEndMinute': 960,
  'busySlots': ['2026-11-01T08:00:00.000Z'],
  'lastUpdatedAt': '2026-10-21T10:00:00.000Z',
};

/// Today's shape before the working-hours fields existed.
Map<String, dynamic> legacyDoctorJson() {
  final json = doctorJson()
    ..remove('workingDays')
    ..remove('dayStartMinute')
    ..remove('dayEndMinute')
    ..remove('busySlots');
  return json;
}

void main() {
  group('DoctorModel', () {
    test('empty returns every field at its default', () {
      final model = DoctorModel.empty();
      expect(model.uid, '');
      expect(model.isPathologist, isFalse);
      expect(model.isAvailable, isFalse);
      expect(model.fcmTokens, isEmpty);
      expect(model.appointmentsHandled, 0);
      expect(model.ordersCreated, 0);
      expect(model.reportsSigned, 0);
      expect(model.workingDays, [1, 2, 3, 4, 5]);
      expect(model.dayStartMinute, 480);
      expect(model.dayEndMinute, 1020);
      expect(model.busySlots, isEmpty);
      expect(model.synced, isTrue);
    });

    test('fromJson parses a complete document', () {
      final model = DoctorModel.fromJson(doctorJson());
      expect(model.uid, 'doctor-1');
      expect(model.verificationStatus, 'Verified');
      expect(model.facilityName, 'Example Health Centre');
      expect(model.workingDays, [1, 2, 3, 6]);
      expect(model.dayStartMinute, 540);
      expect(model.dayEndMinute, 960);
      expect(model.busySlots, ['2026-11-01T08:00:00.000Z']);
      expect(model.synced, isTrue);
    });

    test(
      'fromJson fills working-hours defaults when the fields are absent',
      () {
        final model = DoctorModel.fromJson(legacyDoctorJson());
        expect(model.workingDays, [1, 2, 3, 4, 5]);
        expect(model.dayStartMinute, 480);
        expect(model.dayEndMinute, 1020);
        expect(model.busySlots, isEmpty);
        expect(model.uid, 'doctor-1');
      },
    );

    test('fromJson round-trips through toJson', () {
      final json = doctorJson();
      expect(DoctorModel.fromJson(json).toJson(), json);
    });

    test('toJson writes the four working-hours fields', () {
      final json = DoctorModel.fromJson(doctorJson()).toJson();
      expect(json['workingDays'], [1, 2, 3, 6]);
      expect(json['dayStartMinute'], 540);
      expect(json['dayEndMinute'], 960);
      expect(json['busySlots'], ['2026-11-01T08:00:00.000Z']);
    });

    test('toJson never emits synced', () {
      final model = DoctorModel.fromJson(doctorJson());
      expect(model.toJson().containsKey('synced'), isFalse);
      expect(
        model.copyWith(synced: false).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('fullName puts the title first', () {
      final model = DoctorModel.fromJson(doctorJson());
      expect(model.fullName, 'Dr. Brian Mwangi');
      expect(model.copyWith(title: '').fullName, 'Brian Mwangi');
      expect(DoctorModel.empty().fullName, '');
    });

    test('enum getters parse the stored strings', () {
      final model = DoctorModel.fromJson(doctorJson());
      expect(model.verificationStatusValue, VerificationStatus.verified);
      expect(model.languageValue, AppLanguage.en);
    });

    test('enum getters never throw on unknown values', () {
      final model = DoctorModel.fromJson(doctorJson());
      expect(
        model.copyWith(verificationStatus: 'Unknown').verificationStatusValue,
        VerificationStatus.pending,
      );
      expect(model.copyWith(language: 'fr').languageValue, AppLanguage.en);
    });
  });
}
