import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/features/lock/data/lock_storage.dart';

class _MockSecure extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecure secure;
  late Map<String, String> store;
  late LockStorage storage;

  setUp(() {
    secure = _MockSecure();
    store = {};
    when(
      () => secure.read(key: any(named: 'key')),
    ).thenAnswer((inv) async => store[inv.namedArguments[#key] as String]);
    when(
      () => secure.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((inv) async {
      store[inv.namedArguments[#key] as String] =
          inv.namedArguments[#value] as String;
    });
    when(() => secure.delete(key: any(named: 'key'))).thenAnswer((inv) async {
      store.remove(inv.namedArguments[#key] as String);
    });
    // Fixed bytes so hashes are stable across runs.
    storage = LockStorage(
      secureStorage: secure,
      random: Random(1),
      iterations: 1000,
    );
  });

  group('LockStorage', () {
    test('rule 1: setPin stores only salt and hash, never the PIN', () async {
      await storage.setPin('4829');
      expect(store.values.any((v) => v.contains('4829')), isFalse);
      expect(store['tabibu.lock.pinHash'], isNotNull);
      expect(store['tabibu.lock.pinSalt'], isNotNull);
      expect(store['tabibu.lock.enabled'], 'true');
      expect(await storage.isEnabled(), isTrue);
      expect(await storage.verifyPin('4829'), isTrue);
      expect(await storage.verifyPin('0000'), isFalse);
    });

    test('clearAll removes only the lock keys', () async {
      await storage.setPin('4829');
      await storage.setBiometrics(enabled: true);
      await storage.clearAll();
      expect(store.keys.where((k) => k.startsWith('tabibu.lock.')), isEmpty);
      expect(await storage.isEnabled(), isFalse);
    });

    test('refuses a PIN that is not four digits', () async {
      expect(() => storage.setPin('12'), throwsArgumentError);
      expect(() => storage.setPin('abcd'), throwsArgumentError);
      expect(await storage.isEnabled(), isFalse);
    });
  });
}
