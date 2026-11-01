import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/notifications/data/datasources/notification_firebase.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late NotificationFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    remote = NotificationFirebase(firestore: firestore);
  });

  group('fetchInboxDelta', () {
    test('returns only the recipient rows at or after the cursor', () async {
      await firestore.collection('notifications').doc('n1').set({
        'recipientUid': 'u1',
        'status': 'Unread',
        'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
      });
      await firestore.collection('notifications').doc('n2').set({
        'recipientUid': 'u1',
        'status': 'Unread',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('notifications').doc('other').set({
        'recipientUid': 'u2',
        'status': 'Unread',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchInboxDelta(
        recipientUid: 'u1',
        cursor: '2026-11-01T11:00:00.000Z',
      );
      expect(rows.map((r) => r.uid), ['n2']);
    });
  });

  group('markRead', () {
    test('updates only status, readAt and lastUpdatedAt', () async {
      await firestore.collection('notifications').doc('n1').set({
        'recipientUid': 'u1',
        'status': 'Unread',
        'readAt': '',
        'title': 'Keep',
        'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
      });

      await remote.markRead(
        notificationUid: 'n1',
        readAt: '2026-11-01T13:00:00.000Z',
      );

      final data = (await firestore.collection('notifications').doc('n1').get())
          .data()!;
      expect(data['status'], 'Read');
      expect(data['readAt'], '2026-11-01T13:00:00.000Z');
      expect(data['title'], 'Keep');
      expect(data['lastUpdatedAt'], isNot(equals('2026-11-01T10:00:00.000Z')));
      expect(
        data.keys.toSet(),
        containsAll([
          'status',
          'readAt',
          'lastUpdatedAt',
          'title',
          'recipientUid',
        ]),
      );
    });
  });
}
