import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';

import '../../../../helpers/helpers.dart';

class _MockFunctions extends Mock implements FirebaseFunctions {}

class _MockCallable extends Mock implements HttpsCallable {}

class _MockCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

class _MockStorage extends Mock implements FirebaseStorage {}

class _MockFirestore extends Mock implements FirebaseFirestore {}

// Mocktail can only fake the sealed Firestore query types via implements;
// every member forwards through noSuchMethod, which is all the test needs.
// ignore: subtype_of_sealed_class
class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// Mocktail can only fake the sealed Firestore query types via implements;
// every member forwards through noSuchMethod, which is all the test needs.
// ignore: subtype_of_sealed_class
class _MockDoc extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

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

    test('eviction reads reach the server, never the cache', () async {
      final recording = RecordingFirestore();
      final server = ConversationFirebase(
        firestore: recording,
        functions: functions,
        storage: storage,
      );

      await server.fetchParticipantDelta(uid: 'u1');
      await server.fetchConversation('c1');
      await server.fetchMessages(
        conversationUid: 'c1',
        callerUid: 'u1',
        limit: 200,
      );
      await server.fetchMessages(
        conversationUid: 'c1',
        callerUid: 'u1',
        limit: 200,
        fromSentAt: '2026-11-01T10:00:00.000Z',
      );
      await server.fetchCursor(conversationUid: 'c1', uid: 'u1');

      recording.expectServerReads(7);
    });

    test('one conversation by id, or null when the server has none', () async {
      await firestore.collection('conversations').doc('c1').set({
        'participantUids': ['u1', 'u2'],
        'lastUpdatedAt': '2026-11-01T12:00:00.000Z',
        'lastMessageAt': '2026-11-01T12:00:00.000Z',
      });

      final hit = await remote.fetchConversation('c1');
      expect(hit?.participantUids, ['u1', 'u2']);
      expect(await remote.fetchConversation('nope'), isNull);
    });

    test('messages are ordered by sentAt', () async {
      final col = firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages');
      await col.doc('m2').set({
        'senderUid': 'u1',
        'sentAt': '2026-11-01T11:00:00.000Z',
        'status': 'Sent',
        'text': 'second',
      });
      await col.doc('m1').set({
        'senderUid': 'u1',
        'sentAt': '2026-11-01T10:00:00.000Z',
        'status': 'Sent',
        'text': 'first',
      });

      final rows = await remote.fetchMessages(
        conversationUid: 'c1',
        callerUid: 'u1',
      );
      expect(rows.map((r) => r.uid), ['m1', 'm2']);
    });

    test(
      'withheld rows reach only their sender, merged in stamp order',
      () async {
        final col = firestore
            .collection('conversations')
            .doc('c1')
            .collection('messages');
        await col.doc('m1').set({
          'senderUid': 'u2',
          'sentAt': '2026-11-01T10:00:00.000Z',
          'status': 'Sent',
          'text': 'theirs, readable',
        });
        await col.doc('m2').set({
          'senderUid': 'u2',
          'sentAt': '2026-11-01T11:00:00.000Z',
          'status': 'Withheld',
          'text': '',
        });
        await col.doc('m3').set({
          'senderUid': 'u1',
          'sentAt': '2026-11-01T12:00:00.000Z',
          'status': 'Withheld',
          'text': '',
        });
        await col.doc('m4').set({
          'senderUid': 'u1',
          'sentAt': '2026-11-01T13:00:00.000Z',
          'status': 'Sent',
          'text': 'mine, readable',
        });

        final rows = await remote.fetchMessages(
          conversationUid: 'c1',
          callerUid: 'u1',
        );
        // m4 matches both halves of the split and still appears once.
        expect(rows.map((r) => r.uid), ['m1', 'm3', 'm4']);
      },
    );

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
          'status': 'Sent',
          'text': entry.key,
        });
      }

      final first = await remote.fetchMessages(
        conversationUid: 'c1',
        callerUid: 'u1',
        limit: 2,
      );
      expect(first.map((r) => r.uid), ['m1', 'm2']);
      final rest = await remote.fetchMessages(
        conversationUid: 'c1',
        callerUid: 'u1',
        limit: 2,
        fromSentAt: first.last.sentAt,
      );
      expect(rest.map((r) => r.uid).toSet(), {'m2', 'm3'});
    });

    test('a full peer page holds back a newer own row', () async {
      final col = firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages');
      final base = DateTime.utc(2026, 11, 1, 10);
      for (var i = 0; i < 201; i++) {
        await col.doc('p$i').set({
          'senderUid': 'u2',
          'sentAt': base.add(Duration(seconds: i)).toIso8601String(),
          'status': 'Sent',
          'text': 'p$i',
        });
      }
      await col.doc('mine').set({
        'senderUid': 'u1',
        'sentAt': base.add(const Duration(seconds: 201)).toIso8601String(),
        'status': 'Sent',
        'text': 'mine',
      });

      // The readable query comes back full, so the page ends at its last
      // row; the newer own row waits instead of dragging the cursor past
      // the peer row still behind it.
      final first = await remote.fetchMessages(
        conversationUid: 'c1',
        callerUid: 'u1',
        limit: 200,
      );
      expect(first, hasLength(200));
      expect(first.map((r) => r.uid), isNot(contains('mine')));
      expect(first.last.uid, 'p199');

      final rest = await remote.fetchMessages(
        conversationUid: 'c1',
        callerUid: 'u1',
        limit: 200,
        fromSentAt: first.last.sentAt,
      );
      expect(rest.map((r) => r.uid).toSet(), {'p199', 'p200', 'mine'});

      final all = {...first.map((r) => r.uid), ...rest.map((r) => r.uid)};
      expect(all, hasLength(202));
    });

    test('interleaved threads page completely and terminate', () async {
      final col = firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages');
      final base = DateTime.utc(2026, 11, 1, 10);
      for (var i = 0; i < 500; i++) {
        final own = i.isOdd;
        await col.doc('m$i').set({
          'senderUid': own ? 'u1' : 'u2',
          'sentAt': base.add(Duration(seconds: i)).toIso8601String(),
          'status': own && i % 50 == 1 ? 'Withheld' : 'Sent',
          'text': 'm$i',
        });
      }

      final seen = <String>{};
      String? cursor;
      var pages = 0;
      for (;;) {
        final page = await remote.fetchMessages(
          conversationUid: 'c1',
          callerUid: 'u1',
          limit: 200,
          fromSentAt: cursor,
        );
        if (page.isEmpty) break;
        expect(page.map((r) => r.uid).toSet(), hasLength(page.length));
        final before = seen.length;
        seen.addAll(page.map((r) => r.uid));
        if (seen.length == before) break;
        cursor = page.last.sentAt;
        pages++;
        expect(pages, lessThan(10), reason: 'paging terminates');
      }
      expect(seen, hasLength(500));
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

    test('create stamps lastUpdatedAt from lastReadAt', () async {
      await remote.updateCursor(
        conversationUid: 'c1',
        uid: 'u1',
        lastReadAt: '2026-11-01T11:00:00.000Z',
      );

      final doc = await firestore
          .collection('conversations')
          .doc('c1')
          .collection('cursors')
          .doc('u1')
          .get();
      expect(doc.data()!['lastUpdatedAt'], '2026-11-01T11:00:00.000Z');
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
      final data = doc.data()!;
      expect(data['kind'], 'Voice');
      expect(data['attachmentPath'], 'conversations/c1/voice/m1.m4a');
      expect(data['attachmentType'], 'audio/mp4');
      expect(data['attachmentSize'], 3);
      expect(data['voiceDurationMs'], 1000);
      expect(data['transcriptLanguage'], '');
      expect(data['deliveredAt'], '');
      expect(data['lastUpdatedAt'], '2026-11-01T10:00:00.000Z');
      expect(
        data.keys.toSet(),
        unorderedEquals(const {
          'uid',
          'conversationUid',
          'senderUid',
          'kind',
          'text',
          'attachmentPath',
          'attachmentType',
          'attachmentSize',
          'voiceDurationMs',
          'voicePeaks',
          'transcriptShared',
          'transcriptLanguage',
          'transcriptStatus',
          'identifierFlagged',
          'inputMode',
          'status',
          'withheldReason',
          'sentAt',
          'deliveredAt',
          'lastUpdatedAt',
        }),
      );
    });

    test('a failed create deletes the upload', () async {
      final ref = _MockRef();
      final snap = _MockTaskSnapshot();
      final mockFirestore = _MockFirestore();
      final conversations = _MockCollection();
      final conversation = _MockDoc();
      final messages = _MockCollection();
      final docRef = _MockDoc();
      when(() => storage.ref(any())).thenReturn(ref);
      when(
        () => ref.putData(any(), any()),
      ).thenAnswer((_) => _FakeUploadTask(snap));
      when(() => mockFirestore.collection(any())).thenReturn(conversations);
      when(() => conversations.doc(any())).thenReturn(conversation);
      when(() => conversation.collection(any())).thenReturn(messages);
      when(() => messages.doc(any())).thenReturn(docRef);
      when(() => docRef.set(any())).thenThrow(
        FirebaseException(plugin: 'firestore', code: 'permission-denied'),
      );
      when(ref.delete).thenAnswer((_) async {});
      final failing = ConversationFirebase(
        firestore: mockFirestore,
        functions: functions,
        storage: storage,
      );

      await expectLater(
        failing.createVoiceMessage(
          conversationUid: 'c1',
          messageUid: 'm1',
          senderUid: 'u1',
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'audio/mp4',
          durationMs: 1000,
          voicePeaks: const [1, 2],
          sentAt: '2026-11-01T10:00:00.000Z',
        ),
        throwsA(AppError.permissionDenied),
      );
      verify(ref.delete).called(1);
    });

    test('voice values outside the rules never reach the server', () async {
      final ref = _MockRef();
      when(() => storage.ref(any())).thenReturn(ref);

      for (final bad in [
        () => remote.createVoiceMessage(
          conversationUid: 'c1',
          messageUid: 'm1',
          senderUid: 'u1',
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'video/mp4',
          durationMs: 1000,
          voicePeaks: const [1, 2],
          sentAt: '2026-11-01T10:00:00.000Z',
        ),
        () => remote.createVoiceMessage(
          conversationUid: 'c1',
          messageUid: 'm1',
          senderUid: 'u1',
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'audio/mp4',
          durationMs: 0,
          voicePeaks: const [1, 2],
          sentAt: '2026-11-01T10:00:00.000Z',
        ),
        () => remote.createVoiceMessage(
          conversationUid: 'c1',
          messageUid: 'm1',
          senderUid: 'u1',
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'audio/mp4',
          durationMs: 1000,
          voicePeaks: List.filled(65, 1),
          sentAt: '2026-11-01T10:00:00.000Z',
        ),
        () => remote.createVoiceMessage(
          conversationUid: 'c1',
          messageUid: 'm1',
          senderUid: 'u1',
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'audio/mp4',
          durationMs: 1000,
          voicePeaks: const [1, 101],
          sentAt: '2026-11-01T10:00:00.000Z',
        ),
      ]) {
        await expectLater(bad(), throwsArgumentError);
      }
      verifyNever(() => ref.putData(any(), any()));
    });
  });

  group('text messages', () {
    test('the payload matches messageKeys exactly', () async {
      await remote.createTextMessage(
        conversationUid: 'c1',
        messageUid: 'm1',
        senderUid: 'u1',
        text: 'hello',
        sentAt: '2026-11-01T10:00:00.000Z',
      );

      final doc = await firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages')
          .doc('m1')
          .get();
      final data = doc.data()!;
      expect(data['kind'], 'Text');
      expect(data['text'], 'hello');
      expect(data['voiceDurationMs'], 0);
      expect(data['voicePeaks'], isEmpty);
      expect(data['transcriptLanguage'], '');
      expect(data['deliveredAt'], '');
      expect(data['lastUpdatedAt'], data['sentAt']);
      expect(
        data.keys.toSet(),
        unorderedEquals(const {
          'uid',
          'conversationUid',
          'senderUid',
          'kind',
          'text',
          'attachmentPath',
          'attachmentType',
          'attachmentSize',
          'voiceDurationMs',
          'voicePeaks',
          'transcriptShared',
          'transcriptLanguage',
          'transcriptStatus',
          'identifierFlagged',
          'inputMode',
          'status',
          'withheldReason',
          'sentAt',
          'deliveredAt',
          'lastUpdatedAt',
        }),
      );
    });

    test('empty and over-long text never reach the server', () async {
      for (final text in ['', 'x' * 2001]) {
        await expectLater(
          remote.createTextMessage(
            conversationUid: 'c1',
            messageUid: 'm1',
            senderUid: 'u1',
            text: text,
            sentAt: '2026-11-01T10:00:00.000Z',
          ),
          throwsArgumentError,
        );
      }

      final snap = await firestore
          .collection('conversations')
          .doc('c1')
          .collection('messages')
          .doc('m1')
          .get();
      expect(snap.exists, isFalse);
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
