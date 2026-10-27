import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/app/app.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/auth_helper.dart';
import 'package:tabibu/core/helpers/blocs_helper.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/helpers/notifications_helper.dart';
import 'package:tabibu/core/helpers/theme_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/app_update_service.dart';
import 'package:tabibu/core/services/internet_service.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/core/services/rasp_service.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/onboarding_hive.dart';

class _MockAuthHelper extends Mock implements AuthHelper {}

class _MockHiveHelper extends Mock implements HiveHelper {}

class _MockUpdates extends Mock implements AppUpdateService {}

class _MockNotifications extends Mock implements NotificationService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockThemeHelper extends Mock implements ThemeHelper {}

void main() {
  late _MockAuthHelper auth;
  late _MockHiveHelper hive;
  late _MockUpdates updates;

  setUp(() {
    auth = _MockAuthHelper();
    hive = _MockHiveHelper();
    updates = _MockUpdates();
    final notifications = _MockNotifications();
    final analytics = _MockAnalytics();
    final theme = _MockThemeHelper();
    when(theme.read).thenReturn(ThemePreference.system);

    when(
      () => auth.resolveSession(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => const SignedOutSession());
    when(() => auth.currentUid).thenReturn(null);
    when(() => updates.isUpdateRequired()).thenAnswer((_) async => false);
    when(() => hive.getCachedOnboarding()).thenAnswer((_) async => null);
    when(
      () => notifications.tokenRefreshes,
    ).thenAnswer((_) => const Stream.empty());

    getIt
      ..registerSingleton<AuthHelper>(auth)
      ..registerSingleton<HiveHelper>(hive)
      ..registerSingleton<AppUpdateService>(updates)
      ..registerSingleton<NotificationService>(notifications)
      ..registerSingleton<AnalyticsService>(analytics)
      ..registerSingleton<InternetService>(InternetService())
      ..registerSingleton<NotificationsHelper>(
        NotificationsHelper(
          notificationService: notifications,
          hiveHelper: hive,
        ),
      )
      ..registerSingleton<RaspService>(RaspService())
      ..registerSingleton<ThemeHelper>(theme);
  });

  tearDown(getIt.reset);

  Future<void> start(WidgetTester tester) async {
    // As bootstrap mounts it.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: BlocsHelper.initializeBlocs(),
        child: const App(),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('a first run goes to the language screen', (tester) async {
    await start(tester);
    expect(find.text('A2 Language'), findsOneWidget);
  });

  testWidgets('a returning, signed-out person goes to sign-in', (tester) async {
    when(() => hive.getCachedOnboarding()).thenAnswer(
      (_) async => OnboardingHive(isOnboarded: true, languageString: 'en'),
    );
    await start(tester);
    expect(find.text('B1 Sign in'), findsOneWidget);
  });

  testWidgets('the saved language is the app language', (tester) async {
    when(() => hive.getCachedOnboarding()).thenAnswer(
      (_) async => OnboardingHive(isOnboarded: false, languageString: 'sw'),
    );
    await start(tester);
    final context = tester.element(find.text('A2 Language'));
    expect(Localizations.localeOf(context).languageCode, 'sw');
  });

  testWidgets('an outdated build goes nowhere but the update screen', (
    tester,
  ) async {
    when(() => updates.isUpdateRequired()).thenAnswer((_) async => true);
    await start(tester);
    expect(find.text('Update required'), findsOneWidget);
  });
}
