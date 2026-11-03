// cspell:ignore mabadiliko hariri ramani slaidi Imesainiwa maelezo
import 'package:bloc_test/bloc_test.dart';
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
import 'package:tabibu/features/reports/data/models/report_measurement_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';
import 'package:tabibu/features/reports/presentation/doctor_report_screen.dart';
import 'package:tabibu/features/reports/presentation/widgets/explanation_draft_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

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
  responses: const [
    ReportResponseModel(
      section: 'Microscopic',
      question: 'tumourGrade',
      answer: 'Grade 2',
    ),
  ],
);

const _aiExplanation = 'AI-DRAFT-EXPLANATION-SENTINEL';
const _approvedText = 'APPROVED-TEXT-SENTINEL';

void main() {
  group('DoctorReportScreen', () {
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

    GoRouter router({String caseUid = _caseUid}) {
      final routes = GoRouter(
        initialLocation: '/report',
        routes: [
          GoRoute(
            path: '/report',
            builder: (_, _) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>.value(value: authBloc),
                ...blocs.providers,
              ],
              child: DoctorReportScreen(caseUid: caseUid),
            ),
          ),
          GoRoute(
            path: '/doctor/case/:caseUid/report/full',
            builder: (_, state) =>
                Text('stub full ${state.pathParameters['caseUid']}'),
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
      Size surface = const Size(1170, 6000),
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
          expect(find.text(_comments), findsNothing);
          expect(find.byType(LoadingView), findsOneWidget);
        },
      );

      testWidgets('rule 1: a report that is not the current signed one is '
          'not shown', (tester) async {
        await pumpScreen(
          tester,
          reader: loaded(_report().copyWith(status: 'Superseded')),
        );

        expect(find.text(_diagnosis), findsNothing);
        expect(find.text('Report in progress'), findsOneWidget);
      });

      testWidgets('rule 3: no signed report shows "Report in progress" and '
          'nothing else', (tester) async {
        await pumpScreen(tester, reader: loaded(null));

        expect(find.byType(EmptyState), findsOneWidget);
        expect(find.text('Report in progress'), findsOneWidget);
        expect(
          find.text("The pathologist hasn't signed this report yet."),
          findsOneWidget,
        );
        expect(find.byType(NoticeCard), findsNothing);
        expect(find.byType(KeyValueCard), findsNothing);
        expect(find.text(_diagnosis), findsNothing);
        expect(find.byType(MoreButton), findsNothing);
      });

      testWidgets('rule 4: no AI diff, change count, edit marker, heatmap or '
          'slide row, in English or Swahili', (tester) async {
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
      });

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

      testWidgets('rule 5: no AI frame, AI colour or sparkle; the banner is '
          'the signed notice', (tester) async {
        await pumpScreen(tester, reader: loaded(_report()));

        expect(find.byType(AiDraftFrame), findsNothing);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is AssetIcon && w.asset.path == Assets.icons.sparkleIcon.path,
          ),
          findsNothing,
        );
        final notices = tester.widgetList<NoticeCard>(find.byType(NoticeCard));
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

        // No AI-draft colour is painted anywhere on the screen.
        final status = Theme.of(
          tester.element(find.byType(DoctorReportScreen)),
        ).extension<AppStatusColors>()!;
        final painted = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .map((d) => d.decoration)
            .whereType<BoxDecoration>()
            .map((d) => d.color);
        expect(painted, isNot(contains(status.aiDraftContainer)));
      });

      testWidgets('rule 6: diagnosis, comments and measurements are verbatim '
          'with the PDF labels', (tester) async {
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
        expect(find.text('Comments'), findsOneWidget);
        expect(find.text('Measurements'), findsOneWidget);
        expect(find.text('Largest focus'), findsOneWidget);
        expect(find.text('2.1 mm'), findsOneWidget);
      });

      testWidgets('rule 7: the private notice shows until the report is '
          'released', (tester) async {
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
      });

      testWidgets('rule 8: while loading, no release or decision control and '
          'only ReportReaderOpened is added', (tester) async {
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
      });
    });

    group('explanations (R-4)', () {
      final l10n = lookupAppLocalizations(const Locale('en'));

      ReportTextModel draft(String language, [String text = _aiExplanation]) =>
          ReportTextModel(
            uid: 'v1_Explanation_$language',
            kind: 'Explanation',
            language: language,
            status: 'Ready',
            machineText: {'summary': text},
          );

      ReportTextApprovedModel approvedText(
        String language, [
        String text = _approvedText,
      ]) => ReportTextApprovedModel(
        uid: 'v1_Explanation_$language',
        language: language,
        approvedText: {'summary': text},
      );

      Future<void> settleSheet(WidgetTester tester) async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }

      List<ReportReaderEvent> sent() => verify(
        () => blocs.reportReader.add(captureAny()),
      ).captured.cast<ReportReaderEvent>();

      Finder inFrame(String text) => find.descendant(
        of: find.byType(AiDraftFrame),
        matching: find.text(text),
      );

      Color? fillOf(WidgetTester tester, String label) => tester
          .widget<Material>(
            find
                .descendant(
                  of: find.widgetWithText(TabibuButton, label),
                  matching: find.byType(Material),
                )
                .first,
          )
          .color;

      Finder draftMore() => find.descendant(
        of: find.byType(ExplanationDraftCard),
        matching: find.byType(MoreButton),
      );

      Future<void> openEdit(WidgetTester tester) async {
        await tester.tap(find.text(l10n.reviewEdit));
        await settleSheet(tester);
      }

      group('before release', () {
        testWidgets('rule 1: Mark as discussed is the one primary action and '
            'nothing is sent until it is confirmed', (tester) async {
          await pumpScreen(tester, reader: loaded(_report()));

          expect(find.text(l10n.explanationMarkButton), findsOneWidget);
          final status = Theme.of(
            tester.element(find.byType(DoctorReportScreen)),
          ).extension<AppStatusColors>()!;
          expect(fillOf(tester, l10n.explanationMarkButton), status.ink);
          expect(find.byType(AiDraftFrame), findsNothing);
          verifyNever(() => blocs.reportReader.add(any()));
        });

        testWidgets('rule 4: the sheet says what happens, asks for no mode or '
            'date and carries no AI text', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(_report(), explanations: {'en': draft('en')}),
          );
          await tester.tap(find.text(l10n.explanationMarkButton));
          await settleSheet(tester);

          expect(find.text(l10n.explanationMarkTitle('Amina')), findsOneWidget);
          expect(find.text(l10n.explanationReleaseNote), findsOneWidget);
          expect(find.text(l10n.explanationConfirm), findsOneWidget);
          expect(find.text(l10n.explanationInPerson), findsNothing);
          expect(find.text(l10n.explanationPhoneOrVideo), findsNothing);
          expect(find.text(l10n.explanationWhen), findsNothing);
          expect(find.byType(TextField), findsNothing);
          expect(find.textContaining(_aiExplanation), findsNothing);
          expect(find.textContaining(_approvedText), findsNothing);
          verifyNever(() => blocs.reportReader.add(any()));
        });

        testWidgets('rule 4: Cancel sends nothing', (tester) async {
          await pumpScreen(tester, reader: loaded(_report()));
          await tester.tap(find.text(l10n.explanationMarkButton));
          await settleSheet(tester);

          await tester.tap(find.text(l10n.commonCancel));
          await settleSheet(tester);

          verifyNever(() => blocs.reportReader.add(any()));
          expect(find.text(l10n.explanationConfirm), findsNothing);
        });

        testWidgets('rule 4: confirming sends only ReportDiscussedRequested, '
            'once the sheet has slid away', (tester) async {
          await pumpScreen(tester, reader: loaded(_report()));
          await tester.tap(find.text(l10n.explanationMarkButton));
          await settleSheet(tester);

          await tester.tap(find.text(l10n.explanationConfirm));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          verifyNever(() => blocs.reportReader.add(any()));

          await settleSheet(tester);
          expect(sent(), [const ReportDiscussedRequested()]);
        });

        testWidgets('a write in progress turns the button to a spinner that '
            'does not open the sheet', (tester) async {
          await pumpScreen(
            tester,
            reader: ReportReaderWriteInProgress(
              uid: 'doctor-1',
              role: Role.doctor,
              caseUid: _caseUid,
              report: _report(),
            ),
          );

          await tester.tap(find.byType(TabibuButton), warnIfMissed: false);
          await settleSheet(tester);

          expect(find.text(l10n.explanationConfirm), findsNothing);
          verifyNever(() => blocs.reportReader.add(any()));
        });

        testWidgets('a failed release keeps the report and the button, and '
            'shows the error', (tester) async {
          final report = _report();
          whenListen(
            blocs.reportReader,
            Stream<ReportReaderState>.value(
              ReportReaderWriteFailure(
                error: AppError.noInternet,
                uid: 'doctor-1',
                role: Role.doctor,
                caseUid: _caseUid,
                report: report,
              ),
            ),
            initialState: loaded(report),
          );
          await tester.pumpRouterApp(router());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));

          expect(
            find.text(AppError.noInternet.description(l10n)),
            findsOneWidget,
          );
          expect(find.text(_diagnosis), findsOneWidget);
          expect(find.text(l10n.explanationMarkButton), findsOneWidget);
          await tester.pump(const Duration(seconds: 5));
        });
      });

      group('after release', () {
        testWidgets('rule 2: each draft sits in the AI frame, verbatim, with '
            'the patient and language in its title', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {
                'en': draft('en', '  English draft\nline two  '),
                'sw': draft('sw', 'Rasimu ya Kiswahili'),
              },
            ),
          );

          expect(find.byType(AiDraftFrame), findsNWidgets(2));
          expect(find.text(l10n.alertReviewAiDraftNotSent), findsNWidgets(2));
          expect(inFrame('  English draft\nline two  '), findsOneWidget);
          expect(inFrame('Rasimu ya Kiswahili'), findsOneWidget);
          expect(
            find.text(l10n.explanationDraftTitle('Amina', 'English')),
            findsOneWidget,
          );
          expect(
            find.text(l10n.explanationDraftTitle('Amina', 'Kiswahili')),
            findsOneWidget,
          );
          expect(find.text(l10n.explanationMarkButton), findsNothing);
        });

        testWidgets('rule 1: showing drafts sends nothing', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en'), 'sw': draft('sw')},
            ),
          );

          verifyNever(() => blocs.reportReader.add(any()));
        });

        testWidgets('rule 2: approved text sits outside any AI frame, marked '
            'Approved', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              approved: {'en': approvedText('en'), 'sw': approvedText('sw')},
            ),
          );

          expect(find.text(_approvedText), findsNWidgets(2));
          expect(find.byType(AiDraftFrame), findsNothing);
          expect(
            find.ancestor(
              of: find.text(_approvedText).first,
              matching: find.byType(AiDraftFrame),
            ),
            findsNothing,
          );
          expect(find.text(l10n.explanationApproved), findsNWidgets(2));
          expect(find.text(l10n.explanationWaitingForDraft), findsNothing);
          expect(
            find.byWidgetPredicate(
              (w) => w is NoticeCard && w.variant == NoticeVariant.aiDraft,
            ),
            findsNothing,
          );
        });

        testWidgets('rule 2: one language approved, the other still a draft', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'sw': draft('sw')},
              approved: {'en': approvedText('en')},
            ),
          );

          expect(inFrame(_aiExplanation), findsOneWidget);
          expect(find.text(_approvedText), findsOneWidget);
          expect(inFrame(_approvedText), findsNothing);
        });

        testWidgets('rule 3: Approve as is is the primary action and Edit the '
            'secondary; Reject is not a button on the card', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en')},
            ),
          );

          final theme = Theme.of(
            tester.element(find.byType(DoctorReportScreen)),
          );
          expect(
            fillOf(tester, l10n.alertReviewApproveAsIs),
            theme.extension<AppStatusColors>()!.ink,
          );
          expect(
            fillOf(tester, l10n.reviewEdit),
            theme.colorScheme.surfaceContainerHigh,
          );
          expect(find.text(l10n.alertReviewReject), findsNothing);
          final approveY = tester
              .getTopLeft(find.text(l10n.alertReviewApproveAsIs))
              .dy;
          final editY = tester.getTopLeft(find.text(l10n.reviewEdit)).dy;
          expect(approveY, lessThan(editY));
        });

        testWidgets('rule 1: Approve as is sends the decision for that '
            'language only', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en'), 'sw': draft('sw')},
            ),
          );

          await tester.tap(find.text(l10n.alertReviewApproveAsIs).last);
          await tester.pump();

          expect(sent(), [const ExplanationDecisionRequested(language: 'sw')]);
        });

        testWidgets('rule 1: Edit opens a prefilled sheet that sends the '
            'edited text, without approving yet', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en')},
            ),
          );
          await openEdit(tester);

          expect(find.text(l10n.explanationEditTitle), findsOneWidget);
          final field = tester.widget<TextField>(find.byType(TextField));
          expect(field.controller?.text, _aiExplanation);
          verifyNever(() => blocs.reportReader.add(any()));

          await tester.enterText(
            find.byType(TextField),
            'Edited by the doctor',
          );
          await tester.pump();
          await tester.tap(find.text(l10n.explanationSaveAndApprove));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          verifyNever(() => blocs.reportReader.add(any()));

          await settleSheet(tester);
          expect(sent(), [
            const ExplanationDecisionRequested(
              language: 'en',
              editedText: {'summary': 'Edited by the doctor'},
            ),
          ]);
        });

        testWidgets('rule 1: an unchanged edit is sent as it is; the reader '
            'turns it into an approval', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en')},
            ),
          );
          await openEdit(tester);

          await tester.tap(find.text(l10n.explanationSaveAndApprove));
          await settleSheet(tester);

          expect(sent(), [
            const ExplanationDecisionRequested(
              language: 'en',
              editedText: {'summary': _aiExplanation},
            ),
          ]);
        });

        testWidgets('a blank segment cannot be saved and closing the sheet '
            'sends nothing', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en')},
            ),
          );
          await openEdit(tester);

          await tester.enterText(find.byType(TextField), '   ');
          await tester.pump();
          await tester.tap(find.text(l10n.explanationSaveAndApprove));
          await settleSheet(tester);
          expect(find.text(l10n.explanationEditTitle), findsOneWidget);

          await tester.tap(find.text(l10n.commonCancel));
          await settleSheet(tester);
          expect(find.text(l10n.explanationEditTitle), findsNothing);
          verifyNever(() => blocs.reportReader.add(any()));
        });

        testWidgets('rule 3: Reject takes the options button and a '
            'confirmation, then rejects that language', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en')},
            ),
          );
          final title = l10n.explanationDraftTitle('Amina', 'English');

          await tester.tap(draftMore());
          await settleSheet(tester);
          expect(find.text(l10n.alertReviewReject), findsOneWidget);
          verifyNever(() => blocs.reportReader.add(any()));

          await tester.tap(find.text(l10n.alertReviewReject));
          await settleSheet(tester);
          // The confirmation: the same name again, a Reject button, Cancel.
          expect(find.text(title), findsNWidgets(2));
          expect(find.text(l10n.alertReviewReject), findsOneWidget);
          expect(find.text(l10n.commonCancel), findsOneWidget);
          verifyNever(() => blocs.reportReader.add(any()));

          await tester.tap(find.text(l10n.alertReviewReject));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          verifyNever(() => blocs.reportReader.add(any()));

          await settleSheet(tester);
          expect(sent(), [
            const ExplanationDecisionRequested(language: 'en', reject: true),
          ]);
        });

        testWidgets('rule 3: backing out of the confirmation rejects '
            'nothing', (tester) async {
          await pumpScreen(
            tester,
            reader: loaded(
              _report(released: true),
              explanations: {'en': draft('en')},
            ),
          );

          await tester.tap(draftMore());
          await settleSheet(tester);
          await tester.tap(find.text(l10n.alertReviewReject));
          await settleSheet(tester);
          await tester.tap(find.text(l10n.commonCancel));
          await settleSheet(tester);

          verifyNever(() => blocs.reportReader.add(any()));
          expect(find.byType(AiDraftFrame), findsOneWidget);
        });

        testWidgets('waiting for the draft: says so and refreshes by '
            'reopening the case', (tester) async {
          await pumpScreen(tester, reader: loaded(_report(released: true)));

          expect(find.text(l10n.explanationWaitingForDraft), findsOneWidget);
          expect(find.byType(AiDraftFrame), findsNothing);
          verifyNever(() => blocs.reportReader.add(any()));

          await tester.tap(find.text(l10n.commonRetry));
          await tester.pump();

          expect(sent(), [
            const ReportReaderOpened(
              uid: 'doctor-1',
              role: Role.doctor,
              caseUid: _caseUid,
            ),
          ]);
        });

        testWidgets('a write in progress turns every control off', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            reader: ReportReaderWriteInProgress(
              uid: 'doctor-1',
              role: Role.doctor,
              caseUid: _caseUid,
              report: _report(released: true),
              explanations: {'en': draft('en')},
            ),
          );

          await tester.tap(find.text(l10n.alertReviewApproveAsIs));
          await tester.tap(find.text(l10n.reviewEdit));
          await tester.tap(draftMore(), warnIfMissed: false);
          await settleSheet(tester);

          verifyNever(() => blocs.reportReader.add(any()));
          expect(find.text(l10n.explanationEditTitle), findsNothing);
          expect(find.text(l10n.alertReviewReject), findsNothing);
          expect(inFrame(_aiExplanation), findsOneWidget);
        });

        testWidgets('a failed decision keeps the draft and shows the error', (
          tester,
        ) async {
          final report = _report(released: true);
          final drafts = {'en': draft('en')};
          whenListen(
            blocs.reportReader,
            Stream<ReportReaderState>.value(
              ReportReaderWriteFailure(
                error: AppError.noInternet,
                uid: 'doctor-1',
                role: Role.doctor,
                caseUid: _caseUid,
                report: report,
                explanations: drafts,
              ),
            ),
            initialState: loaded(report, explanations: drafts),
          );
          await tester.pumpRouterApp(router());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));

          expect(
            find.text(AppError.noInternet.description(l10n)),
            findsOneWidget,
          );
          expect(inFrame(_aiExplanation), findsOneWidget);
          expect(find.text(l10n.alertReviewApproveAsIs), findsOneWidget);
          await tester.pump(const Duration(seconds: 5));
        });
      });

      group('rule 5: a patient role', () {
        testWidgets('never sees an explanation, a draft or a release control', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            reader: ReportReaderLoadSuccess(
              uid: 'patient-1',
              role: Role.patient,
              caseUid: _caseUid,
              report: _report(released: true),
              explanations: {'en': draft('en'), 'sw': draft('sw')},
              approved: {'en': approvedText('en')},
            ),
          );

          expect(find.byType(AiDraftFrame), findsNothing);
          expect(find.textContaining(_aiExplanation), findsNothing);
          expect(find.textContaining(_approvedText), findsNothing);
          expect(find.text(l10n.explanationWaitingForDraft), findsNothing);
          expect(find.text(l10n.alertReviewApproveAsIs), findsNothing);
          expect(find.text(l10n.explanationMarkButton), findsNothing);
          verifyNever(() => blocs.reportReader.add(any()));
        });

        testWidgets('is offered no release on an unreleased report', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            reader: ReportReaderLoadSuccess(
              uid: 'patient-1',
              role: Role.patient,
              caseUid: _caseUid,
              report: _report(),
            ),
          );

          expect(find.text(l10n.explanationMarkButton), findsNothing);
        });
      });

      group('layout', () {
        testWidgets('drafts and approved text draw in dark mode', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            themeMode: ThemeMode.dark,
            reader: loaded(
              _report(released: true),
              explanations: {'sw': draft('sw')},
              approved: {'en': approvedText('en')},
            ),
          );

          expect(inFrame(_aiExplanation), findsOneWidget);
          expect(find.text(_approvedText), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        for (final scale in const [1.3, 2.0]) {
          testWidgets(
            'Swahili at ${scale}x text on a 390 dp screen, with a long '
            'draft, does not overflow',
            (tester) async {
              tester.platformDispatcher.textScaleFactorTestValue = scale;
              addTearDown(
                tester.platformDispatcher.clearTextScaleFactorTestValue,
              );
              final long = List.filled(400, 'maelezo').join(' ');
              await pumpScreen(
                tester,
                locale: const Locale('sw'),
                surface: const Size(390 * 3, 12000),
                reader: loaded(
                  _report(released: true),
                  explanations: {
                    'en': draft('en', long),
                    'sw': draft('sw', long),
                  },
                  approved: {'en': approvedText('en')},
                ),
              );
              final sw = lookupAppLocalizations(const Locale('sw'));

              expect(tester.takeException(), isNull);
              expect(find.text(sw.alertReviewApproveAsIs), findsWidgets);
              expect(
                find.text(sw.explanationDraftTitle('Amina', sw.languageEn)),
                findsOneWidget,
              );
            },
          );
        }

        for (final scale in const [1.3, 2.0]) {
          testWidgets('Swahili sheet at ${scale}x text does not overflow', (
            tester,
          ) async {
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final sw = lookupAppLocalizations(const Locale('sw'));
            await pumpScreen(
              tester,
              locale: const Locale('sw'),
              surface: const Size(1170, 12000),
              reader: loaded(_report()),
            );

            await tester.tap(find.text(sw.explanationMarkButton));
            await settleSheet(tester);

            expect(find.text(sw.explanationMarkTitle('Amina')), findsOneWidget);
            expect(tester.takeException(), isNull);
          });
        }
      });
    });

    group('data', () {
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

      testWidgets('does not reopen a case the reader already holds', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        verifyNever(() => blocs.reportReader.add(any()));
        verifyNever(() => blocs.cases.add(any()));
      });

      testWidgets('the top bar names the report, the patient and the order', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        expect(find.text('Pathology report'), findsOneWidget);
        expect(find.text('Amina Wambui · TB-0231'), findsOneWidget);
      });
    });

    group('options', () {
      testWidgets('the options sheet has one row that opens the full report', (
        tester,
      ) async {
        await pumpScreen(tester, reader: loaded(_report()));

        await tester.tap(find.byType(MoreButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Open pathology report'), findsOneWidget);
        expect(find.text('Full findings'), findsOneWidget);
        expect(find.textContaining('MDT consult'), findsNothing);
        expect(find.textContaining('Message'), findsNothing);

        await tester.tap(find.text('Open pathology report'));
        await tester.pumpAndSettle();

        expect(find.text('stub full case-1'), findsOneWidget);
      });
    });

    group('states', () {
      testWidgets('offline keeps the cached report under the connectivity '
          'banner', (tester) async {
        await pumpScreen(tester, reader: loaded(_report(), offline: true));

        expect(find.byType(ConnectivityBanner), findsOneWidget);
        expect(find.text("You're offline"), findsOneWidget);
        expect(find.text(_diagnosis), findsOneWidget);
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

      testWidgets('shows the error notification when a load fails', (
        tester,
      ) async {
        whenListen(
          blocs.reportReader,
          Stream<ReportReaderState>.value(
            ReportReaderLoadFailure(
              error: AppError.noInternet,
              uid: 'doctor-1',
              role: Role.doctor,
              caseUid: _caseUid,
              report: _report(),
            ),
          ),
          initialState: loaded(_report()),
        );
        await tester.pumpRouterApp(router());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(
          find.text(
            AppError.noInternet.description(
              lookupAppLocalizations(const Locale('en')),
            ),
          ),
          findsOneWidget,
        );
        expect(find.text(_diagnosis), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
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
        tester.view.physicalSize = const Size(390 * 3, 6000);
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
        expect(find.text(_diagnosis), findsOneWidget);
      });

      testWidgets('has a labelled back button', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpScreen(tester, reader: loaded(_report()));

        expect(
          find.bySemanticsLabel(
            lookupAppLocalizations(const Locale('en')).commonBack,
          ),
          findsOneWidget,
        );
        semantics.dispose();
      });
    });
  });
}
