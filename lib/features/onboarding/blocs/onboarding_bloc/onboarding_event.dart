import 'package:equatable/equatable.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// A6. Marks onboarding done on the device.
final class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
