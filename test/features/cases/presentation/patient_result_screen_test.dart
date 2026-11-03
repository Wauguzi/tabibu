import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/cases/presentation/patient_result_screen.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';
import 'package:tabibu/features/reports/presentation/report_download.dart';
import 'package:tabibu/features/reports/presentation/widgets/listen_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_file_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

class _MockDownload extends Mock implements ReportDownload {}

PatientSession _session() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

DateTime _nairobi({required int plusDays, required int hour, int minute = 0}) {
  final now = nairobiNow();
  final day = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).add(Duration(days: plusDays));
  return DateTime.utc(
    day.year,
    day.month,
    day.day,
    hour,
    minute,
  ).subtract(nairobiOffset);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const CasesRequested(uid: '', role: .patient));
    registerFallbackValue(const CaseLogRequested(caseUid: '', role: .patient));
    registerFallbackValue(const AppointmentsRequested(uid: '', role: .patient));
    registerFallbackValue(const ReportReaderReset());
    registerFallbackValue(const PathologyReportModel());
    registerFallbackValue(const CaseModel());
    registerFallbackValue(PatientModel.empty());
    registerFallbackValue(lookupAppLocalizations(const Locale('en')));
    registerFallbackValue(DateTime.utc(2026));
  });

  group('PatientResultScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;
    late _MockDownload download;

    Future<void> pumpScreen(
      WidgetTester tester, {
      required CasesState cases,
      List<AppointmentModel> appointments = const [],
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      String caseUid = 'c1',
      ReportDownload? reportDownload,
    }) async {
      when(() => blocs.cases.state).thenReturn(cases);
      when(
        () => blocs.appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: appointments));
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: PatientResultScreen(
            caseUid: caseUid,
            download: reportDownload ?? download,
          ),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      download = _MockDownload();
      when(() => blocs.cases.add(any())).thenReturn(null);
      when(() => blocs.appointments.add(any())).thenReturn(null);
      when(
        () => download.sharePatientReport(
          report: any(named: 'report'),
          caseModel: any(named: 'caseModel'),
          patient: any(named: 'patient'),
          language: any(named: 'language'),
          l10n: any(named: 'l10n'),
          now: any(named: 'now'),
        ),
      ).thenAnswer((_) async {});
    });

    testWidgets('waiting shows timeline and no report content', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: const CasesLoadSuccess(
          cases: [
            CaseModel(
              uid: 'c1',
              resultState: 'WithDoctor',
              doctorName: 'Dr. Kamau',
              doctorFacilityName: 'Aga Khan',
              pathologistName: 'Dr. Odhiambo',
              sampleCollectedAt: '2024-10-24T08:00:00Z',
              currentReportUid: 'r1',
              discussionAppointmentUid: 'a1',
              tests: [OrderedTestModel(name: 'Lymph node')],
            ),
          ],
          reports: [
            PathologyReportModel(
              uid: 'r1',
              caseUid: 'c1',
              signedAt: '2024-10-27T10:00:00Z',
              signedByName: 'Dr. Odhiambo',
              signedByFacilityName: 'Lancet Kenya',
              diagnosis: 'Should not show while waiting',
              comments: 'Secret note',
            ),
          ],
        ),
        appointments: [
          AppointmentModel(
            uid: 'a1',
            scheduledStart: _nairobi(
              plusDays: 2,
              hour: 11,
              minute: 15,
            ).toIso8601String(),
          ),
        ],
      );

      expect(find.text(l10n.resultsWaitingHeadline), findsOneWidget);
      expect(find.text(l10n.resultsWaitingExplanation), findsOneWidget);
      expect(find.byType(VerificationTimeline), findsOneWidget);
      expect(find.byType(ReportFileCard), findsNothing);
      expect(find.byType(ListenCard), findsNothing);
      expect(find.text('Should not show while waiting'), findsNothing);
      expect(find.text('Secret note'), findsNothing);
      expect(find.text(l10n.resultsSeeAppointment), findsOneWidget);
      verify(
        () => blocs.cases.add(
          const CaseLogRequested(caseUid: 'c1', role: .patient),
        ),
      ).called(1);
    });

    testWidgets('shared shows doctor note and a Download action', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: const CasesLoadSuccess(
          cases: [
            CaseModel(
              uid: 'c1',
              resultState: 'Released',
              doctorName: 'Dr. James Otieno',
              doctorFacilityName: 'Mama Lucy',
              releasedAt: '2024-09-12T00:00:00Z',
              currentReportUid: 'r1',
              tests: [OrderedTestModel(name: 'Full blood count')],
            ),
          ],
          reports: [
            PathologyReportModel(
              uid: 'r1',
              caseUid: 'c1',
              testName: 'Full blood count',
              signedAt: '2024-09-12T00:00:00Z',
              comments: 'Your blood count is in the healthy range.',
              diagnosis: 'Normal',
            ),
          ],
        ),
      );

      expect(find.text(l10n.resultDetailShared), findsOneWidget);
      expect(
        find.text(l10n.resultDetailSharedBy('Dr. James Otieno')),
        findsOneWidget,
      );
      expect(
        find.text('Your blood count is in the healthy range.'),
        findsOneWidget,
      );
      expect(find.byType(ReportFileCard), findsOneWidget);
      expect(find.byType(ListenCard), findsNothing);
      expect(find.byType(VerificationTimeline), findsNothing);
      expect(find.text(l10n.resultDetailDownload), findsOneWidget);
      expect(
        tester.widget<ReportFileCard>(find.byType(ReportFileCard)).onDownload,
        isNotNull,
      );
    });

    group('share entry points (S-3)', () {
      const released = CasesLoadSuccess(
        cases: [
          CaseModel(
            uid: 'c1',
            resultState: 'Released',
            doctorName: 'Dr. James Otieno',
            releasedAt: '2024-09-12T00:00:00Z',
            currentReportUid: 'r1',
            tests: [OrderedTestModel(name: 'Full blood count')],
          ),
        ],
        reports: [PathologyReportModel(uid: 'r1', caseUid: 'c1')],
      );

      Future<void> pumpRouted(WidgetTester tester) async {
        _useTallSurface(tester);
        when(() => blocs.cases.state).thenReturn(released);
        when(
          () => blocs.appointments.state,
        ).thenReturn(const AppointmentsLoadSuccess());
        when(
          () => authBloc.state,
        ).thenReturn(SignInSuccess(session: _session()));
        final router = GoRouter(
          initialLocation: '/result',
          routes: [
            GoRoute(
              path: '/result',
              builder: (_, _) => MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>.value(value: authBloc),
                  ...blocs.providers,
                ],
                child: PatientResultScreen(caseUid: 'c1', download: download),
              ),
            ),
            GoRoute(
              path: '/patient/result/:caseUid/share',
              builder: (_, state) =>
                  Text('stub share ${state.pathParameters['caseUid']}'),
            ),
            GoRoute(
              path: '/patient/result/:caseUid/who-can-see',
              builder: (_, state) =>
                  Text('stub who ${state.pathParameters['caseUid']}'),
            ),
            GoRoute(
              path: '/patient/shares',
              builder: (_, _) => const Text('stub shares'),
            ),
            GoRoute(
              path: '/patient/result/:caseUid/history',
              builder: (_, state) =>
                  Text('stub history ${state.pathParameters['caseUid']}'),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpRouterApp(router);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      testWidgets('rule 6: the report card offers Share', (tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpRouted(tester);

        final card = tester.widget<ReportFileCard>(find.byType(ReportFileCard));
        expect(card.shareLabel, l10n.resultDetailShare);
        expect(card.onShare, isNotNull);
        expect(find.text(l10n.resultDetailShare), findsOneWidget);
      });

      testWidgets('rule 6: Share opens the share screen for the case', (
        tester,
      ) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpRouted(tester);

        await tester.tap(find.text(l10n.resultDetailShare));
        await tester.pumpAndSettle();

        expect(find.text('stub share c1'), findsOneWidget);
      });

      testWidgets('rule 6: More opens who can see for the case', (
        tester,
      ) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpRouted(tester);

        await tester.tap(find.byType(MoreButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.tap(find.text(l10n.shareWhoCanSeeTitle));
        await tester.pumpAndSettle();

        expect(find.text('stub who c1'), findsOneWidget);
      });

      testWidgets('rule 6: More opens the shared reports list', (tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpRouted(tester);

        await tester.tap(find.byType(MoreButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.tap(find.text(l10n.shareListTitle));
        await tester.pumpAndSettle();

        expect(find.text('stub shares'), findsOneWidget);
      });

      testWidgets('the history row opens the case history', (tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpRouted(tester);

        await tester.tap(find.text(l10n.accessLogTitle));
        await tester.pumpAndSettle();

        expect(find.text('stub history c1'), findsOneWidget);
      });
    });

    testWidgets('waiting also ends in the history row', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: const CasesLoadSuccess(
          cases: [
            CaseModel(
              uid: 'c1',
              resultState: 'WithDoctor',
              doctorName: 'Dr. Kamau',
              tests: [OrderedTestModel(name: 'Lymph node')],
            ),
          ],
        ),
      );

      expect(find.text(l10n.accessLogTitle), findsOneWidget);
    });

    testWidgets('renders waiting in light and dark', (tester) async {
      _useTallSurface(tester);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await pumpScreen(
          tester,
          themeMode: mode,
          cases: const CasesLoadSuccess(
            cases: [
              CaseModel(
                uid: 'c1',
                resultState: 'WithDoctor',
                doctorName: 'Dr. Kamau',
                tests: [OrderedTestModel(name: 'Lymph node')],
              ),
            ],
          ),
        );
        expect(find.byType(PatientResultScreen), findsOneWidget);
      }
    });

    testWidgets('renders shared in Swahili', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('sw'));
      await pumpScreen(
        tester,
        locale: const Locale('sw'),
        cases: const CasesLoadSuccess(
          cases: [
            CaseModel(
              uid: 'c1',
              resultState: 'Released',
              doctorName: 'Dr. Otieno',
              currentReportUid: 'r1',
              tests: [OrderedTestModel(name: 'Full blood count')],
            ),
          ],
          reports: [
            PathologyReportModel(uid: 'r1', caseUid: 'c1', comments: 'Note'),
          ],
        ),
      );
      expect(find.text(l10n.resultDetailShared), findsOneWidget);
    });

    group('explained entry (F-8)', () {
      const releasedCase = CasesLoadSuccess(
        cases: [
          CaseModel(
            uid: 'c1',
            resultState: 'Released',
            doctorName: 'Dr. Kamau',
            currentReportUid: 'r1',
            tests: [OrderedTestModel(name: 'Lymph node')],
          ),
        ],
        reports: [PathologyReportModel(uid: 'r1', caseUid: 'c1')],
      );

      ReportReaderState reader({
        Map<String, ReportTextApprovedModel> approved = const {},
        Map<String, ReportTextModel> explanations = const {},
        Role role = Role.patient,
        String caseUid = 'c1',
      }) => ReportReaderLoadSuccess(
        uid: 'patient-1',
        role: role,
        caseUid: caseUid,
        approved: approved,
        explanations: explanations,
      );

      const approved = {
        'en': ReportTextApprovedModel(
          uid: 'v1_Explanation_en',
          language: 'en',
          approvedText: {'summary': 'Approved text'},
        ),
      };

      Future<void> pumpWith(
        WidgetTester tester, {
        required ReportReaderState state,
        CasesState cases = releasedCase,
        ThemeMode themeMode = ThemeMode.light,
        Locale? locale,
      }) async {
        _useTallSurface(tester);
        when(() => blocs.reportReader.state).thenReturn(state);
        await pumpScreen(
          tester,
          cases: cases,
          themeMode: themeMode,
          locale: locale,
        );
      }

      testWidgets('shows the Explained row when the doctor approved one', (
        tester,
      ) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpWith(tester, state: reader(approved: approved));

        expect(find.text(l10n.explainedHeadline('Dr. Kamau')), findsOneWidget);
        expect(find.text(l10n.explainedAiAttribution), findsOneWidget);
        expect(find.text('Approved text'), findsNothing);
      });

      testWidgets('shows no row without an approved explanation, even with '
          'drafts in the state', (tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpWith(
          tester,
          state: reader(
            explanations: const {
              'en': ReportTextModel(
                uid: 'v1_Explanation_en',
                machineText: {'summary': 'DRAFT-SENTINEL'},
              ),
            },
          ),
        );

        expect(find.text(l10n.explainedHeadline('Dr. Kamau')), findsNothing);
        expect(find.text(l10n.explainedAiAttribution), findsNothing);
        expect(find.text('DRAFT-SENTINEL'), findsNothing);
      });

      testWidgets('shows no row for another case', (tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpWith(
          tester,
          state: reader(approved: approved, caseUid: 'other'),
        );

        expect(find.text(l10n.explainedAiAttribution), findsNothing);
      });

      testWidgets('shows no row for another role', (tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpWith(
          tester,
          state: reader(approved: approved, role: Role.doctor),
        );

        expect(find.text(l10n.explainedAiAttribution), findsNothing);
      });

      testWidgets('shows no row while the result is still with the doctor', (
        tester,
      ) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        await pumpWith(
          tester,
          state: reader(approved: approved),
          cases: const CasesLoadSuccess(
            cases: [
              CaseModel(
                uid: 'c1',
                resultState: 'WithDoctor',
                doctorName: 'Dr. Kamau',
              ),
            ],
          ),
        );

        expect(find.text(l10n.explainedAiAttribution), findsNothing);
      });

      testWidgets('reads the case through the reader only, opening it as '
          'the patient', (tester) async {
        await pumpWith(tester, state: const ReportReaderInitial());

        final added = verify(
          () => blocs.reportReader.add(captureAny()),
        ).captured;
        expect(added, [
          const ReportReaderOpened(
            uid: 'patient-1',
            role: Role.patient,
            caseUid: 'c1',
          ),
        ]);
      });

      testWidgets('does not reopen a case the reader already holds', (
        tester,
      ) async {
        await pumpWith(tester, state: reader(approved: approved));

        verifyNever(() => blocs.reportReader.add(any()));
      });

      testWidgets('tapping the row opens the explained result', (tester) async {
        _useTallSurface(tester);
        final l10n = lookupAppLocalizations(const Locale('en'));
        when(() => blocs.cases.state).thenReturn(releasedCase);
        when(
          () => blocs.appointments.state,
        ).thenReturn(const AppointmentsLoadSuccess());
        when(
          () => authBloc.state,
        ).thenReturn(SignInSuccess(session: _session()));
        when(
          () => blocs.reportReader.state,
        ).thenReturn(reader(approved: approved));
        final router = GoRouter(
          initialLocation: '/result',
          routes: [
            GoRoute(
              path: '/result',
              builder: (_, _) => MultiBlocProvider(
                providers: [
                  BlocProvider<AuthBloc>.value(value: authBloc),
                  ...blocs.providers,
                ],
                child: PatientResultScreen(caseUid: 'c1', download: download),
              ),
            ),
            GoRoute(
              path: '/patient/result/:caseUid/explained',
              builder: (_, state) =>
                  Text('stub explained ${state.pathParameters['caseUid']}'),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpRouterApp(router);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.text(l10n.explainedAiAttribution));
        await tester.pumpAndSettle();

        expect(find.text('stub explained c1'), findsOneWidget);
      });

      for (final scale in const [1.3, 2.0]) {
        testWidgets('draws in dark mode and Swahili at ${scale}x', (
          tester,
        ) async {
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final sw = lookupAppLocalizations(const Locale('sw'));
          await pumpWith(
            tester,
            state: reader(approved: approved),
            themeMode: ThemeMode.dark,
            locale: const Locale('sw'),
          );

          expect(find.text(sw.explainedAiAttribution), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    });

    group('PDF download', () {
      const shared = CasesLoadSuccess(
        cases: [
          CaseModel(
            uid: 'c1',
            resultState: 'Released',
            doctorName: 'Dr. Otieno',
            doctorUid: 'doc-1',
            currentReportUid: 'r1',
            doctorFacilityName: 'Aga Khan',
            tests: [OrderedTestModel(name: 'Full blood count')],
          ),
        ],
        reports: [
          PathologyReportModel(
            uid: 'r1',
            caseUid: 'c1',
            releasedToPatient: true,
            comments: 'Your blood count is in the healthy range.',
            testName: 'Full blood count',
          ),
        ],
      );

      testWidgets('disables Download while the PDF is building', (
        tester,
      ) async {
        _useTallSurface(tester);
        final l10n = lookupAppLocalizations(const Locale('en'));
        final gate = Completer<void>();
        when(
          () => download.sharePatientReport(
            report: any(named: 'report'),
            caseModel: any(named: 'caseModel'),
            patient: any(named: 'patient'),
            language: any(named: 'language'),
            l10n: any(named: 'l10n'),
            now: any(named: 'now'),
          ),
        ).thenAnswer((_) => gate.future);

        await pumpScreen(tester, cases: shared);
        await tester.tap(find.text(l10n.resultDetailDownload));
        await tester.pump();

        expect(find.text(l10n.resultsLoadingLabel), findsWidgets);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        final card = tester.widget<ReportFileCard>(find.byType(ReportFileCard));
        expect(card.onDownload, isNull);

        gate.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          tester.widget<ReportFileCard>(find.byType(ReportFileCard)).onDownload,
          isNotNull,
        );
      });

      testWidgets('a failure shows a generic message and keeps the screen '
          'usable', (tester) async {
        _useTallSurface(tester);
        final l10n = lookupAppLocalizations(const Locale('en'));
        when(
          () => download.sharePatientReport(
            report: any(named: 'report'),
            caseModel: any(named: 'caseModel'),
            patient: any(named: 'patient'),
            language: any(named: 'language'),
            l10n: any(named: 'l10n'),
            now: any(named: 'now'),
          ),
        ).thenThrow(AppError.permissionDenied);

        await pumpScreen(tester, cases: shared);
        await tester.tap(find.text(l10n.resultDetailDownload));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text(l10n.errorUnknown), findsOneWidget);
        expect(find.text(l10n.errorPermissionDenied), findsNothing);
        expect(find.byType(ReportFileCard), findsOneWidget);
        expect(find.text(l10n.resultDetailBookFollowUp), findsOneWidget);
        expect(
          tester.widget<ReportFileCard>(find.byType(ReportFileCard)).onDownload,
          isNotNull,
        );
      });
    });

    testWidgets('grows at 1.3x without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(
        tester,
        cases: const CasesLoadSuccess(
          cases: [
            CaseModel(
              uid: 'c1',
              resultState: 'WithDoctor',
              doctorName: 'Dr. Kamau',
              sampleCollectedAt: '2024-10-24T08:00:00Z',
              currentReportUid: 'r1',
              tests: [OrderedTestModel(name: 'Lymph node')],
            ),
          ],
          reports: [
            PathologyReportModel(
              uid: 'r1',
              caseUid: 'c1',
              signedAt: '2024-10-27T10:00:00Z',
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
