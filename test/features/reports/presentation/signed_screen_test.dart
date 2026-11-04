// cspell:ignore zzzqqq
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/presentation/signed_screen.dart';
import 'package:tabibu/features/reports/presentation/widgets/signed_report_row.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
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

PractitionerSession _session() => PractitionerSession(
  doctor: RoleSessions.pathologist.doctor.copyWith(uid: 'path-1'),
  roles: RoleSessions.pathologist.roles,
);

/// An ISO instant for a Nairobi wall-clock time on a day near today.
String _at({required int plusDays, required int hour, int minute = 0}) {
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
  ).subtract(nairobiOffset).toIso8601String();
}

String _mondayAt(int hour, [int minute = 0]) =>
    _at(plusDays: -(nairobiNow().weekday - 1), hour: hour, minute: minute);

PathologyReportModel _report({
  required String uid,
  required String caseUid,
  String pathologistUid = 'path-1',
  String status = 'Signed',
  String orderNumber = 'ODR-AO-AW-02112026-001',
  String testName = 'Lymph node',
  String signedAt = '',
  String startedAt = '',
  List<NotifiableFindingModel> findings = const [],
}) => PathologyReportModel(
  uid: uid,
  caseUid: caseUid,
  pathologistUid: pathologistUid,
  status: status,
  orderNumber: orderNumber,
  testName: testName,
  signedAt: signedAt,
  startedAt: startedAt,
  notifiableFindings: findings,
);

CaseModel _case(String uid, String patientName) =>
    CaseModel(uid: uid, patientName: patientName);

void main() {
  setUpAll(() {
    registerFallbackValue(const CasesRequested(uid: '', role: .pathologist));
  });

  group('SignedScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    List<PathologyReportModel> signedMine() => [
      _report(
        uid: 'r1',
        caseUid: 'case-1',
        signedAt: _at(plusDays: 0, hour: 10, minute: 42),
        startedAt: _at(plusDays: 0, hour: 10, minute: 24),
      ),
      _report(
        uid: 'r2',
        caseUid: 'case-2',
        orderNumber: 'ODR-AO-MN-02112026-002',
        testName: 'Blood smear',
        signedAt: _at(plusDays: 0, hour: 9, minute: 58),
        startedAt: _at(plusDays: 0, hour: 9, minute: 50),
        findings: const [NotifiableFindingModel(diseaseId: 'malaria')],
      ),
      _report(
        uid: 'r3',
        caseUid: 'case-3',
        orderNumber: 'ODR-AO-PK-02112026-003',
        testName: 'Core biopsy',
        signedAt: _mondayAt(9, 20),
        startedAt: _mondayAt(9),
      ),
      _report(
        uid: 'r-old',
        caseUid: 'case-4',
        orderNumber: 'ODR-AO-GA-02112026-004',
        testName: 'Thin smear',
        signedAt: _at(plusDays: -10, hour: 8, minute: 47),
        startedAt: _at(plusDays: -10, hour: 8, minute: 30),
        findings: const [NotifiableFindingModel(diseaseId: 'malaria')],
      ),
    ];

    List<CaseModel> joinedCases() => [
      _case('case-1', 'Amina Wambui'),
      _case('case-2', 'Mary Njeri'),
      _case('case-3', 'Peter Kiprono'),
      _case('case-4', 'Grace Atieno'),
      _case('case-9', 'Faith Wanjiku'),
    ];

    List<WorklistEntryModel> deskEntries() => const [
      WorklistEntryModel(
        caseUid: 'case-9',
        orderNumber: 'ODR-JK-FW-02112026-009',
        testName: 'Slide review',
      ),
    ];

    int todayCount() => nairobiNow().weekday == DateTime.monday ? 3 : 2;
    int todayMinutes() => nairobiNow().weekday == DateTime.monday ? 15 : 13;

    Future<void> pumpScreen(
      WidgetTester tester, {
      CasesState? cases,
      List<WorklistEntryModel>? desk,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      when(
        () => blocs.cases.state,
      ).thenReturn(cases ?? const CasesLoadSuccess());
      when(
        () => blocs.desk.state,
      ).thenReturn(DeskLoadSuccess(entries: desk ?? deskEntries()));
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: const SignedScreen(),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
    }

    GoRouter routerWith(CasesState cases) {
      when(() => blocs.cases.state).thenReturn(cases);
      when(
        () => blocs.desk.state,
      ).thenReturn(DeskLoadSuccess(entries: deskEntries()));
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
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
            builder: (_, _) => withBlocs(const SignedScreen()),
          ),
          GoRoute(
            path: '/pathologist/case/:caseUid',
            builder: (_, state) =>
                Text('stub case ${state.pathParameters['caseUid']}'),
          ),
          GoRoute(
            path: '/pathologist/case/:caseUid/compare',
            builder: (_, state) =>
                Text('stub compare ${state.pathParameters['caseUid']}'),
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

    testWidgets('today lists the newest first with the tile', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
      );

      expect(find.text(l10n.tabSigned), findsOneWidget);
      expect(find.text(l10n.signedTabSubtitle), findsOneWidget);
      expect(find.byType(ShortcutTile), findsOneWidget);
      expect(find.text('${todayCount()}'), findsOneWidget);
      expect(find.text(l10n.deskSignedToday), findsOneWidget);
      expect(
        find.text(l10n.signedTabAvgMinutes(todayMinutes())),
        findsOneWidget,
      );
      expect(find.text(l10n.signedTabToday), findsOneWidget);
      expect(find.text(l10n.signedTabWeek), findsOneWidget);
      expect(find.text(l10n.signedTabNotifiable), findsWidgets);

      expect(find.byType(SignedReportRow), findsNWidgets(todayCount()));
      expect(find.text('ODR-AO-AW-02112026-001 · Lymph node'), findsOneWidget);
      expect(find.text(l10n.signedTabSignedTime('10:42 AM')), findsOneWidget);
      expect(find.text(l10n.signedTabSent), findsWidgets);
      // Newest first.
      final first = tester.getTopLeft(
        find.text('ODR-AO-AW-02112026-001 · Lymph node'),
      );
      final second = tester.getTopLeft(
        find.text('ODR-AO-MN-02112026-002 · Blood smear'),
      );
      expect(first.dy, lessThan(second.dy));
    });

    testWidgets('notifiable rows carry the chip and the sent line', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
      );

      expect(
        find.text(
          '${l10n.signedTabSignedTime('9:58 AM')} · ${l10n.signedTabEventSent}',
        ),
        findsOneWidget,
      );
      // The row chip, besides the filter chip.
      expect(find.text(l10n.signedTabNotifiable), findsNWidgets(2));
    });

    testWidgets("another signer's reports are never listed", (tester) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          reports: [
            ...signedMine(),
            _report(
              uid: 'r-other',
              caseUid: 'case-1',
              pathologistUid: 'path-9',
              orderNumber: 'ODR-AO-XX-02112026-099',
              testName: 'Stranger test',
              signedAt: _at(plusDays: 0, hour: 11),
            ),
            _report(
              uid: 'r-superseded',
              caseUid: 'case-1',
              status: 'Superseded',
              orderNumber: 'ODR-AO-XX-02112026-098',
              testName: 'Old version',
              signedAt: _at(plusDays: 0, hour: 11),
            ),
            _report(
              uid: 'r-unset',
              caseUid: 'case-1',
              orderNumber: 'ODR-AO-XX-02112026-097',
              testName: 'Unsigned',
            ),
          ],
          cases: joinedCases(),
        ),
      );

      expect(find.byType(SignedReportRow), findsNWidgets(todayCount()));
      expect(find.textContaining('Stranger test'), findsNothing);
      expect(find.textContaining('Old version'), findsNothing);
      expect(find.textContaining('Unsigned'), findsNothing);
    });

    testWidgets('this week counts since Nairobi Monday', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
      );

      await tester.tap(find.text(l10n.signedTabWeek));
      await tester.pump();

      expect(find.text(l10n.signedTabSignedWeek), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byType(SignedReportRow), findsNWidgets(3));
      expect(find.text('ODR-AO-PK-02112026-003 · Core biopsy'), findsOneWidget);
    });

    testWidgets('notifiable keeps the today tile and any date', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      final oldAt = nairobiTimeOf(_at(plusDays: -10, hour: 8, minute: 47))!;
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
      );

      await tester.tap(find.text(l10n.signedTabNotifiable).first);
      await tester.pump();

      expect(find.text(l10n.deskSignedToday), findsOneWidget);
      expect(find.text('${todayCount()}'), findsOneWidget);
      expect(find.byType(SignedReportRow), findsNWidgets(2));
      // Older rows show a weekday date, never a time.
      final date = DateFormat('EEE d MMM', 'en').format(oldAt);
      expect(
        find.text(
          '${l10n.signedTabSignedDate(date)}'
          ' · ${l10n.signedTabEventSent}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a report signed at 23:30 Nairobi counts as today', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          reports: [
            _report(
              uid: 'r-late',
              caseUid: 'case-1',
              orderNumber: 'ODR-AO-LL-02112026-010',
              testName: 'Late smear',
              signedAt: _at(plusDays: 0, hour: 23, minute: 30),
            ),
          ],
          cases: joinedCases(),
        ),
      );

      expect(find.text(l10n.deskSignedToday), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('ODR-AO-LL-02112026-010 · Late smear'), findsOneWidget);
    });

    testWidgets('the average skips missing and negative durations', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          reports: [
            _report(
              uid: 'r-good',
              caseUid: 'case-1',
              signedAt: _at(plusDays: 0, hour: 10, minute: 30),
              startedAt: _at(plusDays: 0, hour: 10),
            ),
            _report(
              uid: 'r-backwards',
              caseUid: 'case-1',
              orderNumber: 'ODR-AO-BB-02112026-011',
              testName: 'Backwards',
              signedAt: _at(plusDays: 0, hour: 10),
              startedAt: _at(plusDays: 0, hour: 11),
            ),
            _report(
              uid: 'r-no-start',
              caseUid: 'case-1',
              orderNumber: 'ODR-AO-CC-02112026-012',
              testName: 'No start',
              signedAt: _at(plusDays: 0, hour: 9),
            ),
          ],
          cases: joinedCases(),
        ),
      );

      expect(find.text(l10n.signedTabAvgMinutes(30)), findsOneWidget);
    });

    testWidgets('the average hides when nothing has both times', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          reports: [
            _report(
              uid: 'r-no-start',
              caseUid: 'case-1',
              signedAt: _at(plusDays: 0, hour: 9),
            ),
          ],
          cases: joinedCases(),
        ),
      );

      expect(find.textContaining('Avg'), findsNothing);
      expect(find.textContaining('min a case'), findsNothing);
    });

    testWidgets('search filters on number, test and patient', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
      );

      await tester.enterText(find.byType(SearchField), 'mary');
      await tester.pump();
      expect(find.byType(SignedReportRow), findsOneWidget);
      expect(find.text('ODR-AO-MN-02112026-002 · Blood smear'), findsOneWidget);

      await tester.enterText(find.byType(SearchField), 'core biopsy');
      await tester.tap(
        find.text(lookupAppLocalizations(const Locale('en')).signedTabWeek),
      );
      await tester.pump();
      expect(find.byType(SignedReportRow), findsOneWidget);
      expect(find.text('ODR-AO-PK-02112026-003 · Core biopsy'), findsOneWidget);
    });

    testWidgets('no match on the desk offers the case', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.pumpRouterApp(
        routerWith(
          CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(SearchField), 'Wanjiku');
      await tester.pump();

      expect(find.byType(ShortcutTile), findsNothing);
      expect(find.byType(TabibuFilterChip), findsNothing);
      expect(
        find.text(l10n.signedTabNoResultsTitle('Wanjiku')),
        findsOneWidget,
      );
      expect(find.text(l10n.signedTabStillOnDesk), findsOneWidget);
      expect(find.text(l10n.signedTabGoToCase), findsOneWidget);
      expect(
        find.text(l10n.signedTabOpenCase('ODR-JK-FW-02112026-009')),
        findsOneWidget,
      );
      expect(find.byType(TipsCard), findsOneWidget);
      expect(find.text(l10n.signedTabNoResultsTip), findsOneWidget);

      await tester.tap(
        find.text(l10n.signedTabOpenCase('ODR-JK-FW-02112026-009')),
      );
      await tester.pumpAndSettle();
      expect(find.text('stub case case-9'), findsOneWidget);
    });

    testWidgets('no match off the desk shows tips and clear only', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
      );

      await tester.enterText(find.byType(SearchField), 'zzzqqq');
      await tester.pump();

      expect(find.text(l10n.signedTabNoResultsTitle('zzzqqq')), findsOneWidget);
      expect(find.text(l10n.signedTabStillOnDesk), findsNothing);
      expect(find.text(l10n.signedTabGoToCase), findsNothing);
      expect(find.byType(TipsCard), findsOneWidget);

      await tester.tap(find.text(l10n.resultsClearSearch));
      await tester.pump();
      expect(find.byType(SignedReportRow), findsNWidgets(todayCount()));
    });

    testWidgets('an order-number-shaped query shows the format hint', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
      );

      await tester.enterText(find.byType(SearchField), 'ODR-AO');
      await tester.pump();

      expect(find.text(l10n.caseSearchHint), findsOneWidget);
      expect(find.byType(SignedReportRow), findsWidgets);
    });

    testWidgets('empty fetches and shows the state alone', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(tester, cases: const CasesLoadSuccess());

      verify(
        () => blocs.cases.add(
          const CasesRequested(uid: 'path-1', role: Role.pathologist),
        ),
      ).called(1);
      expect(find.text(l10n.tabSigned), findsOneWidget);
      expect(find.text(l10n.signedTabSubtitle), findsOneWidget);
      expect(find.text(l10n.signedTabEmptyTitle), findsOneWidget);
      expect(find.text(l10n.signedTabEmptyBody), findsOneWidget);
      expect(find.byType(SearchField), findsNothing);
      expect(find.byType(ShortcutTile), findsNothing);
      expect(find.byType(TabibuFilterChip), findsNothing);
    });

    testWidgets('offline shows the banner above cached rows', (tester) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await pumpScreen(
        tester,
        cases: CasesLoadSuccess(
          reports: signedMine(),
          cases: joinedCases(),
          offline: true,
        ),
      );

      expect(find.byType(ConnectivityBanner), findsOneWidget);
      expect(find.text(l10n.notificationsOfflineTitle), findsOneWidget);
      expect(find.byType(SignedReportRow), findsNWidgets(todayCount()));

      await tester.tap(find.text(l10n.commonRetry));
      await tester.pump();
      verify(
        () => blocs.cases.add(
          const CasesRefreshed(uid: 'path-1', role: Role.pathologist),
        ),
      ).called(1);
    });

    testWidgets('loading shows the spinner', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, cases: const CasesLoadInProgress());

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(SignedReportRow), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('a row opens the workspace', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(
        routerWith(
          CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('ODR-AO-AW-02112026-001 · Lymph node'));
      await tester.pumpAndSettle();
      expect(find.text('stub case case-1'), findsOneWidget);
    });

    testWidgets('compare opens the comparison, not the workspace', (
      tester,
    ) async {
      _useTallSurface(tester);
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.pumpRouterApp(
        routerWith(
          CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text(l10n.signedTabCompare).first);
      await tester.pumpAndSettle();
      expect(find.text('stub compare case-1'), findsOneWidget);
      expect(find.text('stub case case-1'), findsNothing);
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
        cases: CasesLoadSuccess(reports: signedMine(), cases: joinedCases()),
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );

      expect(find.text(l10n.tabSigned), findsOneWidget);
      expect(find.text(l10n.signedTabSubtitle), findsOneWidget);
      expect(find.text(l10n.deskSignedToday), findsOneWidget);
      expect(find.text(l10n.signedTabToday), findsOneWidget);
      expect(find.byType(SignedReportRow), findsNWidgets(todayCount()));
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
