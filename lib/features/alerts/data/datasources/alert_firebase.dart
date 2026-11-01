import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/models/alert_clinician_brief_model.dart';
import 'package:tabibu/features/alerts/data/models/public_alert_model.dart';

/// Approver callables and public-alert reads. No caching.
@lazySingleton
class AlertFirebase {
  AlertFirebase({required this._firestore, required this._functions});

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final Logger _logger = Logger();

  AppError _toAppError(Object e) => switch (e) {
    AppError() => e,
    FirebaseFunctionsException() => AppError.fromFunctionsException(e),
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

  /// Patient delta: county + released + cursor (I-34).
  Future<List<PublicAlertModel>> fetchPatientPublicAlerts({
    required int countyId,
    String? cursor,
  }) => _guard('Patient public alerts', () async {
    var query = _publicAlerts
        .where('countyId', isEqualTo: countyId)
        .where('patientsReleased', isEqualTo: true);
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

  /// Clinician delta: `clinicianCountyIds` contains + cursor (I-35).
  Future<List<PublicAlertModel>> fetchClinicianPublicAlerts({
    required int countyId,
    String? cursor,
  }) => _guard('Clinician public alerts', () async {
    var query = _publicAlerts.where(
      'clinicianCountyIds',
      arrayContains: countyId,
    );
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
