import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/conversations/data/cache/conversation_cache_helper.dart';
import 'package:tabibu/features/conversations/data/datasources/conversation_firebase.dart';
import 'package:tabibu/features/conversations/data/models/case_summary_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_cursor_model.dart';
import 'package:tabibu/features/conversations/data/models/conversation_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_member_hive.dart';
import 'package:tabibu/features/conversations/data/models/conversation_model.dart';
import 'package:tabibu/features/conversations/data/models/message_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/data/models/message_preview_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_hive.dart';
import 'package:tabibu/features/conversations/data/models/message_transcript_model.dart';

class _MockConversationFirebase extends Mock implements ConversationFirebase {}

class _MockHiveHelper extends Mock implements HiveHelperImpl {}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t2 = '2026-11-02T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';
const _t4 = '2026-11-04T10:00:00.000Z';

ConversationModel _conv(
  String uid, {
  List<String> members = const ['u1', 'u2'],
  String lastMessageAt = _t1,
  String stamp = _t1,
  bool synced = true,
  String type = 'GroupConsult',
  String resourceType = 'Case',
  String resourceUid = 'case1',
}) => ConversationModel.empty().copyWith(
  uid: uid,
  participantUids: members,
  lastMessageAt: lastMessageAt,
  lastUpdatedAt: stamp,
  synced: synced,
  type: type,
  linkedResourceType: resourceType,
  linkedResourceUid: resourceUid,
);

MessageModel _msg(
  String uid, {
  String conv = 'c1',
  String sender = 'u2',
  String sentAt = _t2,
  String stamp = _t2,
  bool synced = true,
  String status = 'Sent',
  String text = 'hello',
}) => MessageModel.empty().copyWith(
  uid: uid,
  conversationUid: conv,
  senderUid: sender,
  text: text,
  status: status,
  sentAt: sentAt,
  lastUpdatedAt: stamp,
  synced: synced,
);

MessageTranscriptModel _transcript(
  String messageUid, {
  String kind = 'shared',
  String sender = 'u2',
  String conv = 'c1',
}) => MessageTranscriptModel.empty().copyWith(
  uid: kind,
  messageUid: messageUid,
  senderUid: sender,
  conversationUid: conv,
  text: 'transcript text',
  lastUpdatedAt: _t2,
);

void main() {
  late Directory dir;
  late _MockConversationFirebase remote;
  late ConversationCacheHelper helper;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<int>[]);
    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(ConversationHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(33)) {
      Hive.registerAdapter(ConversationMemberHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(34)) {
      Hive.registerAdapter(CaseSummaryHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(35)) {
      Hive.registerAdapter(MessageHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(36)) {
      Hive.registerAdapter(MessagePreviewHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(37)) {
      Hive.registerAdapter(ConversationCursorHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(38)) {
      Hive.registerAdapter(MessageTranscriptHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_conv_cache_');
    Hive.init(dir.path);
    await Hive.openBox<ConversationHive>(HiveHelperImpl.conversationsBox);
    await Hive.openBox<ConversationCursorHive>(
      HiveHelperImpl.conversationCursorsBox,
    );
    await Hive.openBox<MessageTranscriptHive>(
      HiveHelperImpl.messageTranscriptsBox,
    );
    await Hive.openLazyBox<MessageHive>(HiveHelperImpl.messagesBoxName);
    remote = _MockConversationFirebase();
    final hive = _MockHiveHelper();
    Future<LazyBox<MessageHive>> openMessages(_) async =>
        Hive.lazyBox<MessageHive>(HiveHelperImpl.messagesBoxName);
    when(hive.messagesBox).thenAnswer(openMessages);
    helper = ConversationCacheHelper(
      db: DBHelperImpl(),
      remote: remote,
      hive: hive,
    );
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  Future<void> seedThread() =>
      helper.cacheConversations([_conv('c1')], fromCloud: true);

  group('merge guard', () {
    test('an unsynced conversation survives a newer cloud row', () async {
      await helper.cacheConversations([
        _conv('c1', synced: false),
      ], fromCloud: false);
      when(
        () => remote.fetchParticipantDelta(
          uid: any(named: 'uid'),
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_conv('c1', stamp: _t3)]);

      await helper.syncConversations('u1');

      final rows = await helper.getConversations('u1');
      expect(rows.single.lastUpdatedAt, _t1);
      expect(rows.single.synced, isFalse);
    });

    test('a synced conversation is replaced by a newer cloud row', () async {
      await helper.cacheConversations([_conv('c1')], fromCloud: true);
      when(
        () => remote.fetchParticipantDelta(
          uid: any(named: 'uid'),
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_conv('c1', stamp: _t3)]);

      await helper.syncConversations('u1');

      final rows = await helper.getConversations('u1');
      expect(rows.single.lastUpdatedAt, _t3);
      expect(rows.single.synced, isTrue);
    });

    test('a cloud echo of our queued message replaces it', () async {
      await seedThread();
      when(
        () => remote.createTextMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          text: any(named: 'text'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenThrow(AppError.noInternet);
      final queued = await helper.queueTextMessage(
        conversationUid: 'c1',
        senderUid: 'u1',
        text: 'hi',
      );
      when(() => remote.fetchMessages(conversationUid: 'c1')).thenAnswer(
        (_) async => [
          _msg(queued.uid, sender: 'u1', status: 'Delivered', stamp: _t3),
        ],
      );

      await helper.syncMessages('u1', 'c1');

      final rows = await helper.getMessages('u1', 'c1');
      expect(rows.single.status, 'Delivered');
      expect(rows.single.synced, isTrue);
    });

    test('an unsynced message survives an unrelated newer cloud row', () async {
      await seedThread();
      await helper.cacheMessages([
        _msg('m1', sender: 'u1', synced: false, stamp: _t1),
      ], fromCloud: false);

      await helper.cacheMessages([
        _msg('m1', stamp: _t3, text: 'forged'),
      ], fromCloud: true);

      final rows = await helper.getMessages('u1', 'c1');
      expect(rows.single.senderUid, 'u1');
      expect(rows.single.synced, isFalse);
    });
  });

  group('scope', () {
    test('threads without the uid are never returned', () async {
      await helper.cacheConversations([
        _conv('c1', members: ['u1']),
        _conv('c2', members: ['u2']),
      ], fromCloud: true);

      expect((await helper.getConversations('u1')).map((c) => c.uid), ['c1']);
      expect(await helper.getConversations(''), isEmpty);
      expect(
        await helper.getConversation('u2', 'c1'),
        isA<ConversationModel>(),
      );
      expect((await helper.getConversation('u2', 'c1')).uid, isEmpty);
    });

    test('messages outside the thread are never returned', () async {
      await helper.cacheConversations([
        _conv('c1', members: ['u1']),
      ], fromCloud: true);
      await helper.cacheMessages([_msg('m1')], fromCloud: true);

      expect(await helper.getMessages('u2', 'c1'), isEmpty);
      expect(await helper.unreadCount('u2', 'c1'), 0);
      await expectLater(
        helper.syncMessages('u2', 'c1'),
        throwsA(AppError.dataNotFound),
      );
      await expectLater(
        helper.queueTextMessage(
          conversationUid: 'c1',
          senderUid: 'u2',
          text: 'hi',
        ),
        throwsA(AppError.dataNotFound),
      );
    });

    test('conversations filter by type and resource', () async {
      await helper.cacheConversations([
        _conv('c1', type: 'Direct'),
        _conv('c2', resourceUid: 'case2'),
      ], fromCloud: true);

      expect(
        (await helper.getConversations('u1', type: .direct)).map((c) => c.uid),
        ['c1'],
      );
      expect(
        (await helper.getForResource('u1', 'Case', 'case2')).map((c) => c.uid),
        ['c2'],
      );
      expect(await helper.getForResource('u1', 'Case', 'nope'), isEmpty);
    });
  });

  group('remote fails', () {
    test('with a cache it returns the cache', () async {
      await helper.cacheConversations([_conv('c1')], fromCloud: true);
      await helper.cacheMessages([_msg('m1')], fromCloud: true);
      when(
        () => remote.fetchParticipantDelta(
          uid: any(named: 'uid'),
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);
      when(
        () => remote.fetchMessages(
          conversationUid: any(named: 'conversationUid'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      expect((await helper.syncConversations('u1')).map((c) => c.uid), ['c1']);
      expect((await helper.syncMessages('u1', 'c1')).map((m) => m.uid), ['m1']);
    });

    test('without a cache it rethrows', () async {
      when(
        () => remote.fetchParticipantDelta(
          uid: any(named: 'uid'),
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.requestTimeout);
      when(
        () => remote.fetchMessages(
          conversationUid: any(named: 'conversationUid'),
        ),
      ).thenThrow(AppError.requestTimeout);

      await expectLater(
        helper.syncConversations('u1'),
        throwsA(AppError.requestTimeout),
      );
      await seedThread();
      await expectLater(
        helper.syncMessages('u1', 'c1'),
        throwsA(AppError.requestTimeout),
      );
    });

    test('a refusal rethrows even with a cache', () async {
      await helper.cacheConversations([_conv('c1')], fromCloud: true);
      when(
        () => remote.fetchParticipantDelta(
          uid: any(named: 'uid'),
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.syncConversations('u1'),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  group('messages', () {
    test('pages run newest first', () async {
      await seedThread();
      await helper.cacheMessages([
        _msg('m1', sentAt: _t1),
        _msg('m2'),
        _msg('m3', sentAt: _t3),
      ], fromCloud: true);

      expect(
        (await helper.getMessages('u1', 'c1', limit: 2)).map((m) => m.uid),
        ['m3', 'm2'],
      );
      expect(
        (await helper.getMessages('u1', 'c1', before: _t3)).map((m) => m.uid),
        ['m2', 'm1'],
      );
    });

    test(
      'pruning keeps the newest 200 synced rows and every queued row',
      () async {
        await seedThread();
        final base = DateTime.utc(2026, 11);
        final batch = [
          for (var i = 0; i < 201; i++)
            _msg(
              'm$i',
              sentAt: base.add(Duration(seconds: i)).toIso8601String(),
            ),
        ];
        await helper.cacheMessages(batch, fromCloud: true);
        await helper.cacheMessages([
          _msg('pending', sender: 'u1', sentAt: _t1, synced: false),
        ], fromCloud: false);

        final rows = await helper.getMessages('u1', 'c1');
        expect(rows, hasLength(201));
        expect(rows.map((m) => m.uid), contains('pending'));
        expect(rows.map((m) => m.uid), isNot(contains('m0')));
        expect(rows.map((m) => m.uid), contains('m200'));
      },
    );

    test('the queue returns Pending rows oldest first', () async {
      await seedThread();
      await helper.cacheMessages([
        _msg('m1', sender: 'u1', synced: false),
        _msg('m2', sender: 'u1', sentAt: _t1, synced: false),
        _msg('m3', sentAt: _t1, synced: false),
        _msg('m4', sender: 'u1', sentAt: _t3),
      ], fromCloud: false);

      expect((await helper.getQueuedMessages('u1')).map((m) => m.uid), [
        'm2',
        'm1',
      ]);
      expect(await helper.getQueuedMessages(''), isEmpty);
    });

    test("unread counts others' messages past the cursor", () async {
      await seedThread();
      await helper.cacheMessages([
        _msg('m1'),
        _msg('m2', sentAt: _t3),
        _msg('m3', sender: 'u1', sentAt: _t3),
        _msg('m4', sentAt: _t3, status: 'Withheld'),
      ], fromCloud: true);
      when(
        () => remote.updateCursor(
          conversationUid: any(named: 'conversationUid'),
          uid: any(named: 'uid'),
          lastReadAt: any(named: 'lastReadAt'),
        ),
      ).thenAnswer((_) async {});
      await helper.moveCursor('u1', 'c1', _t1);

      expect(await helper.unreadCount('u1', 'c1'), 2);

      await helper.moveCursor('u1', 'c1', _t3);
      expect(await helper.unreadCount('u1', 'c1'), 0);
    });
  });

  group('queue and replay', () {
    test('a text message sends at once and caches the echo', () async {
      await seedThread();
      when(
        () => remote.createTextMessage(
          conversationUid: 'c1',
          messageUid: any(named: 'messageUid'),
          senderUid: 'u1',
          text: 'hi',
          sentAt: any(named: 'sentAt'),
        ),
      ).thenAnswer((_) async {});
      when(() => remote.fetchMessages(conversationUid: 'c1')).thenAnswer(
        (i) async => [
          _msg(
            // The echo carries the queued uid; the helper finds it by id.
            (await helper.getQueuedMessages('u1')).single.uid,
            sender: 'u1',
            status: 'Delivered',
            stamp: _t3,
          ),
        ],
      );

      final sent = await helper.queueTextMessage(
        conversationUid: 'c1',
        senderUid: 'u1',
        text: 'hi',
      );

      expect(sent.status, 'Delivered');
      expect(sent.synced, isTrue);
      verify(
        () => remote.createTextMessage(
          conversationUid: 'c1',
          messageUid: any(named: 'messageUid'),
          senderUid: 'u1',
          text: 'hi',
          sentAt: any(named: 'sentAt'),
        ),
      ).called(1);
    });

    test('an offline text stays queued without throwing', () async {
      await seedThread();
      when(
        () => remote.createTextMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          text: any(named: 'text'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenThrow(AppError.noInternet);

      final queued = await helper.queueTextMessage(
        conversationUid: 'c1',
        senderUid: 'u1',
        text: 'hi',
      );

      expect(queued.status, 'Pending');
      expect(queued.synced, isFalse);
      expect((await helper.getQueuedMessages('u1')).map((m) => m.uid), [
        queued.uid,
      ]);
      verifyNever(
        () => remote.fetchMessages(
          conversationUid: any(named: 'conversationUid'),
        ),
      );
    });

    test('a voice message keeps its local path through the echo', () async {
      await seedThread();
      final file = File('${dir.path}/note.m4a')..writeAsBytesSync([1, 2, 3]);
      when(
        () => remote.createVoiceMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          bytes: any(named: 'bytes'),
          contentType: any(named: 'contentType'),
          durationMs: any(named: 'durationMs'),
          voicePeaks: any(named: 'voicePeaks'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenAnswer((_) async {});
      when(() => remote.fetchMessages(conversationUid: 'c1')).thenAnswer(
        (_) async => [
          _msg(
            (await helper.getQueuedMessages('u1')).single.uid,
            sender: 'u1',
            stamp: _t3,
          ),
        ],
      );

      final sent = await helper.queueVoiceMessage(
        conversationUid: 'c1',
        senderUid: 'u1',
        localPath: file.path,
        durationMs: 5000,
        voicePeaks: const [10, 20],
      );

      expect(sent.synced, isTrue);
      expect(sent.localAttachmentPath, file.path);
      final captured =
          verify(
                () => remote.createVoiceMessage(
                  conversationUid: 'c1',
                  messageUid: any(named: 'messageUid'),
                  senderUid: 'u1',
                  bytes: captureAny(named: 'bytes'),
                  contentType: 'audio/mp4',
                  durationMs: 5000,
                  voicePeaks: const [10, 20],
                  sentAt: any(named: 'sentAt'),
                ),
              ).captured.single
              as List<int>;
      expect(captured, [1, 2, 3]);
    });

    test('a voice message without its recording fails visibly', () async {
      await seedThread();

      await expectLater(
        helper.queueVoiceMessage(
          conversationUid: 'c1',
          senderUid: 'u1',
          localPath: '${dir.path}/missing.m4a',
          durationMs: 5000,
          voicePeaks: const [10],
        ),
        throwsA(AppError.dataNotFound),
      );

      final rows = await helper.getMessages('u1', 'c1');
      expect(rows.single.status, 'Failed');
      expect(rows.single.synced, isTrue);
      verifyNever(
        () => remote.createVoiceMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          bytes: any(named: 'bytes'),
          contentType: any(named: 'contentType'),
          durationMs: any(named: 'durationMs'),
          voicePeaks: any(named: 'voicePeaks'),
          sentAt: any(named: 'sentAt'),
        ),
      );
    });

    test('a refused send drops for the server truth', () async {
      await seedThread();
      when(
        () => remote.createTextMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          text: any(named: 'text'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenThrow(AppError.noInternet);
      final queued = await helper.queueTextMessage(
        conversationUid: 'c1',
        senderUid: 'u1',
        text: 'hi',
      );
      when(
        () => remote.createTextMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          text: any(named: 'text'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => remote.fetchMessages(conversationUid: 'c1'),
      ).thenAnswer((_) async => [_msg(queued.uid, sender: 'u1', stamp: _t3)]);

      await expectLater(
        helper.replayPendingMessages('u1'),
        throwsA(AppError.permissionDenied),
      );

      final rows = await helper.getMessages('u1', 'c1');
      expect(rows.single.status, 'Sent');
      expect(rows.single.synced, isTrue);
    });

    test('a denied refetch evicts the queued message', () async {
      await seedThread();
      when(
        () => remote.createTextMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          text: any(named: 'text'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenThrow(AppError.noInternet);
      await helper.queueTextMessage(
        conversationUid: 'c1',
        senderUid: 'u1',
        text: 'hi',
      );
      when(
        () => remote.createTextMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          text: any(named: 'text'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => remote.fetchMessages(
          conversationUid: any(named: 'conversationUid'),
        ),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.replayPendingMessages('u1'),
        throwsA(AppError.permissionDenied),
      );

      expect(await helper.getMessages('u1', 'c1'), isEmpty);
    });

    test(
      'a refused send the server never saw fails but keeps the words',
      () async {
        await seedThread();
        when(
          () => remote.createTextMessage(
            conversationUid: any(named: 'conversationUid'),
            messageUid: any(named: 'messageUid'),
            senderUid: any(named: 'senderUid'),
            text: any(named: 'text'),
            sentAt: any(named: 'sentAt'),
          ),
        ).thenThrow(AppError.noInternet);
        await helper.queueTextMessage(
          conversationUid: 'c1',
          senderUid: 'u1',
          text: 'unsent words',
        );
        when(
          () => remote.createTextMessage(
            conversationUid: any(named: 'conversationUid'),
            messageUid: any(named: 'messageUid'),
            senderUid: any(named: 'senderUid'),
            text: any(named: 'text'),
            sentAt: any(named: 'sentAt'),
          ),
        ).thenThrow(AppError.dataNotFound);
        when(
          () => remote.fetchMessages(conversationUid: 'c1'),
        ).thenAnswer((_) async => <MessageModel>[]);

        await expectLater(
          helper.replayPendingMessages('u1'),
          throwsA(AppError.dataNotFound),
        );

        final rows = await helper.getMessages('u1', 'c1');
        expect(rows.single.status, 'Failed');
        expect(rows.single.text, 'unsent words');
      },
    );

    test('a transient replay failure stays queued', () async {
      await seedThread();
      when(
        () => remote.createTextMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
          senderUid: any(named: 'senderUid'),
          text: any(named: 'text'),
          sentAt: any(named: 'sentAt'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      await helper.queueTextMessage(
        conversationUid: 'c1',
        senderUid: 'u1',
        text: 'hi',
      );
      await expectLater(
        helper.replayPendingMessages('u1'),
        throwsA(AppError.serviceUnavailable),
      );

      final queued = await helper.getQueuedMessages('u1');
      expect(queued, hasLength(1));
      expect(queued.single.status, 'Pending');
    });
  });

  group('withdraw', () {
    test('a withdraw clears the text, transcripts and local file', () async {
      await seedThread();
      final file = File('${dir.path}/note.m4a')..writeAsBytesSync([1]);
      await helper.cacheMessages([
        _msg(
          'm1',
          sender: 'u1',
          text: 'voice note',
        ).copyWith(localAttachmentPath: file.path),
      ], fromCloud: true);
      await helper.cacheTranscripts(
        [_transcript('m1', kind: 'machine', sender: 'u1')],
        fromCloud: true,
        viewerUid: 'u1',
        viewerRole: .patient,
      );
      when(
        () => remote.withdrawMessage(conversationUid: 'c1', messageUid: 'm1'),
      ).thenAnswer((_) async => <String, dynamic>{});

      await helper.withdrawMessage(
        conversationUid: 'c1',
        messageUid: 'm1',
        senderUid: 'u1',
      );

      final rows = await helper.getMessages('u1', 'c1');
      expect(rows.single.status, 'Withheld');
      expect(rows.single.text, isEmpty);
      expect(
        await helper.getTranscript('m1', 'machine', 'u1', .patient),
        isNull,
      );
      expect(file.existsSync(), isFalse);
      verify(
        () => remote.withdrawMessage(conversationUid: 'c1', messageUid: 'm1'),
      ).called(1);
    });

    test("a non-sender's withdraw is refused without a round trip", () async {
      await seedThread();
      await helper.cacheMessages([_msg('m1')], fromCloud: true);

      await expectLater(
        helper.withdrawMessage(
          conversationUid: 'c1',
          messageUid: 'm1',
          senderUid: 'u1',
        ),
        throwsA(AppError.permissionDenied),
      );
      verifyNever(
        () => remote.withdrawMessage(
          conversationUid: any(named: 'conversationUid'),
          messageUid: any(named: 'messageUid'),
        ),
      );
    });
  });

  group('cursors', () {
    test('a cursor moves forward locally and remotely', () async {
      await seedThread();
      when(
        () => remote.updateCursor(
          conversationUid: 'c1',
          uid: 'u1',
          lastReadAt: _t2,
        ),
      ).thenAnswer((_) async {});

      final moved = await helper.moveCursor('u1', 'c1', _t2);

      expect(moved.lastReadAt, _t2);
      expect(moved.synced, isTrue);
      expect((await helper.getCursor('u1', 'c1'))?.lastReadAt, _t2);
    });

    test('a backward move is a no-op', () async {
      await seedThread();
      when(
        () => remote.updateCursor(
          conversationUid: any(named: 'conversationUid'),
          uid: any(named: 'uid'),
          lastReadAt: any(named: 'lastReadAt'),
        ),
      ).thenAnswer((_) async {});
      await helper.moveCursor('u1', 'c1', _t3);
      clearInteractions(remote);

      final kept = await helper.moveCursor('u1', 'c1', _t1);

      expect(kept.lastReadAt, _t3);
      verifyNever(
        () => remote.updateCursor(
          conversationUid: any(named: 'conversationUid'),
          uid: any(named: 'uid'),
          lastReadAt: any(named: 'lastReadAt'),
        ),
      );
    });

    test('an offline move stays queued, then replays', () async {
      await seedThread();
      when(
        () => remote.updateCursor(
          conversationUid: any(named: 'conversationUid'),
          uid: any(named: 'uid'),
          lastReadAt: any(named: 'lastReadAt'),
        ),
      ).thenThrow(AppError.noInternet);

      final moved = await helper.moveCursor('u1', 'c1', _t2);
      expect(moved.synced, isFalse);

      when(
        () => remote.updateCursor(
          conversationUid: any(named: 'conversationUid'),
          uid: any(named: 'uid'),
          lastReadAt: any(named: 'lastReadAt'),
        ),
      ).thenAnswer((_) async {});
      await helper.replayPendingCursors('u1');

      expect((await helper.getCursor('u1', 'c1'))?.synced, isTrue);
    });

    test('a cloud cursor never moves the local one backward', () async {
      await seedThread();
      when(
        () => remote.updateCursor(
          conversationUid: any(named: 'conversationUid'),
          uid: any(named: 'uid'),
          lastReadAt: any(named: 'lastReadAt'),
        ),
      ).thenAnswer((_) async {});
      await helper.moveCursor('u1', 'c1', _t3);
      when(
        () => remote.fetchCursor(conversationUid: 'c1', uid: 'u1'),
      ).thenAnswer(
        (_) async => ConversationCursorModel.empty().copyWith(
          uid: 'u1',
          conversationUid: 'c1',
          lastReadAt: _t1,
          lastUpdatedAt: _t4,
        ),
      );

      await helper.syncCursor('u1', 'c1');

      expect((await helper.getCursor('u1', 'c1'))?.lastReadAt, _t3);
    });

    test('a denied cursor refetch evicts the row', () async {
      await seedThread();
      when(
        () => remote.updateCursor(
          conversationUid: any(named: 'conversationUid'),
          uid: any(named: 'uid'),
          lastReadAt: any(named: 'lastReadAt'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => remote.fetchCursor(conversationUid: 'c1', uid: 'u1'),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.moveCursor('u1', 'c1', _t2),
        throwsA(AppError.permissionDenied),
      );
      expect(await helper.getCursor('u1', 'c1'), isNull);
    });
  });

  group('transcripts', () {
    test('a patient caches shared, never machine', () async {
      await helper.cacheTranscripts(
        [_transcript('m1'), _transcript('m1', kind: 'machine')],
        fromCloud: true,
        viewerUid: 'u1',
        viewerRole: .patient,
      );

      expect(
        Hive.box<MessageTranscriptHive>(
          HiveHelperImpl.messageTranscriptsBox,
        ).keys,
        ['m1_shared'],
      );
    });

    test('the sender keeps their own machine transcript', () async {
      await helper.cacheTranscripts(
        [_transcript('m1', kind: 'machine', sender: 'u1')],
        fromCloud: true,
        viewerUid: 'u1',
        viewerRole: .patient,
      );

      final row = Hive.box<MessageTranscriptHive>(
        HiveHelperImpl.messageTranscriptsBox,
      ).get('m1_machine');
      expect(row?.text, 'transcript text');
    });

    test('a clinician caches a machine transcript', () async {
      await helper.cacheTranscripts(
        [_transcript('m1', kind: 'machine')],
        fromCloud: true,
        viewerUid: 'd1',
        viewerRole: .doctor,
      );

      final row = Hive.box<MessageTranscriptHive>(
        HiveHelperImpl.messageTranscriptsBox,
      ).get('m1_machine');
      expect(row?.text, 'transcript text');
    });

    test('reads gate machine transcripts by viewer', () async {
      await helper.cacheConversations([
        _conv('c1', members: ['u1', 'u2']),
      ], fromCloud: true);
      await helper.cacheTranscripts(
        [_transcript('m1', kind: 'machine'), _transcript('m1')],
        fromCloud: true,
        viewerUid: 'd1',
        viewerRole: .doctor,
      );

      // A patient reads the sender's shared text, never the machine text.
      expect(
        (await helper.getTranscript('m1', 'shared', 'u1', .patient))?.text,
        'transcript text',
      );
      expect(
        await helper.getTranscript('m1', 'machine', 'u1', .patient),
        isNull,
      );
      // A stranger reads nothing at all.
      expect(
        await helper.getTranscript('m1', 'shared', 'u9', .patient),
        isNull,
      );
      expect(await helper.getTranscript('m1', 'draft', 'u1', .patient), isNull);
    });
  });

  group('thread cursors', () {
    test('cursors trail the newest cached row by a day', () async {
      await helper.cacheConversations([
        _conv('c1'),
        _conv('c2', stamp: _t2, members: ['u1']),
      ], fromCloud: true);
      await helper.cacheMessages([_msg('m1', stamp: _t3)], fromCloud: true);

      expect(await helper.conversationCursor('u1'), '2026-11-01T10:00:00.000Z');
      expect(
        await helper.messageCursor('u1', 'c1'),
        '2026-11-02T10:00:00.000Z',
      );
      expect(await helper.messageCursor('u9', 'c1'), isNull);
    });
  });
}
