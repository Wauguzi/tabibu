import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// A secure store backed by a map, so key rotation can be observed.
_MockSecureStorage _storage(Map<String, String> values) {
  final storage = _MockSecureStorage();
  when(
    () => storage.read(key: any(named: 'key')),
  ).thenAnswer((i) async => values[i.namedArguments[#key] as String]);
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((i) async {
    values[i.namedArguments[#key] as String] =
        i.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key'))).thenAnswer((i) async {
    values.remove(i.namedArguments[#key] as String);
  });
  return storage;
}

PatientModel _patient(
  String id, {
  String uid = '',
  List<String> doctorUids = const [],
  String lastUpdatedAt = '2026-10-27T09:00:00.000Z',
  bool synced = true,
  String firstName = 'Amina',
}) => PatientModel.empty().copyWith(
  patientId: id,
  uid: uid,
  doctorUids: doctorUids,
  firstName: firstName,
  lastUpdatedAt: lastUpdatedAt,
  synced: synced,
);

void main() {
  late Directory dir;
  late Map<String, String> secrets;

  HiveHelperImpl helper([FlutterSecureStorage? storage]) =>
      HiveHelperImpl.withInit(
        initHive: () async => Hive.init(dir.path),
        dbHelper: DBHelperImpl(),
        secureStorage: storage ?? _storage(secrets),
      );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('tabibu_hive_');
    secrets = {};
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('initBoxes', () {
    test('creates a 32-byte key once and reuses it', () async {
      final first = helper();
      await first.initBoxes();
      final key = secrets['hiveKey'];
      expect(key, isNotNull);
      await first.cachePatients([_patient('p1', uid: 'u1')], fromCloud: true);
      await Hive.close();

      final second = helper();
      await second.initBoxes();
      expect(secrets['hiveKey'], key);
      expect((await second.getCachedOwnPatientRecord('u1'))?.patientId, 'p1');
    });

    test('rotates an unreadable key instead of failing', () async {
      final storage = _storage(secrets);
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenThrow(PlatformException(code: 'BadPadding'));
      final hive = helper(storage);
      await hive.initBoxes();
      expect(secrets['hiveKey'], isNotNull);
      expect(await hive.getCachedPractitioners(), isEmpty);
    });

    test('treats the reset sentinel as no key', () async {
      secrets['hiveKey'] = 'Data has been reset';
      await helper().initBoxes();
      expect(secrets['hiveKey'], isNot('Data has been reset'));
    });

    test('recreates boxes the stored key cannot open', () async {
      final first = helper();
      await first.initBoxes();
      await first.cachePatients([_patient('p1', uid: 'u1')], fromCloud: true);
      await Hive.close();

      // A different key than the one the boxes were written with.
      secrets['hiveKey'] = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
      final second = helper();
      await second.initBoxes();
      expect(await second.getCachedOwnPatientRecord('u1'), isNull);
    });
  });

  group('clearOnSignOut', () {
    test(
      'drops every cached row, rotates the key, keeps preferences',
      () async {
        final hive = helper();
        await hive.initBoxes();
        final before = secrets['hiveKey'];
        await hive.updateLanguage(languageString: 'sw');
        await hive.cachePatients([_patient('p1', uid: 'u1')], fromCloud: true);
        await hive.cacheDoctorProfile(
          DoctorModel.empty().copyWith(uid: 'd1'),
          fromCloud: true,
        );
        await hive.cachePractitioners([
          PractitionerModel.empty().copyWith(uid: 'd1'),
        ], fromCloud: true);

        await hive.clearOnSignOut();

        expect(secrets['hiveKey'], isNot(before));
        expect((await hive.getCachedOnboarding())?.languageString, 'sw');
        expect(await hive.getCachedOwnPatientRecord('u1'), isNull);
        // Gone from disk, not only from the open box: reopen and look again.
        await Hive.close();
        final reopened = helper();
        await reopened.initBoxes();
        expect(await reopened.getCachedOwnPatientRecord('u1'), isNull);
        expect(await hive.getCachedDoctorProfile('d1'), isNull);
        expect(await hive.getCachedPractitioners(), isEmpty);
      },
    );
  });

  group('scopeTo', () {
    test("wipes another person's cache before the first read", () async {
      final hive = helper();
      await hive.initBoxes();
      await hive.scopeTo('u1');
      await hive.cachePatients([_patient('p1', uid: 'u1')], fromCloud: true);

      // u2 signs in without u1 having signed out.
      await hive.scopeTo('u2');
      expect(await hive.getCachedOwnPatientRecord('u1'), isNull);
      expect(secrets['hiveOwnerUid'], 'u2');
    });

    test("keeps the same person's cache", () async {
      final hive = helper();
      await hive.initBoxes();
      await hive.scopeTo('u1');
      await hive.cachePatients([_patient('p1', uid: 'u1')], fromCloud: true);
      await hive.scopeTo('u1');
      expect((await hive.getCachedOwnPatientRecord('u1'))?.patientId, 'p1');
    });

    test('a sign-out leaves the cache unowned', () async {
      final hive = helper();
      await hive.initBoxes();
      await hive.scopeTo('u1');
      await hive.clearOnSignOut();
      expect(secrets.containsKey('hiveOwnerUid'), isFalse);
    });
  });

  group('cachePatients', () {
    late HiveHelperImpl hive;

    setUp(() async {
      hive = helper();
      await hive.initBoxes();
    });

    test('a cloud row never replaces an unsynced local edit', () async {
      await hive.cachePatients([
        _patient('p1', uid: 'u1', firstName: 'Local', synced: false),
      ], fromCloud: false);
      await hive.cachePatients([
        _patient(
          'p1',
          uid: 'u1',
          firstName: 'Cloud',
          lastUpdatedAt: '2026-10-28T09:00:00.000Z',
        ),
      ], fromCloud: true);
      expect((await hive.getCachedOwnPatientRecord('u1'))?.firstName, 'Local');
    });

    test('an older cloud row does not replace a newer one', () async {
      await hive.cachePatients([
        _patient(
          'p1',
          uid: 'u1',
          firstName: 'Newer',
          lastUpdatedAt: '2026-10-28T09:00:00.000Z',
        ),
      ], fromCloud: true);
      await hive.cachePatients([
        _patient('p1', uid: 'u1', firstName: 'Older'),
      ], fromCloud: true);
      expect((await hive.getCachedOwnPatientRecord('u1'))?.firstName, 'Newer');
    });

    test('a cloud row is stored as synced', () async {
      await hive.cachePatients([
        _patient('p1', uid: 'u1', synced: false),
      ], fromCloud: true);
      expect((await hive.getCachedOwnPatientRecord('u1'))?.synced, isTrue);
    });
  });

  group('scoped reads', () {
    late HiveHelperImpl hive;

    setUp(() async {
      hive = helper();
      await hive.initBoxes();
      await hive.cachePatients([
        _patient('p1', uid: 'u1', doctorUids: ['d1']),
        _patient('p2', doctorUids: ['d1', 'd2']),
        _patient('p3', doctorUids: ['d2']),
      ], fromCloud: true);
    });

    test('a patient reads only the record carrying their uid', () async {
      expect((await hive.getCachedOwnPatientRecord('u1'))?.patientId, 'p1');
      expect(await hive.getCachedOwnPatientRecord('u2'), isNull);
      // Unregistered records have uid '', which must match nobody.
      expect(await hive.getCachedOwnPatientRecord(''), isNull);
    });

    test("a doctor reads only their care team's patients", () async {
      expect(
        (await hive.getCachedCarePatients('d1')).map((p) => p.patientId),
        unorderedEquals(['p1', 'p2']),
      );
      expect(await hive.getCachedCarePatients('d3'), isEmpty);
      expect(await hive.getCachedCarePatients(''), isEmpty);
    });

    test('the care-list cursor starts a day before the newest row', () async {
      expect(await hive.carePatientsCursor('d1'), '2026-10-26T09:00:00.000Z');
      expect(await hive.carePatientsCursor('d3'), isNull);
    });
  });
}
