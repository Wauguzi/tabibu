import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_bloc.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_event.dart';
import 'package:tabibu/features/lock/blocs/lock_bloc/lock_state.dart';
import 'package:tabibu/features/lock/data/biometric_authenticator.dart';
import 'package:tabibu/features/lock/data/lock_storage.dart';

class _MockStorage extends Mock implements LockStorage {}

class _MockBio extends Mock implements BiometricAuthenticator {}

void main() {
  late _MockStorage storage;
  late _MockBio bio;
  late DateTime clock;

  LockBloc build() =>
      LockBloc(storage: storage, biometrics: bio, now: () => clock);

  const secret = '4829';

  setUp(() {
    storage = _MockStorage();
    bio = _MockBio();
    clock = DateTime.utc(2026, 11, 3, 12);
    when(() => storage.isEnabled()).thenAnswer((_) async => false);
    when(() => storage.biometricsEnabled()).thenAnswer((_) async => false);
    when(() => storage.lockAfterSeconds()).thenAnswer((_) async => 0);
    when(() => storage.failedAttempts()).thenAnswer((_) async => 0);
    when(() => storage.lockoutUntil()).thenAnswer((_) async => null);
    when(() => storage.verifyPin(any())).thenAnswer((_) async => false);
    when(() => storage.setPin(any())).thenAnswer((_) async {});
    when(
      () => storage.setBiometrics(enabled: any(named: 'enabled')),
    ).thenAnswer((_) async {});
    when(() => storage.setLockAfter(any())).thenAnswer((_) async {});
    when(() => storage.clearAll()).thenAnswer((_) async {});
    when(() => storage.resetFailures()).thenAnswer((_) async {});
    when(
      () => storage.recordFailure(lockoutUntil: any(named: 'lockoutUntil')),
    ).thenAnswer((_) async => 1);
    when(() => bio.isAvailable()).thenAnswer((_) async => true);
    when(
      () => bio.authenticate(reason: any(named: 'reason')),
    ).thenAnswer((_) async => true);
  });

  group('LockBloc', () {
    test('starts unlocked and empty', () {
      expect(build().state, const LockInitial());
      expect(build().state.locked, isFalse);
    });

    group('rule 2: cold start and background timeout', () {
      blocTest<LockBloc, LockState>(
        'cold start covers the app while reading, then locks when a PIN is set',
        build: build,
        setUp: () {
          when(() => storage.isEnabled()).thenAnswer((_) async => true);
        },
        act: (bloc) => bloc.add(const LockColdStart()),
        expect: () => [
          isA<LockLoadInProgress>().having((s) => s.locked, 'locked', isTrue),
          isA<LockLoadSuccess>()
              .having((s) => s.enabled, 'enabled', isTrue)
              .having((s) => s.locked, 'locked', isTrue),
        ],
      );

      blocTest<LockBloc, LockState>(
        'resuming after the chosen delay locks; sooner does not',
        build: build,
        seed: () => const LockLoadSuccess(enabled: true),
        setUp: () {
          when(() => storage.isEnabled()).thenAnswer((_) async => true);
          when(() => storage.lockAfterSeconds()).thenAnswer((_) async => 60);
        },
        act: (bloc) async {
          // Stamp background time, then advance the clock before resume.
          bloc.add(const LockAppBackgrounded());
          await Future<void>.delayed(Duration.zero);
          clock = clock.add(const Duration(seconds: 30));
          bloc.add(const LockAppResumed());
          await Future<void>.delayed(Duration.zero);
          expect(bloc.state.locked, isFalse);

          bloc.add(const LockAppBackgrounded());
          await Future<void>.delayed(Duration.zero);
          clock = clock.add(const Duration(seconds: 61));
          final locked = bloc.stream.firstWhere((s) => s.locked);
          bloc.add(const LockAppResumed());
          await locked;
        },
        verify: (bloc) {
          expect(bloc.state.locked, isTrue);
        },
      );

      blocTest<LockBloc, LockState>(
        'lock-after 0 locks on any return from the background',
        build: build,
        seed: () => const LockLoadSuccess(enabled: true),
        setUp: () {
          when(() => storage.isEnabled()).thenAnswer((_) async => true);
          when(() => storage.lockAfterSeconds()).thenAnswer((_) async => 0);
        },
        act: (bloc) {
          bloc
            ..add(const LockAppBackgrounded())
            ..add(const LockAppResumed());
        },
        verify: (bloc) => expect(bloc.state.locked, isTrue),
      );

      blocTest<LockBloc, LockState>(
        'cold-start storage fault stays locked (fail closed)',
        build: build,
        setUp: () {
          when(() => storage.isEnabled()).thenThrow(Exception('secure'));
        },
        act: (bloc) => bloc.add(const LockColdStart()),
        expect: () => [
          isA<LockLoadInProgress>().having((s) => s.locked, 'locked', isTrue),
          isA<LockLoadFailure>().having((s) => s.locked, 'locked', isTrue),
        ],
      );

      blocTest<LockBloc, LockState>(
        'retry after cold-start fault unlocks when no PIN exists',
        build: build,
        setUp: () {
          var calls = 0;
          when(() => storage.isEnabled()).thenAnswer((_) async {
            calls += 1;
            if (calls == 1) throw Exception('secure');
            return false;
          });
        },
        act: (bloc) async {
          bloc.add(const LockColdStart());
          await bloc.stream.firstWhere((s) => s is LockLoadFailure);
          bloc.add(const LockStatusRequested());
        },
        verify: (bloc) {
          expect(bloc.state, isA<LockLoadSuccess>());
          expect(bloc.state.locked, isFalse);
          expect(bloc.state.enabled, isFalse);
        },
      );

      blocTest<LockBloc, LockState>(
        'retry after cold-start fault keeps the cover when a PIN exists',
        build: build,
        setUp: () {
          var calls = 0;
          when(() => storage.isEnabled()).thenAnswer((_) async {
            calls += 1;
            if (calls == 1) throw Exception('secure');
            return true;
          });
        },
        act: (bloc) async {
          bloc.add(const LockColdStart());
          await bloc.stream.firstWhere((s) => s is LockLoadFailure);
          bloc.add(const LockStatusRequested());
        },
        verify: (bloc) {
          expect(bloc.state, isA<LockLoadSuccess>());
          expect(bloc.state.enabled, isTrue);
          expect(bloc.state.locked, isTrue);
        },
      );

      blocTest<LockBloc, LockState>(
        'resume still fails closed when the lock was on and storage throws',
        build: build,
        seed: () => const LockLoadSuccess(enabled: true),
        setUp: () {
          when(() => storage.isEnabled()).thenThrow(Exception('secure'));
          when(() => storage.lockAfterSeconds()).thenAnswer((_) async => 0);
        },
        act: (bloc) {
          bloc
            ..add(const LockAppBackgrounded())
            ..add(const LockAppResumed());
        },
        verify: (bloc) {
          expect(bloc.state, isA<LockLoadFailure>());
          expect(bloc.state.locked, isTrue);
        },
      );
    });

    group('rule 3: biometrics needs the PIN', () {
      blocTest<LockBloc, LockState>(
        'turning biometrics on verifies the PIN first',
        build: build,
        seed: () => const LockLoadSuccess(enabled: true),
        setUp: () {
          when(() => storage.isEnabled()).thenAnswer((_) async => true);
          when(() => storage.verifyPin(secret)).thenAnswer((_) async => true);
          when(() => storage.biometricsEnabled()).thenAnswer((_) async => true);
        },
        act: (bloc) => bloc.add(
          const LockBiometricsToggleRequested(enable: true, pin: secret),
        ),
        verify: (_) {
          verify(() => storage.verifyPin(secret)).called(1);
          verify(() => storage.setBiometrics(enabled: true)).called(1);
          verify(() => bio.isAvailable()).called(1);
        },
      );

      blocTest<LockBloc, LockState>(
        'biometrics alone never replaces a missing PIN',
        build: build,
        seed: () => const LockLoadSuccess(
          enabled: true,
          locked: true,
          biometricsEnabled: true,
        ),
        setUp: () {
          when(() => storage.isEnabled()).thenAnswer((_) async => true);
          when(() => storage.biometricsEnabled()).thenAnswer((_) async => true);
        },
        act: (bloc) =>
            bloc.add(const LockBiometricUnlockRequested(reason: 'Unlock')),
        verify: (bloc) {
          verify(() => bio.authenticate(reason: 'Unlock')).called(1);
          expect(bloc.state.locked, isFalse);
        },
      );
    });

    group('rule 4: wrong PIN limit then sign-out', () {
      blocTest<LockBloc, LockState>(
        'four wrong PINs leave attempts; the fifth requires sign-out',
        build: build,
        seed: () => const LockLoadSuccess(enabled: true, locked: true),
        setUp: () {
          when(() => storage.isEnabled()).thenAnswer((_) async => true);
          var failures = 0;
          when(
            () => storage.failedAttempts(),
          ).thenAnswer((_) async => failures);
          when(
            () =>
                storage.recordFailure(lockoutUntil: any(named: 'lockoutUntil')),
          ).thenAnswer((_) async {
            return failures += 1;
          });
        },
        act: (bloc) async {
          for (var i = 0; i < 5; i++) {
            bloc.add(const LockPinVerifyRequested(pin: '0000'));
            await bloc.stream.first;
          }
        },
        verify: (bloc) {
          expect(bloc.state, isA<LockSignOutRequired>());
          expect(bloc.state.signOutRequired, isTrue);
          expect(bloc.state.locked, isTrue);
        },
      );
    });

    group('rule 5: disable and sign-out clear the PIN', () {
      blocTest<LockBloc, LockState>(
        'turning the lock off needs the PIN then clears storage',
        build: build,
        seed: () => const LockLoadSuccess(enabled: true),
        setUp: () {
          when(() => storage.isEnabled()).thenAnswer((_) async => true);
          when(() => storage.verifyPin(secret)).thenAnswer((_) async => true);
        },
        act: (bloc) => bloc.add(const LockDisableRequested(pin: secret)),
        expect: () => [isA<LockWriteInProgress>(), const LockDisableSuccess()],
        verify: (_) {
          verify(() => storage.verifyPin(secret)).called(1);
          verify(() => storage.clearAll()).called(1);
        },
      );

      blocTest<LockBloc, LockState>(
        'LockStorageCleared wipes the store and resets',
        build: build,
        seed: () => const LockLoadSuccess(enabled: true, locked: true),
        act: (bloc) => bloc.add(const LockStorageCleared()),
        expect: () => [const LockInitial()],
        verify: (_) => verify(() => storage.clearAll()).called(1),
      );
    });

    group('creating a PIN', () {
      blocTest<LockBloc, LockState>(
        'matching four digits turns the lock on',
        build: build,
        act: (bloc) => bloc.add(
          const LockPinCreateRequested(pin: secret, confirmPin: secret),
        ),
        expect: () => [
          isA<LockWriteInProgress>(),
          isA<LockPinCreateSuccess>().having((s) => s.enabled, 'on', isTrue),
        ],
        verify: (_) {
          verify(() => storage.setPin(secret)).called(1);
          verify(() => storage.setBiometrics(enabled: false)).called(1);
        },
      );

      blocTest<LockBloc, LockState>(
        'a mismatch is refused without writing',
        build: build,
        act: (bloc) => bloc.add(
          const LockPinCreateRequested(pin: secret, confirmPin: '0000'),
        ),
        expect: () => [isA<LockPinMismatch>()],
        verify: (_) => verifyNever(() => storage.setPin(any())),
      );
    });

    group('rule 6: no PIN in logs', () {
      late List<String> logged;
      late DebugPrintCallback original;

      setUp(() {
        logged = [];
        original = debugPrint;
        debugPrint = (message, {wrapWidth}) => logged.add(message ?? '');
        Logger.addOutputListener((event) => logged.addAll(event.lines));
      });

      tearDown(() {
        debugPrint = original;
      });

      test('create and verify never put the digits in a log line', () async {
        var enabled = false;
        when(() => storage.isEnabled()).thenAnswer((_) async => enabled);
        when(() => storage.setPin(any())).thenAnswer((_) async {
          enabled = true;
        });
        when(() => storage.verifyPin(secret)).thenAnswer((_) async => true);
        final bloc = build();
        addTearDown(bloc.close);

        await runZoned(
          () async {
            final created = bloc.stream.firstWhere(
              (s) => s is LockPinCreateSuccess,
            );
            bloc.add(
              const LockPinCreateRequested(pin: secret, confirmPin: secret),
            );
            await created;
            final unlocked = bloc.stream.firstWhere(
              (s) => s is LockLoadSuccess && !s.locked,
            );
            bloc.add(const LockPinVerifyRequested(pin: secret));
            await unlocked;
            // Event toString must not leak either.
            expect(
              const LockPinVerifyRequested(pin: secret).toString(),
              isNot(contains(secret)),
            );
          },
          zoneSpecification: ZoneSpecification(
            print: (_, _, _, line) => logged.add(line),
          ),
        );

        expect(logged.where((line) => line.contains(secret)), isEmpty);
      });
    });
  });
}
