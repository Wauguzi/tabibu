import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/cases/blocs/cases_bloc/cases_state.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';

import '../../../helpers/helpers.dart';

/// The doctor tab now shows its screen: its blocs settled past loading (the
/// spinner never settles).
FeatureBlocs _loadedDoctorBlocs() {
  final blocs = FeatureBlocs();
  when(
    () => blocs.notifications.state,
  ).thenReturn(const NotificationsLoadSuccess());
  when(
    () => blocs.appointments.state,
  ).thenReturn(const AppointmentsLoadSuccess());
  when(() => blocs.cases.state).thenReturn(const CasesLoadSuccess());
  return blocs;
}

void main() {
  group('HomeTabScreen', () {
    // After a pump: the app's delegates load the date symbols.
    String today() => DateFormat('EEE d MMM', 'en').format(DateTime.now());

    testWidgets("greets a patient with their area and today's date", (
      tester,
    ) async {
      // The patient tab now shows its screen: settle its blocs past loading
      // (the spinner never settles) and read the Nairobi date it shows.
      final blocs = FeatureBlocs();
      when(
        () => blocs.notifications.state,
      ).thenReturn(const NotificationsLoadSuccess());
      when(
        () => blocs.publicAlerts.state,
      ).thenReturn(const PublicAlertsLoadSuccess());
      when(
        () => blocs.appointments.state,
      ).thenReturn(const AppointmentsLoadSuccess());
      when(() => blocs.cases.state).thenReturn(const CasesLoadSuccess());
      when(
        () => blocs.directory.state,
      ).thenReturn(const DirectoryLoadSuccess());
      await tester.pumpRoleApp(RoleSessions.patient, '/patient', blocs: blocs);
      await tester.pumpAndSettle();

      final nairobiToday = DateFormat('EEE d MMM', 'en').format(nairobiNow());
      expect(find.text('Hi, Amina'), findsOneWidget);
      expect(find.text('Embakasi · $nairobiToday'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is CircleIconButton && w.semanticLabel == 'Notifications',
        ),
        findsOneWidget,
      );
    });

    testWidgets('greets a doctor by title with their facility', (tester) async {
      await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor',
        blocs: _loadedDoctorBlocs(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hi, Dr. Kamau'), findsOneWidget);
      expect(
        find.text('${today()} · Aga Khan University Hospital'),
        findsOneWidget,
      );
    });

    testWidgets('reads the date in Kiswahili', (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        RoleSessions.doctor(),
        '/doctor',
        blocs: _loadedDoctorBlocs(),
      );
      await tester.pumpAndSettle();

      final today = DateFormat('EEE d MMM', 'sw').format(nairobiNow());
      expect(
        find.text('$today · Aga Khan University Hospital'),
        findsOneWidget,
      );
    });

    testWidgets('renders in Swahili in dark mode at 2.0x text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        RoleSessions.pathologist,
        '/pathologist',
        themeMode: ThemeMode.dark,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Habari, Dr. Odhiambo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
