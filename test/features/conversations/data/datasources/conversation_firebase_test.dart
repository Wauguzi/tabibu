import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockRef extends Mock implements Reference {}

class _MockTaskSnapshot extends Mock implements TaskSnapshot {}

class _FakeUploadTask extends Fake implements UploadTask {
  _FakeUploadTask(this._snap);

  final TaskSnapshot _snap;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) => Future<R>.value(onValue(_snap));
}

class _Refusal extends FirebaseFunctionsException {
  _Refusal(String reason, String code) : super(message: reason, code: code);
}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockFunctions functions;
  late _MockCallable callable;
  late _MockStorage storage;
  late ConversationFirebase remote;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(SettableMetadata(contentType: 'audio/mp4'));
  });

  setUp(() {
    firestore = FakeFirebaseFirestore();
    functions = _MockFunctions();
    callable = _MockCallable();
    storage = _MockStorage();
    remote = ConversationFirebase(
      firestore: firestore,
      functions: functions,
      storage: storage,
    );
    when(() => functions.httpsCallable(any())).thenReturn(callable);
  });

  group('queries', () {
    test('participant delta returns only the member rows', () async {
      await firestore.collection('conversations').doc('c1').set({
        'participantUids': ['u1', 'u2'],
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        'lastMessageAt': '2026-11-01T12:00:00.000Z',
      });
      await firestore.collection('conversations').doc('c2').set({
        'participantUids': ['u3'],
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        'lastMessageAt': '2026-11-01T12:00:00.000Z',
      });

      final rows = await remote.fetchParticipantDelta(uid: 'u1');
      expect(rows.map((r) => r.uid), ['c1']);
    });

    test('messages are ordered by sentAt', () async {
      final col = firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages');
      await col.doc('m2').set({
        'senderUid': 'u1',
        'sentAt': '2026-11-01T11:00:00.000Z',
        'text': 'second',
      });
      await col.doc('m1').set({
        'senderUid': 'u1',
        'sentAt': '2026-11-01T10:00:00.000Z',
        'text': 'first',
      });

      final rows = await remote.fetchMessages(conversationUid: 'c1');
      expect(rows.map((r) => r.uid), ['m1', 'm2']);
    });

    test('messages page by limit and an inclusive cursor', () async {
      final col = firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages');
      // m2 and m3 share a stamp across the page boundary.
      const stamps = {
        'm1': '2026-11-01T11:00:00.000Z',
        'm2': '2026-11-01T12:00:00.000Z',
        'm3': '2026-11-01T12:00:00.000Z',
      };
      for (final entry in stamps.entries) {
        await col.doc(entry.key).set({
          'senderUid': 'u1',
          'sentAt': entry.value,
          'text': entry.key,
        });
      }

      final first = await remote.fetchMessages(conversationUid: 'c1', limit: 2);
      expect(first.map((r) => r.uid), ['m1', 'm2']);
      final rest = await remote.fetchMessages(
        conversationUid: 'c1',
        limit: 2,
        fromSentAt: first.last.sentAt,
      );
      expect(rest.map((r) => r.uid).toSet(), {'m2', 'm3'});
    });

    test('one message by id, null when missing', () async {
      final col = firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages');
      await col.doc('m1').set({
        'senderUid': 'u1',
        'sentAt': '2026-11-01T10:00:00.000Z',
        'text': 'first',
      });

      final hit = await remote.fetchMessage(
        conversationUid: 'c1',
        messageUid: 'm1',
      );
      expect(hit?.text, 'first');
      final miss = await remote.fetchMessage(
        conversationUid: 'c1',
        messageUid: 'nope',
      );
      expect(miss, isNull);
    });
  });

  group('cursor', () {
    test('creates a forward cursor and refuses a rewind', () async {
      await remote.updateCursor(
        conversationUid: 'c1',
        uid: 'u1',
        lastReadAt: '2026-11-01T11:00:00.000Z',
      );
      await remote.updateCursor(
        conversationUid: 'c1',
        uid: 'u1',
        lastReadAt: '2026-11-01T10:00:00.000Z',
      );
      final cursor = await remote.fetchCursor(conversationUid: 'c1', uid: 'u1');
      expect(cursor?.lastReadAt, '2026-11-01T11:00:00.000Z');
    });
  });

  group('voice notes', () {
    test('upload then create; a failed upload creates no message', () async {
      final ref = _MockRef();
      when(() => storage.ref(any())).thenReturn(ref);
      when(
        () => ref.putData(any(), any()),
      ).thenThrow(FirebaseException(plugin: 'storage', code: 'unavailable'));

      await expectLater(
        remote.createVoiceMessage(
          conversationUid: 'c1',
          messageUid: 'm1',
          senderUid: 'u1',
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'audio/mp4',
          durationMs: 1000,
          voicePeaks: const [1, 2],
          sentAt: '2026-11-01T10:00:00.000Z',
        ),
        throwsA(AppError.serviceUnavailable),
      );

      final snap = await firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages')
          .doc('m1')
          .get();
      expect(snap.exists, isFalse);
    });

    test('successful upload writes the message', () async {
      final ref = _MockRef();
      final snap = _MockTaskSnapshot();
      when(() => storage.ref(any())).thenReturn(ref);
      when(
        () => ref.putData(any(), any()),
      ).thenAnswer((_) => _FakeUploadTask(snap));

      await remote.createVoiceMessage(
        conversationUid: 'c1',
        messageUid: 'm1',
        senderUid: 'u1',
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'audio/mp4',
        durationMs: 1000,
        voicePeaks: const [1, 2],
        sentAt: '2026-11-01T10:00:00.000Z',
      );

      final doc = await firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages')
          .doc('m1')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['kind'], 'Voice');
      expect(doc.data()!['attachmentPath'], 'conversations/c1/voice/m1.m4a');
    });
  });

  group('callables', () {
    test('openMdt sends caseUid and invitees', () async {
      final result = _MockCallableResult();
      when(() => result.data).thenReturn({'status': 'ok'});
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenAnswer((_) async => result);

      await remote.openMdt(
        conversationUid: 'mdt-1',
        caseUid: 'case-1',
        specialty: 'Pathology',
        description: 'Discuss margins',
        inviteeUids: const ['d2'],
      );

      verify(() => functions.httpsCallable('openMdt')).called(1);
      final sent =
          verify(
                () => callable.call<dynamic>(captureAny<dynamic>()),
              ).captured.single
              as Map<String, dynamic>;
      expect(sent['caseUid'], 'case-1');
      expect(sent['inviteeUids'], ['d2']);
    });

    test('withdrawMessage maps a functions refusal', () async {
      when(
        () => callable.call<dynamic>(any<dynamic>()),
      ).thenThrow(_Refusal('permission-denied', 'permission-denied'));
      await expectLater(
        remote.withdrawMessage(conversationUid: 'c1', messageUid: 'm1'),
        throwsA(AppError.permissionDenied),
      );
    });
  });
}
