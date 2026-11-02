import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/avatar.dart';
import 'package:tabibu/core/widgets/status_chip.dart';
import 'package:tabibu/features/appointments/presentation/widgets/patient_card.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('PatientCard', () {
    testWidgets('shows name, details, initials and chip', (tester) async {
      await tester.pumpApp(
        const PatientCard(
          name: 'Amina Wambui',
          details: '46 · F · Embakasi',
          chip: StatusChip(label: 'Checked in', tone: .signed),
        ),
      );

      expect(find.text('Amina Wambui'), findsOneWidget);
      expect(find.text('46 · F · Embakasi'), findsOneWidget);
      expect(find.text('Checked in'), findsOneWidget);
      expect(find.byType(Avatar), findsOneWidget);
      expect(find.text('AW'), findsOneWidget);
    });

    testWidgets('omits the action row when actions is empty', (tester) async {
      await tester.pumpApp(
        const PatientCard(name: 'Amina Wambui', details: '46 · F · Embakasi'),
      );

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('fires action taps and announces labels', (tester) async {
      var calls = 0;
      await tester.pumpApp(
        PatientCard(
          name: 'Amina Wambui',
          details: '46 · F · Embakasi',
          actions: [
            PatientCardAction(
              icon: Assets.icons.phoneIcon,
              label: 'Call',
              onTap: () => calls++,
            ),
            PatientCardAction(
              icon: Assets.icons.documentIcon,
              label: 'Records',
              onTap: () {},
            ),
          ],
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Call')),
        matchesSemantics(label: 'Call', isButton: true, hasTapAction: true),
      );

      await tester.tap(find.bySemanticsLabel('Call'));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('scrolls five long actions without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: PatientCard(
            name: 'Amina Wambui',
            details: '46 · F · Embakasi',
            actions: [
              for (var i = 0; i < 5; i++)
                PatientCardAction(
                  icon: Assets.icons.phoneIcon,
                  label: 'Very long action label number $i',
                  onTap: () {},
                ),
            ],
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(ListView), const Offset(-200, 0));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const PatientCard(name: 'Amina Wambui', details: '46 · F · Embakasi'),
          themeMode: mode,
        );
        expect(find.byType(PatientCard), findsOneWidget);
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
          child: PatientCard(
            name: 'Amina Wambui',
            details: '46 · F · Embakasi',
            chip: const StatusChip(label: 'Checked in', tone: .signed),
            actions: [
              PatientCardAction(
                icon: Assets.icons.phoneIcon,
                label: 'Call',
                onTap: () {},
              ),
              PatientCardAction(
                icon: Assets.icons.documentIcon,
                label: 'Records',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
