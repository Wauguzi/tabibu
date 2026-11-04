import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_chip_row.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('SlotChipRow', () {
    const slots = [
      SlotOption(label: '9:00 AM', taken: false),
      SlotOption(
        label: '10:30 AM',
        taken: true,
        semanticLabel: '10:30 AM, taken',
      ),
      SlotOption(label: '11:15 AM', taken: false),
    ];

    testWidgets('renders slot labels', (tester) async {
      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: SlotChipRow(slots: slots, selected: 2, onSelected: (_) {}),
        ),
      );
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
      expect(find.text('11:15 AM'), findsOneWidget);
    });

    testWidgets('fires onSelected for free slots only', (tester) async {
      final selected = <int>[];
      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: SlotChipRow(
            slots: slots,
            selected: null,
            onSelected: selected.add,
          ),
        ),
      );

      await tester.tap(find.text('9:00 AM'));
      expect(selected, [0]);

      await tester.tap(find.text('10:30 AM'));
      expect(selected, [0]);
    });

    testWidgets('taken slot announces as taken and disabled', (tester) async {
      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: SlotChipRow(slots: slots, selected: null, onSelected: (_) {}),
        ),
      );
      expect(
        tester.getSemantics(find.text('10:30 AM')),
        matchesSemantics(
          label: '10:30 AM, taken',
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
            child: SlotChipRow(slots: slots, selected: 0, onSelected: (_) {}),
          ),
          themeMode: mode,
        );
        expect(find.byType(SlotChipRow), findsOneWidget);
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
          child: SlotChipRow(slots: slots, selected: 0, onSelected: (_) {}),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
