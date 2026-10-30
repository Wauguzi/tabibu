import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_gradients.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/widgets/pattern_card.dart';

import '../../helpers/helpers.dart';

void main() {
  group('PatternCard', () {
    testWidgets('paints the hero gradient under content', (tester) async {
      await tester.pumpApp(const PatternCard(child: Text('Hero content')));

      expect(find.text('Hero content'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final clipped = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipped.borderRadius, BorderRadius.circular(AppRadii.hero));

      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(PatternCard),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient = (box.decoration as BoxDecoration).gradient;
      expect(gradient, AppGradients.tealHero);
    });

    testWidgets('deepens the hero in dark mode', (tester) async {
      await tester.pumpApp(
        const PatternCard(child: Text('Hero content')),
        themeMode: ThemeMode.dark,
      );

      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(PatternCard),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient = (box.decoration as BoxDecoration).gradient;
      expect(gradient, AppGradients.tealHeroDark);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const PatternCard(child: Text('A long hero line that must wrap')),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
