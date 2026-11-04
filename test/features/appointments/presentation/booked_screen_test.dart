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
import 'package:tabibu/features/appointments/presentation/booked_screen.dart';
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

void main() {
  group('BookedScreen', () {
    late MockAppointmentsBloc appointments;
    late MockDirectoryBloc directory;
    late MockAuthBloc authBloc;

    final start = DateTime.now().toUtc().add(const Duration(days: 2));
    late AppointmentModel appointment;

    setUp(() {
      appointment = AppointmentModel(
        uid: 'a-new',
        doctorUid: 'd1',
        doctorName: 'Dr. Wanjiru Kamau',
        facilityName: 'Aga Khan University Hospital',
        scheduledStart: start.toIso8601String(),
      );
      appointments = MockAppointmentsBloc();
      when(
        () => appointments.state,
      ).thenReturn(AppointmentsLoadSuccess(appointments: [appointment]));
      directory = MockDirectoryBloc();
      when(() => directory.state).thenReturn(
        const DirectoryLoadSuccess(
          all: [
            PractitionerModel(
              uid: 'd1',
              title: 'Dr.',
              firstName: 'Wanjiru',
              lastName: 'Kamau',
              profilePictureUrl: '',
              isPathologist: false,
              specialties: ['General surgery'],
              bio: '',
              facilityId: '',
              facilityMflCode: '',
              facilityName: 'Aga Khan University Hospital',
              county: 'Nairobi',
              subCounty: 'Embakasi',
              geohash: '',
              isAvailable: true,
              appointmentsHandled: 0,
              ordersCreated: 0,
              reportsSigned: 0,
              lastUpdatedAt: '',
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
        BlocProvider<DirectoryBloc>.value(value: directory),
      ],
      child: const BookedScreen(appointmentUid: 'a-new'),
    );

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/booked-test',
        routes: [
          GoRoute(path: '/booked-test', builder: (_, _) => screen()),
          GoRoute(path: '/patient', builder: (_, _) => const Text('stub home')),
          GoRoute(
            path: '/patient/appointment/:appointmentUid',
            builder: (_, state) => Text(
              'stub appointment ${state.pathParameters['appointmentUid']}',
            ),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    testWidgets('shows the booked confirmation', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text("You're booked, Amina"), findsOneWidget);
      expect(find.text("We'll remind you the day before."), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('General surgery'), findsOneWidget);
      final at = start.add(nairobiOffset);
      expect(
        find.text(DateFormat('EEE d MMM', 'en').format(at)),
        findsOneWidget,
      );
      expect(find.text(DateFormat('h:mm a', 'en').format(at)), findsOneWidget);
      expect(find.text('Aga Khan University Hospital'), findsOneWidget);
      expect(
        find.text(
          'Bring your ID, medical cover certificate and any past results.',
        ),
        findsOneWidget,
      );
      expect(find.text('View appointment'), findsOneWidget);
      expect(find.text('Back home'), findsOneWidget);
    });

    testWidgets('system back goes home', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('stub home'), findsOneWidget);
    });

    testWidgets('View appointment replaces with the appointment', (
      tester,
    ) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('View appointment'));
      await tester.pumpAndSettle();

      expect(find.text('stub appointment a-new'), findsOneWidget);
    });

    testWidgets('Back home goes home', (tester) async {
      _useTallSurface(tester);
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back home'));
      await tester.pumpAndSettle();

      expect(find.text('stub home'), findsOneWidget);
    });

    testWidgets('a missing appointment syncs and spins', (tester) async {
      _useTallSurface(tester);
      when(
        () => appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess());
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => appointments.add(
          const AppointmentsRequested(uid: 'patient-1', role: Role.patient),
        ),
      ).called(1);
      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text("You're booked, Amina"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(BookedScreen)),
      );
      expect(find.text(l10n.bookedTitle('Amina')), findsOneWidget);
      expect(find.text(l10n.bookedBody), findsOneWidget);
      expect(find.text(l10n.bookedBring), findsOneWidget);
      expect(find.text(l10n.bookedViewAppointment), findsOneWidget);
      expect(find.text(l10n.bookedBackHome), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text("You're booked, Amina"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
