// cspell:ignore Ongezeko kila mwenye homa chandarua kilichotibiwa
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/reference_data_helper.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_bloc.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_state.dart';
import 'package:tabibu/features/alerts/data/datasources/alert_firebase.dart';
import 'package:tabibu/features/alerts/data/models/alert_evidence_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_disease_model.dart';
import 'package:tabibu/features/alerts/data/models/notifiable_lab_test_model.dart';
import 'package:tabibu/features/alerts/presentation/alert_review_screen.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

class _MockAlerts extends Mock implements AlertFirebase {}

class _MockInternet extends Mock implements InternetService {}

class _MockReferenceData extends Mock implements ReferenceDataHelper {}

const _texts = {
  'clinician_en': AlertTextModel(
    headline: 'Malaria rise in {county}',
    body: 'Test every febrile patient.',
  ),
  'patient_en': AlertTextModel(
    headline: 'More malaria than usual',
    body: 'Sleep under a treated net.',
  ),
  'clinician_sw': AlertTextModel(
    headline: 'Ongezeko la malaria',
    body: 'Pima kila mgonjwa mwenye homa.',
  ),
  'patient_sw': AlertTextModel(
    headline: 'Malaria zaidi ya kawaida',
    body: 'Lala chini ya chandarua.',
  ),
};

AlertModel _alert({
  String uid = 'a1',
  int draft = 3,
  int evidence = 7,
  String status = 'Draft',
  bool synthetic = false,
  Map<String, AlertTextModel> machineText = _texts,
}) => AlertModel(
  uid: uid,
  diseaseId: 'malaria',
  countyName: 'Embakasi',
  status: status,
  draftRevision: draft,
  evidenceRevision: evidence,
  synthetic: synthetic,
  machineText: machineText,
  evidence: const AlertEvidenceModel(
    confirmedCount: 14,
    baselineMean: 4.6,
    windowWeeks: 8,
  ),
);

const _register = [
  NotifiableDiseaseModel(
    diseaseId: 'malaria',
    nameEn: 'Malaria',
    nameSw: 'Malaria',
    labTests: [
      NotifiableLabTestModel(name: 'malaria smears', strength: 'Confirms'),
    ],
  ),
];

PractitionerSession _approver({bool approves = true}) {
  final base = RoleSessions.doctor(isAlertApprover: approves);
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: 'doctor-1'),
    roles: base.roles,
  );
}

void main() {
  late MockAuthBloc authBloc;
  late MockAlertReviewBloc mockBloc;
  late _MockAlerts alerts;
  late _MockInternet internet;
  late _MockReferenceData referenceData;
  final l10n = lookupAppLocalizations(const Locale('en'));

  setUpAll(() {
    registerFallbackValue(const AlertReviewReset());
  });

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(SignInSuccess(session: _approver()));
    mockBloc = MockAlertReviewBloc();
    when(() => mockBloc.add(any())).thenReturn(null);
    alerts = _MockAlerts();
    internet = _MockInternet();
    when(() => internet.check()).thenAnswer((_) async => true);
    referenceData = _MockReferenceData();
    when(
      () => referenceData.notifiableDiseases(),
    ).thenAnswer((_) async => _register);
    getIt.registerSingleton<ReferenceDataHelper>(referenceData);
  });

  tearDown(getIt.reset);

  GoRouter router(AlertReviewBloc bloc) {
    // Same paths as AlertReviewRoute / AlertSentRoute / DoctorHomeRoute so
    // pushReplacement and go replace the matched page, not stack on `/review`.
    final routes = GoRouter(
      initialLocation: '/doctor/alert/a1',
      routes: [
        GoRoute(
          path: '/doctor/alert/:alertUid',
          builder: (_, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<AlertReviewBloc>.value(value: bloc),
            ],
            child: AlertReviewScreen(
              alertUid: state.pathParameters['alertUid']!,
            ),
          ),
        ),
        GoRoute(path: '/doctor', builder: (_, _) => const Text('stub home')),
        GoRoute(
          path: '/doctor/alert/:alertUid/sent',
          builder: (_, state) =>
              Text('stub sent ${state.pathParameters['alertUid']}'),
        ),
      ],
    );
    addTearDown(routes.dispose);
    return routes;
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    AlertReviewBloc? bloc,
    ThemeMode themeMode = ThemeMode.light,
    Locale? locale,
    Size? surface,
  }) async {
    tester.view.physicalSize = surface ?? const Size(1170, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // Clear a prior releaseRouter / failed expect so the new router mounts.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpRouterApp(
      router(bloc ?? mockBloc),
      themeMode: themeMode,
      locale: locale,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  void mockState(AlertReviewState state) =>
      when(() => mockBloc.state).thenReturn(state);

  Future<void> settleSheet(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  // The error notification keeps a four-second timer.
  Future<void> drainNotification(WidgetTester tester) =>
      tester.pump(const Duration(seconds: 5));

  /// Approval / reject success navigates away; tearDown hangs if the
  /// transition is still open when the test ends.
  Future<void> settleDecision(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Detach before tearDown's `GoRouter.dispose` — `pushReplacement` leaves
  /// a transition that otherwise never finishes under the test binding.
  Future<void> releaseRouter(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  void stubApprove({Future<Map<String, dynamic>> Function()? answer}) => when(
    () => alerts.approveAlert(
      alertUid: any(named: 'alertUid'),
      decision: any(named: 'decision'),
      draftRevision: any(named: 'draftRevision'),
      evidenceRevision: any(named: 'evidenceRevision'),
      audience: any(named: 'audience'),
      editedText: any(named: 'editedText'),
      reason: any(named: 'reason'),
    ),
  ).thenAnswer((_) => (answer ?? () async => {'status': 'ok'})());

  VerificationResult verifyApprove({
    required String decision,
    int draft = 3,
    int evidence = 7,
    String? reason,
  }) => verify(
    () => alerts.approveAlert(
      alertUid: any(named: 'alertUid'),
      decision: decision,
      draftRevision: draft,
      evidenceRevision: evidence,
      audience: any(named: 'audience'),
      editedText: any(named: 'editedText'),
      reason: reason ?? any(named: 'reason'),
    ),
  );

  // Never closed: awaiting a bloc's close inside a widget test's fake clock
  // does not return. The bloc holds no timer, so nothing is left running.
  AlertReviewBloc realBloc() =>
      AlertReviewBloc(alerts: alerts, internet: internet);

  String allText(WidgetTester tester) => [
    for (final t in tester.widgetList<Text>(find.byType(Text)))
      t.data ?? t.textSpan?.toPlainText() ?? '',
  ].join('\n');

  Finder approveButton() =>
      find.widgetWithText(TabibuButton, l10n.alertReviewApproveAsIs);

  /// The pinned primary button; its label becomes a spinner while loading.
  Finder approveSlot() => find.byType(TabibuButton).last;

  group('AlertReviewScreen', () {
    group('rules', () {
      testWidgets(
        'rule 1: English and Kiswahili drafts each sit in their own AI frame, '
        'verbatim, with the evidence outside the frames',
        (tester) async {
          mockState(AlertReviewLoadSuccess(current: _alert()));
          await pumpScreen(tester);

          final frames = find.byType(AiDraftFrame);
          expect(frames, findsNWidgets(2));
          for (final frame in tester.widgetList<AiDraftFrame>(frames)) {
            expect(frame.label, l10n.alertReviewAiDraftNotSent);
          }
          final english = frames.at(0);
          final swahili = frames.at(1);
          for (final text in [
            l10n.languageEn,
            'Malaria rise in {county}',
            'Test every febrile patient.',
            'More malaria than usual',
            'Sleep under a treated net.',
          ]) {
            expect(
              find.descendant(of: english, matching: find.text(text)),
              findsOneWidget,
              reason: 'English frame: $text',
            );
            expect(
              find.descendant(of: swahili, matching: find.text(text)),
              findsNothing,
              reason: 'Kiswahili frame: $text',
            );
          }
          for (final text in [
            l10n.languageSw,
            'Ongezeko la malaria',
            'Pima kila mgonjwa mwenye homa.',
            'Malaria zaidi ya kawaida',
            'Lala chini ya chandarua.',
          ]) {
            expect(
              find.descendant(of: swahili, matching: find.text(text)),
              findsOneWidget,
              reason: 'Kiswahili frame: $text',
            );
          }

          // Evidence: plain facts, in no frame.
          for (final fact in [
            l10n.alertReviewSignalCases(14, 'malaria smears'),
            l10n.alertReviewSignalBaseline('Embakasi', 5),
          ]) {
            expect(find.text(fact), findsOneWidget);
            expect(
              find.descendant(of: frames, matching: find.text(fact)),
              findsNothing,
            );
          }
          expect(find.text('Embakasi'), findsOneWidget);
        },
      );

      testWidgets(
        'rule 2: Approve as is, Edit and the ••• menu; Reject only in the menu',
        (tester) async {
          mockState(AlertReviewLoadSuccess(current: _alert()));
          await pumpScreen(tester);

          expect(approveButton(), findsOneWidget);
          expect(find.text(l10n.reviewEdit), findsNWidgets(2));
          expect(find.byType(MoreButton), findsOneWidget);
          expect(find.text(l10n.alertReviewReject), findsNothing);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          expect(find.text(l10n.alertReviewReject), findsOneWidget);
          expect(find.text(l10n.alertReviewRejectSub), findsOneWidget);
        },
      );

      testWidgets(
        'rule 2: Approve as is asks the bloc to approve this alert and '
        'nothing else',
        (tester) async {
          mockState(AlertReviewLoadSuccess(current: _alert()));
          await pumpScreen(tester);
          clearInteractions(mockBloc);

          await tester.tap(approveButton());
          await tester.pump();

          verify(
            () => mockBloc.add(const AlertApproveRequested(alertUid: 'a1')),
          ).called(1);
          verifyNoMoreInteractions(mockBloc);
        },
      );

      testWidgets(
        'rule 2: approving sends the revisions the approver saw, never a '
        're-read',
        (tester) async {
          stubApprove();
          var reads = 0;
          when(() => alerts.fetchAlert('a1')).thenAnswer((_) async {
            reads++;
            // The first read is what the approver sees; anything after it
            // has moved on.
            return reads == 1 ? _alert() : _alert(draft: 9, evidence: 9);
          });
          await pumpScreen(tester, bloc: realBloc());

          expect(reads, 1);
          await tester.tap(approveButton());
          await settleDecision(tester);

          verifyApprove(decision: 'Approve').called(1);
          expect(reads, 2);
          // The second fetch moved on; the call still used the revisions
          // the approver had seen (3 / 7), never 9 / 9.
          verifyNever(
            () => alerts.approveAlert(
              alertUid: any(named: 'alertUid'),
              decision: any(named: 'decision'),
              draftRevision: 9,
              evidenceRevision: 9,
              audience: any(named: 'audience'),
              editedText: any(named: 'editedText'),
              reason: any(named: 'reason'),
            ),
          );
          await tester.pump(const Duration(seconds: 1));
          expect(find.text('stub sent a1'), findsOneWidget);
          await releaseRouter(tester);
        },
      );

      testWidgets(
        'rule 3: Edit opens a sheet per language, prefilled, and saving '
        'approves the edited text with every draft key',
        (tester) async {
          mockState(AlertReviewLoadSuccess(current: _alert()));
          await pumpScreen(tester);
          clearInteractions(mockBloc);

          await tester.tap(find.text(l10n.reviewEdit).last);
          await settleSheet(tester);
          // The Kiswahili sheet, prefilled with the Kiswahili drafts only.
          final fields = tester
              .widgetList<TextField>(find.byType(TextField))
              .map((f) => f.controller?.text)
              .toList();
          expect(fields, [
            'Ongezeko la malaria',
            'Pima kila mgonjwa mwenye homa.',
            'Malaria zaidi ya kawaida',
            'Lala chini ya chandarua.',
          ]);

          await tester.enterText(
            find.byType(TextField).at(3),
            'Lala chini ya chandarua kilichotibiwa.',
          );
          await tester.pump();
          await tester.tap(find.text(l10n.explanationSaveAndApprove));
          await settleSheet(tester);

          verify(
            () => mockBloc.add(
              AlertApproveRequested(
                alertUid: 'a1',
                editedText: Map<String, AlertTextModel>.of(_texts)
                  ..['patient_sw'] = const AlertTextModel(
                    headline: 'Malaria zaidi ya kawaida',
                    body: 'Lala chini ya chandarua kilichotibiwa.',
                  ),
              ),
            ),
          ).called(1);
        },
      );

      testWidgets('rule 3: the English sheet carries the English drafts', (
        tester,
      ) async {
        mockState(AlertReviewLoadSuccess(current: _alert()));
        await pumpScreen(tester);

        await tester.tap(find.text(l10n.reviewEdit).first);
        await settleSheet(tester);

        expect(
          tester
              .widgetList<TextField>(find.byType(TextField))
              .map((f) => f.controller?.text),
          [
            'Malaria rise in {county}',
            'Test every febrile patient.',
            'More malaria than usual',
            'Sleep under a treated net.',
          ],
        );
        expect(find.text(l10n.languageEn), findsWidgets);
      });

      testWidgets(
        'rule 3: an unchanged edit is an approval as is (the bloc decides)',
        (tester) async {
          stubApprove();
          when(() => alerts.fetchAlert('a1')).thenAnswer((_) async => _alert());
          await pumpScreen(tester, bloc: realBloc());

          await tester.tap(find.text(l10n.reviewEdit).first);
          await settleSheet(tester);
          await tester.tap(find.text(l10n.explanationSaveAndApprove));
          await settleSheet(tester);
          await settleDecision(tester);

          verifyApprove(decision: 'Approve').called(1);
          verifyNever(
            () => alerts.approveAlert(
              alertUid: any(named: 'alertUid'),
              decision: 'ApproveEdited',
              draftRevision: any(named: 'draftRevision'),
              evidenceRevision: any(named: 'evidenceRevision'),
              audience: any(named: 'audience'),
              editedText: any(named: 'editedText'),
              reason: any(named: 'reason'),
            ),
          );
          expect(find.text('stub sent a1'), findsOneWidget);
          await releaseRouter(tester);
        },
      );

      testWidgets('rule 3: a real edit is sent as ApproveEdited, all four '
          'keys, with the revisions seen', (tester) async {
        stubApprove();
        when(() => alerts.fetchAlert('a1')).thenAnswer((_) async => _alert());
        await pumpScreen(tester, bloc: realBloc());

        await tester.tap(find.text(l10n.reviewEdit).first);
        await settleSheet(tester);
        await tester.enterText(
          find.byType(TextField).at(1),
          'Test all fevers.',
        );
        await tester.pump();
        await tester.tap(find.text(l10n.explanationSaveAndApprove));
        await settleSheet(tester);
        await settleDecision(tester);

        final sent =
            verify(
                  () => alerts.approveAlert(
                    alertUid: any(named: 'alertUid'),
                    decision: 'ApproveEdited',
                    draftRevision: 3,
                    evidenceRevision: 7,
                    audience: any(named: 'audience'),
                    editedText: captureAny(named: 'editedText'),
                    reason: any(named: 'reason'),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(sent.keys, unorderedEquals(_texts.keys));
        expect(sent['clinician_en'], {
          'headline': 'Malaria rise in {county}',
          'body': 'Test all fevers.',
        });
        expect(find.text('stub sent a1'), findsOneWidget);
        await releaseRouter(tester);
      });

      testWidgets(
        'rule 4: Reject is a required choice, then Reject alert; the reason '
        'goes to the bloc',
        (tester) async {
          mockState(AlertReviewLoadSuccess(current: _alert()));
          await pumpScreen(tester);
          clearInteractions(mockBloc);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          await tester.tap(find.text(l10n.alertReviewReject));
          await settleSheet(tester);

          expect(find.text(l10n.alertReviewRejectTitle), findsOneWidget);
          for (final reason in [
            l10n.alertReviewReasonNotEnough,
            l10n.alertReviewReasonOneHousehold,
            l10n.alertReviewReasonWrongArea,
            l10n.alertReviewReasonOther,
          ]) {
            expect(find.text(reason), findsOneWidget);
          }
          // Nothing chosen: tapping Reject alert does nothing.
          await tester.tap(find.text(l10n.alertReviewRejectAlert));
          await settleSheet(tester);
          verifyNever(() => mockBloc.add(any()));
          expect(find.text(l10n.alertReviewRejectTitle), findsOneWidget);

          await tester.tap(find.text(l10n.alertReviewReasonOneHousehold));
          await tester.pump();
          await tester.tap(find.text(l10n.alertReviewRejectAlert));
          await settleSheet(tester);

          verify(
            () => mockBloc.add(
              AlertRejectRequested(
                alertUid: 'a1',
                reason: l10n.alertReviewReasonOneHousehold,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'rule 4: a rejection returns to the doctor home and the alert leaves '
        'the queue',
        (tester) async {
          stubApprove();
          when(
            () => alerts.fetchAwaitingDecision(),
          ).thenAnswer((_) async => [_alert(), _alert(uid: 'a2')]);
          var reads = 0;
          when(() => alerts.fetchAlert('a1')).thenAnswer((_) async {
            reads++;
            return reads == 1 ? _alert() : _alert(status: 'Rejected');
          });
          final bloc = realBloc()..add(const AlertQueueRequested());
          await pumpScreen(tester, bloc: bloc);
          expect(bloc.state.queue.map((a) => a.uid), ['a1', 'a2']);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          await tester.tap(find.text(l10n.alertReviewReject));
          await settleSheet(tester);
          await tester.tap(find.text(l10n.alertReviewReasonWrongArea));
          await tester.pump();
          await tester.tap(find.text(l10n.alertReviewRejectAlert));
          await settleSheet(tester);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          verifyApprove(
            decision: 'Reject',
            reason: l10n.alertReviewReasonWrongArea,
          ).called(1);
          await tester.pump(const Duration(seconds: 1));
          expect(bloc.state, isA<AlertDecisionSuccess>());
          expect(bloc.state.queue.map((a) => a.uid), ['a2']);
          expect(find.text('stub home'), findsOneWidget);
          expect(find.byType(AlertReviewScreen), findsNothing);
          await releaseRouter(tester);
        },
      );

      testWidgets(
        'rule 5: an approval replaces the review with the sent screen',
        (tester) async {
          stubApprove();
          var reads = 0;
          when(() => alerts.fetchAlert('a1')).thenAnswer((_) async {
            reads++;
            return reads == 1 ? _alert() : _alert(status: 'Approved');
          });
          await pumpScreen(tester, bloc: realBloc());

          await tester.tap(approveButton());
          await settleDecision(tester);

          expect(find.text('stub sent a1'), findsOneWidget);
          // pushReplacement updates the location (F-1); go_router may still
          // hold the prior page off the active match.
          expect(
            GoRouter.of(
              tester.element(find.text('stub sent a1')),
            ).state.uri.path,
            '/doctor/alert/a1/sent',
          );
          await releaseRouter(tester);
        },
      );

      testWidgets(
        'rule 6: a stale revision shows the error, reloads the alert and '
        'never sends twice; the next approval carries the new revisions',
        (tester) async {
          var reads = 0;
          when(() => alerts.fetchAlert('a1')).thenAnswer((_) async {
            reads++;
            return reads == 1
                ? _alert()
                : _alert(
                    draft: 4,
                    evidence: 8,
                    machineText: {
                      ..._texts,
                      'patient_en': const AlertTextModel(
                        headline: 'Updated headline',
                        body: 'Updated body.',
                      ),
                    },
                  );
          });
          var approvals = 0;
          stubApprove(
            answer: () async {
              approvals++;
              // The server's refusal of a changed draft reaches the bloc as
              // an AppError.
              if (approvals == 1) throw AppError.unknown;
              return {'status': 'ok'};
            },
          );
          await pumpScreen(tester, bloc: realBloc());
          expect(find.text('More malaria than usual'), findsOneWidget);

          await tester.tap(approveButton());
          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.text(l10n.errorUnknown), findsOneWidget);
          expect(reads, 2);
          expect(find.text('Updated headline'), findsOneWidget);
          expect(find.text('More malaria than usual'), findsNothing);
          verifyApprove(decision: 'Approve').called(1);
          await drainNotification(tester);

          // Approved again only when the approver chooses to, with the
          // revisions of the text now on screen.
          await tester.tap(approveButton());
          await settleDecision(tester);
          verifyApprove(decision: 'Approve', draft: 4, evidence: 8).called(1);
          expect(find.text('stub sent a1'), findsOneWidget);
          await releaseRouter(tester);
        },
      );

      testWidgets('rule 6: an offline failure shows the error without '
          'reloading', (tester) async {
        when(() => internet.check()).thenAnswer((_) async => false);
        when(() => alerts.fetchAlert('a1')).thenAnswer((_) async => _alert());
        await pumpScreen(tester, bloc: realBloc());

        await tester.tap(approveButton());
        await tester.pump();
        await tester.pump();

        expect(find.text(l10n.errorNoInternet), findsOneWidget);
        verify(() => alerts.fetchAlert('a1')).called(1);
        verifyNever(
          () => alerts.approveAlert(
            alertUid: any(named: 'alertUid'),
            decision: any(named: 'decision'),
            draftRevision: any(named: 'draftRevision'),
            evidenceRevision: any(named: 'evidenceRevision'),
            audience: any(named: 'audience'),
            editedText: any(named: 'editedText'),
            reason: any(named: 'reason'),
          ),
        );
        await drainNotification(tester);
      });

      testWidgets('rule 6: a double tap on Approve as is sends one approval', (
        tester,
      ) async {
        final release = Completer<Map<String, dynamic>>();
        addTearDown(() {
          if (!release.isCompleted) {
            release.complete({'status': 'ok'});
          }
        });
        stubApprove(answer: () => release.future);
        when(() => alerts.fetchAlert('a1')).thenAnswer((_) async => _alert());
        await pumpScreen(tester, bloc: realBloc());

        await tester.tap(approveButton());
        await tester.tap(approveButton());
        await tester.pump();
        await tester.pump();
        // Label is a spinner while in flight; tap the same primary slot.
        await tester.tap(approveSlot(), warnIfMissed: false);
        await tester.pump();

        verifyApprove(decision: 'Approve').called(1);
        release.complete({'status': 'ok'});
        await settleDecision(tester);
        expect(find.text('stub sent a1'), findsOneWidget);
        await releaseRouter(tester);
      });

      testWidgets('rule 6: while a decision is in flight every control is '
          'off', (tester) async {
        mockState(AlertDecisionInProgress(current: _alert()));
        await pumpScreen(tester);

        final buttons = tester
            .widgetList<TabibuButton>(find.byType(TabibuButton))
            .toList();
        expect(buttons, hasLength(3));
        for (final button in buttons) {
          expect(button.onTap, isNull);
        }
        expect(
          tester.widget<MoreButton>(find.byType(MoreButton)).onTap,
          isNull,
        );
      });

      testWidgets('rule 7: dark mode draws every part', (tester) async {
        mockState(AlertReviewLoadSuccess(current: _alert(synthetic: true)));
        await pumpScreen(tester, themeMode: ThemeMode.dark);

        expect(find.byType(AiDraftFrame), findsNWidgets(2));
        expect(find.text(l10n.alertReviewDemoBanner), findsOneWidget);
        expect(approveButton(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        testWidgets(
          'rule 7: Kiswahili at 1.3x on a 390 dp screen (${mode.name}) '
          'does not overflow and shows no English',
          (tester) async {
            tester.platformDispatcher.textScaleFactorTestValue = 1.3;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            mockState(AlertReviewLoadSuccess(current: _alert()));
            await pumpScreen(
              tester,
              locale: const Locale('sw'),
              themeMode: mode,
              surface: const Size(390 * 3, 6000),
            );
            final sw = lookupAppLocalizations(const Locale('sw'));

            expect(find.text(sw.alertReviewApproveAsIs), findsOneWidget);
            expect(find.text(sw.alertReviewAiDraftNotSent), findsNWidgets(2));
            expect(find.text(sw.alertReviewTitle), findsOneWidget);
            final text = allText(tester);
            for (final english in [
              l10n.alertReviewApproveAsIs,
              l10n.alertReviewAiDraftNotSent,
              l10n.alertReviewTitle,
              l10n.alertReviewDraftsTitle,
              l10n.alertReviewWhyThisAlert,
              l10n.alertReviewApprovalNotice,
            ]) {
              expect(text, isNot(contains(english)));
            }
            expect(tester.takeException(), isNull);

            // The sheets too.
            await tester.tap(find.byType(MoreButton));
            await settleSheet(tester);
            expect(find.text(sw.alertReviewReject), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    });

    group('access', () {
      testWidgets('without the approver claim it shows nothing and asks for '
          'nothing', (tester) async {
        when(
          () => authBloc.state,
        ).thenReturn(SignInSuccess(session: _approver(approves: false)));
        mockState(AlertReviewLoadSuccess(current: _alert()));
        await pumpScreen(tester);

        expect(find.byType(AiDraftFrame), findsNothing);
        expect(find.byType(TabibuButton), findsNothing);
        expect(find.byType(TopBar), findsNothing);
        expect(allText(tester).trim(), isEmpty);
        verifyNever(() => mockBloc.add(any()));
      });

      testWidgets('a patient session shows nothing either', (tester) async {
        when(
          () => authBloc.state,
        ).thenReturn(SignInSuccess(session: RoleSessions.patient));
        mockState(AlertReviewLoadSuccess(current: _alert()));
        await pumpScreen(tester);

        expect(find.byType(AiDraftFrame), findsNothing);
        verifyNever(() => mockBloc.add(any()));
      });
    });

    group('states', () {
      testWidgets('opens the alert it was given, fresh', (tester) async {
        mockState(const AlertReviewInitial());
        await pumpScreen(tester);

        verify(
          () => mockBloc.add(const AlertReviewOpened(alertUid: 'a1')),
        ).called(1);
        expect(find.byType(LoadingView), findsOneWidget);
        expect(find.byType(AiDraftFrame), findsNothing);
      });

      testWidgets("never shows another alert's draft while this one loads", (
        tester,
      ) async {
        mockState(AlertReviewLoadInProgress(current: _alert(uid: 'other')));
        await pumpScreen(tester);

        expect(find.byType(LoadingView), findsOneWidget);
        expect(find.text('More malaria than usual'), findsNothing);
      });

      testWidgets('a failed load shows the error and Try again reloads', (
        tester,
      ) async {
        mockState(const AlertReviewLoadFailure(error: AppError.dataNotFound));
        await pumpScreen(tester);
        clearInteractions(mockBloc);

        expect(find.text(l10n.errorDataNotFound), findsOneWidget);
        expect(find.byType(AiDraftFrame), findsNothing);
        await tester.tap(find.text(l10n.commonRetry));
        await tester.pump();

        verify(
          () => mockBloc.add(const AlertReviewOpened(alertUid: 'a1')),
        ).called(1);
      });

      for (final status in ['Approved', 'Rejected', 'Withdrawn', 'Expired']) {
        testWidgets('a $status alert offers nothing to approve and no '
            '"not sent" drafts', (tester) async {
          mockState(AlertReviewLoadSuccess(current: _alert(status: status)));
          await pumpScreen(tester);

          expect(find.byType(AiDraftFrame), findsNothing);
          expect(approveButton(), findsNothing);
          expect(find.byType(MoreButton), findsNothing);
        });
      }

      testWidgets('an alert missing a draft key cannot be approved', (
        tester,
      ) async {
        mockState(
          AlertReviewLoadSuccess(
            current: _alert(machineText: {'patient_en': _texts['patient_en']!}),
          ),
        );
        await pumpScreen(tester);

        expect(tester.widget<TabibuButton>(approveButton()).onTap, isNull);
      });

      testWidgets('a demo alert carries the banner; a real one does not', (
        tester,
      ) async {
        mockState(AlertReviewLoadSuccess(current: _alert(synthetic: true)));
        await pumpScreen(tester);
        expect(find.text(l10n.alertReviewDemoBanner), findsOneWidget);

        mockState(AlertReviewLoadSuccess(current: _alert()));
        await tester.pumpWidget(const SizedBox());
        await pumpScreen(tester);
        expect(find.text(l10n.alertReviewDemoBanner), findsNothing);
      });

      testWidgets('the disease register failing does not stop the review', (
        tester,
      ) async {
        when(
          () => referenceData.notifiableDiseases(),
        ).thenAnswer((_) async => throw StateError('no asset'));
        mockState(AlertReviewLoadSuccess(current: _alert()));
        await pumpScreen(tester);

        expect(find.byType(AiDraftFrame), findsNWidgets(2));
        expect(approveButton(), findsOneWidget);
      });
    });
  });
}
