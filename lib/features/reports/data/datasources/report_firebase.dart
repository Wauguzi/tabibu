import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/features/preread/data/models/preread_model.dart';
import 'package:tabibu/features/reports/data/models/pathology_report_model.dart';
import 'package:tabibu/features/reports/data/models/preread_score_model.dart';
import 'package:tabibu/features/reports/data/models/report_draft_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_approved_model.dart';
import 'package:tabibu/features/reports/data/models/report_text_model.dart';

/// Signed reports, drafts, pre-reads and report callables. No caching.
@lazySingleton
class ReportFirebase {
  ReportFirebase({required this._firestore, required this._functions});

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final Logger _logger = Logger();

  /// Client-writable draft fields (Initial/Amendment union + Addendum).
  static const draftEditableFields = {
    'title',
    'diagnosisType',
    'diagnosis',
    'comments',
    'responses',
    'labelOverrides',
    'labelOverrideCount',
    'isCritical',
    'diagnosisStartedAt',
    'startedFromPreread',
    'language',
    'amendmentReason',
    'addendumText',
    'notifiableFindings',
    'confirmatoryRequests',
    'hintShownDiseaseIds',
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

  DocumentReference<Map<String, dynamic>> _case(String caseUid) =>
      _firestore.collection('cases').doc(caseUid);

  CollectionReference<Map<String, dynamic>> _reports(String caseUid) =>
      _case(caseUid).collection('reports');

  DocumentReference<Map<String, dynamic>> _draft(
    String caseUid,
    String pathologistUid,
  ) => _case(caseUid).collection('reportDrafts').doc(pathologistUid);

  /// Clinician/pathologist delta: collection group, `readerUids` contains (I-8).
  Future<List<PathologyReportModel>> fetchReaderDelta({
    required String uid,
    String? cursor,
  }) => _guard('Report reader delta', () async {
    var query = _firestore
        .collectionGroup('reports')
        .where('readerUids', arrayContains: uid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        PathologyReportModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// Patient delta: must also filter `releasedToPatient == true` (I-9, S-3).
  Future<List<PathologyReportModel>> fetchPatientDelta({
    required String uid,
    String? cursor,
  }) => _guard('Report patient delta', () async {
    var query = _firestore
        .collectionGroup('reports')
        .where('readerUids', arrayContains: uid)
        .where('releasedToPatient', isEqualTo: true);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        PathologyReportModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  Future<PathologyReportModel?> fetchReport({
    required String caseUid,
    required String reportUid,
  }) => _guard('Fetch report', () async {
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await _reports(
      caseUid,
    ).doc(reportUid).get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) return null;
    return PathologyReportModel.fromJson({'uid': snap.id, ...snap.data()!});
  });

  /// PDF path: always from the server so a stale cache is never rendered.
  Future<PathologyReportModel?> fetchReportForPdf({
    required String caseUid,
    required String reportUid,
  }) => _guard('Fetch report for PDF', () async {
    final snap = await _reports(
      caseUid,
    ).doc(reportUid).get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) return null;
    return PathologyReportModel.fromJson({'uid': snap.id, ...snap.data()!});
  });

  Future<ReportDraftModel?> fetchDraft({
    required String caseUid,
    required String pathologistUid,
  }) => _guard('Fetch report draft', () async {
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await _draft(
      caseUid,
      pathologistUid,
    ).get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) return null;
    return ReportDraftModel.fromJson({'uid': snap.id, ...snap.data()!});
  });

  /// Targeted draft update: only [draftEditableFields] plus stamp.
  Future<void> updateDraft({
    required String caseUid,
    required String pathologistUid,
    required Map<String, dynamic> fields,
  }) {
    // A caller asking to change a field the rules forbid has a bug; failing
    // here keeps it from believing the change was saved.
    final refused = fields.keys.where((k) => !draftEditableFields.contains(k));
    if (refused.isNotEmpty) {
      throw ArgumentError.value(refused.toList(), 'fields', 'not editable');
    }
    return _guard('Update report draft', () async {
      final data = <String, dynamic>{
        ...fields,
        'lastUpdatedAt': syncTimestamp(),
      };
      if (data.containsKey('labelOverrides') &&
          !data.containsKey('labelOverrideCount')) {
        final overrides = data['labelOverrides'];
        if (overrides is Map) {
          data['labelOverrideCount'] = overrides.length;
        }
      }
      if (data.length == 1) return;
      await _draft(caseUid, pathologistUid).update(data);
    });
  }

  Future<PrereadModel?> fetchPreread({
    required String caseUid,
    required String runUid,
  }) => _guard('Fetch preread', () async {
    final snap = await _case(caseUid).collection('preread').doc(runUid).get();
    if (!snap.exists || snap.data() == null) return null;
    return PrereadModel.fromJson({'uid': snap.id, ...snap.data()!});
  });

  Future<PrereadScoreModel?> fetchPrereadScore({
    required String caseUid,
    required String runUid,
  }) => _guard('Fetch preread score', () async {
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await _case(caseUid)
        .collection('prereadScores')
        .doc(runUid)
        .get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) return null;
    return PrereadScoreModel.fromJson({'uid': snap.id, ...snap.data()!});
  });

  /// Approved text by deterministic id only (list is denied by rules).
  Future<ReportTextApprovedModel?> fetchApprovedText({
    required String caseUid,
    required String textUid,
  }) => _guard('Fetch approved report text', () async {
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await _case(caseUid)
        .collection('reportTextsApproved')
        .doc(textUid)
        .get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) return null;
    return ReportTextApprovedModel.fromJson({'uid': snap.id, ...snap.data()!});
  });

  /// Working (unapproved) report text by id. Never cached — AI text an
  /// approver has not signed off must not land in Hive.
  Future<ReportTextModel?> fetchReportText({
    required String caseUid,
    required String textUid,
  }) => _guard('Fetch report text', () async {
    final snap = await _case(caseUid)
        .collection('reportTexts')
        .doc(textUid)
        .get(const GetOptions(source: Source.server));
    if (!snap.exists || snap.data() == null) return null;
    return ReportTextModel.fromJson({'uid': snap.id, ...snap.data()!});
  });

  Future<Map<String, dynamic>> startReport({
    required String caseUid,
    required String kind,
  }) => _guard(
    'Start report',
    () => _call('startReport', {'caseUid': caseUid, 'kind': kind}),
  );

  Future<Map<String, dynamic>> discardDraft({
    required String caseUid,
    required String draftLastUpdatedAt,
  }) => _guard(
    'Discard draft',
    () => _call('discardDraft', {
      'caseUid': caseUid,
      'draftLastUpdatedAt': draftLastUpdatedAt,
    }),
  );

  Future<Map<String, dynamic>> scorePreread({
    required String caseUid,
    required String runUid,
    required int overall,
    required String findingsVerdict,
    required String impressionVerdict,
    required String measurementsVerdict,
    required String segmentationVerdict,
    required String urgencyVerdict,
    required String prereadShownAt,
    String comment = '',
  }) => _guard(
    'Score preread',
    () => _call('scorePreread', {
      'caseUid': caseUid,
      'runUid': runUid,
      'overall': overall,
      'findingsVerdict': findingsVerdict,
      'impressionVerdict': impressionVerdict,
      'measurementsVerdict': measurementsVerdict,
      'segmentationVerdict': segmentationVerdict,
      'urgencyVerdict': urgencyVerdict,
      'comment': comment,
      'prereadShownAt': prereadShownAt,
    }),
  );

  Future<Map<String, dynamic>> signReport({
    required String caseUid,
    required String signaturePng,
    required String draftLastUpdatedAt,
  }) => _guard(
    'Sign report',
    () => _call('signReport', {
      'caseUid': caseUid,
      'signaturePng': signaturePng,
      'draftLastUpdatedAt': draftLastUpdatedAt,
    }),
  );

  Future<Map<String, dynamic>> markDiscussed({
    required String caseUid,
    required String reportUid,
  }) => _guard(
    'Mark discussed',
    () => _call('markDiscussed', {'caseUid': caseUid, 'reportUid': reportUid}),
  );

  Future<Map<String, dynamic>> approveReportText({
    required String caseUid,
    required String textUid,
    required String decision,
    Map<String, String>? approvedText,
  }) => _guard('Approve report text', () {
    final data = <String, dynamic>{
      'caseUid': caseUid,
      'textUid': textUid,
      'decision': decision,
      'approvedText': ?approvedText,
    };
    return _call('approveReportText', data);
  });

  Future<Map<String, dynamic>> requestReportText({
    required String caseUid,
    required String reportUid,
    required String kind,
  }) => _guard(
    'Request report text',
    () => _call('requestReportText', {
      'caseUid': caseUid,
      'reportUid': reportUid,
      'kind': kind,
    }),
  );
}
