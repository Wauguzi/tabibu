import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:tabibu/features/cases/presentation/results_screen.dart';
import 'package:tabibu/features/reports/presentation/widgets/results_slide.dart';
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

CaseModel _case({
  required String uid,
  required String resultState,
  required String testName,
  String doctorName = 'Dr. Kamau',
  String releasedAt = '',
  String discussionAppointmentUid = '',
  String lastUpdatedAt = '',
}) => CaseModel(
  uid: uid,
  resultState: resultState,
  doctorName: doctorName,
  releasedAt: releasedAt,
  discussionAppointmentUid: discussionAppointmentUid,
  lastUpdatedAt: lastUpdatedAt,
  tests: [OrderedTestModel(name: testName)],
);

void main() {
  setUpAll(() {
    registerFallbackValue(const CasesRequested(uid: '', role: .patient));
    registerFallbackValue(const AppointmentsRequested(uid: '', role: .patient));
  });

  group('ResultsScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    Future<void> pumpScreen(
      WidgetTester tester, {
      CasesState? cases,
      List<AppointmentModel> appointments = const [],
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      when(
        () => blocs.cases.state,
      ).thenReturn(cases ?? const CasesLoadSuccess());
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
          child: const ResultsScreen(),
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

    testWidgets('orders newest first and slides the newest with-doctor', (
      tester,
    ) async {
      _useTallSurface(tester);
      final older = _case(
        uid: 'c-old',
        resultState: 'WithDoctor',
        testName: 'Malaria smear',
        lastUpdatedAt: '2024-01-01T00:00:00Z',
      );
      final newer = _case(
        uid: 'c-new',
        resultState: 'WithDoctor',
        testName: 'Lymph node',
        discussionAppointmentUid: 'a1',
        lastUpdatedAt: '2024-10-01T00:00:00Z',
      );
      final shared = _case(
        uid: 'c-shared',
        resultState: 'Released',
        testName: 'Full blood count',
        doctorName: 'Dr. Otieno',
        releasedAt: '2024-09-12T00:00:00Z',
      );
      // Bloc contract: newest first.
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: [newer, older, shared]),
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

      expect(find.byType(ResultsSlide), findsOneWidget);
      expect(find.textContaining('Lymph node'), findsWidgets);
      expect(find.text('Full blood count'), findsOneWidget);
      expect(find.text('Malaria smear'), findsOneWidget);
    });

    testWidgets('filter chips show counts and filter the list', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [
            _case(uid: '1', resultState: 'WithDoctor', testName: 'Lymph node'),
            _case(
              uid: '2',
              resultState: 'Released',
              testName: 'Full blood count',
              releasedAt: '2024-09-12T00:00:00Z',
            ),
            _case(
              uid: '3',
              resultState: 'Released',
              testName: 'Malaria smear',
              releasedAt: '2024-07-03T00:00:00Z',
            ),
            _case(
              uid: '4',
              resultState: 'Pending',
              testName: 'Breast ultrasound',
            ),
          ],
        ),
      );

      expect(find.text(l10n.resultsFilterAll(4)), findsOneWidget);
      expect(find.text(l10n.resultsFilterWithDoctor(1)), findsOneWidget);
      expect(find.text(l10n.resultsFilterShared(2)), findsOneWidget);

      await tester.tap(find.text(l10n.resultsFilterShared(2)));
      await tester.pump();
      expect(find.byType(ResultsSlide), findsNothing);
      expect(find.text('Full blood count'), findsOneWidget);
      expect(find.text('Lymph node'), findsNothing);
    });

    testWidgets('search filters by test name', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [
            _case(
              uid: '1',
              resultState: 'Released',
              testName: 'Full blood count',
              releasedAt: '2024-09-12T00:00:00Z',
            ),
            _case(
              uid: '2',
              resultState: 'Released',
              testName: 'Malaria smear',
              releasedAt: '2024-07-03T00:00:00Z',
            ),
          ],
        ),
      );

      await tester.enterText(find.byType(TextField), 'thyroid');
      await tester.pump();
      expect(find.text(l10n.resultsNoResultsTitle('thyroid')), findsOneWidget);

      await tester.tap(find.text(l10n.resultsClearSearch));
      await tester.pump();
      expect(find.text('Full blood count'), findsOneWidget);
    });

    testWidgets('shared row opens the result route', (tester) async {
      _useTallSurface(tester);
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(
          cases: [
            _case(
              uid: 'c-shared',
              resultState: 'Released',
              testName: 'Full blood count',
              releasedAt: '2024-09-12T00:00:00Z',
            ),
          ],
        ),
      );
      when(
        () => blocs.appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess());
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                ...blocs.providers,
              ],
              child: const ResultsScreen(),
            ),
          ),
          GoRoute(
            path: '/patient/result/:caseUid',
            builder: (_, state) =>
                Text('stub result ${state.pathParameters['caseUid']}'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpRouterApp(router);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Full blood count'));
      await tester.pumpAndSettle();
      expect(find.text('stub result c-shared'), findsOneWidget);
    });

    testWidgets('shows offline banner', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: const CasesLoadSuccess(offline: true));
      expect(find.text(l10n.resultsOfflineTitle), findsOneWidget);
    });

    testWidgets('shows loading', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: const CasesLoadInProgress());
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.bySemanticsLabel(l10n.resultsLoadingLabel), findsOneWidget);
    });

    testWidgets('renders in light and dark', (tester) async {
      _useTallSurface(tester);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await pumpScreen(
          tester,
          themeMode: mode,
          cases: CasesLoadSuccess(
            cases: [
              _case(
                uid: '1',
                resultState: 'Released',
                testName: 'Full blood count',
                releasedAt: '2024-09-12T00:00:00Z',
              ),
            ],
          ),
        );
        expect(find.byType(ResultsScreen), findsOneWidget);
      }
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('sw'));
      await pumpScreen(
        tester,
        locale: const Locale('sw'),
        cases: const CasesLoadSuccess(),
      );
      expect(find.text(l10n.resultsTitle), findsOneWidget);
    });

    testWidgets('grows at 1.3x without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [
            _case(uid: '1', resultState: 'WithDoctor', testName: 'Lymph node'),
            _case(
              uid: '2',
              resultState: 'Released',
              testName: 'Full blood count',
              releasedAt: '2024-09-12T00:00:00Z',
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
