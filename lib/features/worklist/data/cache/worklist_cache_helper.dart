import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/worklist/data/cache/worklist_rank.dart';
import 'package:tabibu/features/worklist/data/datasources/worklist_firebase.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_hive.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

/// Cached pathologist desk: the layer the blocs call.
@lazySingleton
class WorklistCacheHelper {
  WorklistCacheHelper({required this._db, required this._remote});

  final DBHelper _db;
  final WorklistFirebase _remote;
  final Logger _logger = Logger();

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

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
  Future<List<WorklistEntryModel>> syncDesk(
    String pathologistUid, {
    String? since,
    DateTime? now,
  }) async {
    if (pathologistUid.isEmpty) return const [];
    try {
      final remote = await _remote.fetchPathologistDelta(
        pathologistUid: pathologistUid,
        cursor: since ?? await deskCursor(pathologistUid),
      );
      await cacheEntries(
        remote,
        fromCloud: true,
        pathologistUid: pathologistUid,
      );
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getDesk(pathologistUid, now: now);
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getDesk(pathologistUid, now: now);
  }

  /// Open desk rows for [pathologistUid], ranked for [now] (UTC).
  Future<List<WorklistEntryModel>> getDesk(
    String pathologistUid, {
    DateTime? now,
  }) async {
    if (pathologistUid.isEmpty) return const [];
    final rows = [
      for (final row in await _db.getAll<WorklistEntryHive>(
        HiveHelperImpl.worklistBox,
      ))
        if (row.pathologistUid == pathologistUid && row.toModel().isOpen)
          row.toModel(),
    ];
    return WorklistRank.sorted(rows, now ?? DateTime.now().toUtc());
  }

  /// Delta cursor for the pathologist's desk, or null to pull everything.
  Future<String?> deskCursor(String pathologistUid) async {
    if (pathologistUid.isEmpty) return null;
    final stamps = [
      for (final row in await _db.getAll<WorklistEntryHive>(
        HiveHelperImpl.worklistBox,
      ))
        if (row.pathologistUid == pathologistUid) row.lastUpdatedAt,
    ];
    return syncCursorFrom(stamps);
  }

  /// Caches desk rows under the merge guard. Entries whose
  /// [WorklistEntryModel.pathologistUid] is empty or not [pathologistUid] are
  /// evicted (F-14: left the case).
  Future<void> cacheEntries(
    List<WorklistEntryModel> entries, {
    required bool fromCloud,
    required String pathologistUid,
  }) async {
    if (pathologistUid.isEmpty) return;
    final cached = {
      for (final row in await _db.getAll<WorklistEntryHive>(
        HiveHelperImpl.worklistBox,
      ))
        row.caseUid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    final toPut = <String, WorklistEntryHive>{};
    for (final e in entries) {
      final key = e.caseUid.isEmpty ? e.uid : e.caseUid;
      if (key.isEmpty) continue;
      if (e.pathologistUid != pathologistUid || e.pathologistUid.isEmpty) {
        await _evict(key, 'left the case');
        continue;
      }
      if (_accepts(
        fromCloud: fromCloud,
        cached: cached[key],
        incoming: e.lastUpdatedAt,
      )) {
        toPut[key] = WorklistEntryHive.fromModel(
          fromCloud ? e.copyWith(synced: true) : e,
        );
      }
    }
    if (toPut.isNotEmpty) {
      await _db.putAll<WorklistEntryHive>(HiveHelperImpl.worklistBox, toPut);
    }
  }

  /// Drops a desk row the pathologist no longer owns (F-14).
  Future<void> evictEntry(String caseUid) => _evict(caseUid, 'evict');

  Future<void> _evict(String caseUid, String reason) async {
    if (caseUid.isEmpty) return;
    if (kDebugMode) _logger.i('Evicting worklist $caseUid: $reason.');
    await _db.delete<WorklistEntryHive>(HiveHelperImpl.worklistBox, caseUid);
  }
}
