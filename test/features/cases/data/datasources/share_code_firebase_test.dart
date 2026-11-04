import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/cases/data/datasources/share_code_firebase.dart';
import 'package:tabibu/features/cases/data/models/share_code_model.dart';

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
  late ShareCodeFirebase remote;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = _MockFunctions();
    callable = _MockCallable();
    remote = ShareCodeFirebase(firestore: firestore, functions: functions);
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('deltas', () {
    test('creator delta returns only the caller rows', () async {
      await firestore.collection('shareCodes').doc('s1').set({
        'createdByUid': 'doc1',
        'recipientUid': 'path1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('shareCodes').doc('s2').set({
        'createdByUid': 'other',
        'recipientUid': 'doc1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchCreatorDelta(createdByUid: 'doc1');
      expect(rows.map((r) => r.uid), ['s1']);
    });

    test('recipient delta returns only the recipient rows', () async {
      await firestore.collection('shareCodes').doc('s1').set({
        'createdByUid': 'doc1',
        'recipientUid': 'path1',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('shareCodes').doc('s2').set({
        'createdByUid': 'doc1',
        'recipientUid': 'other',
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchRecipientDelta(recipientUid: 'path1');
      expect(rows.map((r) => r.uid), ['s1']);
    });
  });

  group('callables', () {
    test('createShareCode sends the documented map', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'ok'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.createShareCode(
        shareUid: 's1',
        caseUid: 'c1',
        recipientUid: 'path1',
      );

      verify(() => functions.httpsCallable('createShareCode')).called(1);
      final sent =
          verify(
                () => callable.call<dynamic>(captureAny<dynamic>()),
              ).captured.single
              as Map<String, dynamic>;
      expect(sent, {
        'shareUid': 's1',
        'caseUid': 'c1',
        'recipientUid': 'path1',
      });
    });

    test(
      'redeemShareCode sends code but never surfaces it in errors',
      () async {
        const secret = 'PLAINTEXT-CODE-XYZ';
        when(
          () => callable.call<dynamic>(any<dynamic>()),
        ).thenThrow(_Refusal('wrongCode', 'permission-denied'));

        Object? caught;
        try {
          await remote.redeemShareCode(shareUid: 's1', code: secret);
        } on Object catch (e) {
          caught = e;
        }
        expect(caught, AppError.wrongShareCode);
        expect(caught.toString(), isNot(contains(secret)));
        expect('$caught', isNot(contains(secret)));

        final sent =
            verify(
                  () => callable.call<dynamic>(captureAny<dynamic>()),
                ).captured.single
                as Map<String, dynamic>;
        expect(sent['code'], secret);
      },
    );

    test('reissueShareCode is called by name', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'ok'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.reissueShareCode(shareUid: 's1');
      verify(() => functions.httpsCallable('reissueShareCode')).called(1);
    });
  });

  group('model', () {
    test('ShareCodeModel.toString does not carry a raw code', () {
      final model = ShareCodeModel.fromJson({
        'uid': 's1',
        'caseUid': 'c1',
        'createdByUid': 'doc1',
        'recipientUid': 'path1',
        'notificationUid': 'n1',
      });
      expect(model.toString(), isNot(contains('code')));
    });
  });

  group('server reads', () {
    test('eviction reads reach the server, never the cache', () async {
      final recording = RecordingFirestore();
      final server = ShareCodeFirebase(
        firestore: recording,
        functions: functions,
      );

      await server.fetchCreatorDelta(createdByUid: 'u1');
      await server.fetchRecipientDelta(recipientUid: 'u1');
      await server.fetchShareCode('s1');

      recording.expectServerReads(3);
    });
  });
}
