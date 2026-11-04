import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
import 'package:tabibu/features/orders/presentation/widgets/order_send_step.dart';
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
  String appointmentUid = 'appt-1',
  String patientId = 'pat-1',
  String patientName = 'Amina Wambui',
}) => OrderDraft(
  appointmentUid: appointmentUid,
  patientId: patientId,
  patientName: patientName,
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
  List<PractitionerModel>? pathologists,
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
  pathologists: pathologists ?? [_pathologist],
  riskCheck: riskCheck,
  riskCheckSettled: settled,
);

void _useTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

AppointmentModel _visit({
  required String uid,
  required String patientId,
  required String patientName,
  String status = 'Accepted',
  String doctorUid = 'doc-1',
  String start = '',
  String end = '',
}) => AppointmentModel(
  uid: uid,
  status: status,
  patientId: patientId,
  patientName: patientName,
  doctorUid: doctorUid,
  scheduledStart: start,
  scheduledEnd: end,
);

void main() {
  setUpAll(() async {
    registerFallbackValue(const OrderReset());
    registerFallbackValue(const SlideUploadReset());
    registerFallbackValue(const CasesRefreshed(uid: '', role: .doctor));
    await initializeDateFormatting('sw');
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

    Future<void> pumpScreen(
      WidgetTester tester, {
      String appointmentUid = 'appt-1',
      String caseUid = '',
      Locale? locale,
      ThemeMode mode = ThemeMode.light,
    }) async {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpApp(
        providers(
          OrderScreen(appointmentUid: appointmentUid, caseUid: caseUid),
        ),
        locale: locale,
        themeMode: mode,
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

    testWidgets('a reopened order tells the bloc who refused', (tester) async {
      order(const OrderInitial());
      when(() => blocs.cases.state).thenReturn(
        CasesLoadSuccess(
          cases: [
            const CaseModel().copyWith(
              uid: 'case-1',
              declinedPathologistUids: ['path-a'],
            ),
          ],
        ),
      );
      await pumpScreen(tester, caseUid: 'case-1');

      verify(
        () => blocs.order.add(
          const OrderStarted(
            appointmentUid: 'appt-1',
            patientId: 'pat-1',
            patientName: 'Amina Wambui',
            doctorUid: 'doc-1',
            caseUid: 'case-1',
            declinedPathologistUids: ['path-a'],
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

    group('patient step', () {
      void visits(List<AppointmentModel> list) {
        when(
          () => blocs.appointments.state,
        ).thenReturn(AppointmentsLoadSuccess(appointments: list));
      }

      List<AppointmentModel> mixed() => [
        _visit(
          uid: 'a-accepted',
          patientId: 'pat-1',
          patientName: 'Amina Wambui',
          start: '2030-06-01T09:00:00Z',
        ),
        _visit(
          uid: 'a-done',
          status: 'Completed',
          patientId: 'pat-2',
          patientName: 'Brian Otieno',
          start: '2030-05-01T09:00:00Z',
        ),
        _visit(
          uid: 'a-asked',
          status: 'Requested',
          patientId: 'pat-3',
          patientName: 'Cynthia Njeri',
        ),
        _visit(
          uid: 'a-no',
          status: 'Declined',
          patientId: 'pat-4',
          patientName: 'David Kamau',
        ),
        _visit(
          uid: 'a-gone',
          status: 'Cancelled',
          patientId: 'pat-5',
          patientName: 'Faith Achieng',
        ),
        _visit(
          uid: 'a-theirs',
          patientId: 'pat-6',
          patientName: 'Edith Wanjiru',
          doctorUid: 'doc-9',
        ),
      ];

      testWidgets('lists only orderable patients of this doctor', (
        tester,
      ) async {
        order(const OrderInitial());
        visits(mixed());

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            await pumpScreen(tester, appointmentUid: '', locale: locale);

            expect(find.text(l10n.orderPatientTitle), findsOneWidget);
            expect(find.text('Amina Wambui'), findsOneWidget);
            expect(find.text('Brian Otieno'), findsOneWidget);
            expect(find.text('Cynthia Njeri'), findsNothing);
            expect(find.text('David Kamau'), findsNothing);
            expect(find.text('Faith Achieng'), findsNothing);
            expect(find.text('Edith Wanjiru'), findsNothing);
          }
        }
      });

      testWidgets('each row hangs off the right visit', (tester) async {
        order(const OrderInitial());
        visits([
          _visit(
            uid: 'a-old',
            status: 'Completed',
            patientId: 'pat-1',
            patientName: 'Amina Wambui',
            start: '2020-01-01T09:00:00Z',
          ),
          _visit(
            uid: 'a-now',
            patientId: 'pat-1',
            patientName: 'Amina Wambui',
            start: '2020-06-01T09:00:00Z',
            end: '2030-06-01T09:00:00Z',
          ),
          _visit(
            uid: 'a-later',
            patientId: 'pat-1',
            patientName: 'Amina Wambui',
            start: '2025-01-01T09:00:00Z',
          ),
          _visit(
            uid: 'b-old',
            status: 'Completed',
            patientId: 'pat-2',
            patientName: 'Brian Otieno',
            start: '2020-01-01T09:00:00Z',
          ),
          _visit(
            uid: 'b-latest',
            status: 'Completed',
            patientId: 'pat-2',
            patientName: 'Brian Otieno',
            start: '2021-03-04T09:00:00Z',
          ),
        ]);
        await pumpScreen(tester, appointmentUid: '');

        // One row per patient, on the latest visit date.
        expect(find.text('Amina Wambui'), findsOneWidget);
        expect(find.text('Brian Otieno'), findsOneWidget);
        expect(
          find.text(
            DateFormat(
              'EEE d MMM',
              'en',
            ).format(DateTime.parse('2021-03-04T09:00:00Z')),
          ),
          findsOneWidget,
        );

        // The visit under way wins over the later one.
        await tester.tap(find.text('Amina Wambui'));
        await tester.pump();
        final picked =
            verify(() => blocs.order.add(captureAny())).captured.single
                as OrderStarted;
        expect(picked.appointmentUid, 'a-now');
        expect(picked.patientId, 'pat-1');
        expect(picked.patientName, 'Amina Wambui');
        expect(picked.doctorUid, 'doc-1');
      });

      testWidgets('search filters the rows', (tester) async {
        order(const OrderInitial());
        visits(mixed());
        await pumpScreen(tester, appointmentUid: '');

        await tester.enterText(find.byType(TextField), 'brian');
        await tester.pump();

        expect(find.text('Brian Otieno'), findsOneWidget);
        expect(find.text('Amina Wambui'), findsNothing);
      });

      testWidgets('picking moves to the tests as step 2 of 4', (tester) async {
        final semantics = tester.ensureSemantics();
        final editing = _editing(_draft(appointmentUid: 'a-accepted'));
        order(const OrderInitial(), [editing]);
        visits(mixed());

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            // Unmount first: taps move the wizard's step.
            await tester.pumpWidget(const SizedBox());
            await pumpScreen(tester, appointmentUid: '', locale: locale);

            expect(
              find.bySemanticsLabel(l10n.orderStepProgress(1, 4)),
              findsOneWidget,
            );
            await tester.tap(find.text('Amina Wambui'));
            await tester.pump();

            expect(
              find.bySemanticsLabel(l10n.orderStepProgress(2, 4)),
              findsOneWidget,
            );
            expect(find.text(l10n.orderTestsTitle), findsOneWidget);
            expect(find.text(l10n.orderPatientTitle), findsNothing);
          }
        }
        semantics.dispose();
      });

      testWidgets('no visits shows the empty state, not a crash', (
        tester,
      ) async {
        order(const OrderInitial());
        visits([]);

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            await pumpScreen(tester, appointmentUid: '', locale: locale);

            expect(find.text(l10n.orderPatientEmptyTitle), findsOneWidget);
            expect(find.text(l10n.orderPatientEmptyBody), findsOneWidget);
          }
        }
      });

      testWidgets('opened from a visit skips the patient step', (tester) async {
        final semantics = tester.ensureSemantics();
        order(_editing(_draft()));
        visits(mixed());

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            await pumpScreen(tester, locale: locale);

            expect(
              find.bySemanticsLabel(l10n.orderStepProgress(1, 3)),
              findsOneWidget,
            );
            expect(find.text(l10n.orderTestsTitle), findsOneWidget);
            expect(find.text(l10n.orderPatientTitle), findsNothing);
          }
        }
        semantics.dispose();
      });

      testWidgets('switching patients with content confirms first', (
        tester,
      ) async {
        order(_editing(_draft(testIds: ['t1'], appointmentUid: 'a-accepted')));
        visits(mixed());

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            // Unmount first: taps move the wizard's step.
            await tester.pumpWidget(const SizedBox());
            await pumpScreen(tester, appointmentUid: '', locale: locale);

            await tester.tap(find.text('Brian Otieno'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 600));

            expect(
              find.text(l10n.orderPatientChangeTitle('Brian Otieno')),
              findsOneWidget,
            );
            await tester.tap(find.text(l10n.orderPatientChangeConfirm));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 600));

            final picked =
                verify(() => blocs.order.add(captureAny())).captured.last
                    as OrderStarted;
            expect(picked.appointmentUid, 'a-done');
            expect(picked.patientId, 'pat-2');
          }
        }
      });

      testWidgets('cancelling the switch stays on the patient', (tester) async {
        order(_editing(_draft(testIds: ['t1'], appointmentUid: 'a-accepted')));
        visits(mixed());
        await pumpScreen(tester, appointmentUid: '');

        await tester.tap(find.text('Brian Otieno'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.tap(find.text(_en.commonCancel));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        verifyNever(() => blocs.order.add(any()));
        expect(find.text(_en.orderPatientTitle), findsOneWidget);
      });

      testWidgets('switching patients without content asks nothing', (
        tester,
      ) async {
        order(_editing(_draft(appointmentUid: 'a-accepted')));
        visits(mixed());
        await pumpScreen(tester, appointmentUid: '');

        await tester.tap(find.text('Brian Otieno'));
        await tester.pump();

        expect(find.text(_en.orderPatientChangeBody), findsNothing);
        final picked =
            verify(() => blocs.order.add(captureAny())).captured.single
                as OrderStarted;
        expect(picked.appointmentUid, 'a-done');
      });

      testWidgets('back from the patient step leaves the wizard', (
        tester,
      ) async {
        order(const OrderInitial());
        visits(mixed());
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (_, _) => const Text('home-stub')),
            GoRoute(
              path: '/doctor/order',
              builder: (_, _) => providers(const OrderScreen()),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpRouterApp(router);
        unawaited(router.push('/doctor/order'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text(_en.orderPatientTitle), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('home-stub'), findsOneWidget);
      });

      testWidgets('a refused create shows the plain line', (tester) async {
        for (final error in [AppError.notInCare, AppError.invalidAppointment]) {
          final failed = OrderWriteFailure(
            error: error,
            draft: _draft(testIds: ['t1']),
          );
          order(_editing(_draft(testIds: ['t1'])), [failed]);
          await tester.pumpWidget(const SizedBox());
          await pumpScreen(tester);
          await tester.pump(const Duration(milliseconds: 400));

          expect(find.text(error.description(_en)), findsOneWidget);
          await tester.pump(const Duration(seconds: 5));
        }
      });

      testWidgets('the same visit just advances', (tester) async {
        final semantics = tester.ensureSemantics();
        order(_editing(_draft(testIds: ['t1'], appointmentUid: 'a-accepted')));
        visits(mixed());
        await pumpScreen(tester, appointmentUid: '');

        await tester.tap(find.text('Amina Wambui'));
        await tester.pump();

        verifyNever(() => blocs.order.add(any()));
        expect(
          find.bySemanticsLabel(_en.orderStepProgress(2, 4)),
          findsOneWidget,
        );
        semantics.dispose();
      });

      testWidgets('the patient step fits at 1.0x and 2.0x, both languages, '
          'both modes', (tester) async {
        order(const OrderInitial());
        visits(mixed());

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            for (final mode in [ThemeMode.light, ThemeMode.dark]) {
              _useTextScale(tester, scale);
              final l10n = lookupAppLocalizations(locale);
              await pumpScreen(
                tester,
                appointmentUid: '',
                locale: locale,
                mode: mode,
              );

              expect(find.text(l10n.orderPatientTitle), findsOneWidget);
              expect(find.text('Amina Wambui'), findsOneWidget);
              expect(find.text('Brian Otieno'), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
          }
        }
      });

      testWidgets('the change-patient sheet fits too', (tester) async {
        order(_editing(_draft(testIds: ['t1'], appointmentUid: 'a-accepted')));
        visits(mixed());

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            for (final mode in [ThemeMode.light, ThemeMode.dark]) {
              _useTextScale(tester, scale);
              final l10n = lookupAppLocalizations(locale);
              // Unmount first: taps move the wizard's step.
              await tester.pumpWidget(const SizedBox());
              await pumpScreen(
                tester,
                appointmentUid: '',
                locale: locale,
                mode: mode,
              );

              await tester.tap(find.text('Brian Otieno'));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 600));

              expect(
                find.text(l10n.orderPatientChangeTitle('Brian Otieno')),
                findsOneWidget,
              );
              expect(find.text(l10n.orderPatientChangeConfirm), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
          }
        }
      });
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

      testWidgets('two tests each get a remove control of at least 48 dp', (
        tester,
      ) async {
        order(_editing(_draft(testIds: ['t1', 't2'])));
        await pumpScreen(tester);
        await tester.tap(find.text(_en.orderContinueTests(2)));
        await tester.pump();

        expect(tester.takeException(), isNull);
        final removes = find.byWidgetPredicate(
          (w) =>
              w is CircleIconButton &&
              w.semanticLabel.startsWith(_en.orderRemoveTest('')),
        );
        expect(removes, findsNWidgets(2));
        for (final remove in removes.evaluate()) {
          expect(
            tester.getSize(find.byWidget(remove.widget)).shortestSide,
            greaterThanOrEqualTo(48),
          );
        }
      });

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

      testWidgets('no pathologist to offer says so', (tester) async {
        order(_editing(created(), pathologists: []));

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            await pumpScreen(tester, caseUid: 'case-1', locale: locale);

            final line = find.text(l10n.orderNoPathologists);
            await tester.scrollUntilVisible(
              line,
              500,
              scrollable: find
                  .descendant(
                    of: find.byType(OrderSendStep),
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            expect(line, findsOneWidget);
          }
        }
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
        initialLocation: '/doctor/order?appointment-uid=appt-1',
        routes: [
          GoRoute(
            path: '/doctor/order',
            builder: (_, state) => providers(
              OrderScreen(
                appointmentUid:
                    state.uri.queryParameters['appointment-uid'] ?? '',
              ),
            ),
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
