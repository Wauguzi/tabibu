import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/features/onboarding/presentation/update_required_screen.dart';

import '../../../helpers/helpers.dart';

class MockAppUpdateService extends Mock implements AppUpdateService {}

void main() {
  group('UpdateRequiredScreen', () {
    late MockAppUpdateService updateService;

    setUp(() {
      updateService = MockAppUpdateService();
      when(
        () => updateService.storeUrl(isIos: any(named: 'isIos')),
      ).thenReturn(Uri.parse('https://example.com/app'));
      getIt.registerSingleton<AppUpdateService>(updateService);
    });

    tearDown(getIt.reset);

    testWidgets('renders in light and dark', (tester) async {
      await tester.pumpApp(
        const UpdateRequiredScreen(),
        themeMode: ThemeMode.light,
      );
      await tester.pumpAndSettle();
      expect(find.text('Please update Tabibu'), findsOneWidget);

      await tester.pumpApp(
        const UpdateRequiredScreen(),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();
      expect(find.text('Please update Tabibu'), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(
        const UpdateRequiredScreen(),
        locale: const Locale('sw'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tafadhali sasisha Tabibu'), findsOneWidget);
    });

    testWidgets('falls back to ARB without Remote Config', (tester) async {
      await tester.pumpApp(const UpdateRequiredScreen());
      await tester.pumpAndSettle();

      expect(find.text('Please update Tabibu'), findsOneWidget);
      expect(
        find.text(
          'This version is no longer supported. '
          'Update to keep using Tabibu.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('lays out at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(const UpdateRequiredScreen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('hides the button without a store URL', (tester) async {
      when(
        () => updateService.storeUrl(isIos: any(named: 'isIos')),
      ).thenReturn(null);

      await tester.pumpApp(const UpdateRequiredScreen());
      await tester.pumpAndSettle();

      expect(find.text('Update now'), findsNothing);
    });

    testWidgets('a failed launch shows its message', (tester) async {
      // The store link refuses to open; the platform channel is mocked
      // because no engine handles it under test.
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

      await tester.pumpApp(const UpdateRequiredScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't open the store. Please try again."),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
