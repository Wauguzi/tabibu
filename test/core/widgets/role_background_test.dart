import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_gradients.dart';
import 'package:tabibu/core/widgets/role_background.dart';

import '../../helpers/helpers.dart';

LinearGradient backgroundGradient(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(RoleBackground),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).gradient! as LinearGradient;
}

void main() {
  group('RoleBackground', () {
    testWidgets('washes light roles from the top', (tester) async {
      await tester.pumpApp(
        const RoleBackground.patient(child: Text('Patient')),
      );

      final gradient = backgroundGradient(tester);
      expect(gradient.colors[0], AppGradients.skyToLavender.colors[0]);
      expect(gradient.colors[1], AppGradients.skyToLavender.colors[1]);
      expect(find.text('Patient'), findsOneWidget);
    });

    testWidgets('gives each role its wash in both themes', (tester) async {
      final cases = [
        (
          const RoleBackground.patient(child: Text('x')),
          AppGradients.skyToLavender,
          AppGradients.skyToLavenderDark,
        ),
        (
          const RoleBackground.doctor(child: Text('x')),
          AppGradients.mintToSky,
          AppGradients.mintToSkyDark,
        ),
        (
          const RoleBackground.pathologist(child: Text('x')),
          AppGradients.lavenderToMint,
          AppGradients.lavenderToMintDark,
        ),
      ];

      for (final (background, light, dark) in cases) {
        await tester.pumpApp(background, themeMode: ThemeMode.light);
        expect(backgroundGradient(tester).colors[0], light.colors[0]);

        await tester.pumpApp(background, themeMode: ThemeMode.dark);
        expect(backgroundGradient(tester).colors[0], dark.colors[0]);
      }
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const RoleBackground.doctor(child: Text('A long line of content')),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
