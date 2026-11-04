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
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/desk_search_screen.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_entry_row.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';
import 'desk_fixtures.dart';

void main() {
  group('DeskSearchScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    setUpAll(() {
      registerFallbackValue(const DeskReset());
      registerFallbackValue(const CasesReset());
      registerFallbackValue(const NotificationsReset());
    });

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => blocs.desk.isClosed).thenReturn(false);
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: deskSession()));
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        ...blocs.providers,
      ],
      child: DeskSearchScreen(now: () => deskNow),
    );

    void stub({List<WorklistEntryModel>? entries}) {
      final list = entries ?? deskEntries();
      when(
        () => blocs.desk.state,
      ).thenReturn(DeskLoadSuccess(entries: list, visible: list));
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(
          cases: [
            for (var n = 1; n <= 6; n++)
              deskCase(
                n,
                patient: n == 3 ? 'Njeri Mwangi' : 'Amina Wambui',
                age: n == 3 ? 52 : 46,
              ),
          ],
        ),
      );
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      final router = deskRouter(screen);
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router, themeMode: themeMode, locale: locale);
      await tester.pumpAndSettle();
    }

    Future<void> type(WidgetTester tester, String query) async {
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();
    }

    Finder rows() => find.byType(DeskEntryRow);

    testWidgets('does not open the keyboard on its own', (tester) async {
      useTallSurface(tester);
      stub();
      await pumpScreen(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField)).autofocus,
        isFalse,
      );
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('asks for the desk and the cases when it has none', (
      tester,
    ) async {
      final router = deskRouter(screen);
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pump();

      verify(
        () => blocs.desk.add(const DeskRequested(pathologistUid: deskUid)),
      ).called(1);
      verify(
        () => blocs.cases.add(
          const CasesRequested(uid: deskUid, role: Role.pathologist),
        ),
      ).called(1);
    });

    testWidgets('an empty query lists every case with its rank', (
      tester,
    ) async {
      useTallSurface(tester);
      stub();
      await pumpScreen(tester);

      expect(rows(), findsNWidgets(6));
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('typing tells the desk the query', (tester) async {
      useTallSurface(tester);
      stub();
      await pumpScreen(tester);

      await type(tester, 'lymph');

      verify(
        () => blocs.desk.add(const DeskQueryChanged(query: 'lymph')),
      ).called(1);
    });

    testWidgets('closing the screen leaves the desk query empty', (
      tester,
    ) async {
      useTallSurface(tester);
      stub();
      await pumpScreen(tester);
      await type(tester, 'njeri');
      clearInteractions(blocs.desk);

      await tester.pumpWidget(const SizedBox());

      verify(() => blocs.desk.add(const DeskQueryChanged(query: ''))).called(1);
    });

    group('finding', () {
      testWidgets('by patient name, folded for case', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await type(tester, 'NJERI');

        expect(rows(), findsOneWidget);
        expect(find.text('ODR-JK-AW-02112026-003'), findsOneWidget);
        // Rank follows the filtered list (one hit → 1), not the desk index.
        expect(find.text('1'), findsOneWidget);
        expect(find.text('1 result for NJERI'), findsOneWidget);
      });

      testWidgets('by the end of a case number', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await type(tester, '02112026-005');

        expect(rows(), findsOneWidget);
        expect(find.text('ODR-JK-AW-02112026-005'), findsOneWidget);
      });

      testWidgets('by test name', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await type(tester, 'lymph');

        expect(rows(), findsNWidgets(6));
        expect(find.text('6 results for lymph'), findsOneWidget);
      });

      testWidgets('clearing the field brings every case back', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);
        await type(tester, 'njeri');
        expect(rows(), findsOneWidget);

        await type(tester, '');

        expect(rows(), findsNWidgets(6));
      });

      testWidgets('a result opens its case', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);
        await type(tester, 'njeri');

        await tester.tap(find.text('ODR-JK-AW-02112026-003'));
        await tester.pumpAndSettle();

        expect(find.text('stub case case-3'), findsOneWidget);
      });
    });

    group('a number that is not one', () {
      testWidgets('gets the format hint and the closest match', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        // One digit short of 02112026-001.
        await type(tester, 'ODR-JK-AW-0211202-001');

        expect(
          find.text('Case numbers look like ODR-JK-AW-02112026-001.'),
          findsOneWidget,
        );
        expect(find.text('Check the case number'), findsWidgets);
        expect(find.text('Closest match'), findsOneWidget);
        expect(rows(), findsNothing);
        expect(find.text('No results'), findsNothing);

        await tester.tap(find.text('ODR-JK-AW-02112026-001 · Amina W.'));
        await tester.pumpAndSettle();
        expect(find.text('stub case case-1'), findsOneWidget);
      });

      testWidgets('a number still being typed is not an error', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await type(tester, 'ODR-JK-AW-0211');

        expect(find.textContaining('Case numbers look like'), findsNothing);
        expect(rows(), findsNWidgets(6));
      });

      testWidgets('with nothing near, offers only to clear', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await type(tester, 'ODR-ZZ');

        expect(find.text('Closest match'), findsNothing);
        expect(find.text('Clear search'), findsOneWidget);
      });
    });

    group('no results', () {
      testWidgets('says so and links on', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await type(tester, 'zzz');

        expect(find.text('No case zzz on your desk'), findsOneWidget);
        expect(find.text('No results'), findsOneWidget);
        expect(find.text('Look somewhere else'), findsOneWidget);
        expect(find.byType(TipsCard), findsOneWidget);
        expect(
          find.text('Check the number on the slide label'),
          findsOneWidget,
        );

        await tester.tap(find.text('All 6 cases'));
        await tester.pumpAndSettle();
        expect(find.text('stub list all'), findsOneWidget);
      });

      testWidgets('Search Signed goes to the signed reports', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);
        await type(tester, 'zzz');

        await tester.tap(find.text('Search Signed'));
        await tester.pumpAndSettle();

        expect(find.text('stub signed'), findsOneWidget);
      });

      testWidgets('a valid number that is not on the desk is no results', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await type(tester, 'ODR-JK-AW-02112026-099');

        expect(find.text('No results'), findsOneWidget);
        expect(find.textContaining('Case numbers look like'), findsNothing);
      });

      testWidgets('Clear search empties the field and the desk query', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);
        await type(tester, 'zzz');

        await tester.ensureVisible(find.text('Clear search'));
        await tester.tap(find.text('Clear search'));
        await tester.pumpAndSettle();

        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text,
          isEmpty,
        );
        expect(rows(), findsNWidgets(6));
        verify(
          () => blocs.desk.add(const DeskQueryChanged(query: '')),
        ).called(1);
      });

      testWidgets('on an empty desk there is no "All 0 cases" link', (
        tester,
      ) async {
        stub(entries: const []);
        await pumpScreen(tester);

        await type(tester, 'zzz');

        expect(find.text('No results'), findsOneWidget);
        expect(find.textContaining('All 0'), findsNothing);
      });
    });

    group('looks', () {
      testWidgets('renders in light and dark', (tester) async {
        useTallSurface(tester);
        stub();
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await pumpScreen(tester, themeMode: mode);
          await type(tester, 'zzz');
          expect(find.text('No case zzz on your desk'), findsOneWidget);
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

        expect(find.text(sw.deskSearchTitle), findsOneWidget);
        expect(rows(), findsNWidgets(6));
        // The whole case number, on one line (lesson 10).
        expect(isOneLine(tester, find.text('ODR-JK-AW-02112026-001')), isTrue);

        await type(tester, 'zzz');
        expect(find.text(sw.deskSearchNoCase('zzz')), findsOneWidget);
        expect(find.text(sw.deskSearchSigned), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
