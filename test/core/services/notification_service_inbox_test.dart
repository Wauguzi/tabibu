import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/services/notification_service.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  late _MockPlugin plugin;
  late NotificationService service;

  setUpAll(() => registerFallbackValue(const NotificationDetails()));

  setUp(() {
    plugin = _MockPlugin();
    service = NotificationService.withPlugin(plugin);
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
  });

  test('every channel is high importance, including case updates', () {
    for (final channel in NotificationChannel.values) {
      expect(channel.importance, Importance.high, reason: channel.id);
    }
  });

  test('a category names its channel as the server does', () {
    expect(NotificationService.channelIdOfCategory('Account'), 'account');
    expect(NotificationService.channelIdOfCategory('Alert'), 'alerts');
    expect(NotificationService.channelIdOfCategory('Case'), 'case_updates');
    expect(NotificationService.channelIdOfCategory('Report'), 'case_updates');
  });

  test('one row has one id, so a banner is never stacked on its twin', () {
    expect(
      NotificationService.notificationIdOf('reportSigned:c1_v1:doc'),
      NotificationService.notificationIdOf('reportSigned:c1_v1:doc'),
    );
    expect(
      NotificationService.notificationIdOf('a'),
      isNot(NotificationService.notificationIdOf('b')),
    );
    expect(NotificationService.notificationIdOf(null), isNull);
    expect(NotificationService.notificationIdOf(''), isNull);
    expect(NotificationService.notificationIdOf('x'), greaterThanOrEqualTo(0));
  });

  test(
    'an inbox row is shown with its title and text, high, on its channel',
    () async {
      await service.showInboxRow(
        notificationUid: 'explanationReady:c1_v1:doc',
        title: 'Explanation ready',
        message: 'An explanation is ready to review.',
        category: 'Case',
      );

      final details =
          verify(
                () => plugin.show(
                  id: NotificationService.notificationIdOf(
                    'explanationReady:c1_v1:doc',
                  )!,
                  title: 'Explanation ready',
                  body: 'An explanation is ready to review.',
                  notificationDetails: captureAny(named: 'notificationDetails'),
                  // The tap carries the row's uid, as an inbox tap does.
                  payload: 'explanationReady:c1_v1:doc',
                ),
              ).captured.single
              as NotificationDetails;
      expect(details.android?.channelId, 'case_updates');
      expect(details.android?.importance, Importance.high);
      expect(details.android?.priority, Priority.high);
      expect(details.iOS?.presentAlert, isTrue);
      expect(details.iOS?.presentBanner, isTrue);
    },
  );

  test('a device that can receive a push leaves the row to the push', () async {
    // A token means FCM delivers it: showing it here too would be a second one.
    service.debugAllowPushForTest();

    await service.showInboxRow(
      notificationUid: 'x',
      title: 't',
      message: 'm',
      category: 'Case',
    );

    verifyNever(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
        payload: any(named: 'payload'),
      ),
    );
  });
}
