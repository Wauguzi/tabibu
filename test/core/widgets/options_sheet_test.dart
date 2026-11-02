import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/options_sheet.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('showOptionsSheet', () {
    List<OptionsAction<String>> actions() => [
      OptionsAction(
        value: 'mdt',
        icon: Assets.icons.mdtIcon,
        label: 'Open MDT chat',
        supporting: 'Talk it through with the team',
      ),
      OptionsAction(
        value: 'delete',
        icon: Assets.icons.deleteIcon,
        label: 'Delete case',
        destructive: true,
      ),
    ];

    Finder rowFinder(ColorScheme scheme) => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color ==
              scheme.surfaceContainerLow &&
          (w.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(AppRadii.field),
    );

    // Results are captured, not awaited: awaiting a route's future inside a
    // widget test blocks until a pump that never comes.
    Future<List<String?>> openSheet(
      WidgetTester tester, {
      ThemeMode themeMode = ThemeMode.light,
      Locale? locale,
      String? subtitle,
    }) async {
      final results = <String?>[];
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => showOptionsSheet<String>(
                  context,
                  title: 'Case options',
                  subtitle: subtitle,
                  actions: actions(),
                ).then(results.add),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        themeMode: themeMode,
        locale: locale,
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);
      return results;
    }

    testWidgets('opens with filled rows', (tester) async {
      await openSheet(tester, subtitle: 'TB-0231');

      expect(find.text('Case options'), findsOneWidget);
      expect(find.text('TB-0231'), findsOneWidget);
      expect(find.text('Open MDT chat'), findsOneWidget);
      expect(find.text('Talk it through with the team'), findsOneWidget);
      expect(find.text('Delete case'), findsOneWidget);
      expect(find.byType(IconTile), findsNWidgets(2));
      expect(
        find.byWidgetPredicate(
          (w) => w is AssetIcon && w.asset == Assets.icons.forwardIcon,
        ),
        findsNWidgets(2),
      );

      final context = tester.element(find.text('Case options'));
      final scheme = Theme.of(context).colorScheme;
      expect(rowFinder(scheme), findsNWidgets(2));
      expect(
        tester.getSize(rowFinder(scheme).first).height,
        greaterThanOrEqualTo(72),
      );
    });

    testWidgets('tapping a row returns its value', (tester) async {
      final results = await openSheet(tester);

      await tester.tap(find.text('Open MDT chat'));
      await settleSheet(tester);

      expect(results, ['mdt']);
      expect(find.text('Case options'), findsNothing);
    });

    testWidgets('paints a destructive row red', (tester) async {
      await openSheet(tester);

      final context = tester.element(find.text('Delete case'));
      final scheme = Theme.of(context).colorScheme;
      final label = tester.widget<Text>(find.text('Delete case'));
      expect(label.style?.color, scheme.error);
      final tiles = tester.widgetList<IconTile>(find.byType(IconTile)).toList();
      expect(tiles[0].tone, IconTone.lavender);
      expect(tiles[1].tone, IconTone.danger);
    });

    testWidgets('renders in dark', (tester) async {
      await openSheet(tester, themeMode: ThemeMode.dark);

      expect(find.text('Case options'), findsOneWidget);
      expect(find.text('Open MDT chat'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      final results = <String?>[];
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => showOptionsSheet<String>(
                  context,
                  title: 'Chagua',
                  actions: [
                    OptionsAction(
                      value: 'one',
                      icon: Assets.icons.mdtIcon,
                      label: 'Moja',
                    ),
                  ],
                ).then(results.add),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        locale: const Locale('sw'),
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);

      expect(find.text('Chagua'), findsOneWidget);
      expect(find.text('Moja'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final results = <String?>[];
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () => showOptionsSheet<String>(
                  context,
                  title: 'A very long sheet title that must wrap',
                  subtitle: 'A very long sheet subtitle that must wrap too',
                  actions: [
                    OptionsAction(
                      value: 'one',
                      icon: Assets.icons.mdtIcon,
                      label: 'A very long action label that must wrap',
                      supporting:
                          'A very long supporting line that must wrap as well',
                    ),
                    OptionsAction(
                      value: 'two',
                      icon: Assets.icons.deleteIcon,
                      label: 'Another very long action label that wraps',
                      destructive: true,
                    ),
                  ],
                ).then(results.add),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await settleSheet(tester);

      expect(tester.takeException(), isNull);
    });
  });
}

/// Sheets keep scheduling frames, so pumpAndSettle never returns; this pumps
/// past the transition instead.
Future<void> settleSheet(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}
