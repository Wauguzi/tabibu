import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/desk_list_screen.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_entry_row.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_rank_badge.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_search_entry.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';
import 'desk_fixtures.dart';

void main() {
  group('DeskListScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    setUpAll(() {
      registerFallbackValue(const DeskReset());
      registerFallbackValue(const CasesReset());
    });

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: deskSession()));
    });

    Widget screen([DeskFilter filter = .all]) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        ...blocs.providers,
      ],
      child: DeskListScreen(filter: filter, now: () => deskNow),
    );

    void stub({
      List<WorklistEntryModel>? entries,
      List<WorklistEntryModel>? visible,
      DeskFilter filter = .all,
      bool offline = false,
    }) {
      final list = entries ?? deskEntries();
      when(() => blocs.desk.state).thenReturn(
        DeskLoadSuccess(
          entries: list,
          visible: visible ?? list,
          filter: filter,
          offline: offline,
        ),
      );
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(cases: [for (var n = 1; n <= 6; n++) deskCase(n)]),
      );
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      DeskFilter filter = .all,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      final router = deskRouter(() => screen(filter));
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router, themeMode: themeMode, locale: locale);
      await tester.pumpAndSettle();
    }

    Finder rows() => find.byType(DeskEntryRow);
    Finder rank(int n) => find.descendant(
      of: find.byType(DeskRankBadge),
      matching: find.text('$n'),
    );

    group('asks for what it shows', () {
      testWidgets('opens on the route filter, then asks for the desk', (
        tester,
      ) async {
        when(() => blocs.desk.state).thenReturn(const DeskInitial());
        final router = deskRouter(() => screen(.lowConfidence));
        addTearDown(router.dispose);
        await tester.pumpRouterApp(router);
        await tester.pump();

        verifyInOrder([
          () => blocs.desk.add(
            const DeskFilterChanged(filter: DeskFilter.lowConfidence),
          ),
          () => blocs.desk.add(const DeskRequested(pathologistUid: deskUid)),
        ]);
        verify(
          () => blocs.cases.add(
            const CasesRequested(uid: deskUid, role: Role.pathologist),
          ),
        ).called(1);
      });

      testWidgets('a loaded desk is not asked for again', (tester) async {
        stub();
        await pumpScreen(tester);

        verifyNever(
          () => blocs.desk.add(const DeskRequested(pathologistUid: deskUid)),
        );
        verifyNever(() => blocs.cases.add(any()));
      });
    });

    group('the chips', () {
      testWidgets('count from every case on the desk', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        expect(find.text('All 6'), findsOneWidget);
        // Ready and low: 2 and 6. Failed case 3 is not counted.
        expect(find.text('Low confidence · 2'), findsOneWidget);
        // Past 4h: 2, 3 and 6.
        expect(find.text('Waiting 4h+ · 3'), findsOneWidget);
        // The malaria profile: 5.
        expect(find.text('Notifiable · 1'), findsOneWidget);
      });

      testWidgets('keep their counts under a filter', (tester) async {
        useTallSurface(tester);
        final list = deskEntries();
        stub(visible: [list[1], list[2], list[5]], filter: .waitingOver4h);
        await pumpScreen(tester, filter: .waitingOver4h);

        expect(find.text('All 6'), findsOneWidget);
        expect(find.text('Waiting 4h+ · 3'), findsOneWidget);
      });

      testWidgets('a tap asks the desk for that filter', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await tester.tap(find.text('Waiting 4h+ · 3'));
        await tester.pump();
        await tester.tap(find.text('Notifiable · 1'));
        await tester.pump();
        await tester.tap(find.text('Low confidence · 2'));
        await tester.pump();
        await tester.tap(find.text('All 6'));
        await tester.pump();

        verifyInOrder([
          () => blocs.desk.add(
            const DeskFilterChanged(filter: DeskFilter.waitingOver4h),
          ),
          () => blocs.desk.add(
            const DeskFilterChanged(filter: DeskFilter.notifiable),
          ),
          () => blocs.desk.add(
            const DeskFilterChanged(filter: DeskFilter.lowConfidence),
          ),
          () => blocs.desk.add(const DeskFilterChanged(filter: DeskFilter.all)),
        ]);
      });
    });

    group('the rows', () {
      testWidgets('rank by the filtered list, not the whole desk', (
        tester,
      ) async {
        useTallSurface(tester);
        final list = deskEntries();
        stub(visible: [list[1], list[2], list[5]], filter: .waitingOver4h);
        await pumpScreen(tester, filter: .waitingOver4h);

        expect(rows(), findsNWidgets(3));
        // Builder index: first visible row is 1, not its place on the desk.
        expect(rank(1), findsOneWidget);
        expect(rank(2), findsOneWidget);
        expect(rank(3), findsOneWidget);
        expect(rank(6), findsNothing);
      });

      testWidgets('low confidence keeps only what the AI actually read', (
        tester,
      ) async {
        useTallSurface(tester);
        // The desk's own filter goes by the stored band alone, which a
        // pre-read that failed still carries.
        final list = [
          deskEntry(1),
          deskEntry(2, band: 'Low', confidence: 0.52),
          deskEntry(3, preread: 'Failed', band: 'Low', confidence: 0.3),
          deskEntry(4, preread: 'Running', band: 'Low', confidence: 0.2),
          deskEntry(5, band: 'Low', confidence: 0.4),
        ];
        stub(
          entries: list,
          visible: [list[1], list[2], list[3], list[4]],
          filter: .lowConfidence,
        );
        await pumpScreen(tester, filter: .lowConfidence);

        expect(rows(), findsNWidgets(2));
        expect(find.text('ODR-JK-AW-02112026-002'), findsOneWidget);
        expect(find.text('ODR-JK-AW-02112026-005'), findsOneWidget);
        expect(find.text('No AI draft'), findsNothing);
        expect(find.text('Low confidence · 52%'), findsOneWidget);
        expect(find.text('Low confidence · 40%'), findsOneWidget);
        expect(find.text('Low confidence · 2'), findsOneWidget);
        expect(find.text('2 cases the AI was unsure about'), findsOneWidget);
      });

      testWidgets('every row wears its AI marking and a row opens its case', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        // Ready: 1, 2, 5, 6.
        expect(find.byType(AiMark), findsNWidgets(4));
        expect(find.text('High 94%'), findsOneWidget);
        expect(find.text('No AI draft'), findsOneWidget);

        await tester.tap(find.text('ODR-JK-AW-02112026-005'));
        await tester.pumpAndSettle();
        expect(find.text('stub case case-5'), findsOneWidget);
      });

      testWidgets('the search field opens search and takes no focus', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        expect(
          tester.widget<TextField>(find.byType(TextField)).autofocus,
          isFalse,
        );
        await tester.tap(find.byType(DeskSearchEntry));
        await tester.pumpAndSettle();
        expect(find.text('stub search'), findsOneWidget);
      });
    });

    group('the subtitle', () {
      testWidgets('is built from the data, per filter', (tester) async {
        useTallSurface(tester);
        final list = deskEntries();
        stub();
        await pumpScreen(tester);
        expect(find.text('6 cases · oldest waiting 9h 0m'), findsOneWidget);

        stub(visible: [list[1], list[2], list[5]], filter: .waitingOver4h);
        await pumpScreen(tester, filter: .waitingOver4h);
        expect(find.text('3 cases waiting over 4 hours'), findsOneWidget);

        stub(visible: [list[4]], filter: .notifiable);
        await pumpScreen(tester, filter: .notifiable);
        expect(
          find.text(
            '1 malaria case · signing adds them to the area alert engine',
          ),
          findsOneWidget,
        );
      });

      testWidgets('is not shown over an empty desk', (tester) async {
        stub(entries: const []);
        await pumpScreen(tester);

        expect(find.textContaining('cases'), findsNothing);
        expect(rows(), findsNothing);
      });
    });

    group('states', () {
      testWidgets('loading shows the spinner and no chips', (tester) async {
        when(() => blocs.desk.state).thenReturn(const DeskLoadInProgress());
        final router = deskRouter(screen);
        addTearDown(router.dispose);
        await tester.pumpRouterApp(router);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(LoadingView), findsOneWidget);
        expect(find.byType(TabibuFilterChip), findsNothing);
      });

      testWidgets('offline keeps the rows it had', (tester) async {
        useTallSurface(tester);
        stub(offline: true);
        await pumpScreen(tester);

        expect(rows(), findsNWidgets(6));
        expect(tester.takeException(), isNull);
      });

      testWidgets('a filter with nothing in it shows no rows', (tester) async {
        useTallSurface(tester);
        stub(visible: const [], filter: .notifiable);
        await pumpScreen(tester, filter: .notifiable);

        expect(rows(), findsNothing);
        expect(find.text('All 6'), findsOneWidget);
      });
    });

    group('looks', () {
      testWidgets('renders in light and dark', (tester) async {
        useTallSurface(tester);
        stub();
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await pumpScreen(tester, themeMode: mode);
          expect(rows(), findsNWidgets(6));
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('Swahili at 1.3x on 390 dp, dark, without overflow', (
        tester,
      ) async {
        usePhoneSurface(tester);
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final sw = lookupAppLocalizations(const Locale('sw'));
        stub();
        await pumpScreen(
          tester,
          themeMode: ThemeMode.dark,
          locale: const Locale('sw'),
        );

        expect(find.text(sw.deskAllCasesTitle), findsOneWidget);
        expect(find.text(sw.deskFilterLowConfidence(2)), findsOneWidget);
        expect(rows(), findsNWidgets(6));
        expect(tester.takeException(), isNull);
        for (var n = 1; n <= 6; n++) {
          expect(
            isOneLine(tester, find.text('ODR-JK-AW-02112026-00$n')),
            isTrue,
            reason: '$n',
          );
        }
      });
    });
  });
}
