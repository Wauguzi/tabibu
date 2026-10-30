import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tappable.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Tappable', () {
    testWidgets('activates with Enter and Space from the keyboard', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        Tappable(onTap: () => taps++, child: const Text('Tap')),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(taps, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 2);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Tappable(onTap: () => taps++, child: const Text('Tap')),
      );

      await tester.tap(find.text('Tap'));
      expect(taps, 1);
    });

    testWidgets('takes no focus and fires nothing when onTap is null', (
      tester,
    ) async {
      await tester.pumpApp(const Tappable(onTap: null, child: Text('Tap')));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(Focus.of(tester.element(find.text('Tap'))).hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('Tap'), findsOneWidget);
    });
  });
}
