import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/worklist/data/cache/worklist_cache_helper.dart';
import 'package:tabibu/features/worklist/data/cache/worklist_rank.dart';
import 'package:tabibu/features/worklist/data/datasources/worklist_firebase.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_hive.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

class _MockWorklistFirebase extends Mock implements WorklistFirebase {}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';

WorklistEntryModel _entry(
  String caseUid, {
  String pathologistUid = 'path1',
  int basePriority = 100,
  String waitingSince = _t1,
  String stamp = _t1,
  String status = 'Open',
  bool synced = true,
}) => WorklistEntryModel.empty().copyWith(
  uid: caseUid,
  caseUid: caseUid,
  pathologistUid: pathologistUid,
  basePriority: basePriority,
  waitingSince: waitingSince,
  lastUpdatedAt: stamp,
  status: status,
  synced: synced,
);

void main() {
  late Directory dir;
  late _MockWorklistFirebase remote;
  late WorklistCacheHelper helper;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(WorklistEntryHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_worklist_cache_');
    Hive.init(dir.path);
    await Hive.openBox<WorklistEntryHive>(HiveHelperImpl.worklistBox);
    remote = _MockWorklistFirebase();
    helper = WorklistCacheHelper(db: DBHelperImpl(), remote: remote);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('WorklistRank', () {
    test(
      'a 3-day routine case (172) ranks below a new priority case (200)',
      () {
        final now = DateTime.parse('2026-11-04T10:00:00.000Z');
      final routine = _entry('c1');
        final priority = _entry(
          'c2',
          basePriority: 200,
          waitingSince: '2026-11-04T10:00:00.000Z',
        );
        expect(WorklistRank.score(routine, now), 172);
        expect(WorklistRank.score(priority, now), 200);
        final ordered = WorklistRank.sorted([routine, priority], now);
        expect(ordered.map((e) => e.caseUid), ['c2', 'c1']);
      },
    );
  });

  group('merge guard', () {
    test('an unsynced row survives a newer cloud row', () async {
      await helper.cacheEntries(
        [_entry('c1', synced: false)],
        fromCloud: false,
        pathologistUid: 'path1',
      );
      when(
        () => remote.fetchPathologistDelta(
          pathologistUid: 'path1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_entry('c1', stamp: _t3, basePriority: 200)]);

      await helper.syncDesk('path1');

      final rows = await helper.getDesk('path1');
      expect(rows.single.basePriority, 100);
      expect(rows.single.synced, isFalse);
    });

    test('a synced row is replaced by a newer cloud row', () async {
      await helper.cacheEntries(
        [_entry('c1')],
        fromCloud: true,
        pathologistUid: 'path1',
      );
      when(
        () => remote.fetchPathologistDelta(
          pathologistUid: 'path1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_entry('c1', stamp: _t3, basePriority: 200)]);

      await helper.syncDesk('path1');

      expect((await helper.getDesk('path1')).single.basePriority, 200);
    });
  });

  group('scope', () {
    test("another pathologist's rows are never returned", () async {
      await helper.cacheEntries(
        [_entry('c1')],
        fromCloud: true,
        pathologistUid: 'path1',
      );
      await helper.cacheEntries(
        [_entry('c2', pathologistUid: 'path2')],
        fromCloud: true,
        pathologistUid: 'path2',
      );

      expect((await helper.getDesk('path1')).map((e) => e.caseUid), ['c1']);
    });
  });

  group('remote fails', () {
    test('with a cache it returns the cache', () async {
      await helper.cacheEntries(
        [_entry('c1')],
        fromCloud: true,
        pathologistUid: 'path1',
      );
      when(
        () => remote.fetchPathologistDelta(
          pathologistUid: 'path1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect((await helper.syncDesk('path1')).map((e) => e.caseUid), ['c1']);
    });

    test('without a cache it rethrows', () async {
      when(
        () => remote.fetchPathologistDelta(
          pathologistUid: 'path1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      await expectLater(
        helper.syncDesk('path1'),
        throwsA(AppError.serviceUnavailable),
      );
    });
  });

  group('eviction', () {
    test('an entry the pathologist left disappears (F-14)', () async {
      await helper.cacheEntries(
        [_entry('c1')],
        fromCloud: true,
        pathologistUid: 'path1',
      );
      await helper.cacheEntries(
        [_entry('c1', pathologistUid: '')],
        fromCloud: true,
        pathologistUid: 'path1',
      );

      expect(await helper.getDesk('path1'), isEmpty);
    });
  });
}
