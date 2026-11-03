import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/presentation/widgets/appointment_hero_card.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';
import 'package:tabibu/features/worklist/presentation/desk_screen.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/features/worklist/presentation/widgets/case_thumb.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_entry_row.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_headline.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_rank_badge.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_search_entry.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';
import 'desk_fixtures.dart';

PathologyReportModel _report({
  required String signedAt,
  String startedAt = '',
  String uid = deskUid,
  String status = 'Signed',
}) => PathologyReportModel(
  pathologistUid: uid,
  status: status,
  signedAt: signedAt,
  startedAt: startedAt,
);

void main() {
  group('DeskScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;
    late DateTime clock;

    setUpAll(() {
      registerFallbackValue(const DeskReset());
      registerFallbackValue(const CasesReset());
      registerFallbackValue(const NotificationsReset());
    });

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      clock = deskNow;
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: deskSession()));
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        ...blocs.providers,
      ],
      child: DeskScreen(now: () => clock),
    );

    void stub({
      List<WorklistEntryModel>? entries,
      DeskState? desk,
      List<CaseModel>? cases,
      List<PathologyReportModel> reports = const [],
      int unread = 0,
    }) {
      final list = entries ?? deskEntries();
      when(
        () => blocs.desk.state,
      ).thenReturn(desk ?? DeskLoadSuccess(entries: list, visible: list));
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(
          cases: cases ?? [for (var n = 1; n <= 6; n++) deskCase(n)],
          reports: reports,
        ),
      );
      when(
        () => blocs.notifications.state,
      ).thenReturn(NotificationsLoadSuccess(unread: unread));
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

    Finder hero() => find.byType(AppointmentHeroCard);
    Finder rows() => find.byType(DeskEntryRow);
    Finder tile(String title) => find.widgetWithText(ShortcutTile, title);

    group('asks for what it shows', () {
      testWidgets('the desk, the cases and the inbox, for this pathologist', (
        tester,
      ) async {
        when(() => blocs.desk.state).thenReturn(const DeskInitial());
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
        verify(
          () => blocs.notifications.add(
            const NotificationsRequested(uid: deskUid),
          ),
        ).called(1);
      });

      testWidgets('a desk already loaded is not asked for again', (
        tester,
      ) async {
        stub();
        await pumpScreen(tester);

        verifyNever(() => blocs.desk.add(any()));
        verifyNever(() => blocs.cases.add(any()));
        verifyNever(() => blocs.notifications.add(any()));
      });
    });

    group('what it shows', () {
      testWidgets('the headline counts the desk and says the AI read first', (
        tester,
      ) async {
        stub();
        await pumpScreen(tester);

        expect(find.byType(DeskHeadline), findsOneWidget);
        expect(find.text('6 cases on desk.'), findsOneWidget);
        expect(find.text('AI read them first.'), findsOneWidget);
      });

      testWidgets('the hero is the first case, not another', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        expect(
          find.descendant(
            of: hero(),
            matching: find.text('ODR-JK-AW-02112026-001 · Lymph node'),
          ),
          findsOneWidget,
        );
        expect(find.text('Most urgent'), findsOneWidget);
        expect(
          find.descendant(
            of: hero(),
            matching: find.text('Amina W., 46 · waiting 1h 20m'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('"Up next" lists ranks 2 to 5 and "All 6" opens the list', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        expect(rows(), findsNWidgets(4));
        for (final rank in ['2', '3', '4', '5']) {
          expect(
            find.descendant(
              of: find.byType(DeskRankBadge),
              matching: find.text(rank),
            ),
            findsOneWidget,
          );
        }
        // Sixth is behind "All 6".
        expect(find.text('ODR-JK-AW-02112026-006'), findsNothing);

        await tester.tap(find.text('All 6'));
        await tester.pumpAndSettle();
        expect(find.text('stub list all'), findsOneWidget);
      });

      testWidgets('rows and the hero open their case', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await tester.tap(find.text('ODR-JK-AW-02112026-003'));
        await tester.pumpAndSettle();
        expect(find.text('stub case case-3'), findsOneWidget);
      });

      testWidgets('the hero button opens the first case', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await tester.tap(find.text('Open case'));
        await tester.pumpAndSettle();
        expect(find.text('stub case case-1'), findsOneWidget);
      });

      testWidgets('the search field goes to search and takes no focus', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        expect(
          tester.widget<TextField>(find.byType(TextField)).autofocus,
          isFalse,
        );
        expect(find.byType(DeskSearchEntry), findsOneWidget);

        await tester.tap(find.byType(DeskSearchEntry));
        await tester.pumpAndSettle();
        expect(find.text('stub search'), findsOneWidget);
      });

      testWidgets('the bell opens notifications and announces unread', (
        tester,
      ) async {
        stub(unread: 2);
        await pumpScreen(tester);

        final bell = find.byWidgetPredicate(
          (w) =>
              w is CircleIconButton &&
              w.semanticLabel == 'Notifications, unread',
        );
        expect(bell, findsOneWidget);
        await tester.tap(bell);
        await tester.pumpAndSettle();
        expect(find.text('stub notifications'), findsOneWidget);
      });
    });

    group('the shortcuts', () {
      testWidgets('count from the data and open their lists', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        // Entries 2 and 6 are ready and low. Entry 3 is failed.
        expect(
          find.descendant(of: tile('Low confidence'), matching: find.text('2')),
          findsOneWidget,
        );
        // Entries 2, 3 and 6 are past 4h; the oldest has waited 9h 0m.
        expect(
          find.descendant(
            of: tile('Waiting over 4h'),
            matching: find.text('3 cases · oldest 9h 0m'),
          ),
          findsOneWidget,
        );

        await tester.tap(tile('Low confidence'));
        await tester.pumpAndSettle();
        expect(find.text('stub list lowConfidence'), findsOneWidget);
      });

      testWidgets('waiting over 4h opens that list', (tester) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        await tester.tap(tile('Waiting over 4h'));
        await tester.pumpAndSettle();
        expect(find.text('stub list waitingOver4h'), findsOneWidget);
      });

      testWidgets('signed today counts since Nairobi midnight', (tester) async {
        useTallSurface(tester);
        // The clock is 15:00 in Nairobi on 2 Nov. 21:30Z the day before is
        // 00:30 on 2 Nov there (today); 20:59Z is 23:59 on 1 Nov (not).
        stub(
          reports: [
            _report(
              signedAt: '2026-11-01T21:30:00Z',
              startedAt: '2026-11-01T21:00:00Z',
            ),
            _report(
              signedAt: '2026-11-02T10:00:00Z',
              startedAt: '2026-11-02T09:50:00Z',
            ),
            _report(
              signedAt: '2026-11-01T20:59:00Z',
              startedAt: '2026-11-01T20:00:00Z',
            ),
            _report(signedAt: '2026-11-02T10:00:00Z', uid: 'someone-else'),
            _report(signedAt: '2026-11-02T10:00:00Z', status: 'Superseded'),
          ],
        );
        await pumpScreen(tester);

        expect(
          find.descendant(
            of: tile('Signed today'),
            matching: find.text('2 · avg 20 min'),
          ),
          findsOneWidget,
        );
        await tester.tap(tile('Signed today'));
        await tester.pumpAndSettle();
        expect(find.text('stub signed'), findsOneWidget);
      });

      testWidgets('with nothing signed it shows a zero, not an average', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        expect(
          find.descendant(of: tile('Signed today'), matching: find.text('0')),
          findsOneWidget,
        );
        expect(find.textContaining('avg'), findsNothing);
      });
    });

    group('H-18', () {
      testWidgets(
        'rule 1: everything the AI produced wears the AI marking, with the '
        'sparkle',
        (tester) async {
          useTallSurface(tester);
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            stub();
            await pumpScreen(tester, themeMode: mode);
            final status = statusOf(tester, find.byType(DeskHeadline));

            // The headline: the second line.
            expect(hasSparkle(tester, find.byType(DeskHeadline)), isTrue);
            expect(
              coloursIn(tester, find.byType(DeskHeadline)),
              contains(status.aiDraft),
            );

            // The hero: its AI chip.
            final heroMark = find.descendant(
              of: hero(),
              matching: find.byType(AiMark),
            );
            expect(heroMark, findsOneWidget);
            expect(hasSparkle(tester, heroMark), isTrue);
            expect(
              coloursIn(tester, heroMark),
              containsAll([status.aiDraft, status.aiDraftContainer]),
            );

            // The low-confidence tile: the sparkle.
            expect(hasSparkle(tester, tile('Low confidence')), isTrue);

            // Rows: a ready pre-read wears the mark, with its band and %.
            for (final label in ['Low confidence · 52%', 'Moderate 70%']) {
              final mark = find.widgetWithText(AiMark, label);
              expect(mark, findsOneWidget, reason: label);
              expect(hasSparkle(tester, mark), isTrue, reason: label);
              expect(
                coloursIn(tester, mark),
                containsAll([status.aiDraft, status.aiDraftContainer]),
                reason: label,
              );
            }
          }
        },
      );

      testWidgets(
        'rule 2: no AI item and no urgency or wait wears the signed colour; '
        'only the signed tile is mint',
        (tester) async {
          useTallSurface(tester);
          for (final mode in [ThemeMode.light, ThemeMode.dark]) {
            stub();
            await pumpScreen(tester, themeMode: mode);
            final status = statusOf(tester, find.byType(DeskHeadline));
            final signed = signedColours(status);

            for (final finder in [
              find.byType(DeskHeadline),
              aiMarks,
              tile('Low confidence'),
              find.widgetWithText(StatusChip, 'Priority'),
              find.widgetWithText(StatusChip, 'Waiting over 6h'),
            ]) {
              expect(finder, findsWidgets);
              for (final element in finder.evaluate()) {
                final colours = coloursIn(
                  tester,
                  find.byWidget(element.widget),
                );
                expect(
                  colours.where((c) => c != null && signed.contains(c)),
                  isEmpty,
                  reason: '$finder in ${mode.name}',
                );
              }
            }
            expect(
              tester
                  .widget<StatusChip>(
                    find.widgetWithText(StatusChip, 'Priority'),
                  )
                  .tone,
              StatusTone.attention,
            );
            expect(
              tester
                  .widget<StatusChip>(
                    find.widgetWithText(StatusChip, 'Waiting over 6h'),
                  )
                  .tone,
              StatusTone.attention,
            );
            // The signed tile is the one place that is mint, and it carries
            // no sparkle.
            expect(hasSparkle(tester, tile('Signed today')), isFalse);
          }
        },
      );

      testWidgets(
        'rule 3: only a ready pre-read says "AI draft ready"; failed says No '
        'AI draft in neutral; queued, running and none say nothing',
        (tester) async {
          useTallSurface(tester);
          stub();
          await pumpScreen(tester);

          // Rows 3 (failed) and 4 (running).
          expect(find.text('No AI draft'), findsOneWidget);
          final failed = find.widgetWithText(StatusChip, 'No AI draft');
          expect(tester.widget<StatusChip>(failed).tone, StatusTone.neutral);
          final failedRow = find.ancestor(
            of: find.text('ODR-JK-AW-02112026-003'),
            matching: rows(),
          );
          expect(
            find.descendant(of: failedRow, matching: find.byType(AiMark)),
            findsNothing,
          );
          final runningRow = find.ancestor(
            of: find.text('ODR-JK-AW-02112026-004'),
            matching: rows(),
          );
          expect(
            find.descendant(of: runningRow, matching: find.byType(AiMark)),
            findsNothing,
          );
          expect(
            find.descendant(of: runningRow, matching: find.byType(StatusChip)),
            findsNothing,
          );
          expect(
            find.descendant(of: runningRow, matching: find.textContaining('%')),
            findsNothing,
          );

          // A hero that failed says so, and a hero that is queued says
          // nothing.
          for (final (preread, says) in [
            ('Failed', 'No AI draft'),
            ('Queued', null),
            ('', null),
          ]) {
            stub(
              entries: [
                deskEntry(1, preread: preread),
                ...deskEntries().skip(1),
              ],
            );
            await pumpScreen(tester);
            expect(
              find.descendant(of: hero(), matching: find.byType(AiMark)),
              findsNothing,
              reason: preread,
            );
            expect(
              find.descendant(of: hero(), matching: find.text('No AI draft')),
              says == null ? findsNothing : findsOneWidget,
              reason: preread,
            );
            expect(
              find.descendant(
                of: hero(),
                matching: find.text('AI draft ready'),
              ),
              findsNothing,
              reason: preread,
            );
          }
        },
      );

      testWidgets(
        'rule 4: the hero figure is the time waiting, with no AI measurement, '
        'heatmap or thumb',
        (tester) async {
          useTallSurface(tester);
          stub();
          await pumpScreen(tester);

          expect(
            find.descendant(of: hero(), matching: find.text('1h 20m')),
            findsOneWidget,
          );
          expect(
            find.descendant(of: hero(), matching: find.text('waiting')),
            findsOneWidget,
          );
          expect(
            find.descendant(of: hero(), matching: find.textContaining('mm')),
            findsNothing,
          );
          expect(find.byType(Image), findsNothing);
          expect(find.byType(CaseThumb), findsNothing);
        },
      );

      testWidgets('rule 5: a band always comes with its percent', (
        tester,
      ) async {
        useTallSurface(tester);
        stub(
          entries: [
            deskEntry(1),
            deskEntry(2, band: 'Low', confidence: 0.524),
            deskEntry(3, band: 'Moderate', confidence: 0.7),
            deskEntry(4, confidence: 1.4),
            deskEntry(5, confidence: -0.2),
          ],
        );
        await pumpScreen(tester);

        expect(find.text('Low confidence · 52%'), findsOneWidget);
        expect(find.text('Moderate 70%'), findsOneWidget);
        // Outside 0 to 1: neither band nor percent, only that a draft is
        // ready.
        for (final n in [4, 5]) {
          final row = find.ancestor(
            of: find.text('ODR-JK-AW-02112026-00$n'),
            matching: rows(),
          );
          expect(
            find.descendant(of: row, matching: find.text('AI draft ready')),
            findsOneWidget,
          );
          expect(
            find.descendant(of: row, matching: find.textContaining('%')),
            findsNothing,
          );
          expect(
            find.descendant(of: row, matching: find.textContaining('High')),
            findsNothing,
          );
        }
        // Every band word on screen sits beside a percent.
        for (final word in ['High ', 'Moderate ', 'Low confidence']) {
          for (final text in tester.widgetList<Text>(
            find.textContaining(word),
          )) {
            final data = text.data ?? '';
            if (data.contains('Low confidence') && !data.contains('·')) {
              continue; // the shortcut tile title and its body
            }
            if (data.startsWith('High ') || data.startsWith('Moderate ')) {
              expect(data, contains('%'));
            }
          }
        }
      });

      testWidgets('rule 6: a screen reader hears the AI marking', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        useTallSurface(tester);
        stub();
        await pumpScreen(tester);

        expect(
          find.bySemanticsLabel(
            RegExp(
              r'ODR-JK-AW-02112026-002[\s\S]*Priority'
              r'[\s\S]*AI draft ready · Low confidence · 52%',
            ),
          ),
          findsOneWidget,
        );
        final heroMark = find.descendant(
          of: hero(),
          matching: find.byType(AiMark),
        );
        // The hero reads as one block, the AI marking inside it.
        expect(tester.getSemantics(heroMark).label, contains('AI draft ready'));
        // The headline is a heading and reads both lines.
        final headline = tester.getSemantics(find.byType(DeskHeadline));
        expect(headline.getSemanticsData().flagsCollection.isHeader, isTrue);
        expect(headline.label, contains('AI read them first.'));
        handle.dispose();
      });
    });

    group('time', () {
      testWidgets('elapsed time is instants apart, across Nairobi midnight', (
        tester,
      ) async {
        useTallSurface(tester);
        // 00:30 in Nairobi on 2 Nov; the case has waited since 23:00 on 1 Nov.
        clock = DateTime.utc(2026, 11, 1, 21, 30);
        stub(
          entries: [
            deskEntry(1, waitingSince: '2026-11-01T20:00:00Z'),
            deskEntry(2, waitingSince: '2026-11-01T21:10:00Z'),
          ],
        );
        await pumpScreen(tester);

        expect(
          find.descendant(of: hero(), matching: find.text('1h 30m')),
          findsOneWidget,
        );
        expect(find.text('20m'), findsOneWidget);
      });

      testWidgets('a stamp with another zone is the same instant', (
        tester,
      ) async {
        useTallSurface(tester);
        // 05:00 at -05:00 is 10:00Z, two hours before the clock.
        stub(
          entries: [
            deskEntry(1, waitingSince: '2026-11-02T05:00:00-05:00'),
            deskEntry(2, waitingSince: '2026-11-02T13:00:00+03:00'),
          ],
        );
        await pumpScreen(tester);

        expect(
          find.descendant(of: hero(), matching: find.text('2h 0m')),
          findsOneWidget,
        );
        // 13:00 at +03:00 is 10:00Z too.
        expect(find.text('2h 0m'), findsNWidgets(2));
      });

      testWidgets('a bad waitingSince shows no time and no wait chip', (
        tester,
      ) async {
        useTallSurface(tester);
        stub(
          entries: [
            deskEntry(1, waitingSince: 'not a time'),
            deskEntry(2, waited: null),
          ],
        );
        await pumpScreen(tester);

        expect(find.text('waiting'), findsNothing);
        expect(find.textContaining(RegExp(r'^\d+h \d+m$')), findsNothing);
        expect(find.byType(StatusChip), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });

    group('states', () {
      testWidgets('empty: explains, has no button and no dot (F-11)', (
        tester,
      ) async {
        stub(entries: const [], desk: const DeskLoadSuccess());
        await pumpScreen(tester);

        expect(find.text('Your desk is empty'), findsOneWidget);
        expect(find.byType(EmptyState), findsOneWidget);
        expect(find.byType(TabibuButton), findsNothing);
        expect(find.byType(DeskHeadline), findsNothing);
        expect(hero(), findsNothing);
        expect(find.byType(ShortcutBento), findsNothing);
      });

      testWidgets('loading shows the spinner, not an empty desk', (
        tester,
      ) async {
        stub(desk: const DeskLoadInProgress());
        await tester.pumpRouterApp(deskRouter(screen));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(LoadingView), findsOneWidget);
        expect(find.text('Your desk is empty'), findsNothing);
      });

      testWidgets('a failed load is not shown as an empty desk', (
        tester,
      ) async {
        stub(desk: const DeskLoadFailure(error: AppError.serviceUnavailable));
        await pumpScreen(tester);

        expect(find.text('Your desk is empty'), findsNothing);
        expect(find.text('Slow connection'), findsOneWidget);
      });

      testWidgets('offline keeps the desk, shows the banner and retries', (
        tester,
      ) async {
        useTallSurface(tester);
        final list = deskEntries();
        stub(
          desk: DeskLoadSuccess(entries: list, visible: list, offline: true),
        );
        await pumpScreen(tester);

        expect(find.byType(ConnectivityBanner), findsOneWidget);
        expect(find.text('6 cases on desk.'), findsOneWidget);
        expect(rows(), findsNWidgets(4));

        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        verify(
          () => blocs.desk.add(const DeskRefreshed(pathologistUid: deskUid)),
        ).called(1);
        verify(
          () => blocs.cases.add(
            const CasesRefreshed(uid: deskUid, role: Role.pathologist),
          ),
        ).called(1);
        verify(
          () => blocs.notifications.add(
            const NotificationsRefreshed(uid: deskUid),
          ),
        ).called(1);
      });

      testWidgets('one case has no "Up next"', (tester) async {
        stub(entries: [deskEntry(1)]);
        await pumpScreen(tester);

        expect(find.text('Up next'), findsNothing);
        expect(rows(), findsNothing);
        expect(find.text('1 case on desk.'), findsOneWidget);
      });
    });

    group('looks', () {
      testWidgets('renders in light and dark, ink on the hero pill', (
        tester,
      ) async {
        useTallSurface(tester);
        stub();
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await pumpScreen(tester, themeMode: mode);

          expect(find.byType(DeskScreen), findsOneWidget);
          final label = tester.widget<Text>(find.text('Open case'));
          expect(label.style?.color, AppColors.inkLight);
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

        expect(find.text(sw.deskCasesOnDesk(6)), findsOneWidget);
        expect(find.text(sw.deskAiReadFirst), findsOneWidget);
        expect(find.text(sw.deskUpNext), findsOneWidget);
        expect(tester.takeException(), isNull);
        // Every case number stays on one line, whole (lesson 10).
        for (final n in [2, 3, 4, 5]) {
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
