import 'package:bloc_test/bloc_test.dart';
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
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_strip.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_chip_row.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/features/practitioners/presentation/doctor_profile_screen.dart';
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

/// The pinned clock: a Tuesday mid-morning in Nairobi, so the planner's
/// lead and the busy cover below land the same whatever hour runs this.
final _fixedNow = DateTime.utc(2026, 10, 27, 7);

/// 09:00 Nairobi for the coming days, as the server would store them.
List<String> _busySlots(DateTime now) {
  final nairobi = nairobiNow(now);
  final today = DateTime.utc(nairobi.year, nairobi.month, nairobi.day);
  return [
    for (var i = 0; i < 10; i++)
      DateTime.utc(
        today.year,
        today.month,
        today.day,
        9,
      ).add(Duration(days: i)).subtract(nairobiOffset).toIso8601String(),
  ];
}

String _timeOf(DateTime start, [String language = 'en']) =>
    DateFormat('h:mm a', language).format(nairobiNow(start));

void main() {
  group('DoctorProfileScreen', () {
    late MockDirectoryBloc directory;
    late MockAppointmentsBloc appointments;
    late MockAuthBloc authBloc;
    late PractitionerModel doctor;

    setUp(() {
      doctor = PractitionerModel(
        uid: 'd1',
        title: 'Dr.',
        firstName: 'Wanjiru',
        lastName: 'Kamau',
        profilePictureUrl: '',
        isPathologist: false,
        specialties: const ['General surgery'],
        bio:
            'Breast and general surgeon with many years in practice. Sees '
            'adults for breast lumps, biopsies and follow-up after surgery, '
            'with clinics every weekday morning and afternoon.',
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
        busySlots: _busySlots(_fixedNow),
      );
      directory = MockDirectoryBloc();
      when(
        () => directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: [doctor]));
      appointments = MockAppointmentsBloc();
      when(
        () => appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess());
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
        BlocProvider<DirectoryBloc>.value(value: directory),
        BlocProvider<AppointmentsBloc>.value(value: appointments),
      ],
      child: DoctorProfileScreen(doctorUid: 'd1', now: _fixedNow),
    );

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(path: '/profile', builder: (_, _) => screen()),
          GoRoute(
            path: '/patient/appointment/:appointmentUid',
            builder: (_, state) => Text(
              'stub appointment ${state.pathParameters['appointmentUid']}',
            ),
          ),
          GoRoute(
            path: '/patient/appointment/:appointmentUid/booked',
            builder: (_, state) =>
                Text('stub booked ${state.pathParameters['appointmentUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    /// The first day with both a taken and a free slot; the busy cover above
    /// guarantees one whatever time it is.
    int mixedDay() {
      final days = const SlotPlanner().days(doctor, _fixedNow);
      return days.indexWhere((d) => d.available && d.slots.any((s) => s.taken));
    }

    Future<void> selectDay(WidgetTester tester, int index) async {
      final pills = find.descendant(
        of: find.byType(DayStrip),
        matching: find.byType(Tappable),
      );
      await tester.tap(pills.at(index));
      await tester.pump();
    }

    Future<void> selectSlot(WidgetTester tester, String label) async {
      final chip = find.text(label);
      await tester.scrollUntilVisible(
        chip,
        200,
        scrollable: find.descendant(
          of: find.byType(SlotChipRow),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(chip);
      await tester.pump();
    }

    testWidgets('loads the doctor without refetching', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('KMPDC verified'), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('General surgery'), findsOneWidget);
      expect(find.text('Aga Khan University Hospital'), findsWidgets);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('Embakasi'), findsOneWidget);
      expect(find.text('Pick a day'), findsOneWidget);
      expect(find.textContaining(RegExp('times? free')), findsOneWidget);
      expect(find.text('Choose a time'), findsOneWidget);
      verifyNever(() => directory.add(const DirectoryRequested()));
    });

    testWidgets('Read more expands the bio', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Read more'));
      await tester.pump();

      expect(find.text('Read more'), findsNothing);
      expect(find.textContaining('weekday morning'), findsOneWidget);
    });

    testWidgets('an unknown doctor syncs, then shows not found', (
      tester,
    ) async {
      _useTallSurface(tester);
      when(() => directory.state).thenReturn(const DirectoryLoadSuccess());
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      verify(() => directory.add(const DirectoryRequested())).called(1);
      expect(find.text('Doctor not found'), findsOneWidget);
      expect(find.text("This doctor isn't in the directory."), findsOneWidget);
    });

    testWidgets('a missing doctor shows the spinner while syncing', (
      tester,
    ) async {
      _useTallSurface(tester);
      when(() => directory.state).thenReturn(const DirectoryLoadInProgress());
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.text('Doctor not found'), findsNothing);
    });

    testWidgets('a taken slot is disabled and announced', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final days = const SlotPlanner().days(doctor, _fixedNow);
      final dayIndex = mixedDay();
      await selectDay(tester, dayIndex);
      final taken = days[dayIndex].slots.firstWhere((s) => s.taken);
      final label = _timeOf(taken.start);

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == '$label, taken',
        ),
        findsOneWidget,
      );
      await selectSlot(tester, label);

      expect(find.text('Choose a time'), findsOneWidget);
    });

    testWidgets('Book enables once a slot is chosen', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TabibuButton>(
              find.widgetWithText(TabibuButton, 'Choose a time'),
            )
            .onTap,
        isNull,
      );

      final days = const SlotPlanner().days(doctor, _fixedNow);
      final dayIndex = mixedDay();
      await selectDay(tester, dayIndex);
      final free = days[dayIndex].slots.firstWhere((s) => !s.taken);
      await selectSlot(tester, _timeOf(free.start));

      final bookLabel =
          'Book ${DateFormat('EEE d MMM', 'en').format(days[dayIndex].date)}, '
          '${_timeOf(free.start)}';
      expect(
        tester
            .widget<TabibuButton>(find.widgetWithText(TabibuButton, bookLabel))
            .onTap,
        isNotNull,
      );
    });

    testWidgets('booking dispatches the exact event', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      final days = const SlotPlanner().days(doctor, _fixedNow);
      final dayIndex = mixedDay();
      await selectDay(tester, dayIndex);
      final free = days[dayIndex].slots.firstWhere((s) => !s.taken);
      await selectSlot(tester, _timeOf(free.start));
      await tester.enterText(find.byType(EditableText), 'A lump for two weeks');
      final bookLabel =
          'Book ${DateFormat('EEE d MMM', 'en').format(days[dayIndex].date)}, '
          '${_timeOf(free.start)}';
      await tester.tap(find.text(bookLabel));
      await tester.pump();

      verify(
        () => appointments.add(
          AppointmentBookRequested(
            uid: 'patient-1',
            doctorUid: 'd1',
            type: 'Consultation',
            start: free.start,
            symptomText: 'A lump for two weeks',
          ),
        ),
      ).called(1);
    });

    testWidgets('booking success replaces with Booked', (tester) async {
      _useTallSurface(tester);
      final booked = AppointmentModel(
        uid: 'a-new',
        doctorUid: 'd1',
        doctorName: 'Dr. Wanjiru Kamau',
        facilityName: 'Aga Khan University Hospital',
        scheduledStart: DateTime.now().toUtc().toIso8601String(),
      );
      whenListen(
        appointments,
        Stream.fromIterable([
          AppointmentBookSuccess(appointment: booked, appointments: [booked]),
        ]),
        initialState: const AppointmentsLoadSuccess(),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.text('stub booked a-new'), findsOneWidget);
    });

    testWidgets('booking failure toasts', (tester) async {
      _useTallSurface(tester);
      whenListen(
        appointments,
        Stream.fromIterable([
          const AppointmentWriteFailure(error: AppError.noInternet),
        ]),
        initialState: const AppointmentsLoadSuccess(),
      );
      await tester.pumpApp(screen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DoctorProfileScreen)),
      );
      expect(find.text(AppError.noInternet.description(l10n)), findsOneWidget);
      // Let the toast dismiss so its timer doesn't outlive the test.
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('offline shows the banner and disables Book', (tester) async {
      _useTallSurface(tester);
      when(
        () => appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess(offline: true));
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Booking needs internet'), findsOneWidget);
      expect(find.text('Reconnect to book this appointment.'), findsOneWidget);

      final days = const SlotPlanner().days(doctor, _fixedNow);
      final dayIndex = mixedDay();
      await selectDay(tester, dayIndex);
      final free = days[dayIndex].slots.firstWhere((s) => !s.taken);
      await selectSlot(tester, _timeOf(free.start));

      final bookLabel =
          'Book ${DateFormat('EEE d MMM', 'en').format(days[dayIndex].date)}, '
          '${_timeOf(free.start)}';
      expect(
        tester
            .widget<TabibuButton>(find.widgetWithText(TabibuButton, bookLabel))
            .onTap,
        isNull,
      );
    });

    testWidgets('the booked notice opens the appointment', (tester) async {
      _useTallSurface(tester);
      final start = DateTime.now().toUtc().add(const Duration(days: 2));
      when(() => appointments.state).thenReturn(
        AppointmentsLoadSuccess(
          appointments: [
            AppointmentModel(
              uid: 'a-booked',
              status: 'Accepted',
              doctorUid: 'd1',
              doctorName: 'Dr. Wanjiru Kamau',
              facilityName: 'Aga Khan University Hospital',
              scheduledStart: start.toIso8601String(),
            ),
          ],
        ),
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      expect(find.text("You're booked with Dr. Kamau"), findsOneWidget);
      final at = start.add(nairobiOffset);
      expect(
        find.text(
          "${DateFormat('EEE d MMM', 'en').format(at)} · "
          "${DateFormat('h:mm a', 'en').format(at)}",
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('View appointment'));
      await tester.pumpAndSettle();

      expect(find.text('stub appointment a-booked'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Pick a day'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DoctorProfileScreen)),
      );
      expect(find.text('Daktari'), findsOneWidget);
      expect(find.text(l10n.doctorProfileVerified), findsOneWidget);
      expect(find.text(l10n.doctorProfilePickDay), findsOneWidget);
      expect(find.text(l10n.doctorProfileChooseTime), findsOneWidget);
      expect(
        find.text(Specialty.generalSurgery.description(l10n)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      _useTallSurface(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Pick a day'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
