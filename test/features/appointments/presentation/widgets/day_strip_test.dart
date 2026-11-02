import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_strip.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DayStrip', () {
    const days = [
      DayOption(weekday: 'Mon', day: '26', available: true),
      DayOption(weekday: 'Wed', day: '28', available: false),
      DayOption(weekday: 'Thu', day: '29', available: true),
    ];

    testWidgets('renders weekday and day labels', (tester) async {
      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: DayStrip(days: days, selected: 2, onSelected: (_) {}),
        ),
      );
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
    });

    testWidgets('fires onSelected for available days only', (tester) async {
      final selected = <int>[];
      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: DayStrip(days: days, selected: 0, onSelected: selected.add),
        ),
      );

      await tester.tap(find.text('29'));
      expect(selected, [2]);

      await tester.tap(find.text('28'));
      expect(selected, [2]);
    });

    testWidgets('unavailable day is disabled', (tester) async {
      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: DayStrip(days: days, selected: 0, onSelected: (_) {}),
        ),
      );
      expect(
        tester.getSemantics(find.text('Wed')),
        matchesSemantics(
          label: 'Wed 28',
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
        ),
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          SizedBox(
            width: 390,
            child: DayStrip(days: days, selected: 0, onSelected: (_) {}),
          ),
          themeMode: mode,
        );
        expect(find.byType(DayStrip), findsOneWidget);
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
          child: DayStrip(days: days, selected: 0, onSelected: (_) {}),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
