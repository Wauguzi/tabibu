import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingInProgress extends OnboardingState {
  const OnboardingInProgress();
}

final class OnboardingComplete extends OnboardingState {
  const OnboardingComplete();
}

final class OnboardingFailure extends OnboardingState {
  const OnboardingFailure({required this.error});

  final AppError error;

  @override
  List<Object?> get props => [error];
}
