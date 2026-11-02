import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/cache/case_cache_helper.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/cache/report_cache_helper.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';

class _MockCases extends Mock implements CaseCacheHelper {}

class _MockReports extends Mock implements ReportCacheHelper {}

CaseModel _case(String uid) => CaseModel.empty().copyWith(uid: uid);

PathologyReportModel _report(String uid) =>
    PathologyReportModel.empty().copyWith(uid: uid, caseUid: 'c1');

CaseLogEntryModel _log(String caseUid, int seq) =>
    CaseLogEntryModel.empty().copyWith(caseUid: caseUid, seq: seq);

void main() {
  late _MockCases cases;
  late _MockReports reports;

  CasesBloc build() => CasesBloc(cases: cases, reports: reports);

  setUpAll(() {
    registerFallbackValue(Role.patient);
  });

  setUp(() {
    cases = _MockCases();
    reports = _MockReports();
  });

  group('CasesBloc', () {
    test('starts empty', () {
      expect(build().state, const CasesInitial());
    });

    blocTest<CasesBloc, CasesState>(
      'drops its data on reset',
      build: build,
      seed: () => const CasesLoadSuccess(offline: true),
      act: (bloc) => bloc.add(const CasesReset()),
      expect: () => [const CasesInitial()],
    );

    group('CasesRequested', () {
      blocTest<CasesBloc, CasesState>(
        'with caches emits success, then the synced rows',
        setUp: () {
          when(
            () => cases.getCases('u1'),
          ).thenAnswer((_) async => [_case('c1')]);
          when(
            () => reports.getReports('u1', role: Role.patient),
          ).thenAnswer((_) async => [_report('r1')]);
          when(
            () => cases.syncCases('u1'),
          ).thenAnswer((_) async => [_case('c1'), _case('c2')]);
          when(
            () => reports.syncReports('u1', role: Role.patient),
          ).thenAnswer((_) async => [_report('r1'), _report('r2')]);
        },
        build: build,
        act: (bloc) =>
            bloc.add(const CasesRequested(uid: 'u1', role: Role.patient)),
        expect: () => [
          const CasesLoadInProgress(),
          CasesLoadSuccess(cases: [_case('c1')], reports: [_report('r1')]),
          CasesLoadSuccess(
            cases: [_case('c1'), _case('c2')],
            reports: [_report('r1'), _report('r2')],
          ),
        ],
      );

      blocTest<CasesBloc, CasesState>(
        'with empty caches skips the first success',
        setUp: () {
          when(() => cases.getCases('u1')).thenAnswer((_) async => []);
          when(
            () => reports.getReports('u1', role: Role.doctor),
          ).thenAnswer((_) async => []);
          when(
            () => cases.syncCases('u1'),
          ).thenAnswer((_) async => [_case('c1')]);
          when(
            () => reports.syncReports('u1', role: Role.doctor),
          ).thenAnswer((_) async => [_report('r1')]);
        },
        build: build,
        act: (bloc) =>
            bloc.add(const CasesRequested(uid: 'u1', role: Role.doctor)),
        expect: () => [
          const CasesLoadInProgress(),
          CasesLoadSuccess(cases: [_case('c1')], reports: [_report('r1')]),
        ],
      );

      for (final role in Role.values) {
        blocTest<CasesBloc, CasesState>(
          'passes $role to the report helper',
          setUp: () {
            when(() => cases.getCases('u1')).thenAnswer((_) async => []);
            when(
              () => reports.getReports('u1', role: role),
            ).thenAnswer((_) async => []);
            when(() => cases.syncCases('u1')).thenAnswer((_) async => []);
            when(
              () => reports.syncReports('u1', role: role),
            ).thenAnswer((_) async => []);
          },
          build: build,
          act: (bloc) => bloc.add(CasesRequested(uid: 'u1', role: role)),
          verify: (_) {
            verify(() => reports.getReports('u1', role: role)).called(1);
            verify(() => reports.syncReports('u1', role: role)).called(1);
          },
        );
      }
    });

    group('CasesRefreshed', () {
      blocTest<CasesBloc, CasesState>(
        'syncs first',
        setUp: () {
          when(
            () => cases.syncCases('u1'),
          ).thenAnswer((_) async => [_case('c1')]);
          when(
            () => reports.syncReports('u1', role: Role.pathologist),
          ).thenAnswer((_) async => [_report('r1')]);
        },
        build: build,
        seed: () => CasesLoadSuccess(cases: [_case('c0')]),
        act: (bloc) =>
            bloc.add(const CasesRefreshed(uid: 'u1', role: Role.pathologist)),
        expect: () => [
          CasesLoadInProgress(cases: [_case('c0')]),
          CasesLoadSuccess(cases: [_case('c1')], reports: [_report('r1')]),
        ],
      );
    });

    group('offline', () {
      blocTest<CasesBloc, CasesState>(
        'cases sync offline alone keeps the reports',
        setUp: () {
          when(() => cases.syncCases('u1')).thenThrow(AppError.noInternet);
          when(
            () => reports.syncReports('u1', role: Role.patient),
          ).thenAnswer((_) async => [_report('r1')]);
        },
        build: build,
        seed: () => CasesLoadSuccess(cases: [_case('c1')]),
        act: (bloc) =>
            bloc.add(const CasesRefreshed(uid: 'u1', role: Role.patient)),
        expect: () => [
          CasesLoadInProgress(cases: [_case('c1')]),
          CasesLoadSuccess(
            cases: [_case('c1')],
            reports: [_report('r1')],
            offline: true,
          ),
        ],
      );

      blocTest<CasesBloc, CasesState>(
        'reports sync offline alone keeps the cases',
        setUp: () {
          when(
            () => cases.syncCases('u1'),
          ).thenAnswer((_) async => [_case('c1')]);
          when(
            () => reports.syncReports('u1', role: Role.patient),
          ).thenThrow(AppError.requestTimeout);
        },
        build: build,
        seed: () => CasesLoadSuccess(reports: [_report('r0')]),
        act: (bloc) =>
            bloc.add(const CasesRefreshed(uid: 'u1', role: Role.patient)),
        expect: () => [
          CasesLoadInProgress(reports: [_report('r0')]),
          CasesLoadSuccess(
            cases: [_case('c1')],
            reports: [_report('r0')],
            offline: true,
          ),
        ],
      );

      blocTest<CasesBloc, CasesState>(
        'both offline with caches keeps the rows',
        setUp: () {
          when(() => cases.syncCases('u1')).thenThrow(AppError.noInternet);
          when(
            () => reports.syncReports('u1', role: Role.patient),
          ).thenThrow(AppError.serviceUnavailable);
        },
        build: build,
        seed: () =>
            CasesLoadSuccess(cases: [_case('c1')], reports: [_report('r1')]),
        act: (bloc) =>
            bloc.add(const CasesRefreshed(uid: 'u1', role: Role.patient)),
        expect: () => [
          CasesLoadInProgress(cases: [_case('c1')], reports: [_report('r1')]),
          CasesLoadSuccess(
            cases: [_case('c1')],
            reports: [_report('r1')],
            offline: true,
          ),
        ],
      );

      blocTest<CasesBloc, CasesState>(
        'both offline without caches fails',
        setUp: () {
          when(() => cases.syncCases('u1')).thenThrow(AppError.noInternet);
          when(
            () => reports.syncReports('u1', role: Role.patient),
          ).thenThrow(AppError.noInternet);
        },
        build: build,
        act: (bloc) =>
            bloc.add(const CasesRefreshed(uid: 'u1', role: Role.patient)),
        expect: () => [
          const CasesLoadInProgress(),
          const CasesLoadFailure(error: AppError.noInternet),
        ],
      );
    });

    group('partial failure', () {
      blocTest<CasesBloc, CasesState>(
        'keeps synced cases when reports fail hard',
        setUp: () {
          when(
            () => cases.syncCases('u1'),
          ).thenAnswer((_) async => [_case('c1'), _case('c2')]);
          when(
            () => reports.syncReports('u1', role: Role.doctor),
          ).thenThrow(AppError.permissionDenied);
        },
        build: build,
        seed: () => CasesLoadSuccess(reports: [_report('r0')]),
        act: (bloc) =>
            bloc.add(const CasesRefreshed(uid: 'u1', role: Role.doctor)),
        expect: () => [
          CasesLoadInProgress(reports: [_report('r0')]),
          CasesLoadFailure(
            error: AppError.permissionDenied,
            cases: [_case('c1'), _case('c2')],
            reports: [_report('r0')],
          ),
        ],
      );
    });

    group('parallel sync', () {
      test('both syncs start before either finishes', () async {
        final casesStarted = Completer<void>();
        final reportsStarted = Completer<void>();
        final releaseCases = Completer<List<CaseModel>>();
        final releaseReports = Completer<List<PathologyReportModel>>();

        when(() => cases.syncCases('u1')).thenAnswer((_) {
          casesStarted.complete();
          return releaseCases.future;
        });
        when(() => reports.syncReports('u1', role: Role.patient)).thenAnswer((
          _,
        ) {
          reportsStarted.complete();
          return releaseReports.future;
        });

        final bloc = build()
          ..add(const CasesRefreshed(uid: 'u1', role: Role.patient));

        await Future.wait([casesStarted.future, reportsStarted.future]);
        // Complete reports first, then cases — out of start order.
        releaseReports.complete([_report('r1')]);
        releaseCases.complete([_case('c1')]);

        await expectLater(
          bloc.stream,
          emitsThrough(
            CasesLoadSuccess(cases: [_case('c1')], reports: [_report('r1')]),
          ),
        );
        await bloc.close();
      });
    });

    group('CaseLogRequested', () {
      blocTest<CasesBloc, CasesState>(
        'replaces one case log and keeps another',
        setUp: () {
          when(
            () => cases.syncLog(caseUid: 'c2', role: Role.doctor),
          ).thenAnswer((_) async => [_log('c2', 1), _log('c2', 2)]);
        },
        build: build,
        seed: () => CasesLoadSuccess(
          cases: [_case('c1'), _case('c2')],
          logs: {
            'c1': [_log('c1', 1)],
            'c2': [_log('c2', 9)],
          },
        ),
        act: (bloc) =>
            bloc.add(const CaseLogRequested(caseUid: 'c2', role: Role.doctor)),
        expect: () => [
          CasesLoadSuccess(
            cases: [_case('c1'), _case('c2')],
            logs: {
              'c1': [_log('c1', 1)],
              'c2': [_log('c2', 1), _log('c2', 2)],
            },
          ),
        ],
      );
    });
  });
}
