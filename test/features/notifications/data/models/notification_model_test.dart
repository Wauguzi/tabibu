import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_model.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

Map<String, dynamic> notificationJson() => {
  'uid': 'notification-1',
  'threadUid': 'thread-1',
  'idempotencyKey': 'notification-1',
  'creationDate': '2026-11-01T08:00:00.000Z',
  'recipientUid': 'doctor-1',
  'recipientRole': 'doctor',
  'initiatorUid': 'patient-1',
  'initiatorRole': 'patient',
  'initiatorName': 'Amina Otieno',
  'title': 'New appointment request',
  'message': 'A patient requested a slot.',
  'templateKey': 'appointment_requested',
  'templateArgs': {'slot': '08:00'},
  'category': 'Appointment',
  'priority': 'High',
  'channel': 'Push',
  'source': 'Function',
  'scope': 'Cloud',
  'status': 'Unread',
  'readAt': '',
  'resourceType': 'Appointment',
  'resourceUid': 'appt-1',
  'metadata': {
    'actionType': 'Approval',
    'actionStatus': 'Pending',
    'actionedByUid': '',
    'actionedAt': '',
    'expiresAt': '2026-11-02T08:00:00.000Z',
    'deepLink': '/appointments/appt-1',
    'shareCode': 'SECRET-CODE-42',
    'extras': {'county': 'Nairobi'},
  },
  'pushRequestedAt': '2026-11-01T08:00:01.000Z',
  'pushSentAt': '2026-11-01T08:00:02.000Z',
  'lastUpdatedAt': '2026-11-01T08:00:02.000Z',
};

void main() {
  final now = DateTime.utc(2026, 11, 1, 12);

  group('NotificationModel', () {
    test('fromJson of a full Cloud row round-trips through toJson', () {
      final json = notificationJson();
      expect(NotificationModel.fromJson(json).toJson(), json);
    });

    test('a row missing optional keys reads the defaults', () {
      final model = NotificationModel.fromJson({'uid': 'notification-2'});
      expect(model.uid, 'notification-2');
      expect(model.threadUid, '');
      expect(model.templateArgs, isEmpty);
      expect(model.status, 'Unread');
      expect(model.metadata, NotificationMetadataModel.empty());
      expect(model.synced, isTrue);
    });

    test('toJson never contains synced', () {
      final model = NotificationModel.fromJson(notificationJson());
      expect(model.toJson().containsKey('synced'), isFalse);
      expect(
        model.copyWith(synced: false).toJson().containsKey('synced'),
        isFalse,
      );
    });

    test('typed getters parse the stored strings', () {
      final model = NotificationModel.fromJson(notificationJson());
      expect(model.categoryValue, NotificationCategory.appointment);
      expect(model.priorityValue, NotificationPriority.high);
      expect(model.channelValue, NotificationChannel.push);
      expect(model.sourceValue, NotificationSource.cloudFunction);
      expect(model.scopeValue, NotificationScope.cloud);
      expect(model.statusValue, NotificationStatus.unread);
      expect(model.resourceTypeValue, NotificationResourceType.appointment);
      expect(model.metadata.actionTypeValue, NotificationActionType.approval);
      expect(
        model.metadata.actionStatusValue,
        NotificationActionStatus.pending,
      );
    });

    test('isRead is false for Unread and true otherwise', () {
      final unread = NotificationModel.fromJson(notificationJson());
      expect(unread.isRead, isFalse);
      expect(unread.copyWith(status: 'Read').isRead, isTrue);
      expect(unread.copyWith(status: 'Archived').isRead, isTrue);
    });

    test('isLocalOnly follows scope', () {
      final cloud = NotificationModel.fromJson(notificationJson());
      expect(cloud.isLocalOnly, isFalse);
      expect(cloud.copyWith(scope: 'Local').isLocalOnly, isTrue);
    });

    test('hasShareCode follows metadata.shareCode', () {
      final model = NotificationModel.fromJson(notificationJson());
      expect(model.hasShareCode, isTrue);
      expect(
        model
            .copyWith(metadata: model.metadata.copyWith(shareCode: ''))
            .hasShareCode,
        isFalse,
      );
    });

    test('isExpired is true only when expiresAt is earlier than now', () {
      final model = NotificationModel.fromJson(notificationJson());
      expect(
        model
            .copyWith(
              metadata: model.metadata.copyWith(
                expiresAt: '2026-11-01T11:00:00.000Z',
              ),
            )
            .isExpired(now),
        isTrue,
      );
      expect(
        model
            .copyWith(
              metadata: model.metadata.copyWith(
                expiresAt: '2026-11-01T13:00:00.000Z',
              ),
            )
            .isExpired(now),
        isFalse,
      );
      expect(
        model
            .copyWith(metadata: model.metadata.copyWith(expiresAt: ''))
            .isExpired(now),
        isFalse,
      );
    });

    test('isActionable needs Approval, Pending and a live expiry', () {
      final model = NotificationModel.fromJson(notificationJson());
      expect(
        model
            .copyWith(
              metadata: model.metadata.copyWith(
                expiresAt: '2026-11-01T13:00:00.000Z',
              ),
            )
            .isActionable(now),
        isTrue,
      );
      expect(
        model
            .copyWith(
              metadata: model.metadata.copyWith(
                expiresAt: '2026-11-01T11:00:00.000Z',
              ),
            )
            .isActionable(now),
        isFalse,
      );
      expect(
        model
            .copyWith(
              metadata: model.metadata.copyWith(
                actionStatus: 'Accepted',
                expiresAt: '2026-11-01T13:00:00.000Z',
              ),
            )
            .isActionable(now),
        isFalse,
      );
      expect(
        model
            .copyWith(
              metadata: model.metadata.copyWith(
                actionType: '',
                expiresAt: '2026-11-01T13:00:00.000Z',
              ),
            )
            .isActionable(now),
        isFalse,
      );
    });

    test('local sets Local, App and InApp', () {
      final model = NotificationModel.local(
        uid: 'local-1',
        recipientUid: 'doctor-1',
        templateKey: 'sync_failed',
        templateArgs: const {'reason': 'offline'},
        category: 'Account',
        resourceType: 'Case',
        resourceUid: 'case-1',
        creationDate: '2026-11-01T09:00:00.000Z',
        title: 'Could not sync',
        message: 'Try again when you are online.',
      );
      expect(model.scope, 'Local');
      expect(model.source, 'App');
      expect(model.channel, 'InApp');
      expect(model.synced, isTrue);
      expect(model.idempotencyKey, 'local-1');
      expect(model.isLocalOnly, isTrue);
      expect(model.scopeValue, NotificationScope.local);
      expect(model.sourceValue, NotificationSource.app);
      expect(model.channelValue, NotificationChannel.inApp);
    });

    test('toString never contains a share code', () {
      const code = 'SECRET-CODE-42';
      final model = NotificationModel.fromJson(notificationJson());
      expect(model.metadata.shareCode, code);
      expect(model.metadata.toString(), isNot(contains(code)));
      expect(model.metadata.toString(), contains('shareCode: ***'));
      expect(model.toString(), isNot(contains(code)));
    });
  });
}
