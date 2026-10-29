import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';

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
  });
}
