// cspell:ignore amína Amna Wambu zzzqqq
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/cases/presentation/cases_screen.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_row.dart';
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

CaseModel _case({
  required String uid,
  String orderNumber = 'ODR-JK-AW-02112026-001',
  String patientName = 'Amina Wambui',
  String currentStage = 'PathologistAccepted',
  String resultState = 'Pending',
  String testName = 'Breast excision',
  String createdAt = '',
}) => CaseModel(
  uid: uid,
  orderNumber: orderNumber,
  patientName: patientName,
  currentStage: currentStage,
  resultState: resultState,
  createdAt: createdAt,
  tests: testName.isEmpty ? const [] : [OrderedTestModel(name: testName)],
);

void main() {
  setUpAll(() {
    registerFallbackValue(const CasesRequested(uid: '', role: .doctor));
  });

  group('CasesScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    Future<void> pumpScreen(
      WidgetTester tester, {
      CasesState? cases,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      when(
        () => blocs.cases.state,
      ).thenReturn(cases ?? const CasesLoadSuccess());
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.doctor()));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: const CasesScreen(),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
    }

    GoRouter routerWith(CasesState cases) {
      when(() => blocs.cases.state).thenReturn(cases);
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
          GoRoute(path: '/', builder: (_, _) => withBlocs(const CasesScreen())),
          GoRoute(
            path: '/doctor/case/:caseUid',
            builder: (_, state) =>
                Text('stub case ${state.pathParameters['caseUid']}'),
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

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => blocs.cases.add(any())).thenReturn(null);
    });

    List<CaseModel> nineCases() => [
      _case(
        uid: 'needs',
        currentStage: 'ReportSigned',
        resultState: 'WithDoctor',
        testName: 'Sentinel lymph node',
      ),
      _case(
        uid: 'prog-path',
        orderNumber: 'ODR-JK-MN-02112026-002',
        patientName: 'Mary Njeri',
      ),
      _case(
        uid: 'prog-reporting',
        orderNumber: 'ODR-JK-PK-02112026-003',
        patientName: 'Peter Kiprono',
        currentStage: 'ReportInProgress',
        testName: 'Lymph node FNA',
      ),
      _case(
        uid: 'signed',
        orderNumber: 'ODR-JK-JM-02112026-004',
        patientName: 'Joseph Mwangi',
        currentStage: 'ReportSigned',
        testName: 'Blood smear',
      ),
      _case(
        uid: 'ordered',
        orderNumber: 'ODR-JK-GA-02112026-005',
        patientName: 'Grace Atieno',
        currentStage: 'OrderCreated',
        testName: 'Core biopsy',
      ),
      for (var i = 0; i < 4; i++)
        _case(
          uid: 'done-$i',
          orderNumber: 'ODR-JK-ZZ-0101202$i-00$i',
          patientName: 'Zawadi Mwezi',
          currentStage: 'Completed',
          testName: 'Slide review',
          createdAt: '2024-0${i + 1}-15T09:00:00Z',
        ),
    ];

    testWidgets('sections, subtitle and chips follow the data', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      expect(find.text(l10n.tabCases), findsOneWidget);
      expect(find.text(l10n.doctorCasesSubtitle(5, 1)), findsOneWidget);
      expect(find.text(l10n.doctorCasesNeedsYou), findsOneWidget);
      expect(find.text(l10n.doctorCasesInProgress), findsOneWidget);
      expect(find.text(l10n.doctorCasesDone), findsOneWidget);
      // Five open, four done: Done shows three with a See all.
      expect(find.byType(CaseRow), findsNWidgets(8));
      expect(find.text(l10n.doctorCasesSeeAll), findsOneWidget);
      // Chips: All with the count, the four states.
      expect(find.text(l10n.doctorCasesFilterAll(9)), findsOneWidget);
      expect(find.text(l10n.doctorCasesOrdered), findsWidgets);
      expect(find.text(l10n.doctorCasesWithPathologist), findsWidgets);
      expect(find.text(l10n.doctorCasesSigned), findsWidgets);
    });

    testWidgets('rows show the number, test and status', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      expect(
        find.text('ODR-JK-AW-02112026-001 · Sentinel lymph node'),
        findsOneWidget,
      );
      expect(
        find.text('ODR-JK-MN-02112026-002 · Breast excision'),
        findsOneWidget,
      );
      expect(find.text(l10n.doctorCasesDiscuss), findsWidgets);
      expect(find.text(l10n.doctorCaseReportInProgress), findsOneWidget);
    });

    testWidgets('a case with no tests shows the order number alone', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          cases: [_case(uid: 'bare', testName: '')],
        ),
      );

      expect(find.text('ODR-JK-AW-02112026-001'), findsOneWidget);
    });

    testWidgets('See all switches the chip to Closed', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      await tester.tap(find.text(l10n.doctorCasesSeeAll));
      await tester.pump();
      // All four done rows now, newest first.
      expect(find.byType(CaseRow), findsNWidgets(4));
      expect(
        find.text('ODR-JK-ZZ-01012023-003 · Slide review'),
        findsOneWidget,
      );
      expect(
        find.text('ODR-JK-ZZ-01012020-000 · Slide review'),
        findsOneWidget,
      );
    });

    testWidgets('the filters sit in one horizontal scroll row', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      final scrollers = find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      );
      expect(scrollers, findsOneWidget);
    });

    testWidgets('chips and search combine', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      final withPathologist = find.text(l10n.doctorCasesWithPathologist).first;
      await tester.ensureVisible(withPathologist);
      await tester.pump();
      await tester.tap(withPathologist);
      await tester.pump();
      expect(find.byType(CaseRow), findsNWidgets(2));

      await tester.enterText(find.byType(SearchField), 'peter');
      await tester.pump();
      expect(find.byType(CaseRow), findsOneWidget);
      expect(
        find.text('ODR-JK-PK-02112026-003 · Lymph node FNA'),
        findsOneWidget,
      );
    });

    testWidgets('search folds case and accents', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      await tester.enterText(find.byType(SearchField), 'amína');
      await tester.pump();
      expect(find.byType(CaseRow), findsOneWidget);
      expect(
        find.text('ODR-JK-AW-02112026-001 · Sentinel lymph node'),
        findsOneWidget,
      );
    });

    testWidgets('a wrong case number shows the check block', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      await tester.enterText(find.byType(SearchField), 'ODR-JK-AW-02112026-01');
      await tester.pump();

      expect(find.text(l10n.caseSearchHint), findsOneWidget);
      expect(find.text(l10n.doctorCasesCheckNumber), findsOneWidget);
      expect(find.text(l10n.doctorCasesCheckNumberBody), findsOneWidget);
      expect(find.text(l10n.caseSearchClosestMatch), findsOneWidget);
      expect(
        find.text('ODR-JK-AW-02112026-001 · Amina Wambui'),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.resultsClearSearch));
      await tester.pump();
      expect(find.byType(CaseRow), findsNWidgets(8));
    });

    testWidgets('no match shows did-you-mean with the pill and tips', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      await tester.enterText(find.byType(SearchField), 'Amna Wambu');
      await tester.pump();

      expect(
        find.text(l10n.doctorCasesNoMatchTitle('Amna Wambu')),
        findsOneWidget,
      );
      expect(find.text(l10n.doctorCasesNoMatchBody), findsOneWidget);
      expect(find.text(l10n.caseSearchDidYouMean), findsOneWidget);
      expect(find.text('Amina Wambui'), findsOneWidget);
      expect(find.byType(TipsCard), findsOneWidget);
      expect(find.text(l10n.doctorCasesTipSearch), findsOneWidget);
      expect(find.text(l10n.doctorCasesTipSeen), findsOneWidget);

      // The pill runs the suggested search.
      await tester.tap(find.text('Amina Wambui'));
      await tester.pump();
      expect(find.byType(CaseRow), findsOneWidget);
    });

    testWidgets('no match and nothing close shows the block without the pill', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: CasesLoadSuccess(cases: nineCases()));

      await tester.enterText(find.byType(SearchField), 'zzzqqq');
      await tester.pump();

      expect(find.text(l10n.doctorCasesNoMatchTitle('zzzqqq')), findsOneWidget);
      expect(find.text(l10n.caseSearchDidYouMean), findsNothing);
      expect(find.byType(TipsCard), findsOneWidget);
    });

    testWidgets('empty shows the state with no search and no chips', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: const CasesLoadSuccess());

      expect(find.text(l10n.tabCases), findsOneWidget);
      expect(find.text(l10n.doctorCasesNoneOpen), findsOneWidget);
      expect(find.text(l10n.doctorCasesEmptyTitle), findsOneWidget);
      expect(find.text(l10n.doctorCasesEmptyBody), findsOneWidget);
      expect(find.byType(SearchField), findsNothing);
      expect(find.byType(TabibuFilterChip), findsNothing);
      expect(find.byType(TabibuButton), findsNothing);
    });

    testWidgets('offline shows the banner above cached rows', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: nineCases(), offline: true),
      );

      expect(find.byType(ConnectivityBanner), findsOneWidget);
      expect(find.text(l10n.notificationsOfflineTitle), findsOneWidget);
      expect(find.byType(CaseRow), findsNWidgets(8));
    });

    testWidgets('loading shows the spinner', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, cases: const CasesLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(CaseRow), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('needs-you and signed rows open the report, others the case', (
      tester,
    ) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(
        routerWith(CasesLoadSuccess(cases: nineCases())),
      );
      await tester.pump();

      await tester.tap(
        find.text('ODR-JK-AW-02112026-001 · Sentinel lymph node'),
      );
      await tester.pumpAndSettle();
      expect(find.text('stub report needs'), findsOneWidget);
    });

    testWidgets('unsigned rows open the case', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(
        routerWith(CasesLoadSuccess(cases: nineCases())),
      );
      await tester.pump();

      await tester.tap(find.text('ODR-JK-MN-02112026-002 · Breast excision'));
      await tester.pumpAndSettle();
      expect(find.text('stub case prog-path'), findsOneWidget);
    });

    testWidgets('refresh keeps the query and the chip', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(cases: nineCases(), offline: true),
      );

      await tester.enterText(find.byType(SearchField), 'zawadi');
      final closed = find.text(l10n.doctorCasesClosed).first;
      await tester.ensureVisible(closed);
      await tester.pump();
      await tester.tap(closed);
      await tester.pump();
      expect(find.byType(CaseRow), findsNWidgets(4));

      // The banner's retry is the same refresh dispatch as the pull.
      await tester.tap(find.text(l10n.commonRetry));
      await tester.pump();
      verify(
        () => blocs.cases.add(const CasesRefreshed(uid: '', role: Role.doctor)),
      ).called(1);
      expect(find.byType(CaseRow), findsNWidgets(4));
      expect(
        find.text('ODR-JK-ZZ-01012023-003 · Slide review'),
        findsOneWidget,
      );
    });

    testWidgets('a refreshed case moves from In progress to Needs you', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      final waiting = _case(uid: 'moving');
      final before = CasesLoadSuccess(cases: [waiting]);
      final moved = CasesLoadSuccess(
        cases: [
          waiting.copyWith(
            currentStage: 'ReportSigned',
            resultState: 'WithDoctor',
          ),
        ],
      );
      final inbox = StreamController<CasesState>.broadcast();
      addTearDown(inbox.close);
      whenListen(blocs.cases, inbox.stream, initialState: before);
      await pumpScreen(tester, cases: before);
      expect(find.text(l10n.doctorCasesNeedsYou), findsNothing);

      when(() => blocs.cases.state).thenReturn(moved);
      inbox.add(moved);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(l10n.doctorCasesNeedsYou), findsOneWidget);
      expect(find.text(l10n.doctorCasesSubtitle(1, 1)), findsOneWidget);
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
        cases: CasesLoadSuccess(cases: nineCases()),
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );

      expect(find.text(l10n.tabCases), findsOneWidget);
      expect(find.text(l10n.doctorCasesSubtitle(5, 1)), findsOneWidget);
      expect(find.text(l10n.doctorCasesNeedsYou), findsOneWidget);
      expect(find.text(l10n.doctorCasesCheckNumber), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
