import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('CircleIconButton', () {
    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        CircleIconButton(
          icon: Assets.icons.backIcon,
          onTap: () => taps++,
          semanticLabel: 'Back',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleIconButton));
      expect(taps, 1);
    });

    testWidgets('announces a labelled button', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            CircleIconButton(
              icon: Assets.icons.backIcon,
              onTap: () {},
              semanticLabel: 'Back',
            ),
            CircleIconButton(
              icon: Assets.icons.backIcon,
              onTap: null,
              semanticLabel: 'Back',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(CircleIconButton).first),
        matchesSemantics(
          label: 'Back',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byType(CircleIconButton).last),
        matchesSemantics(label: 'Back', isButton: true, hasEnabledState: true),
      );
    });

    testWidgets('meets the 48dp floor', (tester) async {
      await tester.pumpApp(
        CircleIconButton(
          icon: Assets.icons.backIcon,
          onTap: () {},
          semanticLabel: 'Back',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(CircleIconButton)), const Size(48, 48));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('activates with Enter and Space from the keyboard', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        CircleIconButton(
          icon: Assets.icons.backIcon,
          onTap: () => taps++,
          semanticLabel: 'Back',
        ),
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

    test('a smaller diameter fails', () {
      expect(
        () => CircleIconButton(
          icon: Assets.icons.backIcon,
          onTap: () {},
          semanticLabel: 'Back',
          diameter: 47,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('sinks onto cards and fills for the primary', (tester) async {
      await tester.pumpApp(
        Row(
          children: [
            CircleIconButton(
              icon: Assets.icons.backIcon,
              onTap: () {},
              semanticLabel: 'Back',
              onCard: true,
            ),
            CircleIconButton(
              icon: Assets.icons.forwardIcon,
              onTap: () {},
              semanticLabel: 'Forward',
              filled: true,
            ),
          ],
        ),
      );

      final context = tester.element(find.byType(Row));
      final scheme = Theme.of(context).colorScheme;
      final status = Theme.of(context).extension<AppStatusColors>()!;
      final materials = tester
          .widgetList<Material>(find.byType(Material))
          .where((m) => m.shape is CircleBorder)
          .toList();
      expect(materials[0].color, scheme.surfaceContainerLow);
      expect(materials[1].color, status.ink);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        CircleIconButton(
          icon: Assets.icons.backIcon,
          onTap: () {},
          semanticLabel: 'Back',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
