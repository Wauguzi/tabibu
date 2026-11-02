import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/notifications/data/cache/notification_cache_helper.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';

/// The signed-in user's inbox, newest first.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({NotificationCacheHelper? cache})
    : _cache = cache ?? getIt<NotificationCacheHelper>(),
      super(const NotificationsInitial()) {
    // Cache first, then a silent sync; a second open while loading is
    // pointless.
    on<NotificationsRequested>(_onRequested, transformer: droppable());
    // Sync first: pull-to-refresh.
    on<NotificationsRefreshed>(_onRefreshed, transformer: droppable());
    // Writes must not race each other.
    on<NotificationReadRequested>(_onRead, transformer: sequential());
    on<NotificationsAllReadRequested>(_onAllRead, transformer: sequential());
    // Live inbox: restartable so a second start replaces the first; stop
    // closes the bridge controller that feed `emit.forEach`.
    on<NotificationsWatchStarted>(_onWatchStarted, transformer: restartable());
    on<NotificationsWatchStopped>(_onWatchStopped);
    on<NotificationsReset>(_onReset);
  }

  final NotificationCacheHelper _cache;

  /// Bridge from the cache watch into `emit.forEach`. Closing it ends the
  /// running watch handler (stop / reset / close / restart).
  StreamController<void>? _watchBridge;
  StreamSubscription<void>? _watchSub;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  NotificationsLoadInProgress _inProgress() => NotificationsLoadInProgress(
    items: state.items,
    unread: state.unread,
    offline: state.offline,
  );

  NotificationsLoadFailure _failure(Object e) => NotificationsLoadFailure(
    error: _toAppError(e),
    items: state.items,
    unread: state.unread,
    offline: state.offline,
  );

  Future<NotificationsLoadSuccess> _success(
    String uid,
    List<NotificationModel> items, {
    bool offline = false,
  }) async => NotificationsLoadSuccess(
    items: items,
    unread: await _cache.unreadCount(uid),
    offline: offline,
  );

  // The Firestore listener is cancelled explicitly: closing the bridge ends
  // the handler but is not guaranteed to cancel what feeds it.
  Future<void> _closeWatchBridge() async {
    await _watchSub?.cancel();
    _watchSub = null;
    final bridge = _watchBridge;
    _watchBridge = null;
    if (bridge != null && !bridge.isClosed) {
      await bridge.close();
    }
  }

  Future<void> _onWatchStarted(
    NotificationsWatchStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    await _closeWatchBridge();
    final bridge = StreamController<void>();
    _watchBridge = bridge;
    // A listener error never reaches the handler: it would end live updates.
    _watchSub = _cache
        .watchInbox(event.uid)
        .listen(bridge.add, onError: (Object _) {}, onDone: bridge.close);

    await emit.forEach<NotificationsLoadSuccess>(
      bridge.stream.asyncMap((_) async {
        final items = await _cache.getInbox(event.uid);
        return await _success(event.uid, items, offline: state.offline);
      }),
      onData: (next) => next,
    );
  }

  Future<void> _onWatchStopped(
    NotificationsWatchStopped event,
    Emitter<NotificationsState> emit,
  ) async {
    await _closeWatchBridge();
  }

  Future<void> _onReset(
    NotificationsReset event,
    Emitter<NotificationsState> emit,
  ) async {
    await _closeWatchBridge();
    emit(const NotificationsInitial());
  }

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(_inProgress());
    try {
      final cached = await _cache.getInbox(event.uid);
      if (cached.isNotEmpty) {
        emit(await _success(event.uid, cached));
      }
      try {
        final synced = await _cache.syncInbox(event.uid);
        emit(await _success(event.uid, synced));
      } on Object catch (e) {
        final error = _toAppError(e);
        if (_offline.contains(error)) {
          final items = cached.isNotEmpty ? cached : state.items;
          if (items.isEmpty) {
            emit(_failure(error));
            return;
          }
          emit(await _success(event.uid, items, offline: true));
          return;
        }
        emit(_failure(error));
      }
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(_inProgress());
    try {
      final synced = await _cache.syncInbox(event.uid);
      emit(await _success(event.uid, synced));
    } on Object catch (e) {
      final error = _toAppError(e);
      if (_offline.contains(error) && state.items.isNotEmpty) {
        emit(await _success(event.uid, state.items, offline: true));
        return;
      }
      emit(_failure(error));
    }
  }

  Future<void> _onRead(
    NotificationReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    NotificationModel? current;
    for (final row in state.items) {
      if (row.uid == event.notificationUid) {
        current = row;
        break;
      }
    }
    if (current == null || current.isRead) return;

    try {
      final updated = await _cache.markRead(event.uid, event.notificationUid);
      final items = [
        for (final row in state.items)
          if (row.uid == updated.uid) updated else row,
      ];
      // A read queued offline keeps the offline banner up.
      emit(await _success(event.uid, items, offline: state.offline));
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onAllRead(
    NotificationsAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final unread = [
      for (final row in state.items)
        if (!row.isRead) row,
    ];
    try {
      for (final row in unread) {
        await _cache.markRead(event.uid, row.uid);
      }
      emit(
        await _success(
          event.uid,
          await _cache.getInbox(event.uid),
          offline: state.offline,
        ),
      );
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  @override
  Future<void> close() => _closeWatchBridge().then((_) => super.close());
}
