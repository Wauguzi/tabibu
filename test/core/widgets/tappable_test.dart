import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tappable.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Tappable', () {
    testWidgets('a child that cannot give intrinsic sizes still lays out', (
      tester,
    ) async {
      await tester.pumpApp(
        Tappable(
          onTap: () {},
          child: LayoutBuilder(
            builder: (_, constraints) => const SizedBox(width: 20, height: 20),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Tappable)).shortestSide, 48);
    });

    testWidgets('a full-width child stays full width', (tester) async {
      await tester.pumpApp(
        Tappable(
          onTap: () {},
          child: const SizedBox(width: double.infinity, height: 60),
        ),
      );
      await tester.pumpAndSettle();

      final width = tester.getSize(find.byType(Tappable)).width;
      final screen =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(width, screen);
    });

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

    testWidgets(
      'pads a 20 dp child to a 48 dp hit target and exposes its label',
      (tester) async {
        await tester.pumpApp(
          Tappable(
            onTap: () {},
            semanticLabel: 'Open day',
            child: const SizedBox(width: 20, height: 20, child: Text('·')),
          ),
        );
        await tester.pumpAndSettle();

        final size = tester.getSize(find.byType(Tappable));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
        expect(
          tester.getSemantics(find.byType(Tappable)),
          matchesSemantics(
            label: 'Open day',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
      },
    );
  });
}
