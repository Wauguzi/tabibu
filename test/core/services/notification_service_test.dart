import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/services/notification_service.dart';
import 'package:tabibu/l10n/l10n.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  late _MockPlugin plugin;
  late NotificationService service;

  setUpAll(() {
    registerFallbackValue(const NotificationDetails());
  });

  setUp(() {
    plugin = _MockPlugin();
    service = NotificationService.withPlugin(plugin);
  });

  group('showNotification', () {
    test('names the icon and the channel on every show', () async {
      when(
        () => plugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});

      await service.showNotification(
        title: 'Signed in',
        message: 'Welcome back.',
        channel: NotificationChannel.alerts,
        payload: 'alert/a1',
      );

      final details =
          verify(
                () => plugin.show(
                  id: any(named: 'id'),
                  title: 'Signed in',
                  body: 'Welcome back.',
                  notificationDetails: captureAny(named: 'notificationDetails'),
                  payload: 'alert/a1',
                ),
              ).captured.single
              as NotificationDetails;
      expect(details.android?.icon, NotificationService.androidIcon);
      expect(details.android?.channelId, 'alerts');
      expect(details.android?.importance, Importance.high);
      expect(details.iOS?.presentBanner, isTrue);
    });

    test('never throws when the plugin does', () async {
      when(
        () => plugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).thenThrow(PlatformException(code: 'invalid_icon'));

      await expectLater(
        service.showNotification(title: 't', message: 'm'),
        completes,
      );
    });
  });

  group('launchPayload', () {
    test('the payload of the notification that launched the app', () async {
      when(plugin.getNotificationAppLaunchDetails).thenAnswer(
        (_) async => const NotificationAppLaunchDetails(
          true,
          notificationResponse: NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: 'case/c1',
          ),
        ),
      );
      expect(await service.launchPayload(), 'case/c1');
    });

    test('null when the app was opened normally', () async {
      when(
        plugin.getNotificationAppLaunchDetails,
      ).thenAnswer((_) async => const NotificationAppLaunchDetails(false));
      expect(await service.launchPayload(), isNull);
    });
  });

  test('every channel is named in en and sw', () {
    for (final code in ['en', 'sw']) {
      final l10n = lookupAppLocalizations(Locale(code));
      for (final channel in NotificationChannel.values) {
        expect(channel.name(l10n), isNotEmpty, reason: '$code ${channel.id}');
        expect(channel.description(l10n), isNotEmpty);
      }
    }
  });

  test('the icon the service names exists and is kept in release', () {
    const name = NotificationService.androidIcon;
    final drawable = File('android/app/src/main/res/drawable/$name.xml');
    expect(drawable.existsSync(), isTrue, reason: 'missing ${drawable.path}');

    // Resolved by name at runtime, which R8's resource shrinker cannot see.
    final keep = File('android/app/src/main/res/raw/keep.xml');
    expect(keep.readAsStringSync(), contains('@drawable/$name'));
  });
}
