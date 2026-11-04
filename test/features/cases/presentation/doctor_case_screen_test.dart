import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/cases/presentation/doctor_case_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _useTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

const _scales = [1.0, 2.0];
const _locales = [Locale('en'), Locale('sw')];

CaseModel _case({
  String uid = 'case-1',
  String orderNumber = 'ODR-JK-MN-02112026-002',
  String patientName = 'Mary Njeri',
  int patientAgeYears = 52,
  String currentStage = 'PathologistAccepted',
  String resultState = 'Pending',
  String appointmentUid = 'appt-1',
  String doctorFacilityName = 'Aga Khan University Hospital',
  String pathologistName = 'Dr. Achieng Odhiambo',
  String createdAt = '2026-10-26T07:20:00Z',
  String sampleReceivedAt = '2026-10-27T06:05:00Z',
  String sampleNotes = 'Right breast · wide local excision',
  String priority = 'Routine',
  String testName = 'Breast excision',
}) => CaseModel(
  uid: uid,
  orderNumber: orderNumber,
  patientName: patientName,
  patientAgeYears: patientAgeYears,
  currentStage: currentStage,
  resultState: resultState,
  appointmentUid: appointmentUid,
  doctorFacilityName: doctorFacilityName,
  pathologistName: pathologistName,
  createdAt: createdAt,
  sampleReceivedAt: sampleReceivedAt,
  sampleNotes: sampleNotes,
  priority: priority,
  tests: testName.isEmpty ? const [] : [OrderedTestModel(name: testName)],
);

AppointmentModel _appointment() => const AppointmentModel(
  uid: 'appt-1',
  facilityName: 'Aga Khan University Hospital',
  scheduledStart: '2026-10-26T07:00:00Z',
);

String _stamp(String iso, String language) =>
    DateFormat('EEE d MMM, h:mm a', language).format(nairobiTimeOf(iso)!);

String _day(String iso, String language) =>
    DateFormat('EEE d MMM', language).format(nairobiTimeOf(iso)!);

void main() {
  setUpAll(() {
    registerFallbackValue(const CasesRequested(uid: '', role: .doctor));
    registerFallbackValue(const CaseLogRequested(caseUid: '', role: .doctor));
    registerFallbackValue(const AppointmentsRequested(uid: '', role: .doctor));
  });

  group('DoctorCaseScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    Future<void> pumpScreen(
      WidgetTester tester, {
      CasesState? cases,
      List<AppointmentModel>? appointments,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      String caseUid = 'case-1',
    }) async {
      when(
        () => blocs.cases.state,
      ).thenReturn(cases ?? const CasesLoadSuccess());
      when(() => blocs.appointments.state).thenReturn(
        AppointmentsLoadSuccess(appointments: appointments ?? [_appointment()]),
      );
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: DoctorCaseScreen(caseUid: caseUid),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
    }

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => blocs.cases.add(any())).thenReturn(null);
      when(() => blocs.appointments.add(any())).thenReturn(null);
    });

    testWidgets('shows the patient, timeline and order', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: [_case()]));

      // Top bar: the order number and test · stage.
      expect(find.text('ODR-JK-MN-02112026-002'), findsOneWidget);
      expect(
        find.text(
          l10n.doctorCaseSubtitle('Breast excision', 'with pathologist'),
        ),
        findsOneWidget,
      );
      // Patient block: name, age, the appointment line, the stage chip.
      expect(find.text('Mary Njeri, 52'), findsOneWidget);
      expect(
        find.text(
          l10n.doctorCaseAppointmentLine(
            _day('2026-10-26T07:00:00Z', 'en'),
            'Aga Khan University Hospital',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.doctorCasesWithPathologist), findsOneWidget);
      // Timeline: all five steps with Nairobi timestamps.
      expect(find.text(l10n.doctorCaseTimelineTitle), findsOneWidget);
      expect(find.text(l10n.doctorCasesOrdered), findsOneWidget);
      expect(
        find.text('${_stamp('2026-10-26T07:20:00Z', 'en')} · Breast excision'),
        findsOneWidget,
      );
      expect(find.text(l10n.doctorCaseSampleReceived), findsOneWidget);
      expect(
        find.text('${_stamp('2026-10-27T06:05:00Z', 'en')} · Breast excision'),
        findsOneWidget,
      );
      expect(find.text(l10n.doctorCaseReading), findsOneWidget);
      expect(find.text('Dr. Achieng Odhiambo'), findsOneWidget);
      expect(find.text(l10n.doctorCaseReportSigned), findsOneWidget);
      expect(find.text(l10n.doctorCaseDiscussWith('Mary')), findsOneWidget);
      expect(find.text(l10n.doctorCaseDiscussDetail), findsOneWidget);
      // Order card: test, specimen, priority; no risk row on the model.
      expect(find.text(l10n.doctorCaseOrder), findsOneWidget);
      expect(find.text(l10n.doctorCaseTest), findsOneWidget);
      expect(find.text('Breast excision'), findsWidgets);
      expect(find.text(l10n.doctorCaseSpecimen), findsOneWidget);
      expect(find.text('Right breast · wide local excision'), findsOneWidget);
      expect(find.text(l10n.doctorCaseRoutine), findsOneWidget);
      expect(find.text(l10n.doctorCaseRiskCheck), findsNothing);
      // Unsigned and not needs-you: no report button.
      expect(find.text(l10n.doctorReportOpenFull), findsNothing);
    });

    testWidgets('marks two steps done, reading now, two next', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: [_case()]));

      expect(find.text(l10n.chipDone), findsNWidgets(2));
      expect(find.text(l10n.doctorCaseNow), findsOneWidget);
      expect(find.text(l10n.doctorCaseNext), findsNWidgets(2));
      expect(find.text(l10n.doctorCaseAttachPathologist), findsNothing);
    });

    testWidgets('without a lab receipt, sample received shows the order time '
        'and the test', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [
            _case(
              currentStage: 'OrderCreated',
              pathologistName: '',
              sampleReceivedAt: '',
            ),
          ],
        ),
      );

      // The same line reads under Ordered and under Sample received.
      expect(
        find.text('${_stamp('2026-10-26T07:20:00Z', 'en')} · Breast excision'),
        findsNWidgets(2),
      );
    });

    testWidgets('an unsent order has its sample and links to attach', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(
          cases: [
            _case(
              currentStage: 'OrderCreated',
              pathologistName: '',
              sampleReceivedAt: '',
            ),
          ],
        ),
      );
      when(
        () => blocs.appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: [_appointment()]));
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));
      final routes = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                ...blocs.providers,
              ],
              child: const DoctorCaseScreen(caseUid: 'case-1'),
            ),
          ),
          GoRoute(
            path: '/doctor/order',
            builder: (_, state) => Text(
              'stub order ${state.uri.queryParameters['appointment-uid']} '
              '${state.uri.queryParameters['case-uid']}',
            ),
          ),
        ],
      );
      addTearDown(routes.dispose);
      await tester.pumpRouterApp(routes);
      await tester.pump();

      // Ordered and sample received are checked; the reading step is now.
      expect(find.text(l10n.chipDone), findsNWidgets(2));
      expect(find.text(l10n.doctorCaseNow), findsOneWidget);
      await tester.tap(find.text(l10n.doctorCaseAttachPathologist));
      await tester.pumpAndSettle();
      expect(find.text('stub order appt-1 case-1'), findsOneWidget);
    });

    testWidgets('a refused case links the reading step back to the order', (
      tester,
    ) async {
      _useTallSurface(tester);
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(
          cases: [
            _case(currentStage: 'PathologistRejected', sampleReceivedAt: ''),
          ],
        ),
      );
      when(
        () => blocs.appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: [_appointment()]));
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));

      // A fresh router per pass, with the old tree unmounted first: a
      // reused router keeps its pushed stack across pumps.
      for (final scale in _scales) {
        for (final locale in _locales) {
          _useTextScale(tester, scale);
          final l10n = lookupAppLocalizations(locale);
          final routes = GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => MultiBlocProvider(
                  providers: [
                    BlocProvider<AuthBloc>.value(value: authBloc),
                    ...blocs.providers,
                  ],
                  child: const DoctorCaseScreen(caseUid: 'case-1'),
                ),
              ),
              GoRoute(
                path: '/doctor/order',
                builder: (_, state) => Text(
                  'stub order ${state.uri.queryParameters['appointment-uid']} '
                  '${state.uri.queryParameters['case-uid']}',
                ),
              ),
            ],
          );
          addTearDown(routes.dispose);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpRouterApp(routes, locale: locale);
          await tester.pump();

          final link = find.text(l10n.doctorCaseAttachPathologist);
          await tester.scrollUntilVisible(link, 500);
          expect(link, findsOneWidget);
          await tester.tap(link);
          await tester.pumpAndSettle();
          expect(find.text('stub order appt-1 case-1'), findsOneWidget);
        }
      }
    });

    testWidgets('a decline reads who refused and why', (tester) async {
      _useTallSurface(tester);
      const reason = 'Fully booked this week';
      final cases = CasesLoadSuccess(
        cases: [_case(currentStage: 'PathologistRejected')],
        logs: const {
          'case-1': [
            CaseLogEntryModel(
              toStage: 'PathologistRejected',
              actionType: 'Reject',
              actionReason: reason,
            ),
          ],
        },
      );

      for (final scale in _scales) {
        for (final locale in _locales) {
          _useTextScale(tester, scale);
          final l10n = lookupAppLocalizations(locale);
          await pumpScreen(tester, cases: cases, locale: locale);

          expect(find.text(l10n.doctorCaseAttachPathologist), findsOneWidget);
          final line = find.text(
            l10n.doctorCaseDeclinedBy('Dr. Achieng Odhiambo', reason),
          );
          await tester.scrollUntilVisible(line, 500);
          expect(line, findsOneWidget);
        }
      }
    });

    testWidgets('a decline with no name on the case still reads the reason', (
      tester,
    ) async {
      _useTallSurface(tester);
      const reason = 'Fully booked this week';
      final cases = CasesLoadSuccess(
        cases: [
          _case(currentStage: 'PathologistRejected', pathologistName: ''),
        ],
        logs: const {
          'case-1': [
            CaseLogEntryModel(
              toStage: 'PathologistRejected',
              actionType: 'Reject',
              actionReason: reason,
            ),
          ],
        },
      );

      for (final locale in _locales) {
        final l10n = lookupAppLocalizations(locale);
        await pumpScreen(tester, cases: cases, locale: locale);

        final line = find.text(l10n.doctorCaseDeclined(reason));
        await tester.scrollUntilVisible(line, 500);
        expect(line, findsOneWidget);
      }
    });

    testWidgets('a lapse with no decline says the request lapsed', (
      tester,
    ) async {
      _useTallSurface(tester);
      final cases = CasesLoadSuccess(
        cases: [_case(currentStage: 'PathologistRejected')],
        logs: const {
          'case-1': [
            CaseLogEntryModel(
              toStage: 'PathologistRejected',
              actionType: 'Expire',
            ),
          ],
        },
      );

      for (final scale in _scales) {
        for (final locale in _locales) {
          _useTextScale(tester, scale);
          final l10n = lookupAppLocalizations(locale);
          await pumpScreen(tester, cases: cases, locale: locale);

          expect(find.text(l10n.doctorCaseAttachPathologist), findsOneWidget);
          final line = find.text(l10n.doctorCaseRequestLapsed);
          await tester.scrollUntilVisible(line, 500);
          expect(line, findsOneWidget);
        }
      }
    });

    testWidgets('falls back to the facility without an appointment', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: [_case(appointmentUid: '')]),
        appointments: const [],
      );

      expect(find.text('Aga Khan University Hospital'), findsOneWidget);
      expect(find.textContaining('Appointment'), findsNothing);
      expect(find.text(l10n.doctorCasesWithPathologist), findsOneWidget);
    });

    testWidgets('shows the name alone when the age is missing', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: [_case(patientAgeYears: 0)]),
      );

      expect(find.text('Mary Njeri'), findsOneWidget);
      expect(find.textContaining(', 0'), findsNothing);
    });

    testWidgets('reads the signed time from the log and offers the report', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [_case(currentStage: 'ReportSigned')],
          logs: const {
            'case-1': [
              CaseLogEntryModel(
                toStage: 'ReportSigned',
                createdAt: '2026-10-27T07:42:00Z',
              ),
            ],
          },
        ),
      );

      expect(find.text(_stamp('2026-10-27T07:42:00Z', 'en')), findsOneWidget);
      expect(find.text(l10n.chipDone), findsNWidgets(4));
      expect(find.text(l10n.doctorReportOpenFull), findsOneWidget);
    });

    testWidgets('names the report in progress while reporting', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [_case(currentStage: 'ReportInProgress')],
        ),
      );

      expect(
        find.text('Dr. Achieng Odhiambo · ${l10n.doctorCaseReportInProgress}'),
        findsOneWidget,
      );
      expect(find.text(l10n.doctorCaseReportInProgress), findsOneWidget);
    });

    testWidgets('a needs-you case opens the report', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(
          cases: [
            _case(currentStage: 'ReportSigned', resultState: 'WithDoctor'),
          ],
        ),
      );
      when(
        () => blocs.appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: [_appointment()]));
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));
      Widget withBlocs(Widget child) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          ...blocs.providers,
        ],
        child: child,
      );
      final routes = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                withBlocs(const DoctorCaseScreen(caseUid: 'case-1')),
          ),
          GoRoute(
            path: '/doctor/case/:caseUid/report',
            builder: (_, state) =>
                Text('stub report ${state.pathParameters['caseUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      await tester.pumpRouterApp(routes);
      await tester.pump();

      expect(find.text(l10n.doctorCasesDiscuss), findsOneWidget);
      await tester.tap(find.text(l10n.doctorReportOpenFull));
      await tester.pumpAndSettle();
      expect(find.text('stub report case-1'), findsOneWidget);
    });

    testWidgets('the history row opens the case history', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      when(
        () => blocs.cases.state,
      ).thenReturn(CasesLoadSuccess(cases: [_case()]));
      when(
        () => blocs.appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: [_appointment()]));
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));
      Widget withBlocs(Widget child) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          ...blocs.providers,
        ],
        child: child,
      );
      final routes = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                withBlocs(const DoctorCaseScreen(caseUid: 'case-1')),
          ),
          GoRoute(
            path: '/doctor/case/:caseUid/history',
            builder: (_, state) =>
                Text('stub history ${state.pathParameters['caseUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      await tester.pumpRouterApp(routes);
      await tester.pump();

      await tester.tap(find.text(l10n.accessLogTitle));
      await tester.pumpAndSettle();
      expect(find.text('stub history case-1'), findsOneWidget);
    });

    testWidgets('a case with no tests shows the stage alone', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [_case(testName: '', sampleNotes: '', priority: 'Urgent')],
        ),
      );

      expect(
        find.text(l10n.doctorCaseSubtitle('Breast excision', 'x')),
        findsNothing,
      );
      expect(find.text('with pathologist'), findsOneWidget);
      expect(find.text(l10n.doctorCaseTest), findsNothing);
      expect(find.text(l10n.doctorCaseSpecimen), findsNothing);
      expect(find.text(l10n.doctorCaseUrgent), findsOneWidget);
    });

    testWidgets('maps the middle priority tier', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: [_case(priority: 'Priority')]),
      );

      // The row label reads Priority too.
      expect(find.text(l10n.urgencyPriority), findsNWidgets(2));
    });

    testWidgets('a missing case shows not found', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: [_case()]),
        caseUid: 'no-such-case',
      );

      expect(find.text(l10n.errorDataNotFound), findsOneWidget);
      expect(find.byType(KeyValueCard), findsNothing);
      verify(
        () => blocs.cases.add(
          const CaseLogRequested(caseUid: 'no-such-case', role: .doctor),
        ),
      ).called(1);
    });

    testWidgets('loading shows the spinner', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, cases: const CasesLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('renders in Swahili, dark, at 1.3x', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(
        () => tester.platformDispatcher.clearTextScaleFactorTestValue(),
      );
      final l10n = lookupAppLocalizations(const Locale('sw'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [
            _case(
              patientName: 'Consolata Wanjiku Muthoni',
              patientAgeYears: 61,
            ),
          ],
        ),
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );

      expect(find.text('ODR-JK-MN-02112026-002'), findsOneWidget);
      expect(find.text('Consolata Wanjiku Muthoni, 61'), findsOneWidget);
      expect(find.text(l10n.doctorCaseTimelineTitle), findsOneWidget);
      expect(
        find.text(l10n.doctorCaseDiscussWith('Consolata')),
        findsOneWidget,
      );
      expect(find.text(l10n.doctorCaseOrder), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
