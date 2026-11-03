import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('PatientProfileScreen', () {
    setUpAll(() => initializeDateFormatting('sw'));

    // Tall enough that the lazy list builds every row.
    void tallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(1170, 6000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    PatientSession fullSession() => PatientSession(
      patient: RoleSessions.patient.patient.copyWith(
        middleName: 'Mumbi',
        email: 'amina.wambui@gmail.com',
      ),
      roles: RoleSessions.patient.roles,
    );

    testWidgets('shows the hero and the About-me rows', (tester) async {
      tallView(tester);
      final session = fullSession();
      await tester.pumpRoleApp(session, '/patient/profile/details');
      await tester.pumpAndSettle();

      final age = session.patient.ageOn(nairobiNow());
      expect(find.text('My profile'), findsOneWidget);
      expect(find.text('Amina W.'), findsOneWidget);
      expect(find.text('$age years · Embakasi'), findsOneWidget);
      expect(find.text('About me'), findsOneWidget);
      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('14 Mar 1980 · $age years'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('+254 712 *** ***'), findsOneWidget);
      expect(find.text('amina.wambui@gmail.com'), findsOneWidget);
      expect(find.text('Embakasi, Nairobi'), findsOneWidget);
    });

    testWidgets('the care-team sections stay out without fields', (
      tester,
    ) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/details',
      );
      await tester.pumpAndSettle();

      for (final text in [
        'For my care team',
        'Blood group',
        'Allergies',
        'In an emergency',
        'Health cover',
      ]) {
        expect(find.text(text), findsNothing, reason: text);
      }
    });

    testWidgets('the pencil opens the edit screen', (tester) async {
      tallView(tester);
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile/details',
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is CircleIconButton &&
              widget.icon == Assets.icons.editIcon,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('a bad birth date degrades to dateless text', (tester) async {
      tallView(tester);
      final session = PatientSession(
        patient: RoleSessions.patient.patient.copyWith(
          dateOfBirth: 'not-a-date',
        ),
        roles: RoleSessions.patient.roles,
      );
      await tester.pumpRoleApp(session, '/patient/profile/details');
      await tester.pumpAndSettle();

      expect(find.text('Embakasi'), findsOneWidget);
      expect(find.text('Embakasi, Nairobi'), findsOneWidget);
      expect(find.text('not-a-date'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Swahili in dark mode at 1.3x text', (
      tester,
    ) async {
      tallView(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(
        fullSession(),
        '/patient/profile/details',
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Wasifu wangu'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
