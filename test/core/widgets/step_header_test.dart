import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/core/widgets/step_header.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StepHeader', () {
    testWidgets('renders bars and the count', (tester) async {
      await tester.pumpApp(
        StepHeader(
          step: 2,
          total: 4,
          progressLabel: 'Step 2 of 4',
          backLabel: 'Back',
          onBack: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2/4'), findsOneWidget);
    });

    testWidgets('announces progress and the back button', (tester) async {
      await tester.pumpApp(
        StepHeader(
          step: 2,
          total: 4,
          progressLabel: 'Step 2 of 4',
          backLabel: 'Back',
          onBack: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('2/4')),
        matchesSemantics(label: 'Step 2 of 4'),
      );
      expect(
        tester.getSemantics(find.byType(CircleIconButton)),
        matchesSemantics(
          label: 'Back',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('animates the bars as steps complete', (tester) async {
      var step = 1;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              StepHeader(
                step: step,
                total: 4,
                progressLabel: 'Step $step of 4',
                backLabel: 'Back',
                onBack: () {},
              ),
              TextButton(
                onPressed: () => setState(() => step = 3),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsNWidgets(4));

      await tester.tap(find.text('Next'));
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-animation the count has moved but the bars are still filling.
      expect(find.text('3/4'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('3/4'), findsOneWidget);
    });

    testWidgets('fires onBack', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        StepHeader(
          step: 1,
          total: 4,
          progressLabel: 'Step 1 of 4',
          backLabel: 'Back',
          onBack: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleIconButton).first);
      expect(taps, 1);
    });

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(
        StepHeader(
          step: 1,
          total: 4,
          progressLabel: 'Step 1 of 4',
          backLabel: 'Back',
          onBack: () {},
        ),
        themeMode: ThemeMode.light,
      );
      await tester.pumpAndSettle();
      expect(find.text('1/4'), findsOneWidget);

      await tester.pumpApp(
        StepHeader(
          step: 1,
          total: 4,
          progressLabel: 'Step 1 of 4',
          backLabel: 'Back',
          onBack: () {},
        ),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();
      expect(find.text('1/4'), findsOneWidget);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        StepHeader(
          step: 2,
          total: 4,
          progressLabel: 'Step 2 of 4',
          backLabel: 'Back',
          onBack: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
