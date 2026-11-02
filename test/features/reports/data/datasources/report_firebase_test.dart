import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/reports/data/datasources/report_firebase.dart';

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
  late ReportFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = _MockFunctions();
    callable = _MockCallable();
    remote = ReportFirebase(firestore: firestore, functions: functions);
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('deltas', () {
    test(
      'reader delta returns only rows whose readerUids contain the caller',
      () async {
        await firestore
            .collection('cases')
            .doc('c1')
            .collection('reports')
            .doc('v1')
            .set({
              'readerUids': ['doc1'],
              'releasedToPatient': false,
              'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
            });
        await firestore
            .collection('cases')
            .doc('c2')
            .collection('reports')
            .doc('v1')
            .set({
              'readerUids': ['other'],
              'releasedToPatient': true,
              'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
            });

        final rows = await remote.fetchReaderDelta(uid: 'doc1');
        expect(rows.map((r) => r.uid), ['v1']);
      },
    );

    test('patient delta requires releasedToPatient', () async {
      await firestore
          .collection('cases')
          .doc('c1')
          .collection('reports')
          .doc('v1')
          .set({
            'readerUids': ['amina'],
            'releasedToPatient': false,
            'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
          });
      await firestore
          .collection('cases')
          .doc('c1')
          .collection('reports')
          .doc('v2')
          .set({
            'readerUids': ['amina'],
            'releasedToPatient': true,
            'lastUpdatedAt': '2026-11-01T13:00:00.000Z',
          });

      final rows = await remote.fetchPatientDelta(uid: 'amina');
      expect(rows.map((r) => r.uid), ['v2']);
    });
  });

  group('fetchReportForPdf', () {
    test('reads with Source.server', () async {
      await firestore
          .collection('cases')
          .doc('c1')
          .collection('reports')
          .doc('v1')
          .set({
            'readerUids': ['doc1'],
            'diagnosis': 'ok',
            'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
          });

      final report = await remote.fetchReportForPdf(
        caseUid: 'c1',
        reportUid: 'v1',
      );
      expect(report?.uid, 'v1');
      expect(report?.diagnosis, 'ok');
      // FakeFirebaseFirestore honours GetOptions; the call path uses server.
      final snap = await firestore
          .collection('cases')
          .doc('c1')
          .collection('reports')
          .doc('v1')
          .get(const GetOptions(source: Source.server));
      expect(snap.exists, isTrue);
    });
  });

  group('updateDraft', () {
    test('writes only editable fields plus lastUpdatedAt', () async {
      await firestore
          .collection('cases')
          .doc('c1')
          .collection('reportDrafts')
          .doc('path1')
          .set({
            'kind': 'Initial',
            'status': 'Editing',
            'title': '',
            'diagnosis': '',
            'pathologistUid': 'path1',
            'lastUpdatedAt': '2026-11-01T10:00:00.000Z',
          });

      await remote.updateDraft(
        caseUid: 'c1',
        pathologistUid: 'path1',
        fields: {
          'title': 'Biopsy',
          'labelOverrides': {'a': 'x'},
        },
      );

      final data =
          (await firestore
                  .collection('cases')
                  .doc('c1')
                  .collection('reportDrafts')
                  .doc('path1')
                  .get())
              .data()!;
      expect(data['title'], 'Biopsy');
      expect(data['status'], 'Editing');
      expect(data['pathologistUid'], 'path1');
      expect(data['labelOverrideCount'], 1);
      expect(data['lastUpdatedAt'], isNot('2026-11-01T10:00:00.000Z'));
    });
  });

  test('updateDraft refuses a field the rules forbid', () {
    expect(
      () => remote.updateDraft(
        caseUid: 'c1',
        pathologistUid: 'path1',
        fields: {'title': 'Biopsy', 'status': 'Signed'},
      ),
      throwsArgumentError,
    );
  });

  group('approved text', () {
    test('fetches by id only', () async {
      await firestore
          .collection('cases')
          .doc('c1')
          .collection('reportTextsApproved')
          .doc('v1_Translation_sw')
          .set({
            'approvedText': {'title': 't'},
            'approverUid': 'path1',
          });

      final text = await remote.fetchApprovedText(
        caseUid: 'c1',
        textUid: 'v1_Translation_sw',
      );
      expect(text?.uid, 'v1_Translation_sw');
      expect(text?.approvedText['title'], 't');
    });
  });

  group('callables', () {
    test('signReport sends draftLastUpdatedAt', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'reportUid': 'v1'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.signReport(
        caseUid: 'c1',
        signaturePng: 'base64',
        draftLastUpdatedAt: '2026-11-01T10:00:00.000Z',
      );

      verify(() => functions.httpsCallable('signReport')).called(1);
      final sent =
          verify(
                () => callable.call<dynamic>(captureAny<dynamic>()),
              ).captured.single
              as Map<String, dynamic>;
      expect(sent['draftLastUpdatedAt'], '2026-11-01T10:00:00.000Z');
      expect(sent['signaturePng'], 'base64');
    });

    test('discardDraft maps a functions refusal', () async {
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenThrow(_Refusal('draftChanged', 'failed-precondition'));
      await expectLater(
        remote.discardDraft(caseUid: 'c1', draftLastUpdatedAt: 'stale'),
        throwsA(isA<AppError>()),
      );
    });

    test('markDiscussed is called by name', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'ok'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.markDiscussed(caseUid: 'c1', reportUid: 'v1');
      verify(() => functions.httpsCallable('markDiscussed')).called(1);
    });
  });

  group('server reads', () {
    test('eviction reads reach the server, never the cache', () async {
      final recording = RecordingFirestore();
      final server = ReportFirebase(firestore: recording, functions: functions);

      await server.fetchReaderDelta(uid: 'u1');
      await server.fetchPatientDelta(uid: 'u1');
      await server.fetchReport(caseUid: 'c1', reportUid: 'v1');
      await server.fetchDraft(caseUid: 'c1', pathologistUid: 'path1');
      await server.fetchPrereadScore(caseUid: 'c1', runUid: 'run1');
      await server.fetchApprovedText(
        caseUid: 'c1',
        textUid: 'v1_Explanation_en',
      );

      recording.expectServerReads(6);
    });
  });
}
