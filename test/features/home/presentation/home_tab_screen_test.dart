import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('HomeTabScreen', () {
    // After a pump: the app's delegates load the date symbols.
    String today() => DateFormat('EEE d MMM', 'en').format(DateTime.now());

    testWidgets("greets a patient with their area and today's date", (
      tester,
    ) async {
      await tester.pumpRoleApp(RoleSessions.patient, '/patient');
      await tester.pumpAndSettle();

      expect(find.text('Habari, Amina'), findsOneWidget);
      expect(find.text('Embakasi · ${today()}'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is CircleIconButton && w.semanticLabel == 'Notifications',
        ),
        findsOneWidget,
      );
    });

    testWidgets('greets a doctor by title with their facility', (tester) async {
      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor');
      await tester.pumpAndSettle();

      expect(find.text('Habari, Dr. Kamau'), findsOneWidget);
      expect(
        find.text('${today()} · Aga Khan University Hospital'),
        findsOneWidget,
      );
    });

    testWidgets('reads the date in Kiswahili', (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('sw')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpRoleApp(RoleSessions.doctor(), '/doctor');
      await tester.pumpAndSettle();

      final today = DateFormat('EEE d MMM', 'sw').format(DateTime.now());
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
      await tester.pumpAndSettle();

      expect(find.text('Habari, Dr. Odhiambo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
