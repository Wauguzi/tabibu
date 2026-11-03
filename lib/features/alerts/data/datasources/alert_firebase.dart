import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/alert_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

/// Approver callables and public-alert reads. No caching.
@lazySingleton
class AlertFirebase {
  AlertFirebase({required this._firestore, required this._functions});

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final Logger _logger = Logger();

  static const _server = GetOptions(source: Source.server);

  AppError _toAppError(Object e) => switch (e) {
    AppError() => e,
    FirebaseFunctionsException() => AppError.fromFunctionsException(e),
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

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> data,
  ) async {
    final result = await _functions.httpsCallable(name).call<dynamic>(data);
    final raw = result.data;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  CollectionReference<Map<String, dynamic>> get _publicAlerts =>
      _firestore.collection('publicAlerts');

  CollectionReference<Map<String, dynamic>> get _alerts =>
      _firestore.collection('alerts');

  /// Approver queue: drafts awaiting a decision, oldest draft first (F-39).
  Future<List<AlertModel>> fetchAwaitingDecision() =>
      _guard('Awaiting decision', () async {
        final snap = await _alerts
            .where('status', isEqualTo: AlertStatus.draft.value)
            .orderBy('draftedAt')
            .get(_server);
        return [
          for (final doc in snap.docs)
            AlertModel.fromJson({'uid': doc.id, ...doc.data()}),
        ];
      });

  /// One working alert by id, server source.
  Future<AlertModel?> fetchAlert(String alertUid) =>
      _guard('Fetch alert', () async {
        if (alertUid.isEmpty) return null;
        final snap = await _alerts.doc(alertUid).get(_server);
        if (!snap.exists || snap.data() == null) return null;
        return AlertModel.fromJson({'uid': snap.id, ...snap.data()!});
      });

  Future<Map<String, dynamic>> approveAlert({
    required String alertUid,
    required String decision,
    required int draftRevision,
    required int evidenceRevision,
    String audience = 'CliniciansThenPatients',
    Map<String, dynamic>? editedText,
    String? reason,
  }) => _guard('Approve alert', () {
    final data = <String, dynamic>{
      'alertUid': alertUid,
      'decision': decision,
      'draftRevision': draftRevision,
      'evidenceRevision': evidenceRevision,
      'audience': audience,
      'editedText': ?editedText,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };
    return _call('approveAlert', data);
  });

  Future<Map<String, dynamic>> requestAlertDraft({required String alertUid}) =>
      _guard(
        'Request alert draft',
        () => _call('requestAlertDraft', {'alertUid': alertUid}),
      );

  /// Patient delta: county + released + non-synthetic + cursor (I-34).
  /// The `synthetic == false` filter proves the read rule: without it one
  /// synthetic row denies the whole list. Demo accounts read synthetics
  /// through a separate query once the demo claim is wired (matrix §demo).
  Future<List<PublicAlertModel>> fetchPatientPublicAlerts({
    required int countyId,
    String? cursor,
  }) => _guard('Patient public alerts', () async {
    var query = _publicAlerts
        .where('countyId', isEqualTo: countyId)
        .where('patientsReleased', isEqualTo: true)
        .where('synthetic', isEqualTo: false);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    final snap = await query.get();
    return [
      for (final doc in snap.docs)
        PublicAlertModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// Clinician delta: `clinicianCountyIds` contains + non-synthetic +
  /// cursor (I-35). The `synthetic == false` filter proves the read rule:
  /// without it one synthetic row denies the whole list.
  Future<List<PublicAlertModel>> fetchClinicianPublicAlerts({
    required int countyId,
    String? cursor,
  }) => _guard('Clinician public alerts', () async {
    var query = _publicAlerts
        .where('clinicianCountyIds', arrayContains: countyId)
        .where('synthetic', isEqualTo: false);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    final snap = await query.get();
    return [
      for (final doc in snap.docs)
        PublicAlertModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  Future<PublicAlertModel?> fetchPublicAlert(String alertUid) =>
      _guard('Fetch public alert', () async {
        final snap = await _publicAlerts.doc(alertUid).get();
        if (!snap.exists || snap.data() == null) return null;
        return PublicAlertModel.fromJson({'uid': snap.id, ...snap.data()!});
      });

  Future<AlertClinicianBriefModel?> fetchClinicianBrief(String alertUid) =>
      _guard('Fetch clinician brief', () async {
        final snap = await _publicAlerts
            .doc(alertUid)
            .collection('doctor')
            .doc('brief')
            .get();
        if (!snap.exists || snap.data() == null) return null;
        return AlertClinicianBriefModel.fromJson(snap.data()!);
      });
}
