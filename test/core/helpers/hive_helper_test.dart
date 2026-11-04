import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_hive.dart';
import 'package:tabibu/features/appointments/data/models/appointment_intake_hive.dart';
import 'package:tabibu/features/cases/data/models/case_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_hive.dart';
import 'package:tabibu/features/cases/data/models/case_payment_hive.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_hive.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_hive.dart';
import 'package:tabibu/features/reports/data/models/preread_score_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_hive.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_hive.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_hive.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

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

    test('a row written after a sign-out is wiped before the next person '
        'reads', () async {
      final hive = helper();
      await hive.initBoxes();
      await hive.scopeTo('u1');
      await hive.clearOnSignOut();
      // A read that started before the sign-out lands after it.
      await hive.cachePatients([_patient('p1', uid: 'u1')], fromCloud: true);

      await hive.scopeTo('u2');
      expect(await hive.getCachedOwnPatientRecord('u1'), isNull);
      expect(secrets['hiveOwnerUid'], 'u2');
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

  group('record boxes', () {
    const eagerOpens = <Type, String>{
      // Cases.
      CaseHive: HiveHelperImpl.casesBox,
      CaseLogEntryHive: HiveHelperImpl.caseLogsBox,
      CasePaymentHive: HiveHelperImpl.casePaymentsBox,
      ShareCodeHive: HiveHelperImpl.shareCodesBox,
      RiskCheckHive: HiveHelperImpl.riskChecksBox,
      NotesTranslationHive: HiveHelperImpl.notesTranslationsBox,
      // Reports.
      PathologyReportHive: HiveHelperImpl.pathologyReportsBox,
      ReportDraftHive: HiveHelperImpl.reportDraftsBox,
      PrereadScoreHive: HiveHelperImpl.prereadScoresBox,
      WorklistEntryHive: HiveHelperImpl.worklistBox,
      ReportTextApprovedHive: HiveHelperImpl.reportTextsBox,
      // Appointments.
      AppointmentHive: HiveHelperImpl.appointmentsBox,
      AppointmentIntakeHive: HiveHelperImpl.appointmentIntakesBox,
      // Conversations.
      ConversationHive: HiveHelperImpl.conversationsBox,
      ConversationCursorHive: HiveHelperImpl.conversationCursorsBox,
      MessageTranscriptHive: HiveHelperImpl.messageTranscriptsBox,
      // Notifications.
      NotificationHive: HiveHelperImpl.notificationsBox,
      // Alerts.
      PublicAlertHive: HiveHelperImpl.publicAlertsBox,
      AlertClinicianBriefHive: HiveHelperImpl.alertClinicianBriefsBox,
      AlertReceiptHive: HiveHelperImpl.alertReceiptsBox,
    };

    test('opens all 20 record boxes eagerly, messages stays lazy', () async {
      await helper().initBoxes();
      for (final name in eagerOpens.values) {
        expect(Hive.isBoxOpen(name), isTrue, reason: name);
      }
      expect(Hive.isBoxOpen(HiveHelperImpl.messagesBoxName), isFalse);
    });

    test('record box contents are unreadable without the cipher', () async {
      await helper().initBoxes();
      await Hive.box<ShareCodeHive>(
        HiveHelperImpl.shareCodesBox,
      ).put('code-1', ShareCodeHive.fromModel(ShareCodeModel.empty()));
      await Hive.close();

      await expectLater(
        Hive.openBox<ShareCodeHive>(HiveHelperImpl.shareCodesBox),
        throwsA(isA<HiveError>()),
      );
    });

    test('messagesBox() opens lazily and caches the future', () async {
      final hive = helper();
      await hive.initBoxes();
      final first = hive.messagesBox();
      expect(identical(first, hive.messagesBox()), isTrue);
      final box = await first;
      expect(box.name, HiveHelperImpl.messagesBoxName);
      expect(Hive.isBoxOpen(HiveHelperImpl.messagesBoxName), isTrue);
    });

    test('clearOnSignOut deletes every record box, opened or not', () async {
      final hive = helper();
      await hive.initBoxes();
      // Open messages lazily but close one eager box again: deletion must
      // reach boxes whatever their open state.
      await hive.messagesBox();
      await Hive.box<CaseHive>(HiveHelperImpl.casesBox).close();
      expect(Hive.isBoxOpen(HiveHelperImpl.casesBox), isFalse);

      await hive.clearOnSignOut();

      const messages = HiveHelperImpl.messagesBoxName;
      final names = [...eagerOpens.values, messages];
      for (final name in names) {
        // clearOnSignOut reopens the eager boxes empty under a fresh key.
        final reopened = name != messages;
        expect(Hive.isBoxOpen(name), reopened, reason: name);
        expect(await Hive.boxExists(name), reopened, reason: name);
      }
      expect(Hive.box<CaseHive>(HiveHelperImpl.casesBox), isEmpty);
    });

    test('DBHelper.deleteAll deletes each record box from disk', () async {
      await helper().initBoxes();
      final db = DBHelperImpl();
      for (final entry in eagerOpens.entries) {
        await db.deleteAll({entry.key: entry.value});
        expect(await Hive.boxExists(entry.value), isFalse, reason: entry.value);
      }
      await db.deleteAll({MessageHive: HiveHelperImpl.messagesBoxName});
      expect(await Hive.boxExists(HiveHelperImpl.messagesBoxName), isFalse);
    });

    test('DBHelper.deleteAll closes an opened lazy messages box', () async {
      final hive = helper();
      await hive.initBoxes();
      await hive.messagesBox();
      expect(Hive.isBoxOpen(HiveHelperImpl.messagesBoxName), isTrue);

      await DBHelperImpl().deleteAll({
        MessageHive: HiveHelperImpl.messagesBoxName,
      });

      expect(Hive.isBoxOpen(HiveHelperImpl.messagesBoxName), isFalse);
      expect(await Hive.boxExists(HiveHelperImpl.messagesBoxName), isFalse);
    });

    test('DBHelper.deleteAll of an unknown type throws StateError', () async {
      await helper().initBoxes();
      await expectLater(
        DBHelperImpl().deleteAll({Object: 'someBox'}),
        throwsA(isA<StateError>()),
      );
    });

    group('media cache', () {
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      late Directory fakeCache;

      setUp(() {
        fakeCache = Directory.systemTemp.createTempSync('tabibu_cache_');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'getApplicationCacheDirectory') {
                return fakeCache.path;
              }
              return null;
            });
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        fakeCache.deleteSync(recursive: true);
      });

      test('clearOnSignOut deletes the tabibu_media directory', () async {
        final media = Directory('${fakeCache.path}/tabibu_media')
          ..createSync(recursive: true);
        File('${media.path}/clip.mp4').writeAsStringSync('bytes');

        await helper().initBoxes();
        await helper().clearOnSignOut();

        expect(media.existsSync(), isFalse);
        expect(fakeCache.existsSync(), isTrue);
      });

      test('clearOnSignOut succeeds when tabibu_media is missing', () async {
        await helper().initBoxes();
        await helper().clearOnSignOut();
      });
    });

    group('voice pending', () {
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      late Directory fakeSupport;

      setUp(() {
        fakeSupport = Directory.systemTemp.createTempSync('tabibu_support_');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'getApplicationSupportDirectory') {
                return fakeSupport.path;
              }
              if (call.method == 'getApplicationCacheDirectory') {
                return fakeSupport.path;
              }
              return null;
            });
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        if (fakeSupport.existsSync()) {
          fakeSupport.deleteSync(recursive: true);
        }
      });

      test('clearOnSignOut wipes voice_pending', () async {
        final pending = Directory('${fakeSupport.path}/voice_pending')
          ..createSync(recursive: true);
        File('${pending.path}/voice_1.m4a').writeAsStringSync('bytes');

        await helper().initBoxes();
        await helper().clearOnSignOut();

        expect(pending.existsSync(), isFalse);
      });

      test('scopeTo another uid also wipes voice_pending', () async {
        await helper().initBoxes();
        await helper().scopeTo('u1');
        final pending = Directory('${fakeSupport.path}/voice_pending')
          ..createSync(recursive: true);
        File('${pending.path}/voice_2.m4a').writeAsStringSync('bytes');
        await helper().scopeTo('u2');

        expect(
          Directory('${fakeSupport.path}/voice_pending').existsSync(),
          isFalse,
        );
      });
    });
  });
}
