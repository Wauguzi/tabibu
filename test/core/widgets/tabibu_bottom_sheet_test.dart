import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/theme_builder.dart';
import 'package:tabibu/core/widgets/widgets.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TabibuBottomSheet', () {
    // Results are captured, not awaited: awaiting a route's future inside a
    // widget test blocks until a pump that never comes.
    Future<List<String?>> openSheet(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      String? subtitle,
      String? cancelLabel,
      Widget Function(BuildContext context)? builder,
    }) async {
      final results = <String?>[];
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => TabibuBottomSheet.show<String>(
                  context,
                  title: 'Sheet title',
                  subtitle: subtitle,
                  cancelLabel: cancelLabel,
                  builder: builder ?? (_) => const Text('Sheet body'),
                ).then(results.add),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        themeMode: themeMode,
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);
      return results;
    }

    testWidgets(
      'shows the title, subtitle and content, with no close control',
      (tester) async {
        await openSheet(tester, subtitle: 'Sheet subtitle');

        expect(find.text('Sheet title'), findsOneWidget);
        expect(find.text('Sheet subtitle'), findsOneWidget);
        expect(find.text('Sheet body'), findsOneWidget);
        expect(find.byType(CircleIconButton), findsNothing);
      },
    );

    testWidgets('dismisses on a drag down', (tester) async {
      final results = await openSheet(tester);

      await tester.fling(find.text('Sheet title'), const Offset(0, 500), 1500);
      await settleSheet(tester);

      expect(find.text('Sheet body'), findsNothing);
      expect(results, [null]);
    });

    testWidgets('dismisses on back', (tester) async {
      final results = await openSheet(tester);

      await tester.binding.handlePopRoute();
      await settleSheet(tester);

      expect(find.text('Sheet body'), findsNothing);
      expect(results, [null]);
    });

    testWidgets('Cancel dismisses with no value', (tester) async {
      final results = await openSheet(tester, cancelLabel: 'Cancel');

      await tester.tap(find.text('Cancel'));
      await settleSheet(tester);

      expect(find.text('Sheet body'), findsNothing);
      expect(results, [null]);
    });

    testWidgets('returns the value popped from the content', (tester) async {
      final results = await openSheet(
        tester,
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).pop('picked'),
          child: const Text('Pick'),
        ),
      );

      await tester.tap(find.text('Pick'));
      await settleSheet(tester);

      expect(results, ['picked']);
    });

    testWidgets('uses the lowest surface in dark mode', (tester) async {
      await openSheet(tester, themeMode: ThemeMode.dark);

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(TabibuBottomSheet),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(
        material.color,
        buildTheme(Brightness.dark).colorScheme.surfaceContainerLowest,
      );
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

/// Cupertino sheet routes keep scheduling frames, so pumpAndSettle never
/// returns; this pumps past the transition instead.
Future<void> settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}
