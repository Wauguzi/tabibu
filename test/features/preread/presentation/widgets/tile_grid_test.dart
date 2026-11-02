import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/dashed_border.dart';
import 'package:tabibu/features/preread/presentation/widgets/tile_grid.dart';

import '../../../../helpers/helpers.dart';

void main() {
  const tiles = [
    TileCell(id: 'A1', tone: TileTone.tumour),
    TileCell(id: 'A2', tone: TileTone.normal),
    TileCell(id: 'A3', tone: TileTone.other),
    TileCell(id: 'B1', tone: TileTone.normal, flagged: true),
    TileCell(id: 'B2', tone: TileTone.tumour, unclear: true),
  ];

  Widget grid({ValueChanged<int>? onTap}) {
    return SizedBox(
      width: 390,
      child: TileGrid(
        columns: 3,
        tiles: tiles,
        onTap: onTap ?? (_) {},
        cellLabel: (i) => 'Cell ${tiles[i].id}',
      ),
    );
  }

  group('TileGrid', () {
    testWidgets('renders every tone, flagged and unclear', (tester) async {
      await tester.pumpApp(grid());

      expect(find.text('A1'), findsOneWidget);
      expect(find.text('A2'), findsOneWidget);
      expect(find.text('A3'), findsOneWidget);
      expect(find.text('B1'), findsOneWidget);
      expect(find.text('B2'), findsOneWidget);
      expect(find.byType(DashedBorder), findsOneWidget);
    });

    testWidgets('taps report the index and announce caller labels', (
      tester,
    ) async {
      final tapped = <int>[];
      await tester.pumpApp(grid(onTap: tapped.add));

      await tester.tap(find.text('A3'));
      expect(tapped, [2]);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Cell A1')),
        matchesSemantics(label: 'Cell A1', isButton: true, hasTapAction: true),
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(grid(), themeMode: mode);
        expect(find.byType(TileGrid), findsOneWidget);
      }
    });

    testWidgets('grows at 1.3x text without overflow at 390 dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(grid());
      expect(tester.takeException(), isNull);
    });
  });
}
