import 'package:equatable/equatable.dart';

sealed class LockEvent extends Equatable {
  const LockEvent();

  @override
  List<Object?> get props => [];
}

/// The settings and the lock as they stand; never changes whether the app
/// is locked.
final class LockStatusRequested extends LockEvent {
  const LockStatusRequested();
}

/// Dispatched by `App` before the first frame: locks when a PIN is set.
final class LockColdStart extends LockEvent {
  const LockColdStart();
}

/// Turns the lock on. Refused while one is already on: changing the PIN is
/// turning the lock off with the old one, then on again.
final class LockPinCreateRequested extends LockEvent {
  const LockPinCreateRequested({required this.pin, required this.confirmPin});

  final String pin;
  final String confirmPin;

  /// An event's `toString` reaches logs and bloc tooling; the digits must not.
  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [pin, confirmPin];
}

final class LockPinVerifyRequested extends LockEvent {
  const LockPinVerifyRequested({required this.pin});

  final String pin;

  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [pin];
}

/// Turning biometrics on needs the PIN; turning it off does not, since it
/// removes a way in rather than adding one.
final class LockBiometricsToggleRequested extends LockEvent {
  const LockBiometricsToggleRequested({
    required this.enable,
    required this.pin,
  });

  final bool enable;
  final String pin;

  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [enable, pin];
}

final class LockDisableRequested extends LockEvent {
  const LockDisableRequested({required this.pin});

  final String pin;

  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [pin];
}

/// One of `LockBloc.lockAfterOptions`: 0, 60, 300 or 900.
final class LockAfterChanged extends LockEvent {
  const LockAfterChanged({required this.seconds});

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

final class LockAppBackgrounded extends LockEvent {
  const LockAppBackgrounded();
}

final class LockAppResumed extends LockEvent {
  const LockAppResumed();
}

/// [reason] is the system prompt's text; the screen owns the strings.
final class LockBiometricUnlockRequested extends LockEvent {
  const LockBiometricUnlockRequested({required this.reason});

  final String reason;

  @override
  List<Object?> get props => [reason];
}

/// In-memory only: back to the initial state.
final class LockReset extends LockEvent {
  const LockReset();
}

/// Sign-out: the stored PIN, biometrics choice and failure count go, then
/// the bloc resets.
final class LockStorageCleared extends LockEvent {
  const LockStorageCleared();
}
