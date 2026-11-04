import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/lock/data/pbkdf2.dart';

void main() {
  group('pbkdf2HmacSha256', () {
    test('is deterministic for the same password, salt and count', () {
      final salt = utf8.encode('tabibu-salt');
      final a = pbkdf2HmacSha256(
        password: utf8.encode('1234'),
        salt: salt,
        iterations: 1000,
      );
      final b = pbkdf2HmacSha256(
        password: utf8.encode('1234'),
        salt: salt,
        iterations: 1000,
      );
      expect(a, b);
      expect(a, hasLength(32));
    });

    test('changes when the PIN changes', () {
      final salt = utf8.encode('tabibu-salt');
      final a = pbkdf2HmacSha256(
        password: utf8.encode('1234'),
        salt: salt,
        iterations: 1000,
      );
      final b = pbkdf2HmacSha256(
        password: utf8.encode('1235'),
        salt: salt,
        iterations: 1000,
      );
      expect(a, isNot(b));
    });

    test('refuses fewer than one round', () {
      expect(
        () => pbkdf2HmacSha256(
          password: utf8.encode('1234'),
          salt: utf8.encode('s'),
          iterations: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
