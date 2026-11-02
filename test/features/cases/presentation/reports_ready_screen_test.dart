import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/cases/presentation/reports_ready_screen.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PractitionerSession _session() {
  final base = RoleSessions.doctor();
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: 'doctor-1'),
    roles: base.roles,
  );
}

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

CaseModel _case({
  required String uid,
  required String patientName,
  String orderNumber = 'TB-0231',
  String testName = 'Sentinel lymph node',
  String resultState = 'WithDoctor',
  String currentReportUid = '',
}) => CaseModel(
  uid: uid,
  orderNumber: orderNumber,
  patientName: patientName,
  resultState: resultState,
  currentReportUid: currentReportUid,
  tests: [OrderedTestModel(name: testName)],
);

void main() {
  group('ReportsReadyScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    });

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/ready',
        routes: [
          GoRoute(
            path: '/ready',
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                ...blocs.providers,
              ],
              child: const ReportsReadyScreen(),
            ),
          ),
          GoRoute(
            path: '/doctor/case/:caseUid/report',
            builder: (_, state) =>
                Text('stub report ${state.pathParameters['caseUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      required CasesState cases,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      when(() => blocs.cases.state).thenReturn(cases);
      await tester.pumpRouterApp(
        router(),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    final readyCases = [
      _case(
        uid: 'case-old',
        patientName: 'Peter Kiprono',
        orderNumber: 'TB-0233',
        testName: 'Lymph node FNA',
        currentReportUid: 'report-old',
      ),
      _case(
        uid: 'case-new',
        patientName: 'Amina Wambui',
        currentReportUid: 'report-new',
      ),
      _case(
        uid: 'case-update',
        patientName: 'Grace Atieno',
        orderNumber: 'TB-0235',
        testName: 'Skin punch',
        resultState: 'UpdateWithDoctor',
      ),
      _case(
        uid: 'case-released',
        patientName: 'Mary Njeri',
        resultState: 'Released',
      ),
      _case(
        uid: 'case-pending',
        patientName: 'John Otieno',
        resultState: 'Pending',
      ),
    ];

    final reports = [
      const PathologyReportModel(
        uid: 'report-old',
        caseUid: 'case-old',
        signedAt: '2026-10-30T08:00:00Z',
      ),
      const PathologyReportModel(
        uid: 'report-new',
        caseUid: 'case-new',
        signedAt: '2026-11-02T08:00:00Z',
      ),
    ];

    testWidgets('asks for the doctor\u2019s cases on open', (tester) async {
      await pumpScreen(tester, cases: const CasesLoadSuccess());

      verify(
        () => blocs.cases.add(
          const CasesRequested(uid: 'doctor-1', role: Role.doctor),
        ),
      ).called(1);
    });

    testWidgets('lists only signed, undiscussed reports, newest first', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: readyCases, reports: reports),
      );

      expect(find.text('Reports ready'), findsOneWidget);
      expect(find.text('3 signed · discuss with patients'), findsOneWidget);
      expect(find.text('Amina Wambui'), findsOneWidget);
      expect(find.text('TB-0231 · Sentinel lymph node'), findsOneWidget);
      expect(find.text('TB-0233 · Lymph node FNA'), findsOneWidget);
      expect(find.text('Mary Njeri'), findsNothing);
      expect(find.text('John Otieno'), findsNothing);
      expect(find.text('Signed'), findsNWidgets(3));
      expect(
        find.byWidgetPredicate(
          (w) => w is StatusChip && w.tone == StatusTone.signed,
        ),
        findsNWidgets(3),
      );
      expect(find.byType(NoticeCard), findsOneWidget);
      expect(
        find.text('Patients see a report after you mark it as discussed.'),
        findsOneWidget,
      );

      // Newest signature first; no date goes last.
      final order = [
        for (final t in ['Amina Wambui', 'Peter Kiprono', 'Grace Atieno'])
          tester.getTopLeft(find.text(t)).dy,
      ];
      expect(order, [...order]..sort());
    });

    testWidgets('a row opens its report', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: readyCases, reports: reports),
      );

      await tester.tap(find.text('Peter Kiprono'));
      await tester.pumpAndSettle();

      expect(find.text('stub report case-old'), findsOneWidget);
    });

    testWidgets('one report reads as one', (tester) async {
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [_case(uid: 'case-1', patientName: 'Amina Wambui')],
        ),
      );

      expect(find.text('1 signed · discuss with patients'), findsOneWidget);
    });

    testWidgets('nothing ready shows the empty state', (tester) async {
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [
            _case(
              uid: 'case-released',
              patientName: 'Mary Njeri',
              resultState: 'Released',
            ),
          ],
        ),
      );

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No reports ready'), findsOneWidget);
      expect(
        find.text('Signed reports to discuss with patients will show here.'),
        findsOneWidget,
      );
      expect(find.byType(ListRowCard), findsNothing);
      expect(find.byType(NoticeCard), findsNothing);
    });

    testWidgets('loading shows the spinner with its announcement', (
      tester,
    ) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: const CasesLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
      expect(
        find.bySemanticsLabel(l10n.reportsReadyLoadingLabel),
        findsOneWidget,
      );
      expect(find.byType(EmptyState), findsNothing);
    });

    testWidgets('has a labelled back button', (tester) async {
      await pumpScreen(tester, cases: const CasesLoadSuccess());
      expect(
        find.byWidgetPredicate(
          (w) => w is CircleIconButton && w.semanticLabel == 'Back',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      _useTallSurface(tester);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await pumpScreen(
          tester,
          themeMode: mode,
          cases: CasesLoadSuccess(cases: readyCases, reports: reports),
        );
        expect(find.byType(ReportsReadyScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      final sw = lookupAppLocalizations(const Locale('sw'));
      await pumpScreen(
        tester,
        locale: const Locale('sw'),
        cases: CasesLoadSuccess(cases: readyCases, reports: reports),
      );

      expect(find.text(sw.reportsReadyTitle), findsOneWidget);
      expect(find.text(sw.reportsReadyNotice), findsOneWidget);
      expect(find.text(sw.reportsReadySigned), findsNWidgets(3));
    });

    testWidgets('grows at 1.3x in Swahili without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
        cases: CasesLoadSuccess(cases: readyCases, reports: reports),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
