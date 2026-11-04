import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/core/widgets/shortcut_tile.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ShortcutTile', () {
    ShortcutTile tile({VoidCallback? onTap, bool tall = false}) {
      return ShortcutTile(
        icon: Assets.icons.calendarIcon,
        tone: IconTone.sky,
        title: 'Booking requests',
        body: '2 new today',
        value: '2',
        badge: const Text('New'),
        illustration: const Text('Art'),
        onTap: onTap,
        tall: tall,
      );
    }

    Finder arrowFinder() => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).shape == BoxShape.circle,
    );

    Finder buttonFinder() => find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.button == true,
    );

    testWidgets('renders every slot in the tone pastel', (tester) async {
      await tester.pumpApp(tile(onTap: () {}, tall: true));
      await tester.pumpAndSettle();

      expect(find.text('Booking requests'), findsOneWidget);
      expect(find.text('2 new today'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Art'), findsOneWidget);

      final context = tester.element(find.byType(ShortcutTile));
      final scheme = Theme.of(context).colorScheme;
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ShortcutTile),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = card.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.skyLight);
      expect(decoration.borderRadius, BorderRadius.circular(AppRadii.tile));
      expect(decoration.boxShadow, isNull);

      final value = tester.widget<Text>(find.text('2'));
      expect(value.style?.fontSize, 40);
      expect(value.style?.fontWeight, FontWeight.w700);
      expect(value.style?.color, scheme.onSurface);
      final title = tester.widget<Text>(find.text('Booking requests'));
      expect(title.style?.fontSize, 16);
      final body = tester.widget<Text>(find.text('2 new today'));
      expect(body.style?.fontSize, 13);
    });

    testWidgets('shows the arrow only with a tap', (tester) async {
      await tester.pumpApp(tile());
      await tester.pumpAndSettle();
      expect(arrowFinder(), findsNothing);

      await tester.pumpApp(tile(onTap: () {}));
      await tester.pumpAndSettle();
      expect(arrowFinder(), findsOneWidget);
      expect(tester.getSize(arrowFinder()), const Size(36, 36));
      final arrow = tester.widget<AssetIcon>(
        find.byWidgetPredicate(
          (w) => w is AssetIcon && w.asset == Assets.icons.arrowUpRightIcon,
        ),
      );
      expect(arrow.size, 14);
    });

    testWidgets('is a button only with a tap', (tester) async {
      await tester.pumpApp(tile());
      await tester.pumpAndSettle();
      expect(buttonFinder(), findsNothing);

      await tester.pumpApp(tile(onTap: () {}));
      await tester.pumpAndSettle();
      expect(buttonFinder(), findsOneWidget);
      final semantics = tester.widget<Semantics>(buttonFinder());
      expect(semantics.properties.enabled, isTrue);
    });

    testWidgets('fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpApp(tile(onTap: () => taps++, tall: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Booking requests'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('renders a metric tile with no arrow or button', (
      tester,
    ) async {
      await tester.pumpApp(
        ShortcutTile(
          icon: Assets.icons.documentIcon,
          tone: IconTone.white,
          title: 'Tumour tiles',
          body: 'AI counted',
          value: '14/48',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tumour tiles'), findsOneWidget);
      expect(find.text('14/48'), findsOneWidget);
      expect(find.text('AI counted'), findsOneWidget);
      expect(arrowFinder(), findsNothing);
      expect(buttonFinder(), findsNothing);
    });

    testWidgets('shows the illustration only when tall', (tester) async {
      await tester.pumpApp(tile(onTap: () {}, tall: true));
      await tester.pumpAndSettle();
      expect(find.text('Art'), findsOneWidget);

      await tester.pumpApp(tile(onTap: () {}));
      await tester.pumpAndSettle();
      expect(find.text('Art'), findsNothing);
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        tile(onTap: () {}, tall: true),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking requests'), findsOneWidget);
      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ShortcutTile),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, AppColors.skyDark);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        ShortcutTile(
          icon: Assets.icons.calendarIcon,
          tone: IconTone.sky,
          title: 'Matokeo yako',
          body: 'Ripoti tayari',
          value: '3',
          badge: const Text('Moja'),
          illustration: const Text('Ripoti'),
          onTap: () {},
          tall: true,
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Matokeo yako'), findsOneWidget);
      expect(find.text('Ripoti tayari'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        ShortcutTile(
          icon: Assets.icons.calendarIcon,
          tone: IconTone.sky,
          title: 'A very long tile title that must wrap across lines',
          body: 'A very long tile body that must wrap across lines too',
          value: '14/48',
          badge: const Text('New'),
          illustration: const Text('Art'),
          onTap: () {},
          tall: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('ShortcutTile icon colours', () {
    for (final dark in [false, true]) {
      testWidgets('${dark ? 'dark' : 'light'}: glyph and tile contrast', (
        tester,
      ) async {
        await tester.pumpApp(
          ShortcutTile(
            icon: Assets.icons.calendarIcon,
            tone: IconTone.sky,
            title: 'Booking requests',
            onTap: () {},
          ),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        );
        await tester.pumpAndSettle();

        final icons = tester
            .widgetList<AssetIcon>(find.byType(AssetIcon))
            .toList();
        final tile = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere(
              (c) =>
                  c.constraints?.maxWidth == 44 &&
                  c.decoration is BoxDecoration,
            );
        final fill = (tile.decoration! as BoxDecoration).color;
        // The icon and the arrow share the glyph colour.
        for (final icon in icons) {
          expect(icon.color, dark ? AppColors.white : AppColors.inkLight);
        }
        expect(fill, dark ? AppColors.black : isNot(AppColors.black));
      });
    }
  });

  group('ShortcutBento', () {
    ShortcutBento bento() => ShortcutBento(
      tall: Container(key: const ValueKey('tall'), height: 200),
      top: Container(key: const ValueKey('top'), height: 80),
      bottom: Container(key: const ValueKey('bottom'), height: 80),
    );

    testWidgets('lays tall left and a stacked pair right', (tester) async {
      await tester.pumpApp(bento());
      await tester.pumpAndSettle();

      for (final key in ['tall', 'top', 'bottom']) {
        expect(find.byKey(ValueKey(key)), findsOneWidget);
      }
      final cells = find.byType(Expanded);
      // Two columns, then the pair's two rows.
      expect(cells.evaluate().length, 4);
      final left = tester.getSize(cells.at(0));
      final right = tester.getSize(cells.at(1));
      // The taller side sets the height and the other fills it.
      expect(left.height, 200);
      expect(right.height, 200);
      expect(left.width, right.width);
      const half = (200 - AppSpacing.bentoGap) / 2;
      expect(tester.getSize(find.byKey(const ValueKey('top'))).height, half);
      expect(tester.getSize(find.byKey(const ValueKey('bottom'))).height, half);
      expect(
        tester.getSize(find.byKey(const ValueKey('top'))).width,
        right.width,
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect((row.children[1] as SizedBox).width, AppSpacing.bentoGap);
      final column = tester.widget<Column>(find.byType(Column));
      expect((column.children[1] as SizedBox).height, AppSpacing.bentoGap);
    });

    testWidgets('a tall tile fills a taller pair and sits its words low', (
      tester,
    ) async {
      await tester.pumpApp(
        ShortcutBento(
          tall: ShortcutTile(
            key: const ValueKey('tall'),
            icon: Assets.icons.documentIcon,
            tone: IconTone.lavender,
            title: 'Reports ready',
            value: '2',
            tall: true,
          ),
          top: Container(key: const ValueKey('top'), height: 120),
          bottom: Container(key: const ValueKey('bottom'), height: 120),
        ),
      );
      await tester.pumpAndSettle();

      final tall = tester.getRect(find.byKey(const ValueKey('tall')));
      final pair = tester
          .getRect(find.byKey(const ValueKey('top')))
          .expandToInclude(
            tester.getRect(find.byKey(const ValueKey('bottom'))),
          );
      expect(tall.bottom, pair.bottom);
      expect(tall.top, pair.top);
      // The title rests near the tile's foot, not under the icon.
      final title = tester.getRect(find.text('Reports ready'));
      expect(tall.bottom - title.bottom, lessThan(AppSpacing.lg));
    });

    testWidgets('a short tile sits its words at the foot, no band below', (
      tester,
    ) async {
      await tester.pumpApp(
        ShortcutBento(
          tall: Container(height: 200),
          top: ShortcutTile(
            key: const ValueKey('top'),
            icon: Assets.icons.calendarIcon,
            tone: IconTone.sky,
            title: 'Booking requests',
            body: '2 new today',
            onTap: () {},
          ),
          bottom: Container(height: 40),
        ),
      );
      await tester.pumpAndSettle();

      final tile = tester.getRect(find.byKey(const ValueKey('top')));
      final body = tester.getRect(find.text('2 new today'));
      expect(tile.bottom - body.bottom, lessThan(AppSpacing.lg));
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(bento(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('tall')), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const ShortcutBento(
          tall: Text('Moja'),
          top: Text('Ripoti'),
          bottom: Text('Tayari'),
        ),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

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

      ShortcutTile cell(String title) => ShortcutTile(
        icon: Assets.icons.calendarIcon,
        tone: IconTone.sky,
        title: title,
        body: 'A long body that must wrap inside its narrow column',
        value: '14/48',
        onTap: () {},
      );
      await tester.pumpApp(
        SingleChildScrollView(
          child: ShortcutBento(
            tall: cell('A long tall title that must wrap'),
            top: cell('A long top title that must wrap'),
            bottom: cell('A long bottom title that must wrap'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
