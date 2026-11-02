import 'dart:async';

import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_event.dart';
import 'package:tabibu/features/alerts/blocs/alert_review_bloc/alert_review_state.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/widgets/appointment_hero_card.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_timeline.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/home/presentation/doctor_home_screen.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PractitionerSession _session({bool approver = false}) {
  final base = RoleSessions.doctor(isAlertApprover: approver);
  return PractitionerSession(
    doctor: base.doctor.copyWith(uid: 'doctor-1'),
    roles: base.roles,
  );
}

/// Phone-width, very tall surface so the lazily-built sliver list mounts
/// every row and below-fold taps hit.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Nairobi "now" cut to the minute, so every offset below is whole minutes.
DateTime _base() {
  final now = nairobiNow();
  return DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);
}

/// The day plan reaches 100 minutes back and 90 ahead; near midnight it would
/// spill into another Nairobi day, so those tests stand down.
bool _dayHasRoom() {
  final now = nairobiNow();
  final minutes = now.hour * 60 + now.minute;
  return minutes >= 105 && minutes <= 24 * 60 - 95;
}

/// The instant the server stores for [minutes] from [base] (Nairobi time).
String _at(DateTime base, int minutes) => base
    .add(Duration(minutes: minutes))
    .subtract(nairobiOffset)
    .toIso8601String();

String _clock(DateTime base, int minutes, [String language = 'en']) =>
    DateFormat('h:mm a', language).format(base.add(Duration(minutes: minutes)));

AppointmentModel _appointment({
  required String uid,
  required DateTime base,
  required int from,
  required int to,
  String patient = 'Amina Wambui',
  String status = 'Accepted',
  String discussedCaseUid = '',
  String createdAt = '',
}) => AppointmentModel(
  uid: uid,
  status: status,
  patientName: patient,
  doctorUid: 'doctor-1',
  discussedCaseUid: discussedCaseUid,
  scheduledStart: _at(base, from),
  scheduledEnd: _at(base, to),
  createdAt: createdAt,
);

CaseModel _case({
  required String uid,
  String resultState = 'WithDoctor',
  String patientName = 'Amina Wambui',
  String testName = 'Lymph node',
  int age = 46,
}) => CaseModel(
  uid: uid,
  resultState: resultState,
  patientName: patientName,
  patientAgeYears: age,
  tests: [OrderedTestModel(name: testName)],
);

NotificationModel _request(String uid, {String status = 'Unread'}) =>
    NotificationModel(
      uid: uid,
      templateKey: 'appointmentRequested',
      status: status,
    );

AlertModel _alert(String uid, String drafted, {String county = 'Embakasi'}) =>
    AlertModel(
      uid: uid,
      status: 'Draft',
      countyName: county,
      draftedAt: drafted,
    );

void main() {
  group('DoctorHomeScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    });

    Widget screen({Key? key}) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        ...blocs.providers,
      ],
      child: DoctorHomeScreen(key: key),
    );

    void stub({
      List<AppointmentModel> appointments = const [],
      List<CaseModel> cases = const [],
      List<AlertModel> queue = const [],
      NotificationsState? inbox,
      bool offline = false,
    }) {
      when(
        () => blocs.notifications.state,
      ).thenReturn(inbox ?? NotificationsLoadSuccess(offline: offline));
      when(() => blocs.appointments.state).thenReturn(
        AppointmentsLoadSuccess(appointments: appointments, offline: offline),
      );
      when(
        () => blocs.cases.state,
      ).thenReturn(CasesLoadSuccess(cases: cases, offline: offline));
      when(
        () => blocs.alertReview.state,
      ).thenReturn(AlertReviewLoadSuccess(queue: queue));
    }

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (_, _) => screen()),
          GoRoute(
            path: '/doctor/notifications',
            builder: (_, _) => const Text('stub notifications'),
          ),
          GoRoute(
            path: '/doctor/reports-ready',
            builder: (_, _) => const Text('stub reports ready'),
          ),
          GoRoute(
            path: '/doctor/booking-requests',
            builder: (_, _) => const Text('stub bookings'),
          ),
          GoRoute(
            path: '/doctor/appointment/:appointmentUid',
            builder: (_, state) => Text(
              'stub appointment ${state.pathParameters['appointmentUid']}',
            ),
          ),
          GoRoute(
            path: '/doctor/alert/:alertUid',
            builder: (_, state) =>
                Text('stub alert ${state.pathParameters['alertUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    Future<void> pumpScreen(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
    }) async {
      await tester.pumpRouterApp(
        router(),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.pumpAndSettle();
    }

    /// Done 100 to 70 minutes ago, now -5 to +25, next +60 to +90: a free gap
    /// before the now card and another before the last.
    List<AppointmentModel> fullDay(DateTime base) => [
      _appointment(
        uid: 'a-next',
        base: base,
        from: 60,
        to: 90,
        patient: 'Lucy Achieng',
        createdAt: _at(base, -24 * 60),
      ),
      _appointment(
        uid: 'a-done',
        base: base,
        from: -100,
        to: -70,
        patient: 'Mary Njeri',
      ),
      _appointment(
        uid: 'a-now',
        base: base,
        from: -5,
        to: 25,
        discussedCaseUid: 'case-1',
      ),
      _appointment(
        uid: 'a-yesterday',
        base: base,
        from: -24 * 60,
        to: -24 * 60 + 30,
        patient: 'Peter Kiprono',
      ),
      _appointment(
        uid: 'a-request',
        base: base,
        from: 120,
        to: 150,
        patient: 'Grace Atieno',
        status: 'Requested',
      ),
    ];

    testWidgets('asks only for what a non-approver may read', (tester) async {
      stub();
      await tester.pumpApp(screen());
      await tester.pump();

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
      verify(
        () => blocs.notifications.add(
          const NotificationsRequested(uid: 'doctor-1'),
        ),
      ).called(1);
      verifyNever(() => blocs.alertReview.add(const AlertQueueRequested()));
    });

    testWidgets('an approver also asks for the alert queue', (tester) async {
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: _session(approver: true)));
      stub();
      await tester.pumpApp(screen());
      await tester.pump();

      verify(
        () => blocs.alertReview.add(const AlertQueueRequested()),
      ).called(1);
    });

    testWidgets('headline counts today and reports ready from the data', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: fullDay(base),
        cases: [
          _case(uid: 'case-1'),
          _case(uid: 'case-2', resultState: 'UpdateWithDoctor'),
          _case(uid: 'case-3', resultState: 'Released'),
        ],
      );
      await pumpScreen(tester);

      expect(find.text('Hi, Dr. Kamau'), findsOneWidget);
      expect(find.text('3 appointments today.'), findsOneWidget);
      expect(find.text('2 reports ready.'), findsOneWidget);
      expect(find.text('Your day'), findsOneWidget);
      expect(find.text('Calendar'), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(Fab), findsNothing);
    });

    testWidgets('the now card names the appointment under way', (tester) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: fullDay(base),
        cases: [_case(uid: 'case-1')],
      );
      await pumpScreen(tester);

      expect(find.text('Now · ${_clock(base, -5)}'), findsOneWidget);
      expect(find.text('Appointment 2 of 3'), findsOneWidget);
      expect(find.text('Amina Wambui, 46'), findsOneWidget);
      expect(find.text('Lymph node · report signed'), findsOneWidget);
      expect(find.text('Open report and start'), findsOneWidget);
      expect(find.text('Start appointment'), findsNothing);
    });

    testWidgets('without a signed report the button starts the appointment', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(appointments: fullDay(base));
      await pumpScreen(tester);

      expect(find.text('Start appointment'), findsOneWidget);
      expect(find.text('Open report and start'), findsNothing);
    });

    testWidgets('with nothing under way the card is the next appointment', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(appointments: fullDay(base)..removeWhere((a) => a.uid == 'a-now'));
      await pumpScreen(tester);

      expect(find.textContaining('Now ·'), findsNothing);
      // The next card has the time as its eyebrow; the timeline shows it too.
      expect(find.text(_clock(base, 60)), findsWidgets);
      expect(find.text('Appointment 2 of 2'), findsOneWidget);
      expect(find.byType(AppointmentHeroCard), findsOneWidget);
      expect(find.byType(Fab), findsNothing);
      // The hero names no chat and no secondary action.
      expect(
        tester
            .widget<AppointmentHeroCard>(find.byType(AppointmentHeroCard))
            .secondary,
        isNull,
      );
    });

    testWidgets('the timeline marks done, now and upcoming, with free gaps', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(appointments: fullDay(base));
      await pumpScreen(tester);

      final entries = tester
          .widget<DayTimeline>(find.byType(DayTimeline))
          .entries;
      expect(entries.map((e) => e.state).toList(), [
        TimelineEntryState.done,
        TimelineEntryState.free,
        TimelineEntryState.now,
        TimelineEntryState.free,
        TimelineEntryState.upcoming,
      ]);
      expect(entries[1].title, 'Free · 65 min');
      expect(entries[1].subtitle, 'Good time to read reports');
      expect(entries[3].title, 'Free · 35 min');
      expect(entries[0].title, 'Mary Njeri');
      expect(entries[2].nowLabel, 'Now');
      expect(entries[4].title, 'Lucy Achieng');
      expect(entries[4].subtitle, startsWith('booked '));
      expect(find.text('Free · 65 min'), findsOneWidget);
      expect(find.text('Good time to read reports'), findsNWidgets(2));
      // Yesterday's and a still-requested booking are not on today's rail.
      expect(find.text('Peter Kiprono'), findsNothing);
      expect(find.text('Grace Atieno'), findsNothing);
    });

    testWidgets('a gap under 30 minutes is not shown', (tester) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: [
          _appointment(uid: 'a-1', base: base, from: -5, to: 25),
          _appointment(
            uid: 'a-2',
            base: base,
            from: 50,
            to: 80,
            patient: 'Lucy Achieng',
          ),
        ],
      );
      await pumpScreen(tester);

      final entries = tester
          .widget<DayTimeline>(find.byType(DayTimeline))
          .entries;
      expect(entries.map((e) => e.state), [
        TimelineEntryState.now,
        TimelineEntryState.upcoming,
      ]);
    });

    testWidgets('a timeline card opens its appointment', (tester) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(appointments: fullDay(base));
      await pumpScreen(tester);

      await tester.tap(find.text('Lucy Achieng'));
      await tester.pumpAndSettle();

      expect(find.text('stub appointment a-next'), findsOneWidget);
    });

    testWidgets('the hero button opens the current appointment', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(appointments: fullDay(base));
      await pumpScreen(tester);

      await tester.tap(find.text('Start appointment'));
      await tester.pumpAndSettle();

      expect(find.text('stub appointment a-now'), findsOneWidget);
    });

    testWidgets('a non-approver gets two tiles and no alert tile', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: fullDay(base),
        cases: [_case(uid: 'case-1')],
        // Even a queue that somehow reached the bloc stays hidden.
        queue: [_alert('alert-1', '2026-10-30T08:00:00Z')],
      );
      await pumpScreen(tester);

      expect(find.text('Needs you'), findsOneWidget);
      expect(find.byType(ShortcutBento), findsNothing);
      expect(find.byType(ShortcutTile), findsNWidgets(2));
      expect(find.text('Reports ready'), findsOneWidget);
      expect(find.text('Booking requests'), findsOneWidget);
      expect(find.text('Alert to approve'), findsNothing);
      verifyNever(() => blocs.alertReview.add(const AlertQueueRequested()));
    });

    testWidgets('the tiles show their counts and open their screens', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: fullDay(base),
        cases: [_case(uid: 'case-1')],
      );
      await pumpScreen(tester);

      expect(find.text('1 new today'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.text('Booking requests'));
      await tester.pumpAndSettle();
      expect(find.text('stub bookings'), findsOneWidget);
    });

    testWidgets('the reports tile opens the reports ready list', (
      tester,
    ) async {
      _useTallSurface(tester);
      stub(cases: [_case(uid: 'case-1')]);
      await pumpScreen(tester);

      await tester.tap(find.text('Reports ready').last);
      await tester.pumpAndSettle();

      expect(find.text('stub reports ready'), findsOneWidget);
    });

    testWidgets('an approver sees the alert tile for the oldest draft', (
      tester,
    ) async {
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: _session(approver: true)));
      _useTallSurface(tester);
      stub(
        cases: [_case(uid: 'case-1')],
        queue: [
          _alert('alert-new', '2026-10-31T08:00:00Z', county: 'Kisumu'),
          _alert('alert-old', '2026-10-29T08:00:00Z'),
        ],
      );
      await pumpScreen(tester);

      expect(find.byType(ShortcutBento), findsOneWidget);
      expect(find.text('Alert to approve'), findsOneWidget);
      expect(find.text('2 new'), findsOneWidget);
      expect(find.text('Embakasi'), findsOneWidget);

      await tester.tap(find.text('Alert to approve'));
      await tester.pumpAndSettle();

      expect(find.text('stub alert alert-old'), findsOneWidget);
    });

    testWidgets('an approver with an empty queue gets no alert tile', (
      tester,
    ) async {
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: _session(approver: true)));
      _useTallSurface(tester);
      stub(cases: [_case(uid: 'case-1')]);
      await pumpScreen(tester);

      expect(find.text('Alert to approve'), findsNothing);
      expect(find.byType(ShortcutBento), findsNothing);
      expect(find.byType(ShortcutTile), findsNWidgets(2));
    });

    testWidgets('the bell opens notifications and announces unread', (
      tester,
    ) async {
      stub(inbox: const NotificationsLoadSuccess(unread: 2));
      await pumpScreen(tester);

      final bell = find.byWidgetPredicate(
        (w) =>
            w is CircleIconButton && w.semanticLabel == 'Notifications, unread',
      );
      expect(bell, findsOneWidget);

      await tester.tap(bell);
      await tester.pumpAndSettle();

      expect(find.text('stub notifications'), findsOneWidget);
    });

    group('a new booking request', () {
      late StreamController<NotificationsState> inbox;

      setUp(() {
        inbox = StreamController<NotificationsState>.broadcast();
        addTearDown(inbox.close);
      });

      void emit(NotificationsState state) {
        when(() => blocs.notifications.state).thenReturn(state);
        inbox.add(state);
      }

      void listenFrom(NotificationsState initial) {
        stub(inbox: initial);
        whenListen(blocs.notifications, inbox.stream, initialState: initial);
      }

      const refresh = AppointmentsRefreshed(uid: 'doctor-1', role: Role.doctor);

      testWidgets('refreshes the appointments', (tester) async {
        listenFrom(NotificationsLoadSuccess(items: [_request('n-1')]));
        await pumpScreen(tester);
        verifyNever(() => blocs.appointments.add(refresh));

        emit(
          NotificationsLoadSuccess(
            items: [_request('n-2'), _request('n-1')],
            unread: 2,
          ),
        );
        await tester.pumpAndSettle();

        verify(() => blocs.appointments.add(refresh)).called(1);
      });

      testWidgets('what was already unread on open does not refresh', (
        tester,
      ) async {
        listenFrom(const NotificationsInitial());
        await pumpScreen(tester);

        emit(const NotificationsLoadInProgress());
        emit(NotificationsLoadSuccess(items: [_request('n-1')], unread: 1));
        await tester.pumpAndSettle();

        verifyNever(() => blocs.appointments.add(refresh));

        emit(
          NotificationsLoadSuccess(
            items: [_request('n-2'), _request('n-1')],
            unread: 2,
          ),
        );
        await tester.pumpAndSettle();

        verify(() => blocs.appointments.add(refresh)).called(1);
      });

      testWidgets('reading or another kind of row does not refresh', (
        tester,
      ) async {
        listenFrom(NotificationsLoadSuccess(items: [_request('n-1')]));
        await pumpScreen(tester);

        emit(
          NotificationsLoadSuccess(items: [_request('n-1', status: 'Read')]),
        );
        emit(
          const NotificationsLoadSuccess(
            items: [NotificationModel(uid: 'n-9', templateKey: 'orderCreated')],
            unread: 1,
          ),
        );
        await tester.pumpAndSettle();

        verifyNever(() => blocs.appointments.add(refresh));
      });
    });

    testWidgets('no appointments and no reports shows the empty state', (
      tester,
    ) async {
      stub();
      await pumpScreen(tester);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No appointments yet'), findsOneWidget);
      expect(
        find.text(
          'Patients near Aga Khan University Hospital can find you now. '
          'New bookings show here.',
        ),
        findsOneWidget,
      );
      expect(find.byType(TwoToneHeadline), findsNothing);
      expect(find.byType(ShortcutTile), findsNothing);
      expect(find.byType(Fab), findsNothing);
      expect(find.text('Hi, Dr. Kamau'), findsOneWidget);
    });

    testWidgets('a pending booking keeps the tiles within reach', (
      tester,
    ) async {
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: [
          _appointment(
            uid: 'a-request',
            base: base,
            from: 600,
            to: 630,
            status: 'Requested',
          ),
        ],
      );
      await pumpScreen(tester);

      expect(find.byType(EmptyState), findsNothing);
      expect(find.text('Booking requests'), findsOneWidget);
    });

    testWidgets('loading shows the spinner under the header', (tester) async {
      when(
        () => blocs.appointments.state,
      ).thenReturn(const AppointmentsLoadInProgress());
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.byType(LoadingView), findsOneWidget);
      expect(
        find.bySemanticsLabel(l10n.doctorHomeLoadingLabel),
        findsOneWidget,
      );
      expect(find.text('Hi, Dr. Kamau'), findsOneWidget);
      expect(find.byType(TwoToneHeadline), findsNothing);
      expect(find.byType(EmptyState), findsNothing);
    });

    testWidgets('offline shows the banner, keeps the day, and retries', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: fullDay(base),
        cases: [_case(uid: 'case-1')],
        offline: true,
      );
      await pumpScreen(tester);

      expect(find.text("You're offline"), findsOneWidget);
      expect(
        find.textContaining("Today's schedule and notes saved at"),
        findsOneWidget,
      );
      expect(find.text('3 appointments today.'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      verify(
        () => blocs.notifications.add(
          const NotificationsRefreshed(uid: 'doctor-1'),
        ),
      ).called(1);
      verify(
        () => blocs.appointments.add(
          const AppointmentsRefreshed(uid: 'doctor-1', role: Role.doctor),
        ),
      ).called(1);
      verify(
        () => blocs.cases.add(
          const CasesRefreshed(uid: 'doctor-1', role: Role.doctor),
        ),
      ).called(1);
    });

    testWidgets('renders in light and dark with ink text on the hero pill', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      stub(
        appointments: fullDay(base),
        cases: [_case(uid: 'case-1')],
      );
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpRouterApp(router(), themeMode: mode);
        await tester.pumpAndSettle();

        expect(find.byType(DoctorHomeScreen), findsOneWidget);
        final label = tester.widget<Text>(find.text('Open report and start'));
        expect(label.style?.color, AppColors.inkLight);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('renders in Swahili', (tester) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      final base = _base();
      final sw = lookupAppLocalizations(const Locale('sw'));
      stub(
        appointments: fullDay(base),
        cases: [_case(uid: 'case-1')],
      );
      await pumpScreen(tester, locale: const Locale('sw'));

      expect(find.text(sw.doctorHomeAppointmentsToday(3)), findsOneWidget);
      expect(find.text(sw.doctorHomeReportsReady(1)), findsOneWidget);
      expect(find.text(sw.doctorHomeYourDay), findsOneWidget);
      expect(find.text(sw.doctorHomeNeedsYou), findsOneWidget);
      expect(find.text(sw.doctorHomeFreeGap(65)), findsOneWidget);
      expect(find.text(sw.doctorHomeNow), findsOneWidget);
    });

    testWidgets('grows at 1.3x in Swahili and dark without overflow', (
      tester,
    ) async {
      if (!_dayHasRoom()) return;
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: _session(approver: true)));
      final base = _base();
      stub(
        appointments: fullDay(base),
        cases: [_case(uid: 'case-1')],
        queue: [_alert('alert-1', '2026-10-30T08:00:00Z')],
      );
      await pumpScreen(
        tester,
        themeMode: ThemeMode.dark,
        locale: const Locale('sw'),
      );

      expect(find.byType(ShortcutBento), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
