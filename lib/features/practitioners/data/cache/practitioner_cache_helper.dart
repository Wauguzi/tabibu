import 'package:injectable/injectable.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/practitioners/data/datasources/practitioner_firebase.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

/// Cached practitioner directory: the layer the blocs call.
///
/// Rows the delta omits stay cached — the public directory never shrinks per
/// viewer, so nothing is evicted here.
@lazySingleton
class PractitionerCacheHelper {
  PractitionerCacheHelper({required this._hive, required this._remote});

  final HiveHelper _hive;
  final PractitionerFirebase _remote;

  /// Failures that mean "the cloud cannot be reached", for which the cache
  /// stands in.
  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  /// Remote first; the cache answers only when the cloud cannot be reached.
  Future<List<PractitionerModel>> syncPractitioners() async {
    try {
      final remote = await _remote.fetchDelta(
        cursor: await _hive.practitionersCursor(),
      );
      await _hive.cachePractitioners(remote, fromCloud: true);
    } on AppError catch (e) {
      if (!_offline.contains(e)) rethrow;
      final cached = await _hive.getCachedPractitioners();
      // Nothing cached is "could not read", never "there is none".
      if (cached.isEmpty) rethrow;
      return cached;
    }
    return await _hive.getCachedPractitioners();
  }

  /// The cached directory.
  Future<List<PractitionerModel>> getPractitioners() =>
      _hive.getCachedPractitioners();

  /// Cache first; on a miss, fetch one row, cache it and return.
  Future<PractitionerModel?> getPractitioner(String uid) async {
    if (uid.isEmpty) return null;
    for (final row in await _hive.getCachedPractitioners()) {
      if (row.uid == uid) return row;
    }
    final remote = await _remote.fetchPractitioner(uid);
    if (remote == null) return null;
    await _hive.cachePractitioners([remote], fromCloud: true);
    return remote;
  }
}
