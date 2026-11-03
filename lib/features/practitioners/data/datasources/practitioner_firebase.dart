import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

/// Firestore reads for the public practitioner directory. No caching.
@lazySingleton
class PractitionerFirebase {
  PractitionerFirebase({required this._firestore});

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
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e('$operation failed: $e', stackTrace: stackTrace);
      }
      throw _toAppError(e);
    }
  }

  CollectionReference<Map<String, dynamic>> get _practitioners =>
      _firestore.collection('practitioners');

  /// Directory delta: inclusive `lastUpdatedAt >=` cursor
  /// (`practitioners.delta`). An empty cursor lower-bounds at `''`, which
  /// every real stamp is past.
  Future<List<PractitionerModel>> fetchDelta({String? cursor}) =>
      _guard('Practitioner directory delta', () async {
        final bound = (cursor != null && cursor.isNotEmpty) ? cursor : '';
        final query = _practitioners
            .where('lastUpdatedAt', isGreaterThanOrEqualTo: bound)
            .orderBy('lastUpdatedAt');
        // Server truth: a cached answer must throw, not drive local decisions.
        final snap = await query.get(const GetOptions(source: Source.server));
        return [
          for (final doc in snap.docs)
            PractitionerModel.fromJson({'uid': doc.id, ...doc.data()}),
        ];
      });

  /// One directory row by id, or null when missing.
  Future<PractitionerModel?> fetchPractitioner(String uid) =>
      _guard('Fetch practitioner', () async {
        if (uid.isEmpty) return null;
        final snap = await _practitioners
            .doc(uid)
            .get(const GetOptions(source: Source.server));
        if (!snap.exists || snap.data() == null) return null;
        return PractitionerModel.fromJson({'uid': snap.id, ...snap.data()!});
      });
}
