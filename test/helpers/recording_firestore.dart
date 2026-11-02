import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Firestore fake that records every `get`'s [GetOptions] and answers
/// empty. Eviction-driving reads must all demand [Source.server], so an
/// offline cache answer throws instead of deleting a Hive row.
class RecordingFirestore extends Fake implements FirebaseFirestore {
  final List<GetOptions?> log = [];

  /// Every recorded read demanded the server, in exactly [count] reads.
  void expectServerReads(int count) {
    expect(log, hasLength(count));
    for (final options in log) {
      expect(options?.source, Source.server);
    }
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _RecordingCollection(log);

  @override
  Query<Map<String, dynamic>> collectionGroup(String collectionId) =>
      _RecordingQuery(log);
}

// A Fake can only stand in for the sealed Firestore types via implements;
// every member below is hand-written, which is all the test needs.
// ignore: subtype_of_sealed_class
class _RecordingCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _RecordingCollection(this._log);

  final List<GetOptions?> _log;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _RecordingDoc(_log);

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) => _RecordingQuery(_log);
}

// A Fake can only stand in for the sealed Firestore types via implements;
// every member below is hand-written, which is all the test needs.
// ignore: subtype_of_sealed_class
class _RecordingQuery extends Fake implements Query<Map<String, dynamic>> {
  _RecordingQuery(this._log);

  final List<GetOptions?> _log;

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) => _RecordingQuery(_log);

  @override
  Query<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) => _RecordingQuery(_log);

  @override
  Query<Map<String, dynamic>> limit(int limit) => _RecordingQuery(_log);

  @override
  Query<Map<String, dynamic>> startAt(Iterable<Object?> values) =>
      _RecordingQuery(_log);

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    _log.add(options);
    return _RecordingQuerySnap();
  }
}

// A Fake can only stand in for the sealed Firestore types via implements;
// every member below is hand-written, which is all the test needs.
// ignore: subtype_of_sealed_class
class _RecordingDoc extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _RecordingDoc(this._log);

  final List<GetOptions?> _log;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _RecordingCollection(_log);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    _log.add(options);
    return _RecordingDocSnap();
  }
}

class _RecordingQuerySnap extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => [];
}

// A Fake can only stand in for the sealed Firestore types via implements;
// every member below is hand-written, which is all the test needs.
// ignore: subtype_of_sealed_class
class _RecordingDocSnap extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  bool get exists => false;

  @override
  Map<String, dynamic>? data() => null;
}
