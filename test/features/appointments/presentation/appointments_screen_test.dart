import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/appointments_screen.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

/// Phone-width, very tall surface so the sliver list mounts every row.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// A Nairobi wall-clock time as the instant the server would store.
DateTime _nairobi({required int plusDays, required int hour, int minute = 0}) {
  final now = nairobiNow();
  final day = DateTime.utc(now.year, now.month, now.day);
  return DateTime.utc(
    day.year,
    day.month,
    day.day,
    hour,
    minute,
  ).add(Duration(days: plusDays)).subtract(nairobiOffset);
}

AppointmentModel _appointment({
  required String uid,
  required DateTime start,
  required String doctorName,
  String status = 'Accepted',
  String facilityName = 'Aga Khan',
}) => AppointmentModel(
  uid: uid,
  status: status,
  doctorName: doctorName,
  facilityName: facilityName,
  scheduledStart: start.toIso8601String(),
);

void main() {
  group('AppointmentsScreen', () {
    late MockAppointmentsBloc appointments;
    late MockAuthBloc authBloc;

    List<AppointmentModel> all() => [
      _appointment(
        uid: 'a-next',
        start: _nairobi(plusDays: 2, hour: 11, minute: 15),
        doctorName: 'Dr. Wanjiru Kamau',
      ),
      _appointment(
        uid: 'a-later',
        start: _nairobi(plusDays: 5, hour: 9),
        doctorName: 'Dr. James Otieno',
        facilityName: 'Mama Lucy',
      ),
      _appointment(
        uid: 'a-req',
        start: _nairobi(plusDays: 3, hour: 14),
        doctorName: 'Dr. Achieng Odhiambo',
        status: 'Requested',
      ),
      _appointment(
        uid: 'a-past1',
        start: _nairobi(plusDays: -10, hour: 10),
        doctorName: 'Dr. Grace Wambui',
        status: 'Completed',
      ),
      _appointment(
        uid: 'a-past2',
        start: _nairobi(plusDays: -40, hour: 10),
        doctorName: 'Dr. Mary Kamau',
      ),
      _appointment(
        uid: 'a-decl',
        start: _nairobi(plusDays: 1, hour: 10),
        doctorName: 'Dr. Amina Otieno',
        status: 'Declined',
      ),
      _appointment(
        uid: 'a-cancel',
        start: _nairobi(plusDays: -5, hour: 10),
        doctorName: 'Dr. Amina Kamau',
        status: 'Cancelled',
      ),
      _appointment(
        uid: 'a-exp',
        start: _nairobi(plusDays: 4, hour: 10),
        doctorName: 'Dr. Grace Otieno',
        status: 'Expired',
      ),
      _appointment(
        uid: 'a-missed',
        start: _nairobi(plusDays: -3, hour: 10),
        doctorName: 'Dr. Mary Otieno',
        status: 'NoShow',
      ),
    ];

    setUp(() {
      appointments = MockAppointmentsBloc();
      when(
        () => appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: all()));
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(
        SignInSuccess(
          session: PatientSession(
            patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
            roles: RoleSessions.patient.roles,
          ),
        ),
      );
    });

    Widget screen() => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AppointmentsBloc>.value(value: appointments),
      ],
      child: const AppointmentsScreen(),
    );

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/appointments-test',
        routes: [
          GoRoute(path: '/appointments-test', builder: (_, _) => screen()),
          GoRoute(
            path: '/patient/appointment/:appointmentUid',
            builder: (_, state) => Text(
              'stub appointment ${state.pathParameters['appointmentUid']}',
            ),
          ),
          GoRoute(
            path: '/patient/doctors',
            builder: (_, _) => const Text('stub doctors'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    double top(WidgetTester tester, String text) =>
        tester.getTopLeft(find.text(text)).dy;

    testWidgets('requests the patient appointments on open', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      verify(
        () => appointments.add(
          const AppointmentsRequested(uid: 'patient-1', role: Role.patient),
        ),
      ).called(1);
    });

    testWidgets('groups and orders upcoming and past', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Your appointments'), findsOneWidget);
      expect(find.text('3 coming up · 6 past'), findsOneWidget);

      // The hero is the soonest upcoming visit.
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Consultation · Aga Khan'), findsOneWidget);
      expect(
        find.text(
          DateFormat('EEE d MMM', 'en').format(
            _nairobi(plusDays: 2, hour: 11, minute: 15).add(nairobiOffset),
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('11:15 AM'), findsOneWidget);
      expect(find.text('View appointment'), findsOneWidget);

      // Further upcoming visits follow soonest first.
      expect(
        top(tester, 'Dr. Achieng Odhiambo'),
        lessThan(top(tester, 'Dr. James Otieno')),
      );
      expect(find.text('Waiting for the doctor'), findsOneWidget);

      // Past newest first, across statuses.
      expect(find.text('Past appointments'), findsOneWidget);
      final order = [
        'Dr. Grace Otieno',
        'Dr. Amina Otieno',
        'Dr. Mary Otieno',
        'Dr. Amina Kamau',
        'Dr. Grace Wambui',
        'Dr. Mary Kamau',
      ];
      for (var i = 0; i < order.length - 1; i++) {
        expect(
          top(tester, order[i]),
          lessThan(top(tester, order[i + 1])),
          reason: '${order[i]} above ${order[i + 1]}',
        );
      }
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Declined'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // A completed visit carries no chip.
      final completed = tester.widget<ListRowCard>(
        find.ancestor(
          of: find.text('Dr. Grace Wambui'),
          matching: find.byType(ListRowCard),
        ),
      );
      expect(completed.chip, isNull);
      expect(find.byType(Fab), findsOneWidget);
    });

    testWidgets('a requested hero shows the waiting chip', (tester) async {
      _useTallSurface(tester);
      when(() => appointments.state).thenReturn(
        AppointmentsLoadSuccess(
          appointments: [
            _appointment(
              uid: 'a-req',
              start: _nairobi(plusDays: 3, hour: 14),
              doctorName: 'Dr. Achieng Odhiambo',
              status: 'Requested',
            ),
          ],
        ),
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('1 coming up · 0 past'), findsOneWidget);
      expect(find.text('Waiting for the doctor'), findsOneWidget);
      expect(find.text('View appointment'), findsOneWidget);
    });

    testWidgets('nothing upcoming shows the book prompt', (tester) async {
      _useTallSurface(tester);
      when(() => appointments.state).thenReturn(
        AppointmentsLoadSuccess(
          appointments: [
            _appointment(
              uid: 'a-past1',
              start: _nairobi(plusDays: -10, hour: 10),
              doctorName: 'Dr. Grace Wambui',
              status: 'Completed',
            ),
          ],
        ),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.text('No upcoming appointments'), findsOneWidget);
      expect(find.text('When you book, it shows here.'), findsOneWidget);
      expect(find.byType(Fab), findsNothing);
      expect(find.text('Past appointments'), findsOneWidget);

      await tester.tap(find.text('Book an appointment'));
      await tester.pumpAndSettle();

      expect(find.text('stub doctors'), findsOneWidget);
    });

    testWidgets('the Fab opens the directory', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Fab));
      await tester.pumpAndSettle();

      expect(find.text('stub doctors'), findsOneWidget);
    });

    testWidgets('a row opens its detail', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dr. Grace Wambui'));
      await tester.pumpAndSettle();

      expect(find.text('stub appointment a-past1'), findsOneWidget);
    });

    testWidgets('loading with nothing cached shows the spinner', (
      tester,
    ) async {
      _useTallSurface(tester);
      when(
        () => appointments.state,
      ).thenReturn(const AppointmentsLoadInProgress());
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Your appointments'), findsOneWidget);
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(Fab), findsNothing);
    });

    testWidgets('renders in dark mode', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Your appointments'), findsOneWidget);
      expect(find.text('View appointment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AppointmentsScreen)),
      );
      expect(find.text(l10n.appointmentsTitle), findsOneWidget);
      expect(find.text(l10n.appointmentsSubtitle(3, 6)), findsOneWidget);
      expect(find.text(l10n.appointmentsPastTitle), findsOneWidget);
      expect(find.text(l10n.appointmentsViewAppointment), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Your appointments'), findsOneWidget);
      expect(find.text('View appointment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
