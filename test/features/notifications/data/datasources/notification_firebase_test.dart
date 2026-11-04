import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/notifications/data/datasources/notification_firebase.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late NotificationFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    remote = NotificationFirebase(firestore: firestore);
  });

  group('watchInboxDelta', () {
    test(
      'emits added and modified rows; skips removed; honours the cursor',
      () async {
        await firestore.collection('notifications').doc('old').set({
          'recipientUid': 'u1',
          'status': 'Unread',
          'title': 'before',
          'lastUpdatedAt': '2026-11-01T09:00:00.000Z',
        });

        final events = <List<String>>[];
        final sub = remote
            .watchInboxDelta(
              recipientUid: 'u1',
              cursor: '2026-11-01T10:00:00.000Z',
            )
            .listen((rows) => events.add(rows.map((r) => r.uid).toList()));

        // First snapshot for an empty matching set emits nothing.
        await Future<void>.delayed(Duration.zero);
        expect(events, isEmpty);

        await firestore.collection('notifications').doc('n1').set({
          'recipientUid': 'u1',
          'status': 'Unread',
          'title': 'new',
          'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        });
        await Future<void>.delayed(Duration.zero);
        expect(events, [
          ['n1'],
        ]);

        await firestore.collection('notifications').doc('n1').update({
          'title': 'changed',
          'lastUpdatedAt': '2026-11-01T13:00:00.000Z',
        });
        await Future<void>.delayed(Duration.zero);
        expect(events.last, ['n1']);

        await firestore.collection('notifications').doc('n1').delete();
        await Future<void>.delayed(Duration.zero);
        // Removed rows must not produce an event.
        expect(events, hasLength(2));

        // Outside the cursor / other recipient stay out.
        await firestore.collection('notifications').doc('n2').set({
          'recipientUid': 'u2',
          'status': 'Unread',
          'lastUpdatedAt': '2026-11-01T14:00:00.000Z',
        });
        await Future<void>.delayed(Duration.zero);
        expect(events, hasLength(2));

        await sub.cancel();
      },
    );
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

  group('server reads', () {
    test('eviction reads reach the server, never the cache', () async {
      final recording = RecordingFirestore();
      final server = NotificationFirebase(firestore: recording);

      await server.fetchInboxDelta(recipientUid: 'u1');

      recording.expectServerReads(1);
    });
  });
}
