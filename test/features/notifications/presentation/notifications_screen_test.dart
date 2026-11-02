import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_model.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';
import 'package:tabibu/features/notifications/presentation/notifications_screen.dart';
import 'package:tabibu/l10n/l10n.dart';

import '../../../helpers/helpers.dart';

const _nairobiOffset = Duration(hours: 3);

/// Noon in Nairobi on the given day, as an instant. Midday keeps the row
/// inside its bucket wherever the device zone is.
DateTime _nairobiNoon(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day, 12).subtract(_nairobiOffset);

NotificationModel _row({
  required String uid,
  required DateTime at,
  String templateKey = '',
  String category = 'Appointment',
  String status = 'Unread',
  String title = '',
  String message = '',
  String deepLink = '',
}) => NotificationModel(
  uid: uid,
  creationDate: at.toIso8601String(),
  templateKey: templateKey,
  category: category,
  status: status,
  title: title,
  message: message,
  metadata: NotificationMetadataModel(deepLink: deepLink),
);

PatientSession _patientSession() => PatientSession(
  patient: RoleSessions.patient.patient.copyWith(uid: 'patient-1'),
  roles: RoleSessions.patient.roles,
);

void main() {
  group('NotificationsScreen', () {
    late FeatureBlocs blocs;
    late MockAuthBloc authBloc;

    setUp(() {
      blocs = FeatureBlocs();
      authBloc = MockAuthBloc();
      when(
        () => authBloc.state,
      ).thenReturn(SignInSuccess(session: _patientSession()));
    });

    Widget screen(Role role) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<NotificationsBloc>.value(value: blocs.notifications),
      ],
      child: NotificationsScreen(role: role),
    );

    /// One row per group: a known template with its own title, an unknown
    /// template keeping the server copy, and a known template falling back
    /// to the server title.
    List<NotificationModel> groupedRows() {
      final now = DateTime.now().toUtc().add(_nairobiOffset);
      final today = _nairobiNoon(now);
      return [
        _row(
          uid: 'n-today',
          at: today,
          templateKey: NotificationTemplate.appointmentAccepted.value,
          deepLink: '/appointments/a1',
        ),
        _row(
          uid: 'n-yesterday',
          at: today.subtract(const Duration(days: 1)),
          category: 'Report',
          status: 'Read',
          title: 'Server title',
          message: 'Server message',
          deepLink: '/conversations/x1',
        ),
        _row(
          uid: 'n-earlier',
          at: today.subtract(const Duration(days: 10)),
          templateKey: NotificationTemplate.reportSigned.value,
          category: 'Result',
          title: 'Signed report ready',
          deepLink: '/cases/c1/reports/r1',
        ),
      ];
    }

    Future<void> pumpLoaded(WidgetTester tester, Role role) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(NotificationsLoadSuccess(items: groupedRows()));
      await tester.pumpApp(screen(role));
      await tester.pumpAndSettle();
    }

    testWidgets('requests the inbox on open', (tester) async {
      await tester.pumpApp(screen(.patient));
      // No settle: the loading spinner never stops.
      await tester.pump();

      verify(
        () => blocs.notifications.add(
          const NotificationsRequested(uid: 'patient-1'),
        ),
      ).called(1);
    });

    testWidgets('shows a spinner while loading with no rows', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(const NotificationsLoadInProgress());
      await tester.pumpApp(screen(.patient));
      // No settle: the loading spinner never stops.
      await tester.pump();

      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(MoreButton), findsOneWidget);
    });

    testWidgets('groups rows under Today, Yesterday and Earlier', (
      tester,
    ) async {
      await pumpLoaded(tester, .patient);

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      // Known template: the inbox re-renders in the current language.
      expect(find.text('Appointment confirmed'), findsOneWidget);
      expect(
        find.text('Your appointment request was accepted.'),
        findsOneWidget,
      );
      // Unknown template: the server copy.
      expect(find.text('Server title'), findsOneWidget);
      expect(find.text('Server message'), findsOneWidget);
      // Known template without a title: the server title, template body.
      expect(find.text('Signed report ready'), findsOneWidget);
      expect(find.text('A signed report is ready.'), findsOneWidget);
    });

    testWidgets('renders the groups in dark mode', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(NotificationsLoadSuccess(items: groupedRows()));
      await tester.pumpApp(screen(.doctor), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
    });

    testWidgets('each role gets its own empty sentence', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(const NotificationsLoadSuccess());

      await tester.pumpApp(screen(.patient));
      await tester.pumpAndSettle();
      expect(find.text("You're all caught up"), findsOneWidget);
      expect(
        find.text('Appointments, results and health notices will show here.'),
        findsOneWidget,
      );

      await tester.pumpApp(screen(.doctor));
      await tester.pumpAndSettle();
      expect(
        find.text('Bookings, signed reports and area alerts will show here.'),
        findsOneWidget,
      );

      await tester.pumpApp(screen(.pathologist));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'New cases, questions from doctors and MDT invites will show here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides the menu when empty and loaded', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(const NotificationsLoadSuccess());
      await tester.pumpApp(screen(.doctor));
      await tester.pumpAndSettle();

      expect(find.byType(MoreButton), findsNothing);
    });

    testWidgets('shows the offline banner above the list', (tester) async {
      when(() => blocs.notifications.state).thenReturn(
        NotificationsLoadSuccess(items: groupedRows(), offline: true),
      );
      await tester.pumpApp(screen(.patient));
      await tester.pumpAndSettle();

      expect(find.text("You're offline"), findsOneWidget);
      expect(find.text("Showing what's saved on this phone."), findsOneWidget);
      expect(find.text('Appointment confirmed'), findsOneWidget);
    });

    testWidgets('shows the failure as a toast', (tester) async {
      whenListen(
        blocs.notifications,
        Stream.fromIterable([
          const NotificationsLoadFailure(error: AppError.noInternet),
        ]),
        initialState: const NotificationsInitial(),
      );
      await tester.pumpApp(screen(.patient));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final l10n = AppLocalizations.of(
        tester.element(find.byType(NotificationsScreen)),
      );
      expect(find.text(AppError.noInternet.description(l10n)), findsOneWidget);
      // Let the toast's auto-dismiss fire; a settle alone never advances to it.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('a row marks itself read and opens its target', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(NotificationsLoadSuccess(items: groupedRows()));
      final router = GoRouter(
        initialLocation: '/notifications',
        routes: [
          GoRoute(path: '/notifications', builder: (_, _) => screen(.patient)),
          GoRoute(
            path: '/patient/appointment/:appointmentUid',
            builder: (_, _) => const Text('stub appointment'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      final row = find.text('Appointment confirmed');
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();

      verify(
        () => blocs.notifications.add(
          const NotificationReadRequested(
            uid: 'patient-1',
            notificationUid: 'n-today',
          ),
        ),
      ).called(1);
      expect(find.text('stub appointment'), findsOneWidget);
    });

    testWidgets('a Tier 2 link only marks the row read', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(NotificationsLoadSuccess(items: groupedRows()));
      await tester.pumpApp(screen(.patient));
      await tester.pumpAndSettle();

      final row = find.text('Server title');
      await tester.ensureVisible(row);
      await tester.tap(row);
      await tester.pumpAndSettle();

      verify(
        () => blocs.notifications.add(
          const NotificationReadRequested(
            uid: 'patient-1',
            notificationUid: 'n-yesterday',
          ),
        ),
      ).called(1);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('the menu marks all as read', (tester) async {
      await pumpLoaded(tester, .patient);

      await tester.tap(find.byType(MoreButton));
      await tester.pumpAndSettle();
      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.text('Mark all as read'));
      await tester.pumpAndSettle();

      verify(
        () => blocs.notifications.add(
          const NotificationsAllReadRequested(uid: 'patient-1'),
        ),
      ).called(1);
    });

    testWidgets('the menu refreshes', (tester) async {
      await pumpLoaded(tester, .patient);

      await tester.tap(find.byType(MoreButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      verify(
        () => blocs.notifications.add(
          const NotificationsRefreshed(uid: 'patient-1'),
        ),
      ).called(1);
    });

    testWidgets('groups by the Nairobi day across midnight', (tester) async {
      final nairobiNow = DateTime.now().toUtc().add(_nairobiOffset);
      final midnight = DateTime.utc(
        nairobiNow.year,
        nairobiNow.month,
        nairobiNow.day,
      ).subtract(_nairobiOffset);
      // 00:30 in Nairobi is still yesterday in UTC: UTC grouping would put
      // this row under Yesterday.
      final afterMidnight = midnight.add(const Duration(minutes: 30));
      final beforeMidnight = midnight.subtract(const Duration(minutes: 30));
      when(() => blocs.notifications.state).thenReturn(
        NotificationsLoadSuccess(
          items: [
            _row(uid: 'n-after', at: afterMidnight, title: 'After midnight'),
            _row(uid: 'n-before', at: beforeMidnight, title: 'Before midnight'),
          ],
        ),
      );
      await tester.pumpApp(screen(.patient));
      await tester.pumpAndSettle();

      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(top('Today') < top('After midnight'), isTrue);
      expect(top('After midnight') < top('Yesterday'), isTrue);
      expect(top('Yesterday') < top('Before midnight'), isTrue);
      // Today shows the time, yesterday the weekday, in Nairobi time.
      expect(
        find.text(
          DateFormat('h:mm a', 'en').format(afterMidnight.add(_nairobiOffset)),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          DateFormat('EEE', 'en').format(beforeMidnight.add(_nairobiOffset)),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders in Swahili', (tester) async {
      when(
        () => blocs.notifications.state,
      ).thenReturn(NotificationsLoadSuccess(items: groupedRows()));
      await tester.pumpApp(screen(.patient), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      // New Kiswahili words would fail the spell gate (the bundle does not
      // allow extending the dictionary), so these come from l10n itself.
      final l10n = AppLocalizations.of(
        tester.element(find.byType(NotificationsScreen)),
      );
      expect(find.text(l10n.notificationsTitle), findsOneWidget);
      expect(find.text('Leo'), findsOneWidget);
      expect(find.text('Jana'), findsOneWidget);
      expect(find.text(l10n.notificationsEarlier), findsOneWidget);
      expect(find.text('Miadi imethibitishwa'), findsOneWidget);
      expect(
        find.text(l10n.notificationAppointmentAcceptedBody),
        findsOneWidget,
      );
    });

    testWidgets('lays out at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpLoaded(tester, .pathologist);

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Appointment confirmed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
