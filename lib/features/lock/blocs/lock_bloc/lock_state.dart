import 'package:equatable/equatable.dart';
import 'package:tabibu/core/constants/enums.dart';

/// The wrong-PIN allowance; the sixth screen is a sign-out.
const lockMaxAttempts = 5;

/// The data lives on the base so a toggle or a failed try never blanks the
/// lock screen. Nothing here holds a PIN or a biometric result.
sealed class LockState extends Equatable {
  const LockState({
    this.enabled = false,
    this.locked = false,
    this.biometricsEnabled = false,
    this.lockAfterSeconds = 0,
    this.attemptsRemaining = lockMaxAttempts,
    this.lockoutUntil,
    this.signOutRequired = false,
    this.error,
  });

  final bool enabled;

  /// What `App`'s overlay reads: true covers every screen.
  final bool locked;
  final bool biometricsEnabled;
  final int lockAfterSeconds;
  final int attemptsRemaining;

  /// UTC. Null when no lockout is running.
  final DateTime? lockoutUntil;

  /// Set once the failures reach [lockMaxAttempts]; `App` signs out.
  final bool signOutRequired;
  final AppError? error;

  @override
  List<Object?> get props => [
    enabled,
    locked,
    biometricsEnabled,
    lockAfterSeconds,
    attemptsRemaining,
    lockoutUntil,
    signOutRequired,
    error,
  ];
}

final class LockInitial extends LockState {
  const LockInitial();
}

/// Always locked: until the stored settings are read, the app is covered.
final class LockLoadInProgress extends LockState {
  const LockLoadInProgress({
    super.enabled,
    super.biometricsEnabled,
    super.lockAfterSeconds,
    super.attemptsRemaining,
    super.lockoutUntil,
    super.signOutRequired,
  }) : super(locked: true);
}

/// The lock as it stands: after a load, an unlock, a lock, or a setting
/// change.
final class LockLoadSuccess extends LockState {
  const LockLoadSuccess({
    super.enabled,
    super.locked,
    super.biometricsEnabled,
    super.lockAfterSeconds,
    super.attemptsRemaining,
    super.lockoutUntil,
    super.signOutRequired,
  });
}

/// The settings could not be read. The lock stays as it was: failing shut
/// would leave a person with no way in but reinstalling.
final class LockLoadFailure extends LockState {
  const LockLoadFailure({
    required AppError super.error,
    super.enabled,
    super.locked,
    super.biometricsEnabled,
    super.lockAfterSeconds,
    super.attemptsRemaining,
    super.lockoutUntil,
    super.signOutRequired,
  });
}

final class LockWriteInProgress extends LockState {
  const LockWriteInProgress({
    super.enabled,
    super.locked,
    super.biometricsEnabled,
    super.lockAfterSeconds,
    super.attemptsRemaining,
    super.lockoutUntil,
    super.signOutRequired,
  });
}

final class LockWriteFailure extends LockState {
  const LockWriteFailure({
    required AppError super.error,
    super.enabled,
    super.locked,
    super.biometricsEnabled,
    super.lockAfterSeconds,
    super.attemptsRemaining,
    super.lockoutUntil,
    super.signOutRequired,
  });
}

final class LockPinCreateSuccess extends LockState {
  const LockPinCreateSuccess({super.biometricsEnabled, super.lockAfterSeconds})
    : super(enabled: true);
}

/// The two entries differ.
final class LockPinMismatch extends LockState {
  const LockPinMismatch({super.enabled, super.locked});
}

/// Not four digits.
final class LockPinMalformed extends LockState {
  const LockPinMalformed({super.enabled, super.locked});
}

/// A wrong PIN, counted; [attemptsRemaining] says how many are left.
final class LockPinWrong extends LockState {
  const LockPinWrong({
    required super.attemptsRemaining,
    super.enabled,
    super.locked,
    super.biometricsEnabled,
    super.lockAfterSeconds,
  });
}

/// A try was refused, unchecked, while [lockoutUntil] is ahead.
final class LockOutActive extends LockState {
  const LockOutActive({
    required DateTime super.lockoutUntil,
    super.enabled,
    super.locked,
    super.biometricsEnabled,
    super.lockAfterSeconds,
    super.attemptsRemaining,
    super.signOutRequired,
  });
}

/// Five wrong PINs. The only way out of the lock screen is signing out,
/// which wipes the session's local data; there is no reset that skips
/// authentication.
final class LockSignOutRequired extends LockState {
  const LockSignOutRequired({
    super.lockoutUntil,
    super.enabled = true,
    super.locked = true,
    super.biometricsEnabled,
    super.lockAfterSeconds,
  }) : super(attemptsRemaining: 0, signOutRequired: true);
}

/// Biometrics are not enrolled or usable on this device.
final class LockBiometricUnavailable extends LockState {
  const LockBiometricUnavailable({
    super.enabled,
    super.locked,
    super.lockAfterSeconds,
  });
}

/// Not recognised, cancelled or errored: no detail is kept, the PIN is
/// still the way in.
final class LockBiometricFailed extends LockState {
  const LockBiometricFailed({
    super.enabled,
    super.locked,
    super.biometricsEnabled,
    super.lockAfterSeconds,
    super.attemptsRemaining,
  });
}

final class LockDisableSuccess extends LockState {
  const LockDisableSuccess();
}
