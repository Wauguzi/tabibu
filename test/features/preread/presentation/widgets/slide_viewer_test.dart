import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/features/preread/presentation/widgets/slide_viewer.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

void main() {
  // 1x1 PNG.
  final okBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
    // cspell:disable-next-line
    '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );
  final okImage = MemoryImage(Uint8List.fromList(okBytes));
  final badImage = MemoryImage(Uint8List.fromList([1, 2, 3]));

  Widget viewer({
    required bool heatmapOn,
    required ValueChanged<bool> onHeatmapChanged,
    VoidCallback? onTiles,
    ImageProvider? image,
    ImageProvider? heatmap,
  }) {
    return SizedBox(
      width: 390,
      child: SlideViewer(
        image: image ?? okImage,
        heatmap: heatmap,
        heatmapOn: heatmapOn,
        onHeatmapChanged: onHeatmapChanged,
        heatmapLabel: 'Heat map',
        tilesLabel: 'Tiles',
        onTiles: onTiles ?? () {},
        scaleLabel: 'x20 · 1 mm',
        legendLow: 'Normal',
        legendHigh: 'Likely tumour',
        zoomInLabel: 'Zoom in',
        zoomOutLabel: 'Zoom out',
      ),
    );
  }

  group('SlideViewer', () {
    testWidgets('toggle calls back', (tester) async {
      var on = true;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) {
            return viewer(
              heatmapOn: on,
              onHeatmapChanged: (v) => setState(() => on = v),
            );
          },
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(on, isFalse);
    });

    testWidgets('tiles tap fires', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        viewer(
          heatmapOn: false,
          onHeatmapChanged: (_) {},
          onTiles: () => taps++,
        ),
      );
      await tester.tap(find.text('Tiles'));
      expect(taps, 1);
    });

    testWidgets('zoom buttons change scale and stop at the bounds', (
      tester,
    ) async {
      await tester.pumpApp(viewer(heatmapOn: false, onHeatmapChanged: (_) {}));
      await tester.pumpAndSettle();

      final viewerWidget = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final controller = viewerWidget.transformationController!;
      expect(controller.value.getMaxScaleOnAxis(), 1);

      for (var i = 0; i < 20; i++) {
        await tester.tap(find.bySemanticsLabel('Zoom in'));
        await tester.pump();
      }
      expect(controller.value.getMaxScaleOnAxis(), SlideViewer.maxScale);

      for (var i = 0; i < 30; i++) {
        await tester.tap(find.bySemanticsLabel('Zoom out'));
        await tester.pump();
      }
      expect(controller.value.getMaxScaleOnAxis(), SlideViewer.minScale);
    });

    testWidgets('failing image shows the photo fallback', (tester) async {
      await tester.pumpApp(
        viewer(heatmapOn: false, onHeatmapChanged: (_) {}, image: badImage),
      );
      await tester.pump();
      // Image resolves asynchronously; give the errorBuilder a beat.
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        tester
            .widgetList<AssetIcon>(find.byType(AssetIcon))
            .any((icon) => icon.asset == Assets.icons.photoIcon),
        isTrue,
      );
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          viewer(heatmapOn: true, onHeatmapChanged: (_) {}, heatmap: okImage),
          themeMode: mode,
        );
        expect(find.byType(SlideViewer), findsOneWidget);
        expect(find.text('Normal'), findsOneWidget);
        expect(find.text('Likely tumour'), findsOneWidget);
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

      await tester.pumpApp(
        SizedBox(
          width: 390,
          child: viewer(heatmapOn: false, onHeatmapChanged: (_) {}),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
