import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/utils/sync_cursor.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_event.dart';
import 'package:tabibu/features/worklist/blocs/desk_bloc/desk_state.dart';
import 'package:tabibu/features/worklist/data/cache/worklist_cache_helper.dart';
import 'package:tabibu/features/worklist/data/cache/worklist_rank.dart';
import 'package:tabibu/features/worklist/data/models/worklist_entry_model.dart';

/// The pathologist's ranked desk, with its filter and search.
class DeskBloc extends Bloc<DeskEvent, DeskState> {
  DeskBloc({WorklistCacheHelper? cache, DateTime Function()? now})
    : _cache = cache ?? getIt<WorklistCacheHelper>(),
      _now = now ?? DateTime.now,
      super(const DeskInitial()) {
    // Cache first, then a silent sync; a second open while loading is
    // pointless.
    on<DeskRequested>(_onRequested, transformer: droppable());
    // Sync first: pull-to-refresh.
    on<DeskRefreshed>(_onRefreshed, transformer: droppable());
    // Only the latest filter / query matters.
    on<DeskFilterChanged>(_onFilterChanged, transformer: restartable());
    on<DeskQueryChanged>(_onQueryChanged, transformer: restartable());
    on<DeskReset>((_, emit) => emit(const DeskInitial()));
  }

  final WorklistCacheHelper _cache;
  final DateTime Function() _now;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  DeskLoadInProgress _inProgress() => DeskLoadInProgress(
    entries: state.entries,
    visible: state.visible,
    filter: state.filter,
    query: state.query,
    offline: state.offline,
  );

  DeskLoadFailure _failure(Object e) => DeskLoadFailure(
    error: _toAppError(e),
    entries: state.entries,
    visible: state.visible,
    filter: state.filter,
    query: state.query,
    offline: state.offline,
  );

  DeskLoadSuccess _success(
    List<WorklistEntryModel> entries, {
    required DeskFilter filter,
    required String query,
    bool offline = false,
  }) => DeskLoadSuccess(
    entries: entries,
    visible: visibleOf(entries, filter: filter, query: query, now: _now()),
    filter: filter,
    query: query,
    offline: offline,
  );

  Future<void> _onRequested(
    DeskRequested event,
    Emitter<DeskState> emit,
  ) async {
    emit(_inProgress());
    try {
      final now = _now();
      final cached = await _cache.getDesk(event.pathologistUid, now: now);
      if (cached.isNotEmpty) {
        emit(_success(cached, filter: state.filter, query: state.query));
      }
      try {
        final synced = await _cache.syncDesk(event.pathologistUid, now: _now());
        emit(_success(synced, filter: state.filter, query: state.query));
      } on Object catch (e) {
        final error = _toAppError(e);
        if (_offline.contains(error)) {
          final entries = cached.isNotEmpty ? cached : state.entries;
          if (entries.isEmpty) {
            emit(_failure(error));
            return;
          }
          emit(
            _success(
              entries,
              filter: state.filter,
              query: state.query,
              offline: true,
            ),
          );
          return;
        }
        emit(_failure(error));
      }
    } on Object catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onRefreshed(
    DeskRefreshed event,
    Emitter<DeskState> emit,
  ) async {
    emit(_inProgress());
    try {
      final synced = await _cache.syncDesk(event.pathologistUid, now: _now());
      emit(_success(synced, filter: state.filter, query: state.query));
    } on Object catch (e) {
      final error = _toAppError(e);
      if (_offline.contains(error) && state.entries.isNotEmpty) {
        emit(
          _success(
            state.entries,
            filter: state.filter,
            query: state.query,
            offline: true,
          ),
        );
        return;
      }
      emit(_failure(error));
    }
  }

  void _onFilterChanged(DeskFilterChanged event, Emitter<DeskState> emit) {
    emit(
      _success(
        state.entries,
        filter: event.filter,
        query: state.query,
        offline: state.offline,
      ),
    );
  }

  void _onQueryChanged(DeskQueryChanged event, Emitter<DeskState> emit) {
    emit(
      _success(
        state.entries,
        filter: state.filter,
        query: event.query,
        offline: state.offline,
      ),
    );
  }
}

/// Open entries matching [filter] / [query], ranked for [now].
List<WorklistEntryModel> visibleOf(
  List<WorklistEntryModel> entries, {
  required DeskFilter filter,
  required String query,
  required DateTime now,
}) {
  final needle = foldForSearch(query);
  final rows = [
    for (final entry in entries)
      if (entry.isOpen)
        if (_passesFilter(entry, filter, now))
          if (needle.isEmpty || _matches(entry, needle)) entry,
  ];
  return WorklistRank.sorted(rows, now);
}

bool _passesFilter(WorklistEntryModel entry, DeskFilter filter, DateTime now) =>
    switch (filter) {
      .all => true,
      .lowConfidence => entry.confidenceBandValue == ConfidenceBand.low,
      .waitingOver4h => _waitingOver4h(entry, now),
      // Malaria is the only notifiable pre-read profile today; the worklist
      // carries no notifiable flag.
      .notifiable => entry.profileValue == PrereadProfile.malaria,
    };

bool _waitingOver4h(WorklistEntryModel entry, DateTime now) {
  final since = parseSyncTimestamp(entry.waitingSince);
  if (since == null) return false;
  return now.toUtc().difference(since) > const Duration(hours: 4);
}

bool _matches(WorklistEntryModel entry, String needle) {
  final order = foldForSearch(entry.orderNumber);
  if (order.contains(needle)) return true;
  if (foldForSearch(entry.testName).contains(needle)) return true;
  return false;
}
