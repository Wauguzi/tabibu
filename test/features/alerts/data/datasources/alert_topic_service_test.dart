import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/features/alerts/data/datasources/alert_topic_service.dart';

class _MockMessaging extends Mock implements FirebaseMessaging {}

AlertTopicService _service({
  required FirebaseMessaging messaging,
  required SharedPreferences prefs,
  bool forceWeb = false,
}) => AlertTopicService.internal(
  messaging: messaging,
  preferences: prefs,
  forceWeb: forceWeb,
  useRealWebCheck: false,
);

void main() {
  late _MockMessaging messaging;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    messaging = _MockMessaging();
    when(() => messaging.subscribeToTopic(any())).thenAnswer((_) async {});
    when(() => messaging.unsubscribeFromTopic(any())).thenAnswer((_) async {});
  });

  test('topicName uses county and language, with a demo variant', () {
    expect(
      AlertTopicService.topicName(countyId: 47, language: 'sw'),
      'alerts_patient_47_sw',
    );
    expect(
      AlertTopicService.topicName(countyId: 47, language: 'en', demo: true),
      'alerts_patient_demo_47_en',
    );
  });

  test('syncSubscription subscribes and stores the topic', () async {
    final service = _service(messaging: messaging, prefs: prefs);

    await service.syncSubscription(
      topic: 'alerts_patient_47_en',
      receiveNotifications: true,
    );

    verify(() => messaging.subscribeToTopic('alerts_patient_47_en')).called(1);
    expect(service.storedTopic, 'alerts_patient_47_en');
  });

  test('syncSubscription swaps topics and unsubscribes the old one', () async {
    await prefs.setString(AlertTopicService.storedTopicKey, 'old_topic');
    final service = _service(messaging: messaging, prefs: prefs);

    await service.syncSubscription(
      topic: 'alerts_patient_47_sw',
      receiveNotifications: true,
    );

    verify(() => messaging.unsubscribeFromTopic('old_topic')).called(1);
    verify(() => messaging.subscribeToTopic('alerts_patient_47_sw')).called(1);
  });

  test('does nothing on the web', () async {
    final service = _service(
      messaging: messaging,
      prefs: prefs,
      forceWeb: true,
    );

    await service.syncSubscription(
      topic: 'alerts_patient_47_en',
      receiveNotifications: true,
    );
    await service.unsubscribeBeforeSignOut();
    await service.retryPendingUnsubscribeOnSignIn();

    verifyZeroInteractions(messaging);
    expect(service.storedTopic, isNull);
  });

  test('unsubscribeBeforeSignOut queues a retry on failure', () async {
    await prefs.setString(
      AlertTopicService.storedTopicKey,
      'alerts_patient_47_en',
    );
    when(
      () => messaging.unsubscribeFromTopic(any()),
    ).thenThrow(Exception('offline'));
    final service = _service(messaging: messaging, prefs: prefs);

    await service.unsubscribeBeforeSignOut();
    expect(service.storedTopic, isNull);
    expect(service.pendingUnsubscribe, 'alerts_patient_47_en');

    when(() => messaging.unsubscribeFromTopic(any())).thenAnswer((_) async {});
    await service.retryPendingUnsubscribeOnSignIn();
    expect(service.pendingUnsubscribe, isNull);
  });
}
