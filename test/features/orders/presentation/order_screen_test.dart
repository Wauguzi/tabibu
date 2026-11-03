import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_item.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_event.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_draft.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_event.dart';
import 'package:tabibu/features/orders/blocs/order_bloc/order_state.dart';
import 'package:tabibu/features/orders/data/models/lab_test_model.dart';
import 'package:tabibu/features/orders/data/models/lab_test_type_model.dart';
import 'package:tabibu/features/orders/presentation/order_screen.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

final AppLocalizations _en = lookupAppLocalizations(const Locale('en'));

SlideItem _slide({
  double? micronsPerPixel,
  SlideUploadStatus status = SlideUploadStatus.picked,
}) => SlideItem(
  localId: 's1',
  fileName: 'slide-a.jpg',
  bytes: Uint8List(2048),
  contentType: 'image/jpeg',
  micronsPerPixel: micronsPerPixel,
  status: status,
);

const _appointment = AppointmentModel(
  uid: 'appt-1',
  status: 'Accepted',
  patientId: 'pat-1',
  patientName: 'Amina Wambui',
  doctorUid: 'doc-1',
);

LabTestModel _test(String id, String name) => LabTestModel.fromJson({
  'labTestId': id,
  'testTypeId': 'histology',
  'testTypeName': 'Histopathology and Cytology',
  'name': name,
  'isActive': true,
  'testPriceKes': 2500,
  'isPriceEstimate': true,
  'tatCollectionToDelivery': 24,
  'tatDeliveryToResults': 48,
  'totalTurnaroundTime': 72,
});

final List<LabTestModel> _tests = [
  _test('t1', 'Histology · sentinel lymph node'),
  _test('t2', 'Cytology · lymph node FNA'),
];

final PractitionerModel _pathologist = PractitionerModel.empty().copyWith(
  uid: 'path-a',
  title: 'Dr.',
  firstName: 'Achieng',
  lastName: 'Odhiambo',
  facilityName: 'Lancet Kenya, Upper Hill',
  isPathologist: true,
  isAvailable: true,
);

OrderDraft _draft({
  List<String> testIds = const [],
  bool created = false,
  String pathologistUid = '',
  bool protocolConfirmed = false,
}) => OrderDraft(
  appointmentUid: 'appt-1',
  patientId: 'pat-1',
  patientName: 'Amina Wambui',
  doctorUid: 'doc-1',
  caseUid: 'case-1',
  testIds: testIds,
  collectedAt: DateTime.now().subtract(const Duration(hours: 1)),
  created: created,
  pathologistUid: pathologistUid,
  protocolConfirmed: protocolConfirmed,
);

OrderEditing _editing(
  OrderDraft draft, {
  RiskCheckModel? riskCheck,
  bool settled = false,
}) => OrderEditing(
  draft: draft,
  tests: _tests,
  testTypes: [
    LabTestTypeModel.fromJson({
      'testTypeId': 'histology',
      'name': 'Histopathology and Cytology',
      'testCount': 2,
    }),
  ],
  pathologists: [_pathologist],
  riskCheck: riskCheck,
  riskCheckSettled: settled,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const OrderReset());
    registerFallbackValue(const SlideUploadReset());
    registerFallbackValue(const CasesRefreshed(uid: '', role: .doctor));
  });

  group('OrderScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      final base = RoleSessions.doctor();
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PractitionerSession(
            doctor: base.doctor.copyWith(uid: 'doc-1'),
            roles: base.roles,
          ),
        ),
      );
      when(
        () => blocs.appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess(appointments: [_appointment]));
    });

    void order(OrderState state, [List<OrderState> then = const []]) {
      when(() => blocs.order.state).thenReturn(state);
      whenListen(blocs.order, Stream.fromIterable(then), initialState: state);
    }

    Widget providers(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        ...blocs.providers,
      ],
      child: child,
    );

    Future<void> pumpScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        providers(const OrderScreen(appointmentUid: 'appt-1')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets("opens the draft for the appointment's patient", (
      tester,
    ) async {
      order(const OrderInitial());
      await pumpScreen(tester);

      verify(
        () => blocs.order.add(
          const OrderStarted(
            appointmentUid: 'appt-1',
            patientId: 'pat-1',
            patientName: 'Amina Wambui',
            doctorUid: 'doc-1',
          ),
        ),
      ).called(1);
    });

    testWidgets('an appointment no longer listed says so', (tester) async {
      when(
        () => blocs.appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess());
      order(const OrderInitial());
      await pumpScreen(tester);

      expect(find.text(_en.orderAppointmentMissing), findsOneWidget);
      verifyNever(() => blocs.order.add(any()));
    });

    group('tests step', () {
      testWidgets('a tap toggles a test; continue needs one', (tester) async {
        order(_editing(_draft()));
        await pumpScreen(tester);

        expect(tester.widget<StepHeader>(find.byType(StepHeader)).step, 1);
        expect(find.text('Histology · sentinel lymph node'), findsOneWidget);
        expect(
          find.text(
            'Histopathology and Cytology · ${_en.orderPriceEstimate(2500)}',
          ),
          findsNWidgets(2),
        );
        final button = tester.widget<TabibuButton>(
          find.widgetWithText(TabibuButton, _en.orderContinueTests(0)),
        );
        expect(button.onTap, isNull);

        await tester.tap(find.text('Cytology · lymph node FNA'));
        verify(
          () => blocs.order.add(const OrderTestToggled(labTestId: 't2')),
        ).called(1);
      });

      testWidgets('search narrows the list', (tester) async {
        order(_editing(_draft()));
        await pumpScreen(tester);

        await tester.enterText(find.byType(EditableText).first, 'fna');
        await tester.pump();

        expect(find.text('Cytology · lymph node FNA'), findsOneWidget);
        expect(find.text('Histology · sentinel lymph node'), findsNothing);
        expect(find.text(_en.orderTestCount(1)), findsOneWidget);
      });

      testWidgets('continue opens the details', (tester) async {
        order(_editing(_draft(testIds: ['t1'])));
        await pumpScreen(tester);

        await tester.tap(find.text(_en.orderContinueTests(1)));
        await tester.pump();

        expect(find.text(_en.orderDetailsTitle), findsOneWidget);
        expect(tester.widget<StepHeader>(find.byType(StepHeader)).step, 2);
      });
    });

    group('details step', () {
      Future<void> openDetails(WidgetTester tester, OrderDraft draft) async {
        order(_editing(draft));
        await pumpScreen(tester);
        await tester.tap(find.text(_en.orderContinueTests(1)));
        await tester.pump();
      }

      testWidgets('creates a valid order', (tester) async {
        await openDetails(tester, _draft(testIds: ['t1']));

        await tester.tap(find.text(_en.orderCreate));
        verify(() => blocs.order.add(const OrderCreateRequested())).called(1);
      });

      testWidgets('shows what stops an invalid one, and sends nothing', (
        tester,
      ) async {
        await openDetails(
          tester,
          _draft(testIds: ['t1']).copyWith(
            insured: true,
            collectedAt: DateTime.now().subtract(const Duration(days: 9)),
          ),
        );

        await tester.tap(find.text(_en.orderCreate));
        await tester.pump();

        expect(find.text(_en.orderCollectedOld), findsOneWidget);
        expect(find.text(_en.orderInsurerMissing), findsOneWidget);
        expect(find.text(_en.orderPolicyInvalid), findsOneWidget);
        verifyNever(() => blocs.order.add(const OrderCreateRequested()));
      });

      testWidgets("the last test can't be removed", (tester) async {
        await openDetails(tester, _draft(testIds: ['t1']));

        expect(
          find.bySemanticsLabel(
            _en.orderRemoveTest('Histology · sentinel lymph node'),
          ),
          findsNothing,
        );
      });
    });

    group('risk check and pathologist (H-11)', () {
      OrderDraft created({bool confirmed = false, String path = ''}) => _draft(
        testIds: ['t1'],
        created: true,
        pathologistUid: path,
        protocolConfirmed: confirmed,
      );

      testWidgets('a created order opens on the last step', (tester) async {
        order(_editing(created()));
        await pumpScreen(tester);

        expect(find.text(_en.orderSendTitle), findsOneWidget);
      });

      testWidgets('the last step refreshes the cases so the new one is known', (
        tester,
      ) async {
        order(_editing(created()));
        await pumpScreen(tester);

        verify(
          () => blocs.cases.add(
            const CasesRefreshed(uid: 'doc-1', role: .doctor),
          ),
        ).called(1);
      });

      testWidgets('the slides card shows when the case needs slides', (
        tester,
      ) async {
        order(_editing(created()));
        when(() => blocs.cases.state).thenReturn(
          CasesLoadSuccess(
            cases: [
              const CaseModel().copyWith(uid: 'case-1', requiresSlides: true),
            ],
          ),
        );
        await pumpScreen(tester);

        expect(find.text(_en.orderSlidesTitle), findsOneWidget);
      });

      testWidgets('the slides card hides when the case needs none', (
        tester,
      ) async {
        order(_editing(created()));
        when(() => blocs.cases.state).thenReturn(
          CasesLoadSuccess(
            cases: [
              const CaseModel().copyWith(uid: 'case-1', requiresSlides: false),
            ],
          ),
        );
        await pumpScreen(tester);

        expect(find.text(_en.orderSlidesTitle), findsNothing);
      });

      testWidgets("the slides card hides while another case's upload runs", (
        tester,
      ) async {
        order(_editing(created()));
        when(() => blocs.cases.state).thenReturn(
          CasesLoadSuccess(
            cases: [
              const CaseModel().copyWith(uid: 'case-1', requiresSlides: true),
            ],
          ),
        );
        when(
          () => blocs.slideUpload.state,
        ).thenReturn(const SlideUploadInProgress(caseUid: 'case-9'));
        await pumpScreen(tester);

        expect(find.text(_en.orderSlidesTitle), findsNothing);
      });

      testWidgets('while it runs: a status, no AI frame, send closed', (
        tester,
      ) async {
        order(
          _editing(created(path: 'path-a'), riskCheck: const RiskCheckModel()),
        );
        await pumpScreen(tester);

        expect(find.text(_en.orderRiskRunning), findsOneWidget);
        expect(find.byType(AiDraftFrame), findsNothing);
        expect(find.text(_en.orderWaitRisk), findsOneWidget);
        final send = tester.widget<TabibuButton>(
          find.widgetWithText(TabibuButton, _en.orderSend),
        );
        expect(send.onTap, isNull);
      });

      testWidgets('a clear result sits in the AI frame with its limits', (
        tester,
      ) async {
        order(
          _editing(
            created(path: 'path-a'),
            riskCheck: const RiskCheckModel(status: 'Ready'),
            settled: true,
          ),
        );
        await pumpScreen(tester);

        final frame = find.byType(AiDraftFrame);
        expect(frame, findsOneWidget);
        expect(
          find.descendant(of: frame, matching: find.text(_en.orderRiskClear)),
          findsOneWidget,
        );
        expect(find.text(_en.orderRiskDisclaimer), findsOneWidget);
        expect(find.text(_en.orderProtocolConfirm), findsNothing);

        await tester.tap(find.text(_en.orderSend));
        verify(() => blocs.order.add(const OrderSendRequested())).called(1);
      });

      testWidgets('a flag shows the protocol outside the frame and must be '
          'confirmed', (tester) async {
        const flagged = RiskCheckModel(
          status: 'Ready',
          advisoryKey: 'VhfProtocol',
          advisoryEn: 'Follow Ministry of Health protocol.',
          suggestedLabTestIds: ['t2'],
        );
        order(
          _editing(created(path: 'path-a'), riskCheck: flagged, settled: true),
        );
        await pumpScreen(tester);

        final frame = find.byType(AiDraftFrame);
        expect(
          find.descendant(
            of: frame,
            matching: find.text('Follow Ministry of Health protocol.'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: frame,
            matching: find.text('• Cytology · lymph node FNA'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: frame,
            matching: find.text(_en.orderProtocolTitle),
          ),
          findsNothing,
        );
        expect(find.text(_en.orderProtocolTitle), findsOneWidget);
        final check = tester.widget<CheckRow>(find.byType(CheckRow));
        expect(check.value, isFalse, reason: 'unticked by default');
        final send = tester.widget<TabibuButton>(
          find.widgetWithText(TabibuButton, _en.orderSend),
        );
        expect(send.onTap, isNull);

        await tester.tap(find.text(_en.orderProtocolConfirm));
        verify(
          () => blocs.order.add(const OrderProtocolConfirmed(confirmed: true)),
        ).called(1);
      });

      testWidgets('a failed check is a plain status, never a frame', (
        tester,
      ) async {
        order(
          _editing(
            created(),
            riskCheck: const RiskCheckModel(status: 'Failed'),
            settled: true,
          ),
        );
        await pumpScreen(tester);

        expect(find.text(_en.orderRiskFailed), findsOneWidget);
        expect(find.byType(AiDraftFrame), findsNothing);
      });

      group('send with slides', () {
        late StreamController<SlideUploadState> uploads;

        setUp(() {
          uploads = StreamController<SlideUploadState>.broadcast();
          addTearDown(uploads.close);
        });

        Future<void> pumpReady(
          WidgetTester tester,
          List<SlideItem> slides,
        ) async {
          final editing = SlideUploadEditing(caseUid: 'case-1', slides: slides);
          when(() => blocs.slideUpload.state).thenReturn(editing);
          when(
            () => blocs.slideUpload.stream,
          ).thenAnswer((_) => uploads.stream);
          when(() => blocs.cases.state).thenReturn(
            CasesLoadSuccess(
              cases: [
                const CaseModel().copyWith(uid: 'case-1', requiresSlides: true),
              ],
            ),
          );
          order(
            _editing(
              created(path: 'path-a'),
              riskCheck: const RiskCheckModel(status: 'Ready'),
              settled: true,
            ),
          );
          await pumpScreen(tester);
        }

        testWidgets('a waiting slide uploads first, then the order is sent', (
          tester,
        ) async {
          await pumpReady(tester, [_slide(micronsPerPixel: 0.972)]);

          await tester.tap(find.text(_en.orderSend));
          await tester.pump();
          verify(
            () => blocs.slideUpload.add(
              const SlideUploadRequested(uid: 'doc-1', caseUid: 'case-1'),
            ),
          ).called(1);
          verifyNever(() => blocs.order.add(const OrderSendRequested()));

          uploads.add(
            SlideUploadSuccess(
              caseUid: 'case-1',
              slides: [
                _slide(
                  micronsPerPixel: 0.972,
                  status: SlideUploadStatus.uploaded,
                ),
              ],
            ),
          );
          await tester.pump();
          await tester.pump();
          verify(() => blocs.order.add(const OrderSendRequested())).called(1);
        });

        testWidgets('a failed upload stops the send', (tester) async {
          await pumpReady(tester, [_slide(micronsPerPixel: 0.972)]);

          await tester.tap(find.text(_en.orderSend));
          await tester.pump();
          uploads.add(
            SlideUploadFailure(
              error: AppError.noInternet,
              caseUid: 'case-1',
              slides: [
                _slide(
                  micronsPerPixel: 0.972,
                  status: SlideUploadStatus.failed,
                ),
              ],
            ),
          );
          await tester.pump();
          await tester.pump();

          verifyNever(() => blocs.order.add(const OrderSendRequested()));
        });

        testWidgets('with every slide already uploaded it only sends', (
          tester,
        ) async {
          await pumpReady(tester, [
            _slide(micronsPerPixel: 0.972, status: SlideUploadStatus.uploaded),
          ]);

          await tester.tap(find.text(_en.orderSend));
          await tester.pump();

          verifyNever(() => blocs.slideUpload.add(any()));
          verify(() => blocs.order.add(const OrderSendRequested())).called(1);
        });

        testWidgets('a slide with no size keeps Send closed and says why', (
          tester,
        ) async {
          await pumpReady(tester, [_slide()]);

          expect(find.text(_en.orderSlidesSizeBeforeSend), findsOneWidget);
          final send = tester.widget<TabibuButton>(
            find.widgetWithText(TabibuButton, _en.orderSend),
          );
          expect(send.onTap, isNull);
        });
      });

      testWidgets('a tap outside the search field drops the keyboard', (
        tester,
      ) async {
        order(_editing(created()));
        await pumpScreen(tester);

        final search = find.descendant(
          of: find.byType(SearchField),
          matching: find.byType(TextField),
        );
        await tester.tap(search);
        await tester.pump();
        expect(tester.widget<TextField>(search).focusNode?.hasFocus, isTrue);

        await tester.tap(find.text(_en.orderSendTitle));
        await tester.pump();
        expect(tester.widget<TextField>(search).focusNode?.hasFocus, isFalse);
      });

      testWidgets('a pathologist shows initials, not the placeholder icon', (
        tester,
      ) async {
        order(
          _editing(
            created(),
            riskCheck: const RiskCheckModel(status: 'Ready'),
            settled: true,
          ),
        );
        await pumpScreen(tester);

        final card = find.ancestor(
          of: find.text('Dr. Achieng Odhiambo'),
          matching: find.byType(OptionCard),
        );
        expect(
          find.descendant(of: card, matching: find.byType(Avatar)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: card, matching: find.text('AO')),
          findsOneWidget,
        );
      });

      testWidgets('choosing a pathologist', (tester) async {
        order(
          _editing(
            created(),
            riskCheck: const RiskCheckModel(status: 'Ready'),
            settled: true,
          ),
        );
        await pumpScreen(tester);

        await tester.tap(find.text('Dr. Achieng Odhiambo'));
        verify(
          () => blocs.order.add(
            const OrderPathologistSelected(pathologistUid: 'path-a'),
          ),
        ).called(1);
      });
    });

    testWidgets('a sent order replaces the wizard with the sent screen', (
      tester,
    ) async {
      final sent = _editing(_draft(testIds: ['t1'], created: true));
      order(sent, [
        OrderSendSuccess(
          draft: sent.draft,
          tests: sent.tests,
          pathologists: sent.pathologists,
        ),
      ]);
      final router = GoRouter(
        initialLocation: '/doctor/appointment/appt-1/order',
        routes: [
          GoRoute(
            path: '/doctor/appointment/:a/order',
            builder: (_, _) =>
                providers(const OrderScreen(appointmentUid: 'appt-1')),
          ),
          GoRoute(
            path: '/doctor/case/:caseUid/sent',
            builder: (_, state) =>
                Text('sent ${state.pathParameters['caseUid']}'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('sent case-1'), findsOneWidget);
    });
  });
}
