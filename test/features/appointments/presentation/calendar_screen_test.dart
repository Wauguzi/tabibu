import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/appointments/presentation/calendar_screen.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// A 03:30 Nairobi start on [day]: its UTC civil day can differ, which is
/// the point — the calendar groups by Nairobi, whatever the phone's zone.
AppointmentModel _appointment({
  required String uid,
  required String name,
  required DateTime day,
  String status = 'Accepted',
}) => AppointmentModel(
  uid: uid,
  status: status,
  doctorUid: 'd1',
  doctorName: name,
  patientName: 'Amina Njoroge',
  scheduledStart: DateTime.utc(
    day.year,
    day.month,
    day.day,
    3,
    30,
  ).subtract(nairobiOffset).toIso8601String(),
);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final sw = lookupAppLocalizations(const Locale('sw'));

  group('CalendarScreen', () {
    late MockAppointmentsBloc appointments;
    late MockAuthBloc authBloc;
    late DateTime today;
    late AppointmentModel early;
    late AppointmentModel other;

    setUp(() {
      final nairobi = nairobiNow();
      today = DateTime(nairobi.year, nairobi.month, nairobi.day);
      // 01:30 Nairobi today is still yesterday in UTC.
      early = _appointment(uid: 'a-early', name: 'Dr. Early Bird', day: today)
          .copyWith(
            scheduledStart: DateTime.utc(
              today.year,
              today.month,
              today.day,
              1,
              30,
            ).subtract(nairobiOffset).toIso8601String(),
          );
      // The tapped day stays in this month at either boundary.
      final otherDay = today.day == 1
          ? today.add(const Duration(days: 1))
          : today.subtract(const Duration(days: 1));
      other = _appointment(
        uid: 'a-other',
        name: 'Dr. Other Day',
        day: otherDay,
      );
      appointments = MockAppointmentsBloc();
      when(() => appointments.state).thenReturn(
        AppointmentsLoadSuccess(
          appointments: [
            early,
            other,
            _appointment(
              uid: 'a-cancelled',
              name: 'Dr. Cancelled Away',
              day: today,
              status: 'Cancelled',
            ),
          ],
        ),
      );
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
      child: const CalendarScreen(role: .patient),
    );

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/calendar-test',
        routes: [
          GoRoute(path: '/calendar-test', builder: (_, _) => screen()),
          GoRoute(
            path: '/patient/appointment/:appointmentUid',
            builder: (_, state) =>
                Text('stub appt ${state.pathParameters['appointmentUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    testWidgets('groups by Nairobi day, not the UTC day', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.text(en.calendarTitle), findsOneWidget);
      // 01:30 Nairobi today, though its UTC day is yesterday.
      expect(find.text('Dr. Early Bird'), findsOneWidget);
      expect(find.text('Dr. Other Day'), findsNothing);
      // Cancelled rows stay out of the month.
      expect(find.text('Dr. Cancelled Away'), findsNothing);
    });

    testWidgets('tapping a day shows that day', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      final otherDay = nairobiTimeOf(other.scheduledStart)!;
      await tester.tap(find.text('${otherDay.day}'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Other Day'), findsOneWidget);
      expect(find.text('Dr. Early Bird'), findsNothing);
    });

    testWidgets('tapping an upcoming row opens that appointment', (
      tester,
    ) async {
      _useTallSurface(tester);
      final future = nairobiNow().add(const Duration(hours: 3));
      final futureDay = DateTime(future.year, future.month, future.day);
      when(() => appointments.state).thenReturn(
        AppointmentsLoadSuccess(
          appointments: [
            AppointmentModel(
              uid: 'a-later',
              status: 'Accepted',
              doctorUid: 'd1',
              doctorName: 'Dr. Later Day',
              patientName: 'Amina Njoroge',
              scheduledStart: future.subtract(nairobiOffset).toIso8601String(),
            ),
          ],
        ),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      if (futureDay.month != today.month) {
        await tester.tap(find.byType(IconButton).at(1));
        await tester.pumpAndSettle();
      }
      if (futureDay != today) {
        await tester.tap(find.text('${futureDay.day}'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Dr. Later Day'));
      await tester.pumpAndSettle();

      expect(find.text('stub appt a-later'), findsOneWidget);
    });

    testWidgets('the month arrows move the grid, not the selection', (
      tester,
    ) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      final next = DateTime(today.year, today.month + 1);
      await tester.tap(find.byType(IconButton).at(1));
      await tester.pumpAndSettle();

      expect(find.text(DateFormat('MMMM y').format(next)), findsOneWidget);
      // The timeline still dates the selected day until another is tapped.
      expect(find.text('Dr. Early Bird'), findsOneWidget);
    });

    testWidgets('renders in Swahili, dark, at 1.3x text', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpRouterApp(
        router(),
        themeMode: .dark,
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text(sw.calendarTitle), findsOneWidget);
      expect(find.text('Dr. Early Bird'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
