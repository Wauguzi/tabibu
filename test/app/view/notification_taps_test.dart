import 'dart:async';

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
import 'package:tabibu/features/auth/presentation/decision_screen.dart';
import 'package:tabibu/features/notifications/data/cache/notification_cache_helper.dart';

class _MockAuthHelper extends Mock implements AuthHelper {}

class _MockHiveHelper extends Mock implements HiveHelper {}

class _MockUpdates extends Mock implements AppUpdateService {}

class _MockNotifications extends Mock implements NotificationService {}

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockThemeHelper extends Mock implements ThemeHelper {}

class _MockCache extends Mock implements NotificationCacheHelper {}

/// App tap wiring without mounting a role home (those screens need the full
/// getIt graph). Route mapping is covered in notification_target_test.
void main() {
  late _MockAuthHelper auth;
  late _MockHiveHelper hive;
  late _MockUpdates updates;
  late _MockNotifications notifications;
  late StreamController<String> taps;

  setUp(() {
    auth = _MockAuthHelper();
    hive = _MockHiveHelper();
    updates = _MockUpdates();
    notifications = _MockNotifications();
    taps = StreamController<String>.broadcast();
    addTearDown(taps.close);

    when(
      () => updates.remoteText(any(), any()),
    ).thenAnswer((i) => i.positionalArguments[1] as String);
    when(() => updates.isUpdateRequired()).thenAnswer((_) async => false);
    when(() => hive.getCachedOnboarding()).thenAnswer(
      (_) async => OnboardingHive(isOnboarded: true, languageString: 'en'),
    );
    when(() => auth.currentUid).thenReturn(null);
    when(
      () => notifications.tokenRefreshes,
    ).thenAnswer((_) => const Stream.empty());
    when(() => notifications.taps).thenAnswer((_) => taps.stream);
    when(() => notifications.launchPayload()).thenAnswer((_) async => null);

    final analytics = _MockAnalytics();
    final theme = _MockThemeHelper();
    when(theme.read).thenReturn(ThemePreference.system);
    final cache = _MockCache();
    when(() => cache.getInbox(any())).thenAnswer((_) async => const []);
    when(() => cache.watchInbox(any())).thenAnswer((_) => const Stream.empty());

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
      ..registerSingleton<ThemeHelper>(theme)
      ..registerSingleton<NotificationCacheHelper>(cache);
  });

  tearDown(getIt.reset);

  Future<void> startSignedOut(WidgetTester tester) async {
    when(
      () => auth.resolveSession(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => const SignedOutSession());
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: BlocsHelper.initializeBlocs(),
        child: const App(),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(DecisionScreen.minimumDwell);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('no navigation while signed out: taps are not subscribed', (
    tester,
  ) async {
    await startSignedOut(tester);
    verifyNever(() => notifications.taps);
    verifyNever(() => notifications.launchPayload());
    taps.add('/alerts/a1');
    await tester.pump();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
