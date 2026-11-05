import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/hero_carousel.dart';
import 'package:tabibu/core/widgets/page_dots.dart';

import '../../helpers/helpers.dart';

void main() {
  group('HeroCarousel', () {
    testWidgets('shows one slide with no dots', (tester) async {
      await tester.pumpApp(const HeroCarousel(slides: [Text('One')]));
      await tester.pumpAndSettle();

      expect(find.text('One'), findsOneWidget);
      expect(find.byType(PageDots), findsNothing);
      expect(tester.getSize(find.byType(PageView)), const Size(800, 240));
    });

    testWidgets('keeps a gap between neighbouring slides', (tester) async {
      const first = Key('first-slide');
      const second = Key('second-slide');
      await tester.pumpApp(
        const HeroCarousel(
          slides: [
            ColoredBox(key: first, color: Color(0xFFFF0000)),
            ColoredBox(key: second, color: Color(0xFF0000FF)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final left = tester.getRect(find.byKey(first));
      final right = tester.getRect(find.byKey(second));
      expect(right.left - left.right, AppSpacing.bentoGap);
    });

    testWidgets('shows dots for two slides and swiping moves the current dot', (
      tester,
    ) async {
      await tester.pumpApp(
        const HeroCarousel(slides: [Text('One'), Text('Two')]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsNWidgets(2));
      PageDots dots() => tester.widget<PageDots>(find.byType(PageDots));
      expect(dots().index, 0);

      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(dots().index, 1);
    });

    testWidgets('uses a custom height', (tester) async {
      await tester.pumpApp(
        const HeroCarousel(slides: [Text('One')], height: 300),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(PageView)), const Size(800, 300));
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        const HeroCarousel(slides: [Text('One'), Text('Two')]),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('One'), findsOneWidget);
      expect(find.byType(PageDots), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const HeroCarousel(slides: [Text('Moja'), Text('Ripoti')]),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Moja'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const HeroCarousel(slides: [Text('One'), Text('Two')]),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
