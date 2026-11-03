import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/app/view/app.dart' show tabibuLocalizationsDelegates;
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_lab_test_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/preread/data/datasources/preread_storage.dart';
import 'package:tabibu/features/preread/data/models/preread_draft_model.dart';
import 'package:tabibu/features/preread/data/models/preread_finding_model.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_event.dart';
import 'package:tabibu/features/reports/blocs/case_workspace_bloc/case_workspace_state.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';
import 'package:tabibu/features/reports/data/models/report_template_model.dart';
import 'package:tabibu/features/reports/data/models/report_template_question_model.dart';
import 'package:tabibu/features/reports/data/models/report_template_section_model.dart';
import 'package:tabibu/features/reports/presentation/case_workspace_screen.dart';
import 'package:tabibu/features/reports/presentation/widgets/signature_pad.dart';
import 'package:tabibu/features/reports/presentation/widgets/signed_case_view.dart';
import 'package:tabibu/features/reports/presentation/widgets/verdict_selector.dart';
import 'package:tabibu/features/reports/presentation/widgets/workspace_score_card.dart';
import 'package:tabibu/features/worklist/presentation/widgets/ai_mark.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

class MockReferenceDataHelper extends Mock implements ReferenceDataHelper {}

class MockPrereadStorage extends Mock implements PrereadStorage {}

const _caseUid = 'case-1';
const _runUid = 'run-1';
const _smear = '9f7bb988-7068-4bc4-a7c5-08c690da9482';
const _histology = 'histology-lab-test';

const _aiImpression = 'Malaria parasites are seen on the smear.';
const _aiFinding = 'Ring forms are present in the thin film.';
const _aiNextStep = 'Repeat the smear in six hours.';
const _ownDiagnosis = 'Plasmodium infection confirmed on microscopy.';
const _ownComments = 'Discuss treatment with the doctor.';

const _malaria = NotifiableDiseaseModel(
  diseaseId: 'malaria',
  nameEn: 'Malaria',
  nameSw: 'Malaria',
  reportingCategory: 'Weekly',
  labTests: [NotifiableLabTestModel(labTestId: _smear, strength: 'Confirms')],
);

// Only presumptive on this smear: never offered for a tick.
const _dengue = NotifiableDiseaseModel(
  diseaseId: 'dengue',
  nameEn: 'Dengue',
  nameSw: 'Dengue',
  reportingCategory: 'Weekly',
  labTests: [
    NotifiableLabTestModel(labTestId: _smear, strength: 'Presumptive'),
  ],
);

// Confirmed by this smear but not on the register.
const _unlisted = NotifiableDiseaseModel(
  diseaseId: 'unlisted',
  nameEn: 'Unlisted fever',
  nameSw: 'Unlisted fever',
  labTests: [NotifiableLabTestModel(labTestId: _smear, strength: 'Confirms')],
);

const List<NotifiableDiseaseModel> _register = [_malaria, _dengue, _unlisted];

CaseModel _case({String testId = _smear}) => CaseModel(
  uid: _caseUid,
  orderNumber: 'TB-0231',
  patientName: 'Amina Wambui',
  patientSex: 'Female',
  patientAgeYears: 46,
  doctorName: 'Dr. Wanjiru Kamau',
  tests: [OrderedTestModel(labTestId: testId, name: 'Malaria smear')],
);

ReportDraftModel _draft({
  String diagnosis = '',
  String comments = '',
  String run = _runUid,
  bool fromPreread = false,
  List<NotifiableFindingModel> findings = const [],
}) => ReportDraftModel(
  uid: 'draft-1',
  caseUid: _caseUid,
  prereadRunUid: run,
  diagnosis: diagnosis,
  comments: comments,
  startedFromPreread: fromPreread,
  notifiableFindings: findings,
);

PrereadModel _preread({String status = 'Ready'}) => PrereadModel(
  uid: _runUid,
  caseUid: _caseUid,
  profile: 'Malaria',
  status: status,
  imagePaths: const ['slides/smear.png'],
  micronsPerPixel: 0.25,
  measurements: const {'density': 2.5},
  models: const {'segmentation': 'seg-model-v1'},
  draft: const PrereadDraftModel(
    impression: _aiImpression,
    findings: [PrereadFindingModel(text: _aiFinding)],
    confidence: 0.87,
    confidenceBand: 'High',
    urgency: 'Priority',
    nextSteps: [_aiNextStep],
  ),
);

const _score = PrereadScoreModel(uid: _runUid, runUid: _runUid, overall: 4);

CaseWorkspaceLoadSuccess _loaded({
  ReportDraftModel? draft,
  PrereadModel? preread,
  PrereadScoreModel? score,
  CaseModel? caseModel,
  bool offline = false,
}) => CaseWorkspaceLoadSuccess(
  caseUid: _caseUid,
  caseModel: caseModel ?? _case(),
  draft: draft ?? _draft(),
  preread: preread,
  score: score,
  offline: offline,
);

CaseWorkspaceWriteFailure _failed(CaseWorkspaceState from) =>
    CaseWorkspaceWriteFailure(
      error: AppError.unknown,
      caseUid: from.caseUid,
      caseModel: from.caseModel,
      draft: from.draft,
      preread: from.preread,
      score: from.score,
    );

// A report the pathologist can sign: own text, no AI pre-read to score.
CaseWorkspaceLoadSuccess _signable({
  List<NotifiableFindingModel> findings = const [],
  bool offline = false,
}) => _loaded(
  draft: _draft(
    diagnosis: _ownDiagnosis,
    comments: _ownComments,
    run: '',
    findings: findings,
  ),
  offline: offline,
);

// A ready pre-read, not yet scored: the report is locked.
CaseWorkspaceLoadSuccess _locked({
  String diagnosis = '',
  bool fromPreread = false,
}) => _loaded(
  draft: _draft(diagnosis: diagnosis, fromPreread: fromPreread),
  preread: _preread(),
);

// A ready pre-read, scored: the AI draft can be adopted or set aside.
CaseWorkspaceLoadSuccess _chooser() =>
    _loaded(draft: _draft(), preread: _preread(), score: _score);

CaseWorkspaceLoadSuccess _adopted({
  String diagnosis = _aiImpression,
  String comments = _aiFinding,
}) => _loaded(
  draft: _draft(diagnosis: diagnosis, comments: comments, fromPreread: true),
  preread: _preread(),
  score: _score,
);

const _signedReport = PathologyReportModel(
  uid: 'report-1',
  caseUid: _caseUid,
  orderNumber: 'TB-0231',
  diagnosis: _ownDiagnosis,
  comments: _ownComments,
  signedByName: 'Achieng Odhiambo',
  signedAt: '2026-10-27T07:42:00Z',
);

void main() {
  group('CaseWorkspaceScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;
    late MockReferenceDataHelper reference;
    late MockPrereadStorage storage;
    late StreamController<CaseWorkspaceState> states;
    late AppLocalizations l10n;
    late AppLocalizations swL10n;

    setUpAll(() async {
      registerFallbackValue(const CaseWorkspaceReset());
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
      swL10n = await AppLocalizations.delegate.load(const Locale('sw'));
    });

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      reference = MockReferenceDataHelper();
      storage = MockPrereadStorage();
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: RoleSessions.pathologist));
      when(reference.notifiableDiseases).thenAnswer((_) async => _register);
      when(() => storage.downloadUrl(any())).thenAnswer((_) async => null);
    });

    // The blocs sit above the app, as in the real tree: the sign sheet is
    // pushed on the root navigator and must still reach the workspace bloc.
    Future<void> pumpScreen(
      WidgetTester tester,
      CaseWorkspaceState state, {
      ThemeMode themeMode = .light,
      Locale? locale,
      Size surface = const Size(1170, 12000),
      double textScale = 1,
    }) async {
      tester.view.physicalSize = surface;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      states = StreamController<CaseWorkspaceState>.broadcast();
      addTearDown(states.close);
      whenListen(blocs.caseWorkspace, states.stream, initialState: state);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => CaseWorkspaceScreen(
              caseUid: _caseUid,
              reference: reference,
              storage: storage,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      // Clear the last pump so the screen's initState runs again.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: MaterialApp.router(
            key: ValueKey(themeMode),
            theme: buildTheme(.light),
            darkTheme: buildTheme(.dark),
            themeMode: themeMode,
            localizationsDelegates: tabibuLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> emit(WidgetTester tester, CaseWorkspaceState state) async {
      states.add(state);
      // One pump delivers the state, the next draws it.
      await tester.pump();
      await tester.pump();
    }

    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> openSignSheet(WidgetTester tester) async {
      await tester.tap(find.text(l10n.workspaceSignReport));
      await settleSheet(tester);
    }

    Future<void> drawStroke(WidgetTester tester) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SignaturePad)),
      );
      await gesture.moveBy(const Offset(60, 0));
      await gesture.moveBy(const Offset(40, 20));
      await gesture.up();
      await tester.pump();
    }

    Future<void> tickAttestation(WidgetTester tester) async {
      await tester.tap(find.text(l10n.signSheetAttestation));
      await tester.pump();
    }

    bool attested(WidgetTester tester) => tester
        .widget<CheckRow>(
          find.widgetWithText(CheckRow, l10n.signSheetAttestation),
        )
        .value;

    TabibuButton button(WidgetTester tester, String label) =>
        tester.widget<TabibuButton>(find.widgetWithText(TabibuButton, label));

    bool enabled(WidgetTester tester, String label) =>
        button(tester, label).onTap != null;

    TabibuTextField field(WidgetTester tester, String label) =>
        tester.widget<TabibuTextField>(
          find.byWidgetPredicate(
            (w) => w is TabibuTextField && w.label == label,
          ),
        );

    Finder inFrame(Finder of) =>
        find.ancestor(of: of, matching: find.byType(AiDraftFrame));

    Finder aiDraftFrames() => find.byWidgetPredicate(
      (w) => w is AiDraftFrame && w.label == l10n.workspaceAiDraft,
    );

    Finder scoreChips() => find.descendant(
      of: find.byType(WorkspaceScoreCard),
      matching: find.byType(TabibuFilterChip),
    );

    Finder scoreOption(String text, {int at = 0}) => find
        .descendant(
          of: find.byType(WorkspaceScoreCard),
          matching: find.text(text),
        )
        .at(at);

    // Every explicit colour painted under [root].
    List<Color> colours(WidgetTester tester, Finder root) {
      Iterable<Widget> under(Type type) => find
          .descendant(of: root, matching: find.byType(type))
          .evaluate()
          .map((e) => e.widget);
      final painted = <Color>[];
      for (final w in under(DecoratedBox).cast<DecoratedBox>()) {
        final decoration = w.decoration;
        final color = decoration is BoxDecoration ? decoration.color : null;
        if (color != null) painted.add(color);
      }
      for (final w in under(Text).cast<Text>()) {
        final color = w.style?.color;
        if (color != null) painted.add(color);
      }
      for (final w in under(AssetIcon).cast<AssetIcon>()) {
        final color = w.color;
        if (color != null) painted.add(color);
      }
      for (final w in under(DashedBorder).cast<DashedBorder>()) {
        painted.add(w.color);
      }
      return painted;
    }

    void expectNoSignedColour(WidgetTester tester, Finder root) {
      final status = Theme.of(
        tester.element(find.byType(CaseWorkspaceScreen)),
      ).extension<AppStatusColors>()!;
      final painted = colours(tester, root);
      expect(painted, isNotEmpty);
      expect(
        painted,
        everyElement(
          isNot(anyOf(status.signed, status.signedDot, status.signedContainer)),
        ),
      );
    }

    group('a case asked of this pathologist', () {
      CaseWorkspaceLoadSuccess asked() => CaseWorkspaceLoadSuccess(
        caseUid: _caseUid,
        caseModel: CaseModel(
          uid: _caseUid,
          orderNumber: 'TB-0231',
          currentStage: 'PathologistRequested',
          requestedPathologistUid: RoleSessions.pathologist.doctor.uid,
          priority: 'Urgent',
          sampleNotes: 'Left axilla',
          clinicalNotes: 'Invasive ductal carcinoma on biopsy.',
          requiresSlides: true,
          tests: const [OrderedTestModel(name: 'Histopathology examination')],
        ),
      );

      testWidgets('shows the order with Accept and Decline, nothing of the '
          'workspace', (tester) async {
        await pumpScreen(tester, asked());

        expect(find.text(l10n.workspaceRequestTitle), findsOneWidget);
        expect(find.text('Histopathology examination'), findsWidgets);
        expect(find.text('Left axilla'), findsOneWidget);
        expect(find.text(l10n.doctorCaseUrgent), findsOneWidget);
        expect(find.text(l10n.workspaceRequestAccept), findsOneWidget);
        expect(find.text(l10n.workspaceRequestDecline), findsOneWidget);
        expect(find.byType(WorkspaceScoreCard), findsNothing);
      });

      testWidgets('Accept sends the acceptance', (tester) async {
        await pumpScreen(tester, asked());

        await tester.tap(find.text(l10n.workspaceRequestAccept));
        await tester.pump();

        verify(
          () => blocs.caseWorkspace.add(const CaseRequestAccepted()),
        ).called(1);
      });

      testWidgets('Decline needs a reason, then sends it trimmed', (
        tester,
      ) async {
        await pumpScreen(tester, asked());

        await tester.tap(find.text(l10n.workspaceRequestDecline));
        await settleSheet(tester);
        expect(find.text(l10n.workspaceRequestDeclineTitle), findsOneWidget);

        // Empty: said, and nothing is sent.
        await tester.tap(
          find.descendant(
            of: find.byType(TabibuBottomSheet),
            matching: find.text(l10n.workspaceRequestDecline),
          ),
        );
        await tester.pump();
        expect(find.text(l10n.workspaceRequestReasonRequired), findsOneWidget);
        verifyNever(() => blocs.caseWorkspace.add(any()));

        await tester.enterText(
          find.descendant(
            of: find.byType(TabibuBottomSheet),
            matching: find.byType(TextField),
          ),
          '  On leave this week  ',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(TabibuBottomSheet),
            matching: find.text(l10n.workspaceRequestDecline),
          ),
        );
        await settleSheet(tester);

        verify(
          () => blocs.caseWorkspace.add(
            const CaseRequestDeclined(reason: 'On leave this week'),
          ),
        ).called(1);
      });
    });

    group('an accepted case with no sample recorded', () {
      testWidgets('opens on the accession, starting from a made-up number', (
        tester,
      ) async {
        final base = RoleSessions.pathologist;
        when(() => authBloc.state).thenReturn(
          SignInSuccess(
            session: PractitionerSession(
              doctor: base.doctor.copyWith(
                uid: 'path-1',
                firstName: 'Wanjiru',
                lastName: 'Kamau',
              ),
              roles: base.roles,
            ),
          ),
        );
        await pumpScreen(
          tester,
          const CaseWorkspaceLoadSuccess(
            caseUid: _caseUid,
            caseModel: CaseModel(
              uid: _caseUid,
              orderNumber: 'ODR-AO-AO-03112026-005',
              currentStage: 'PrereadReady',
              pathologistUid: 'path-1',
            ),
          ),
        );

        expect(find.text(l10n.workspaceSampleTitle), findsOneWidget);
        // Today's date is in the number, so it is read by its shape.
        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byType(TabibuTextField),
            matching: find.byType(TextField),
          ),
        );
        expect(field.controller?.text, matches(RegExp(r'^LAB-WK-\d{8}-005$')));
      });
    });

    group('the template questions', () {
      const cancer = ReportTemplateModel(
        templateKey: 'Cancer',
        sections: [
          ReportTemplateSectionModel(
            sectionKey: 'Macroscopic',
            order: 1,
            questions: [
              ReportTemplateQuestionModel(
                questionKey: 'specimenDescription',
                order: 1,
                required: true,
              ),
              ReportTemplateQuestionModel(
                questionKey: 'specimenSize',
                order: 2,
              ),
            ],
          ),
          ReportTemplateSectionModel(
            sectionKey: 'Microscopic',
            order: 2,
            questions: [
              ReportTemplateQuestionModel(
                questionKey: 'microscopicDescription',
                order: 1,
                required: true,
              ),
            ],
          ),
        ],
      );

      ReportDraftModel draft({
        List<ReportResponseModel> responses = const [],
      }) => ReportDraftModel(
        uid: 'draft-1',
        caseUid: _caseUid,
        diagnosis: _ownDiagnosis,
        comments: _ownComments,
        templateKey: 'Cancer',
        responses: responses,
      );

      CaseWorkspaceLoadSuccess loaded(ReportDraftModel d) =>
          CaseWorkspaceLoadSuccess(
            caseUid: _caseUid,
            caseModel: _case(),
            draft: d,
          );

      setUp(
        () => when(reference.reportTemplates).thenAnswer((_) async => [cancer]),
      );

      Finder questionField(String label) => find.byWidgetPredicate(
        (w) => w is TabibuTextField && w.label == label,
      );

      testWidgets('each question is a field, the required ones starred', (
        tester,
      ) async {
        await pumpScreen(tester, loaded(draft()));

        final specimen = tester.widget<TabibuTextField>(
          questionField(l10n.reportQuestionSpecimenDescription),
        );
        final size = tester.widget<TabibuTextField>(
          questionField(l10n.reportQuestionSpecimenSize),
        );
        final microscopic = tester.widget<TabibuTextField>(
          questionField(l10n.reportQuestionMicroscopicDescription),
        );
        expect(specimen.required, isTrue);
        expect(size.required, isFalse);
        expect(microscopic.required, isTrue);
        expect(find.text(l10n.reportSectionMacroscopic), findsWidgets);
        expect(find.text(l10n.reportSectionMicroscopic), findsWidgets);
      });

      Finder answerField(String label) => find.descendant(
        of: questionField(label),
        matching: find.byType(TextField),
      );

      TabibuButton signButton(WidgetTester tester) =>
          tester.widget<TabibuButton>(
            find.widgetWithText(TabibuButton, l10n.workspaceSignReport),
          );

      testWidgets('Sign stays closed, with its reason, until they are typed', (
        tester,
      ) async {
        await pumpScreen(tester, loaded(draft()));

        expect(find.text(l10n.workspaceRequiredBeforeSign), findsOneWidget);
        expect(signButton(tester).onTap, isNull);

        await tester.enterText(
          answerField(l10n.reportQuestionSpecimenDescription),
          'One lymph node, 6 mm.',
        );
        await tester.pump();
        // One of the two required ones is still empty.
        expect(signButton(tester).onTap, isNull);
      });

      testWidgets('Sign opens as soon as the required ones are typed, and '
          'saves them first', (tester) async {
        await pumpScreen(tester, loaded(draft()));

        await tester.enterText(
          answerField(l10n.reportQuestionSpecimenDescription),
          'One lymph node, 6 mm.',
        );
        await tester.enterText(
          answerField(l10n.reportQuestionMicroscopicDescription),
          'A focus of carcinoma cells.',
        );
        await tester.pump();

        expect(find.text(l10n.workspaceRequiredBeforeSign), findsNothing);
        expect(signButton(tester).onTap, isNotNull);

        await tester.tap(find.text(l10n.workspaceSignReport));
        await tester.pump();

        final sent = verify(
          () => blocs.caseWorkspace.add(captureAny()),
        ).captured.whereType<CaseDraftEdited>().single;
        expect((sent.fields['responses'] as List<dynamic>).length, 2);
      });

      testWidgets('a tap outside the fields drops the keyboard', (
        tester,
      ) async {
        await pumpScreen(tester, loaded(draft()));

        final field = answerField(l10n.reportQuestionSpecimenSize);
        await tester.tap(field);
        await tester.pump();
        expect(tester.widget<TextField>(field).focusNode?.hasFocus, isTrue);

        await tester.tap(find.text(l10n.reportSectionMicroscopic).first);
        await tester.pump();
        expect(tester.widget<TextField>(field).focusNode?.hasFocus, isFalse);
      });

      testWidgets('saved answers fill the fields and open Sign', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          loaded(
            draft(
              responses: const [
                ReportResponseModel(
                  section: 'Macroscopic',
                  question: 'specimenDescription',
                  answer: 'One lymph node, 6 mm.',
                  order: 1,
                ),
                ReportResponseModel(
                  section: 'Microscopic',
                  question: 'microscopicDescription',
                  answer: 'A focus of carcinoma cells.',
                  order: 1,
                ),
              ],
            ),
          ),
        );

        expect(find.text('One lymph node, 6 mm.'), findsOneWidget);
        expect(find.text(l10n.workspaceRequiredBeforeSign), findsNothing);
        final sign = tester.widget<TabibuButton>(
          find.widgetWithText(TabibuButton, l10n.workspaceSignReport),
        );
        expect(sign.onTap, isNotNull);
      });

      testWidgets('Save draft sends the answers under their keys', (
        tester,
      ) async {
        await pumpScreen(tester, loaded(draft()));

        await tester.enterText(
          find.descendant(
            of: questionField(l10n.reportQuestionSpecimenDescription),
            matching: find.byType(TextField),
          ),
          '  One lymph node, 6 mm.  ',
        );
        await tester.enterText(
          find.descendant(
            of: questionField(l10n.reportQuestionMicroscopicDescription),
            matching: find.byType(TextField),
          ),
          'A focus of carcinoma cells.',
        );
        await tester.tap(find.text(l10n.workspaceSaveDraft));
        await tester.pump();

        final sent = verify(
          () => blocs.caseWorkspace.add(captureAny()),
        ).captured.whereType<CaseDraftEdited>().single;
        final responses = sent.fields['responses'] as List<dynamic>;
        expect(responses, [
          {
            'section': 'Macroscopic',
            'question': 'specimenDescription',
            'answer': 'One lymph node, 6 mm.',
            'order': 1,
          },
          {
            'section': 'Microscopic',
            'question': 'microscopicDescription',
            'answer': 'A focus of carcinoma cells.',
            'order': 1,
          },
        ]);
      });
    });

    group('rules', () {
      testWidgets('rule 1: every AI value of the pre-read sits in the AI draft '
          'frame, and the ready chip is the AI mark', (tester) async {
        await pumpScreen(tester, _chooser());

        final frame = find.byType(AiDraftFrame);
        expect(frame, findsOneWidget);
        expect(
          tester.widget<AiDraftFrame>(frame).label,
          l10n.workspaceAiPreread,
        );
        for (final value in [
          _aiImpression,
          _aiFinding,
          _aiNextStep,
          l10n.deskBandRow(l10n.deskBandHigh, '87%'),
          l10n.urgencyPriority,
          'density · 2.5',
        ]) {
          expect(inFrame(find.text(value)), findsOneWidget, reason: value);
        }

        final mark = find.byType(AiMark);
        expect(mark, findsOneWidget);
        expect(tester.widget<AiMark>(mark).label, l10n.deskAiDraftReady);
        expect(inFrame(mark), findsNothing);
      });

      testWidgets('rule 1: the AI draft in the fields is framed too', (
        tester,
      ) async {
        await pumpScreen(tester, _adopted());

        expect(aiDraftFrames(), findsNWidgets(2));
        for (final label in [
          l10n.reportSectionDiagnosis,
          l10n.reportSectionComments,
        ]) {
          expect(
            find.descendant(
              of: aiDraftFrames(),
              matching: find.byWidgetPredicate(
                (w) => w is TabibuTextField && w.label == label,
              ),
            ),
            findsOneWidget,
            reason: label,
          );
        }
      });

      testWidgets('rule 1: nothing AI-derived uses the signed colour, in '
          'light and dark', (tester) async {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await pumpScreen(tester, _adopted(), themeMode: mode);

          expectNoSignedColour(
            tester,
            find.byWidgetPredicate((w) => w is AiDraftFrame || w is AiMark),
          );
          final status = Theme.of(
            tester.element(find.byType(CaseWorkspaceScreen)),
          ).extension<AppStatusColors>()!;
          expect(
            colours(tester, find.byType(AiMark)),
            contains(status.aiDraftContainer),
          );
          expect(
            colours(tester, find.byType(AiDraftFrame)),
            contains(status.draftBorder),
          );
        }
      });

      testWidgets('rule 2: with a ready pre-read not yet scored, the report '
          'is locked and the score card leads', (tester) async {
        await pumpScreen(
          tester,
          _locked(diagnosis: _ownDiagnosis, fromPreread: true),
        );

        expect(find.byType(WorkspaceScoreCard), findsOneWidget);
        expect(find.text(l10n.scoreLockLine), findsOneWidget);
        expect(find.text(l10n.workspaceStartFromAiDraft), findsNothing);
        expect(enabled(tester, l10n.workspaceSignReport), isFalse);
        expect(enabled(tester, l10n.workspaceSaveDraft), isFalse);
        expect(field(tester, l10n.reportSectionDiagnosis).readOnly, isTrue);
        expect(field(tester, l10n.reportSectionComments).readOnly, isTrue);
        expect(
          tester
              .widget<CheckRow>(
                find.widgetWithText(CheckRow, l10n.workspaceCriticalFinding),
              )
              .onChanged,
          isNull,
        );
        expect(
          find
              .widgetWithText(
                TabibuFilterChip,
                l10n.reportPdfDiagnosisTypeFinal,
              )
              .evaluate()
              .map((e) => (e.widget as TabibuFilterChip).onTap),
          everyElement(isNull),
        );
        verifyNever(() => blocs.caseWorkspace.add(any()));
      });

      testWidgets('rule 2: scoring unlocks the report', (tester) async {
        await pumpScreen(
          tester,
          _locked(diagnosis: _ownDiagnosis, fromPreread: true),
        );

        await emit(
          tester,
          _loaded(
            draft: _draft(diagnosis: _ownDiagnosis, fromPreread: true),
            preread: _preread(),
            score: _score,
          ),
        );

        expect(find.byType(WorkspaceScoreCard), findsNothing);
        expect(find.text(l10n.scoreLockLine), findsNothing);
        expect(enabled(tester, l10n.workspaceSignReport), isTrue);
        expect(enabled(tester, l10n.workspaceSaveDraft), isTrue);
        expect(field(tester, l10n.reportSectionDiagnosis).readOnly, isFalse);
      });

      testWidgets('rule 2: a pre-read that is not ready never locks the '
          'report', (tester) async {
        await pumpScreen(
          tester,
          _loaded(
            draft: _draft(diagnosis: _ownDiagnosis),
            preread: _preread(status: 'Failed'),
          ),
        );

        expect(find.byType(WorkspaceScoreCard), findsNothing);
        expect(find.text(l10n.scoreLockLine), findsNothing);
        expect(find.byType(AiDraftFrame), findsNothing);
        expect(find.byType(AiMark), findsNothing);
        expect(enabled(tester, l10n.workspaceSignReport), isTrue);
      });

      testWidgets('rule 2: nothing is preselected on the score card', (
        tester,
      ) async {
        await pumpScreen(tester, _locked());

        expect(scoreChips(), findsNWidgets(16));
        expect(
          scoreChips().evaluate().map(
            (e) => (e.widget as TabibuFilterChip).selected,
          ),
          everyElement(isFalse),
        );
        expect(
          tester.widget<OverallScore>(find.byType(OverallScore)).value,
          isNull,
        );
        expect(enabled(tester, l10n.scoreSave), isFalse);
      });

      testWidgets('rule 2: Save score stays disabled until every verdict and '
          'the overall score are chosen, then sends exactly those', (
        tester,
      ) async {
        await pumpScreen(tester, _locked());

        await tester.tap(scoreOption(l10n.scoreAgree));
        await tester.tap(scoreOption(l10n.scorePartlyAgree, at: 1));
        await tester.tap(scoreOption(l10n.scoreDisagree, at: 2));
        await tester.tap(scoreOption(l10n.scoreCorrected));
        await tester.tap(scoreOption(l10n.scorePoor));
        await tester.pump();
        expect(enabled(tester, l10n.scoreSave), isFalse);
        expect(
          tester.widget<OverallScore>(find.byType(OverallScore)).value,
          isNull,
        );

        await tester.tap(
          find.descendant(
            of: find.byType(OverallScore),
            matching: find.text('4'),
          ),
        );
        await tester.pump();
        expect(enabled(tester, l10n.scoreSave), isTrue);
        expect(
          scoreChips()
              .evaluate()
              .where((e) => (e.widget as TabibuFilterChip).selected)
              .length,
          5,
        );

        await tester.tap(find.text(l10n.scoreSave));
        await tester.pump();

        expect(verify(() => blocs.caseWorkspace.add(captureAny())).captured, [
          const CasePrereadScored(
            overall: 4,
            findingsVerdict: 'Agree',
            impressionVerdict: 'PartlyAgree',
            urgencyVerdict: 'Disagree',
            measurementsVerdict: 'Corrected',
            segmentationVerdict: 'Poor',
          ),
        ]);
      });

      testWidgets('rule 3: nothing is adopted or sent until a button is '
          'tapped', (tester) async {
        await pumpScreen(tester, _chooser());

        expect(find.text(l10n.workspaceStartFromAiDraft), findsOneWidget);
        expect(find.text(l10n.workspaceWriteOwn), findsOneWidget);
        // The fields stay in view under the buttons, empty: nothing of the AI
        // draft is put in them until its own button is tapped.
        expect(
          field(tester, l10n.reportSectionDiagnosis).controller?.text,
          isEmpty,
        );
        expect(
          field(tester, l10n.reportSectionComments).controller?.text,
          isEmpty,
        );
        expect(aiDraftFrames(), findsNothing);
        verifyNever(() => blocs.caseWorkspace.add(any()));
      });

      testWidgets('rule 3: Write my own sends nothing and opens empty '
          'fields', (tester) async {
        await pumpScreen(tester, _chooser());

        await tester.tap(find.text(l10n.workspaceWriteOwn));
        await tester.pump();

        verifyNever(() => blocs.caseWorkspace.add(any()));
        expect(find.text(l10n.workspaceStartFromAiDraft), findsNothing);
        expect(
          field(tester, l10n.reportSectionDiagnosis).controller?.text,
          isEmpty,
        );
        expect(
          field(tester, l10n.reportSectionComments).controller?.text,
          isEmpty,
        );
        expect(aiDraftFrames(), findsNothing);
        expect(find.text(l10n.workspaceYourEdit), findsNothing);
      });

      testWidgets('rule 3: only the explicit button adopts the AI draft', (
        tester,
      ) async {
        await pumpScreen(tester, _chooser());

        await tester.tap(find.text(l10n.workspaceStartFromAiDraft));
        await tester.pump();

        expect(verify(() => blocs.caseWorkspace.add(captureAny())).captured, [
          const CaseDraftStartedFromPreread(),
        ]);
      });

      testWidgets('rule 4: text equal to the AI draft is framed as an AI '
          'draft, not as the pathologist own text', (tester) async {
        await pumpScreen(tester, _adopted());

        expect(aiDraftFrames(), findsNWidgets(2));
        expect(find.text(l10n.workspaceYourEdit), findsNothing);
      });

      testWidgets('rule 4: edited text shows Your edit and leaves the AI '
          'frame', (tester) async {
        await pumpScreen(tester, _adopted(comments: _ownComments));

        expect(aiDraftFrames(), findsOneWidget);
        expect(
          find.descendant(
            of: aiDraftFrames(),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is TabibuTextField &&
                  w.label == l10n.reportSectionDiagnosis,
            ),
          ),
          findsOneWidget,
        );
        expect(find.text(l10n.workspaceYourEdit), findsOneWidget);

        await pumpScreen(
          tester,
          _adopted(diagnosis: _ownDiagnosis, comments: _ownComments),
        );

        expect(aiDraftFrames(), findsNothing);
        expect(find.text(l10n.workspaceYourEdit), findsNWidgets(2));
      });

      testWidgets('rule 4: the frame gives way to Your edit on the first '
          'change the bloc reports', (tester) async {
        await pumpScreen(tester, _adopted());
        expect(aiDraftFrames(), findsNWidgets(2));

        await emit(tester, _adopted(diagnosis: '$_aiImpression Edited.'));

        expect(aiDraftFrames(), findsOneWidget);
        expect(find.text(l10n.workspaceYourEdit), findsOneWidget);
      });

      testWidgets('rule 4: the frame gives way to Your edit on the first '
          'keystroke', (tester) async {
        await pumpScreen(tester, _adopted());
        expect(aiDraftFrames(), findsNWidgets(2));

        await tester.enterText(
          find.descendant(
            of: aiDraftFrames().first,
            matching: find.byType(EditableText),
          ),
          '$_aiImpression!',
        );
        await tester.pump();

        expect(aiDraftFrames(), findsOneWidget);
        expect(find.text(l10n.workspaceYourEdit), findsOneWidget);
      });

      testWidgets('rule 4: a report not started from the AI draft is never '
          'labelled either way', (tester) async {
        await pumpScreen(
          tester,
          _loaded(
            draft: _draft(diagnosis: _aiImpression, comments: _ownComments),
            preread: _preread(),
            score: _score,
          ),
        );

        expect(aiDraftFrames(), findsNothing);
        expect(find.text(l10n.workspaceYourEdit), findsNothing);
      });

      testWidgets('rule 5: notifiable boxes start unticked and only the '
          'confirmable disease is offered', (tester) async {
        await pumpScreen(tester, _signable());

        final row = find.widgetWithText(
          CheckRow,
          l10n.workspacePositiveFor('Malaria'),
        );
        expect(row, findsOneWidget);
        expect(tester.widget<CheckRow>(row).value, isFalse);
        expect(find.text(l10n.workspaceNotifiableExplainer), findsOneWidget);
        expect(
          find.textContaining(l10n.workspacePositiveFor('Dengue')),
          findsNothing,
        );
        expect(
          find.textContaining(l10n.workspacePositiveFor('Unlisted fever')),
          findsNothing,
        );
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is CheckRow &&
                w.label.startsWith(l10n.workspacePositiveFor('')),
          ),
          findsOneWidget,
        );
        verifyNever(() => blocs.caseWorkspace.add(any()));
      });

      testWidgets('rule 5: a case with no confirming test offers nothing to '
          'tick', (tester) async {
        await pumpScreen(
          tester,
          _loaded(
            draft: _draft(diagnosis: _ownDiagnosis, run: ''),
            caseModel: _case(testId: _histology),
          ),
        );

        expect(find.text(l10n.workspaceNotifiableExplainer), findsNothing);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is CheckRow &&
                w.label.startsWith(l10n.workspacePositiveFor('')),
          ),
          findsNothing,
        );
        expect(
          find.widgetWithText(CheckRow, l10n.workspaceCriticalFinding),
          findsOneWidget,
        );
      });

      testWidgets('rule 5: ticking sends the disease with alertRequested '
          'false', (tester) async {
        await pumpScreen(tester, _signable());

        await tester.tap(find.text(l10n.workspacePositiveFor('Malaria')));
        await tester.pump();

        final captured = verify(
          () => blocs.caseWorkspace.add(captureAny()),
        ).captured;
        expect(captured, [
          const CaseDraftEdited(
            fields: {
              'notifiableFindings': [
                {'diseaseId': 'malaria', 'alertRequested': false},
              ],
            },
          ),
        ]);
      });

      testWidgets('rule 5: a ticked disease reads ticked from the draft, and '
          'unticking removes it', (tester) async {
        await pumpScreen(
          tester,
          _signable(
            findings: [const NotifiableFindingModel(diseaseId: 'malaria')],
          ),
        );

        final row = find.widgetWithText(
          CheckRow,
          l10n.workspacePositiveFor('Malaria'),
        );
        expect(tester.widget<CheckRow>(row).value, isTrue);

        await tester.tap(find.text(l10n.workspacePositiveFor('Malaria')));
        await tester.pump();

        expect(verify(() => blocs.caseWorkspace.add(captureAny())).captured, [
          const CaseDraftEdited(fields: {'notifiableFindings': <Object>[]}),
        ]);
      });

      testWidgets('rule 6: the attestation starts unticked on every open', (
        tester,
      ) async {
        await pumpScreen(tester, _signable());

        await openSignSheet(tester);
        expect(find.text(l10n.signSheetTitle), findsOneWidget);
        expect(attested(tester), isFalse);

        await tickAttestation(tester);
        expect(attested(tester), isTrue);

        await tester.tap(find.text(l10n.commonCancel));
        await settleSheet(tester);
        expect(find.text(l10n.signSheetTitle), findsNothing);

        await openSignSheet(tester);
        expect(find.text(l10n.signSheetTitle), findsOneWidget);
        expect(attested(tester), isFalse);
        verifyNever(() => blocs.caseWorkspace.add(any()));
      });

      testWidgets('rule 6: Sign needs the tick and a stroke, and neither '
          'alone is enough', (tester) async {
        await pumpScreen(tester, _signable());
        await openSignSheet(tester);

        expect(enabled(tester, l10n.signSheetSignAndSend), isFalse);

        await tickAttestation(tester);
        expect(enabled(tester, l10n.signSheetSignAndSend), isFalse);

        await tickAttestation(tester);
        expect(attested(tester), isFalse);
        await drawStroke(tester);
        expect(enabled(tester, l10n.signSheetSignAndSend), isFalse);

        await tickAttestation(tester);
        expect(enabled(tester, l10n.signSheetSignAndSend), isTrue);

        await tickAttestation(tester);
        expect(enabled(tester, l10n.signSheetSignAndSend), isFalse);
        verifyNever(() => blocs.caseWorkspace.add(any()));
      });

      testWidgets('rule 6: Sign is disabled while offline, even with the '
          'tick and a stroke', (tester) async {
        await pumpScreen(tester, _signable());
        await openSignSheet(tester);
        await tickAttestation(tester);
        await drawStroke(tester);
        expect(enabled(tester, l10n.signSheetSignAndSend), isTrue);

        await emit(tester, _signable(offline: true));

        expect(find.text(l10n.signSheetOfflineTitle), findsOneWidget);
        expect(find.text(l10n.signSheetSignAndSend), findsNothing);
        expect(enabled(tester, l10n.signSheetSignWhenOnline), isFalse);

        await emit(tester, _signable());
        expect(enabled(tester, l10n.signSheetSignAndSend), isTrue);
      });

      testWidgets('rule 6: signing sends the attested signature once', (
        tester,
      ) async {
        await pumpScreen(tester, _signable());
        await openSignSheet(tester);
        await tickAttestation(tester);
        await drawStroke(tester);

        await tester.tap(find.text(l10n.signSheetSignAndSend));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump();

        final sent = verify(
          () => blocs.caseWorkspace.add(captureAny()),
        ).captured.whereType<CaseSignRequested>().single;
        expect(sent.attested, isTrue);
        expect(
          utf8.decode(base64Decode(sent.signaturePng).sublist(1, 4)),
          'PNG',
        );
      });

      testWidgets('rule 7: a failed sign keeps the sheet and the draft, '
          'shows the error and never shows signed', (tester) async {
        final start = _signable();
        await pumpScreen(tester, start);
        await openSignSheet(tester);
        await tickAttestation(tester);
        await drawStroke(tester);
        await tester.tap(find.text(l10n.signSheetSignAndSend));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 300)),
        );
        await tester.pump();

        await emit(tester, _failed(start));
        await tester.pump(const Duration(milliseconds: 400));

        final message = AppError.unknown.description(l10n);
        expect(find.text(l10n.signSheetTitle), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is NoticeCard &&
                w.variant == NoticeVariant.error &&
                w.body == message,
          ),
          findsOneWidget,
        );
        expect(find.byType(SignedCaseView), findsNothing);
        expect(find.text(l10n.signedCaseSignedByYou), findsNothing);
        expect(find.text(_ownDiagnosis), findsOneWidget);
        expect(find.text(_ownComments), findsOneWidget);
        expect(attested(tester), isTrue);
        expect(find.text(l10n.signSheetClear), findsOneWidget);
        expect(enabled(tester, l10n.signSheetSignAndSend), isTrue);

        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('rule 7: only a successful sign closes the sheet and shows '
          'the signed report', (tester) async {
        final start = _signable();
        await pumpScreen(tester, start);
        await openSignSheet(tester);

        await emit(
          tester,
          CaseSignSuccess(
            caseUid: _caseUid,
            caseModel: start.caseModel,
            draft: start.draft,
            signed: _signedReport,
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text(l10n.signSheetTitle), findsNothing);
        expect(find.byType(SignedCaseView), findsOneWidget);
        expect(find.text(l10n.signedCaseSignedByYou), findsOneWidget);
      });

      test('rule 8: every workspace string has a Swahili one that is not '
          'the English', () {
        Map<String, dynamic> read(String name) =>
            jsonDecode(File('lib/l10n/arb/$name.arb').readAsStringSync())
                as Map<String, dynamic>;
        final en = read('app_en');
        final sw = read('app_sw');
        final keys = [
          for (final key in en.keys)
            if (!key.startsWith('@') &&
                RegExp(
                  '^(workspace|score|signSheet|signedCase)[A-Z]',
                ).hasMatch(key))
              key,
        ];

        expect(keys, isNotEmpty);
        for (final key in keys) {
          expect(sw[key], isA<String>(), reason: 'sw is missing $key');
          expect(sw[key], isNot(en[key]), reason: 'sw repeats English: $key');
        }
      });

      test('rule 8: the workspace code holds no string literal of its own', () {
        final literal = RegExp(
          r'''(Text\(|label:|title:|body:|hint:|message:|semanticLabel:)\s*'[A-Za-z]''',
        );
        for (final path in [
          'lib/features/reports/presentation/case_workspace_screen.dart',
          'lib/features/reports/presentation/widgets/workspace_score_card.dart',
          'lib/features/reports/presentation/widgets/workspace_sign_sheet.dart',
          'lib/features/reports/presentation/widgets/signed_case_view.dart',
          'lib/features/reports/presentation/widgets/verdict_selector.dart',
        ]) {
          expect(
            literal.hasMatch(File(path).readAsStringSync()),
            isFalse,
            reason: '$path draws an English literal',
          );
        }
      });

      testWidgets('rule 8: Swahili replaces the English on the workspace', (
        tester,
      ) async {
        await pumpScreen(tester, _locked(), locale: const Locale('sw'));

        for (final (en, sw) in [
          (l10n.scoreTitle, swL10n.scoreTitle),
          (l10n.scoreLockLine, swL10n.scoreLockLine),
          (l10n.scoreSave, swL10n.scoreSave),
          (l10n.workspaceSaveDraft, swL10n.workspaceSaveDraft),
          (l10n.workspaceSignReport, swL10n.workspaceSignReport),
          (l10n.workspaceAiPreread, swL10n.workspaceAiPreread),
        ]) {
          expect(find.text(en), findsNothing, reason: en);
          expect(find.text(sw), findsOneWidget, reason: sw);
        }
      });

      testWidgets('rule 8: dark mode draws the locked workspace and the '
          'sign sheet', (tester) async {
        await pumpScreen(tester, _locked(), themeMode: .dark);

        expect(
          Theme.of(tester.element(find.byType(CaseWorkspaceScreen))).brightness,
          Brightness.dark,
        );
        expect(find.byType(AiDraftFrame), findsOneWidget);
        expect(find.byType(WorkspaceScoreCard), findsOneWidget);
        expect(tester.takeException(), isNull);

        await pumpScreen(tester, _signable(), themeMode: .dark);
        await openSignSheet(tester);

        expect(find.text(l10n.signSheetTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('rule 8: Swahili at 1.3x text on a 390 dp screen does not '
          'overflow', (tester) async {
        // The default surface is already 390 dp wide.
        await pumpScreen(
          tester,
          _locked(),
          locale: const Locale('sw'),
          textScale: 1.3,
        );
        expect(tester.takeException(), isNull);
        expect(find.text(swL10n.scoreTitle), findsOneWidget);

        await pumpScreen(
          tester,
          _signable(
            findings: [const NotifiableFindingModel(diseaseId: 'malaria')],
          ),
          locale: const Locale('sw'),
          textScale: 1.3,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(swL10n.workspaceSignReport));
        await settleSheet(tester);

        expect(find.text(swL10n.signSheetTitle), findsOneWidget);
        expect(
          find.text(swL10n.signSheetNotifiableNotice('Malaria')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('rule 8: a tablet width draws the workspace and the sign '
          'sheet', (tester) async {
        const tablet = Size(820 * 3, 12000);
        await pumpScreen(tester, _locked(), surface: tablet);
        expect(find.byType(WorkspaceScoreCard), findsOneWidget);
        expect(tester.takeException(), isNull);

        await pumpScreen(tester, _signable(), surface: tablet);
        await openSignSheet(tester);

        expect(find.text(l10n.signSheetTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('data', () {
      testWidgets('opens the case as the pathologist when the bloc holds '
          'another', (tester) async {
        await pumpScreen(tester, const CaseWorkspaceInitial());

        expect(verify(() => blocs.caseWorkspace.add(captureAny())).captured, [
          CaseWorkspaceOpened(
            caseUid: _caseUid,
            pathologistUid: RoleSessions.pathologist.doctor.uid,
          ),
        ]);
      });

      testWidgets('does not reopen a case the bloc already holds', (
        tester,
      ) async {
        await pumpScreen(tester, _signable());

        verifyNever(() => blocs.caseWorkspace.add(any()));
      });

      testWidgets('the top bar names the order, the test and the patient', (
        tester,
      ) async {
        await pumpScreen(tester, _signable());

        expect(find.text('TB-0231'), findsOneWidget);
        expect(find.text('Malaria smear · Amina W., 46'), findsOneWidget);
      });

      testWidgets('reads the register once and offers its confirmable '
          'diseases', (tester) async {
        await pumpScreen(tester, _signable());

        verify(reference.notifiableDiseases).called(1);
      });

      testWidgets('asks storage for the slide, and draws no viewer when it '
          'has none', (tester) async {
        await pumpScreen(tester, _chooser());

        verify(() => storage.downloadUrl('slides/smear.png')).called(1);
        expect(find.byType(AiDraftFrame), findsOneWidget);
      });

      testWidgets('Save draft sends only what changed', (tester) async {
        await pumpScreen(tester, _signable());

        await tester.enterText(
          find.descendant(
            of: find.byWidgetPredicate(
              (w) =>
                  w is TabibuTextField && w.label == l10n.reportSectionComments,
            ),
            matching: find.byType(EditableText),
          ),
          'A new comment.',
        );
        await tester.tap(find.text(l10n.workspaceSaveDraft));
        await tester.pump();

        expect(verify(() => blocs.caseWorkspace.add(captureAny())).captured, [
          const CaseDraftEdited(fields: {'comments': 'A new comment.'}),
        ]);
      });

      testWidgets('a write failure shows the error notification', (
        tester,
      ) async {
        final start = _signable();
        await pumpScreen(tester, start);

        await emit(tester, _failed(start));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text(AppError.unknown.description(l10n)), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('the list ends in the history row', (tester) async {
        await pumpScreen(tester, _loaded());

        expect(find.text(l10n.accessLogTitle), findsOneWidget);
      });
    });
  });
}
