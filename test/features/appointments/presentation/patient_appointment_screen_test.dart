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
import 'package:tabibu/features/appointments/presentation/patient_appointment_screen.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
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

PractitionerModel _doctor({
  required String uid,
  required String lastName,
  required String specialty,
}) => PractitionerModel(
  uid: uid,
  title: 'Dr.',
  firstName: 'Wanjiru',
  lastName: lastName,
  profilePictureUrl: '',
  isPathologist: false,
  specialties: [specialty],
  bio: '',
  facilityId: '',
  facilityMflCode: '',
  facilityName: 'Aga Khan',
  county: 'Nairobi',
  subCounty: 'Embakasi',
  geohash: '',
  isAvailable: true,
  appointmentsHandled: 0,
  ordersCreated: 0,
  reportsSigned: 0,
  lastUpdatedAt: '',
);

void main() {
  group('PatientAppointmentScreen', () {
    late MockAppointmentsBloc appointments;
    late MockDirectoryBloc directory;
    late MockAuthBloc authBloc;

    final start = DateTime.now().toUtc().add(const Duration(days: 2));
    late AppointmentModel upcoming;

    setUp(() {
      upcoming = AppointmentModel(
        uid: 'a-up',
        status: 'Accepted',
        doctorUid: 'd1',
        doctorName: 'Dr. Wanjiru Kamau',
        facilityName: 'Aga Khan',
        scheduledStart: start.toIso8601String(),
        symptomText: 'A lump for two weeks',
      );
      appointments = MockAppointmentsBloc();
      when(
        () => appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: [upcoming]));
      directory = MockDirectoryBloc();
      when(() => directory.state).thenReturn(
        DirectoryLoadSuccess(
          all: [
            _doctor(uid: 'd1', lastName: 'Kamau', specialty: 'General surgery'),
            _doctor(
              uid: 'd2',
              lastName: 'Otieno',
              specialty: 'General practice',
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

    Widget screen({String uid = 'a-up', bool moved = false}) =>
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<AppointmentsBloc>.value(value: appointments),
            BlocProvider<DirectoryBloc>.value(value: directory),
          ],
          child: PatientAppointmentScreen(appointmentUid: uid, moved: moved),
        );

    /// A sheet opens and closes on animations that never settle.
    Future<void> settleSheet(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    final en = lookupAppLocalizations(const Locale('en'));

    GoRouter router([String uid = 'a-up']) {
      final routes = GoRouter(
        initialLocation: '/appointment-test',
        routes: [
          GoRoute(
            path: '/appointment-test',
            builder: (_, _) => screen(uid: uid),
          ),
          GoRoute(
            path: '/patient/result/:caseUid',
            builder: (_, state) =>
                Text('stub result ${state.pathParameters['caseUid']}'),
          ),
          GoRoute(
            path: '/patient/calendar',
            builder: (_, _) => const Text('stub calendar'),
          ),
          GoRoute(
            path: '/patient/appointment/:appointmentUid/chat',
            builder: (_, state) =>
                Text('stub chat ${state.pathParameters['appointmentUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    String whenText([String language = 'en']) {
      final at = start.add(nairobiOffset);
      return '${DateFormat('EEE d MMM', language).format(at)} · '
          "${DateFormat('h:mm a', language).format(at)}";
    }

    testWidgets('an upcoming visit shows the checklist', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Consultation'), findsOneWidget);
      expect(find.text(whenText()), findsNWidgets(2));
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('General surgery · Aga Khan'), findsOneWidget);
      expect(find.text('Aga Khan'), findsOneWidget);
      expect(find.text('A lump for two weeks'), findsOneWidget);
      expect(find.text('Before you come'), findsOneWidget);
      expect(find.text('Arrive 10 minutes early'), findsOneWidget);
      expect(
        find.text('Bring your ID and any medicines you take'),
        findsOneWidget,
      );
      expect(find.text('You can bring someone with you'), findsOneWidget);
      expect(find.text('Appointment chat'), findsOneWidget);
      expect(find.text('See your results'), findsNothing);
    });

    testWidgets('bundle 51: the chat row opens the appointment chat', (
      tester,
    ) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appointment chat'));
      await tester.pumpAndSettle();

      expect(find.text('stub chat a-up'), findsOneWidget);
    });

    testWidgets('a past visit with a case links its results', (tester) async {
      _useTallSurface(tester);
      when(() => appointments.state).thenReturn(
        AppointmentsLoadSuccess(
          appointments: [
            AppointmentModel(
              uid: 'a-past',
              status: 'Completed',
              doctorUid: 'd2',
              doctorName: 'Dr. James Otieno',
              facilityName: 'Mama Lucy',
              scheduledStart: DateTime.now()
                  .toUtc()
                  .subtract(const Duration(days: 10))
                  .toIso8601String(),
              type: 'CaseDiscussion',
              discussedCaseUid: 'case-1',
            ),
          ],
        ),
      );
      await tester.pumpRouterApp(router('a-past'));
      await tester.pumpAndSettle();

      expect(find.text('Results discussion'), findsOneWidget);
      expect(find.text('Dr. James Otieno'), findsOneWidget);
      expect(find.text('Before you come'), findsNothing);

      await tester.tap(find.text('See your results'));
      await tester.pumpAndSettle();

      expect(find.text('stub result case-1'), findsOneWidget);
    });

    testWidgets('a past visit without a case shows no link', (tester) async {
      _useTallSurface(tester);
      when(() => appointments.state).thenReturn(
        AppointmentsLoadSuccess(
          appointments: [
            AppointmentModel(
              uid: 'a-past',
              status: 'Completed',
              doctorUid: 'd2',
              doctorName: 'Dr. James Otieno',
              facilityName: 'Mama Lucy',
              scheduledStart: DateTime.now()
                  .toUtc()
                  .subtract(const Duration(days: 10))
                  .toIso8601String(),
            ),
          ],
        ),
      );
      await tester.pumpApp(screen(uid: 'a-past'));
      await tester.pumpAndSettle();

      expect(find.text('See your results'), findsNothing);
      expect(find.text('Before you come'), findsNothing);
    });

    testWidgets('an unknown id syncs, then shows not found', (tester) async {
      _useTallSurface(tester);
      when(
        () => appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess());
      await tester.pumpApp(screen(uid: 'a-missing'));
      await tester.pumpAndSettle();

      verify(
        () => appointments.add(
          const AppointmentsRequested(uid: 'patient-1', role: Role.patient),
        ),
      ).called(1);
      expect(find.text('Appointment not found'), findsOneWidget);
      expect(find.text("This appointment isn't here."), findsOneWidget);
    });

    testWidgets('a missing appointment spins while syncing', (tester) async {
      _useTallSurface(tester);
      when(
        () => appointments.state,
      ).thenReturn(const AppointmentsLoadInProgress());
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Appointment not found'), findsNothing);
    });

    testWidgets('renders in dark mode', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(PatientAppointmentScreen)),
      );
      expect(find.text(l10n.appointmentsTypeConsultation), findsOneWidget);
      expect(find.text(whenText('sw')), findsNWidgets(2));
      expect(find.text(l10n.appointmentDetailBeforeYouCome), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an upcoming visit offers reschedule and cancel', (
      tester,
    ) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text(en.rescheduleButton), findsOneWidget);
      expect(find.text(en.cancelAppointmentConfirm), findsOneWidget);

      await tester.tap(find.text(en.rescheduleButton));
      await settleSheet(tester);

      expect(find.byType(TabibuBottomSheet), findsOneWidget);
      expect(find.text(en.rescheduleTitle), findsOneWidget);

      Navigator.of(tester.element(find.byType(TabibuBottomSheet))).pop();
      await settleSheet(tester);
    });

    testWidgets('confirming the cancel sends it with the reason', (
      tester,
    ) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text(en.cancelAppointmentConfirm));
      await settleSheet(tester);
      await tester.tap(find.text(en.cancelAppointmentReasonBetter));
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(TabibuBottomSheet),
          matching: find.text(en.cancelAppointmentConfirm),
        ),
      );
      await settleSheet(tester);

      verify(
        () => appointments.add(
          AppointmentCancelRequested(
            appointmentUid: 'a-up',
            cancelledByUid: 'patient-1',
            reason: en.cancelAppointmentReasonBetter,
          ),
        ),
      ).called(1);
    });

    testWidgets('a moved landing names the new time', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(moved: true));
      await tester.pumpAndSettle();

      expect(find.text(en.rescheduleMovedTo(whenText())), findsOneWidget);
      expect(
        find.text(en.rescheduleDoctorTold('Dr. Wanjiru Kamau')),
        findsOneWidget,
      );
    });

    testWidgets('the calendar button opens the month', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(en.calendarTitle));
      await tester.pumpAndSettle();

      expect(find.text('stub calendar'), findsOneWidget);
    });
  });
}
