import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/alerts/data/datasources/alert_firebase.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

class _Refusal extends FirebaseFunctionsException {
  _Refusal(String reason, String code) : super(message: reason, code: code);
}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockFunctions functions;
  late _MockCallable callable;
  late AlertFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = _MockFunctions();
    callable = _MockCallable();
    remote = AlertFirebase(firestore: firestore, functions: functions);
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('callables', () {
    test('approveAlert sends the documented map', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'ok'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.approveAlert(
        alertUid: 'a1',
        decision: 'Approve',
        draftRevision: 2,
        evidenceRevision: 3,
        audience: 'CliniciansOnly',
      );

      verify(() => functions.httpsCallable('approveAlert')).called(1);
      final sent =
          verify(
                () => callable.call<dynamic>(captureAny<dynamic>()),
              ).captured.single
              as Map<String, dynamic>;
      expect(sent['alertUid'], 'a1');
      expect(sent['decision'], 'Approve');
      expect(sent['draftRevision'], 2);
      expect(sent['evidenceRevision'], 3);
      expect(sent['audience'], 'CliniciansOnly');
    });

    test('requestAlertDraft maps a functions refusal', () async {
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenThrow(_Refusal('notApprover', 'permission-denied'));
      await expectLater(
        remote.requestAlertDraft(alertUid: 'a1'),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  group('reads', () {
    test('patient public alerts require release and county', () async {
      await firestore.collection('publicAlerts').doc('a1').set({
        'countyId': 47,
        'patientsReleased': true,
        'synthetic': false,
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        'diseaseId': 'cholera',
      });
      await firestore.collection('publicAlerts').doc('a2').set({
        'countyId': 47,
        'patientsReleased': false,
        'synthetic': false,
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        'diseaseId': 'cholera',
      });
      await firestore.collection('publicAlerts').doc('a3').set({
        'countyId': 1,
        'patientsReleased': true,
        'synthetic': false,
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        'diseaseId': 'cholera',
      });
      // Synthetic, released, same county: excluded, so the read rule holds
      // for every row the query can return.
      await firestore.collection('publicAlerts').doc('a4').set({
        'countyId': 47,
        'patientsReleased': true,
        'synthetic': true,
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        'diseaseId': 'cholera',
      });

      final rows = await remote.fetchPatientPublicAlerts(countyId: 47);
      expect(rows.map((r) => r.uid), ['a1']);
    });

    test('clinician public alerts use clinicianCountyIds', () async {
      await firestore.collection('publicAlerts').doc('a1').set({
        'clinicianCountyIds': [47, 48],
        'synthetic': false,
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('publicAlerts').doc('a2').set({
        'clinicianCountyIds': [1],
        'synthetic': false,
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('publicAlerts').doc('a3').set({
        'clinicianCountyIds': [47],
        'synthetic': true,
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchClinicianPublicAlerts(countyId: 47);
      expect(rows.map((r) => r.uid), ['a1']);
    });

    test('clinician brief is read under doctor/brief', () async {
      await firestore
          .collection('publicAlerts')
          .doc('a1')
          .collection('doctor')
          .doc('brief')
          .set({
            'uid': 'brief',
            'alertUid': 'a1',
            'countyId': 47,
            'confirmedCount': 3,
            'rule': 'Manual',
            'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
          });

      final brief = await remote.fetchClinicianBrief('a1');
      expect(brief?.alertUid, 'a1');
      expect(brief?.confirmedCount, 3);
    });
  });
}
