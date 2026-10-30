import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/widgets/glass_container.dart';

import '../../helpers/helpers.dart';

BoxDecoration glassDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(BackdropFilter),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('GlassContainer', () {
    testWidgets('clips, tints and blurs at 2.0x without overflow', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const Center(
          child: GlassContainer(
            radius: 24,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Behind glass'),
            ),
          ),
        ),
      );

      expect(find.text('Behind glass'), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);

      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(filter.filter, ImageFilter.blur(sigmaX: 30, sigmaY: 30));

      final clipped = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipped.borderRadius, BorderRadius.circular(24));

      final decoration = glassDecoration(tester);
      expect(decoration.color, AppColors.glassTintLight);
      expect(
        (decoration.border! as Border).top.color,
        AppColors.glassBorderLight,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('dims the shell in dark mode', (tester) async {
      await tester.pumpApp(
        const Center(child: GlassContainer(child: Text('Dark glass'))),
        themeMode: ThemeMode.dark,
      );

      final decoration = glassDecoration(tester);
      expect(decoration.color, AppColors.glassTintDark);
      expect(
        (decoration.border! as Border).top.color,
        AppColors.glassBorderDark,
      );
    });
  });
}
