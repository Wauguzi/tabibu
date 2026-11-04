import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/db_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/notifications/data/cache/notification_cache_helper.dart';
import 'package:tabibu/features/notifications/data/datasources/notification_firebase.dart';
import 'package:tabibu/features/notifications/data/models/notification_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_hive.dart';
import 'package:tabibu/features/notifications/data/models/notification_metadata_model.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

class _MockNotificationFirebase extends Mock implements NotificationFirebase {}

class _ThrowingDb extends Fake implements DBHelper {
  _ThrowingDb(this._inner, {required this.failPuts});

  final DBHelper _inner;
  bool failPuts;

  @override
  Future<List<T>> getAll<T>(String box) => _inner.getAll<T>(box);

  @override
  Future<T?> get<T>(String box, String key) => _inner.get<T>(box, key);

  @override
  Future<void> put<T>(String box, String key, T value) =>
      _inner.put<T>(box, key, value);

  @override
  Future<void> putAll<T>(String box, Map<String, T> entries) {
    if (failPuts) throw Exception('merge failed');
    return _inner.putAll<T>(box, entries);
  }

  @override
  Future<void> delete<T>(String box, String key) => _inner.delete<T>(box, key);
}

const _t1 = '2026-11-01T10:00:00.000Z';
const _t2 = '2026-11-02T10:00:00.000Z';
const _t3 = '2026-11-03T10:00:00.000Z';

NotificationModel _note(
  String uid, {
  String recipient = 'u1',
  String created = _t1,
  String stamp = _t1,
  bool synced = true,
  String status = 'Unread',
  String title = 'title',
}) => NotificationModel.empty().copyWith(
  uid: uid,
  recipientUid: recipient,
  creationDate: created,
  lastUpdatedAt: stamp,
  synced: synced,
  status: status,
  title: title,
);

void main() {
  late Directory dir;
  late _MockNotificationFirebase remote;
  late NotificationCacheHelper helper;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(40)) {
      Hive.registerAdapter(NotificationHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(41)) {
      Hive.registerAdapter(NotificationMetadataHiveAdapter());
    }
  });

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('tabibu_note_cache_');
    Hive.init(dir.path);
    await Hive.openBox<NotificationHive>(HiveHelperImpl.notificationsBox);
    remote = _MockNotificationFirebase();
    helper = NotificationCacheHelper(db: DBHelperImpl(), remote: remote);
  });

  tearDown(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('merge guard', () {
    test('a queued read survives a cloud refresh of its row', () async {
      await helper.cacheNotifications([
        _note('n1', synced: false, status: 'Read').copyWith(readAt: _t2),
      ], fromCloud: false);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_note('n1', stamp: _t3, title: 'new title')]);

      await helper.syncInbox('u1');

      final rows = await helper.getInbox('u1');
      expect(rows.single.status, 'Read');
      expect(rows.single.readAt, _t2);
      expect(rows.single.title, 'new title');
      expect(rows.single.synced, isFalse);
    });

    test('a synced row is replaced by a newer cloud row', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_note('n1', stamp: _t3, title: 'new title')]);

      await helper.syncInbox('u1');

      final rows = await helper.getInbox('u1');
      expect(rows.single.title, 'new title');
      expect(rows.single.synced, isTrue);
    });

    test('a synced row is kept against an older cloud row', () async {
      await helper.cacheNotifications([
        _note('n1', stamp: _t3),
      ], fromCloud: true);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_note('n1', title: 'old title')]);

      await helper.syncInbox('u1');

      expect((await helper.getInbox('u1')).single.title, 'title');
    });
  });

  group('scope', () {
    test("another recipient's rows are never returned", () async {
      await helper.cacheNotifications([
        _note('n1'),
        _note('n2', recipient: 'u2'),
      ], fromCloud: true);

      expect((await helper.getInbox('u1')).map((n) => n.uid), ['n1']);
      expect(await helper.getInbox(''), isEmpty);
      expect(await helper.unreadCount('u2'), 1);
      expect(await helper.getUnsynced('u1'), isEmpty);
    });
  });

  group('remote fails', () {
    test('with a cache it returns the cache', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      expect((await helper.syncInbox('u1')).map((n) => n.uid), ['n1']);
    });

    test('without a cache it rethrows', () async {
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.serviceUnavailable);

      await expectLater(
        helper.syncInbox('u1'),
        throwsA(AppError.serviceUnavailable),
      );
    });

    test('a refusal rethrows even with a cache', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.syncInbox('u1'),
        throwsA(AppError.permissionDenied),
      );
    });
  });

  group('inbox', () {
    test('archived rows stay out; newest first; limit applies', () async {
      await helper.cacheNotifications([
        _note('n1', status: 'Archived'),
        _note('n2'),
        _note('n3', created: _t3),
      ], fromCloud: true);

      expect((await helper.getInbox('u1')).map((n) => n.uid), ['n3', 'n2']);
      expect((await helper.getInbox('u1', limit: 1)).map((n) => n.uid), ['n3']);
    });

    test('unread counts unread rows', () async {
      await helper.cacheNotifications([
        _note('n1'),
        _note('n2', status: 'Read'),
        _note('n3', status: 'Archived'),
      ], fromCloud: true);

      expect(await helper.unreadCount('u1'), 1);
      expect(await helper.unreadCount(''), 0);
    });

    test('actionable rows are pending approvals', () async {
      final approval = const NotificationMetadataModel().copyWith(
        actionType: 'Approval',
        actionStatus: 'Pending',
        expiresAt: '2026-12-01T10:00:00.000Z',
      );
      final expired = approval.copyWith(expiresAt: _t1);
      await helper.cacheNotifications([
        _note('n1').copyWith(metadata: approval),
        _note('n2').copyWith(metadata: expired),
        _note('n3'),
      ], fromCloud: true);

      expect(
        (await helper.getActionable(
          'u1',
          DateTime.utc(2026, 11, 5),
        )).map((n) => n.uid),
        ['n1'],
      );
    });

    test('a repeat local upsert overwrites by id', () async {
      await helper.upsertLocal(
        NotificationModel.local(
          uid: 'local1',
          recipientUid: 'u1',
          templateKey: 'k',
          templateArgs: const {},
          category: 'c',
          resourceType: 'r',
          resourceUid: 'res',
          creationDate: _t1,
          title: 'first',
        ),
      );
      await helper.upsertLocal(
        NotificationModel.local(
          uid: 'local1',
          recipientUid: 'u1',
          templateKey: 'k',
          templateArgs: const {},
          category: 'c',
          resourceType: 'r',
          resourceUid: 'res',
          creationDate: _t1,
          title: 'second',
        ),
      );

      final rows = await helper.getInbox('u1');
      expect(rows, hasLength(1));
      expect(rows.single.title, 'second');
      expect(rows.single.isLocalOnly, isTrue);
    });

    test('local rows never move the cursor', () async {
      await helper.upsertLocal(
        NotificationModel.local(
          uid: 'local1',
          recipientUid: 'u1',
          templateKey: 'k',
          templateArgs: const {},
          category: 'c',
          resourceType: 'r',
          resourceUid: 'res',
          creationDate: _t3,
        ),
      );

      expect(await helper.cursor('u1'), isNull);

      await helper.cacheNotifications([
        _note('n1', stamp: _t3),
      ], fromCloud: true);
      expect(await helper.cursor('u1'), '2026-11-02T10:00:00.000Z');
    });
  });

  group('mark read', () {
    test('a read sends and marks the row synced', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.markRead(
          notificationUid: 'n1',
          readAt: any(named: 'readAt'),
        ),
      ).thenAnswer((_) async {});

      final read = await helper.markRead('u1', 'n1');

      expect(read.status, 'Read');
      expect(read.readAt, isNotEmpty);
      expect(read.synced, isTrue);
      verify(
        () => remote.markRead(
          notificationUid: 'n1',
          readAt: any(named: 'readAt'),
        ),
      ).called(1);
    });

    test('an offline read stays queued without throwing', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.markRead(
          notificationUid: any(named: 'notificationUid'),
          readAt: any(named: 'readAt'),
        ),
      ).thenThrow(AppError.noInternet);

      final read = await helper.markRead('u1', 'n1');

      expect(read.status, 'Read');
      expect(read.synced, isFalse);
      expect((await helper.getUnsynced('u1')).map((n) => n.uid), ['n1']);
    });

    test('a local-only read is never sent', () async {
      await helper.upsertLocal(
        NotificationModel.local(
          uid: 'local1',
          recipientUid: 'u1',
          templateKey: 'k',
          templateArgs: const {},
          category: 'c',
          resourceType: 'r',
          resourceUid: 'res',
          creationDate: _t1,
        ),
      );

      final read = await helper.markRead('u1', 'local1');

      expect(read.status, 'Read');
      expect(read.synced, isTrue);
      verifyNever(
        () => remote.markRead(
          notificationUid: any(named: 'notificationUid'),
          readAt: any(named: 'readAt'),
        ),
      );
    });

    test("another recipient's row cannot be marked", () async {
      await helper.cacheNotifications([
        _note('n1', recipient: 'u2'),
      ], fromCloud: true);

      await expectLater(
        helper.markRead('u1', 'n1'),
        throwsA(AppError.dataNotFound),
      );
      await expectLater(
        helper.markRead('u1', 'missing'),
        throwsA(AppError.dataNotFound),
      );
    });

    test('a refused read drops for the server truth', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.markRead(
          notificationUid: any(named: 'notificationUid'),
          readAt: any(named: 'readAt'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => [_note('n1', stamp: _t3, status: 'Archived')]);

      await expectLater(
        helper.markRead('u1', 'n1'),
        throwsA(AppError.permissionDenied),
      );

      // Archived rows leave the inbox, but the row itself is server truth.
      expect(await helper.getInbox('u1'), isEmpty);
      final box = Hive.box<NotificationHive>(HiveHelperImpl.notificationsBox);
      expect(box.get('n1')?.status, 'Archived');
      expect(box.get('n1')?.synced, isTrue);
    });

    test('a denied refetch evicts the row', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.markRead(
          notificationUid: any(named: 'notificationUid'),
          readAt: any(named: 'readAt'),
        ),
      ).thenThrow(AppError.dataNotFound);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.permissionDenied);

      await expectLater(
        helper.markRead('u1', 'n1'),
        throwsA(AppError.dataNotFound),
      );

      final box = Hive.box<NotificationHive>(HiveHelperImpl.notificationsBox);
      expect(box.get('n1'), isNull);
    });

    test('an offline refetch after a refusal keeps the row', () async {
      await helper.cacheNotifications([_note('n1')], fromCloud: true);
      when(
        () => remote.markRead(
          notificationUid: any(named: 'notificationUid'),
          readAt: any(named: 'readAt'),
        ),
      ).thenThrow(AppError.permissionDenied);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenThrow(AppError.noInternet);

      await expectLater(
        helper.markRead('u1', 'n1'),
        throwsA(AppError.permissionDenied),
      );

      final box = Hive.box<NotificationHive>(HiveHelperImpl.notificationsBox);
      expect(box.get('n1'), isNotNull);
      expect(box.get('n1')?.synced, isFalse);
    });

    test('a transient replay failure stays queued', () async {
      await helper.cacheNotifications([
        _note('n1', synced: false, status: 'Read').copyWith(readAt: _t2),
      ], fromCloud: false);
      when(
        () => remote.markRead(
          notificationUid: any(named: 'notificationUid'),
          readAt: any(named: 'readAt'),
        ),
      ).thenThrow(AppError.requestTimeout);

      await expectLater(
        helper.replayPendingReads('u1'),
        throwsA(AppError.requestTimeout),
      );

      expect((await helper.getUnsynced('u1')).map((n) => n.uid), ['n1']);
    });
  });

  group('prune', () {
    test('synced rows older than 90 days go; queued rows stay', () async {
      await helper.cacheNotifications([
        _note('old', created: '2026-06-01T10:00:00.000Z'),
        _note('recent', created: '2026-10-15T10:00:00.000Z'),
        _note('undated', created: '', stamp: ''),
      ], fromCloud: true);
      await helper.cacheNotifications([
        _note(
          'oldQueued',
          created: '2026-06-01T10:00:00.000Z',
          synced: false,
          status: 'Read',
        ),
      ], fromCloud: false);

      await helper.pruneInbox('u1', now: DateTime.utc(2026, 11, 5));

      final box = Hive.box<NotificationHive>(HiveHelperImpl.notificationsBox);
      expect(box.get('old'), isNull);
      expect(box.get('recent'), isNotNull);
      expect(box.get('oldQueued'), isNotNull);
      expect(box.get('undated'), isNotNull);
    });

    test('pruning is scoped to the syncing recipient', () async {
      await helper.cacheNotifications([
        _note('old', recipient: 'u2', created: '2026-06-01T10:00:00.000Z'),
      ], fromCloud: true);
      when(
        () => remote.fetchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) async => <NotificationModel>[]);

      await helper.syncInbox('u1');

      // Pruning is scoped: u2's row survives u1's sync.
      final box = Hive.box<NotificationHive>(HiveHelperImpl.notificationsBox);
      expect(box.get('old'), isNotNull);
    });
  });

  group('watchInbox', () {
    test('a batch merges and ticks; never evicts', () async {
      await helper.cacheNotifications([
        _note('kept', created: '2026-01-01T10:00:00.000Z'),
      ], fromCloud: true);

      final deltas = StreamController<List<NotificationModel>>();
      when(
        () => remote.watchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) => deltas.stream);

      final ticks = <void>[];
      final ticked = Completer<void>();
      final sub = helper.watchInbox('u1').listen((tick) {
        ticks.add(tick);
        if (!ticked.isCompleted) ticked.complete();
      });

      deltas.add([_note('n2', stamp: _t2, title: 'live')]);
      await ticked.future.timeout(const Duration(seconds: 5));

      expect(ticks, hasLength(1));
      final inbox = await helper.getInbox('u1');
      expect(inbox.map((n) => n.uid), containsAll(['kept', 'n2']));

      await sub.cancel();
      await deltas.close();
    });

    test('a failing merge is skipped and the stream continues', () async {
      final db = _ThrowingDb(DBHelperImpl(), failPuts: true);
      final watching = NotificationCacheHelper(db: db, remote: remote);
      final deltas = StreamController<List<NotificationModel>>();
      when(
        () => remote.watchInboxDelta(
          recipientUid: 'u1',
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((_) => deltas.stream);

      final ticks = <void>[];
      final sub = watching.watchInbox('u1').listen(ticks.add);

      deltas.add([_note('n1', stamp: _t2)]);
      await pumpEventQueue();
      expect(ticks, isEmpty);

      db.failPuts = false;
      deltas.add([_note('n2', stamp: _t3)]);
      await pumpEventQueue();
      expect(ticks, hasLength(1));

      await sub.cancel();
      await deltas.close();
    });
  });
}
