import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/worklist/data/datasources/worklist_firebase.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late WorklistFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    remote = WorklistFirebase(firestore: firestore);
  });

  group('fetchPathologistDelta', () {
    test('returns only the pathologist rows at or after the cursor', () async {
      await firestore.collection('worklist').doc('c1').set({
        'pathologistUid': 'path1',
        'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
      });
      await firestore.collection('worklist').doc('c2').set({
        'pathologistUid': 'path1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('worklist').doc('other').set({
        'pathologistUid': 'path2',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchPathologistDelta(
        pathologistUid: 'path1',
        cursor: '2026-11-01T11:00:00.000Z',
      );
      expect(rows.map((r) => r.uid), ['c2']);
    });

    test('without a cursor returns every row in stamp order', () async {
      await firestore.collection('worklist').doc('c2').set({
        'pathologistUid': 'path1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('worklist').doc('c1').set({
        'pathologistUid': 'path1',
        'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
      });

      final rows = await remote.fetchPathologistDelta(pathologistUid: 'path1');
      expect(rows.map((r) => r.uid), ['c1', 'c2']);
    });
  });

  group('fetchEntry', () {
    test('returns the row by case id, null when missing', () async {
      await firestore.collection('worklist').doc('c1').set({
        'pathologistUid': 'path1',
        'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
      });

      final hit = await remote.fetchEntry('c1');
      expect(hit?.uid, 'c1');
      expect(await remote.fetchEntry('nope'), isNull);
    });
  });

  group('server reads', () {
    test('eviction reads reach the server, never the cache', () async {
      final recording = RecordingFirestore();
      final server = WorklistFirebase(firestore: recording);

      await server.fetchPathologistDelta(pathologistUid: 'path1');

      recording.expectServerReads(1);
    });
  });
}
