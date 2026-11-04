// cspell:ignore Didnt
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/doctor_appointment_screen.dart';
import 'package:tabibu/features/appointments/presentation/widgets/patient_card.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/presentation/widgets/case_stepper.dart';
import 'package:tabibu/features/cases/presentation/widgets/notes_card.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester, {double width = 1170}) {
  tester.view.physicalSize = Size(width, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _useTextScale(WidgetTester tester, double scale) {
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// A sheet opens and closes on animations that never settle under a spinner.
Future<void> settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

PractitionerSession _session() {
  final base = RoleSessions.doctor();
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: 'doctor-1'),
    roles: base.roles,
  );
}

/// An accepted visit whose slot is [startsIn]..[endsIn] from now, so the
/// screen's own clock decides what is allowed.
AppointmentModel _appointment({
  Duration startsIn = const Duration(hours: -1),
  Duration endsIn = const Duration(hours: 1),
  String status = 'Accepted',
  String name = 'Amina Wambui',
  List<String> caseUids = const ['case-1'],
  String discussedCaseUid = '',
  String language = 'sw',
}) {
  final now = DateTime.now().toUtc();
  return AppointmentModel(
    uid: 'a1',
    status: status,
    patientUid: 'patient-1',
    patientName: name,
    doctorUid: 'doctor-1',
    createdByUid: 'patient-1',
    scheduledStart: now.add(startsIn).toIso8601String(),
    scheduledEnd: now.add(endsIn).toIso8601String(),
    createdAt: '2026-10-22T07:00:00Z',
    caseUids: caseUids,
    discussedCaseUid: discussedCaseUid,
    symptomLanguage: language,
  );
}

CaseModel _case({
  String uid = 'case-1',
  String notes = '',
  String stage = 'OrderCreated',
  String createdAt = '2026-10-23T07:00:00Z',
  String orderNumber = 'TB-0231',
  String appointmentUid = '',
}) => CaseModel(
  uid: uid,
  appointmentUid: appointmentUid,
  orderNumber: orderNumber,
  patientAgeYears: 46,
  patientSex: 'Female',
  clinicalNotes: notes,
  currentStage: stage,
  createdAt: createdAt,
);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final sw = lookupAppLocalizations(const Locale('sw'));

  setUpAll(() {
    registerFallbackValue(const AppointmentsReset());
    registerFallbackValue(const CasesReset());
  });

  group('DoctorAppointmentScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;
    late StreamController<AppointmentsState> appointmentStates;
    late StreamController<CasesState> caseStates;
    late GoRouter router;

    void register({
      required AppointmentsState appointments,
      CasesState cases = const CasesLoadSuccess(),
    }) {
      when(() => blocs.appointments.state).thenReturn(appointments);
      when(
        () => blocs.appointments.stream,
      ).thenAnswer((_) => appointmentStates.stream);
      when(() => blocs.cases.state).thenReturn(cases);
      when(() => blocs.cases.stream).thenAnswer((_) => caseStates.stream);
    }

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      appointmentStates = StreamController<AppointmentsState>.broadcast();
      caseStates = StreamController<CasesState>.broadcast();
      addTearDown(appointmentStates.close);
      addTearDown(caseStates.close);
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      register(
        appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
        cases: CasesLoadSuccess(cases: [_case()]),
      );
    });

    /// Delivers a state and the frame it causes; the stream delivers on the
    /// event queue, so the queue is drained, not hopped a set number of times.
    Future<void> emitAppointments(
      WidgetTester tester,
      AppointmentsState state,
    ) async {
      when(() => blocs.appointments.state).thenReturn(state);
      appointmentStates.add(state);
      await tester.runAsync(pumpEventQueue);
      await tester.pump();
    }

    Future<void> emitCases(WidgetTester tester, CasesState state) async {
      when(() => blocs.cases.state).thenReturn(state);
      caseStates.add(state);
      await tester.runAsync(pumpEventQueue);
      await tester.pump();
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('home-stub')),
            routes: [
              GoRoute(
                path: 'doctor/appointment/:appointmentUid',
                builder: (_, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider<AuthBloc>.value(value: authBloc),
                    ...blocs.providers,
                  ],
                  child: DoctorAppointmentScreen(
                    appointmentUid: state.pathParameters['appointmentUid']!,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'chat',
                    builder: (_, _) => const Scaffold(body: Text('chat-stub')),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/doctor/calendar',
            builder: (_, _) => const Scaffold(body: Text('calendar-stub')),
          ),
          GoRoute(
            path: '/doctor/order',
            builder: (_, state) => Scaffold(
              body: Column(
                children: [
                  const Text('order-stub'),
                  Text(
                    'visit ${state.uri.queryParameters['appointment-uid']} '
                    'case ${state.uri.queryParameters['case-uid']}',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      await tester.pumpRouterApp(router, themeMode: themeMode, locale: locale);
      unawaited(router.push('/doctor/appointment/a1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    Finder inSheet(Finder matching) =>
        find.descendant(of: find.byType(TabibuBottomSheet), matching: matching);

    // By label, not text: a loading button hides its text.
    Finder buttonLabelled(String label) => find.byWidgetPredicate(
      (widget) => widget is TabibuButton && widget.label == label,
    );

    Finder endButton() => buttonLabelled(en.doctorAppointmentEnd);
    Finder orderButton() => buttonLabelled(en.doctorAppointmentOrderTest);

    Finder pencil() => find.descendant(
      of: find.byType(NotesCard),
      matching: find.byType(CircleIconButton),
    );

    /// The nairobi clock the screen prints for an instant.
    String subtitleOf(String iso, [String language = 'en']) {
      final time = nairobiTimeOf(iso)!;
      return DateFormat('EEE d MMM · h:mm a', language).format(time);
    }

    group('data', () {
      testWidgets('asks for both blocs only when they lack this visit', (
        tester,
      ) async {
        register(appointments: const AppointmentsInitial());
        _useTallSurface(tester);
        await pumpScreen(tester);

        verify(
          () => blocs.appointments.add(
            const AppointmentsRequested(uid: 'doctor-1', role: Role.doctor),
          ),
        ).called(1);
        verify(
          () => blocs.cases.add(
            const CasesRequested(uid: 'doctor-1', role: Role.doctor),
          ),
        ).called(1);
      });

      testWidgets('asks for nothing when both blocs already have data', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        verifyNever(() => blocs.appointments.add(any()));
        verifyNever(() => blocs.cases.add(any()));
      });

      testWidgets('a missing visit shows not found, with Back', (tester) async {
        register(appointments: const AppointmentsLoadSuccess());
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text(en.appointmentDetailNotFoundTitle), findsOneWidget);
        expect(find.byType(PatientCard), findsNothing);

        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is CircleIconButton &&
                widget.semanticLabel == en.commonBack,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('home-stub'), findsOneWidget);
      });

      testWidgets('shows a spinner label while the sync runs', (tester) async {
        register(appointments: const AppointmentsLoadInProgress());
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.byType(LoadingView), findsOneWidget);
        expect(find.text(en.appointmentDetailNotFoundTitle), findsNothing);
      });

      testWidgets('waits for the case an appointment points at', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: const CasesLoadInProgress(),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        // No flash of the first-visit variant.
        expect(find.byType(LoadingView), findsOneWidget);
        expect(find.text(en.doctorAppointmentNewTitle), findsNothing);

        await emitCases(tester, CasesLoadSuccess(cases: [_case()]));
        expect(find.byType(CaseStepper), findsOneWidget);
      });

      testWidgets('the discussed case wins over the newer one', (tester) async {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [
              _appointment(
                caseUids: ['case-1', 'case-2'],
                discussedCaseUid: 'case-1',
              ),
            ],
          ),
          cases: CasesLoadSuccess(
            cases: [
              _case(orderNumber: 'TB-0001'),
              _case(
                uid: 'case-2',
                orderNumber: 'TB-0002',
                createdAt: '2026-10-30T07:00:00Z',
              ),
            ],
          ),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text('TB-0001'), findsOneWidget);
        expect(find.text('TB-0002'), findsNothing);
      });

      testWidgets('else the newest of the cases this doctor has', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [
              _appointment(caseUids: ['case-1', 'case-2', 'case-gone']),
            ],
          ),
          cases: CasesLoadSuccess(
            cases: [
              _case(orderNumber: 'TB-0001'),
              _case(
                uid: 'case-2',
                orderNumber: 'TB-0002',
                createdAt: '2026-10-30T07:00:00Z',
              ),
            ],
          ),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text('TB-0002'), findsOneWidget);
        expect(find.text('TB-0001'), findsNothing);
      });
    });

    group('variant A, with a case', () {
      testWidgets('titles, patient, stepper and info tiles', (tester) async {
        final appointment = _appointment();
        register(
          appointments: AppointmentsLoadSuccess(appointments: [appointment]),
          cases: CasesLoadSuccess(cases: [_case()]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text(en.appointmentsTypeConsultation), findsWidgets);
        expect(
          find.text(subtitleOf(appointment.scheduledStart)),
          findsOneWidget,
        );
        expect(find.text('Amina Wambui'), findsOneWidget);
        expect(find.text('46 · ${en.sexFemale}'), findsOneWidget);
        // No check-in data and no call, chat or records: no chip, no actions.
        expect(
          find.descendant(
            of: find.byType(PatientCard),
            matching: find.byType(StatusChip),
          ),
          findsNothing,
        );
        expect(
          tester.widget<PatientCard>(find.byType(PatientCard)).actions,
          isEmpty,
        );

        expect(find.text('TB-0231'), findsOneWidget);
        // OrderCreated is the model's step 1; the screen never maps stages.
        expect(tester.widget<CaseStepper>(find.byType(CaseStepper)).current, 1);
        expect(
          find.text('${en.doctorCaseNext} · ${en.rolePathologist}'),
          findsOneWidget,
        );
        expect(find.textContaining('Booked by Amina, '), findsOneWidget);
        expect(find.text(en.languageSw), findsOneWidget);
        expect(
          find.text(en.doctorAppointmentPreferredLanguage),
          findsOneWidget,
        );
        expect(find.text(en.doctorAppointmentWhyBooked('Amina')), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('a finished case reads Done, never a next step', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: CasesLoadSuccess(cases: [_case(stage: 'Completed')]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(tester.widget<CaseStepper>(find.byType(CaseStepper)).current, 5);
        expect(find.text(en.chipDone), findsOneWidget);
        expect(find.textContaining(en.doctorCaseNext), findsNothing);
      });

      testWidgets('no preferred language: one tile, no empty claim', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [_appointment(language: '')],
          ),
          cases: CasesLoadSuccess(cases: [_case()]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text(en.doctorAppointmentPreferredLanguage), findsNothing);
        expect(find.text(en.languageEn), findsNothing);
      });
    });

    group('variant B, first visit', () {
      setUp(() {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [_appointment(caseUids: const [])],
          ),
        );
      });

      testWidgets('shows why the patient booked, with no stepper or notes', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text(en.doctorAppointmentNewTitle), findsOneWidget);
        expect(find.byType(CaseStepper), findsNothing);
        expect(find.byType(NotesCard), findsNothing);
        expect(
          find.text(en.doctorAppointmentWhyBooked('Amina')),
          findsOneWidget,
        );
        expect(
          find.text(en.doctorAppointmentTypeDuration('Consultation', 120)),
          findsOneWidget,
        );
        expect(find.text(en.languageSw), findsOneWidget);
        expect(find.text(en.doctorAppointmentFirstYes), findsOneWidget);
        expect(find.textContaining('Booked by Amina, '), findsOneWidget);
      });

      testWidgets('a patient the doctor has finished with is not first time', (
        tester,
      ) async {
        final earlier = _appointment(
          caseUids: const [],
          status: 'Completed',
        ).copyWith(uid: 'a0');
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [
              _appointment(caseUids: const []),
              earlier,
            ],
          ),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text(en.doctorAppointmentFirstNo), findsOneWidget);
        expect(find.text(en.doctorAppointmentFirstYes), findsNothing);
      });
    });

    group('end and options', () {
      testWidgets('End is disabled until the slot starts, with its reason', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [
              _appointment(
                startsIn: const Duration(hours: 2),
                endsIn: const Duration(hours: 3),
              ),
            ],
          ),
          cases: CasesLoadSuccess(cases: [_case()]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(tester.widget<TabibuButton>(endButton()).onTap, isNull);
        expect(find.text(en.doctorAppointmentEndDisabled), findsOneWidget);
        expect(tester.widget<TabibuButton>(orderButton()).onTap, isNotNull);

        await tester.tap(endButton(), warnIfMissed: false);
        await tester.pump();
        verifyNever(() => blocs.appointments.add(any()));
      });

      testWidgets('End is enabled once started, and sends Completed', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(tester.widget<TabibuButton>(endButton()).onTap, isNotNull);
        expect(find.text(en.doctorAppointmentEndDisabled), findsNothing);

        await tester.tap(endButton());
        await tester.pump();

        verify(
          () => blocs.appointments.add(
            const AppointmentCompleteRequested(
              appointmentUid: 'a1',
              outcome: 'Completed',
            ),
          ),
        ).called(1);
      });

      testWidgets('a slot starting this instant counts as started', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [_appointment(startsIn: Duration.zero)],
          ),
          cases: CasesLoadSuccess(cases: [_case()]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(tester.widget<TabibuButton>(endButton()).onTap, isNotNull);
      });

      testWidgets('an order made at this visit but not sent picks up where '
          'it stopped', (tester) async {
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: CasesLoadSuccess(cases: [_case(appointmentUid: 'a1')]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(orderButton(), findsNothing);
        await tester.tap(buttonLabelled(en.doctorCaseAttachPathologist));
        await tester.pumpAndSettle();

        expect(find.text('order-stub'), findsOneWidget);
        expect(find.text('visit a1 case case-1'), findsOneWidget);
      });

      testWidgets('a refused case at this visit reopens the order', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: CasesLoadSuccess(
            cases: [_case(stage: 'PathologistRejected', appointmentUid: 'a1')],
          ),
        );
        _useTallSurface(tester);

        for (final scale in [1.0, 2.0]) {
          for (final locale in [const Locale('en'), const Locale('sw')]) {
            _useTextScale(tester, scale);
            final l10n = lookupAppLocalizations(locale);
            // Unmount first: pumpScreen builds a fresh router per pass.
            await tester.pumpWidget(const SizedBox());
            await pumpScreen(tester, locale: locale);

            expect(
              buttonLabelled(l10n.doctorAppointmentOrderTest),
              findsNothing,
            );
            final attach = buttonLabelled(l10n.doctorCaseAttachPathologist);
            expect(attach, findsOneWidget);
            await tester.tap(attach);
            await tester.pumpAndSettle();

            expect(find.text('order-stub'), findsOneWidget);
            expect(find.text('visit a1 case case-1'), findsOneWidget);
          }
        }
      });

      testWidgets('the end hint sits in the body under the notes', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [
              _appointment(
                startsIn: const Duration(hours: 2),
                endsIn: const Duration(hours: 3),
              ),
            ],
          ),
          cases: CasesLoadSuccess(cases: [_case()]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        final hint = find.text(en.doctorAppointmentEndDisabled);
        expect(
          find.descendant(of: find.byType(BottomActionBar), matching: hint),
          findsNothing,
        );
        expect(
          tester.getTopLeft(hint).dy,
          greaterThan(tester.getBottomLeft(find.byType(NotesCard)).dy),
        );
      });

      testWidgets('Order a test pushes the order route', (tester) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(orderButton());
        await tester.pumpAndSettle();

        expect(find.text('order-stub'), findsOneWidget);
      });

      testWidgets(
        'bundle 51: mid-slot options offer Message the patient and open chat',
        (tester) async {
          _useTallSurface(tester);
          await pumpScreen(tester);

          expect(find.byType(MoreButton), findsOneWidget);
          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          expect(inSheet(find.text(en.chatMessagePatient)), findsOneWidget);
          expect(inSheet(find.text(en.chatMessagePatientBody)), findsOneWidget);
          // Call and records stay hidden (F-11); chat is back (S-3).
          expect(
            inSheet(find.text(en.doctorAppointmentDidntCome)),
            findsNothing,
          );

          await tester.tap(inSheet(find.text(en.chatMessagePatient)));
          await tester.pump(const Duration(milliseconds: 700));
          await settleSheet(tester);

          expect(find.text('chat-stub'), findsOneWidget);
        },
      );

      group('after the slot', () {
        setUp(() {
          register(
            appointments: AppointmentsLoadSuccess(
              appointments: [
                _appointment(
                  startsIn: const Duration(hours: -2),
                  endsIn: const Duration(hours: -1),
                ),
              ],
            ),
            cases: CasesLoadSuccess(cases: [_case()]),
          );
        });

        testWidgets('Didn’t come completes as NoShow, after the sheet shut', (
          tester,
        ) async {
          _useTallSurface(tester);
          await pumpScreen(tester);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          expect(
            inSheet(find.text(en.doctorAppointmentDidntCome)),
            findsOneWidget,
          );
          // Message + Didn’t come; call and records stay hidden.
          expect(inSheet(find.text(en.chatMessagePatient)), findsOneWidget);
          expect(inSheet(find.byType(Tappable)), findsNWidgets(2));

          await tester.tap(inSheet(find.text(en.doctorAppointmentDidntCome)));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          // Still sliding away: nothing sent yet.
          verifyNever(() => blocs.appointments.add(any()));

          await tester.pump(const Duration(milliseconds: 600));
          verify(
            () => blocs.appointments.add(
              const AppointmentCompleteRequested(
                appointmentUid: 'a1',
                outcome: 'NoShow',
              ),
            ),
          ).called(1);
          expect(find.byType(TabibuBottomSheet), findsNothing);
        });

        testWidgets('dismissing the options sheet sends nothing', (
          tester,
        ) async {
          _useTallSurface(tester);
          await pumpScreen(tester);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          await tester.tapAt(const Offset(20, 40));
          await settleSheet(tester);
          await tester.pump(const Duration(seconds: 1));

          verifyNever(() => blocs.appointments.add(any()));
        });
      });

      group('before the slot', () {
        setUp(() {
          register(
            appointments: AppointmentsLoadSuccess(
              appointments: [
                _appointment(
                  startsIn: const Duration(hours: 2),
                  endsIn: const Duration(hours: 3),
                ),
              ],
            ),
            cases: CasesLoadSuccess(cases: [_case()]),
          );
        });

        testWidgets('an upcoming visit offers Move, Message and Cancel', (
          tester,
        ) async {
          _useTallSurface(tester);
          await pumpScreen(tester);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);

          expect(inSheet(find.text(en.rescheduleEntryMove)), findsOneWidget);
          expect(inSheet(find.text(en.chatMessagePatient)), findsOneWidget);
          expect(
            inSheet(find.text(en.cancelAppointmentConfirm)),
            findsOneWidget,
          );
          expect(
            inSheet(find.text(en.doctorAppointmentDidntCome)),
            findsNothing,
          );
        });

        testWidgets('Move opens the move sheet', (tester) async {
          _useTallSurface(tester);
          await pumpScreen(tester);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          await tester.tap(inSheet(find.text(en.rescheduleEntryMove)));
          await tester.pump(const Duration(milliseconds: 700));
          await settleSheet(tester);

          expect(find.text(en.rescheduleTitle), findsOneWidget);

          Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
          await settleSheet(tester);
        });

        testWidgets('Cancel sends the doctor cancel with the note', (
          tester,
        ) async {
          _useTallSurface(tester);
          await pumpScreen(tester);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          await tester.tap(inSheet(find.text(en.cancelAppointmentConfirm)));
          await tester.pump(const Duration(milliseconds: 700));
          await settleSheet(tester);

          expect(
            find.text(en.cancelAppointmentTitleDoctor('Amina')),
            findsOneWidget,
          );
          await tester.enterText(find.byType(TextField), 'In theatre');
          await tester.pump();
          await tester.tap(inSheet(find.text(en.cancelAppointmentConfirm)));
          await settleSheet(tester);

          verify(
            () => blocs.appointments.add(
              const AppointmentCancelRequested(
                appointmentUid: 'a1',
                cancelledByUid: 'doctor-1',
                note: 'In theatre',
              ),
            ),
          ).called(1);
        });
      });

      testWidgets('success reads Ended and removes every action', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(endButton());
        await tester.pump();
        await emitAppointments(
          tester,
          AppointmentWriteInProgress(appointments: [_appointment()]),
        );
        expect(tester.widget<TabibuButton>(endButton()).isLoading, isTrue);

        final done = _appointment(status: 'Completed');
        await emitAppointments(
          tester,
          AppointmentCompleteSuccess(appointment: done, appointments: [done]),
        );

        expect(find.text(en.doctorAppointmentEnded), findsOneWidget);
        expect(endButton(), findsNothing);
        expect(orderButton(), findsNothing);
        expect(find.byType(MoreButton), findsNothing);
      });

      testWidgets('ending offline says so and keeps the buttons', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(endButton());
        await tester.pump();
        await emitAppointments(
          tester,
          AppointmentWriteFailure(
            error: AppError.noInternet,
            appointments: [_appointment()],
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text(AppError.noInternet.description(en)), findsOneWidget);
        expect(endButton(), findsOneWidget);
        expect(find.text(en.doctorAppointmentEnded), findsNothing);

        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 300));
      });

      testWidgets('a failure this screen did not start stays quiet', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await emitAppointments(
          tester,
          AppointmentWriteFailure(
            error: AppError.noInternet,
            appointments: [_appointment()],
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text(AppError.noInternet.description(en)), findsNothing);
      });

      for (final status in ['Completed', 'NoShow', 'Declined', 'Cancelled']) {
        testWidgets('a $status visit has no bar and no options', (
          tester,
        ) async {
          register(
            appointments: AppointmentsLoadSuccess(
              appointments: [
                _appointment(
                  status: status,
                  startsIn: const Duration(hours: -2),
                  endsIn: const Duration(hours: -1),
                ),
              ],
            ),
            cases: CasesLoadSuccess(cases: [_case()]),
          );
          _useTallSurface(tester);
          await pumpScreen(tester);

          expect(find.byType(BottomActionBar), findsNothing);
          expect(find.byType(MoreButton), findsNothing);
          expect(find.text(en.doctorAppointmentEnded), findsNothing);
        });
      }

      testWidgets('the calendar button opens the month', (tester) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(find.byTooltip(en.calendarTitle));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('calendar-stub'), findsOneWidget);
      });

      testWidgets(
        'Didn’t come joins the sheet once the slot ends (Message was already '
        'there)',
        (tester) async {
          // Message is available mid-slot; Didn’t come waits for the end.
          final soon = _appointment(endsIn: const Duration(milliseconds: 1500));
          register(
            appointments: AppointmentsLoadSuccess(appointments: [soon]),
            cases: CasesLoadSuccess(cases: [_case()]),
          );
          _useTallSurface(tester);
          await pumpScreen(tester);
          expect(find.byType(MoreButton), findsOneWidget);

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          expect(inSheet(find.text(en.chatMessagePatient)), findsOneWidget);
          expect(
            inSheet(find.text(en.doctorAppointmentDidntCome)),
            findsNothing,
          );
          Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
          await settleSheet(tester);

          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 1600)),
          );
          await tester.pump(const Duration(seconds: 2));

          await tester.tap(find.byType(MoreButton));
          await settleSheet(tester);
          expect(
            inSheet(find.text(en.doctorAppointmentDidntCome)),
            findsOneWidget,
          );
        },
      );
    });

    group('notes', () {
      testWidgets('shows the case’s notes, or the hint when there are none', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: CasesLoadSuccess(cases: [_case(notes: 'Wound is clean')]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(find.text('Wound is clean'), findsOneWidget);
        expect(find.text(en.doctorAppointmentNotesHint), findsNothing);

        await emitCases(tester, CasesLoadSuccess(cases: [_case()]));
        expect(find.text(en.doctorAppointmentNotesHint), findsOneWidget);
      });

      testWidgets('the pencil opens a prefilled sheet, and no keyboard', (
        tester,
      ) async {
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: CasesLoadSuccess(cases: [_case(notes: 'Wound is clean')]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(pencil());
        await settleSheet(tester);

        expect(inSheet(find.text('Wound is clean')), findsOneWidget);
        expect(
          inSheet(find.text(en.doctorAppointmentNotesSave)),
          findsOneWidget,
        );
        final field = tester.widget<TextField>(inSheet(find.byType(TextField)));
        expect(field.autofocus, isFalse);
        expect(field.maxLines, greaterThan(1));
      });

      testWidgets('tapping the empty card opens the sheet too', (tester) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(find.text(en.doctorAppointmentNotesHint));
        await settleSheet(tester);

        expect(find.byType(TabibuBottomSheet), findsOneWidget);
      });

      testWidgets('Save sends the trimmed text and waits for the result', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(pencil());
        await settleSheet(tester);
        await tester.enterText(
          inSheet(find.byType(TextField)),
          '  Sentinel node in formalin  ',
        );
        await tester.pump();
        await tester.tap(inSheet(find.text(en.doctorAppointmentNotesSave)));
        await tester.pump();

        verify(
          () => blocs.cases.add(
            const CaseNotesSaveRequested(
              caseUid: 'case-1',
              clinicalNotes: 'Sentinel node in formalin',
            ),
          ),
        ).called(1);
        // Open until the bloc answers.
        expect(find.byType(TabibuBottomSheet), findsOneWidget);
      });

      testWidgets('Save is disabled while a write is in progress', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(pencil());
        await settleSheet(tester);
        await tester.enterText(inSheet(find.byType(TextField)), 'New text');
        await tester.pump();
        await tester.tap(inSheet(find.text(en.doctorAppointmentNotesSave)));
        await tester.pump();
        await emitCases(tester, CasesLoadSuccess(cases: [_case()]).toWriting());

        final save = inSheet(find.byType(TabibuButton));
        expect(tester.widget<TabibuButton>(save).onTap, isNull);
        expect(tester.widget<TabibuButton>(save).isLoading, isTrue);
      });

      testWidgets('the toast waits for the sheet to finish closing', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(pencil());
        await settleSheet(tester);
        await tester.enterText(inSheet(find.byType(TextField)), 'Saved text');
        await tester.pump();
        await tester.tap(inSheet(find.text(en.doctorAppointmentNotesSave)));
        await tester.pump();
        await emitCases(
          tester,
          CasesLoadSuccess(cases: [_case(notes: 'Saved text')]).toSaved(),
        );

        // Mid-slide: the notice has not opened.
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text(en.doctorAppointmentNotesSaved), findsNothing);

        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(TabibuBottomSheet), findsNothing);
        expect(find.text(en.doctorAppointmentNotesSaved), findsOneWidget);
        expect(find.text('Saved text'), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 300));
      });

      testWidgets('saving offline says the same calm thing', (tester) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(pencil());
        await settleSheet(tester);
        await tester.enterText(inSheet(find.byType(TextField)), 'Queued text');
        await tester.pump();
        await tester.tap(inSheet(find.text(en.doctorAppointmentNotesSave)));
        await tester.pump();
        // The helper queues the edit and answers with the edited case.
        await emitCases(
          tester,
          CaseNotesSaveSuccess(
            cases: [_case(notes: 'Queued text')],
            offline: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text(en.doctorAppointmentNotesSaved), findsOneWidget);
        expect(find.text(AppError.noInternet.description(en)), findsNothing);
        expect(find.text(en.doctorAppointmentNotesFailed), findsNothing);

        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 300));
      });

      testWidgets('a failure keeps the sheet, the text and offers a retry', (
        tester,
      ) async {
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(pencil());
        await settleSheet(tester);
        await tester.enterText(inSheet(find.byType(TextField)), 'Draft notes');
        await tester.pump();
        await tester.tap(inSheet(find.text(en.doctorAppointmentNotesSave)));
        await tester.pump();
        await emitCases(
          tester,
          CaseWriteFailure(error: AppError.permissionDenied, cases: [_case()]),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text(en.doctorAppointmentNotesFailed), findsOneWidget);
        expect(find.byType(TabibuBottomSheet), findsOneWidget);
        expect(inSheet(find.text('Draft notes')), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 300));
        final save = inSheet(find.byType(TabibuButton));
        expect(tester.widget<TabibuButton>(save).onTap, isNotNull);
      });

      testWidgets('unchanged text closes without a write', (tester) async {
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: CasesLoadSuccess(cases: [_case(notes: 'Same')]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        await tester.tap(pencil());
        await settleSheet(tester);
        await tester.tap(inSheet(find.text(en.doctorAppointmentNotesSave)));
        await settleSheet(tester);
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(TabibuBottomSheet), findsNothing);
        verifyNever(
          () => blocs.cases.add(any(that: isA<CaseNotesSaveRequested>())),
        );
        expect(find.text(en.doctorAppointmentNotesSaved), findsNothing);
      });

      testWidgets('2,000 characters fit the sheet and the card, no more', (
        tester,
      ) async {
        final long = List.filled(2000, 'a').join();
        register(
          appointments: AppointmentsLoadSuccess(appointments: [_appointment()]),
          cases: CasesLoadSuccess(cases: [_case(notes: long)]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);
        expect(tester.takeException(), isNull);
        expect(find.text(long), findsOneWidget);

        await tester.tap(pencil());
        await settleSheet(tester);
        await tester.enterText(inSheet(find.byType(TextField)), '$long-extra');
        await tester.pump();

        final field = tester.widget<TextField>(inSheet(find.byType(TextField)));
        expect(field.controller!.text.length, 2000);
        expect(tester.takeException(), isNull);
      });
    });

    group('layout', () {
      testWidgets('a very long patient name never overflows', (tester) async {
        register(
          appointments: AppointmentsLoadSuccess(
            appointments: [
              _appointment(
                name:
                    'Wanjiru Mwangi-Kamau Achieng Njeri Otieno Odhiambo '
                    'Achieng Njeri Otieno Odhiambo Wanjiru',
              ),
            ],
          ),
          cases: CasesLoadSuccess(cases: [_case()]),
        );
        _useTallSurface(tester);
        await pumpScreen(tester);

        expect(tester.takeException(), isNull);
        expect(find.byType(PatientCard), findsOneWidget);
      });

      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        for (final variantB in [false, true]) {
          testWidgets('Swahili at 1.3x on 390 dp, ${mode.name}, '
              '${variantB ? 'first visit' : 'with a case'}', (tester) async {
            _useTallSurface(tester);
            tester.platformDispatcher.textScaleFactorTestValue = 1.3;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            if (variantB) {
              register(
                appointments: AppointmentsLoadSuccess(
                  appointments: [_appointment(caseUids: const [])],
                ),
              );
            }
            await pumpScreen(
              tester,
              themeMode: mode,
              locale: const Locale('sw'),
            );

            expect(tester.takeException(), isNull);
            expect(find.text(sw.doctorAppointmentEnd), findsOneWidget);
            expect(find.text(sw.doctorAppointmentOrderTest), findsOneWidget);
            if (!variantB) {
              expect(find.byType(CaseStepper), findsOneWidget);
              await tester.tap(pencil());
              await settleSheet(tester);
              expect(tester.takeException(), isNull);
            }
          });
        }
      }
    });
  });
}

extension on CasesLoadSuccess {
  CaseWriteInProgress toWriting() =>
      CaseWriteInProgress(cases: cases, offline: offline);

  CaseNotesSaveSuccess toSaved() =>
      CaseNotesSaveSuccess(cases: cases, offline: offline);
}
