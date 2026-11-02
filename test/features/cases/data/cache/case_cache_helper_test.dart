import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/datasources/share_code_firebase.dart';
import 'package:tabibu/features/cases/data/models/case_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/case_payment_hive.dart';
import 'package:tabibu/features/cases/data/models/case_payment_model.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_hive.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';
import 'package:tabibu/features/cases/data/models/slide_image_hive.dart';

class _MockCaseFirebase extends Mock implements CaseFirebase {}

class _MockShareCodeFirebase extends Mock implements ShareCodeFirebase {}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';

CaseModel _case(
  String uid, {
  List<String> participants = const ['doc1', 'pat1'],
  String doctorUid = 'doc1',
  String patientUid = 'pat1',
  String pathologistUid = 'path1',
  String stamp = _t1,
  bool synced = true,
  String notes = 'n',
}) => CaseModel.empty().copyWith(
  uid: uid,
  participantUids: participants,
  doctorUid: doctorUid,
  patientUid: patientUid,
  pathologistUid: pathologistUid,
  lastUpdatedAt: stamp,
  synced: synced,
  clinicalNotes: notes,
  currentStage: 'OrderCreated',
);

void main() {
  late Directory dir;
  late _MockCaseFirebase cases;
  late _MockShareCodeFirebase shares;
  late CaseCacheHelper helper;
  late DBHelper db;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(OrderedTestHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(SlideImageHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CaseHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(CaseLogEntryHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(CasePaymentHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(ShareCodeHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(RiskCheckHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(NotesTranslationHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_case_cache_');
    Hive.init(dir.path);
    await Hive.openBox<CaseHive>(HiveHelperImpl.casesBox);
    await Hive.openBox<CaseLogEntryHive>(HiveHelperImpl.caseLogsBox);
    await Hive.openBox<CasePaymentHive>(HiveHelperImpl.casePaymentsBox);
    await Hive.openBox<ShareCodeHive>(HiveHelperImpl.shareCodesBox);
    await Hive.openBox<RiskCheckHive>(HiveHelperImpl.riskChecksBox);
    await Hive.openBox<NotesTranslationHive>(
      HiveHelperImpl.notesTranslationsBox,
    );
    cases = _MockCaseFirebase();
    shares = _MockShareCodeFirebase();
    db = DBHelperImpl();
    helper = CaseCacheHelper(db: db, cases: cases, shares: shares);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('merge guard', () {
    test('an unsynced row survives a newer cloud row', () async {
      await helper.cacheCases(
        [_case('c1', synced: false)],
        fromCloud: false,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_case('c1', stamp: _t3, notes: 'cloud')]);

      await helper.syncCases('doc1');

      final rows = await helper.getCases('doc1');
      expect(rows.single.clinicalNotes, 'n');
      expect(rows.single.synced, isFalse);
    });

    test('a synced row is replaced by a newer cloud row', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_case('c1', stamp: _t3, notes: 'cloud')]);

      await helper.syncCases('doc1');

      expect((await helper.getCases('doc1')).single.clinicalNotes, 'cloud');
    });
  });

  group('scope', () {
    test('another uid never sees the case', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      expect(await helper.getCases('stranger'), isEmpty);
    });
  });

  group('remote fails', () {
    test('with a cache it returns the cache', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect((await helper.syncCases('doc1')).map((c) => c.uid), ['c1']);
    });

    test('without a cache it rethrows', () async {
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      await expectLater(
        helper.syncCases('doc1'),
        throwsA(AppError.serviceUnavailable),
      );
    });
  });

  group('patient device rules', () {
    test(
      'a non-patientVisible log entry is never cached for a patient',
      () async {
        await helper.cacheLogEntries(
          [
            CaseLogEntryModel.empty().copyWith(
              uid: '0001',
              caseUid: 'c1',
              seq: 1,
              patientVisible: false,
              lastUpdatedAt: _t1,
            ),
            CaseLogEntryModel.empty().copyWith(
              uid: '0002',
              caseUid: 'c1',
              seq: 2,
              patientVisible: true,
              lastUpdatedAt: _t1,
            ),
          ],
          fromCloud: true,
          role: Role.patient,
        );

        final rows = await helper.getLog('c1', role: Role.patient);
        expect(rows.map((e) => e.seq), [2]);
      },
    );

    test('payment for another case role is never returned', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      await helper.cachePayment(
        CasePaymentModel.empty().copyWith(
          caseUid: 'c1',
          method: 'Cash',
          lastUpdatedAt: _t1,
        ),
        fromCloud: true,
        viewerUid: 'doc1',
        caseDoc: _case('c1'),
      );

      expect(await helper.getPayment('c1', 'stranger'), isNull);
      expect(await helper.getPayment('c1', 'doc1'), isNotNull);
    });

    test('a risk check is never cached for a non-doctor', () async {
      await helper.cacheRiskCheck(
        RiskCheckModel.empty().copyWith(caseUid: 'c1', lastUpdatedAt: _t1),
        fromCloud: true,
        doctorUid: 'path1',
        caseDoc: _case('c1'),
      );
      expect(await helper.getRiskCheck('c1', 'path1'), isNull);
    });

    test('a notes translation is never cached for a patient', () async {
      await helper.cacheNotesTranslation(
        NotesTranslationModel.empty().copyWith(
          caseUid: 'c1',
          lastUpdatedAt: _t1,
        ),
        fromCloud: true,
        viewerUid: 'pat1',
        caseDoc: _case('c1'),
      );
      expect(await helper.getNotesTranslation('c1', 'pat1'), isNull);
    });
  });

  group('share code secret', () {
    test('a share-code secret never reaches the box', () async {
      await helper.cacheShareCodeMaps([
        {
          'uid': 's1',
          'caseUid': 'c1',
          'createdByUid': 'doc1',
          'recipientUid': 'doc2',
          'code': 'SECRET99',
          'lastUpdatedAt': _t1,
        },
      ], fromCloud: true);

      final row = await db.get<ShareCodeHive>(
        HiveHelperImpl.shareCodesBox,
        's1',
      );
      expect(row, isNotNull);
      expect(row!.toModel().toJson().containsKey('code'), isFalse);
      expect(jsonEncode(row.toModel().toJson()), isNot(contains('SECRET99')));
      expect(
        CaseCacheHelper.stripShareSecret({'code': 'x', 'uid': 's1'})['code'],
        isNull,
      );
    });
  });

  group('eviction', () {
    test('leaving a case drops the case and its children', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      await helper.cachePayment(
        CasePaymentModel.empty().copyWith(caseUid: 'c1', lastUpdatedAt: _t1),
        fromCloud: true,
        viewerUid: 'doc1',
        caseDoc: _case('c1'),
      );
      await helper.cacheRiskCheck(
        RiskCheckModel.empty().copyWith(caseUid: 'c1', lastUpdatedAt: _t1),
        fromCloud: true,
        doctorUid: 'doc1',
        caseDoc: _case('c1'),
      );
      await helper.cacheLogEntries(
        [
          CaseLogEntryModel.empty().copyWith(
            caseUid: 'c1',
            seq: 1,
            patientVisible: true,
            lastUpdatedAt: _t1,
          ),
        ],
        fromCloud: true,
        role: Role.doctor,
      );
      await helper.cacheShareCodes([
        ShareCodeModel.empty().copyWith(
          uid: 's1',
          caseUid: 'c1',
          createdByUid: 'doc1',
          lastUpdatedAt: _t1,
        ),
      ], fromCloud: true);

      await helper.cacheCases(
        [
          _case('c1', participants: ['pat1']),
        ],
        fromCloud: true,
        viewerUid: 'doc1',
      );

      expect(await helper.getCases('doc1'), isEmpty);
      expect(
        await db.get<CasePaymentHive>(HiveHelperImpl.casePaymentsBox, 'c1'),
        isNull,
      );
      expect(
        await db.get<RiskCheckHive>(HiveHelperImpl.riskChecksBox, 'c1'),
        isNull,
      );
      expect(await helper.getLog('c1', role: Role.doctor), isEmpty);
      expect(await helper.getShareCodes('doc1', asCreator: true), isEmpty);
    });

    test('a full pull evicts untold cases', () async {
      await helper.cacheCases(
        [_case('c1'), _case('c2')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_case('c1', stamp: _t3, notes: 'cloud')]);

      await helper.syncCases('doc1', since: '');

      expect((await helper.getCases('doc1')).map((c) => c.uid), ['c1']);
      verifyNever(() => cases.fetchCase(any()));
    });

    test('a queued case survives a full pull', () async {
      await helper.cacheCases(
        [_case('c9', synced: false)],
        fromCloud: false,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => []);

      await helper.syncCases('doc1', since: '');

      expect((await helper.getCases('doc1')).map((c) => c.uid), ['c9']);
    });

    test('a delta refetch evicts a denied case', () async {
      await helper.cacheCases(
        [_case('c1'), _case('c2')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_case('c1', stamp: _t3)]);
      when(() => cases.fetchCase('c2')).thenThrow(AppError.permissionDenied);

      await helper.syncCases('doc1');

      expect((await helper.getCases('doc1')).map((c) => c.uid), ['c1']);
    });

    test('a delta refetch refreshes a listed case', () async {
      await helper.cacheCases(
        [_case('c1'), _case('c2')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_case('c1', stamp: _t3)]);
      when(
        () => cases.fetchCase('c2'),
      ).thenAnswer((_) async => _case('c2', stamp: _t3, notes: 'fresh'));

      await helper.syncCases('doc1');

      final rows = await helper.getCases('doc1');
      expect(rows.map((c) => c.uid), contains('c2'));
      expect(rows.firstWhere((c) => c.uid == 'c2').clinicalNotes, 'fresh');
    });

    test('a failed delta refetch keeps the case', () async {
      await helper.cacheCases(
        [_case('c1'), _case('c2')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_case('c1', stamp: _t3)]);
      when(() => cases.fetchCase('c2')).thenThrow(AppError.unknown);

      await helper.syncCases('doc1');

      expect((await helper.getCases('doc1')).map((c) => c.uid), contains('c2'));
    });

    test('a denied payment sync evicts the synced row', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      await helper.cachePayment(
        CasePaymentModel.empty().copyWith(caseUid: 'c1', lastUpdatedAt: _t1),
        fromCloud: true,
        viewerUid: 'doc1',
        caseDoc: _case('c1'),
      );
      when(() => cases.fetchPayment('c1')).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.syncPayment(caseUid: 'c1', viewerUid: 'doc1'),
        throwsA(AppError.permissionDenied),
      );
      expect(await helper.getPayment('c1', 'doc1'), isNull);
    });

    test('an unsent payment survives a denied sync', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      await helper.cachePayment(
        CasePaymentModel.empty().copyWith(
          caseUid: 'c1',
          lastUpdatedAt: _t1,
          synced: false,
        ),
        fromCloud: false,
        viewerUid: 'doc1',
        caseDoc: _case('c1'),
      );
      when(() => cases.fetchPayment('c1')).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.syncPayment(caseUid: 'c1', viewerUid: 'doc1'),
        throwsA(AppError.permissionDenied),
      );
      expect(await helper.getPayment('c1', 'doc1'), isNotNull);
    });

    test('a denied patient log sync evicts only visible rows', () async {
      await helper.cacheLogEntries(
        [
          CaseLogEntryModel.empty().copyWith(
            caseUid: 'c1',
            seq: 1,
            patientVisible: false,
            lastUpdatedAt: _t1,
          ),
          CaseLogEntryModel.empty().copyWith(
            caseUid: 'c1',
            seq: 2,
            patientVisible: true,
            lastUpdatedAt: _t1,
          ),
        ],
        fromCloud: true,
        role: Role.doctor,
      );
      when(
        () => cases.fetchPatientLog('c1'),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.syncLog(caseUid: 'c1', role: Role.patient),
        throwsA(AppError.permissionDenied),
      );
      expect(await helper.getLog('c1', role: Role.patient), isEmpty);
      expect((await helper.getLog('c1', role: Role.doctor)).map((e) => e.seq), [
        1,
      ]);
    });

    test('a full pull evicts untold share codes', () async {
      await helper.cacheShareCodes([
        ShareCodeModel.empty().copyWith(
          uid: 's1',
          caseUid: 'c1',
          createdByUid: 'doc1',
          lastUpdatedAt: _t1,
        ),
        ShareCodeModel.empty().copyWith(
          uid: 's2',
          caseUid: 'c1',
          createdByUid: 'doc1',
          lastUpdatedAt: _t1,
        ),
      ], fromCloud: true);
      when(
        () => shares.fetchCreatorDelta(
          createdByUid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer(
        (_) async => [
          ShareCodeModel.empty().copyWith(
            uid: 's1',
            caseUid: 'c1',
            createdByUid: 'doc1',
            lastUpdatedAt: _t3,
          ),
        ],
      );

      await helper.syncShareCodes(uid: 'doc1', asCreator: true, since: '');

      expect(
        (await helper.getShareCodes('doc1', asCreator: true)).map((s) => s.uid),
        ['s1'],
      );
      verifyNever(() => shares.fetchShareCode(any()));
    });

    test('a denied share refetch evicts the code', () async {
      await helper.cacheShareCodes([
        ShareCodeModel.empty().copyWith(
          uid: 's1',
          caseUid: 'c1',
          createdByUid: 'doc1',
          lastUpdatedAt: _t1,
        ),
        ShareCodeModel.empty().copyWith(
          uid: 's2',
          caseUid: 'c1',
          createdByUid: 'doc1',
          lastUpdatedAt: _t1,
        ),
      ], fromCloud: true);
      when(
        () => shares.fetchCreatorDelta(
          createdByUid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer(
        (_) async => [
          ShareCodeModel.empty().copyWith(
            uid: 's1',
            caseUid: 'c1',
            createdByUid: 'doc1',
            lastUpdatedAt: _t3,
          ),
        ],
      );
      when(
        () => shares.fetchShareCode('s2'),
      ).thenThrow(AppError.permissionDenied);

      await helper.syncShareCodes(uid: 'doc1', asCreator: true);

      expect(
        (await helper.getShareCodes('doc1', asCreator: true)).map((s) => s.uid),
        ['s1'],
      );
    });

    test('an offline full pull deletes nothing', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      await helper.cachePayment(
        CasePaymentModel.empty().copyWith(caseUid: 'c1', lastUpdatedAt: _t1),
        fromCloud: true,
        viewerUid: 'doc1',
        caseDoc: _case('c1'),
      );
      await helper.cacheLogEntries(
        [
          CaseLogEntryModel.empty().copyWith(
            caseUid: 'c1',
            seq: 1,
            patientVisible: true,
            lastUpdatedAt: _t1,
          ),
        ],
        fromCloud: true,
        role: Role.doctor,
      );
      await helper.cacheShareCodes([
        ShareCodeModel.empty().copyWith(
          uid: 's1',
          caseUid: 'c1',
          createdByUid: 'doc1',
          lastUpdatedAt: _t1,
        ),
      ], fromCloud: true);
      when(
        () => cases.fetchParticipantDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect((await helper.syncCases('doc1', since: '')).map((c) => c.uid), [
        'c1',
      ]);
      expect(
        await db.get<CasePaymentHive>(HiveHelperImpl.casePaymentsBox, 'c1'),
        isNotNull,
      );
      expect(await helper.getLog('c1', role: Role.doctor), hasLength(1));
      expect(await helper.getShareCodes('doc1', asCreator: true), hasLength(1));
    });

    test('an offline share full pull deletes nothing', () async {
      await helper.cacheShareCodes([
        ShareCodeModel.empty().copyWith(
          uid: 's1',
          caseUid: 'c1',
          createdByUid: 'doc1',
          lastUpdatedAt: _t1,
        ),
      ], fromCloud: true);
      when(
        () => shares.fetchCreatorDelta(
          createdByUid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      await helper.syncShareCodes(uid: 'doc1', asCreator: true, since: '');

      expect(
        (await helper.getShareCodes('doc1', asCreator: true)).map((s) => s.uid),
        ['s1'],
      );
    });

    test('offline single-row syncs keep their rows', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      await helper.cachePayment(
        CasePaymentModel.empty().copyWith(caseUid: 'c1', lastUpdatedAt: _t1),
        fromCloud: true,
        viewerUid: 'doc1',
        caseDoc: _case('c1'),
      );
      await helper.cacheRiskCheck(
        RiskCheckModel.empty().copyWith(caseUid: 'c1', lastUpdatedAt: _t1),
        fromCloud: true,
        doctorUid: 'doc1',
        caseDoc: _case('c1'),
      );
      await helper.cacheNotesTranslation(
        NotesTranslationModel.empty().copyWith(
          caseUid: 'c1',
          lastUpdatedAt: _t1,
        ),
        fromCloud: true,
        viewerUid: 'doc1',
        caseDoc: _case('c1'),
      );
      await helper.cacheLogEntries(
        [
          CaseLogEntryModel.empty().copyWith(
            caseUid: 'c1',
            seq: 2,
            patientVisible: true,
            lastUpdatedAt: _t1,
          ),
        ],
        fromCloud: true,
        role: Role.doctor,
      );
      when(() => cases.fetchPayment('c1')).thenThrow(AppError.noInternet);
      when(() => cases.fetchRiskCheck('c1')).thenThrow(AppError.noInternet);
      when(
        () => cases.fetchNotesTranslation('c1'),
      ).thenThrow(AppError.noInternet);
      when(() => cases.fetchPatientLog('c1')).thenThrow(AppError.noInternet);

      expect(
        await helper.syncPayment(caseUid: 'c1', viewerUid: 'doc1'),
        isNotNull,
      );
      expect(
        await helper.syncRiskCheck(caseUid: 'c1', doctorUid: 'doc1'),
        isNotNull,
      );
      expect(
        await helper.syncNotesTranslation(caseUid: 'c1', viewerUid: 'doc1'),
        isNotNull,
      );
      expect(
        await helper.syncLog(caseUid: 'c1', role: Role.patient),
        hasLength(1),
      );
      expect(await helper.getPayment('c1', 'doc1'), isNotNull);
      expect(await helper.getRiskCheck('c1', 'doc1'), isNotNull);
      expect(await helper.getNotesTranslation('c1', 'doc1'), isNotNull);
    });
  });

  group('replay', () {
    test('a refused notes edit drops for the server truth', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.updateDoctorNotes(
          caseUid: any(named: 'caseUid'),
          currentStage: any(named: 'currentStage'),
          clinicalNotes: any(named: 'clinicalNotes'),
          sampleNotes: any(named: 'sampleNotes'),
          sampleCollectedAt: any(named: 'sampleCollectedAt'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => cases.fetchCase('c1'),
      ).thenAnswer((_) async => _case('c1', stamp: _t3, notes: 'server'));

      await expectLater(
        helper.saveDoctorNotes(caseUid: 'c1', clinicalNotes: 'local'),
        throwsA(AppError.permissionDenied),
      );

      expect((await helper.getCases('doc1')).single.clinicalNotes, 'server');
      expect((await helper.getCases('doc1')).single.synced, isTrue);
    });

    test('a denied refetch evicts the case', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.updateDoctorNotes(
          caseUid: any(named: 'caseUid'),
          currentStage: any(named: 'currentStage'),
          clinicalNotes: any(named: 'clinicalNotes'),
          sampleNotes: any(named: 'sampleNotes'),
          sampleCollectedAt: any(named: 'sampleCollectedAt'),
        ),
      ).thenThrow(AppError.dataNotFound);
      when(() => cases.fetchCase('c1')).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.saveDoctorNotes(caseUid: 'c1', clinicalNotes: 'local'),
        throwsA(AppError.dataNotFound),
      );

      expect(await helper.getCases('doc1'), isEmpty);
    });

    test('offline notes stay queued', () async {
      await helper.cacheCases(
        [_case('c1')],
        fromCloud: true,
        viewerUid: 'doc1',
      );
      when(
        () => cases.updateDoctorNotes(
          caseUid: any(named: 'caseUid'),
          currentStage: any(named: 'currentStage'),
          clinicalNotes: any(named: 'clinicalNotes'),
          sampleNotes: any(named: 'sampleNotes'),
          sampleCollectedAt: any(named: 'sampleCollectedAt'),
        ),
      ).thenThrow(AppError.noInternet);

      final edited = await helper.saveDoctorNotes(
        caseUid: 'c1',
        clinicalNotes: 'queued',
      );
      expect(edited.synced, isFalse);
      expect(edited.clinicalNotes, 'queued');
    });
  });
}
