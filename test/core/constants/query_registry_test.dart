import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/constants/query_registry.dart';

Map<String, dynamic> loadIndexes() {
  final file = File('firestore.indexes.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

bool needsCompositeIndex(QuerySpec spec) {
  if (spec.scope == 'collectionGroup') return true;
  if (spec.filters.length >= 2) return true;
  if (spec.filters.isNotEmpty && spec.orderBy.isNotEmpty) {
    final filterFields = {for (final f in spec.filters) f.split(' ').first};
    return spec.orderBy.any((o) => !filterFields.contains(o.split(' ').first));
  }
  return false;
}

/// Single-field on one collection: at most one equality, array-contains or
/// range filter, and either no orderBy or orderBy on that same field — no
/// composite needed (Firestore's automatic single-field indexes cover it).
bool isSingleField(QuerySpec spec) {
  if (spec.scope != 'collection' && spec.scope != 'nested') return false;
  if (spec.filters.length > 1) return false;
  if (spec.filters.isEmpty) {
    return spec.orderBy.length <= 1;
  }
  final filterField = spec.filters.single.split(' ').first;
  final op = spec.filters.single.split(' ').skip(1).join(' ');
  const allowed = {'==', 'array-contains', '>=', '>', '<=', '<'};
  if (!allowed.contains(op)) return false;
  return spec.orderBy.every((o) => o.split(' ').first == filterField);
}

bool matchesIndex(QuerySpec spec, Map<String, dynamic> index) {
  final expectedScope = spec.scope == 'collectionGroup'
      ? 'COLLECTION_GROUP'
      : 'COLLECTION';
  if (index['collectionGroup'] != spec.collection) return false;
  if (index['queryScope'] != expectedScope) return false;

  final fields = (index['fields'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  final wanted = <({String field, String? op, String? direction})>[
    for (final f in spec.filters)
      (
        field: f.split(' ').first,
        op: f.split(' ').skip(1).join(' '),
        direction: null,
      ),
    for (final o in spec.orderBy)
      if (!spec.filters.any((f) => f.split(' ').first == o.split(' ').first))
        (
          field: o.split(' ').first,
          op: null,
          direction: o.split(' ').skip(1).join(' '),
        ),
  ];
  // Inequality filters still need their field as the first orderBy in the
  // index when orderBy repeats that field — include filter fields only once.
  if (wanted.isEmpty) return false;
  if (fields.length < wanted.length) return false;

  for (var i = 0; i < wanted.length; i++) {
    final w = wanted[i];
    final f = fields[i];
    if (f['fieldPath'] != w.field) return false;
    if (w.op == 'array-contains') {
      if (f['arrayConfig'] != 'CONTAINS') return false;
    } else if (w.direction != null && w.direction!.isNotEmpty) {
      final order = w.direction == 'DESC' ? 'DESCENDING' : 'ASCENDING';
      if (f['order'] != order) return false;
    } else if (f['order'] == null && f['arrayConfig'] == null) {
      return false;
    }
  }
  return true;
}

void main() {
  final indexes = loadIndexes();
  final composite = (indexes['indexes'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('query registry ids are unique', () {
    final ids = queryRegistry.map((q) => q.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('each QuerySpec has a matching composite index or is equality-only', () {
    for (final spec in queryRegistry) {
      if (isSingleField(spec) && !needsCompositeIndex(spec)) {
        continue;
      }
      // App deltas use ==/array-contains plus orderBy on the inequality field.
      // Those still need the composite indexes in §5.1.
      final match = composite.any((idx) => matchesIndex(spec, idx));
      expect(
        match,
        isTrue,
        reason:
            'No composite index for ${spec.id} '
            '(${spec.collection}, ${spec.filters}, ${spec.orderBy})',
      );
    }
  });
}
