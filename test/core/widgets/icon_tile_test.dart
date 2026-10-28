import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/icon_tile.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('IconTile', () {
    testWidgets('renders every size on spec', (tester) async {
      await tester.pumpApp(
        Row(
          children: [
            IconTile(
              icon: Assets.icons.heartIcon,
              tone: IconTone.sky,
              size: IconTileSize.s,
            ),
            IconTile(icon: Assets.icons.heartIcon, tone: IconTone.mint),
            IconTile(
              icon: Assets.icons.heartIcon,
              tone: IconTone.lavender,
              size: IconTileSize.l,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final tiles = find.byType(IconTile);
      expect(tester.getSize(tiles.at(0)), const Size(36, 36));
      expect(tester.getSize(tiles.at(1)), const Size(44, 44));
      expect(tester.getSize(tiles.at(2)), const Size(56, 56));
    });

    testWidgets('renders every tone', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(
          child: Column(
            children: [
              for (final tone in IconTone.values)
                IconTile(icon: Assets.icons.heartIcon, tone: tone),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(IconTile), findsNWidgets(IconTone.values.length));
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        IconTile(icon: Assets.icons.heartIcon, tone: IconTone.sky),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
