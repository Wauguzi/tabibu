import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/practitioners/data/cache/practitioner_cache_helper.dart';
import 'package:tabibu/features/practitioners/data/datasources/practitioner_firebase.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

class _MockPractitionerFirebase extends Mock implements PractitionerFirebase {}

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';

PractitionerModel _doctor(
  String uid, {
  String stamp = _t1,
  bool synced = true,
  String firstName = 'A',
}) => PractitionerModel.empty().copyWith(
  uid: uid,
  firstName: firstName,
  lastUpdatedAt: stamp,
  synced: synced,
);

void main() {
  late Directory dir;
  late _MockPractitionerFirebase remote;
  late HiveHelperImpl hive;
  late PractitionerCacheHelper helper;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PractitionerHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_directory_cache_');
    Hive.init(dir.path);
    await Hive.openBox<PractitionerHive>(HiveHelperImpl.practitionersBox);
    remote = _MockPractitionerFirebase();
    hive = HiveHelperImpl.withInit(
      initHive: () async {},
      dbHelper: DBHelperImpl(),
      secureStorage: _MockSecureStorage(),
    );
    helper = PractitionerCacheHelper(hive: hive, remote: remote);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('syncPractitioners', () {
    test('merges the delta and returns the cache', () async {
      await hive.cachePractitioners([_doctor('d1')], fromCloud: true);
      when(() => remote.fetchDelta(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => [_doctor('d1', stamp: _t3, firstName: 'Brian')],
      );

      final rows = await helper.syncPractitioners();

      expect(rows, hasLength(1));
      expect(rows.single.firstName, 'Brian');
      expect(rows.single.lastUpdatedAt, _t3);
      expect(rows.single.synced, isTrue);
    });

    test('keeps rows the delta omits', () async {
      await hive.cachePractitioners([
        _doctor('d1'),
        _doctor('d2', firstName: 'B'),
      ], fromCloud: true);
      when(
        () => remote.fetchDelta(cursor: any(named: 'cursor')),
      ).thenAnswer((_) async => [_doctor('d1', stamp: _t3)]);

      final rows = await helper.syncPractitioners();

      expect(rows.map((p) => p.uid).toSet(), {'d1', 'd2'});
    });

    test('offline with a cache returns the cache', () async {
      await hive.cachePractitioners([_doctor('d1')], fromCloud: true);
      when(
        () => remote.fetchDelta(cursor: any(named: 'cursor')),
      ).thenThrow(AppError.noInternet);

      expect((await helper.syncPractitioners()).map((p) => p.uid), ['d1']);
    });

    test('offline with an empty cache rethrows', () async {
      when(
        () => remote.fetchDelta(cursor: any(named: 'cursor')),
      ).thenThrow(AppError.serviceUnavailable);

      await expectLater(
        helper.syncPractitioners(),
        throwsA(AppError.serviceUnavailable),
      );
    });

    test('a refusal rethrows even with a cache', () async {
      await hive.cachePractitioners([_doctor('d1')], fromCloud: true);
      when(
        () => remote.fetchDelta(cursor: any(named: 'cursor')),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.syncPractitioners(),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  group('getPractitioner', () {
    test('returns the cached row without fetching', () async {
      await hive.cachePractitioners([_doctor('d1')], fromCloud: true);

      expect((await helper.getPractitioner('d1'))?.uid, 'd1');
      verifyNever(() => remote.fetchPractitioner(any()));
    });

    test('falls back to a fetch and caches it', () async {
      when(
        () => remote.fetchPractitioner('d1'),
      ).thenAnswer((_) async => _doctor('d1', firstName: 'Brian'));

      final row = await helper.getPractitioner('d1');

      expect(row?.firstName, 'Brian');
      expect((await helper.getPractitioners()).single.uid, 'd1');
    });

    test('returns null when the row is missing remote and local', () async {
      when(
        () => remote.fetchPractitioner('gone'),
      ).thenAnswer((_) async => null);

      expect(await helper.getPractitioner('gone'), isNull);
      expect(await helper.getPractitioner(''), isNull);
      verifyNever(() => remote.fetchPractitioner(''));
    });
  });
}
