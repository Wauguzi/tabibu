import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart';
import 'package:tabibu/features/reports/data/models/notifiable_finding_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_hive.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/preread_score_hive.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';
import 'package:tabibu/features/reports/data/models/report_draft_hive.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';
import 'package:tabibu/features/reports/data/models/report_response_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_hive.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';

/// Cached signed reports, own drafts, scores and approved texts: the layer
/// the blocs call. Never caches working texts, provenance, diffs or pre-read
/// runs (S-1).
@lazySingleton
class ReportCacheHelper {
  ReportCacheHelper({required this._db, required this._remote});

  final DBHelper _db;
  final ReportFirebase _remote;
  final Logger _logger = Logger();

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  /// Replay mapping (§3.8). `failed-precondition` (e.g. after signing) maps
  /// to [AppError.unknown] today, so draft replay also drops on unknown.
  static const Set<AppError> _dropAndRefetch = {
    .permissionDenied,
    .dataNotFound,
    .unknown,
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

  String _reportKey(String caseUid, String reportUid) =>
      '${caseUid}_$reportUid';

  String _draftKey(String caseUid, String pathologistUid) =>
      '${caseUid}_$pathologistUid';

  String _scoreKey(String caseUid, String runUid) => '${caseUid}_$runUid';

  String _textKey(String caseUid, String textUid) => '${caseUid}_$textUid';

  /// Remote first. Patients use the release filter; clinicians use reader
  /// scope. Unreleased reports are never written for a patient (S-3).
  Future<List<PathologyReportModel>> syncReports(
    String uid, {
    required Role role,
    String? since,
  }) async {
    if (uid.isEmpty) return const [];
    try {
      final cursor = since ?? await reportsCursor(uid, role: role);
      final remote = role == Role.patient
          ? await _remote.fetchPatientDelta(uid: uid, cursor: cursor)
          : await _remote.fetchReaderDelta(uid: uid, cursor: cursor);
      await cacheReports(remote, fromCloud: true, viewerUid: uid, role: role);
      await _evictUntoldReports(uid, role, {
        for (final r in remote) _reportKey(r.caseUid, r.uid),
      }, fullPull: cursor == null || cursor.isEmpty);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getReports(uid, role: role);
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getReports(uid, role: role);
  }

  /// Cached reports in [uid]'s reader scope; patients only see released ones.
  Future<List<PathologyReportModel>> getReports(
    String uid, {
    required Role role,
  }) async {
    if (uid.isEmpty) return const [];
    return [
      for (final row in await _db.getAll<PathologyReportHive>(
        HiveHelperImpl.pathologyReportsBox,
      ))
        if (row.readerUids.contains(uid) &&
            (role != Role.patient || row.releasedToPatient))
          row.toModel(),
    ];
  }

  Future<String?> reportsCursor(String uid, {required Role role}) async =>
      syncCursorFrom(
        (await getReports(uid, role: role)).map((r) => r.lastUpdatedAt),
      );

  /// Caches reports under the merge guard. A patient never stores an
  /// unreleased report, whatever the data source returned (S-3).
  Future<void> cacheReports(
    List<PathologyReportModel> reports, {
    required bool fromCloud,
    required String viewerUid,
    required Role role,
  }) async {
    if (viewerUid.isEmpty) return;
    final cached = {
      for (final row in await _db.getAll<PathologyReportHive>(
        HiveHelperImpl.pathologyReportsBox,
      ))
        _reportKey(row.caseUid, row.uid): (
          synced: row.synced,
          lastUpdatedAt: row.lastUpdatedAt,
        ),
    };
    await _db.putAll<PathologyReportHive>(HiveHelperImpl.pathologyReportsBox, {
      for (final r in reports)
        if (r.readerUids.contains(viewerUid) &&
            (role != Role.patient || r.releasedToPatient) &&
            _accepts(
              fromCloud: fromCloud,
              cached: cached[_reportKey(r.caseUid, r.uid)],
              incoming: r.lastUpdatedAt,
            ))
          _reportKey(r.caseUid, r.uid): PathologyReportHive.fromModel(
            fromCloud ? r.copyWith(synced: true) : r,
          ),
    });
  }

  /// Evicts one report row. Scores and approved texts are keyed per case,
  /// not per report, so they stay: each syncs and evicts on its own.
  Future<void> evictReport(String caseUid, String reportUid) async {
    if (caseUid.isEmpty || reportUid.isEmpty) return;
    if (kDebugMode) _logger.i('Evicting report $caseUid/$reportUid.');
    await _db.delete<PathologyReportHive>(
      HiveHelperImpl.pathologyReportsBox,
      _reportKey(caseUid, reportUid),
    );
  }

  /// Evicts cached reports the sync did not return, in the viewer's scope
  /// only. A full pull is authoritative, so untold rows go at once; after
  /// a delta each untold row is fetched again, and only a denied,
  /// missing, or out-of-scope row goes. Anything else keeps the row.
  Future<void> _evictUntoldReports(
    String uid,
    Role role,
    Set<String> told, {
    required bool fullPull,
  }) async {
    bool inScope(PathologyReportHive row) =>
        row.readerUids.contains(uid) &&
        (role != Role.patient || row.releasedToPatient);
    for (final row in await _db.getAll<PathologyReportHive>(
      HiveHelperImpl.pathologyReportsBox,
    )) {
      if (!inScope(row) ||
          told.contains(_reportKey(row.caseUid, row.uid)) ||
          !row.synced) {
        continue;
      }
      if (fullPull) {
        await evictReport(row.caseUid, row.uid);
        continue;
      }
      PathologyReportModel? fresh;
      try {
        fresh = await _remote.fetchReport(
          caseUid: row.caseUid,
          reportUid: row.uid,
        );
      } on AppError catch (e) {
        // Denied or missing only: unknown stays, unlike draft replay.
        if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
          await evictReport(row.caseUid, row.uid);
        }
        continue;
      }
      if (fresh == null ||
          !fresh.readerUids.contains(uid) ||
          (role == Role.patient && !fresh.releasedToPatient)) {
        await evictReport(row.caseUid, row.uid);
      } else if (fresh.lastUpdatedAt.compareTo(row.lastUpdatedAt) > 0) {
        await cacheReports(
          [fresh],
          fromCloud: true,
          viewerUid: uid,
          role: role,
        );
      }
    }
  }

  /// Own draft for [pathologistUid] on [caseUid], remote first.
  Future<ReportDraftModel?> syncDraft({
    required String caseUid,
    required String pathologistUid,
  }) async {
    if (caseUid.isEmpty || pathologistUid.isEmpty) return null;
    try {
      final remote = await _remote.fetchDraft(
        caseUid: caseUid,
        pathologistUid: pathologistUid,
      );
      if (remote != null && remote.pathologistUid == pathologistUid) {
        await cacheDraft(
          remote,
          fromCloud: true,
          pathologistUid: pathologistUid,
        );
      } else if (remote == null) {
        // The server deleted it (e.g. after signing); unsent work stays.
        final cached = await getDraft(caseUid, pathologistUid);
        if (cached != null && cached.synced) {
          await _evictDraft(caseUid, pathologistUid, 'gone server-side');
        }
      }
    } on AppError catch (e) {
      // A denied read evicts the synced row; unsent work stays queued.
      if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
        final cached = await getDraft(caseUid, pathologistUid);
        if (cached != null && cached.synced) {
          await _evictDraft(caseUid, pathologistUid, 'sync denied');
        }
      }
      if (!_offline.contains(e)) rethrow;
      final cached = await getDraft(caseUid, pathologistUid);
      if (cached == null) rethrow;
      return cached;
    }
    return await getDraft(caseUid, pathologistUid);
  }

  Future<ReportDraftModel?> getDraft(
    String caseUid,
    String pathologistUid,
  ) async {
    if (caseUid.isEmpty || pathologistUid.isEmpty) return null;
    final row = await _db.get<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
      _draftKey(caseUid, pathologistUid),
    );
    if (row == null || row.pathologistUid != pathologistUid) return null;
    return row.toModel();
  }

  /// Caches only the pathologist's own draft.
  Future<void> cacheDraft(
    ReportDraftModel draft, {
    required bool fromCloud,
    required String pathologistUid,
  }) async {
    if (draft.pathologistUid != pathologistUid) return;
    final key = _draftKey(draft.caseUid, draft.pathologistUid);
    final existing = await _db.get<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
      key,
    );
    if (!_accepts(
      fromCloud: fromCloud,
      cached: existing == null
          ? null
          : (synced: existing.synced, lastUpdatedAt: existing.lastUpdatedAt),
      incoming: draft.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
      key,
      ReportDraftHive.fromModel(
        fromCloud ? draft.copyWith(synced: true) : draft,
      ),
    );
  }

  /// True while any queued field edit for that case's draft is unsynced (F-2).
  Future<bool> hasUnsyncedDraftEdits(String caseUid) async {
    if (caseUid.isEmpty) return false;
    for (final row in await _db.getAll<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
    )) {
      if (row.caseUid == caseUid && !row.synced) return true;
    }
    return false;
  }

  /// Queues a draft field edit locally, then sends; offline it stays queued.
  Future<ReportDraftModel> saveDraftFields({
    required String caseUid,
    required String pathologistUid,
    required Map<String, dynamic> fields,
  }) async {
    final current = await getDraft(caseUid, pathologistUid);
    if (current == null) throw AppError.dataNotFound;
    final now = syncTimestamp();
    var next = current.copyWith(lastUpdatedAt: now, synced: false);
    for (final entry in fields.entries) {
      next = _applyDraftField(next, entry.key, entry.value);
    }
    await cacheDraft(next, fromCloud: false, pathologistUid: pathologistUid);
    try {
      await _remote.updateDraft(
        caseUid: caseUid,
        pathologistUid: pathologistUid,
        fields: fields,
      );
    } on AppError catch (e) {
      if (_offline.contains(e)) return next;
      if (_dropAndRefetch.contains(e)) {
        await _dropAndRefetchDraft(caseUid, pathologistUid);
      }
      rethrow;
    }
    return await _markDraftSynced(caseUid, pathologistUid);
  }

  /// Replays every queued draft edit for [pathologistUid].
  Future<void> replayPendingDraftEdits(String pathologistUid) async {
    if (pathologistUid.isEmpty) return;
    AppError? firstFailure;
    for (final row in await _db.getAll<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
    )) {
      if (row.synced || row.pathologistUid != pathologistUid) continue;
      try {
        await _replayDraft(row.toModel());
      } on AppError catch (e) {
        firstFailure ??= e;
      }
    }
    if (firstFailure != null) throw firstFailure;
  }

  Future<void> _replayDraft(ReportDraftModel row) async {
    final fields = <String, dynamic>{
      'title': row.title,
      'diagnosisType': row.diagnosisType,
      'diagnosis': row.diagnosis,
      'comments': row.comments,
      'responses': [for (final r in row.responses) r.toJson()],
      'labelOverrides': row.labelOverrides,
      'labelOverrideCount': row.labelOverrideCount,
      'isCritical': row.isCritical,
      'diagnosisStartedAt': row.diagnosisStartedAt,
      'startedFromPreread': row.startedFromPreread,
      'language': row.language,
      'amendmentReason': row.amendmentReason,
      'addendumText': row.addendumText,
      'notifiableFindings': [
        for (final f in row.notifiableFindings) f.toJson(),
      ],
      'confirmatoryRequests': row.confirmatoryRequests,
      'hintShownDiseaseIds': row.hintShownDiseaseIds,
    };
    try {
      await _remote.updateDraft(
        caseUid: row.caseUid,
        pathologistUid: row.pathologistUid,
        fields: fields,
      );
    } on AppError catch (e) {
      if (_dropAndRefetch.contains(e)) {
        await _dropAndRefetchDraft(row.caseUid, row.pathologistUid);
      }
      rethrow;
    }
    await _markDraftSynced(row.caseUid, row.pathologistUid);
  }

  Future<void> _dropAndRefetchDraft(
    String caseUid,
    String pathologistUid,
  ) async {
    ReportDraftModel? fresh;
    try {
      fresh = await _remote.fetchDraft(
        caseUid: caseUid,
        pathologistUid: pathologistUid,
      );
    } on AppError catch (e) {
      if (e == AppError.permissionDenied) {
        await _evictDraft(caseUid, pathologistUid, 'refetch denied');
      }
      return;
    }
    final key = _draftKey(caseUid, pathologistUid);
    if (fresh == null || fresh.pathologistUid != pathologistUid) {
      await _evictDraft(caseUid, pathologistUid, 'gone server-side');
      return;
    }
    await _db.put<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
      key,
      ReportDraftHive.fromModel(fresh.copyWith(synced: true)),
    );
  }

  Future<ReportDraftModel> _markDraftSynced(
    String caseUid,
    String pathologistUid,
  ) async {
    final row = await getDraft(caseUid, pathologistUid);
    if (row == null) throw AppError.dataNotFound;
    final synced = row.copyWith(synced: true);
    await _db.put<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
      _draftKey(caseUid, pathologistUid),
      ReportDraftHive.fromModel(synced),
    );
    return synced;
  }

  Future<void> _evictDraft(
    String caseUid,
    String pathologistUid,
    String reason,
  ) async {
    if (kDebugMode) {
      _logger.i('Evicting draft $caseUid/$pathologistUid: $reason.');
    }
    await _db.delete<ReportDraftHive>(
      HiveHelperImpl.reportDraftsBox,
      _draftKey(caseUid, pathologistUid),
    );
  }

  ReportDraftModel _applyDraftField(
    ReportDraftModel draft,
    String key,
    dynamic value,
  ) => switch (key) {
    'title' => draft.copyWith(title: value as String),
    'diagnosisType' => draft.copyWith(diagnosisType: value as String),
    'diagnosis' => draft.copyWith(diagnosis: value as String),
    'comments' => draft.copyWith(comments: value as String),
    'responses' => draft.copyWith(
      responses: [
        for (final r in value as List)
          ReportResponseModel.fromJson(Map<String, dynamic>.from(r as Map)),
      ],
    ),
    'isCritical' => draft.copyWith(isCritical: value as bool),
    'diagnosisStartedAt' => draft.copyWith(diagnosisStartedAt: value as String),
    'startedFromPreread' => draft.copyWith(startedFromPreread: value as bool),
    'language' => draft.copyWith(language: value as String),
    'amendmentReason' => draft.copyWith(amendmentReason: value as String),
    'addendumText' => draft.copyWith(addendumText: value as String),
    'notifiableFindings' => draft.copyWith(
      notifiableFindings: [
        for (final f in value as List)
          NotifiableFindingModel.fromJson(Map<String, dynamic>.from(f as Map)),
      ],
    ),
    'labelOverrides' => draft.copyWith(
      labelOverrides: Map<String, String>.from(value as Map),
    ),
    'labelOverrideCount' => draft.copyWith(labelOverrideCount: value as int),
    'confirmatoryRequests' => draft.copyWith(
      confirmatoryRequests: List<String>.from(value as List),
    ),
    'hintShownDiseaseIds' => draft.copyWith(
      hintShownDiseaseIds: List<String>.from(value as List),
    ),
    _ => draft,
  };

  /// Own pre-read score, remote first.
  Future<PrereadScoreModel?> syncPrereadScore({
    required String caseUid,
    required String runUid,
    required String pathologistUid,
  }) async {
    if (caseUid.isEmpty || runUid.isEmpty || pathologistUid.isEmpty) {
      return null;
    }
    try {
      final remote = await _remote.fetchPrereadScore(
        caseUid: caseUid,
        runUid: runUid,
      );
      if (remote != null && remote.pathologistUid == pathologistUid) {
        await cachePrereadScore(
          remote,
          fromCloud: true,
          pathologistUid: pathologistUid,
        );
      } else if (remote == null) {
        final cached = await getPrereadScore(caseUid, runUid, pathologistUid);
        if (cached != null && cached.synced) {
          await _evictScore(caseUid, runUid, 'gone server-side');
        }
      }
    } on AppError catch (e) {
      // A denied read evicts the synced row; unsent work stays queued.
      if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
        final cached = await getPrereadScore(caseUid, runUid, pathologistUid);
        if (cached != null && cached.synced) {
          await _evictScore(caseUid, runUid, 'sync denied');
        }
      }
      if (!_offline.contains(e)) rethrow;
      final cached = await getPrereadScore(caseUid, runUid, pathologistUid);
      if (cached == null) rethrow;
      return cached;
    }
    return await getPrereadScore(caseUid, runUid, pathologistUid);
  }

  Future<void> _evictScore(String caseUid, String runUid, String reason) async {
    if (kDebugMode) _logger.i('Evicting score $caseUid/$runUid: $reason.');
    await _db.delete<PrereadScoreHive>(
      HiveHelperImpl.prereadScoresBox,
      _scoreKey(caseUid, runUid),
    );
  }

  Future<PrereadScoreModel?> getPrereadScore(
    String caseUid,
    String runUid,
    String pathologistUid,
  ) async {
    final row = await _db.get<PrereadScoreHive>(
      HiveHelperImpl.prereadScoresBox,
      _scoreKey(caseUid, runUid),
    );
    if (row == null || row.pathologistUid != pathologistUid) return null;
    return row.toModel();
  }

  Future<void> cachePrereadScore(
    PrereadScoreModel score, {
    required bool fromCloud,
    required String pathologistUid,
  }) async {
    if (score.pathologistUid != pathologistUid) return;
    final key = _scoreKey(
      score.caseUid,
      score.runUid.isEmpty ? score.uid : score.runUid,
    );
    final existing = await _db.get<PrereadScoreHive>(
      HiveHelperImpl.prereadScoresBox,
      key,
    );
    if (!_accepts(
      fromCloud: fromCloud,
      cached: existing == null
          ? null
          : (synced: existing.synced, lastUpdatedAt: existing.lastUpdatedAt),
      incoming: score.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<PrereadScoreHive>(
      HiveHelperImpl.prereadScoresBox,
      key,
      PrereadScoreHive.fromModel(
        fromCloud ? score.copyWith(synced: true) : score,
      ),
    );
  }

  /// Approved report text by id only (never a working text).
  Future<ReportTextApprovedModel?> syncApprovedText({
    required String caseUid,
    required String textUid,
  }) async {
    if (caseUid.isEmpty || textUid.isEmpty) return null;
    try {
      final remote = await _remote.fetchApprovedText(
        caseUid: caseUid,
        textUid: textUid,
      );
      if (remote != null) {
        await cacheApprovedText(remote, fromCloud: true);
      } else {
        final cached = await getApprovedText(caseUid, textUid);
        if (cached != null && cached.synced) {
          await _evictText(caseUid, textUid, 'gone server-side');
        }
      }
    } on AppError catch (e) {
      // A denied read evicts the synced row; unsent work stays queued.
      if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
        final cached = await getApprovedText(caseUid, textUid);
        if (cached != null && cached.synced) {
          await _evictText(caseUid, textUid, 'sync denied');
        }
      }
      if (!_offline.contains(e)) rethrow;
      final cached = await getApprovedText(caseUid, textUid);
      if (cached == null) rethrow;
      return cached;
    }
    return await getApprovedText(caseUid, textUid);
  }

  Future<void> _evictText(String caseUid, String textUid, String reason) async {
    if (kDebugMode) _logger.i('Evicting text $caseUid/$textUid: $reason.');
    await _db.delete<ReportTextApprovedHive>(
      HiveHelperImpl.reportTextsBox,
      _textKey(caseUid, textUid),
    );
  }

  Future<ReportTextApprovedModel?> getApprovedText(
    String caseUid,
    String textUid,
  ) async {
    return (await _db.get<ReportTextApprovedHive>(
      HiveHelperImpl.reportTextsBox,
      _textKey(caseUid, textUid),
    ))?.toModel();
  }

  Future<void> cacheApprovedText(
    ReportTextApprovedModel text, {
    required bool fromCloud,
  }) async {
    final key = _textKey(text.caseUid, text.uid);
    final existing = await _db.get<ReportTextApprovedHive>(
      HiveHelperImpl.reportTextsBox,
      key,
    );
    if (!_accepts(
      fromCloud: fromCloud,
      cached: existing == null
          ? null
          : (synced: existing.synced, lastUpdatedAt: existing.lastUpdatedAt),
      incoming: text.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<ReportTextApprovedHive>(
      HiveHelperImpl.reportTextsBox,
      key,
      ReportTextApprovedHive.fromModel(
        fromCloud ? text.copyWith(synced: true) : text,
      ),
    );
  }
}
