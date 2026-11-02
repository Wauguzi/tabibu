import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/practitioners/presentation/widgets/stats_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('StatsCard', () {
    const stats = [
      ('15 yrs', 'Experience'),
      ('EN · SW', 'Languages'),
      ('Level 6', 'Hospital'),
    ];

    testWidgets('renders every value and label', (tester) async {
      await tester.pumpApp(const StatsCard(stats: stats));
      expect(find.text('15 yrs'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('EN · SW'), findsOneWidget);
      expect(find.text('Languages'), findsOneWidget);
      expect(find.text('Level 6'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(const StatsCard(stats: stats), themeMode: mode);
        expect(find.byType(StatsCard), findsOneWidget);
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
        const SizedBox(width: 390, child: StatsCard(stats: stats)),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
