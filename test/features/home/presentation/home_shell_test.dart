import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('HomeShell', () {
    List<String?> tabLabels(WidgetTester tester) => [
      for (final element
          in find
              .descendant(
                of: find.byType(FloatingTabBar),
                matching: find.byWidgetPredicate(
                  (w) => w is Semantics && w.properties.button == true,
                ),
              )
              .evaluate())
        (element.widget as Semantics).properties.label,
    ];

    testWidgets('patients get Home, Appointments, Results and Profile', (
      tester,
    ) async {
      await tester.pumpRoleApp(RoleSessions.patient, '/patient');
      await tester.pumpAndSettle();

      expect(tabLabels(tester), ['Home', 'Appointments', 'Results', 'Profile']);
    });

    testWidgets('doctors get Today, Cases, MDT and Profile', (tester) async {
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor');
      await tester.pumpAndSettle();

      expect(tabLabels(tester), ['Today', 'Cases', 'MDT', 'Profile']);
    });

    testWidgets('pathologists get Desk, Signed, MDT and Profile', (
      tester,
    ) async {
      await tester.pumpRoleApp(RoleSessions.pathologist, '/pathologist');
      await tester.pumpAndSettle();

      expect(tabLabels(tester), ['Desk', 'Signed', 'MDT', 'Profile']);
    });

    testWidgets('patients get Kiswahili tabs', (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(RoleSessions.patient, '/patient');
      await tester.pumpAndSettle();

      expect(tabLabels(tester), ['Nyumbani', 'Miadi', 'Majibu', 'Wasifu']);
    });

    testWidgets('a tab opens its screen', (tester) async {
      await tester.pumpRoleApp(RoleSessions.patient, '/patient');
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Results'));
      await tester.pumpAndSettle();
      expect(find.text('Your results'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Your profile'), findsOneWidget);
    });

    testWidgets('each middle tab shows its title', (tester) async {
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor/cases');
      await tester.pumpAndSettle();
      expect(find.text('Cases'), findsWidgets);

      await tester.tap(find.bySemanticsLabel('MDT'));
      await tester.pumpAndSettle();
      expect(find.text('MDT consults'), findsOneWidget);
    });

    testWidgets('back from another tab returns to the first', (tester) async {
      await tester.pumpRoleApp(RoleSessions.pathologist, '/pathologist/mdt');
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Habari, Dr. Odhiambo'), findsOneWidget);
    });

    testWidgets('a tab keeps its state across a tab change', (tester) async {
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/profile');
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable).first;
      await tester.fling(scrollable, const Offset(0, -400), 1000);
      await tester.pumpAndSettle();
      final offset = tester.state<ScrollableState>(scrollable).position.pixels;
      expect(offset, greaterThan(0));

      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      expect(tester.state<ScrollableState>(scrollable).position.pixels, offset);
    });

    testWidgets('tapping the open tab stays on its first screen', (
      tester,
    ) async {
      await tester.pumpRoleApp(RoleSessions.patient, '/patient/results');
      await tester.pumpAndSettle();
      expect(find.text('Your results'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Results'));
      await tester.pumpAndSettle();

      expect(find.text('Your results'), findsOneWidget);
    });

    testWidgets('Sign out is inert while signing out', (tester) async {
      await tester.pumpRoleApp(
        RoleSessions.patient,
        '/patient/profile',
        states: [SignOutInProgress(session: RoleSessions.patient)],
      );
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Sign out'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign out of Tabibu?'), findsNothing);
    });
  });
}
