import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/alerts/data/datasources/alert_firebase.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_hive.dart';
import 'package:tabibu/features/alerts/data/models/alert_receipt_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_hive.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

/// Cached public alerts, clinician briefs and read receipts: the layer the
/// blocs call. The approver queue (`alerts`, `alertSignals`) is live only
/// and never cached (F-39); receipts are local only.
@lazySingleton
class AlertCacheHelper {
  AlertCacheHelper({required this._db, required this._remote});

  final DBHelper _db;
  final AlertFirebase _remote;
  final Logger _logger = Logger();

  /// Failures that mean "the cloud cannot be reached", for which the cache
  /// stands in.
  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

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

  /// The patient's released alerts for one county, remote first; the cache
  /// answers only when the cloud cannot be reached.
  Future<List<PublicAlertModel>> publicAlertsForCounty({
    required int countyId,
    required bool demo,
    String? since,
  }) async {
    if (countyId <= 0) return const [];
    try {
      final remote = await _remote.fetchPatientPublicAlerts(
        countyId: countyId,
        cursor: since ?? await patientAlertsCursor(countyId),
      );
      await cachePublicAlerts(remote, fromCloud: true, demo: demo);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await _cachedPatientAlerts(countyId, demo);
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await _cachedPatientAlerts(countyId, demo);
  }

  /// The clinician's alerts for one county, remote first; the cache answers
  /// only when the cloud cannot be reached.
  Future<List<PublicAlertModel>> publicAlertsForClinician({
    required int countyId,
    required bool demo,
    String? since,
  }) async {
    if (countyId <= 0) return const [];
    try {
      final remote = await _remote.fetchClinicianPublicAlerts(
        countyId: countyId,
        cursor: since ?? await clinicianAlertsCursor(countyId),
      );
      await cachePublicAlerts(remote, fromCloud: true, demo: demo);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await _cachedClinicianAlerts(countyId, demo);
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await _cachedClinicianAlerts(countyId, demo);
  }

  /// Caches public alerts under the merge guard; synthetic alerts are kept
  /// only for demo accounts.
  Future<void> cachePublicAlerts(
    List<PublicAlertModel> alerts, {
    required bool fromCloud,
    required bool demo,
  }) async {
    final cached = {
      for (final row in await _db.getAll<PublicAlertHive>(
        HiveHelperImpl.publicAlertsBox,
      ))
        row.uid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    await _db.putAll<PublicAlertHive>(HiveHelperImpl.publicAlertsBox, {
      for (final a in alerts)
        if ((demo || !a.synthetic) &&
            _accepts(
              fromCloud: fromCloud,
              cached: cached[a.uid],
              incoming: a.lastUpdatedAt,
            ))
          a.uid: PublicAlertHive.fromModel(
            fromCloud ? a.copyWith(synced: true) : a,
          ),
    });
  }

  /// Delta cursor for the patient's county set, or null to pull everything.
  Future<String?> patientAlertsCursor(int countyId) async {
    if (countyId <= 0) return null;
    return syncCursorFrom(
      (await _db.getAll<PublicAlertHive>(HiveHelperImpl.publicAlertsBox))
          .where((r) => r.countyId == countyId && r.patientsReleased)
          .map((r) => r.lastUpdatedAt),
    );
  }

  /// Delta cursor for the clinician's county set, or null to pull
  /// everything.
  Future<String?> clinicianAlertsCursor(int countyId) async {
    if (countyId <= 0) return null;
    return syncCursorFrom(
      (await _db.getAll<PublicAlertHive>(HiveHelperImpl.publicAlertsBox))
          .where((r) => r.clinicianCountyIds.contains(countyId))
          .map((r) => r.lastUpdatedAt),
    );
  }

  Future<List<PublicAlertModel>> _cachedPatientAlerts(
    int countyId,
    bool demo,
  ) async {
    final rows = [
      for (final row in await _db.getAll<PublicAlertHive>(
        HiveHelperImpl.publicAlertsBox,
      ))
        if (row.countyId == countyId &&
            row.patientsReleased &&
            (demo || !row.synthetic))
          row.toModel(),
    ];
    return rows..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
  }

  Future<List<PublicAlertModel>> _cachedClinicianAlerts(
    int countyId,
    bool demo,
  ) async {
    final rows = [
      for (final row in await _db.getAll<PublicAlertHive>(
        HiveHelperImpl.publicAlertsBox,
      ))
        if (row.clinicianCountyIds.contains(countyId) &&
            (demo || !row.synthetic))
          row.toModel(),
    ];
    return rows..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
  }

  /// The clinician brief, remote first; the cache answers only when the
  /// cloud cannot be reached.
  Future<AlertClinicianBriefModel?> briefFor({required String alertUid}) async {
    if (alertUid.isEmpty) return null;
    try {
      final remote = await _remote.fetchClinicianBrief(alertUid);
      if (remote != null) {
        await cacheBriefs([remote], fromCloud: true);
        return remote.copyWith(synced: true);
      }
      return await _cachedBrief(alertUid);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await _cachedBrief(alertUid);
      // Nothing cached is "could not read", never "there is none".
      if (cached == null) rethrow;
      return cached;
    }
  }

  /// Caches clinician briefs under the merge guard.
  Future<void> cacheBriefs(
    List<AlertClinicianBriefModel> briefs, {
    required bool fromCloud,
  }) async {
    final cached = {
      for (final row in await _db.getAll<AlertClinicianBriefHive>(
        HiveHelperImpl.alertClinicianBriefsBox,
      ))
        row.alertUid: (synced: row.synced, lastUpdatedAt: row.lastUpdatedAt),
    };
    await _db.putAll<AlertClinicianBriefHive>(
      HiveHelperImpl.alertClinicianBriefsBox,
      {
        for (final b in briefs)
          if (b.alertUid.isNotEmpty &&
              _accepts(
                fromCloud: fromCloud,
                cached: cached[b.alertUid],
                incoming: b.lastUpdatedAt,
              ))
            b.alertUid: AlertClinicianBriefHive.fromModel(
              fromCloud ? b.copyWith(synced: true) : b,
            ),
      },
    );
  }

  Future<AlertClinicianBriefModel?> _cachedBrief(String alertUid) async =>
      (await _db.get<AlertClinicianBriefHive>(
        HiveHelperImpl.alertClinicianBriefsBox,
        alertUid,
      ))?.toModel();

  /// The cached read receipt, or null when the alert is unread.
  Future<AlertReceiptModel?> receiptFor({required String alertUid}) async {
    if (alertUid.isEmpty) return null;
    return (await _db.get<AlertReceiptHive>(
      HiveHelperImpl.alertReceiptsBox,
      alertUid,
    ))?.toModel();
  }

  /// Records the read locally; receipts never leave the device.
  Future<AlertReceiptModel> markRead({required String alertUid}) async {
    if (alertUid.isEmpty) throw ArgumentError('A receipt needs an alert.');
    final now = syncTimestamp();
    final receipt = AlertReceiptModel(
      alertUid: alertUid,
      readAt: now,
      lastUpdatedAt: now,
    );
    if (kDebugMode) _logger.i('Alert $alertUid read (local receipt).');
    await _db.put<AlertReceiptHive>(
      HiveHelperImpl.alertReceiptsBox,
      alertUid,
      AlertReceiptHive.fromModel(receipt),
    );
    return receipt;
  }
}
