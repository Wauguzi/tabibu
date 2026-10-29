import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/onboarding/presentation/intro_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('IntroScreen', () {
    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(const IntroScreen(), themeMode: ThemeMode.light);
      await tester.pumpAndSettle();
      expect(find.text('Only verified clinicians'), findsOneWidget);

      await tester.pumpApp(const IntroScreen(), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Only verified clinicians'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(const IntroScreen(), locale: const Locale('sw'));
      await tester.pumpAndSettle();
      expect(find.text('Wahudumu walioidhinishwa pekee'), findsOneWidget);
    });

    testWidgets('each slide lays out at 2.0x text without overflow', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const IntroScreen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('One case.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checked by experts'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Next advances and Back returns', (tester) async {
      await tester.pumpApp(const IntroScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('One case.'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checked by experts'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.textContaining('One case.'), findsOneWidget);
    });

    testWidgets('Skip and Get started go to A6', (tester) async {
      Future<void> pumpAtIntro() async {
        final router = GoRouter(
          initialLocation: '/intro',
          routes: [
            GoRoute(path: '/intro', builder: (_, _) => const IntroScreen()),
            GoRoute(
              path: '/get-started',
              builder: (_, _) => const Text('get-started stub'),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpRouterApp(router);
        await tester.pumpAndSettle();
      }

      await pumpAtIntro();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('get-started stub'), findsOneWidget);

      await pumpAtIntro();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(find.text('get-started stub'), findsOneWidget);
    });
  });
}
