// cspell:ignore Kiswahili hakikupata saratani maelezo Hospitali
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
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';
import 'package:tabibu/features/reports/presentation/explained_result_screen.dart';
import 'package:tabibu/features/reports/presentation/widgets/listen_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

const _caseUid = 'case-1';
const _draftText = 'UNAPPROVED-DRAFT-SENTINEL';
const _english = 'Your test found no cancer. We will check again in March.';
const _swahili = 'Kipimo chako hakikupata saratani.';

PatientSession _session() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

ReportTextApprovedModel _approved(
  String language,
  String text, {
  String approver = 'Dr. Kamau',
}) => ReportTextApprovedModel(
  uid: 'v1_Explanation_$language',
  language: language,
  approvedText: {'summary': text},
  approverName: approver,
);

ReportReaderLoadSuccess _loaded({
  Map<String, ReportTextApprovedModel> approved = const {},
  Map<String, ReportTextModel> explanations = const {},
  Role role = Role.patient,
  String caseUid = _caseUid,
  bool offline = false,
}) => ReportReaderLoadSuccess(
  uid: 'patient-1',
  role: role,
  caseUid: caseUid,
  report: const PathologyReportModel(
    uid: 'r1',
    caseUid: _caseUid,
    signedByName: 'Dr. Achieng Odhiambo',
    releasedToPatient: true,
  ),
  approved: approved,
  explanations: explanations,
  offline: offline,
);

void main() {
  group('ExplainedResultScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;
    final l10n = lookupAppLocalizations(const Locale('en'));

    setUpAll(() {
      registerFallbackValue(const ReportReaderReset());
    });

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    });

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/explained',
        routes: [
          GoRoute(
            path: '/explained',
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                ...blocs.providers,
              ],
              child: const ExplainedResultScreen(caseUid: _caseUid),
            ),
          ),
          GoRoute(
            path: '/patient/result/:caseUid',
            builder: (_, state) =>
                Text('stub result ${state.pathParameters['caseUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      required ReportReaderState reader,
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      Size surface = const Size(1170, 4000),
    }) async {
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const SizedBox());
      when(() => blocs.reportReader.state).thenReturn(reader);
      await tester.pumpRouterApp(
        router(),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    String allText(WidgetTester tester) => [
      for (final t in tester.widgetList<Text>(find.byType(Text)))
        t.data ?? t.textSpan?.toPlainText() ?? '',
    ].join('\n');

    group('what it shows', () {
      testWidgets("the approved text, under the doctor's name and the AI "
          'attribution, with the audio line', (tester) async {
        await pumpScreen(
          tester,
          reader: _loaded(approved: {'en': _approved('en', _english)}),
        );

        expect(find.text(l10n.explainedHeadline('Dr. Kamau')), findsOneWidget);
        expect(find.text(l10n.explainedAiAttribution), findsOneWidget);
        expect(find.text(_english), findsOneWidget);
        expect(find.byType(ListenCard), findsOneWidget);
        expect(find.text(l10n.explainedAudioLine), findsOneWidget);
        expect(
          find.text(
            l10n.explainedSharedBy('Dr. Kamau', 'Dr. Achieng Odhiambo'),
          ),
          findsOneWidget,
        );
        expect(find.text(l10n.explainedViewFullReport), findsOneWidget);
      });

      testWidgets('approved text is never inside an AI draft frame or '
          'labelled as a draft', (tester) async {
        await pumpScreen(
          tester,
          reader: _loaded(approved: {'en': _approved('en', _english)}),
        );

        expect(find.byType(AiDraftFrame), findsNothing);
        expect(find.text(l10n.alertReviewAiDraftNotSent), findsNothing);
        expect(
          find.byWidgetPredicate(
            (w) => w is NoticeCard && w.variant == NoticeVariant.aiDraft,
          ),
          findsNothing,
        );
      });

      testWidgets('the listen card is shown but cannot play yet', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          reader: _loaded(approved: {'en': _approved('en', _english)}),
        );

        final card = tester.widget<ListenCard>(find.byType(ListenCard));
        expect(card.onToggle, isNull);
        expect(card.playing, isFalse);
      });
    });

    group('rule 5: only approved text', () {
      testWidgets('drafts in the state are never drawn, with or without '
          'approved text', (tester) async {
        final drafts = {
          'en': const ReportTextModel(
            uid: 'v1_Explanation_en',
            machineText: {'summary': _draftText},
          ),
          'sw': const ReportTextModel(
            uid: 'v1_Explanation_sw',
            machineText: {'summary': _draftText},
          ),
        };

        await pumpScreen(tester, reader: _loaded(explanations: drafts));
        expect(allText(tester), isNot(contains(_draftText)));

        await pumpScreen(
          tester,
          reader: _loaded(
            explanations: drafts,
            approved: {'sw': _approved('sw', _swahili)},
          ),
        );
        expect(allText(tester), isNot(contains(_draftText)));
        expect(find.text(_swahili), findsOneWidget);
      });

      testWidgets('F-8: no approved text shows the released report link '
          'and nothing of the explanation', (tester) async {
        await pumpScreen(tester, reader: _loaded());

        expect(find.byType(ListenCard), findsNothing);
        expect(find.text(l10n.explainedAiAttribution), findsNothing);
        expect(find.text(l10n.explainedAudioLine), findsNothing);
        expect(find.byType(ReportTextCard), findsNothing);
        expect(find.text(l10n.explainedViewFullReport), findsOneWidget);
      });

      testWidgets("another case's or another role's approved text is not "
          'shown', (tester) async {
        await pumpScreen(
          tester,
          reader: _loaded(
            approved: {'en': _approved('en', _english)},
            caseUid: 'other-case',
          ),
        );
        expect(find.text(_english), findsNothing);

        await pumpScreen(
          tester,
          reader: _loaded(
            approved: {'en': _approved('en', _english)},
            role: Role.doctor,
          ),
        );
        expect(find.text(_english), findsNothing);
        expect(find.byType(ListenCard), findsNothing);
      });
    });

    group('language', () {
      testWidgets("opens in the phone's language and switches to the other "
          'one approved', (tester) async {
        await pumpScreen(
          tester,
          reader: _loaded(
            approved: {
              'en': _approved('en', _english),
              'sw': _approved('sw', _swahili),
            },
          ),
          locale: const Locale('sw'),
        );

        expect(find.text(_swahili), findsOneWidget);
        expect(find.text(_english), findsNothing);

        await tester.tap(
          find.text(lookupAppLocalizations(const Locale('sw')).languageEn),
        );
        await tester.pump();

        expect(find.text(_english), findsOneWidget);
        expect(find.text(_swahili), findsNothing);
      });

      testWidgets('shows what exists when only the other language is '
          'approved, with no toggle', (tester) async {
        await pumpScreen(
          tester,
          reader: _loaded(approved: {'sw': _approved('sw', _swahili)}),
        );

        expect(find.text(_swahili), findsOneWidget);
        expect(find.byType(TabibuFilterChip), findsNothing);
      });
    });

    group('data', () {
      testWidgets('opens the case as the patient', (tester) async {
        await pumpScreen(tester, reader: const ReportReaderInitial());

        verify(
          () => blocs.reportReader.add(
            const ReportReaderOpened(
              uid: 'patient-1',
              role: Role.patient,
              caseUid: _caseUid,
            ),
          ),
        ).called(1);
        expect(find.byType(LoadingView), findsOneWidget);
        expect(find.text(l10n.explainedViewFullReport), findsNothing);
      });

      testWidgets('does not reopen a case the reader already holds', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          reader: _loaded(approved: {'en': _approved('en', _english)}),
        );

        verifyNever(() => blocs.reportReader.add(any()));
      });

      testWidgets('the report link opens the released report', (tester) async {
        await pumpScreen(tester, reader: _loaded());

        await tester.tap(find.text(l10n.explainedViewFullReport));
        await tester.pumpAndSettle();

        expect(find.text('stub result case-1'), findsOneWidget);
      });

      testWidgets('offline keeps the saved text under the saved banner', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          reader: _loaded(
            approved: {'en': _approved('en', _english)},
            offline: true,
          ),
        );

        expect(find.byType(ConnectivityBanner), findsOneWidget);
        expect(find.text(l10n.explainedSavedTitle), findsOneWidget);
        expect(find.text(_english), findsOneWidget);
      });

      testWidgets('a load failure keeps the approved text and shows the '
          'error', (tester) async {
        final approved = {'en': _approved('en', _english)};
        whenListen(
          blocs.reportReader,
          Stream<ReportReaderState>.value(
            ReportReaderLoadFailure(
              error: AppError.noInternet,
              uid: 'patient-1',
              role: Role.patient,
              caseUid: _caseUid,
              approved: approved,
            ),
          ),
          initialState: _loaded(approved: approved),
        );
        await tester.pumpRouterApp(router());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(
          find.text(AppError.noInternet.description(l10n)),
          findsOneWidget,
        );
        expect(find.text(_english), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
      });
    });

    group('layout', () {
      testWidgets('draws in dark mode', (tester) async {
        await pumpScreen(
          tester,
          themeMode: ThemeMode.dark,
          reader: _loaded(approved: {'en': _approved('en', _english)}),
        );

        expect(find.text(_english), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      for (final scale in const [1.3, 2.0]) {
        testWidgets('Swahili at ${scale}x text on a 390 dp screen does not '
            'overflow, with a long text and a long doctor name', (
          tester,
        ) async {
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final long = List.filled(300, 'maelezo').join(' ');
          await pumpScreen(
            tester,
            locale: const Locale('sw'),
            surface: const Size(390 * 3, 12000),
            reader: _loaded(
              approved: {
                'en': _approved('en', long),
                'sw': _approved(
                  'sw',
                  long,
                  approver: 'Dkt. Wanjiru Mwangi-Kamau wa Hospitali Kuu',
                ),
              },
            ),
          );
          final sw = lookupAppLocalizations(const Locale('sw'));

          expect(tester.takeException(), isNull);
          expect(find.text(sw.explainedAiAttribution), findsOneWidget);
          expect(find.text(long), findsOneWidget);
        });
      }

      testWidgets('has a labelled back button', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpScreen(tester, reader: _loaded());

        expect(find.bySemanticsLabel(l10n.commonBack), findsOneWidget);
        semantics.dispose();
      });
    });
  });
}
