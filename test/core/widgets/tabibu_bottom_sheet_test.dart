import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/core/widgets/tabibu_bottom_sheet.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TabibuBottomSheet', () {
    Future<void> openSheet(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      String? subtitle,
      String? cancelLabel,
    }) async {
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => TabibuBottomSheet.show<void>(
                  context,
                  title: 'Sheet title',
                  closeLabel: 'Close sheet',
                  subtitle: subtitle,
                  cancelLabel: cancelLabel,
                  builder: (_) => const Text('Sheet body'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        themeMode: themeMode,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    Material sheetMaterial(WidgetTester tester) {
      return find
          .byType(Material)
          .evaluate()
          .map((e) => e.widget)
          .whereType<Material>()
          .firstWhere((m) => m.borderRadius != null);
    }

    Finder handleFinder() {
      return find.byWidgetPredicate(
        (w) =>
            w is Container &&
            (w.decoration as BoxDecoration?)?.borderRadius ==
                BorderRadius.circular(2),
      );
    }

    testWidgets('uses the lowest surface with a top-rounded handle', (
      tester,
    ) async {
      await openSheet(tester, subtitle: 'Sheet subtitle', cancelLabel: 'Close');

      expect(find.text('Sheet title'), findsOneWidget);
      expect(find.text('Sheet subtitle'), findsOneWidget);
      expect(find.text('Sheet body'), findsOneWidget);

      final material = sheetMaterial(tester);
      expect(
        material.color,
        buildTheme(Brightness.light).colorScheme.surfaceContainerLowest,
      );
      expect(
        material.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
      );

      expect(tester.getSize(handleFinder()), const Size(40, 4));

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
    });

    testWidgets('closes from its labelled close control', (tester) async {
      await openSheet(tester);

      expect(
        tester.getSemantics(find.byType(CircleIconButton)),
        matchesSemantics(
          label: 'Close sheet',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
    });

    testWidgets('keeps the lowest surface in dark mode', (tester) async {
      await openSheet(tester, themeMode: ThemeMode.dark);

      expect(
        sheetMaterial(tester).color,
        buildTheme(Brightness.dark).colorScheme.surfaceContainerLowest,
      );
      expect(find.text('Sheet title'), findsOneWidget);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await openSheet(
        tester,
        subtitle: 'A subtitle long enough to wrap onto a second line',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
