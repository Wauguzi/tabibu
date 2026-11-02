import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/notifications/data/models/notification_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

import 'notification_model_test.dart' show notificationJson;

void main() {
  group('NotificationHive', () {
    test('fromModel maps every field in order', () {
      final model = NotificationModel.fromJson(notificationJson());
      final hive = NotificationHive.fromModel(model);
      expect(hive.uid, model.uid);
      expect(hive.threadUid, model.threadUid);
      expect(hive.idempotencyKey, model.idempotencyKey);
      expect(hive.creationDate, model.creationDate);
      expect(hive.recipientUid, model.recipientUid);
      expect(hive.recipientRole, model.recipientRole);
      expect(hive.initiatorUid, model.initiatorUid);
      expect(hive.initiatorRole, model.initiatorRole);
      expect(hive.initiatorName, model.initiatorName);
      expect(hive.title, model.title);
      expect(hive.message, model.message);
      expect(hive.templateKey, model.templateKey);
      expect(hive.templateArgs, model.templateArgs);
      expect(hive.category, model.category);
      expect(hive.priority, model.priority);
      expect(hive.channel, model.channel);
      expect(hive.source, model.source);
      expect(hive.scope, model.scope);
      expect(hive.status, model.status);
      expect(hive.readAt, model.readAt);
      expect(hive.resourceType, model.resourceType);
      expect(hive.resourceUid, model.resourceUid);
      expect(hive.metadata.actionType, model.metadata.actionType);
      expect(hive.metadata.actionStatus, model.metadata.actionStatus);
      expect(hive.metadata.actionedByUid, model.metadata.actionedByUid);
      expect(hive.metadata.actionedAt, model.metadata.actionedAt);
      expect(hive.metadata.expiresAt, model.metadata.expiresAt);
      expect(hive.metadata.deepLink, model.metadata.deepLink);
      expect(hive.metadata.shareCode, model.metadata.shareCode);
      expect(hive.metadata.extras, model.metadata.extras);
      expect(hive.pushRequestedAt, model.pushRequestedAt);
      expect(hive.pushSentAt, model.pushSentAt);
      expect(hive.lastUpdatedAt, model.lastUpdatedAt);
      expect(hive.synced, model.synced);
    });

    test('toModel round-trips, keeping an unsynced row unsynced', () {
      final model = NotificationModel.fromJson(
        notificationJson(),
      ).copyWith(synced: false);
      final roundTripped = NotificationHive.fromModel(model).toModel();
      expect(roundTripped, model);
      expect(roundTripped.synced, isFalse);
      expect(roundTripped.metadata, model.metadata);
      expect(roundTripped.metadata.shareCode, 'SECRET-CODE-42');
      expect(roundTripped.metadata.extras, {'county': 'Nairobi'});
    });
  });
}
