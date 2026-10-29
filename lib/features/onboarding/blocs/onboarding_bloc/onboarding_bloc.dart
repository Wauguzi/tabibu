import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_event.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_state.dart';

/// Marks onboarding done on the device, so the next cold start skips A2–A6.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({HiveHelper? hiveHelper})
    : _hive = hiveHelper ?? getIt<HiveHelper>(),
      super(const OnboardingInitial()) {
    // A double tap on A6 must not write twice.
    on<OnboardingCompleted>(_onCompleted, transformer: droppable());
  }

  final HiveHelper _hive;

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingInProgress());
    try {
      await _hive.cacheOnboarding(isOnboarded: true);
      emit(const OnboardingComplete());
    } on Object catch (_) {
      emit(const OnboardingFailure(error: AppError.unknown));
    }
  }
}
