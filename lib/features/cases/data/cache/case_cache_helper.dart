import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';
import 'package:tabibu/features/cases/data/datasources/share_code_firebase.dart';
import 'package:tabibu/features/cases/data/models/case_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_hive.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/case_payment_hive.dart';
import 'package:tabibu/features/cases/data/models/case_payment_model.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_hive.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_model.dart';
import 'package:tabibu/features/cases/data/models/risk_check_hive.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';
import 'package:tabibu/features/cases/data/models/share_code_hive.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';

/// Cached cases, logs, payment, share codes, risk checks and notes
/// translations: the layer the blocs call.
@lazySingleton
class CaseCacheHelper {
  CaseCacheHelper({
    required this._db,
    required this._cases,
    required this._shares,
  });

  final DBHelper _db;
  final CaseFirebase _cases;
  final ShareCodeFirebase _shares;
  final Logger _logger = Logger();

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  static const Set<AppError> _dropAndRefetch = {
    .permissionDenied,
    .dataNotFound,
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

  /// Strips a share-code secret before any cache write (T-18).
  static Map<String, dynamic> stripShareSecret(Map<String, dynamic> raw) {
    final cleaned = Map<String, dynamic>.from(raw)..remove('code');
    return cleaned;
  }

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<List<CaseModel>> syncCases(String uid, {String? since}) async {
    if (uid.isEmpty) return const [];
    try {
      final cursor = since ?? await casesCursor(uid);
      final remote = await _cases.fetchParticipantDelta(
        uid: uid,
        cursor: cursor,
      );
      await cacheCases(remote, fromCloud: true, viewerUid: uid);
      await _evictUntoldCases(uid, {
        for (final c in remote) c.uid,
      }, fullPull: cursor == null || cursor.isEmpty);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getCases(uid);
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getCases(uid);
  }

  /// Cases where [uid] is in [CaseModel.participantUids].
  Future<List<CaseModel>> getCases(String uid) async {
    if (uid.isEmpty) return const [];
    return [
      for (final row in await _db.getAll<CaseHive>(HiveHelperImpl.casesBox))
        if (row.participantUids.contains(uid)) row.toModel(),
    ];
  }

  /// Delta cursor for the participant's cases, or null to pull everything.
  Future<String?> casesCursor(String uid) async =>
      syncCursorFrom((await getCases(uid)).map((c) => c.lastUpdatedAt));

  /// Caches cases under the merge guard. A row that no longer lists
  /// [viewerUid] in [CaseModel.participantUids] is evicted with its children.
  Future<void> cacheCases(
    List<CaseModel> cases, {
    required bool fromCloud,
    required String viewerUid,
  }) async {
    if (viewerUid.isEmpty) return;
    final cached = {
      for (final row in await _db.getAll<CaseHive>(HiveHelperImpl.casesBox))
        row.uid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    final toPut = <String, CaseHive>{};
    for (final c in cases) {
      if (!c.participantUids.contains(viewerUid)) {
        await evictCase(c.uid);
        continue;
      }
      if (_accepts(
        fromCloud: fromCloud,
        cached: cached[c.uid],
        incoming: c.lastUpdatedAt,
      )) {
        toPut[c.uid] = CaseHive.fromModel(
          fromCloud ? c.copyWith(synced: true) : c,
        );
      }
    }
    if (toPut.isNotEmpty) {
      await _db.putAll<CaseHive>(HiveHelperImpl.casesBox, toPut);
    }
  }

  /// Evicts a case and every child row keyed by that case.
  Future<void> evictCase(String caseUid) async {
    if (caseUid.isEmpty) return;
    if (kDebugMode) _logger.i('Evicting case $caseUid and children.');
    await _db.delete<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    await _db.delete<CasePaymentHive>(HiveHelperImpl.casePaymentsBox, caseUid);
    await _db.delete<RiskCheckHive>(HiveHelperImpl.riskChecksBox, caseUid);
    await _db.delete<NotesTranslationHive>(
      HiveHelperImpl.notesTranslationsBox,
      caseUid,
    );
    for (final row in await _db.getAll<CaseLogEntryHive>(
      HiveHelperImpl.caseLogsBox,
    )) {
      if (row.caseUid == caseUid) {
        await _db.delete<CaseLogEntryHive>(
          HiveHelperImpl.caseLogsBox,
          _logKey(row.caseUid, row.seq),
        );
      }
    }
    for (final row in await _db.getAll<ShareCodeHive>(
      HiveHelperImpl.shareCodesBox,
    )) {
      if (row.caseUid == caseUid) {
        await _db.delete<ShareCodeHive>(HiveHelperImpl.shareCodesBox, row.uid);
      }
    }
  }

  /// Evicts cached cases the sync did not return. A full pull is
  /// authoritative, so untold rows go at once; after a delta each untold
  /// row is fetched again, and only a denied, missing, or non-member
  /// row goes.
  /// Anything else — including every failure — keeps the row, and queued
  /// rows stay for the replay queue.
  Future<void> _evictUntoldCases(
    String uid,
    Set<String> told, {
    required bool fullPull,
  }) async {
    for (final row in await _db.getAll<CaseHive>(HiveHelperImpl.casesBox)) {
      if (!row.participantUids.contains(uid) ||
          told.contains(row.uid) ||
          !row.synced) {
        continue;
      }
      if (fullPull) {
        await evictCase(row.uid);
        continue;
      }
      CaseModel? fresh;
      try {
        fresh = await _cases.fetchCase(row.uid);
      } on AppError catch (e) {
        if (_dropAndRefetch.contains(e)) await evictCase(row.uid);
        continue;
      }
      if (fresh == null || !fresh.participantUids.contains(uid)) {
        await evictCase(row.uid);
      } else if (fresh.lastUpdatedAt.compareTo(row.lastUpdatedAt) > 0) {
        await cacheCases([fresh], fromCloud: true, viewerUid: uid);
      }
    }
  }

  String _logKey(String caseUid, int seq) => '${caseUid}_$seq';

  /// Syncs the case log for [role]: patients get only patient-visible rows.
  Future<List<CaseLogEntryModel>> syncLog({
    required String caseUid,
    required Role role,
  }) async {
    if (caseUid.isEmpty) return const [];
    try {
      final remote = role == Role.patient
          ? await _cases.fetchPatientLog(caseUid)
          : await _cases.fetchClinicianLog(caseUid);
      await cacheLogEntries(remote, fromCloud: true, role: role);
    } on AppError catch (e) {
      // A denied read evicts the rows this role could see; other scopes
      // on the device stay untouched.
      if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
        for (final row in await _db.getAll<CaseLogEntryHive>(
          HiveHelperImpl.caseLogsBox,
        )) {
          if (row.caseUid == caseUid &&
              (role != Role.patient || row.patientVisible)) {
            await _db.delete<CaseLogEntryHive>(
              HiveHelperImpl.caseLogsBox,
              _logKey(row.caseUid, row.seq),
            );
          }
        }
      }
      if (!_offline.contains(e)) rethrow;
      final cached = await getLog(caseUid, role: role);
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getLog(caseUid, role: role);
  }

  /// Cached log rows for [caseUid], scoped by [role].
  Future<List<CaseLogEntryModel>> getLog(
    String caseUid, {
    required Role role,
  }) async {
    if (caseUid.isEmpty) return const [];
    final rows = [
      for (final row in await _db.getAll<CaseLogEntryHive>(
        HiveHelperImpl.caseLogsBox,
      ))
        if (row.caseUid == caseUid &&
            (role != Role.patient || row.patientVisible))
          row.toModel(),
    ]..sort((a, b) => a.seq.compareTo(b.seq));
    return rows;
  }

  /// Caches log rows; a patient never stores a non-visible entry (S-3).
  Future<void> cacheLogEntries(
    List<CaseLogEntryModel> entries, {
    required bool fromCloud,
    required Role role,
  }) async {
    final cached = {
      for (final row in await _db.getAll<CaseLogEntryHive>(
        HiveHelperImpl.caseLogsBox,
      ))
        _logKey(row.caseUid, row.seq): (
          synced: row.synced,
          lastUpdatedAt: row.lastUpdatedAt,
        ),
    };
    await _db.putAll<CaseLogEntryHive>(HiveHelperImpl.caseLogsBox, {
      for (final e in entries)
        if ((role != Role.patient || e.patientVisible) &&
            _accepts(
              fromCloud: fromCloud,
              cached: cached[_logKey(e.caseUid, e.seq)],
              incoming: e.lastUpdatedAt,
            ))
          _logKey(e.caseUid, e.seq): CaseLogEntryHive.fromModel(
            fromCloud ? e.copyWith(synced: true) : e,
          ),
    });
  }

  /// Payment for [caseUid], only when [viewerUid] is the case's doctor or
  /// patient.
  Future<CasePaymentModel?> syncPayment({
    required String caseUid,
    required String viewerUid,
  }) async {
    if (caseUid.isEmpty || viewerUid.isEmpty) return null;
    final caseRow = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (caseRow == null ||
        (caseRow.doctorUid != viewerUid && caseRow.patientUid != viewerUid)) {
      return null;
    }
    try {
      final remote = await _cases.fetchPayment(caseUid);
      if (remote != null) {
        await cachePayment(
          remote,
          fromCloud: true,
          viewerUid: viewerUid,
          caseDoc: caseRow.toModel(),
        );
      } else {
        await _evictSyncedOnly<CasePaymentHive>(
          HiveHelperImpl.casePaymentsBox,
          caseUid,
          (await getPayment(caseUid, viewerUid))?.synced ?? true,
          'payment $caseUid gone server-side',
        );
      }
    } on AppError catch (e) {
      // A denied read evicts the synced row; unsent work stays queued.
      if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
        await _evictSyncedOnly<CasePaymentHive>(
          HiveHelperImpl.casePaymentsBox,
          caseUid,
          (await getPayment(caseUid, viewerUid))?.synced ?? true,
          'payment $caseUid sync denied',
        );
      }
      if (!_offline.contains(e)) rethrow;
      final cached = await getPayment(caseUid, viewerUid);
      if (cached == null) rethrow;
      return cached;
    }
    return await getPayment(caseUid, viewerUid);
  }

  /// Deletes the row at [key] unless it holds unsent work. A null row is
  /// already gone, so [cachedSynced] defaults to evicting.
  Future<void> _evictSyncedOnly<T>(
    String box,
    String key,
    bool cachedSynced,
    String reason,
  ) async {
    if (!cachedSynced) return;
    if (kDebugMode) _logger.i('Evicting $reason.');
    await _db.delete<T>(box, key);
  }

  /// Cached payment, only for the case's doctor or patient.
  Future<CasePaymentModel?> getPayment(String caseUid, String viewerUid) async {
    if (caseUid.isEmpty || viewerUid.isEmpty) return null;
    final caseRow = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (caseRow == null ||
        (caseRow.doctorUid != viewerUid && caseRow.patientUid != viewerUid)) {
      return null;
    }
    return (await _db.get<CasePaymentHive>(
      HiveHelperImpl.casePaymentsBox,
      caseUid,
    ))?.toModel();
  }

  /// Caches payment only when [viewerUid] is the case's doctor or patient.
  Future<void> cachePayment(
    CasePaymentModel payment, {
    required bool fromCloud,
    required String viewerUid,
    required CaseModel caseDoc,
  }) async {
    if (viewerUid.isEmpty) return;
    if (caseDoc.doctorUid != viewerUid && caseDoc.patientUid != viewerUid) {
      return;
    }
    final existing = await _db.get<CasePaymentHive>(
      HiveHelperImpl.casePaymentsBox,
      payment.caseUid,
    );
    if (!_accepts(
      fromCloud: fromCloud,
      cached: existing == null
          ? null
          : (synced: existing.synced, lastUpdatedAt: existing.lastUpdatedAt),
      incoming: payment.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<CasePaymentHive>(
      HiveHelperImpl.casePaymentsBox,
      payment.caseUid,
      CasePaymentHive.fromModel(
        fromCloud ? payment.copyWith(synced: true) : payment,
      ),
    );
  }

  /// Risk check for the case's doctor only.
  Future<RiskCheckModel?> syncRiskCheck({
    required String caseUid,
    required String doctorUid,
  }) async {
    if (caseUid.isEmpty || doctorUid.isEmpty) return null;
    final caseRow = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (caseRow == null || caseRow.doctorUid != doctorUid) return null;
    try {
      final remote = await _cases.fetchRiskCheck(caseUid);
      if (remote != null) {
        await cacheRiskCheck(
          remote,
          fromCloud: true,
          doctorUid: doctorUid,
          caseDoc: caseRow.toModel(),
        );
      } else {
        await _evictSyncedOnly<RiskCheckHive>(
          HiveHelperImpl.riskChecksBox,
          caseUid,
          (await getRiskCheck(caseUid, doctorUid))?.synced ?? true,
          'risk check $caseUid gone server-side',
        );
      }
    } on AppError catch (e) {
      // A denied read evicts the synced row; unsent work stays queued.
      if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
        await _evictSyncedOnly<RiskCheckHive>(
          HiveHelperImpl.riskChecksBox,
          caseUid,
          (await getRiskCheck(caseUid, doctorUid))?.synced ?? true,
          'risk check $caseUid sync denied',
        );
      }
      if (!_offline.contains(e)) rethrow;
      final cached = await getRiskCheck(caseUid, doctorUid);
      if (cached == null) rethrow;
      return cached;
    }
    return await getRiskCheck(caseUid, doctorUid);
  }

  Future<RiskCheckModel?> getRiskCheck(String caseUid, String doctorUid) async {
    if (caseUid.isEmpty || doctorUid.isEmpty) return null;
    final caseRow = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (caseRow == null || caseRow.doctorUid != doctorUid) return null;
    return (await _db.get<RiskCheckHive>(
      HiveHelperImpl.riskChecksBox,
      caseUid,
    ))?.toModel();
  }

  /// Caches a risk check only for the case's ordering doctor (S-8).
  Future<void> cacheRiskCheck(
    RiskCheckModel check, {
    required bool fromCloud,
    required String doctorUid,
    required CaseModel caseDoc,
  }) async {
    if (caseDoc.doctorUid != doctorUid) return;
    final existing = await _db.get<RiskCheckHive>(
      HiveHelperImpl.riskChecksBox,
      check.caseUid.isEmpty ? caseDoc.uid : check.caseUid,
    );
    final key = check.caseUid.isEmpty ? caseDoc.uid : check.caseUid;
    if (!_accepts(
      fromCloud: fromCloud,
      cached: existing == null
          ? null
          : (synced: existing.synced, lastUpdatedAt: existing.lastUpdatedAt),
      incoming: check.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<RiskCheckHive>(
      HiveHelperImpl.riskChecksBox,
      key,
      RiskCheckHive.fromModel(
        fromCloud
            ? check.copyWith(synced: true, caseUid: key)
            : check.copyWith(caseUid: key),
      ),
    );
  }

  /// Notes translation for the case's doctor or pathologist only.
  Future<NotesTranslationModel?> syncNotesTranslation({
    required String caseUid,
    required String viewerUid,
  }) async {
    if (caseUid.isEmpty || viewerUid.isEmpty) return null;
    final caseRow = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (caseRow == null ||
        (caseRow.doctorUid != viewerUid &&
            caseRow.pathologistUid != viewerUid)) {
      return null;
    }
    try {
      final remote = await _cases.fetchNotesTranslation(caseUid);
      if (remote != null) {
        await cacheNotesTranslation(
          remote,
          fromCloud: true,
          viewerUid: viewerUid,
          caseDoc: caseRow.toModel(),
        );
      } else {
        await _evictSyncedOnly<NotesTranslationHive>(
          HiveHelperImpl.notesTranslationsBox,
          caseUid,
          (await getNotesTranslation(caseUid, viewerUid))?.synced ?? true,
          'notes translation $caseUid gone server-side',
        );
      }
    } on AppError catch (e) {
      // A denied read evicts the synced row; unsent work stays queued.
      if (e == AppError.permissionDenied || e == AppError.dataNotFound) {
        await _evictSyncedOnly<NotesTranslationHive>(
          HiveHelperImpl.notesTranslationsBox,
          caseUid,
          (await getNotesTranslation(caseUid, viewerUid))?.synced ?? true,
          'notes translation $caseUid sync denied',
        );
      }
      if (!_offline.contains(e)) rethrow;
      final cached = await getNotesTranslation(caseUid, viewerUid);
      if (cached == null) rethrow;
      return cached;
    }
    return await getNotesTranslation(caseUid, viewerUid);
  }

  Future<NotesTranslationModel?> getNotesTranslation(
    String caseUid,
    String viewerUid,
  ) async {
    if (caseUid.isEmpty || viewerUid.isEmpty) return null;
    final caseRow = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (caseRow == null ||
        (caseRow.doctorUid != viewerUid &&
            caseRow.pathologistUid != viewerUid)) {
      return null;
    }
    return (await _db.get<NotesTranslationHive>(
      HiveHelperImpl.notesTranslationsBox,
      caseUid,
    ))?.toModel();
  }

  /// Caches notes translation only for the case doctor or pathologist (S-8).
  Future<void> cacheNotesTranslation(
    NotesTranslationModel notes, {
    required bool fromCloud,
    required String viewerUid,
    required CaseModel caseDoc,
  }) async {
    if (caseDoc.doctorUid != viewerUid && caseDoc.pathologistUid != viewerUid) {
      return;
    }
    final key = notes.caseUid.isEmpty ? caseDoc.uid : notes.caseUid;
    final existing = await _db.get<NotesTranslationHive>(
      HiveHelperImpl.notesTranslationsBox,
      key,
    );
    if (!_accepts(
      fromCloud: fromCloud,
      cached: existing == null
          ? null
          : (synced: existing.synced, lastUpdatedAt: existing.lastUpdatedAt),
      incoming: notes.lastUpdatedAt,
    )) {
      return;
    }
    await _db.put<NotesTranslationHive>(
      HiveHelperImpl.notesTranslationsBox,
      key,
      NotesTranslationHive.fromModel(
        fromCloud
            ? notes.copyWith(synced: true, caseUid: key)
            : notes.copyWith(caseUid: key),
      ),
    );
  }

  /// Share codes for the creator or recipient, remote first.
  Future<List<ShareCodeModel>> syncShareCodes({
    required String uid,
    required bool asCreator,
    String? since,
  }) async {
    if (uid.isEmpty) return const [];
    try {
      final cursor = since ?? await shareCodesCursor(uid, asCreator: asCreator);
      final remote = asCreator
          ? await _shares.fetchCreatorDelta(createdByUid: uid, cursor: cursor)
          : await _shares.fetchRecipientDelta(
              recipientUid: uid,
              cursor: cursor,
            );
      await cacheShareCodes(remote, fromCloud: true);
      await _evictUntoldShareCodes(uid, asCreator, {
        for (final s in remote) s.uid,
      }, fullPull: cursor == null || cursor.isEmpty);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await getShareCodes(uid, asCreator: asCreator);
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await getShareCodes(uid, asCreator: asCreator);
  }

  Future<List<ShareCodeModel>> getShareCodes(
    String uid, {
    required bool asCreator,
  }) async {
    if (uid.isEmpty) return const [];
    return [
      for (final row in await _db.getAll<ShareCodeHive>(
        HiveHelperImpl.shareCodesBox,
      ))
        if (asCreator ? row.createdByUid == uid : row.recipientUid == uid)
          row.toModel(),
    ];
  }

  Future<String?> shareCodesCursor(
    String uid, {
    required bool asCreator,
  }) async => syncCursorFrom(
    (await getShareCodes(
      uid,
      asCreator: asCreator,
    )).map((s) => s.lastUpdatedAt),
  );

  /// Caches share codes; any secret `code` field is stripped first (T-18).
  Future<void> cacheShareCodes(
    List<ShareCodeModel> codes, {
    required bool fromCloud,
  }) async {
    final cached = {
      for (final row in await _db.getAll<ShareCodeHive>(
        HiveHelperImpl.shareCodesBox,
      ))
        row.uid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    await _db.putAll<ShareCodeHive>(HiveHelperImpl.shareCodesBox, {
      for (final s in codes)
        if (_accepts(
          fromCloud: fromCloud,
          cached: cached[s.uid],
          incoming: s.lastUpdatedAt,
        ))
          s.uid: ShareCodeHive.fromModel(
            fromCloud ? s.copyWith(synced: true) : s,
          ),
    });
  }

  /// Evicts cached share codes the sync did not return, in the viewer's
  /// scope only. A full pull is authoritative; after a delta each untold row is
  /// fetched again, and only a denied, missing, or out-of-scope row
  /// goes. Anything else keeps the row, and queued rows stay for replay.
  Future<void> _evictUntoldShareCodes(
    String uid,
    bool asCreator,
    Set<String> told, {
    required bool fullPull,
  }) async {
    bool inScope(ShareCodeHive row) =>
        asCreator ? row.createdByUid == uid : row.recipientUid == uid;
    for (final row in await _db.getAll<ShareCodeHive>(
      HiveHelperImpl.shareCodesBox,
    )) {
      if (!inScope(row) || told.contains(row.uid) || !row.synced) continue;
      if (fullPull) {
        await evictShareCode(row.uid);
        continue;
      }
      ShareCodeModel? fresh;
      try {
        fresh = await _shares.fetchShareCode(row.uid);
      } on AppError catch (e) {
        if (_dropAndRefetch.contains(e)) await evictShareCode(row.uid);
        continue;
      }
      final outOfScope =
          fresh == null ||
          (asCreator ? fresh.createdByUid != uid : fresh.recipientUid != uid);
      if (outOfScope) {
        await evictShareCode(row.uid);
      } else if (fresh.lastUpdatedAt.compareTo(row.lastUpdatedAt) > 0) {
        await cacheShareCodes([fresh], fromCloud: true);
      }
    }
  }

  /// Evicts one share code.
  Future<void> evictShareCode(String shareUid) async {
    if (shareUid.isEmpty) return;
    if (kDebugMode) _logger.i('Evicting share code $shareUid.');
    await _db.delete<ShareCodeHive>(HiveHelperImpl.shareCodesBox, shareUid);
  }

  /// Caches share-code maps from a callable or snapshot after stripping
  /// secrets.
  Future<void> cacheShareCodeMaps(
    List<Map<String, dynamic>> raw, {
    required bool fromCloud,
  }) async {
    final models = [
      for (final m in raw) ShareCodeModel.fromJson(stripShareSecret(m)),
    ];
    await cacheShareCodes(models, fromCloud: fromCloud);
  }

  /// Queues doctor notes locally, then sends; offline they stay queued.
  Future<CaseModel> saveDoctorNotes({
    required String caseUid,
    required String clinicalNotes,
    String? sampleNotes,
    String? sampleCollectedAt,
  }) async {
    final row = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (row == null) throw AppError.dataNotFound;
    final now = syncTimestamp();
    final edited = row.toModel().copyWith(
      clinicalNotes: clinicalNotes,
      sampleNotes: sampleNotes ?? row.sampleNotes,
      sampleCollectedAt: sampleCollectedAt ?? row.sampleCollectedAt,
      lastUpdatedAt: now,
      synced: false,
    );
    await cacheCases([edited], fromCloud: false, viewerUid: edited.doctorUid);
    try {
      await _cases.updateDoctorNotes(
        caseUid: caseUid,
        currentStage: edited.currentStage,
        clinicalNotes: clinicalNotes,
        sampleNotes: sampleNotes,
        sampleCollectedAt: sampleCollectedAt,
      );
    } on AppError catch (e) {
      if (_offline.contains(e)) return edited;
      if (_dropAndRefetch.contains(e)) {
        await _dropAndRefetchCase(edited);
      }
      rethrow;
    }
    return await _markCaseSynced(caseUid);
  }

  /// Replays queued case notes edits in scope.
  Future<void> replayPendingCaseEdits(String uid) async {
    if (uid.isEmpty) return;
    AppError? firstFailure;
    for (final row in await _db.getAll<CaseHive>(HiveHelperImpl.casesBox)) {
      if (row.synced || row.doctorUid != uid) continue;
      try {
        await _replayNotes(row.toModel());
      } on AppError catch (e) {
        firstFailure ??= e;
      }
    }
    if (firstFailure != null) throw firstFailure;
  }

  Future<void> _replayNotes(CaseModel row) async {
    try {
      await _cases.updateDoctorNotes(
        caseUid: row.uid,
        currentStage: row.currentStage,
        clinicalNotes: row.clinicalNotes,
        sampleNotes: row.sampleNotes,
        sampleCollectedAt: row.sampleCollectedAt,
      );
    } on AppError catch (e) {
      if (_dropAndRefetch.contains(e)) await _dropAndRefetchCase(row);
      rethrow;
    }
    await _markCaseSynced(row.uid);
  }

  Future<void> _dropAndRefetchCase(CaseModel row) async {
    CaseModel? fresh;
    try {
      fresh = await _cases.fetchCase(row.uid);
    } on AppError catch (e) {
      if (e == AppError.permissionDenied) {
        await evictCase(row.uid);
      }
      return;
    }
    if (fresh == null || !fresh.participantUids.contains(row.doctorUid)) {
      await evictCase(row.uid);
      return;
    }
    await _db.put<CaseHive>(
      HiveHelperImpl.casesBox,
      row.uid,
      CaseHive.fromModel(fresh.copyWith(synced: true)),
    );
  }

  Future<CaseModel> _markCaseSynced(String caseUid) async {
    final row = await _db.get<CaseHive>(HiveHelperImpl.casesBox, caseUid);
    if (row == null) throw AppError.dataNotFound;
    final synced = row.toModel().copyWith(synced: true);
    await _db.put<CaseHive>(
      HiveHelperImpl.casesBox,
      caseUid,
      CaseHive.fromModel(synced),
    );
    return synced;
  }
}
