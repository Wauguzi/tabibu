import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_state.dart';
import 'package:tabibu/features/lock/data/biometric_authenticator.dart';
import 'package:tabibu/features/lock/data/lock_storage.dart';

/// The app lock: a four-digit PIN, with biometrics as an extra way in and
/// never the only one. Five wrong PINs sign the person out rather than
/// offer a reset, so nothing here is a way around authentication.
///
/// A PIN is only ever an argument: it is hashed in [LockStorage], never
/// held, emitted, logged or put in analytics. Nothing here logs at all.
class LockBloc extends Bloc<LockEvent, LockState> {
  LockBloc({
    LockStorage? storage,
    BiometricAuthenticator? biometrics,
    DateTime Function()? now,
  }) : _storage = storage ?? getIt<LockStorage>(),
       _biometrics = biometrics ?? getIt<BiometricAuthenticator>(),
       _now = now ?? DateTime.now,
       super(const LockInitial()) {
    on<LockStatusRequested>(_onStatusRequested, transformer: sequential());
    on<LockColdStart>(_onColdStart, transformer: sequential());
    on<LockPinCreateRequested>(_onPinCreate, transformer: sequential());
    on<LockPinVerifyRequested>(_onPinVerify, transformer: sequential());
    on<LockBiometricsToggleRequested>(
      _onBiometricsToggle,
      transformer: sequential(),
    );
    on<LockDisableRequested>(_onDisable, transformer: sequential());
    on<LockAfterChanged>(_onAfterChanged, transformer: sequential());
    on<LockAppBackgrounded>(_onBackgrounded, transformer: sequential());
    on<LockAppResumed>(_onResumed, transformer: sequential());
    on<LockBiometricUnlockRequested>(
      _onBiometricUnlock,
      transformer: sequential(),
    );
    on<LockReset>(_onReset, transformer: sequential());
    on<LockStorageCleared>(_onStorageCleared, transformer: sequential());
  }

  final LockStorage _storage;
  final BiometricAuthenticator _biometrics;
  final DateTime Function() _now;

  /// Straight away, 1 minute, 5 minutes, 15 minutes.
  static const lockAfterOptions = [0, 60, 300, 900];

  /// How long tries are refused once the allowance is spent.
  static const lockoutDuration = Duration(minutes: 5);

  DateTime? _backgroundedAt;

  Future<void> _onStatusRequested(
    LockStatusRequested event,
    Emitter<LockState> emit,
  ) async {
    try {
      emit(await _status(locked: state.locked));
    } on Object catch (_) {
      // Keep the cover if we already had one (cold-start fail-closed).
      emit(_loadFailure(locked: state.locked));
    }
  }

  /// Covers the app first, then reads: no frame shows content before the
  /// answer is known.
  Future<void> _onColdStart(
    LockColdStart event,
    Emitter<LockState> emit,
  ) async {
    emit(
      LockLoadInProgress(
        enabled: state.enabled,
        biometricsEnabled: state.biometricsEnabled,
        lockAfterSeconds: state.lockAfterSeconds,
        attemptsRemaining: state.attemptsRemaining,
        lockoutUntil: state.lockoutUntil,
        signOutRequired: state.signOutRequired,
      ),
    );
    try {
      emit(await _status(locked: true));
    } on Object catch (_) {
      // Fail closed: a storage fault must not uncover the app. Retry and
      // sign-out on the overlay are the way out (bundle 78).
      emit(_loadFailure(locked: true));
    }
  }

  Future<void> _onPinCreate(
    LockPinCreateRequested event,
    Emitter<LockState> emit,
  ) async {
    if (state.locked) return;
    if (!LockStorage.isValidPin(event.pin) ||
        !LockStorage.isValidPin(event.confirmPin)) {
      emit(LockPinMalformed(enabled: state.enabled, locked: state.locked));
      return;
    }
    if (event.pin != event.confirmPin) {
      emit(LockPinMismatch(enabled: state.enabled, locked: state.locked));
      return;
    }
    try {
      // Replacing a PIN without the old one would be a way around the PIN.
      if (await _storage.isEnabled()) {
        emit(_writeFailure(AppError.unknown));
        return;
      }
      emit(_inProgress());
      await _storage.setPin(event.pin);
      await _storage.setBiometrics(enabled: false);
      emit(
        LockPinCreateSuccess(
          lockAfterSeconds: await _storage.lockAfterSeconds(),
        ),
      );
    } on Object catch (_) {
      emit(_writeFailure(AppError.unknown));
    }
  }

  Future<void> _onPinVerify(
    LockPinVerifyRequested event,
    Emitter<LockState> emit,
  ) async {
    try {
      if (!await _storage.isEnabled()) {
        emit(await _status(locked: false));
        return;
      }
      if (!await _checkPin(event.pin, emit)) return;
      emit(await _status(locked: false));
    } on Object catch (_) {
      emit(_writeFailure(AppError.unknown));
    }
  }

  Future<void> _onBiometricsToggle(
    LockBiometricsToggleRequested event,
    Emitter<LockState> emit,
  ) async {
    if (state.locked) return;
    try {
      if (event.enable) {
        if (!await _checkPin(event.pin, emit)) return;
        if (!await _biometrics.isAvailable()) {
          emit(
            LockBiometricUnavailable(
              enabled: state.enabled,
              locked: state.locked,
              lockAfterSeconds: state.lockAfterSeconds,
            ),
          );
          return;
        }
      }
      await _storage.setBiometrics(enabled: event.enable);
      emit(await _status(locked: false));
    } on Object catch (_) {
      emit(_writeFailure(AppError.unknown));
    }
  }

  Future<void> _onDisable(
    LockDisableRequested event,
    Emitter<LockState> emit,
  ) async {
    if (state.locked) return;
    try {
      if (!await _checkPin(event.pin, emit)) return;
      emit(_inProgress());
      await _storage.clearAll();
      emit(const LockDisableSuccess());
    } on Object catch (_) {
      emit(_writeFailure(AppError.unknown));
    }
  }

  Future<void> _onAfterChanged(
    LockAfterChanged event,
    Emitter<LockState> emit,
  ) async {
    if (state.locked) return;
    if (!lockAfterOptions.contains(event.seconds)) {
      emit(_writeFailure(AppError.unknown));
      return;
    }
    try {
      await _storage.setLockAfter(event.seconds);
      emit(await _status(locked: false));
    } on Object catch (_) {
      emit(_writeFailure(AppError.unknown));
    }
  }

  void _onBackgrounded(LockAppBackgrounded event, Emitter<LockState> emit) {
    _backgroundedAt = _now();
  }

  /// Locks once the time away reaches the chosen delay; 0 locks on any
  /// return. A failed read locks when a lock was on: the safe side.
  Future<void> _onResumed(LockAppResumed event, Emitter<LockState> emit) async {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null || state.locked) return;
    try {
      if (!await _storage.isEnabled()) return;
      final after = Duration(seconds: await _storage.lockAfterSeconds());
      if (_now().difference(since) < after) return;
      emit(await _status(locked: true));
    } on Object catch (_) {
      if (state.enabled) emit(_loadFailure(locked: true));
    }
  }

  Future<void> _onBiometricUnlock(
    LockBiometricUnlockRequested event,
    Emitter<LockState> emit,
  ) async {
    try {
      if (!await _storage.isEnabled() || !await _storage.biometricsEnabled()) {
        return;
      }
      final failures = await _storage.failedAttempts();
      final until = await _storage.lockoutUntil();
      // Biometrics must not outlast the attempt limit.
      if (failures >= lockMaxAttempts ||
          (until != null && until.isAfter(_now().toUtc()))) {
        emit(await _status(locked: true));
        return;
      }
      if (!await _biometrics.authenticate(reason: event.reason)) {
        emit(
          LockBiometricFailed(
            enabled: state.enabled,
            locked: state.locked,
            biometricsEnabled: state.biometricsEnabled,
            lockAfterSeconds: state.lockAfterSeconds,
            attemptsRemaining: state.attemptsRemaining,
          ),
        );
        return;
      }
      await _storage.resetFailures();
      emit(await _status(locked: false));
    } on Object catch (_) {
      emit(_writeFailure(AppError.unknown));
    }
  }

  void _onReset(LockReset event, Emitter<LockState> emit) {
    _backgroundedAt = null;
    emit(const LockInitial());
  }

  Future<void> _onStorageCleared(
    LockStorageCleared event,
    Emitter<LockState> emit,
  ) async {
    _backgroundedAt = null;
    try {
      await _storage.clearAll();
      emit(const LockInitial());
    } on Object catch (_) {
      emit(_writeFailure(AppError.unknown));
    }
  }

  /// True when [pin] is right. Otherwise it has emitted why: refused during
  /// a lockout or after the allowance, or a counted wrong PIN. The fifth
  /// starts the lockout and asks for a sign-out.
  Future<bool> _checkPin(String pin, Emitter<LockState> emit) async {
    final now = _now().toUtc();
    final failures = await _storage.failedAttempts();
    final until = await _storage.lockoutUntil();
    final spent = failures >= lockMaxAttempts;
    if (until != null && until.isAfter(now)) {
      emit(
        LockOutActive(
          lockoutUntil: until,
          enabled: state.enabled,
          locked: state.locked,
          biometricsEnabled: state.biometricsEnabled,
          lockAfterSeconds: state.lockAfterSeconds,
          attemptsRemaining: max(0, lockMaxAttempts - failures),
          signOutRequired: spent,
        ),
      );
      return false;
    }
    if (spent) {
      emit(_signOutRequired(until: until));
      return false;
    }
    if (await _storage.verifyPin(pin)) {
      if (failures > 0) await _storage.resetFailures();
      return true;
    }
    final last = failures + 1 >= lockMaxAttempts;
    final lockout = now.add(lockoutDuration);
    final count = await _storage.recordFailure(
      lockoutUntil: last ? lockout : null,
    );
    if (count >= lockMaxAttempts) {
      emit(_signOutRequired(until: lockout));
    } else {
      emit(
        LockPinWrong(
          attemptsRemaining: lockMaxAttempts - count,
          enabled: state.enabled,
          locked: state.locked,
          biometricsEnabled: state.biometricsEnabled,
          lockAfterSeconds: state.lockAfterSeconds,
        ),
      );
    }
    return false;
  }

  Future<LockState> _status({required bool locked}) async {
    final enabled = await _storage.isEnabled();
    final biometrics = enabled && await _storage.biometricsEnabled();
    final after = await _storage.lockAfterSeconds();
    final failures = await _storage.failedAttempts();
    final stored = await _storage.lockoutUntil();
    final until = stored != null && stored.isAfter(_now().toUtc())
        ? stored
        : null;
    if (enabled && failures >= lockMaxAttempts) {
      return LockSignOutRequired(
        lockoutUntil: until,
        biometricsEnabled: biometrics,
        lockAfterSeconds: after,
      );
    }
    return LockLoadSuccess(
      enabled: enabled,
      locked: enabled && locked,
      biometricsEnabled: biometrics,
      lockAfterSeconds: after,
      attemptsRemaining: max(0, lockMaxAttempts - failures),
      lockoutUntil: until,
    );
  }

  LockSignOutRequired _signOutRequired({DateTime? until}) =>
      LockSignOutRequired(
        lockoutUntil: until,
        biometricsEnabled: state.biometricsEnabled,
        lockAfterSeconds: state.lockAfterSeconds,
      );

  LockWriteInProgress _inProgress() => LockWriteInProgress(
    enabled: state.enabled,
    locked: state.locked,
    biometricsEnabled: state.biometricsEnabled,
    lockAfterSeconds: state.lockAfterSeconds,
    attemptsRemaining: state.attemptsRemaining,
    lockoutUntil: state.lockoutUntil,
    signOutRequired: state.signOutRequired,
  );

  LockWriteFailure _writeFailure(AppError error) => LockWriteFailure(
    error: error,
    enabled: state.enabled,
    locked: state.locked,
    biometricsEnabled: state.biometricsEnabled,
    lockAfterSeconds: state.lockAfterSeconds,
    attemptsRemaining: state.attemptsRemaining,
    lockoutUntil: state.lockoutUntil,
    signOutRequired: state.signOutRequired,
  );

  LockLoadFailure _loadFailure({bool locked = false}) => LockLoadFailure(
    error: AppError.unknown,
    enabled: state.enabled,
    locked: locked,
    biometricsEnabled: state.biometricsEnabled,
    lockAfterSeconds: state.lockAfterSeconds,
    attemptsRemaining: state.attemptsRemaining,
    lockoutUntil: state.lockoutUntil,
    signOutRequired: state.signOutRequired,
  );
}
