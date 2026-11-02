import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/features/worklist/presentation/widgets/case_thumb.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('CaseThumb', () {
    testWidgets('shows the test-tube placeholder without an image', (
      tester,
    ) async {
      await tester.pumpApp(const CaseThumb(rank: 2));
      expect(find.byType(CaseThumb), findsOneWidget);
      expect(
        tester.widget<AssetIcon>(find.byType(AssetIcon)).asset,
        Assets.icons.testTubeIcon,
      );
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('rank badge is decorative', (tester) async {
      await tester.pumpApp(const CaseThumb(rank: 3));
      expect(find.text('3'), findsOneWidget);
      expect(find.byType(ExcludeSemantics), findsWidgets);
    });

    testWidgets('renders in light and dark', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(const CaseThumb(rank: 1), themeMode: mode);
        expect(find.byType(CaseThumb), findsOneWidget);
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

      await tester.pumpApp(const CaseThumb(rank: 12));
      expect(tester.takeException(), isNull);
    });
  });
}
