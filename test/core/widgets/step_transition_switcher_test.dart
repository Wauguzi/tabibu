import 'package:animations/animations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/step_transition_switcher.dart';

import '../../helpers/helpers.dart';

void main() {
  group('StepTransitionSwitcher', () {
    Future<void> pumpFlow(
      WidgetTester tester, {
      bool reverse = false,
      bool disableAnimations = false,
    }) async {
      var step = 0;
      var back = false;
      await tester.pumpApp(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                Expanded(
                  child: StepTransitionSwitcher(
                    reverse: back,
                    child: Text('Step $step', key: ValueKey(step)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    back = reverse;
                    step = 1;
                  }),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pump();
    }

    testWidgets('slides forward on a shared axis', (tester) async {
      await pumpFlow(tester);

      // Mid-transition both steps share the frame inside a shared-axis
      // transition.
      expect(find.text('Step 0'), findsOneWidget);
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.byType(SharedAxisTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('Step 0'), findsNothing);
      expect(find.text('Step 1'), findsOneWidget);
    });

    testWidgets('slides back when reversing', (tester) async {
      await pumpFlow(tester, reverse: true);

      expect(find.text('Step 0'), findsOneWidget);
      expect(find.text('Step 1'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Step 1'), findsOneWidget);
    });

    testWidgets('cross-fades in place with reduced motion', (tester) async {
      await pumpFlow(tester, disableAnimations: true);

      expect(find.byType(SharedAxisTransition), findsNothing);
      expect(find.byType(FadeTransition), findsWidgets);

      await tester.pumpAndSettle();
      expect(find.text('Step 1'), findsOneWidget);
    });
  });
}
