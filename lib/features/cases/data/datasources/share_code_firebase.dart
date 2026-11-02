import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';

/// Share-code reads and callables. The raw code is never logged (T-18).
@lazySingleton
class ShareCodeFirebase {
  ShareCodeFirebase({required this._firestore, required this._functions});

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
      // Never interpolate a share code into this log line.
      if (kDebugMode) _logger.e('$operation failed: ${_toAppError(e)}');
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

  CollectionReference<Map<String, dynamic>> get _shareCodes =>
      _firestore.collection('shareCodes');

  /// Creator delta: `createdByUid ==` + cursor (I-6).
  Future<List<ShareCodeModel>> fetchCreatorDelta({
    required String createdByUid,
    String? cursor,
  }) => _guard('Share codes creator delta', () async {
    var query = _shareCodes.where('createdByUid', isEqualTo: createdByUid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        ShareCodeModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  /// Recipient delta: `recipientUid ==` + cursor (I-5).
  Future<List<ShareCodeModel>> fetchRecipientDelta({
    required String recipientUid,
    String? cursor,
  }) => _guard('Share codes recipient delta', () async {
    var query = _shareCodes.where('recipientUid', isEqualTo: recipientUid);
    if (cursor != null && cursor.isNotEmpty) {
      query = query.where('lastUpdatedAt', isGreaterThanOrEqualTo: cursor);
    }
    query = query.orderBy('lastUpdatedAt');
    // Eviction needs server truth: a cached answer must throw, not delete.
    final snap = await query.get(const GetOptions(source: Source.server));
    return [
      for (final doc in snap.docs)
        ShareCodeModel.fromJson({'uid': doc.id, ...doc.data()}),
    ];
  });

  Future<ShareCodeModel?> fetchShareCode(String shareUid) =>
      _guard('Fetch share code', () async {
        // Eviction needs server truth: a cached answer must throw, not delete.
        final snap = await _shareCodes
            .doc(shareUid)
            .get(const GetOptions(source: Source.server));
        if (!snap.exists || snap.data() == null) return null;
        return ShareCodeModel.fromJson({'uid': snap.id, ...snap.data()!});
      });

  Future<Map<String, dynamic>> createShareCode({
    required String shareUid,
    required String caseUid,
    required String recipientUid,
  }) => _guard(
    'Create share code',
    () => _call('createShareCode', {
      'shareUid': shareUid,
      'caseUid': caseUid,
      'recipientUid': recipientUid,
    }),
  );

  /// Redeems [code]. The value is sent to the callable only — never logged.
  Future<Map<String, dynamic>> redeemShareCode({
    required String shareUid,
    required String code,
  }) => _guard(
    'Redeem share code',
    () => _call('redeemShareCode', {'shareUid': shareUid, 'code': code}),
  );

  Future<Map<String, dynamic>> reissueShareCode({required String shareUid}) =>
      _guard(
        'Reissue share code',
        () => _call('reissueShareCode', {'shareUid': shareUid}),
      );

  Future<Map<String, dynamic>> revokeShareCode({required String shareUid}) =>
      _guard(
        'Revoke share code',
        () => _call('revokeShareCode', {'shareUid': shareUid}),
      );
}
