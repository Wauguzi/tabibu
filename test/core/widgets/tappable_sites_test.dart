import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tappable.dart';

import '../../helpers/helpers.dart';

/// Named under-48 sites from bundle 80: each Tappable must report ≥ 48 dp.
void main() {
  group('Tappable sites', () {
    Future<void> pumpLabel(
      WidgetTester tester,
      String label, {
      double textScale = 1,
    }) async {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpApp(
        Tappable(
          onTap: () {},
          semanticLabel: label,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final scale in [1.0, 2.0]) {
      testWidgets('pads See all / Compare / Cancel / Forgot PIN at ${scale}x', (
        tester,
      ) async {
        for (final label in [
          'See all',
          'Compare',
          'Cancel appointment',
          'Forgot PIN',
          'Read more',
          'Change photo',
        ]) {
          await pumpLabel(tester, label, textScale: scale);
          final size = tester.getSize(find.byType(Tappable));
          expect(size.width, greaterThanOrEqualTo(48), reason: label);
          expect(size.height, greaterThanOrEqualTo(48), reason: label);
        }
      });
    }

    testWidgets('calendar day cell activates with Enter and Space', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        Tappable(
          onTap: () => taps++,
          semanticLabel: 'Mon, Nov 3, 2026',
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Center(child: Text('3')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(Tappable)).shortestSide,
        greaterThanOrEqualTo(48),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 2);
    });
  });
}
