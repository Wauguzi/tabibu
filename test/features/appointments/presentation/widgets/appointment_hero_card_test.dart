import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';
import 'package:tabibu/features/appointments/presentation/widgets/appointment_hero_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('AppointmentHeroCard', () {
    testWidgets('renders eyebrow, title, body and actions', (tester) async {
      await tester.pumpApp(
        AppointmentHeroCard(
          eyebrow: 'Next appointment · in 2 days',
          title: 'Thu 29 Oct',
          body: 'Dr. Wanjiru Kamau · Breast surgeon',
          subtitle: '11:15 AM',
          primary: TabibuButton.primary(label: 'Details', onTap: () {}),
          secondary: const SizedBox(width: 48, height: 48),
          progress: const Text('Appointment 3 of 6'),
        ),
      );
      expect(find.text('Next appointment · in 2 days'), findsOneWidget);
      expect(find.text('Thu 29 Oct'), findsOneWidget);
      expect(find.text('Dr. Wanjiru Kamau · Breast surgeon'), findsOneWidget);
      expect(find.text('11:15 AM'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Appointment 3 of 6'), findsOneWidget);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          AppointmentHeroCard(
            eyebrow: 'Now · 11:15 AM',
            title: 'Amina Wambui, 46',
            body: 'Results discussion',
            primary: TabibuButton.primary(label: 'Open', onTap: () {}),
          ),
          themeMode: mode,
        );
        expect(find.byType(AppointmentHeroCard), findsOneWidget);
      }
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: AppointmentHeroCard(
            eyebrow: 'Next appointment · in 2 days',
            title: 'Thu 29 Oct',
            body: 'Dr. Wanjiru Kamau · Breast surgeon, Aga Khan',
            primary: TabibuButton.primary(label: 'Details', onTap: () {}),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
