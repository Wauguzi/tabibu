import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/cases/data/models/case_log_entry_model.dart';
import 'package:tabibu/features/cases/data/models/case_model.dart';
import 'package:tabibu/features/cases/data/models/case_payment_model.dart';
import 'package:tabibu/features/cases/data/models/notes_translation_model.dart';
import 'package:tabibu/features/cases/data/models/risk_check_model.dart';

/// Firestore reads/updates and case callables. No caching.
@lazySingleton
class CaseFirebase {
  CaseFirebase({required this._firestore, required this._functions});

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final Logger _logger = Logger();

  static const _editableStages = {
    'OrderCreated',
    'PathologistRequested',
    'PathologistRejected',
  };

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

  CollectionReference<Map<String, dynamic>> get _cases =>
      _firestore.collection('cases');

  DocumentReference<Map<String, dynamic>> _case(String caseUid) =>
      _cases.doc(caseUid);

  /// Participant delta: `participantUids` contains + cursor (I-1).
  Future<List<CaseModel>> fetchParticipantDelta({
    required String uid,
    String? cursor,
  }) => _guard('Case participant delta', () async {
    var query = _cases.where('participantUids', arrayContains: uid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        CaseModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  Future<CaseModel?> fetchCase(String caseUid) =>
      _guard('Fetch case', () async {
        // Eviction needs server truth: a cached answer must throw, not delete.
        final snap = await _case(
          caseUid,
        ).get(const GetOptions(source: Source.server));
        if (!snap.exists || snap.data() == null) return null;
        return CaseModel.fromJson({'uid': snap.id, ...snap.data()!});
      });

  /// Patient log: must filter `patientVisible == true` (I-3, rules).
  Future<List<CaseLogEntryModel>> fetchPatientLog(String caseUid) =>
      _guard('Case patient log', () async {
        final snap = await _case(caseUid)
            .collection('log')
            .where('patientVisible', isEqualTo: true)
            .orderBy('seq')
            .get();
        return [
          for (final doc in snap.docs)
            CaseLogEntryModel.fromJson({'uid': doc.id, ...doc.data()}),
        ];
      });

  /// Clinician log: doctor/pathologist may read every row.
  Future<List<CaseLogEntryModel>> fetchClinicianLog(String caseUid) => _guard(
    'Case clinician log',
    () async {
      final snap = await _case(caseUid).collection('log').orderBy('seq').get();
      return [
        for (final doc in snap.docs)
          CaseLogEntryModel.fromJson({'uid': doc.id, ...doc.data()}),
      ];
    },
  );

  Future<CasePaymentModel?> fetchPayment(String caseUid) =>
      _guard('Fetch case payment', () async {
        // Eviction needs server truth: a cached answer must throw, not delete.
        final snap = await _case(caseUid)
            .collection('private')
            .doc('payment')
            .get(const GetOptions(source: Source.server));
        if (!snap.exists || snap.data() == null) return null;
        return CasePaymentModel.fromJson(snap.data()!);
      });

  Future<RiskCheckModel?> fetchRiskCheck(String caseUid) =>
      _guard('Fetch risk check', () async {
        // Eviction needs server truth: a cached answer must throw, not delete.
        final snap = await _case(caseUid)
            .collection('riskCheck')
            .doc('current')
            .get(const GetOptions(source: Source.server));
        if (!snap.exists || snap.data() == null) return null;
        return RiskCheckModel.fromJson(snap.data()!);
      });

  Future<NotesTranslationModel?> fetchNotesTranslation(String caseUid) =>
      _guard('Fetch notes translation', () async {
        // Eviction needs server truth: a cached answer must throw, not delete.
        final snap = await _case(caseUid)
            .collection('notesTranslation')
            .doc('current')
            .get(const GetOptions(source: Source.server));
        if (!snap.exists || snap.data() == null) return null;
        return NotesTranslationModel.fromJson(snap.data()!);
      });

  /// Doctor notes while the stage is still editable. Only the four allowed
  /// fields plus stamp (rules §6).
  Future<void> updateDoctorNotes({
    required String caseUid,
    required String currentStage,
    String? clinicalNotes,
    String? sampleNotes,
    String? sampleCollectedAt,
  }) => _guard('Update doctor notes', () async {
    if (!_editableStages.contains(currentStage)) {
      throw AppError.permissionDenied;
    }
    final data = <String, dynamic>{'lastUpdatedAt': syncTimestamp()};
    if (clinicalNotes != null) data['clinicalNotes'] = clinicalNotes;
    if (sampleNotes != null) data['sampleNotes'] = sampleNotes;
    if (sampleCollectedAt != null) {
      data['sampleCollectedAt'] = sampleCollectedAt;
    }
    if (data.length == 1) return;
    await _case(caseUid).update(data);
  });

  Future<Map<String, dynamic>> createOrder({
    required String caseUid,
    required String appointmentUid,
    required String patientId,
    required List<String> labTestIds,
    required String priority,
    required String sampleCollectedAt,
    required Map<String, dynamic> payment,
    String clinicalNotes = '',
    String sampleNotes = '',
    String? pathologistUid,
  }) => _guard('Create order', () {
    final data = <String, dynamic>{
      'caseUid': caseUid,
      'appointmentUid': appointmentUid,
      'patientId': patientId,
      'labTestIds': labTestIds,
      'priority': priority,
      'sampleCollectedAt': sampleCollectedAt,
      'payment': payment,
      'clinicalNotes': clinicalNotes,
      'sampleNotes': sampleNotes,
      'pathologistUid': ?pathologistUid,
    };
    return _call('createOrder', data);
  });

  Future<Map<String, dynamic>> requestPathologist({
    required String caseUid,
    required String pathologistUid,
  }) => _guard(
    'Request pathologist',
    () => _call('requestPathologist', {
      'caseUid': caseUid,
      'pathologistUid': pathologistUid,
    }),
  );

  Future<Map<String, dynamic>> acceptCase({required String caseUid}) =>
      _guard('Accept case', () => _call('acceptCase', {'caseUid': caseUid}));

  Future<Map<String, dynamic>> rejectCase({
    required String caseUid,
    required String reason,
  }) => _guard(
    'Reject case',
    () => _call('rejectCase', {'caseUid': caseUid, 'reason': reason}),
  );

  Future<Map<String, dynamic>> reassignPathologist({
    required String caseUid,
    required String pathologistUid,
  }) => _guard(
    'Reassign pathologist',
    () => _call('reassignPathologist', {
      'caseUid': caseUid,
      'pathologistUid': pathologistUid,
    }),
  );

  Future<Map<String, dynamic>> recordSampleReceived({
    required String caseUid,
    required String labAccessionNo,
  }) => _guard(
    'Record sample received',
    () => _call('recordSampleReceived', {
      'caseUid': caseUid,
      'labAccessionNo': labAccessionNo,
    }),
  );

  Future<Map<String, dynamic>> reserveSlideUploads({
    required String caseUid,
    required int count,
  }) => _guard(
    'Reserve slide uploads',
    () => _call('reserveSlideUploads', {'caseUid': caseUid, 'count': count}),
  );

  Future<Map<String, dynamic>> registerSlides({
    required String caseUid,
    required List<Map<String, dynamic>> images,
  }) => _guard(
    'Register slides',
    () => _call('registerSlides', {'caseUid': caseUid, 'images': images}),
  );

  Future<Map<String, dynamic>> cancelOrder({
    required String caseUid,
    required String reasonCode,
  }) => _guard(
    'Cancel order',
    () => _call('cancelOrder', {'caseUid': caseUid, 'reasonCode': reasonCode}),
  );

  Future<Map<String, dynamic>> completeCase({required String caseUid}) =>
      _guard(
        'Complete case',
        () => _call('completeCase', {'caseUid': caseUid}),
      );

  Future<Map<String, dynamic>> removeCaseViewer({
    required String caseUid,
    required String viewerUid,
  }) => _guard(
    'Remove case viewer',
    () =>
        _call('removeCaseViewer', {'caseUid': caseUid, 'viewerUid': viewerUid}),
  );
}
