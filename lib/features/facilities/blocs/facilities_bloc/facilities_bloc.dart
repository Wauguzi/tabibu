import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/facilities_helper.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_event.dart';
import 'package:tabibu/features/facilities/blocs/facilities_bloc/facilities_state.dart';

/// The bundled reference data behind the area and facility pickers. A failed
/// asset load surfaces as data-not-found: the bundle is missing a row the
/// screen needs.
class FacilitiesBloc extends Bloc<FacilitiesEvent, FacilitiesState> {
  FacilitiesBloc({FacilitiesHelper? facilitiesHelper})
    : _facilities = facilitiesHelper ?? getIt<FacilitiesHelper>(),
      super(const FacilitiesInitial()) {
    // Idempotent cached reads; a second tap while loading is pointless.
    on<FacilitiesCountiesRequested>(_onCounties, transformer: droppable());
    on<FacilitiesSubCountiesRequested>(
      _onSubCounties,
      transformer: droppable(),
    );
    on<FacilitiesFacilityRequested>(_onFacility, transformer: droppable());
    // Keystrokes: only the latest query matters.
    on<FacilitiesSearchRequested>(_onSearch, transformer: restartable());
  }

  final FacilitiesHelper _facilities;

  Future<void> _onCounties(
    FacilitiesCountiesRequested event,
    Emitter<FacilitiesState> emit,
  ) async {
    emit(const CountiesLoadInProgress());
    try {
      emit(CountiesLoadSuccess(await _facilities.counties()));
    } on Object catch (_) {
      emit(const CountiesLoadFailure(error: AppError.dataNotFound));
    }
  }

  Future<void> _onSubCounties(
    FacilitiesSubCountiesRequested event,
    Emitter<FacilitiesState> emit,
  ) async {
    emit(const SubCountiesLoadInProgress());
    try {
      emit(SubCountiesLoadSuccess(await _facilities.nairobiSubCounties()));
    } on Object catch (_) {
      emit(const SubCountiesLoadFailure(error: AppError.dataNotFound));
    }
  }

  Future<void> _onSearch(
    FacilitiesSearchRequested event,
    Emitter<FacilitiesState> emit,
  ) async {
    emit(const FacilitiesSearchInProgress());
    try {
      emit(
        FacilitiesSearchSuccess(
          await _facilities.searchFacilities(
            event.query,
            nearGeohash: event.nearGeohash,
          ),
        ),
      );
    } on Object catch (_) {
      emit(const FacilitiesSearchFailure(error: AppError.dataNotFound));
    }
  }

  Future<void> _onFacility(
    FacilitiesFacilityRequested event,
    Emitter<FacilitiesState> emit,
  ) async {
    try {
      emit(
        FacilityLoadSuccess(await _facilities.facilityById(event.facilityId)),
      );
    } on Object catch (_) {
      emit(const FacilityLoadFailure(error: AppError.dataNotFound));
    }
  }
}
