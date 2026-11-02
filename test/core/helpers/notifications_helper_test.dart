import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/helpers/notifications_helper.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/features/auth/data/models/onboarding_hive.dart';
import 'package:tabibu/l10n/l10n.dart';

class _MockNotificationService extends Mock implements NotificationService {}

class _MockHiveHelper extends Mock implements HiveHelper {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockNotificationService service;
  late _MockHiveHelper cache;
  late NotificationsHelper helper;

  setUp(() {
    service = _MockNotificationService();
    cache = _MockHiveHelper();
    helper = NotificationsHelper(
      notificationService: service,
      hiveHelper: cache,
    );
    when(
      () => service.showNotification(
        title: any(named: 'title'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearLocaleTestValue();
  });

  void onboardAs(String? languageString) {
    when(cache.getCachedOnboarding).thenAnswer(
      (_) async => languageString == null
          ? null
          : OnboardingHive(isOnboarded: true, languageString: languageString),
    );
  }

  Future<(String, String)> shownTitleAndMessage() async {
    final captured = verify(
      () => service.showNotification(
        title: captureAny(named: 'title'),
        message: captureAny(named: 'message'),
      ),
    ).captured;
    final last = captured.sublist(captured.length - 2);
    return (last[0] as String, last[1] as String);
  }

  test('uses the onboarding language when chosen', () async {
    onboardAs('sw');
    final sw = lookupAppLocalizations(const Locale('sw'));

    await helper.notifyPatientRegistered();

    final (title, message) = await shownTitleAndMessage();
    expect(title, sw.notificationWelcomeTitle);
    expect(message, sw.notificationWelcomeMessage);
  });

  test('welcomes back without a name, in the chosen language', () async {
    onboardAs('sw');
    final sw = lookupAppLocalizations(const Locale('sw'));

    await helper.notifyWelcomeBack();

    final (title, message) = await shownTitleAndMessage();
    expect(title, sw.notificationWelcomeBackTitle);
    expect(message, sw.notificationWelcomeBackMessage);
  });

  test('falls back to the device language, then en', () async {
    onboardAs('');
    final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
    final sw = lookupAppLocalizations(const Locale('sw'));
    final en = lookupAppLocalizations(const Locale('en'));

    dispatcher.localeTestValue = const Locale('sw');
    await helper.notifyLicenceReceived();
    var (title, _) = await shownTitleAndMessage();
    expect(title, sw.notificationLicenceReceivedTitle);

    dispatcher.localeTestValue = const Locale('fr');
    await helper.notifyLicenceReceived();
    (title, _) = await shownTitleAndMessage();
    expect(title, en.notificationLicenceReceivedTitle);
  });

  test('never throws when the service fails', () async {
    onboardAs('en');
    when(
      () => service.showNotification(
        title: any(named: 'title'),
        message: any(named: 'message'),
      ),
    ).thenThrow(Exception('plugin down'));

    await helper.notifyPatientRegistered();
    await helper.notifyLicenceReceived();
  });
}
