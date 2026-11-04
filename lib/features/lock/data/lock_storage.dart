import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:tabibu/features/lock/data/pbkdf2.dart';

/// The app lock's whole persisted state, in secure storage and nowhere else
/// (never Hive, preferences or a log). The PIN itself is never kept: only a
/// random salt and the PBKDF2 hash of the PIN with it.
@lazySingleton
class LockStorage {
  LockStorage({
    required FlutterSecureStorage secureStorage,
    @ignoreParam Random? random,
    @ignoreParam this.iterations = defaultIterations,
  }) : _storage = secureStorage,
       _random = random ?? Random.secure();

  final FlutterSecureStorage _storage;
  final Random _random;

  /// Used for a new PIN. A stored hash is checked with the count it was made
  /// with, so raising this never locks anyone out.
  final int iterations;

  static const defaultIterations = 100000;
  static const pinLength = 4;
  static const saltBytes = 16;

  /// Never `deleteAll`: the same store holds the Hive encryption key.
  static const _pinHash = 'tabibu.lock.pinHash';
  static const _pinSalt = 'tabibu.lock.pinSalt';
  static const _iterations = 'tabibu.lock.iterations';
  static const _lockEnabled = 'tabibu.lock.enabled';
  static const _biometricsEnabled = 'tabibu.lock.biometricsEnabled';
  static const _lockAfterSeconds = 'tabibu.lock.lockAfterSeconds';
  static const _failedAttempts = 'tabibu.lock.failedAttempts';
  static const _lockoutUntilIso = 'tabibu.lock.lockoutUntilIso';

  static const List<String> _allKeys = [
    _pinHash,
    _pinSalt,
    _iterations,
    _lockEnabled,
    _biometricsEnabled,
    _lockAfterSeconds,
    _failedAttempts,
    _lockoutUntilIso,
  ];

  static final RegExp _pinPattern = RegExp(r'^\d{4}$');

  static bool isValidPin(String pin) => _pinPattern.hasMatch(pin);

  /// On only when a hash exists to check a PIN against.
  Future<bool> isEnabled() async =>
      await _storage.read(key: _lockEnabled) == 'true' &&
      await _storage.read(key: _pinHash) != null;

  /// Replaces any earlier PIN and clears the failure count. The enabled flag
  /// is written last, so a write that dies half way leaves the lock off.
  Future<void> setPin(String pin) async {
    // A fixed message: the argument must never reach an error log.
    if (!isValidPin(pin)) throw ArgumentError('The PIN must be four digits.');
    final salt = Uint8List.fromList([
      for (var i = 0; i < saltBytes; i++) _random.nextInt(256),
    ]);
    final hash = await _hash(pin, salt, iterations);
    await _storage.write(key: _pinSalt, value: base64Encode(salt));
    await _storage.write(key: _iterations, value: '$iterations');
    await _storage.write(key: _pinHash, value: base64Encode(hash));
    await resetFailures();
    await _storage.write(key: _lockEnabled, value: 'true');
  }

  /// A pure check: counting the failure is [recordFailure]'s job.
  Future<bool> verifyPin(String pin) async {
    if (!isValidPin(pin)) return false;
    final stored = await _storage.read(key: _pinHash);
    final salt = await _storage.read(key: _pinSalt);
    final count = int.tryParse(await _storage.read(key: _iterations) ?? '');
    if (stored == null || salt == null || count == null || count < 1) {
      return false;
    }
    final hash = await _hash(pin, base64Decode(salt), count);
    return _constantTimeEquals(hash, base64Decode(stored));
  }

  /// Sign-out and turning the lock off. Only this feature's keys.
  Future<void> clearAll() async {
    for (final key in _allKeys) {
      await _storage.delete(key: key);
    }
  }

  Future<bool> biometricsEnabled() async =>
      await _storage.read(key: _biometricsEnabled) == 'true';

  Future<void> setBiometrics({required bool enabled}) =>
      _storage.write(key: _biometricsEnabled, value: '$enabled');

  /// Seconds in the background before the lock returns; 0 is straight away,
  /// which is also what an unreadable value means.
  Future<int> lockAfterSeconds() async {
    final seconds = int.tryParse(
      await _storage.read(key: _lockAfterSeconds) ?? '',
    );
    return seconds == null || seconds < 0 ? 0 : seconds;
  }

  Future<void> setLockAfter(int seconds) =>
      _storage.write(key: _lockAfterSeconds, value: '$seconds');

  Future<int> failedAttempts() async {
    final count = int.tryParse(await _storage.read(key: _failedAttempts) ?? '');
    return count == null || count < 0 ? 0 : count;
  }

  Future<DateTime?> lockoutUntil() async {
    final iso = await _storage.read(key: _lockoutUntilIso);
    return iso == null ? null : DateTime.tryParse(iso)?.toUtc();
  }

  /// Returns the new count. [lockoutUntil], when given, is kept with it.
  Future<int> recordFailure({DateTime? lockoutUntil}) async {
    final count = await failedAttempts() + 1;
    await _storage.write(key: _failedAttempts, value: '$count');
    if (lockoutUntil != null) {
      await _storage.write(
        key: _lockoutUntilIso,
        value: lockoutUntil.toUtc().toIso8601String(),
      );
    }
    return count;
  }

  Future<void> resetFailures() async {
    await _storage.delete(key: _failedAttempts);
    await _storage.delete(key: _lockoutUntilIso);
  }

  /// Off the UI isolate: a hundred thousand rounds would drop frames. The
  /// closure captures bytes and a count only.
  static Future<Uint8List> _hash(String pin, Uint8List salt, int rounds) {
    final password = utf8.encode(pin);
    // The web has no isolates: the same hash runs on the page, a fraction of
    // a second for one PIN.
    if (kIsWeb) {
      return Future(
        () => pbkdf2HmacSha256(
          password: password,
          salt: salt,
          iterations: rounds,
        ),
      );
    }
    return Isolate.run(
      () =>
          pbkdf2HmacSha256(password: password, salt: salt, iterations: rounds),
    );
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
