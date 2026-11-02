import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/datasources/case_firebase.dart';

import '../../../../helpers/helpers.dart';

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
  late CaseFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = _MockFunctions();
    callable = _MockCallable();
    remote = CaseFirebase(firestore: firestore, functions: functions);
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('fetchParticipantDelta', () {
    test(
      'returns only the caller participant rows at or after cursor',
      () async {
        await firestore.collection('cases').doc('c1').set({
          'participantUids': ['u1', 'doc'],
          'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
        });
        await firestore.collection('cases').doc('c2').set({
          'participantUids': ['u1'],
          'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        });
        await firestore.collection('cases').doc('other').set({
          'participantUids': ['u2'],
          'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        });

        final rows = await remote.fetchParticipantDelta(
          uid: 'u1',
          cursor: '2026-11-01T11:00:00.000Z',
        );
        expect(rows.map((r) => r.uid), ['c2']);
      },
    );
  });

  group('log', () {
    test('patient log filters patientVisible == true', () async {
      final log = firestore.collection('cases').doc('c1').collection('log');
      await log.doc('0001').set({
        'seq': 1,
        'patientVisible': true,
        'actionType': 'Create',
      });
      await log.doc('0002').set({
        'seq': 2,
        'patientVisible': false,
        'actionType': 'Note',
      });

      final rows = await remote.fetchPatientLog('c1');
      expect(rows.map((r) => r.uid), ['0001']);
    });

    test('clinician log returns every row ordered by seq', () async {
      final log = firestore.collection('cases').doc('c1').collection('log');
      await log.doc('0002').set({'seq': 2, 'patientVisible': false});
      await log.doc('0001').set({'seq': 1, 'patientVisible': true});

      final rows = await remote.fetchClinicianLog('c1');
      expect(rows.map((r) => r.uid), ['0001', '0002']);
    });
  });

  group('updateDoctorNotes', () {
    test('writes only allowed fields plus lastUpdatedAt', () async {
      await firestore.collection('cases').doc('c1').set({
        'clinicalNotes': 'old',
        'priority': 'Routine',
        'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
      });

      await remote.updateDoctorNotes(
        caseUid: 'c1',
        currentStage: 'OrderCreated',
        clinicalNotes: 'new',
        sampleCollectedAt: '2026-10-20T08:00:00.000Z',
      );

      final data = (await firestore.collection('cases').doc('c1').get())
          .data()!;
      expect(data['clinicalNotes'], 'new');
      expect(data['sampleCollectedAt'], '2026-10-20T08:00:00.000Z');
      expect(data['priority'], 'Routine');
      expect(data['lastUpdatedAt'], isNot('2026-11-01T10:00:00.000Z'));
    });

    test('refuses notes after acceptance', () async {
      await expectLater(
        remote.updateDoctorNotes(
          caseUid: 'c1',
          currentStage: 'PathologistAccepted',
          clinicalNotes: 'too late',
        ),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  group('callables', () {
    test('createOrder sends the documented map', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'ok'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.createOrder(
        caseUid: 'c1',
        appointmentUid: 'a1',
        patientId: 'p1',
        labTestIds: ['t1'],
        priority: 'Routine',
        sampleCollectedAt: '2026-10-20T08:00:00.000Z',
        payment: {'method': 'Cash'},
        pathologistUid: 'path1',
      );

      verify(() => functions.httpsCallable('createOrder')).called(1);
      final sent =
          verify(
                () => callable.call<dynamic>(captureAny<dynamic>()),
              ).captured.single
              as Map<String, dynamic>;
      expect(sent['caseUid'], 'c1');
      expect(sent['labTestIds'], ['t1']);
      expect(sent['pathologistUid'], 'path1');
      expect(sent['payment'], {'method': 'Cash'});
    });

    test('acceptCase maps a functions refusal', () async {
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenThrow(_Refusal('requestClosed', 'failed-precondition'));
      await expectLater(
        remote.acceptCase(caseUid: 'c1'),
        throwsA(isA<AppError>()),
      );
    });
  });

  group('server reads', () {
    test('eviction reads reach the server, never the cache', () async {
      final recording = RecordingFirestore();
      final server = CaseFirebase(firestore: recording, functions: functions);

      await server.fetchParticipantDelta(uid: 'u1');
      await server.fetchCase('c1');
      await server.fetchPayment('c1');
      await server.fetchRiskCheck('c1');
      await server.fetchNotesTranslation('c1');

      recording.expectServerReads(5);
    });
  });
}
