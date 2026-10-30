import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/tabibu_button.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TabibuButton', () {
    testWidgets('renders all four variants', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            TabibuButton.primary(label: 'Primary', onTap: () {}),
            TabibuButton.secondary(label: 'Secondary', onTap: () {}),
            TabibuButton.outline(label: 'Outline', onTap: () {}),
            TabibuButton.ghost(label: 'Ghost', onTap: () {}),
          ],
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('Ghost'), findsOneWidget);
    });

    testWidgets('fires onTap and stays silent when disabled', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Column(
          children: [
            TabibuButton.primary(label: 'Enabled', onTap: () => taps++),
            const TabibuButton.primary(label: 'Disabled', onTap: null),
          ],
        ),
      );

      await tester.tap(find.text('Enabled'));
      await tester.tap(find.text('Disabled'));
      expect(taps, 1);
    });

    testWidgets('loading swaps the label for a spinner', (tester) async {
      await tester.pumpApp(
        TabibuButton.primary(label: 'Busy', onTap: () {}, isLoading: true),
      );

      expect(find.byType(SpinKitCircle), findsOneWidget);
      expect(find.text('Busy'), findsNothing);
    });

    testWidgets('loading keeps its size and its announcement', (tester) async {
      var loading = false;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              TabibuButton.primary(
                label: 'Busy',
                onTap: () {},
                isLoading: loading,
              ),
              TextButton(
                onPressed: () => setState(() => loading = true),
                child: const Text('Load'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rested = tester.getSize(find.byType(TabibuButton));
      await tester.tap(find.text('Load'));
      await tester.pump();
      expect(tester.getSize(find.byType(TabibuButton)), rested);
      expect(find.byType(SpinKitCircle), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(TabibuButton)),
        matchesSemantics(label: 'Busy', isButton: true, hasEnabledState: true),
      );
    });

    testWidgets('announces a labelled button', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            TabibuButton.primary(label: 'Enabled', onTap: () {}),
            const TabibuButton.primary(label: 'Disabled', onTap: null),
          ],
        ),
      );

      expect(
        tester.getSemantics(find.text('Enabled')),
        matchesSemantics(
          label: 'Enabled',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Disabled')),
        matchesSemantics(
          label: 'Disabled',
          isButton: true,
          hasEnabledState: true,
        ),
      );
    });

    testWidgets('activates with Enter and Space from the keyboard', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        TabibuButton.primary(label: 'Go', onTap: () => taps++),
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

    testWidgets('meets the 48dp floor', (tester) async {
      await tester.pumpApp(TabibuButton.primary(label: 'Tall', onTap: () {}));

      expect(
        tester.getSize(find.byType(TabibuButton)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        TabibuButton.primary(
          label: 'A long label that must wrap, not clip',
          onTap: () {},
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('dims while pressed, and not once disabled mid-press', (
      tester,
    ) async {
      double opacity() =>
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;

      await tester.pumpApp(TabibuButton.primary(label: 'Go', onTap: () {}));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Go')),
      );
      await tester.pump();
      expect(opacity(), 0.6);

      await tester.pumpApp(
        const TabibuButton.primary(label: 'Go', onTap: null),
      );
      expect(opacity(), 1);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(opacity(), 1);
    });
  });
}
