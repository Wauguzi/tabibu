import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/utils/text_fold.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_event.dart';
import 'package:tabibu/features/practitioners/blocs/directory_bloc/directory_state.dart';
import 'package:tabibu/features/practitioners/data/cache/practitioner_cache_helper.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

/// The public directory of practitioners, filtered for the patient's search.
class DirectoryBloc extends Bloc<DirectoryEvent, DirectoryState> {
  DirectoryBloc({PractitionerCacheHelper? cache})
    : _cache = cache ?? getIt<PractitionerCacheHelper>(),
      super(const DirectoryInitial()) {
    // Cache first, then a silent sync; a second open while loading is
    // pointless.
    on<DirectoryRequested>(_onRequested, transformer: droppable());
    // Sync first: pull-to-refresh.
    on<DirectoryRefreshed>(_onRefreshed, transformer: droppable());
    // Keystrokes: only the latest query matters.
    on<DirectoryQueryChanged>(_onQueryChanged, transformer: restartable());
    on<DirectoryReset>((_, emit) => emit(const DirectoryInitial()));
  }

  final PractitionerCacheHelper _cache;

  static const Set<AppError> _offline = {
    .noInternet,
    .serviceUnavailable,
    .requestTimeout,
  };

  AppError _toAppError(Object e) => e is AppError ? e : .unknown;

  DirectoryLoadInProgress _inProgress() => DirectoryLoadInProgress(
    all: state.all,
    visible: state.visible,
    query: state.query,
    specialty: state.specialty,
    offline: state.offline,
  );

  DirectoryLoadFailure _failure(Object e) => DirectoryLoadFailure(
    error: _toAppError(e),
    all: state.all,
    visible: state.visible,
    query: state.query,
    specialty: state.specialty,
    offline: state.offline,
  );

  DirectoryLoadSuccess _success(
    List<PractitionerModel> all, {
    required String query,
    required Specialty? specialty,
    bool offline = false,
  }) => DirectoryLoadSuccess(
    all: all,
    visible: visibleOf(all, query: query, specialty: specialty),
    query: query,
    specialty: specialty,
    offline: offline,
  );

  Future<void> _onRequested(
    DirectoryRequested event,
    Emitter<DirectoryState> emit,
  ) async {
    emit(_inProgress());
    try {
      final cached = await _cache.getPractitioners();
      if (cached.isNotEmpty) {
        emit(_success(cached, query: state.query, specialty: state.specialty));
      }
      try {
        final synced = await _cache.syncPractitioners();
        emit(_success(synced, query: state.query, specialty: state.specialty));
      } on Object catch (e) {
        final error = _toAppError(e);
        if (_offline.contains(error)) {
          final all = cached.isNotEmpty ? cached : state.all;
          if (all.isEmpty) {
            emit(_failure(error));
            return;
          }
          emit(
            _success(
              all,
              query: state.query,
              specialty: state.specialty,
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
    DirectoryRefreshed event,
    Emitter<DirectoryState> emit,
  ) async {
    emit(_inProgress());
    try {
      final synced = await _cache.syncPractitioners();
      emit(_success(synced, query: state.query, specialty: state.specialty));
    } on Object catch (e) {
      final error = _toAppError(e);
      if (_offline.contains(error) && state.all.isNotEmpty) {
        emit(
          _success(
            state.all,
            query: state.query,
            specialty: state.specialty,
            offline: true,
          ),
        );
        return;
      }
      emit(_failure(error));
    }
  }

  void _onQueryChanged(
    DirectoryQueryChanged event,
    Emitter<DirectoryState> emit,
  ) {
    emit(
      _success(
        state.all,
        query: event.query,
        specialty: event.specialty,
        offline: state.offline,
      ),
    );
  }
}

/// Doctors only, available, matching [query] / [specialty], sorted by name.
List<PractitionerModel> visibleOf(
  List<PractitionerModel> all, {
  required String query,
  Specialty? specialty,
}) {
  final needle = foldForSearch(query);
  final rows = [
    for (final row in all)
      if (!row.isPathologist && row.isAvailable)
        if (specialty == null || row.specialties.contains(specialty.value))
          if (needle.isEmpty || _matches(row, needle)) row,
  ];
  return rows..sort((a, b) {
    final byLast = foldForSearch(
      a.lastName,
    ).compareTo(foldForSearch(b.lastName));
    if (byLast != 0) return byLast;
    return foldForSearch(a.firstName).compareTo(foldForSearch(b.firstName));
  });
}

bool _matches(PractitionerModel row, String needle) {
  if (foldForSearch(row.fullName).contains(needle)) return true;
  if (foldForSearch(row.facilityName).contains(needle)) return true;
  for (final specialty in row.specialties) {
    if (foldForSearch(specialty).contains(needle)) return true;
  }
  return false;
}
