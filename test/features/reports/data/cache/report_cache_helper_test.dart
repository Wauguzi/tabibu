import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_hive.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_hive.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/preread_score_hive.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_hive.dart';
import 'package:tabibu/features/reports/data/models/report_response_hive.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_hive.dart';

class _MockReportFirebase extends Mock implements ReportFirebase {}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';

PathologyReportModel _report(
  String uid, {
  String caseUid = 'c1',
  List<String> readers = const ['doc1', 'pat1'],
  bool released = false,
  String stamp = _t1,
  bool synced = true,
  String diagnosis = 'd',
}) => PathologyReportModel.empty().copyWith(
  uid: uid,
  caseUid: caseUid,
  readerUids: readers,
  releasedToPatient: released,
  lastUpdatedAt: stamp,
  synced: synced,
  diagnosis: diagnosis,
);

ReportDraftModel _draft({
  String caseUid = 'c1',
  String pathologistUid = 'path1',
  String stamp = _t1,
  bool synced = true,
  String title = 't',
}) => ReportDraftModel.empty().copyWith(
  uid: pathologistUid,
  caseUid: caseUid,
  pathologistUid: pathologistUid,
  lastUpdatedAt: stamp,
  synced: synced,
  title: title,
);

void main() {
  late Directory dir;
  late _MockReportFirebase remote;
  late ReportCacheHelper helper;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(ReportResponseHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(ReportAddendumHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(ReportMeasurementHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(52)) {
      Hive.registerAdapter(NotifiableFindingHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(PathologyReportHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(ReportDraftHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(PrereadScoreHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(ReportTextApprovedHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_report_cache_');
    Hive.init(dir.path);
    await Hive.openBox<PathologyReportHive>(HiveHelperImpl.pathologyReportsBox);
    await Hive.openBox<ReportDraftHive>(HiveHelperImpl.reportDraftsBox);
    await Hive.openBox<PrereadScoreHive>(HiveHelperImpl.prereadScoresBox);
    await Hive.openBox<ReportTextApprovedHive>(HiveHelperImpl.reportTextsBox);
    remote = _MockReportFirebase();
    helper = ReportCacheHelper(db: DBHelperImpl(), remote: remote);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('merge guard', () {
    test('an unsynced draft survives a newer cloud row', () async {
      await helper.cacheDraft(
        _draft(synced: false),
        fromCloud: false,
        pathologistUid: 'path1',
      );
      when(
        () => remote.fetchDraft(caseUid: 'c1', pathologistUid: 'path1'),
      ).thenAnswer((_) async => _draft(stamp: _t3, title: 'cloud'));

      await helper.syncDraft(caseUid: 'c1', pathologistUid: 'path1');

      final row = await helper.getDraft('c1', 'path1');
      expect(row!.title, 't');
      expect(row.synced, isFalse);
    });

    test('a synced report is replaced by a newer cloud row', () async {
      await helper.cacheReports(
        [_report('v1')],
        fromCloud: true,
        viewerUid: 'doc1',
        role: Role.doctor,
      );
      when(
        () => remote.fetchReaderDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_report('v1', stamp: _t3, diagnosis: 'new')]);

      await helper.syncReports('doc1', role: Role.doctor);

      expect(
        (await helper.getReports('doc1', role: Role.doctor)).single.diagnosis,
        'new',
      );
    });
  });

  group('scope', () {
    test("another reader's rows are never returned", () async {
      await helper.cacheReports(
        [_report('v1')],
        fromCloud: true,
        viewerUid: 'doc1',
        role: Role.doctor,
      );

      expect(await helper.getReports('stranger', role: Role.doctor), isEmpty);
    });
  });

  group('remote fails', () {
    test('with a cache it returns the cache', () async {
      await helper.cacheReports(
        [_report('v1')],
        fromCloud: true,
        viewerUid: 'doc1',
        role: Role.doctor,
      );
      when(
        () => remote.fetchReaderDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect(
        (await helper.syncReports('doc1', role: Role.doctor)).map((r) => r.uid),
        ['v1'],
      );
    });

    test('without a cache it rethrows', () async {
      when(
        () => remote.fetchReaderDelta(
          uid: 'doc1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      await expectLater(
        helper.syncReports('doc1', role: Role.doctor),
        throwsA(AppError.serviceUnavailable),
      );
    });
  });

  group('patient release (S-3)', () {
    test('an unreleased report is never cached for a patient', () async {
      await helper.cacheReports(
        [_report('v1'), _report('v2', released: true)],
        fromCloud: true,
        viewerUid: 'pat1',
        role: Role.patient,
      );

      final rows = await helper.getReports('pat1', role: Role.patient);
      expect(rows.map((r) => r.uid), ['v2']);
    });

    test(
      'patient sync drops unreleased rows the data source returned',
      () async {
        when(
          () => remote.fetchPatientDelta(
            uid: 'pat1',
            cursor: any(named: 'cursor'),
          ),
        ).thenAnswer(
          (_) async => [_report('v1'), _report('v2', released: true)],
        );

        final rows = await helper.syncReports('pat1', role: Role.patient);
        expect(rows.map((r) => r.uid), ['v2']);
      },
    );
  });

  group('hasUnsyncedDraftEdits', () {
    test('is true while an edit is queued and false after sync', () async {
      await helper.cacheDraft(
        _draft(),
        fromCloud: true,
        pathologistUid: 'path1',
      );
      expect(await helper.hasUnsyncedDraftEdits('c1'), isFalse);

      when(
        () => remote.updateDraft(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ).thenThrow(AppError.noInternet);

      await helper.saveDraftFields(
        caseUid: 'c1',
        pathologistUid: 'path1',
        fields: {'title': 'queued'},
      );
      expect(await helper.hasUnsyncedDraftEdits('c1'), isTrue);

      when(
        () => remote.updateDraft(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ).thenAnswer((_) async {});

      await helper.replayPendingDraftEdits('path1');
      expect(await helper.hasUnsyncedDraftEdits('c1'), isFalse);
    });

    test('a refused draft edit is dropped and the draft reloaded', () async {
      await helper.cacheDraft(
        _draft(),
        fromCloud: true,
        pathologistUid: 'path1',
      );
      when(
        () => remote.updateDraft(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ).thenThrow(AppError.unknown);
      when(
        () => remote.fetchDraft(caseUid: 'c1', pathologistUid: 'path1'),
      ).thenAnswer((_) async => _draft(stamp: _t3, title: 'signed'));

      await expectLater(
        helper.saveDraftFields(
          caseUid: 'c1',
          pathologistUid: 'path1',
          fields: {'title': 'stale'},
        ),
        throwsA(AppError.unknown),
      );

      final row = await helper.getDraft('c1', 'path1');
      expect(row!.title, 'signed');
      expect(row.synced, isTrue);
      expect(await helper.hasUnsyncedDraftEdits('c1'), isFalse);
    });
  });

  group('queued list edits', () {
    Future<Map<String, dynamic>> queueThenReplay(
      Map<String, dynamic> fields,
    ) async {
      await helper.cacheDraft(
        _draft(),
        fromCloud: true,
        pathologistUid: 'path1',
      );
      when(
        () => remote.updateDraft(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ).thenThrow(AppError.noInternet);
      await helper.saveDraftFields(
        caseUid: 'c1',
        pathologistUid: 'path1',
        fields: fields,
      );
      when(
        () => remote.updateDraft(
          caseUid: any(named: 'caseUid'),
          pathologistUid: any(named: 'pathologistUid'),
          fields: any(named: 'fields'),
        ),
      ).thenAnswer((_) async {});
      await helper.replayPendingDraftEdits('path1');
      final captured = verify(
        () => remote.updateDraft(
          caseUid: 'c1',
          pathologistUid: 'path1',
          fields: captureAny(named: 'fields'),
        ),
      ).captured;
      return captured.last as Map<String, dynamic>;
    }

    test(
      'a queued responses edit lands locally and replays the edited value',
      () async {
        const response = {
          'section': 'history',
          'question': 'q1',
          'answer': 'edited answer',
          'order': 1,
        };
        final replayed = await queueThenReplay({
          'responses': [response],
        });
        final row = await helper.getDraft('c1', 'path1');
        expect(row!.responses, hasLength(1));
        expect(row.responses.single.answer, 'edited answer');
        final replayedResponse =
            (replayed['responses'] as List).single as Map<String, dynamic>;
        expect(replayedResponse['answer'], 'edited answer');
      },
    );

    test(
      'a queued findings edit lands locally and replays the edited value',
      () async {
        const finding = {
          'diseaseId': 'ebola_virus_disease',
          'alertRequested': true,
        };
        final replayed = await queueThenReplay({
          'notifiableFindings': [finding],
        });
        final row = await helper.getDraft('c1', 'path1');
        expect(row!.notifiableFindings, hasLength(1));
        expect(row.notifiableFindings.single.diseaseId, 'ebola_virus_disease');
        final replayedFinding =
            (replayed['notifiableFindings'] as List).single
                as Map<String, dynamic>;
        expect(replayedFinding['diseaseId'], 'ebola_virus_disease');
      },
    );
  });

  group('draft ownership', () {
    test("another pathologist's draft is never cached", () async {
      await helper.cacheDraft(
        _draft(pathologistUid: 'path2'),
        fromCloud: true,
        pathologistUid: 'path1',
      );
      expect(await helper.getDraft('c1', 'path1'), isNull);
    });
  });
}
