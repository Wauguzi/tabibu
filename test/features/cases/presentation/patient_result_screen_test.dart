import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/verification_timeline.dart';
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
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/widgets/listen_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_file_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

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
  });

  group('PatientResultScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    Future<void> pumpScreen(
      WidgetTester tester, {
      required CasesState cases,
      List<AppointmentModel> appointments = const [],
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      String caseUid = 'c1',
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
          child: PatientResultScreen(caseUid: caseUid),
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
      when(() => blocs.cases.add(any())).thenReturn(null);
      when(() => blocs.appointments.add(any())).thenReturn(null);
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

    testWidgets('shared shows doctor note and disabled download', (
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
