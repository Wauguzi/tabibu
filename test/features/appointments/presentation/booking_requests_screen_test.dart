import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/booking_requests_screen.dart';
import 'package:tabibu/features/appointments/presentation/widgets/booking_request_card.dart';
import 'package:tabibu/features/appointments/presentation/widgets/decline_booking_sheet.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

// Mon 2 Nov, 11:15 AM Nairobi.
const _esther = '2026-11-02T08:15:00Z';
// Tue 3 Nov, 9:45 AM Nairobi.
const _peter = '2026-11-03T06:45:00Z';

AppointmentModel _appointment(
  String uid,
  String name,
  String start, {
  String status = 'Requested',
  String symptoms = '',
}) => AppointmentModel(
  uid: uid,
  status: status,
  patientName: name,
  doctorUid: 'doctor-1',
  scheduledStart: start,
  symptomText: symptoms,
);

PractitionerSession _session() {
  final base = RoleSessions.doctor();
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: 'doctor-1'),
    roles: base.roles,
  );
}

/// The card's second line: the day, the clock in Nairobi time, and the
/// appointment type in the screen's language.
String _when(String iso, [String language = 'en']) {
  final time = nairobiTimeOf(iso)!;
  final type = lookupAppLocalizations(
    Locale(language),
  ).appointmentsTypeConsultation;
  return '${DateFormat('EEE d MMM', language).format(time)} · '
      '${DateFormat('h:mm a', language).format(time)} · $type';
}

String _clock(String iso, [String language = 'en']) =>
    DateFormat('h:mm a', language).format(nairobiTimeOf(iso)!);

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// A sheet opens and closes on animations that never settle under a spinner.
Future<void> settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final sw = lookupAppLocalizations(const Locale('sw'));

  setUpAll(() => registerFallbackValue(const AppointmentsReset()));

  group('BookingRequestsScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;
    late StreamController<AppointmentsState> states;
    late List<AppointmentModel> rows;

    void register(AppointmentsState initial) {
      when(() => blocs.appointments.state).thenReturn(initial);
      when(() => blocs.appointments.stream).thenAnswer((_) => states.stream);
    }

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      states = StreamController<AppointmentsState>.broadcast();
      addTearDown(states.close);
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
      rows = [
        _appointment(
          'a-peter',
          'Peter Mwangi',
          _peter,
          symptoms: 'Prefers mornings',
        ),
        _appointment('a-esther', 'Esther Achieng', _esther),
        _appointment('a-lucy', 'Lucy Njeri', _esther, status: 'Accepted'),
      ];
      register(AppointmentsLoadSuccess(appointments: rows));
    });

    /// Delivers [state] and the frame it causes. The stream delivers on the
    /// event queue, so the queue is drained, not hopped a set number of times.
    Future<void> emit(WidgetTester tester, AppointmentsState state) async {
      when(() => blocs.appointments.state).thenReturn(state);
      states.add(state);
      await tester.runAsync(pumpEventQueue);
      await tester.pump();
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      await tester.pumpApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            ...blocs.providers,
          ],
          child: const BookingRequestsScreen(),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pump();
    }

    Finder inSheet(Finder matching) =>
        find.descendant(of: find.byType(TabibuBottomSheet), matching: matching);

    Finder declineOf(String name) => find.descendant(
      of: find.ancestor(
        of: find.text(name),
        matching: find.byType(BookingRequestCard),
      ),
      matching: find.widgetWithText(TabibuButton, en.bookingRequestsDecline),
    );

    Finder acceptOf(String name) => find.descendant(
      of: find.ancestor(
        of: find.text(name),
        matching: find.byType(BookingRequestCard),
      ),
      matching: find.widgetWithText(TabibuButton, en.bookingRequestsAccept),
    );

    BookingRequestCard cardOf(WidgetTester tester, String name) =>
        tester.widget<BookingRequestCard>(
          find.ancestor(
            of: find.text(name),
            matching: find.byType(BookingRequestCard),
          ),
        );

    testWidgets('asks for the doctor’s appointments', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      verify(
        () => blocs.appointments.add(
          const AppointmentsRequested(uid: 'doctor-1', role: Role.doctor),
        ),
      ).called(1);
    });

    testWidgets('lists only requested, soonest first, with their details', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      expect(find.byType(BookingRequestCard), findsNWidgets(2));
      expect(find.text('Lucy Njeri'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Esther Achieng')).dy,
        lessThan(tester.getTopLeft(find.text('Peter Mwangi')).dy),
      );
      expect(find.text(en.bookingRequestsTitle), findsOneWidget);
      expect(find.text(en.bookingRequestsNewToday(2)), findsOneWidget);
      expect(find.text(_when(_esther)), findsOneWidget);
      expect(find.text(_when(_peter)), findsOneWidget);
      expect(find.text('Prefers mornings'), findsOneWidget);
      expect(find.text(en.bookingRequestsAccept), findsNWidgets(2));
      expect(find.text(en.bookingRequestsDecline), findsNWidgets(2));
      expect(find.text(en.bookingRequestsFootnote), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the request in Nairobi time, whatever the zone', (
      tester,
    ) async {
      _useTallSurface(tester);
      // 21:30 UTC on the 2nd is already 00:30 on the 3rd in Nairobi.
      rows = [_appointment('a-late', 'Late Night', '2026-11-02T21:30:00Z')];
      register(AppointmentsLoadSuccess(appointments: rows));
      await pumpScreen(tester);

      expect(
        find.text(
          'Tue 3 Nov · ${_clock('2026-11-02T21:30:00Z')} · Consultation',
        ),
        findsOneWidget,
      );
      expect(_clock('2026-11-02T21:30:00Z'), startsWith('12:30'));
    });

    testWidgets('Accept sends exactly the accept decision', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(acceptOf('Peter Mwangi'));
      await tester.pump();

      verify(
        () => blocs.appointments.add(
          const AppointmentDecisionRequested(
            appointmentUid: 'a-peter',
            accept: true,
          ),
        ),
      ).called(1);
    });

    testWidgets('94: a tap outside the decline note dismisses the keyboard', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(declineOf('Peter Mwangi'));
      await settleSheet(tester);

      final field = inSheet(find.byType(TextField));
      await tester.tap(field);
      await tester.pump();
      final node = tester.widget<TextField>(field).focusNode!;
      expect(node.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(
        inSheet(find.text(en.bookingRequestsDeclineTitle('Peter Mwangi'))),
      );
      await tester.pump();
      expect(node.hasPrimaryFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('Decline needs a reason before it can send', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(declineOf('Peter Mwangi'));
      await settleSheet(tester);

      expect(
        inSheet(find.text(en.bookingRequestsDeclineTitle('Peter Mwangi'))),
        findsOneWidget,
      );
      for (final label in [
        en.declineReasonSlotUnavailable,
        en.declineReasonOutsidePractice,
        en.declineReasonReferredElsewhere,
        en.declineReasonOther,
      ]) {
        expect(inSheet(find.text(label)), findsOneWidget);
      }
      expect(find.byType(OptionCard), findsNWidgets(4));
      final send = inSheet(
        find.widgetWithText(TabibuButton, en.bookingRequestsDeclineSend),
      );
      expect(tester.widget<TabibuButton>(send).onTap, isNull);

      await tester.tap(send);
      await settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsOneWidget);
      verifyNever(
        () => blocs.appointments.add(
          any(that: isA<AppointmentDecisionRequested>()),
        ),
      );
    });

    testWidgets('Decline sends the reason and the note', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(declineOf('Peter Mwangi'));
      await settleSheet(tester);
      await tester.tap(inSheet(find.text(en.declineReasonOutsidePractice)));
      await tester.pump();
      await tester.enterText(
        inSheet(find.byType(TextField)),
        '  Try Dr. Ali  ',
      );
      await tester.pump();
      await tester.tap(inSheet(find.text(en.bookingRequestsDeclineSend)));
      await settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsNothing);
      verify(
        () => blocs.appointments.add(
          const AppointmentDecisionRequested(
            appointmentUid: 'a-peter',
            accept: false,
            reason: DeclineReason.outsidePractice,
            note: 'Try Dr. Ali',
          ),
        ),
      ).called(1);
    });

    testWidgets('Decline with no note sends an empty one', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(declineOf('Esther Achieng'));
      await settleSheet(tester);
      await tester.tap(inSheet(find.text(en.declineReasonOther)));
      await tester.pump();
      await tester.tap(inSheet(find.text(en.bookingRequestsDeclineSend)));
      await settleSheet(tester);

      verify(
        () => blocs.appointments.add(
          const AppointmentDecisionRequested(
            appointmentUid: 'a-esther',
            accept: false,
            reason: DeclineReason.other,
          ),
        ),
      ).called(1);
    });

    testWidgets('offers the server’s four reasons, never slotTaken', (
      tester,
    ) async {
      _useTallSurface(tester);
      final seen = <DeclineReason>[];
      await pumpScreen(tester);
      for (final label in [
        en.declineReasonSlotUnavailable,
        en.declineReasonOutsidePractice,
        en.declineReasonReferredElsewhere,
        en.declineReasonOther,
      ]) {
        clearInteractions(blocs.appointments);
        await tester.tap(declineOf('Peter Mwangi'));
        await settleSheet(tester);
        await tester.tap(inSheet(find.text(label)));
        await tester.pump();
        await tester.tap(inSheet(find.text(en.bookingRequestsDeclineSend)));
        await settleSheet(tester);
        final sent =
            verify(
                  () => blocs.appointments.add(
                    captureAny(that: isA<AppointmentDecisionRequested>()),
                  ),
                ).captured.single
                as AppointmentDecisionRequested;
        seen.add(sent.reason!);
      }

      expect(seen, [
        DeclineReason.slotUnavailable,
        DeclineReason.outsidePractice,
        DeclineReason.referredElsewhere,
        DeclineReason.other,
      ]);
    });

    testWidgets('holds the note to 200 characters', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(declineOf('Peter Mwangi'));
      await settleSheet(tester);
      final field = inSheet(find.byType(TextField));
      await tester.enterText(field, 'a' * declineNoteMaxLength);
      await tester.pump();
      expect(
        tester.widget<TextField>(field).controller!.text.length,
        declineNoteMaxLength,
      );

      await tester.enterText(field, 'a' * (declineNoteMaxLength + 50));
      await tester.pump();
      expect(
        tester.widget<TextField>(field).controller!.text.length,
        declineNoteMaxLength,
      );
    });

    testWidgets('Dismissing the sheet sends nothing', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(declineOf('Peter Mwangi'));
      await settleSheet(tester);
      await tester.binding.handlePopRoute();
      await settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsNothing);
      verifyNever(
        () => blocs.appointments.add(
          any(that: isA<AppointmentDecisionRequested>()),
        ),
      );
    });

    testWidgets('marks only the card being written as busy', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(acceptOf('Peter Mwangi'));
      await emit(tester, AppointmentWriteInProgress(appointments: rows));

      expect(cardOf(tester, 'Peter Mwangi').busy, isTrue);
      expect(cardOf(tester, 'Esther Achieng').busy, isFalse);
      expect(
        tester.widget<TabibuButton>(declineOf('Peter Mwangi')).onTap,
        isNull,
      );
      expect(
        tester.widget<TabibuButton>(declineOf('Esther Achieng')).onTap,
        isNotNull,
      );

      await tester.tap(declineOf('Peter Mwangi'), warnIfMissed: false);
      await settleSheet(tester);
      expect(find.byType(TabibuBottomSheet), findsNothing);
    });

    testWidgets('an accepted request leaves the list and shows a strip', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(acceptOf('Peter Mwangi'));
      await emit(tester, AppointmentWriteInProgress(appointments: rows));
      final accepted = rows.first.copyWith(status: 'Accepted');
      await emit(
        tester,
        AppointmentDecisionSuccess(
          appointment: accepted,
          appointments: [accepted, ...rows.skip(1)],
        ),
      );

      expect(find.byType(BookingRequestCard), findsOneWidget);
      expect(find.text('Peter Mwangi'), findsNothing);
      expect(
        find.text(
          en.bookingRequestsAcceptedTitle(
            DateFormat('EEE d MMM').format(nairobiTimeOf(_peter)!),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(en.bookingRequestsAcceptedBody('Peter', _clock(_peter))),
        findsOneWidget,
      );
      expect(find.text(en.bookingRequestsNewToday(1)), findsOneWidget);
      expect(find.textContaining('Undo'), findsNothing);
      expect(find.byType(TextButton), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      expect(
        find.text(en.bookingRequestsAcceptedBody('Peter', _clock(_peter))),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.text(en.bookingRequestsAcceptedBody('Peter', _clock(_peter))),
        findsNothing,
      );
    });

    testWidgets('a declined request leaves the list with no strip', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      final declined = rows.first.copyWith(status: 'Declined');
      await emit(
        tester,
        AppointmentDecisionSuccess(
          appointment: declined,
          appointments: [declined, ...rows.skip(1)],
        ),
      );

      expect(find.byType(BookingRequestCard), findsOneWidget);
      expect(find.text('Peter Mwangi'), findsNothing);
      expect(find.textContaining('is confirmed'), findsNothing);
    });

    testWidgets('a failed write shows a toast and keeps the card', (
      tester,
    ) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      await tester.tap(acceptOf('Peter Mwangi'));
      await emit(tester, AppointmentWriteInProgress(appointments: rows));
      await emit(
        tester,
        AppointmentWriteFailure(error: AppError.noInternet, appointments: rows),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(AppError.noInternet.description(en)), findsOneWidget);
      expect(find.text('Peter Mwangi'), findsOneWidget);
      expect(cardOf(tester, 'Peter Mwangi').busy, isFalse);

      // The toast dismisses itself.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(AppError.noInternet.description(en)), findsNothing);
    });

    testWidgets('shows the empty state with no count line', (tester) async {
      _useTallSurface(tester);
      register(const AppointmentsLoadSuccess());
      await pumpScreen(tester);

      expect(find.text(en.bookingRequestsEmptyTitle), findsOneWidget);
      expect(find.text(en.bookingRequestsEmptyBody), findsOneWidget);
      expect(find.byType(BookingRequestCard), findsNothing);
      expect(find.text(en.bookingRequestsFootnote), findsNothing);
      expect(find.textContaining('new today'), findsNothing);
      expect(tester.widget<TopBar>(find.byType(TopBar)).subtitle, isNull);
    });

    testWidgets('is empty when nothing is still requested', (tester) async {
      _useTallSurface(tester);
      register(
        AppointmentsLoadSuccess(
          appointments: [
            _appointment('a-1', 'Lucy Njeri', _peter, status: 'Accepted'),
            _appointment('a-2', 'Joseph Kamau', _peter, status: 'Declined'),
          ],
        ),
      );
      await pumpScreen(tester);

      expect(find.text(en.bookingRequestsEmptyTitle), findsOneWidget);
    });

    testWidgets('announces loading while the first load runs', (tester) async {
      _useTallSurface(tester);
      register(const AppointmentsLoadInProgress());
      await pumpScreen(tester);

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text(en.bookingRequestsEmptyTitle), findsNothing);
    });

    testWidgets('keeps the cards on screen while a refresh loads', (
      tester,
    ) async {
      _useTallSurface(tester);
      register(AppointmentsLoadInProgress(appointments: rows));
      await pumpScreen(tester);

      expect(find.byType(LoadingView), findsNothing);
      expect(find.byType(BookingRequestCard), findsNWidgets(2));
    });

    testWidgets('has no suggest-another-time and no chat', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester);

      expect(find.textContaining('another time'), findsNothing);
      expect(find.textContaining('Suggest'), findsNothing);
      expect(find.textContaining('Chat'), findsNothing);
      expect(find.text('Speaks English'), findsNothing);
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      await pumpScreen(tester, locale: const Locale('sw'));

      expect(find.text(sw.bookingRequestsTitle), findsOneWidget);
      expect(find.text(sw.bookingRequestsNewToday(2)), findsOneWidget);
      expect(find.text(sw.bookingRequestsAccept), findsNWidgets(2));
      expect(find.text(sw.bookingRequestsDecline), findsNWidgets(2));
      expect(find.text(sw.bookingRequestsFootnote), findsOneWidget);
      expect(find.text(_when(_esther, 'sw')), findsOneWidget);
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('grows at 1.3x in Swahili, ${mode.name}, sheet open', (
        tester,
      ) async {
        _useTallSurface(tester);
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, themeMode: mode, locale: const Locale('sw'));

        expect(find.byType(BookingRequestCard), findsNWidgets(2));
        expect(tester.takeException(), isNull);

        await tester.tap(
          find.widgetWithText(TabibuButton, sw.bookingRequestsDecline).first,
        );
        await settleSheet(tester);

        expect(find.byType(OptionCard), findsNWidgets(4));
        expect(
          inSheet(find.text(sw.declineReasonSlotUnavailable)),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
