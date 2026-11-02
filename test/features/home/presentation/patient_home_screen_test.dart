import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';
import 'package:tabibu/features/alerts/data/models/alert_text_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/appointments/data/models/appointment_model.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_bloc.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_event.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/ordered_test_model.dart';
import 'package:tabibu/features/home/presentation/patient_home_screen.dart';
import 'package:tabibu/features/home/presentation/widgets/book_prompt_card.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_bloc.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

PatientSession _session() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

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

/// A Nairobi wall-clock time as the instant the server would store.
DateTime _nairobi({required int plusDays, required int hour, int minute = 0}) {
  final now = nairobiNow();
  final day = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).add(Duration(days: plusDays));
  return DateTime.utc(
    day.year,
    day.month,
    day.day,
    hour,
    minute,
  ).subtract(nairobiOffset);
}

AppointmentModel _appointment({
  required String uid,
  required DateTime start,
  String status = 'Accepted',
  String doctorUid = 'd1',
  String doctorName = 'Dr. Wanjiru Kamau',
  String facilityName = 'Aga Khan',
}) => AppointmentModel(
  uid: uid,
  status: status,
  doctorUid: doctorUid,
  doctorName: doctorName,
  facilityName: facilityName,
  scheduledStart: start.toIso8601String(),
);

CaseModel _case({
  required String uid,
  String resultState = 'WithDoctor',
  String testName = 'Lymph node',
  String doctorName = 'Dr. Kamau',
  String discussionAppointmentUid = 'a-discuss',
}) => CaseModel(
  uid: uid,
  resultState: resultState,
  doctorName: doctorName,
  discussionAppointmentUid: discussionAppointmentUid,
  tests: [OrderedTestModel(name: testName)],
);

PublicAlertModel _alert() => const PublicAlertModel(
  uid: 'alert-1',
  countyName: 'Embakasi',
  patientText: {
    'en': AlertTextModel(headline: 'More malaria cases than usual this week'),
  },
);

PractitionerModel _doctor({
  required String uid,
  required String firstName,
  required String lastName,
  required String specialty,
  required String subCounty,
}) => PractitionerModel(
  uid: uid,
  title: 'Dr.',
  firstName: firstName,
  lastName: lastName,
  profilePictureUrl: '',
  isPathologist: false,
  specialties: [specialty],
  bio: '',
  facilityId: '',
  facilityMflCode: '',
  facilityName: 'Aga Khan',
  county: 'Nairobi',
  subCounty: subCounty,
  geohash: '',
  isAvailable: true,
  appointmentsHandled: 0,
  ordersCreated: 0,
  reportsSigned: 0,
  lastUpdatedAt: '',
);

void main() {
  group('PatientHomeScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    final doctors = [
      _doctor(
        uid: 'd3',
        firstName: 'Grace',
        lastName: 'Otieno',
        specialty: 'Unknown specialty',
        subCounty: 'Westlands',
      ),
      _doctor(
        uid: 'd1',
        firstName: 'Wanjiru',
        lastName: 'Kamau',
        specialty: 'General surgery',
        subCounty: 'Embakasi',
      ),
      _doctor(
        uid: 'd5',
        firstName: 'Amina',
        lastName: 'Wambui',
        specialty: 'General surgery',
        subCounty: 'Dagoretti',
      ),
      _doctor(
        uid: 'd2',
        firstName: 'Achieng',
        lastName: 'Odhiambo',
        specialty: 'Paediatrics',
        subCounty: 'Embakasi',
      ),
      _doctor(
        uid: 'd4',
        firstName: 'Mary',
        lastName: 'Kamau',
        specialty: 'General surgery',
        subCounty: 'Embakasi',
      ),
    ];

    List<AppointmentModel> appointments() => [
      _appointment(uid: 'a-past', start: _nairobi(plusDays: -1, hour: 10)),
      _appointment(
        uid: 'a-requested',
        start: _nairobi(plusDays: 1, hour: 10),
        status: 'Requested',
      ),
      _appointment(
        uid: 'a-later',
        start: _nairobi(plusDays: 5, hour: 9),
        doctorUid: 'd2',
        doctorName: 'Dr. Achieng Odhiambo',
        facilityName: 'Mama Lucy',
      ),
      _appointment(
        uid: 'a-next',
        start: _nairobi(plusDays: 2, hour: 11, minute: 15),
      ),
      _appointment(uid: 'a-discuss', start: _nairobi(plusDays: 3, hour: 14)),
    ];

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(() => authBloc.state).thenReturn(SignInSuccess(session: _session()));
    });

    Widget screen({Key? key}) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<NotificationsBloc>.value(value: blocs.notifications),
        BlocProvider<PublicAlertsBloc>.value(value: blocs.publicAlerts),
        BlocProvider<AppointmentsBloc>.value(value: blocs.appointments),
        BlocProvider<CasesBloc>.value(value: blocs.cases),
        BlocProvider<DirectoryBloc>.value(value: blocs.directory),
      ],
      child: PatientHomeScreen(key: key),
    );

    void stubDefault({
      List<AppointmentModel>? appointments,
      List<CaseModel>? cases,
      List<PublicAlertModel>? alerts,
      int unread = 2,
    }) {
      when(
        () => blocs.notifications.state,
      ).thenReturn(NotificationsLoadSuccess(unread: unread));
      when(
        () => blocs.publicAlerts.state,
      ).thenReturn(PublicAlertsLoadSuccess(alerts: alerts ?? [_alert()]));
      when(() => blocs.appointments.state).thenReturn(
        AppointmentsLoadSuccess(appointments: appointments ?? const []),
      );
      when(
        () => blocs.cases.state,
      ).thenReturn(CasesLoadSuccess(cases: cases ?? const []));
      when(
        () => blocs.directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: doctors, visible: doctors));
    }

    GoRouter router() {
      final routes = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (_, _) => screen()),
          GoRoute(
            path: '/patient/notifications',
            builder: (_, _) => const Text('stub notifications'),
          ),
          GoRoute(
            path: '/patient/notice/:alertUid',
            builder: (_, state) =>
                Text('stub notice ${state.pathParameters['alertUid']}'),
          ),
          GoRoute(
            path: '/patient/appointment/:appointmentUid',
            builder: (_, state) => Text(
              'stub appointment ${state.pathParameters['appointmentUid']}',
            ),
          ),
          GoRoute(
            path: '/patient/result/:caseUid',
            builder: (_, state) =>
                Text('stub result ${state.pathParameters['caseUid']}'),
          ),
          GoRoute(
            path: '/patient/doctors',
            builder: (_, _) => const Text('stub doctors'),
          ),
          GoRoute(
            path: '/patient/doctors/:doctorUid',
            builder: (_, state) =>
                Text('stub profile ${state.pathParameters['doctorUid']}'),
          ),
        ],
      );
      addTearDown(routes.dispose);
      return routes;
    }

    String subtitleDate(String language) =>
        DateFormat('EEE d MMM', language).format(nairobiNow());

    testWidgets('dispatches the five requests on open', (tester) async {
      await tester.pumpApp(screen());
      await tester.pump();

      verify(
        () => blocs.notifications.add(
          const NotificationsRequested(uid: 'patient-1'),
        ),
      ).called(1);
      verify(
        () => blocs.publicAlerts.add(
          const PublicAlertsRequested(
            county: 'Nairobi',
            demo: false,
            clinician: false,
          ),
        ),
      ).called(1);
      verify(
        () => blocs.appointments.add(
          const AppointmentsRequested(uid: 'patient-1', role: Role.patient),
        ),
      ).called(1);
      verify(
        () => blocs.cases.add(
          const CasesRequested(uid: 'patient-1', role: Role.patient),
        ),
      ).called(1);
      verify(() => blocs.directory.add(const DirectoryRequested())).called(1);
    });

    testWidgets('shows the notice, both slides and four doctors', (
      tester,
    ) async {
      _useTallSurface(tester);
      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Hi, Amina'), findsOneWidget);
      expect(find.text('Embakasi · ${subtitleDate('en')}'), findsOneWidget);
      expect(find.byType(ConnectivityBanner), findsNothing);
      expect(find.text('Your care,'), findsOneWidget);
      expect(find.text('close to home.'), findsOneWidget);

      expect(find.text('Health notice · Embakasi'), findsOneWidget);
      expect(
        find.text('More malaria cases than usual this week'),
        findsOneWidget,
      );

      expect(find.text('Next appointment · in 2 days'), findsOneWidget);
      expect(
        find.text(
          DateFormat('EEE d MMM', 'en').format(
            _nairobi(plusDays: 2, hour: 11, minute: 15).add(nairobiOffset),
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('11:15 AM'), findsOneWidget);
      expect(
        find.text('Dr. Wanjiru Kamau · General surgery, Aga Khan'),
        findsOneWidget,
      );
      expect(find.text('Details'), findsOneWidget);

      expect(find.text('With your doctor'), findsOneWidget);
      expect(find.text('Lymph node results'), findsOneWidget);
      final discussion = DateFormat(
        'EEE d MMM',
        'en',
      ).format(_nairobi(plusDays: 3, hour: 14).add(nairobiOffset));
      expect(
        find.text(
          'Dr. Kamau goes through them with you on $discussion. '
          'Then you can read them here.',
        ),
        findsOneWidget,
      );
      expect(find.byType(PageDots), findsOneWidget);

      expect(find.text('Doctors near you'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.byType(SearchField), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau'), findsOneWidget);
      expect(find.text('Dr. Achieng Odhiambo'), findsOneWidget);
      expect(find.text('Dr. Mary Kamau'), findsOneWidget);
      expect(find.text('Dr. Grace Otieno'), findsOneWidget);
      expect(find.text('Unknown specialty'), findsOneWidget);
      expect(find.text('Dr. Amina Wambui'), findsNothing);
    });

    testWidgets('announces the unread bell', (tester) async {
      stubDefault();
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is CircleIconButton &&
              w.semanticLabel == 'Notifications, unread',
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides the notice when no alert exists', (tester) async {
      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
        alerts: const [],
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Health notice · Embakasi'), findsNothing);
      expect(find.text('Next appointment · in 2 days'), findsOneWidget);
      expect(find.text('Lymph node results'), findsOneWidget);
    });

    testWidgets('without an appointment the book prompt is slide 1', (
      tester,
    ) async {
      stubDefault(cases: [_case(uid: 'case-1')]);
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('No appointments coming up'), findsOneWidget);
      expect(find.text('Lymph node results'), findsOneWidget);
      expect(find.byType(PageDots), findsOneWidget);
    });

    testWidgets('with nothing yet the prompt is full width without dots', (
      tester,
    ) async {
      stubDefault();
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('No appointments coming up'), findsOneWidget);
      expect(find.text('Health notice · Embakasi'), findsOneWidget);
      expect(find.byType(HeroCarousel), findsNothing);
      expect(find.byType(PageDots), findsNothing);
    });

    testWidgets('offline shows the banner and hides search', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(const NotificationsLoadSuccess());
      when(
        () => blocs.publicAlerts.state,
      ).thenReturn(PublicAlertsLoadSuccess(alerts: [_alert()]));
      when(() => blocs.appointments.state).thenReturn(
        AppointmentsLoadSuccess(appointments: appointments(), offline: true),
      );
      when(
        () => blocs.cases.state,
      ).thenReturn(CasesLoadSuccess(cases: [_case(uid: 'case-1')]));
      when(
        () => blocs.directory.state,
      ).thenReturn(DirectoryLoadSuccess(all: doctors, visible: doctors));
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text("You're offline"), findsOneWidget);
      expect(
        find.text('Showing your saved appointments and results.'),
        findsOneWidget,
      );
      expect(find.byType(SearchField), findsNothing);
      expect(find.text('Next appointment · in 2 days'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      verify(
        () => blocs.notifications.add(
          const NotificationsRefreshed(uid: 'patient-1'),
        ),
      ).called(1);
      // Alerts reuse the request for refresh, so initState plus the retry
      // send it twice.
      verify(
        () => blocs.publicAlerts.add(
          const PublicAlertsRequested(
            county: 'Nairobi',
            demo: false,
            clinician: false,
          ),
        ),
      ).called(2);
      verify(
        () => blocs.appointments.add(
          const AppointmentsRefreshed(uid: 'patient-1', role: Role.patient),
        ),
      ).called(1);
      verify(
        () => blocs.cases.add(
          const CasesRefreshed(uid: 'patient-1', role: Role.patient),
        ),
      ).called(1);
      verify(() => blocs.directory.add(const DirectoryRefreshed())).called(1);
    });

    testWidgets('loading shows the hero spinner under the headline', (
      tester,
    ) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(const NotificationsLoadSuccess());
      when(
        () => blocs.publicAlerts.state,
      ).thenReturn(const PublicAlertsLoadSuccess());
      when(
        () => blocs.appointments.state,
      ).thenReturn(const AppointmentsLoadInProgress());
      when(() => blocs.cases.state).thenReturn(const CasesLoadSuccess());
      when(
        () => blocs.directory.state,
      ).thenReturn(const DirectoryLoadSuccess());
      await tester.pumpApp(screen());
      await tester.pump();

      expect(find.text('Hi, Amina'), findsOneWidget);
      expect(find.text('Your care,'), findsOneWidget);
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(BookPromptCard), findsNothing);
    });

    testWidgets('the bell opens notifications', (tester) async {
      stubDefault();
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is CircleIconButton &&
              w.semanticLabel == 'Notifications, unread',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('stub notifications'), findsOneWidget);
    });

    testWidgets('the notice opens the health notice', (tester) async {
      stubDefault();
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('More malaria cases than usual this week'));
      await tester.pumpAndSettle();

      expect(find.text('stub notice alert-1'), findsOneWidget);
    });

    testWidgets('Details opens the appointment', (tester) async {
      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.text('stub appointment a-next'), findsOneWidget);
    });

    testWidgets('the results slide opens the result', (tester) async {
      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
      );
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lymph node results'));
      await tester.pumpAndSettle();

      expect(find.text('stub result case-1'), findsOneWidget);
    });

    testWidgets('Book now opens the directory', (tester) async {
      stubDefault();
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Book now'));
      await tester.pumpAndSettle();

      expect(find.text('stub doctors'), findsOneWidget);
    });

    testWidgets('See all opens the directory', (tester) async {
      _useTallSurface(tester);
      stubDefault();
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      final seeAll = find.text('See all');
      await tester.ensureVisible(seeAll);
      await tester.tap(seeAll);
      await tester.pumpAndSettle();

      expect(find.text('stub doctors'), findsOneWidget);
    });

    testWidgets('a search tap opens the directory', (tester) async {
      _useTallSurface(tester);
      stubDefault();
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      final search = find.byType(SearchField);
      await tester.ensureVisible(search);
      await tester.tap(search);
      await tester.pumpAndSettle();

      expect(find.text('stub doctors'), findsOneWidget);
    });

    testWidgets('a doctor card opens the profile', (tester) async {
      _useTallSurface(tester);
      stubDefault();
      await tester.pumpRouterApp(router());
      await tester.pumpAndSettle();

      final card = find.text('Dr. Achieng Odhiambo');
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.text('stub profile d2'), findsOneWidget);
    });

    testWidgets('without a discussion the results body has no date', (
      tester,
    ) async {
      stubDefault(
        cases: [_case(uid: 'case-1', discussionAppointmentUid: '')],
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(
        find.text('Dr. Kamau will go through them with you.'),
        findsOneWidget,
      );
    });

    testWidgets('the eyebrow counts Nairobi days until the visit', (
      tester,
    ) async {
      Future<void> check(Duration ahead) async {
        final startUtc = DateTime.now().toUtc().add(ahead);
        final start = AppointmentModel(
          uid: 'a-only',
          status: 'Accepted',
          doctorUid: 'd1',
          doctorName: 'Dr. Wanjiru Kamau',
          facilityName: 'Aga Khan',
          scheduledStart: startUtc.toIso8601String(),
        );
        when(
          () => blocs.appointments.state,
        ).thenReturn(AppointmentsLoadSuccess(appointments: [start]));
        when(() => blocs.cases.state).thenReturn(const CasesLoadSuccess());
        when(
          () => blocs.notifications.state,
        ).thenReturn(const NotificationsLoadSuccess());
        when(
          () => blocs.publicAlerts.state,
        ).thenReturn(const PublicAlertsLoadSuccess());
        when(
          () => blocs.directory.state,
        ).thenReturn(const DirectoryLoadSuccess());
        // A fresh key per check: re-pumping the identical widget would not
        // rebuild, and later checks would read the first check's eyebrow.
        await tester.pumpApp(screen(key: ValueKey(ahead)));
        await tester.pumpAndSettle();

        final then = startUtc.add(nairobiOffset);
        final now = DateTime.now().toUtc().add(nairobiOffset);
        final daysUntil = DateTime.utc(
          then.year,
          then.month,
          then.day,
        ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
        final expected = switch (daysUntil) {
          0 => 'Next appointment · today',
          1 => 'Next appointment · tomorrow',
          _ => 'Next appointment · in $daysUntil days',
        };
        expect(find.text(expected), findsOneWidget);
      }

      await check(const Duration(hours: 2));
      await check(const Duration(hours: 26));
      await check(const Duration(days: 5));
    });

    testWidgets("the patient's sub-county comes first, four at most", (
      tester,
    ) async {
      _useTallSurface(tester);
      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      // Row 1 holds two Embakasi doctors, row 2 the third and the first
      // doctor from elsewhere; the fifth doctor is cut.
      expect(top('Dr. Wanjiru Kamau'), lessThan(top('Dr. Mary Kamau')));
      expect(top('Dr. Achieng Odhiambo'), lessThan(top('Dr. Mary Kamau')));
      expect(top('Dr. Mary Kamau'), top('Dr. Grace Otieno'));
      expect(find.text('Dr. Amina Wambui'), findsNothing);
    });

    testWidgets('renders in dark mode', (tester) async {
      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
      );
      await tester.pumpApp(screen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Hi, Amina'), findsOneWidget);
      expect(find.text('Next appointment · in 2 days'), findsOneWidget);
      expect(find.text('Lymph node results'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili', (tester) async {
      _useTallSurface(tester);
      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
      );
      await tester.pumpApp(screen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(PatientHomeScreen)),
      );
      expect(find.text('Habari, Amina'), findsOneWidget);
      expect(find.text(l10n.patientHomeHeadlineFirst), findsOneWidget);
      expect(find.text(l10n.patientHomeHeadlineSecond), findsOneWidget);
      expect(
        find.text(l10n.patientHomeNoticeLabel('Embakasi')),
        findsOneWidget,
      );
      // The alert has no Kiswahili text, so the English headline stands in.
      expect(
        find.text('More malaria cases than usual this week'),
        findsOneWidget,
      );
      expect(find.text(l10n.patientHomeEyebrow(2)), findsOneWidget);
      expect(
        find.text(l10n.patientHomeResultsTitle('Lymph node')),
        findsOneWidget,
      );
      expect(find.text(l10n.patientHomeWithDoctor), findsOneWidget);
      expect(find.text(l10n.patientHomeDoctorsNearYou), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == l10n.patientHomeSearchHint,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      stubDefault(
        appointments: appointments(),
        cases: [_case(uid: 'case-1')],
      );
      await tester.pumpApp(screen());
      await tester.pumpAndSettle();

      expect(find.text('Hi, Amina'), findsOneWidget);
      expect(find.text('Next appointment · in 2 days'), findsOneWidget);
      expect(find.text('Lymph node results'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
