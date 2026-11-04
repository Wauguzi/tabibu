import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_bloc.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/cache/worklist_cache_helper.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

class _MockCache extends Mock implements WorklistCacheHelper {}

final _now = DateTime.utc(2026, 11, 2, 12);

WorklistEntryModel _entry(
  String uid, {
  String orderNumber = 'TB-0231',
  String testName = 'Lymph node',
  String status = 'Open',
  String confidenceBand = 'Moderate',
  String profile = 'Cancer',
  String waitingSince = '2026-11-02T10:00:00.000Z',
  int basePriority = 10,
}) => WorklistEntryModel.empty().copyWith(
  uid: uid,
  pathologistUid: 'p1',
  orderNumber: orderNumber,
  testName: testName,
  status: status,
  confidenceBand: confidenceBand,
  profile: profile,
  waitingSince: waitingSince,
  basePriority: basePriority,
);

void main() {
  late _MockCache cache;

  DeskBloc build() => DeskBloc(cache: cache, now: () => _now);

  setUpAll(() {
    registerFallbackValue(DateTime.utc(2026));
  });

  setUp(() {
    cache = _MockCache();
  });

  group('DeskBloc', () {
    test('starts empty', () {
      expect(build().state, const DeskInitial());
    });

    blocTest<DeskBloc, DeskState>(
      'drops its data on reset',
      build: build,
      seed: () => const DeskLoadSuccess(query: 'TB-0231'),
      act: (bloc) => bloc.add(const DeskReset()),
      expect: () => [const DeskInitial()],
    );

    group('DeskRequested', () {
      blocTest<DeskBloc, DeskState>(
        'with a cache emits success, then the synced rows',
        setUp: () {
          when(
            () => cache.getDesk('p1', now: any(named: 'now')),
          ).thenAnswer((_) async => [_entry('e1')]);
          when(() => cache.syncDesk('p1', now: any(named: 'now'))).thenAnswer(
            (_) async => [_entry('e1'), _entry('e2', orderNumber: 'TB-0232')],
          );
        },
        build: build,
        act: (bloc) => bloc.add(const DeskRequested(pathologistUid: 'p1')),
        expect: () => [
          const DeskLoadInProgress(),
          DeskLoadSuccess(entries: [_entry('e1')], visible: [_entry('e1')]),
          DeskLoadSuccess(
            entries: [
              _entry('e1'),
              _entry('e2', orderNumber: 'TB-0232'),
            ],
            visible: [
              _entry('e1'),
              _entry('e2', orderNumber: 'TB-0232'),
            ],
          ),
        ],
      );

      blocTest<DeskBloc, DeskState>(
        'with an empty cache skips the first success',
        setUp: () {
          when(
            () => cache.getDesk('p1', now: any(named: 'now')),
          ).thenAnswer((_) async => []);
          when(
            () => cache.syncDesk('p1', now: any(named: 'now')),
          ).thenAnswer((_) async => [_entry('e1')]);
        },
        build: build,
        act: (bloc) => bloc.add(const DeskRequested(pathologistUid: 'p1')),
        expect: () => [
          const DeskLoadInProgress(),
          DeskLoadSuccess(entries: [_entry('e1')], visible: [_entry('e1')]),
        ],
      );

      blocTest<DeskBloc, DeskState>(
        'offline with a cache keeps the rows',
        setUp: () {
          when(
            () => cache.getDesk('p1', now: any(named: 'now')),
          ).thenAnswer((_) async => [_entry('e1')]);
          when(
            () => cache.syncDesk('p1', now: any(named: 'now')),
          ).thenThrow(AppError.noInternet);
        },
        build: build,
        act: (bloc) => bloc.add(const DeskRequested(pathologistUid: 'p1')),
        expect: () => [
          const DeskLoadInProgress(),
          DeskLoadSuccess(entries: [_entry('e1')], visible: [_entry('e1')]),
          DeskLoadSuccess(
            entries: [_entry('e1')],
            visible: [_entry('e1')],
            offline: true,
          ),
        ],
      );

      blocTest<DeskBloc, DeskState>(
        'offline with an empty cache fails',
        setUp: () {
          when(
            () => cache.getDesk('p1', now: any(named: 'now')),
          ).thenAnswer((_) async => []);
          when(
            () => cache.syncDesk('p1', now: any(named: 'now')),
          ).thenThrow(AppError.serviceUnavailable);
        },
        build: build,
        act: (bloc) => bloc.add(const DeskRequested(pathologistUid: 'p1')),
        expect: () => [
          const DeskLoadInProgress(),
          const DeskLoadFailure(error: AppError.serviceUnavailable),
        ],
      );
    });

    group('DeskRefreshed', () {
      blocTest<DeskBloc, DeskState>(
        'syncs first and keeps filter and query',
        setUp: () {
          when(
            () => cache.syncDesk('p1', now: any(named: 'now')),
          ).thenAnswer((_) async => [_entry('e1'), _entry('e2')]);
        },
        build: build,
        seed: () => DeskLoadSuccess(
          entries: [_entry('e0')],
          visible: [_entry('e0')],
          filter: DeskFilter.lowConfidence,
          query: 'node',
        ),
        act: (bloc) => bloc.add(const DeskRefreshed(pathologistUid: 'p1')),
        expect: () => [
          DeskLoadInProgress(
            entries: [_entry('e0')],
            visible: [_entry('e0')],
            filter: DeskFilter.lowConfidence,
            query: 'node',
          ),
          DeskLoadSuccess(
            entries: [_entry('e1'), _entry('e2')],
            filter: DeskFilter.lowConfidence,
            query: 'node',
          ),
        ],
      );
    });

    group('filters and query', () {
      final low = _entry('low', confidenceBand: 'Low', basePriority: 1);
      final high = _entry(
        'high',
        confidenceBand: 'High',
        orderNumber: 'TB-0999',
        testName: 'Blood smear',
        basePriority: 50,
      );
      final waiting = _entry(
        'wait',
        orderNumber: 'TB-0300',
        waitingSince: '2026-11-02T07:00:00.000Z', // 5h before _now
        basePriority: 5,
      );
      final boundary = _entry(
        'edge',
        orderNumber: 'TB-0301',
        waitingSince: '2026-11-02T08:00:00.000Z', // exactly 4h
        basePriority: 5,
      );
      final badStamp = _entry(
        'bad',
        orderNumber: 'TB-0302',
        waitingSince: 'not-a-stamp',
        basePriority: 5,
      );
      final malaria = _entry(
        'mal',
        profile: 'Malaria',
        testName: 'Thick smear',
        orderNumber: 'TB-0400',
        basePriority: 20,
      );
      final closed = _entry(
        'closed',
        orderNumber: 'TB-0900',
        status: 'Closed',
        basePriority: 99,
      );
      final accent = _entry(
        'accent',
        testName: 'José cytology',
        orderNumber: 'TB-0555',
        basePriority: 2,
      );

      final all = [
        low,
        high,
        waiting,
        boundary,
        badStamp,
        malaria,
        closed,
        accent,
      ];

      blocTest<DeskBloc, DeskState>(
        'lowConfidence filter',
        build: build,
        seed: () => DeskLoadSuccess(
          entries: all,
          visible: visibleOf(all, filter: DeskFilter.all, query: '', now: _now),
        ),
        act: (bloc) =>
            bloc.add(const DeskFilterChanged(filter: DeskFilter.lowConfidence)),
        expect: () => [
          DeskLoadSuccess(
            entries: all,
            visible: [low],
            filter: DeskFilter.lowConfidence,
          ),
        ],
      );

      blocTest<DeskBloc, DeskState>(
        'waitingOver4h uses a strict 4-hour boundary',
        build: build,
        seed: () => DeskLoadSuccess(
          entries: all,
          visible: visibleOf(all, filter: DeskFilter.all, query: '', now: _now),
        ),
        act: (bloc) =>
            bloc.add(const DeskFilterChanged(filter: DeskFilter.waitingOver4h)),
        expect: () => [
          DeskLoadSuccess(
            entries: all,
            visible: [waiting],
            filter: DeskFilter.waitingOver4h,
          ),
        ],
      );

      blocTest<DeskBloc, DeskState>(
        'notifiable is malaria only',
        build: build,
        seed: () => DeskLoadSuccess(
          entries: all,
          visible: visibleOf(all, filter: DeskFilter.all, query: '', now: _now),
        ),
        act: (bloc) =>
            bloc.add(const DeskFilterChanged(filter: DeskFilter.notifiable)),
        expect: () => [
          DeskLoadSuccess(
            entries: all,
            visible: [malaria],
            filter: DeskFilter.notifiable,
          ),
        ],
      );

      blocTest<DeskBloc, DeskState>(
        'query matches order with and without prefix, test name, accents, case',
        build: build,
        seed: () => DeskLoadSuccess(
          entries: all,
          visible: visibleOf(all, filter: DeskFilter.all, query: '', now: _now),
        ),
        act: (bloc) async {
          bloc
            ..add(const DeskQueryChanged(query: '0231'))
            ..add(const DeskQueryChanged(query: 'tb-0231'))
            ..add(const DeskQueryChanged(query: '  BLOOD '))
            ..add(const DeskQueryChanged(query: 'jose'));
        },
        expect: () => [
          DeskLoadSuccess(entries: all, visible: [low], query: '0231'),
          DeskLoadSuccess(entries: all, visible: [low], query: 'tb-0231'),
          DeskLoadSuccess(entries: all, visible: [high], query: '  BLOOD '),
          DeskLoadSuccess(entries: all, visible: [accent], query: 'jose'),
        ],
      );

      blocTest<DeskBloc, DeskState>(
        'filter and query together; closed entries stay out',
        build: build,
        seed: () => DeskLoadSuccess(
          entries: all,
          visible: visibleOf(all, filter: DeskFilter.all, query: '', now: _now),
        ),
        act: (bloc) async {
          bloc
            ..add(const DeskFilterChanged(filter: DeskFilter.lowConfidence))
            ..add(const DeskQueryChanged(query: '0231'));
        },
        expect: () => [
          DeskLoadSuccess(
            entries: all,
            visible: [low],
            filter: DeskFilter.lowConfidence,
          ),
          DeskLoadSuccess(
            entries: all,
            visible: [low],
            filter: DeskFilter.lowConfidence,
            query: '0231',
          ),
        ],
      );

      test('rank order puts higher score first', () {
        final visible = visibleOf(
          [low, high, malaria],
          filter: DeskFilter.all,
          query: '',
          now: _now,
        );
        expect(visible.map((e) => e.uid), ['high', 'mal', 'low']);
      });
    });
  });
}
