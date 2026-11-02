import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/fab.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Fab', () {
    Fab fab({VoidCallback? onTap}) => Fab(
      icon: Assets.icons.addIcon,
      semanticLabel: 'Add',
      onTap: onTap ?? () {},
    );

    testWidgets('renders a 64dp ink circle with a white glyph', (tester) async {
      await tester.pumpApp(fab());
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(Fab)), const Size(64, 64));
      final context = tester.element(find.byType(Fab));
      final status = Theme.of(context).extension<AppStatusColors>()!;
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(Fab),
          matching: find.byType(DecoratedBox),
        ),
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, status.ink);
      expect(decoration.boxShadow, hasLength(1));
      expect(decoration.boxShadow!.single, AppShadows.card().single);
      final glyph = tester.widget<AssetIcon>(find.byType(AssetIcon));
      expect(glyph.color, Colors.white);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(fab(onTap: () => taps++));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Fab));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('announces a labelled button', (tester) async {
      await tester.pumpApp(fab());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(Fab)),
        matchesSemantics(
          label: 'Add',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('activates with Enter and Space from the keyboard', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(fab(onTap: () => taps++));
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

    testWidgets('keeps contrast in dark', (tester) async {
      await tester.pumpApp(fab(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Fab));
      final status = Theme.of(context).extension<AppStatusColors>()!;
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(Fab),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((box.decoration as BoxDecoration).color, status.ink);
      final glyph = tester.widget<AssetIcon>(find.byType(AssetIcon));
      expect(glyph.color, AppColors.inkLight);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(fab(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      expect(find.byType(Fab), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(fab());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
