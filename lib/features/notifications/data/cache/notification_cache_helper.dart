import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/notifications/data/datasources/notification_firebase.dart';
import 'package:tabibu/features/notifications/data/models/notification_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

/// The cached notification inbox: the layer the blocs call.
@lazySingleton
class NotificationCacheHelper {
  NotificationCacheHelper({required this._db, required this._remote});

  final DBHelper _db;
  final NotificationFirebase _remote;
  final Logger _logger = Logger();

  /// Failures that mean "the cloud cannot be reached", for which the cache
  /// stands in.
  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  /// Replay mapping (§3.8): these drop the local change and refetch by id.
  /// `failed-precondition` collapses into [AppError.unknown], which also
  /// covers transient faults (`aborted`, `internal`), so it stays queued: a
  /// stuck-but-visible row beats a silently dropped read state.
  static const Set<AppError> _dropAndRefetch = {
    .permissionDenied,
    .dataNotFound,
  };

  /// Synced rows older than this are pruned; queued rows are never pruned.
  static const pruneAfter = Duration(days: 90);

  /// Whether [incoming] may replace [cached] (sync rule, §6).
  bool _accepts({
    required bool fromCloud,
    required ({bool synced, String lastUpdatedAt})? cached,
    required String incoming,
  }) =>
      !fromCloud ||
      cached == null ||
      cloudRowWins(
        cachedSynced: cached.synced,
        cachedLastUpdatedAt: cached.lastUpdatedAt,
        incomingLastUpdatedAt: incoming,
      );

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<List<NotificationModel>> syncInbox(String uid, {String? since}) async {
    if (uid.isEmpty) return const [];
    try {
      final remote = await _remote.fetchInboxDelta(
        recipientUid: uid,
        cursor: since ?? await cursor(uid),
      );
      await cacheNotifications(remote, fromCloud: true);
      await pruneInbox(uid);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getInbox(uid);
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getInbox(uid);
  }

  /// The cached inbox, newest first; archived rows stay out of it.
  Future<List<NotificationModel>> getInbox(String uid, {int? limit}) async {
    if (uid.isEmpty) return const [];
    final rows = [
      for (final row in await _db.getAll<NotificationHive>(
        HiveHelperImpl.notificationsBox,
      ))
        if (row.recipientUid == uid &&
            row.status != NotificationStatus.archived.value)
          row.toModel(),
    ];
    final sorted = rows
      ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
    if (limit != null && sorted.length > limit) sorted.length = limit;
    return sorted;
  }

  /// The cached unread rows in scope.
  Future<int> unreadCount(String uid) async {
    if (uid.isEmpty) return 0;
    var count = 0;
    for (final row in await _db.getAll<NotificationHive>(
      HiveHelperImpl.notificationsBox,
    )) {
      if (row.recipientUid == uid &&
          row.status == NotificationStatus.unread.value) {
        count++;
      }
    }
    return count;
  }

  /// The cached rows still awaiting the recipient's action.
  Future<List<NotificationModel>> getActionable(
    String uid,
    DateTime now,
  ) async {
    if (uid.isEmpty) return const [];
    return [
      for (final n in await getInbox(uid))
        if (n.isActionable(now)) n,
    ];
  }

  /// Rows whose local read state is not yet sent.
  Future<List<NotificationModel>> getUnsynced(String uid) async {
    if (uid.isEmpty) return const [];
    return [
      for (final row in await _db.getAll<NotificationHive>(
        HiveHelperImpl.notificationsBox,
      ))
        if (row.recipientUid == uid && !row.synced) row.toModel(),
    ];
  }

  /// Stores a device-only row; the key is the id, so a repeat overwrites.
  Future<void> upsertLocal(NotificationModel row) =>
      cacheNotifications([row], fromCloud: false);

  /// Delta cursor for the inbox, or null to pull everything. Local-only rows
  /// carry no stamp, so they never move it.
  Future<String?> cursor(String uid) async =>
      syncCursorFrom((await getInbox(uid)).map((n) => n.lastUpdatedAt));

  /// Foreground listener: merges each live delta into Hive and ticks once
  /// per successful merge. Never evicts (that is sync's job) and never
  /// errors — a failed merge is skipped so the next delta can re-read.
  /// Built from stream operators so cancel finishes promptly.
  Stream<void> watchInbox(String uid) {
    if (uid.isEmpty) return const Stream<void>.empty();
    return Stream.fromFuture(cursor(uid))
        .asyncExpand((c) {
          return _remote
              .watchInboxDelta(recipientUid: uid, cursor: c)
              .asyncMap((rows) async {
                try {
                  await cacheNotifications(rows, fromCloud: true);
                  return true;
                } on Exception catch (e) {
                  if (kDebugMode) {
                    _logger.w('Merging a notification snapshot failed: $e');
                  }
                  return false;
                }
              })
              .where((merged) => merged)
              .map((_) {});
        })
        .handleError((Object e) {
          // A listener that errors (signed out, access lost) just ends; the
          // next sync reads what it missed.
          if (kDebugMode) _logger.w('Inbox listener ended: $e');
        });
  }

  /// Drops synced rows older than [pruneAfter]; queued rows are never
  /// pruned, and rows without a date are kept.
  Future<void> pruneInbox(String uid, {DateTime? now}) async {
    if (uid.isEmpty) return;
    final cutoff = (now ?? DateTime.now()).toUtc().subtract(pruneAfter);
    for (final row in await _db.getAll<NotificationHive>(
      HiveHelperImpl.notificationsBox,
    )) {
      if (row.recipientUid != uid || !row.synced) continue;
      final stamped =
          parseSyncTimestamp(row.creationDate) ??
          parseSyncTimestamp(row.lastUpdatedAt);
      if (stamped == null || !stamped.isBefore(cutoff)) continue;
      await _db.delete<NotificationHive>(
        HiveHelperImpl.notificationsBox,
        row.uid,
      );
    }
  }

  /// Caches inbox rows: a cloud row never replaces an unsynced read state,
  /// but refreshes everything around it.
  Future<void> cacheNotifications(
    List<NotificationModel> notifications, {
    required bool fromCloud,
  }) async {
    final cached = {
      for (final row in await _db.getAll<NotificationHive>(
        HiveHelperImpl.notificationsBox,
      ))
        row.uid: row,
    };
    await _db.putAll<NotificationHive>(HiveHelperImpl.notificationsBox, {
      for (final n in notifications)
        if (_accepts(
          fromCloud: fromCloud,
          cached: cached[n.uid] == null
              ? null
              : (
                  synced: cached[n.uid]!.synced,
                  lastUpdatedAt: cached[n.uid]!.lastUpdatedAt,
                ),
          incoming: n.lastUpdatedAt,
        ))
          n.uid: NotificationHive.fromModel(
            fromCloud ? n.copyWith(synced: true) : n,
          )
        // The merge keeps the local read state and takes the rest from the
        // server, so a queued read survives a refresh of its row.
        else if (fromCloud && cached[n.uid] != null && !cached[n.uid]!.synced)
          n.uid: NotificationHive.fromModel(
            n.copyWith(
              status: cached[n.uid]!.status,
              readAt: cached[n.uid]!.readAt,
              lastUpdatedAt: cached[n.uid]!.lastUpdatedAt,
              synced: false,
            ),
          ),
    });
  }

  /// Marks read optimistically, then sends it; offline the row stays queued
  /// and is returned. Local-only rows never leave the device.
  Future<NotificationModel> markRead(String uid, String notificationUid) async {
    final row = await _db.get<NotificationHive>(
      HiveHelperImpl.notificationsBox,
      notificationUid,
    );
    if (row == null || row.recipientUid != uid) throw AppError.dataNotFound;
    if (row.toModel().isLocalOnly) {
      final read = row.toModel().copyWith(
        status: NotificationStatus.read.value,
        readAt: syncTimestamp(),
      );
      await _db.put<NotificationHive>(
        HiveHelperImpl.notificationsBox,
        notificationUid,
        NotificationHive.fromModel(read),
      );
      return read;
    }
    final now = syncTimestamp();
    final read = row.toModel().copyWith(
      status: NotificationStatus.read.value,
      readAt: now,
      lastUpdatedAt: now,
      synced: false,
    );
    await _db.put<NotificationHive>(
      HiveHelperImpl.notificationsBox,
      notificationUid,
      NotificationHive.fromModel(read),
    );
    try {
      await _remote.markRead(notificationUid: notificationUid, readAt: now);
    } on AppError catch (e) {
      if (_offline.contains(e)) return read;
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchById(uid, read);
      rethrow;
    }
    return await _markSynced(notificationUid);
  }

  /// Replays every queued read in scope; attempts all of them, then rethrows
  /// the first failure, if any. Local-only rows are never sent.
  Future<void> replayPendingReads(String uid) async {
    if (uid.isEmpty) return;
    AppError? firstFailure;
    for (final row in await getUnsynced(uid)) {
      if (row.isLocalOnly) continue;
      try {
        await _remote.markRead(notificationUid: row.uid, readAt: row.readAt);
      } on AppError catch (e) {
        // Transient (and unknown) errors stay queued for the next flush.
        if (_dropAndRefetch.contains(e)) await _dropAndRefetchById(uid, row);
        firstFailure ??= e;
        continue;
      }
      await _markSynced(row.uid);
    }
    if (firstFailure != null) throw firstFailure;
  }

  /// Drops the queued read for the server truth: the refetch runs first, so
  /// a transient refetch failure leaves the queued row in place.
  Future<void> _dropAndRefetchById(String uid, NotificationModel row) async {
    List<NotificationModel> fresh;
    try {
      fresh = await _remote.fetchInboxDelta(recipientUid: uid);
    } on AppError catch (e) {
      // A denied refetch evicts the row; anything else stays queued.
      if (e == AppError.permissionDenied) {
        await _evict(row.uid, 'refetch denied');
      }
      return;
    }
    final match = fresh.where((n) => n.uid == row.uid).firstOrNull;
    if (match == null) {
      await _evict(row.uid, 'gone server-side');
      return;
    }
    // Direct: the merge guard would keep the queued row this replaces.
    await _db.put<NotificationHive>(
      HiveHelperImpl.notificationsBox,
      row.uid,
      NotificationHive.fromModel(match.copyWith(synced: true)),
    );
  }

  Future<NotificationModel> _markSynced(String notificationUid) async {
    final row = await _db.get<NotificationHive>(
      HiveHelperImpl.notificationsBox,
      notificationUid,
    );
    // Deleted under us (a concurrent sign-out wipes the boxes): the server
    // already has the read, so there is nothing left to do.
    if (row == null) throw AppError.dataNotFound;
    final synced = row.toModel().copyWith(synced: true);
    await _db.put<NotificationHive>(
      HiveHelperImpl.notificationsBox,
      notificationUid,
      NotificationHive.fromModel(synced),
    );
    return synced;
  }

  Future<void> _evict(String notificationUid, String reason) async {
    if (kDebugMode) {
      _logger.i('Evicting notification $notificationUid: $reason.');
    }
    await _db.delete<NotificationHive>(
      HiveHelperImpl.notificationsBox,
      notificationUid,
    );
  }
}
