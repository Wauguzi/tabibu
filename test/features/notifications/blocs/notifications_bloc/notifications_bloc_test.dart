import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/notifications/data/cache/notification_cache_helper.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

class _MockCache extends Mock implements NotificationCacheHelper {}

NotificationModel _note(
  String uid, {
  String status = 'Unread',
  String created = '2026-11-01T12:00:00.000Z',
}) => NotificationModel.empty().copyWith(
  uid: uid,
  recipientUid: 'u1',
  status: status,
  creationDate: created,
);

void main() {
  late _MockCache cache;

  NotificationsBloc build() => NotificationsBloc(cache: cache);

  setUp(() {
    cache = _MockCache();
  });

  group('NotificationsBloc', () {
    test('starts empty', () {
      expect(build().state, const NotificationsInitial());
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'drops its data on reset',
      build: build,
      seed: () => const NotificationsLoadSuccess(unread: 3),
      act: (bloc) => bloc.add(const NotificationsReset()),
      expect: () => [const NotificationsInitial()],
    );

    group('NotificationsRequested', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'with a cache emits success, then the synced rows',
        setUp: () {
          when(
            () => cache.getInbox('u1'),
          ).thenAnswer((_) async => [_note('n1'), _note('n2')]);
          when(() => cache.unreadCount('u1')).thenAnswer((_) async => 2);
          when(
            () => cache.syncInbox('u1'),
          ).thenAnswer((_) async => [_note('n1'), _note('n2'), _note('n3')]);
        },
        build: build,
        act: (bloc) => bloc.add(const NotificationsRequested(uid: 'u1')),
        expect: () => [
          const NotificationsLoadInProgress(),
          NotificationsLoadSuccess(
            items: [_note('n1'), _note('n2')],
            unread: 2,
          ),
          NotificationsLoadSuccess(
            items: [_note('n1'), _note('n2'), _note('n3')],
            unread: 2,
          ),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'with an empty cache skips the first success',
        setUp: () {
          when(() => cache.getInbox('u1')).thenAnswer((_) async => []);
          when(
            () => cache.syncInbox('u1'),
          ).thenAnswer((_) async => [_note('n1')]);
          when(() => cache.unreadCount('u1')).thenAnswer((_) async => 1);
        },
        build: build,
        act: (bloc) => bloc.add(const NotificationsRequested(uid: 'u1')),
        expect: () => [
          const NotificationsLoadInProgress(),
          NotificationsLoadSuccess(items: [_note('n1')], unread: 1),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'offline with a cache keeps the rows and sets offline',
        setUp: () {
          when(
            () => cache.getInbox('u1'),
          ).thenAnswer((_) async => [_note('n1')]);
          when(() => cache.unreadCount('u1')).thenAnswer((_) async => 1);
          when(() => cache.syncInbox('u1')).thenThrow(AppError.noInternet);
        },
        build: build,
        act: (bloc) => bloc.add(const NotificationsRequested(uid: 'u1')),
        expect: () => [
          const NotificationsLoadInProgress(),
          NotificationsLoadSuccess(items: [_note('n1')], unread: 1),
          NotificationsLoadSuccess(
            items: [_note('n1')],
            unread: 1,
            offline: true,
          ),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'offline with an empty cache fails',
        setUp: () {
          when(() => cache.getInbox('u1')).thenAnswer((_) async => []);
          when(
            () => cache.syncInbox('u1'),
          ).thenThrow(AppError.serviceUnavailable);
        },
        build: build,
        act: (bloc) => bloc.add(const NotificationsRequested(uid: 'u1')),
        expect: () => [
          const NotificationsLoadInProgress(),
          const NotificationsLoadFailure(error: AppError.serviceUnavailable),
        ],
      );
    });

    group('NotificationsRefreshed', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'syncs and emits success',
        setUp: () {
          when(
            () => cache.syncInbox('u1'),
          ).thenAnswer((_) async => [_note('n1')]);
          when(() => cache.unreadCount('u1')).thenAnswer((_) async => 1);
        },
        build: build,
        seed: () => NotificationsLoadSuccess(items: [_note('n0')], unread: 1),
        act: (bloc) => bloc.add(const NotificationsRefreshed(uid: 'u1')),
        expect: () => [
          NotificationsLoadInProgress(items: [_note('n0')], unread: 1),
          NotificationsLoadSuccess(items: [_note('n1')], unread: 1),
        ],
      );
    });

    group('NotificationReadRequested', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'marks unread and replaces the row',
        setUp: () {
          when(
            () => cache.markRead('u1', 'n1'),
          ).thenAnswer((_) async => _note('n1', status: 'Read'));
          when(() => cache.unreadCount('u1')).thenAnswer((_) async => 1);
        },
        build: build,
        seed: () => NotificationsLoadSuccess(
          items: [_note('n1'), _note('n2')],
          unread: 2,
        ),
        act: (bloc) => bloc.add(
          const NotificationReadRequested(uid: 'u1', notificationUid: 'n1'),
        ),
        expect: () => [
          NotificationsLoadSuccess(
            items: [
              _note('n1', status: 'Read'),
              _note('n2'),
            ],
            unread: 1,
          ),
        ],
        verify: (_) {
          verify(() => cache.markRead('u1', 'n1')).called(1);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'a read queued offline keeps the offline flag',
        setUp: () {
          when(
            () => cache.markRead('u1', 'n1'),
          ).thenAnswer((_) async => _note('n1', status: 'Read'));
          when(() => cache.unreadCount('u1')).thenAnswer((_) async => 0);
        },
        build: build,
        seed: () => NotificationsLoadSuccess(
          items: [_note('n1')],
          unread: 1,
          offline: true,
        ),
        act: (bloc) => bloc.add(
          const NotificationReadRequested(uid: 'u1', notificationUid: 'n1'),
        ),
        expect: () => [
          NotificationsLoadSuccess(
            items: [_note('n1', status: 'Read')],
            offline: true,
          ),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'already read does nothing',
        build: build,
        seed: () =>
            NotificationsLoadSuccess(items: [_note('n1', status: 'Read')]),
        act: (bloc) => bloc.add(
          const NotificationReadRequested(uid: 'u1', notificationUid: 'n1'),
        ),
        expect: () => <NotificationsState>[],
        verify: (_) {
          verifyNever(() => cache.markRead(any(), any()));
        },
      );
    });

    group('NotificationsAllReadRequested', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'marks every unread row and emits once',
        setUp: () {
          when(
            () => cache.markRead('u1', 'n1'),
          ).thenAnswer((_) async => _note('n1', status: 'Read'));
          when(
            () => cache.markRead('u1', 'n2'),
          ).thenAnswer((_) async => _note('n2', status: 'Read'));
          when(() => cache.getInbox('u1')).thenAnswer(
            (_) async => [
              _note('n1', status: 'Read'),
              _note('n2', status: 'Read'),
              _note('n3', status: 'Read'),
            ],
          );
          when(() => cache.unreadCount('u1')).thenAnswer((_) async => 0);
        },
        build: build,
        seed: () => NotificationsLoadSuccess(
          items: [
            _note('n1'),
            _note('n2'),
            _note('n3', status: 'Read'),
          ],
          unread: 2,
        ),
        act: (bloc) => bloc.add(const NotificationsAllReadRequested(uid: 'u1')),
        expect: () => [
          NotificationsLoadSuccess(
            items: [
              _note('n1', status: 'Read'),
              _note('n2', status: 'Read'),
              _note('n3', status: 'Read'),
            ],
          ),
        ],
        verify: (_) {
          verify(() => cache.markRead('u1', 'n1')).called(1);
          verify(() => cache.markRead('u1', 'n2')).called(1);
          verifyNever(() => cache.markRead('u1', 'n3'));
        },
      );
    });

    group('failures', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'a non-offline failure keeps the data',
        setUp: () {
          when(
            () => cache.syncInbox('u1'),
          ).thenThrow(AppError.permissionDenied);
        },
        build: build,
        seed: () => NotificationsLoadSuccess(items: [_note('n1')], unread: 1),
        act: (bloc) => bloc.add(const NotificationsRefreshed(uid: 'u1')),
        expect: () => [
          NotificationsLoadInProgress(items: [_note('n1')], unread: 1),
          NotificationsLoadFailure(
            error: AppError.permissionDenied,
            items: [_note('n1')],
            unread: 1,
          ),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'reset after success clears the inbox',
        build: build,
        seed: () => NotificationsLoadSuccess(items: [_note('n1')], unread: 1),
        act: (bloc) => bloc.add(const NotificationsReset()),
        expect: () => [const NotificationsInitial()],
      );
    });
  });
}
