import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/practitioners/data/datasources/practitioner_firebase.dart';

import '../../../../helpers/helpers.dart';

Map<String, dynamic> _row(String firstName, String lastUpdatedAt) => {
  'title': 'Dr.',
  'firstName': firstName,
  'lastName': 'Mwangi',
  'profilePictureUrl': '',
  'isPathologist': false,
  'specialties': <String>[],
  'bio': '',
  'facilityId': 'f1',
  'facilityMflCode': '1',
  'facilityName': 'Clinic',
  'county': 'Nairobi',
  'subCounty': 'Kibra',
  'geohash': 'kzf0eg70h',
  'isAvailable': true,
  'appointmentsHandled': 0,
  'ordersCreated': 0,
  'reportsSigned': 0,
  'lastUpdatedAt': lastUpdatedAt,
};

void main() {
  late FakeFirebaseFirestore firestore;
  late PractitionerFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    remote = PractitionerFirebase(firestore: firestore);
  });

  group('fetchDelta', () {
    test('returns only rows at or after the cursor', () async {
      await firestore
          .collection('practitioners')
          .doc('d1')
          .set(_row('A', '2026-11-01T10:00:00.000Z'));
      await firestore
          .collection('practitioners')
          .doc('d2')
          .set(_row('B', '2026-11-01T12:00:00.000Z'));
      await firestore
          .collection('practitioners')
          .doc('d3')
          .set(_row('C', '2026-11-01T11:00:00.000Z'));

      final rows = await remote.fetchDelta(cursor: '2026-11-01T11:00:00.000Z');
      expect(rows.map((r) => r.uid), ['d3', 'd2']);
    });

    test('maps uid from the document id', () async {
      await firestore
          .collection('practitioners')
          .doc('doctor-1')
          .set(_row('Brian', '2026-11-01T10:00:00.000Z'));

      final rows = await remote.fetchDelta();
      expect(rows, hasLength(1));
      expect(rows.single.uid, 'doctor-1');
      expect(rows.single.firstName, 'Brian');
    });
  });

  group('fetchPractitioner', () {
    test('returns the row when present', () async {
      await firestore
          .collection('practitioners')
          .doc('d1')
          .set(_row('Brian', '2026-11-01T10:00:00.000Z'));

      final row = await remote.fetchPractitioner('d1');
      expect(row?.uid, 'd1');
      expect(row?.firstName, 'Brian');
    });

    test('returns null when missing', () async {
      expect(await remote.fetchPractitioner('gone'), isNull);
      expect(await remote.fetchPractitioner(''), isNull);
    });
  });

  group('server reads', () {
    test(
      'delta and single-row reads reach the server, never the cache',
      () async {
        final recording = RecordingFirestore();
        final server = PractitionerFirebase(firestore: recording);

        await server.fetchDelta();
        await server.fetchPractitioner('d1');

        recording.expectServerReads(2);
      },
    );
  });
}
