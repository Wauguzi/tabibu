import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/theme_reveal_transition.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ThemeRevealTransition', () {
    Future<void> pumpReveal(
      WidgetTester tester,
      Brightness brightness, {
      bool disableAnimations = false,
    }) {
      return tester.pumpApp(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: ThemeRevealTransition(
            brightness: brightness,
            child: const Text('Themed content'),
          ),
        ),
      );
    }

    testWidgets('reveals through a snapshot by default', (tester) async {
      await pumpReveal(tester, Brightness.light);
      expect(find.text('Themed content'), findsOneWidget);

      await pumpReveal(tester, Brightness.dark);
      await tester.pump();
      await tester.pump();
      // The previous theme hangs around as a picture mid-reveal.
      expect(find.byType(RawImage), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(RawImage), findsNothing);
      expect(find.text('Themed content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('swaps instantly with reduced motion', (tester) async {
      await pumpReveal(tester, Brightness.light, disableAnimations: true);
      expect(find.text('Themed content'), findsOneWidget);

      await pumpReveal(tester, Brightness.dark, disableAnimations: true);
      await tester.pump();
      await tester.pump();

      expect(find.byType(RawImage), findsNothing);
      expect(find.text('Themed content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
