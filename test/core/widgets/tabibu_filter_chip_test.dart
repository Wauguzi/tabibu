import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tabibu_filter_chip.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TabibuFilterChip', () {
    testWidgets('renders selected and unselected', (tester) async {
      await tester.pumpApp(
        Row(
          children: [
            TabibuFilterChip(label: 'All', selected: true, onTap: () {}),
            TabibuFilterChip(label: 'Nairobi', selected: false, onTap: () {}),
          ],
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Nairobi'), findsOneWidget);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        TabibuFilterChip(label: 'Tap', selected: false, onTap: () => taps++),
      );

      await tester.tap(find.text('Tap'));
      expect(taps, 1);
    });

    testWidgets('announces a selected button', (tester) async {
      await tester.pumpApp(
        Row(
          children: [
            TabibuFilterChip(label: 'All', selected: true, onTap: () {}),
            TabibuFilterChip(label: 'Nairobi', selected: false, onTap: () {}),
          ],
        ),
      );

      expect(
        tester.getSemantics(find.text('All')),
        matchesSemantics(
          label: 'All',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Nairobi')),
        matchesSemantics(
          label: 'Nairobi',
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
    });

    testWidgets('meets the 48dp floor', (tester) async {
      await tester.pumpApp(
        TabibuFilterChip(label: 'Tall', selected: false, onTap: () {}),
      );

      expect(
        tester.getSize(find.byType(TabibuFilterChip)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        TabibuFilterChip(
          label: 'A long label that must wrap, not clip',
          selected: true,
          onTap: () {},
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('activates with Enter from the keyboard', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        TabibuFilterChip(label: 'Tap', selected: false, onTap: () => taps++),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });
}
