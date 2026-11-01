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
    } on Exception catch (e) {
      if (kDebugMode) _logger.e('$operation failed: $e');
      throw _toAppError(e);
    }
  }

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  /// Inbox delta: `recipientUid ==` and `lastUpdatedAt >=` cursor (I-28).
  Future<List<NotificationModel>> fetchInboxDelta({
    required String recipientUid,
    String? cursor,
  }) => _guard('Notification inbox delta', () async {
    var query = _notifications.where('recipientUid', isEqualTo: recipientUid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    final snap = await query.get();
    return [
      for (final doc in snap.docs)
        NotificationModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

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
