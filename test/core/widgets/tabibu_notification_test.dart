import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/widgets/tabibu_notification.dart';

import '../../helpers/helpers.dart';

void main() {
  group('showTabibuNotification', () {
    Future<void> openNotification(
      WidgetTester tester, {
      bool isError = true,
    }) async {
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showTabibuNotification(
                  context,
                  message: 'Something went wrong',
                  isError: isError,
                  dismissLabel: 'Double tap to dismiss',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('enters on a fade-scale transition', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showTabibuNotification(
                  context,
                  message: 'Something went wrong',
                  isError: true,
                  dismissLabel: 'Double tap to dismiss',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.byType(FadeScaleTransition), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);

      // Let the auto-dismiss timer fire so no timer pends at teardown.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('announces the message with its dismiss hint', (tester) async {
      await openNotification(tester, isError: false);

      expect(
        tester.getSemantics(find.text('Something went wrong')),
        matchesSemantics(
          label: 'Something went wrong',
          hint: 'Double tap to dismiss',
          isButton: true,
          hasTapAction: true,
        ),
      );

      await tester.tap(find.text('Something went wrong'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('dismisses on tap and shows info tone', (tester) async {
      await openNotification(tester, isError: false);

      expect(find.text('Something went wrong'), findsOneWidget);
      await tester.tap(find.text('Something went wrong'));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsNothing);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('tints the info tone per theme', (tester) async {
      Future<Color?> toastColor(ThemeMode mode) async {
        await tester.pumpApp(
          Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showTabibuNotification(
                    context,
                    message: 'All caught up',
                    isError: false,
                    dismissLabel: 'Double tap to dismiss',
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
          themeMode: mode,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final color = tester
            .widget<Material>(
              find.byWidgetPredicate(
                (w) => w is Material && w.borderRadius != null,
              ),
            )
            .color;
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        return color;
      }

      expect(
        await toastColor(ThemeMode.light),
        AppColors.notificationInfoLight,
      );
      expect(await toastColor(ThemeMode.dark), AppColors.notificationInfoDark);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await openNotification(tester);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('dismisses with Enter from the keyboard', (tester) async {
      await openNotification(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsNothing);

      await tester.pump(const Duration(seconds: 5));
    });
  });
}
