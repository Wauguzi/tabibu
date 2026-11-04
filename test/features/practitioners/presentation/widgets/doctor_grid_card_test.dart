import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/doctor_grid_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DoctorGridCard', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      VoidCallback? onTap,
      ThemeMode themeMode = ThemeMode.light,
    }) {
      return tester.pumpApp(
        SizedBox(
          width: 180,
          child: DoctorGridCard(
            name: 'Dr. James Otieno',
            specialty: 'General physician',
            onTap: onTap ?? () {},
          ),
        ),
        themeMode: themeMode,
      );
    }

    testWidgets('renders name and specialty', (tester) async {
      await pumpCard(tester);
      expect(find.text('Dr. James Otieno'), findsOneWidget);
      expect(find.text('General physician'), findsOneWidget);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await pumpCard(tester, onTap: () => taps++);
      await tester.tap(find.byType(DoctorGridCard));
      expect(taps, 1);
    });

    testWidgets('announces name and specialty as a button', (tester) async {
      await pumpCard(tester);
      expect(
        tester.getSemantics(find.byType(DoctorGridCard)),
        matchesSemantics(
          label: 'Dr. James Otieno, General physician',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await pumpCard(tester, themeMode: mode);
        expect(find.byType(DoctorGridCard), findsOneWidget);
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
        const SizedBox(
          width: 180,
          child: DoctorGridCard(
            name: 'Dr. James Otieno',
            specialty: 'General physician',
            onTap: _noop,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('a long name keeps to one line, so cards keep one height', (
      tester,
    ) async {
      Future<double> heightFor(String name) async {
        await tester.pumpApp(
          Center(
            child: SizedBox(
              width: 170,
              child: DoctorGridCard(
                name: name,
                specialty: 'General practice',
                onTap: () {},
              ),
            ),
          ),
        );
        return tester.getSize(find.byType(DoctorGridCard)).height;
      }

      final short = await heightFor('Dr. Ann Mutua');
      final long = await heightFor(
        'Dr. Wanjiru Kamau-Njoroge Wambui Achieng Odhiambo',
      );
      expect(long, short);
      final text = tester.widget<Text>(
        find.text('Dr. Wanjiru Kamau-Njoroge Wambui Achieng Odhiambo'),
      );
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}

void _noop() {}
