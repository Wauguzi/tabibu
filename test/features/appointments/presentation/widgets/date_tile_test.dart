import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/appointments/presentation/widgets/date_tile.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DateTile', () {
    testWidgets('renders day number and month label', (tester) async {
      await tester.pumpApp(
        DateTile(date: DateTime(2026, 10, 24), monthLabel: 'OCT'),
      );
      expect(find.text('24'), findsOneWidget);
      expect(find.text('OCT'), findsOneWidget);
    });

    testWidgets('announces day and month', (tester) async {
      await tester.pumpApp(
        DateTile(date: DateTime(2026, 10, 24), monthLabel: 'OCT'),
      );
      expect(
        tester.getSemantics(find.byType(DateTile)),
        matchesSemantics(label: '24 OCT'),
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          DateTile(date: DateTime(2026, 10, 24), monthLabel: 'OCT'),
          themeMode: mode,
        );
        expect(find.byType(DateTile), findsOneWidget);
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
        DateTile(date: DateTime(2026, 10, 24), monthLabel: 'OCT'),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
