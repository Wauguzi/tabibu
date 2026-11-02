import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

/// Pathologist worklist reads: the desk delta and single entries (I-14).
@lazySingleton
class WorklistFirebase {
  WorklistFirebase({required this._firestore});

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

  CollectionReference<Map<String, dynamic>> get _worklist =>
      _firestore.collection('worklist');

  /// Desk delta: `pathologistUid ==` + cursor (I-14).
  Future<List<WorklistEntryModel>> fetchPathologistDelta({
    required String pathologistUid,
    String? cursor,
  }) => _guard('Worklist pathologist delta', () async {
    var query = _worklist.where('pathologistUid', isEqualTo: pathologistUid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        WorklistEntryModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  Future<WorklistEntryModel?> fetchEntry(String caseUid) =>
      _guard('Fetch worklist entry', () async {
        final snap = await _worklist.doc(caseUid).get();
        if (!snap.exists || snap.data() == null) return null;
        return WorklistEntryModel.fromJson({'uid': snap.id, ...snap.data()!});
      });
}
