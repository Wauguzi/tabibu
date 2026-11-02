import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
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
  final needle = _fold(query);
  final rows = [
    for (final row in all)
      if (!row.isPathologist && row.isAvailable)
        if (specialty == null || row.specialties.contains(specialty.value))
          if (needle.isEmpty || _matches(row, needle)) row,
  ];
  return rows..sort((a, b) {
    final byLast = _fold(a.lastName).compareTo(_fold(b.lastName));
    if (byLast != 0) return byLast;
    return _fold(a.firstName).compareTo(_fold(b.firstName));
  });
}

bool _matches(PractitionerModel row, String needle) {
  if (_fold(row.fullName).contains(needle)) return true;
  if (_fold(row.facilityName).contains(needle)) return true;
  for (final specialty in row.specialties) {
    if (_fold(specialty).contains(needle)) return true;
  }
  return false;
}

/// Case- and accent-insensitive fold for directory search.
String _fold(String raw) {
  final lower = raw.trim().toLowerCase();
  final out = StringBuffer();
  for (final unit in lower.runes) {
    final mapped = _latinFold[unit];
    if (mapped != null) {
      out.writeCharCode(mapped);
    } else if (unit >= 0x0300 && unit <= 0x036F) {
      // Combining mark after an NFD source — drop it.
    } else {
      out.writeCharCode(unit);
    }
  }
  return out.toString();
}

/// Common Latin letters with diacritics → ASCII base.
const _latinFold = <int, int>{
  0x00E0: 0x61, 0x00E1: 0x61, 0x00E2: 0x61, 0x00E3: 0x61, 0x00E4: 0x61,
  0x00E5: 0x61, 0x0101: 0x61, 0x0103: 0x61, 0x0105: 0x61, // a
  0x00E8: 0x65, 0x00E9: 0x65, 0x00EA: 0x65, 0x00EB: 0x65, 0x0113: 0x65,
  0x0117: 0x65, 0x0119: 0x65, 0x011B: 0x65, // e
  0x00EC: 0x69, 0x00ED: 0x69, 0x00EE: 0x69, 0x00EF: 0x69, 0x012B: 0x69,
  0x012F: 0x69, // i
  0x00F2: 0x6F, 0x00F3: 0x6F, 0x00F4: 0x6F, 0x00F5: 0x6F, 0x00F6: 0x6F,
  0x00F8: 0x6F, 0x014D: 0x6F, // o
  0x00F9: 0x75, 0x00FA: 0x75, 0x00FB: 0x75, 0x00FC: 0x75, 0x016B: 0x75, // u
  0x00F1: 0x6E, 0x00E7: 0x63, 0x00FD: 0x79, 0x00FF: 0x79,
};
