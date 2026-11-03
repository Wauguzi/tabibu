import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

/// Firestore reads and updates for the notification inbox. No caching.
@lazySingleton
class NotificationFirebase {
  NotificationFirebase({required this._firestore});

  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  AppError _toAppError(Object e) => switch (e) {
    AppError() => e,
    FirebaseException(:final code) => AppError.fromFirebaseCode(code),
    _ => AppError.unknown,
  };

  Future<T> _guard<T>(String operation, Future<T> Function() body) async {
    try {
      return await body();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('$operation failed: $e', stackTrace: stackTrace);
      }
      throw _toAppError(e);
    }
  }

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Query<Map<String, dynamic>> _inboxQuery({
    required String recipientUid,
    String? cursor,
  }) {
    var query = _notifications.where('recipientUid', isEqualTo: recipientUid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    return query.orderBy('lastUpdatedAt');
  }

  /// Inbox delta: `recipientUid ==` and `lastUpdatedAt >=` cursor (I-28).
  Future<List<NotificationModel>> fetchInboxDelta({
    required String recipientUid,
    String? cursor,
  }) => _guard('Notification inbox delta', () async {
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await _inboxQuery(
      recipientUid: recipientUid,
      cursor: cursor,
    ).get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        NotificationModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// Live inbox: the same query as [fetchInboxDelta], as `snapshots()`.
  /// Emits only added and modified rows; empty changes are skipped. Built
  /// from stream operators so cancel finishes promptly.
  Stream<List<NotificationModel>> watchInboxDelta({
    required String recipientUid,
    String? cursor,
  }) => _inboxQuery(recipientUid: recipientUid, cursor: cursor)
      .snapshots()
      .map((snap) {
        return [
          for (final change in snap.docChanges)
            if (change.type != DocumentChangeType.removed &&
                change.doc.data() != null)
              NotificationModel.fromJson({
                'uid': change.doc.id,
                ...change.doc.data()!,
              }),
        ];
      })
      .where((rows) => rows.isNotEmpty);

  /// Recipient may update only `status`, `readAt` and `lastUpdatedAt`.
  Future<void> markRead({
    required String notificationUid,
    required String readAt,
  }) => _guard('Mark notification read', () async {
    await _notifications.doc(notificationUid).update({
      'status': NotificationStatus.read.value,
      'readAt': readAt,
      'lastUpdatedAt': syncTimestamp(),
    });
  });
}
