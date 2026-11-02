import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/alerts/data/cache/alert_cache_helper.dart';
import 'package:tabibu/features/alerts/data/datasources/alert_firebase.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_bullet_hive.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

class _MockAlertFirebase extends Mock implements AlertFirebase {}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t2 = '2026-11-02T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';

PublicAlertModel _alert(
  String uid, {
  int county = 47,
  List<int> clinicianCounties = const [47],
  bool released = true,
  bool synthetic = false,
  String stamp = _t1,
  String issued = _t1,
  bool synced = true,
}) => PublicAlertModel.empty().copyWith(
  uid: uid,
  countyId: county,
  clinicianCountyIds: clinicianCounties,
  patientsReleased: released,
  synthetic: synthetic,
  lastUpdatedAt: stamp,
  issuedAt: issued,
  synced: synced,
);

AlertClinicianBriefModel _brief(String alertUid, {String stamp = _t1}) =>
    AlertClinicianBriefModel.empty().copyWith(
      alertUid: alertUid,
      lastUpdatedAt: stamp,
    );

void main() {
  late Directory dir;
  late _MockAlertFirebase remote;
  late AlertCacheHelper helper;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(46)) {
      Hive.registerAdapter(PublicAlertHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(47)) {
      Hive.registerAdapter(AlertTextHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(48)) {
      Hive.registerAdapter(GuidanceBulletHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(49)) {
      Hive.registerAdapter(GuidanceSourceHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(AlertClinicianBriefHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(51)) {
      Hive.registerAdapter(AlertReceiptHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_alert_cache_');
    Hive.init(dir.path);
    await Hive.openBox<PublicAlertHive>(HiveHelperImpl.publicAlertsBox);
    await Hive.openBox<AlertClinicianBriefHive>(
      HiveHelperImpl.alertClinicianBriefsBox,
    );
    await Hive.openBox<AlertReceiptHive>(HiveHelperImpl.alertReceiptsBox);
    remote = _MockAlertFirebase();
    helper = AlertCacheHelper(db: DBHelperImpl(), remote: remote);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('merge guard', () {
    test('an unsynced row survives a newer cloud row', () async {
      await helper.cachePublicAlerts(
        [_alert('a1', synced: false)],
        fromCloud: false,
        demo: false,
      );
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_alert('a1', stamp: _t3)]);

      await helper.publicAlertsForCounty(countyId: 47, demo: false);

      final box = Hive.box<PublicAlertHive>(HiveHelperImpl.publicAlertsBox);
      expect(box.get('a1')?.lastUpdatedAt, _t1);
      expect(box.get('a1')?.synced, isFalse);
    });

    test('a synced row is replaced by a newer cloud row', () async {
      await helper.cachePublicAlerts(
        [_alert('a1')],
        fromCloud: true,
        demo: false,
      );
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_alert('a1', stamp: _t3)]);

      await helper.publicAlertsForCounty(countyId: 47, demo: false);

      final box = Hive.box<PublicAlertHive>(HiveHelperImpl.publicAlertsBox);
      expect(box.get('a1')?.lastUpdatedAt, _t3);
    });

    test('a synced row is kept against an older cloud row', () async {
      await helper.cachePublicAlerts(
        [_alert('a1', stamp: _t3)],
        fromCloud: true,
        demo: false,
      );
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_alert('a1')]);

      await helper.publicAlertsForCounty(countyId: 47, demo: false);

      final box = Hive.box<PublicAlertHive>(HiveHelperImpl.publicAlertsBox);
      expect(box.get('a1')?.lastUpdatedAt, _t3);
    });
  });

  group('patient scope', () {
    test('only the released county rows reach a patient', () async {
      await helper.cachePublicAlerts(
        [
          _alert('mine'),
          _alert('otherCounty', county: 48, clinicianCounties: [48]),
          _alert('unreleased', released: false),
          _alert('demo', synthetic: true),
        ],
        fromCloud: true,
        demo: true,
      );
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect(
        (await helper.publicAlertsForCounty(
          countyId: 47,
          demo: false,
        )).map((a) => a.uid),
        ['mine'],
      );
    });

    test('a demo account also sees synthetic alerts', () async {
      await helper.cachePublicAlerts(
        [_alert('mine'), _alert('demo', synthetic: true)],
        fromCloud: true,
        demo: true,
      );
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect(
        (await helper.publicAlertsForCounty(
          countyId: 47,
          demo: true,
        )).map((a) => a.uid),
        unorderedEquals(['mine', 'demo']),
      );
    });

    test('synthetic rows are never stored for a non-demo sync', () async {
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer(
        (_) async => [_alert('mine'), _alert('demo', synthetic: true)],
      );

      await helper.publicAlertsForCounty(countyId: 47, demo: false);

      final box = Hive.box<PublicAlertHive>(HiveHelperImpl.publicAlertsBox);
      expect(box.get('demo'), isNull);
      expect(box.get('mine'), isNotNull);
    });

    test('an unknown county reads nothing', () async {
      await helper.cachePublicAlerts(
        [_alert('mine')],
        fromCloud: true,
        demo: false,
      );

      expect(
        await helper.publicAlertsForCounty(countyId: 0, demo: false),
        isEmpty,
      );
      verifyNever(
        () => remote.fetchPatientPublicAlerts(
          countyId: any(named: 'countyId'),
          cursor: any(named: 'cursor'),
        ),
      );
    });
  });

  group('clinician scope', () {
    test('neighbouring counties and unreleased rows are included', () async {
      await helper.cachePublicAlerts(
        [
          _alert('home', clinicianCounties: [47]),
          _alert('neighbour', county: 48, clinicianCounties: [47, 48]),
          _alert('far', county: 49, clinicianCounties: [49]),
          _alert('unreleased', released: false),
          _alert('demo', synthetic: true),
        ],
        fromCloud: true,
        demo: true,
      );
      when(
        () => remote.fetchClinicianPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect(
        (await helper.publicAlertsForClinician(
          countyId: 47,
          demo: false,
        )).map((a) => a.uid),
        unorderedEquals(['home', 'neighbour', 'unreleased']),
      );
    });
  });

  group('remote fails', () {
    test('without a cache it rethrows', () async {
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.serviceUnavailable);
      when(
        () => remote.fetchClinicianPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      await expectLater(
        helper.publicAlertsForCounty(countyId: 47, demo: false),
        throwsA(AppError.serviceUnavailable),
      );
      await expectLater(
        helper.publicAlertsForClinician(countyId: 47, demo: false),
        throwsA(AppError.noInternet),
      );
    });

    test('a refusal rethrows even with a cache', () async {
      await helper.cachePublicAlerts(
        [_alert('mine')],
        fromCloud: true,
        demo: false,
      );
      when(
        () => remote.fetchPatientPublicAlerts(
          countyId: 47,
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.publicAlertsForCounty(countyId: 47, demo: false),
        throwsA(AppError.permissionDenied),
      );
    });

    test('an explicit since overrides the cursor', () async {
      when(
        () => remote.fetchClinicianPublicAlerts(countyId: 47, cursor: 'custom'),
      ).thenAnswer((_) async => <PublicAlertModel>[]);

      await helper.publicAlertsForClinician(
        countyId: 47,
        demo: false,
        since: 'custom',
      );

      verify(
        () => remote.fetchClinicianPublicAlerts(countyId: 47, cursor: 'custom'),
      ).called(1);
    });
  });

  group('cursors', () {
    test('each role trails its own newest cached row by a day', () async {
      await helper.cachePublicAlerts(
        [
          _alert('mine', stamp: _t2),
          _alert('unreleased', released: false, stamp: _t3),
        ],
        fromCloud: true,
        demo: false,
      );

      // The patient cursor sees released rows only.
      expect(await helper.patientAlertsCursor(47), _t1);
      expect(await helper.clinicianAlertsCursor(47), _t2);
      expect(await helper.patientAlertsCursor(0), isNull);
    });
  });

  group('brief', () {
    test('remote first, then the cache', () async {
      when(
        () => remote.fetchClinicianBrief('a1'),
      ).thenAnswer((_) async => _brief('a1', stamp: _t2));

      final brief = await helper.briefFor(alertUid: 'a1');

      expect(brief?.alertUid, 'a1');
      expect(brief?.synced, isTrue);

      when(
        () => remote.fetchClinicianBrief('a1'),
      ).thenThrow(AppError.noInternet);
      expect((await helper.briefFor(alertUid: 'a1'))?.alertUid, 'a1');
    });

    test('without a cache it rethrows; a miss reads as absent', () async {
      when(
        () => remote.fetchClinicianBrief('a1'),
      ).thenThrow(AppError.serviceUnavailable);
      await expectLater(
        helper.briefFor(alertUid: 'a1'),
        throwsA(AppError.serviceUnavailable),
      );

      when(
        () => remote.fetchClinicianBrief('a1'),
      ).thenAnswer((_) async => null);
      expect(await helper.briefFor(alertUid: 'a1'), isNull);
      expect(await helper.briefFor(alertUid: ''), isNull);
    });

    test('a brief merge keeps the newer row', () async {
      await helper.cacheBriefs([_brief('a1', stamp: _t3)], fromCloud: true);
      await helper.cacheBriefs([_brief('a1')], fromCloud: true);
      when(
        () => remote.fetchClinicianBrief('a1'),
      ).thenThrow(AppError.noInternet);

      expect((await helper.briefFor(alertUid: 'a1'))?.lastUpdatedAt, _t3);
    });
  });

  group('receipts', () {
    test('a read is recorded locally', () async {
      expect(await helper.receiptFor(alertUid: 'a1'), isNull);

      final receipt = await helper.markRead(alertUid: 'a1');

      expect(receipt.alertUid, 'a1');
      expect(receipt.readAt, isNotEmpty);
      expect(receipt.synced, isTrue);
      expect((await helper.receiptFor(alertUid: 'a1'))?.readAt, receipt.readAt);
      verifyNever(() => remote.fetchPublicAlert(any()));
    });

    test('receipts reject an empty id', () async {
      expect(await helper.receiptFor(alertUid: ''), isNull);
      await expectLater(
        helper.markRead(alertUid: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('approver queue', () {
    test('the working records are never referenced, let alone cached', () {
      final source = File(
        'lib/features/alerts/data/cache/alert_cache_helper.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('models/alert_model.dart')));
      expect(source, isNot(contains('models/alert_signal.dart')));
      expect(source, isNot(contains(RegExp(r'\bAlertModel\b'))));
      expect(source, isNot(contains(RegExp(r'\bAlertSignalModel\b'))));
    });
  });
}
