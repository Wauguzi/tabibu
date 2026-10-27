import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';

Map<String, dynamic> patientJson() => {
  'patientId': 'patient-1',
  'uid': 'uid-1',
  'isRegistered': true,
  'createdByUid': 'uid-1',
  'firstName': 'Jane',
  'middleName': 'Wanjiru',
  'lastName': 'Otieno',
  'sex': 'Female',
  'dateOfBirth': '1990-06-15',
  'phoneNumber': '+254712345678',
  'email': 'jane@example.com',
  'profilePictureUrl': 'https://example.com/pic.jpg',
  'county': 'Nairobi',
  'subCounty': 'Kibra',
  'geohash': 'kzf0eg70h',
  'doctorUids': ['doctor-1'],
  'fcmTokens': ['token-1'],
  'language': 'sw',
  'receiveNotifications': true,
  'casesReported': 2,
  'appointmentsBooked': 3,
  'createdAt': '2026-10-20T10:00:00.000Z',
  'lastUpdatedAt': '2026-10-21T10:00:00.000Z',
};

void main() {
  group('PatientModel', () {
    test('empty returns every field at its default', () {
      final model = PatientModel.empty();
      expect(model.patientId, '');
      expect(model.uid, '');
      expect(model.isRegistered, isFalse);
      expect(model.doctorUids, isEmpty);
      expect(model.fcmTokens, isEmpty);
      expect(model.casesReported, 0);
      expect(model.appointmentsBooked, 0);
      expect(model.receiveNotifications, isFalse);
      expect(model.synced, isTrue);
    });

    test('fromJson parses a complete document', () {
      final model = PatientModel.fromJson(patientJson());
      expect(model.patientId, 'patient-1');
      expect(model.isRegistered, isTrue);
      expect(model.doctorUids, ['doctor-1']);
      expect(model.casesReported, 2);
      expect(model.synced, isTrue);
    });

    test('fromJson round-trips through toJson', () {
      final json = patientJson();
      expect(PatientModel.fromJson(json).toJson(), json);
    });

    test('toJson never emits synced', () {
      final model = PatientModel.fromJson(patientJson());
      expect(model.toJson().containsKey('synced'), isFalse);
      expect(
        model.copyWith(synced: false).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('fullName joins the non-empty parts', () {
      final model = PatientModel.fromJson(patientJson());
      expect(model.fullName, 'Jane Wanjiru Otieno');
      expect(model.copyWith(middleName: '').fullName, 'Jane Otieno');
      expect(PatientModel.empty().fullName, '');
    });

    test('enum getters parse the stored strings', () {
      final model = PatientModel.fromJson(patientJson());
      expect(model.sexValue, Sex.female);
      expect(model.languageValue, AppLanguage.sw);
    });

    test('enum getters never throw on unknown values', () {
      final model = PatientModel.fromJson(patientJson());
      expect(model.copyWith(sex: 'Other').sexValue, isNull);
      expect(model.copyWith(language: 'fr').languageValue, AppLanguage.en);
    });

    group('ageOn', () {
      test('counts whole years around the birthday', () {
        final model = PatientModel.fromJson(patientJson());
        expect(model.ageOn(DateTime(2026, 6, 14)), 35);
        expect(model.ageOn(DateTime(2026, 6, 15)), 36);
        expect(model.ageOn(DateTime(2026, 6, 16)), 36);
      });

      test('28 February', () {
        final model = PatientModel.fromJson(
          patientJson(),
        ).copyWith(dateOfBirth: '2000-02-28');
        expect(model.ageOn(DateTime(2025, 2, 27)), 24);
        expect(model.ageOn(DateTime(2025, 2, 28)), 25);
      });

      test('29 February birthdays in non-leap years', () {
        final model = PatientModel.fromJson(
          patientJson(),
        ).copyWith(dateOfBirth: '2000-02-29');
        expect(model.ageOn(DateTime(2024, 2, 29)), 24);
        expect(model.ageOn(DateTime(2025, 2, 28)), 24);
        expect(model.ageOn(DateTime(2025, 3)), 25);
      });

      test('an invalid date throws without the value', () {
        final model = PatientModel.fromJson(
          patientJson(),
        ).copyWith(dateOfBirth: 'not-a-date');
        expect(
          () => model.ageOn(DateTime(2026)),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              isNot(contains('not-a-date')),
            ),
          ),
        );
      });
    });
  });
}
