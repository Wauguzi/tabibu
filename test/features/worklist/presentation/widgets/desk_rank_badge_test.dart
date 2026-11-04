import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/features/worklist/presentation/widgets/desk_rank_badge.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('DeskRankBadge', () {
    testWidgets('shows the rank on an ink circle and is decorative', (
      tester,
    ) async {
      await tester.pumpApp(const DeskRankBadge(rank: 7));
      final status = Theme.of(
        tester.element(find.byType(DeskRankBadge)),
      ).extension<AppStatusColors>()!;

      expect(find.text('7'), findsOneWidget);
      final circle = tester.widget<Container>(find.byType(Container));
      expect((circle.decoration! as BoxDecoration).color, status.ink);
      expect(
        find.descendant(
          of: find.byType(DeskRankBadge),
          matching: find.byType(ExcludeSemantics),
        ),
        findsWidgets,
      );
    });

    testWidgets('lesson 1: ink-on-light digits in dark, white in light', (
      tester,
    ) async {
      await tester.pumpApp(const DeskRankBadge(rank: 2));
      expect(tester.widget<Text>(find.text('2')).style?.color, AppColors.white);

      await tester.pumpApp(
        const DeskRankBadge(rank: 2),
        themeMode: ThemeMode.dark,
      );
      expect(
        tester.widget<Text>(find.text('2')).style?.color,
        AppColors.inkLight,
      );
    });

    testWidgets('three digits at 1.3x stay inside the circle', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const DeskRankBadge(rank: 128));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Container)), const Size(28, 28));
    });
  });
}
