import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/features/auth/presentation/reset_password_sent_screen.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('ResetPasswordSentScreen', () {
    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(
        const ResetPasswordSentScreen(),
        themeMode: ThemeMode.light,
      );
      await tester.pumpAndSettle();
      expect(find.text('Check your email'), findsOneWidget);

      await tester.pumpApp(
        const ResetPasswordSentScreen(),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();
      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('lays out in Swahili at 2.0x', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        const ResetPasswordSentScreen(),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('names no address', (tester) async {
      await tester.pumpApp(const ResetPasswordSentScreen());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'We sent a reset link to your email. It works for 30 minutes.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a failed mail launch shows its message', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/url_launcher'),
            (call) async => false,
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/url_launcher'),
              null,
            );
      });

      await tester.pumpApp(const ResetPasswordSentScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open email app'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't open an email app."), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('back to sign in goes to B1', (tester) async {
      final router = GoRouter(
        initialLocation: '/reset-password/sent',
        routes: [
          GoRoute(
            path: '/reset-password/sent',
            builder: (_, _) => const ResetPasswordSentScreen(),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (_, _) => const Text('sign-in stub'),
          ),
        ],
      );
      await tester.pumpRouterApp(router);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to sign in'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in stub'), findsOneWidget);
    });
  });
}
