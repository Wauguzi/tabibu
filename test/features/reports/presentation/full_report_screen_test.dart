// cspell:ignore mabadiliko hariri ramani slaidi Imesainiwa
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_event.dart';
import 'package:tabibu/features/reports/blocs/report_reader_bloc/report_reader_state.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/report_addendum_model.dart';
import 'package:tabibu/features/reports/data/models/report_measurement_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';
import 'package:tabibu/features/reports/presentation/full_report_screen.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_file_card.dart';
import 'package:tabibu/features/reports/presentation/widgets/report_text_card.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../helpers/helpers.dart';

const _caseUid = 'case-1';

const _diagnosis =
    'Metastatic carcinoma in 1 of 1 sentinel lymph node. No capsular '
    'invasion seen.';
const _comments = 'Discuss with the treating surgeon and the MDT.';

PractitionerSession _session() {
  final base = RoleSessions.doctor();
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: 'doctor-1'),
    roles: base.roles,
  );
}

PathologyReportModel _report({
  bool released = false,
  String diagnosis = _diagnosis,
  String comments = _comments,
  List<ReportMeasurementModel> measurements = const [],
  String caseUid = _caseUid,
}) => PathologyReportModel(
  uid: 'report-1',
  caseUid: caseUid,
  orderNumber: 'TB-0231',
  diagnosisType: 'Provisional',
  diagnosis: diagnosis,
  comments: comments,
  signedByTitle: 'Dr.',
  signedByName: 'Achieng Odhiambo',
  signedByFacilityName: 'Lancet Kenya',
  signedAt: '2026-10-27T07:42:00Z',
  releasedToPatient: released,
  measurements: measurements,
  sampleCollectedAt: '2026-10-24T05:40:00Z',
  sampleReceivedAt: '2026-10-24T11:10:00Z',
  labAccessionNo: 'LAB-77/26',
  responses: const [
    ReportResponseModel(
      section: 'Microscopic',
      question: 'margins',
      answer: 'Clear by 2 mm',
      order: 2,
    ),
    ReportResponseModel(
      section: 'Macroscopic',
      question: 'specimenSize',
      answer: '3 x 2 x 1 cm',
    ),
    ReportResponseModel(
      section: 'Microscopic',
      question: 'tumourGrade',
      answer: 'Grade 2',
      order: 1,
    ),
    ReportResponseModel(
      section: 'Custom',
      question: 'unmappedQuestion',
      answer: 'Kept as written',
    ),
  ],
  addenda: const [
    ReportAddendumModel(
      uid: 'ad-1',
      text: 'ER positive on repeat staining.',
      signedByName: 'Achieng Odhiambo',
      signedAt: '2026-10-29T06:00:00Z',
    ),
  ],
);

const _aiExplanation = 'AI-DRAFT-EXPLANATION-SENTINEL';
const _approvedText = 'APPROVED-TEXT-SENTINEL';

void main() {
  group('FullReportScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    setUpAll(() {
      registerFallbackValue(const ReportReaderReset());
      registerFallbackValue(const CasesRequested(uid: '', role: Role.doctor));
    });

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      when(() => blocs.cases.state).thenReturn(
        const CasesLoadSuccess(
          cases: [
            CaseModel(
              uid: _caseUid,
              orderNumber: 'TB-0231',
              patientName: 'Amina Wambui',
              patientSex: 'Female',
              patientAgeYears: 46,
            ),
          ],
        ),
      );
    });

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/full',
        routes: [
          GoRoute(
            path: '/full',
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                ...blocs.providers,
              ],
              child: const FullReportScreen(caseUid: _caseUid),
            ),
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
      Size surface = const Size(1170, 8000),
    }) async {
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      // Clear the last pump so the screen's initState runs again.
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

    ReportReaderLoadSuccess loaded(
      PathologyReportModel? report, {
      bool offline = false,
      Map<String, ReportTextModel> explanations = const {},
      Map<String, ReportTextApprovedModel> approved = const {},
    }) => ReportReaderLoadSuccess(
      uid: 'doctor-1',
      role: Role.doctor,
      caseUid: _caseUid,
      report: report,
      offline: offline,
      explanations: explanations,
      approved: approved,
    );

    // Every string the screen draws, so a banned word cannot hide anywhere.
    String allText(WidgetTester tester) => [
      for (final t in tester.widgetList<Text>(find.byType(Text)))
        t.data ?? t.textSpan?.toPlainText() ?? '',
    ].join('\n');

    group('rules', () {
      testWidgets('rule 1: reads only the signed report in state.report', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        expect(find.text(_diagnosis), findsOneWidget);
        expect(find.text(_comments), findsOneWidget);
        verifyNever(() => blocs.reportReader.add(any()));
      });

      testWidgets(
        'rule 1: a state that belongs to another case shows nothing of it',
        (tester) async {
          await pumpScreen(
            tester,
            reader: ReportReaderLoadSuccess(
              uid: 'doctor-1',
              role: Role.doctor,
              caseUid: 'other-case',
              report: _report(caseUid: 'other-case'),
            ),
          );

          expect(find.text(_diagnosis), findsNothing);
          expect(find.text('Grade 2'), findsNothing);
          expect(find.byType(KeyValueCard), findsNothing);
          expect(find.byType(LoadingView), findsOneWidget);
        },
      );

      testWidgets(
        'rule 1: a report that is not the current signed one is not shown',
        (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(_report().copyWith(status: 'Superseded')),
          );

          expect(find.text(_diagnosis), findsNothing);
          expect(find.text('Report in progress'), findsOneWidget);
        },
      );

      testWidgets(
        'rule 2: explanations and approved text are ignored; the screen is '
        'identical with both full or both empty',
        (tester) async {
          await pumpScreen(tester, reader: loaded(_report()));
          final empty = allText(tester);

          await pumpScreen(
            tester,
            reader: loaded(
              _report(),
              explanations: const {
                'en': ReportTextModel(
                  uid: 'e1',
                  machineText: {'summary': _aiExplanation},
                ),
                'sw': ReportTextModel(
                  uid: 'e2',
                  machineText: {'summary': _aiExplanation},
                ),
              },
              approved: const {
                'en': ReportTextApprovedModel(
                  uid: 'a1',
                  approvedText: {'summary': _approvedText},
                ),
                'sw': ReportTextApprovedModel(
                  uid: 'a2',
                  approvedText: {'summary': _approvedText},
                ),
              },
            ),
          );
          final full = allText(tester);

          expect(full, isNot(contains(_aiExplanation)));
          expect(full, isNot(contains(_approvedText)));
          expect(full, empty);
        },
      );

      testWidgets(
        'rule 3: no signed report shows "Report in progress" and nothing '
        'else',
        (tester) async {
          await pumpScreen(tester, reader: loaded(null));

          expect(find.byType(EmptyState), findsOneWidget);
          expect(find.text('Report in progress'), findsOneWidget);
          expect(
            find.text("The pathologist hasn't signed this report yet."),
            findsOneWidget,
          );
          expect(find.byType(NoticeCard), findsNothing);
          expect(find.byType(KeyValueCard), findsNothing);
          expect(find.byType(ReportTextCard), findsNothing);
        },
      );

      testWidgets(
        'rule 4: no AI diff, change count, edit marker, heatmap or slide '
        'row, in English or Swahili',
        (tester) async {
          for (final (locale, banned) in [
            (
              const Locale('en'),
              RegExp(
                r'change|\bedit|heatmap|slide|pathologist made',
                caseSensitive: false,
              ),
            ),
            (
              const Locale('sw'),
              RegExp('mabadiliko|hariri|ramani|slaidi', caseSensitive: false),
            ),
          ]) {
            await pumpScreen(tester, reader: loaded(_report()), locale: locale);
            expect(
              allText(tester),
              isNot(matches(banned)),
              reason: '${locale.languageCode} text mentions the AI diff',
            );
            expect(find.byType(ListRowCard), findsNothing);
            expect(find.byType(ShortcutTile), findsNothing);
          }
        },
      );

      testWidgets('rule 4: the one AI line is the neutral footnote', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        final footnote = find.ancestor(
          of: find.text('The AI draft is kept on record beside this report.'),
          matching: find.byType(NoticeCard),
        );
        expect(footnote, findsOneWidget);
        expect(
          tester.widget<NoticeCard>(footnote).variant,
          NoticeVariant.neutral,
        );
      });

      testWidgets(
        'rule 5: no AI frame, AI colour or sparkle; the banner is the signed '
        'notice',
        (tester) async {
          await pumpScreen(tester, reader: loaded(_report()));

          expect(find.byType(AiDraftFrame), findsNothing);
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is AssetIcon &&
                  w.asset.path == Assets.icons.sparkleIcon.path,
            ),
            findsNothing,
          );
          final notices = tester.widgetList<NoticeCard>(
            find.byType(NoticeCard),
          );
          expect(
            notices.map((n) => n.variant),
            isNot(contains(NoticeVariant.aiDraft)),
          );
          final banner = tester.widget<NoticeCard>(
            find.ancestor(
              of: find.text('Signed by Dr. Achieng Odhiambo'),
              matching: find.byType(NoticeCard),
            ),
          );
          expect(banner.variant, NoticeVariant.signed);
          expect(find.text('Lancet Kenya · 27 Oct, 10:42 AM'), findsOneWidget);

          final status = Theme.of(
            tester.element(find.byType(FullReportScreen)),
          ).extension<AppStatusColors>()!;
          final painted = tester
              .widgetList<DecoratedBox>(find.byType(DecoratedBox))
              .map((d) => d.decoration)
              .whereType<BoxDecoration>()
              .map((d) => d.color);
          expect(painted, isNot(contains(status.aiDraftContainer)));
        },
      );

      testWidgets(
        'rule 6: diagnosis, comments, every response and the measurements are '
        'verbatim with the PDF labels',
        (tester) async {
          const awkward = '  pT1c N0(i+)\nM0 — "grade 2" <3 mm  ';
          await pumpScreen(
            tester,
            reader: loaded(
              _report(
                diagnosis: awkward,
                comments: 'Comments & caveats: see addendum',
                measurements: const [
                  ReportMeasurementModel(
                    key: 'Largest focus',
                    unit: 'mm',
                    value: 2.1,
                    precision: 1,
                  ),
                ],
              ),
            ),
          );

          expect(find.text(awkward), findsOneWidget);
          expect(find.text('Comments & caveats: see addendum'), findsOneWidget);
          expect(find.text('Diagnosis · Provisional'), findsOneWidget);

          // The PDF's section and question labels, then the answers as given.
          expect(find.text('Macroscopic findings'), findsOneWidget);
          expect(find.text('Specimen size'), findsOneWidget);
          expect(find.text('3 x 2 x 1 cm'), findsOneWidget);
          expect(find.text('Microscopic findings'), findsOneWidget);
          expect(find.text('Tumour grade'), findsOneWidget);
          expect(find.text('Grade 2'), findsOneWidget);
          expect(find.text('Margins'), findsOneWidget);
          expect(find.text('Clear by 2 mm'), findsOneWidget);
          // An unknown section or question keeps its key, never blank.
          expect(find.text('Custom'), findsOneWidget);
          expect(find.text('unmappedQuestion'), findsOneWidget);
          expect(find.text('Kept as written'), findsOneWidget);

          expect(find.text('Measurements'), findsOneWidget);
          expect(find.text('Largest focus'), findsOneWidget);
          expect(find.text('2.1 mm'), findsOneWidget);

          // The PDF's order: sections by position, questions by order.
          double top(String text) => tester.getTopLeft(find.text(text)).dy;
          expect(
            top('Macroscopic findings'),
            lessThan(top('Microscopic findings')),
          );
          expect(top('Microscopic findings'), lessThan(top('Custom')));
          expect(top('Tumour grade'), lessThan(top('Margins')));
        },
      );

      testWidgets(
        'rule 7: the private notice shows until the report is released',
        (tester) async {
          await pumpScreen(tester, reader: loaded(_report()));

          final notice = find.ancestor(
            of: find.text("Amina can't see this yet"),
            matching: find.byType(NoticeCard),
          );
          expect(notice, findsOneWidget);
          expect(
            tester.widget<NoticeCard>(notice).variant,
            NoticeVariant.private,
          );
          expect(
            allText(tester),
            isNot(matches(RegExp(r'\b(she|her)\b', caseSensitive: false))),
          );

          await pumpScreen(tester, reader: loaded(_report(released: true)));

          expect(find.text("Amina can't see this yet"), findsNothing);
          expect(
            find.byWidgetPredicate(
              (w) => w is NoticeCard && w.variant == NoticeVariant.private,
            ),
            findsNothing,
          );
        },
      );

      testWidgets(
        'rule 8: no mark-as-discussed, no decisions, no bottom bar; only '
        'ReportReaderOpened is added',
        (tester) async {
          when(
            () => blocs.reportReader.state,
          ).thenReturn(const ReportReaderInitial());
          await pumpScreen(tester, reader: const ReportReaderInitial());

          expect(find.byType(BottomActionBar), findsNothing);
          expect(find.byType(TabibuButton), findsNothing);
          expect(find.text('Mark as discussed'), findsNothing);
          final added = verify(
            () => blocs.reportReader.add(captureAny()),
          ).captured;
          expect(added, [
            const ReportReaderOpened(
              uid: 'doctor-1',
              role: Role.doctor,
              caseUid: _caseUid,
            ),
          ]);
          expect(added.whereType<ReportDiscussedRequested>(), isEmpty);
          expect(added.whereType<ExplanationDecisionRequested>(), isEmpty);

          // And once the report is on screen nothing more is sent.
          await pumpScreen(tester, reader: loaded(_report()));
          expect(find.text('Mark as discussed'), findsNothing);
          verifyNever(() => blocs.reportReader.add(any()));
        },
      );
    });

    group('content', () {
      testWidgets('the top bar and the specimen card read from the report', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        expect(find.text('Pathology report'), findsOneWidget);
        expect(find.text('Amina Wambui · TB-0231'), findsOneWidget);
        expect(find.text('Specimen'), findsOneWidget);
        expect(find.text('Patient'), findsOneWidget);
        expect(
          find.text('Amina Wambui · 46 · TB-0231 · Female'),
          findsOneWidget,
        );
        expect(find.text('Collected'), findsOneWidget);
        expect(find.text('24 Oct 2026, 8:40 AM'), findsOneWidget);
        expect(find.text('Received'), findsOneWidget);
        expect(find.text('24 Oct 2026, 2:10 PM'), findsOneWidget);
        expect(find.text('Lab number'), findsOneWidget);
        expect(find.text('LAB-77/26'), findsOneWidget);
      });

      testWidgets('a missing specimen value is left out, not shown as a dash', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          reader: loaded(
            _report().copyWith(
              labAccessionNo: '',
              sampleCollectedAt: '',
              sampleReceivedAt: 'not a date',
            ),
          ),
        );

        expect(find.text('Lab number'), findsNothing);
        expect(find.text('Collected'), findsNothing);
        expect(find.text('Received'), findsNothing);
        expect(find.text('—'), findsNothing);
        expect(find.text('Patient'), findsOneWidget);
      });

      testWidgets('a signed addendum is its own card with its date', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        expect(find.text('Addendum · 29 Oct 2026, 9:00 AM'), findsOneWidget);
        expect(find.text('ER positive on repeat staining.'), findsOneWidget);
      });

      testWidgets('no addenda, no addendum card', (tester) async {
        await pumpScreen(
          tester,
          reader: loaded(_report().copyWith(addenda: const [])),
        );

        expect(find.textContaining('Addendum'), findsNothing);
      });

      testWidgets('F-11: no options, download or share on the full report', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        expect(find.byType(MoreButton), findsNothing);
        expect(find.byType(ReportFileCard), findsNothing);
        expect(find.bySemanticsLabel(RegExp('Download|Share')), findsNothing);
        expect(find.byType(CircleIconButton), findsOneWidget);
      });

      testWidgets('opens the case as the doctor, and asks for the cases when '
          'none are loaded', (tester) async {
        when(() => blocs.cases.state).thenReturn(const CasesInitial());
        await pumpScreen(tester, reader: const ReportReaderInitial());

        verify(
          () => blocs.reportReader.add(
            const ReportReaderOpened(
              uid: 'doctor-1',
              role: Role.doctor,
              caseUid: _caseUid,
            ),
          ),
        ).called(1);
        verify(
          () => blocs.cases.add(
            const CasesRequested(uid: 'doctor-1', role: Role.doctor),
          ),
        ).called(1);
        expect(find.byType(LoadingView), findsOneWidget);
      });
    });

    group('states', () {
      testWidgets('offline keeps the cached report under the connectivity '
          'banner', (tester) async {
        await pumpScreen(tester, reader: loaded(_report(), offline: true));

        expect(find.byType(ConnectivityBanner), findsOneWidget);
        expect(find.text(_diagnosis), findsOneWidget);
        expect(find.text('Grade 2'), findsOneWidget);
      });

      testWidgets('a load failure keeps the last good report on screen', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          reader: ReportReaderLoadFailure(
            error: AppError.unknown,
            uid: 'doctor-1',
            role: Role.doctor,
            caseUid: _caseUid,
            report: _report(),
          ),
        );

        expect(find.text(_diagnosis), findsOneWidget);
        expect(find.byType(EmptyState), findsNothing);
      });

      testWidgets('a 3,000-character diagnosis scrolls without overflow', (
        tester,
      ) async {
        final long = List.filled(3000, 'x').join();
        await pumpScreen(
          tester,
          reader: loaded(_report(diagnosis: long)),
          surface: const Size(1170, 2400),
        );
        final position = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position;
        expect(position.maxScrollExtent, greaterThan(0));

        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pump();

        expect(position.pixels, greaterThan(0));
        expect(tester.takeException(), isNull);
        expect(find.text(long), findsOneWidget);
      });

      testWidgets('dark mode draws the same report', (tester) async {
        await pumpScreen(
          tester,
          reader: loaded(_report()),
          themeMode: ThemeMode.dark,
        );

        expect(find.text(_diagnosis), findsOneWidget);
        expect(find.byType(NoticeCard), findsNWidgets(3));
        expect(tester.takeException(), isNull);
      });

      testWidgets('Swahili at 1.3x text on a 390 dp screen does not overflow', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390 * 3, 9000);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        when(() => blocs.reportReader.state).thenReturn(
          loaded(
            _report(
              measurements: const [
                ReportMeasurementModel(
                  key: 'Largest focus',
                  unit: 'mm',
                  value: 2.1,
                  precision: 1,
                ),
              ],
            ),
          ),
        );
        await tester.pumpRouterApp(router(), locale: const Locale('sw'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
        expect(find.text('Amina Wambui · TB-0231'), findsOneWidget);
        expect(find.text('Imesainiwa na Dr. Achieng Odhiambo'), findsOneWidget);
        expect(find.text('Sampuli'), findsOneWidget);
        expect(find.text(_diagnosis), findsOneWidget);
      });

      testWidgets('has a labelled back button', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpScreen(tester, reader: loaded(_report()));

        // With no trailing control the top bar's semantics merge the back
        // button with the title, so match the label's start.
        expect(find.bySemanticsLabel(RegExp('^Back')), findsOneWidget);
        semantics.dispose();
      });
    });
  });
}
