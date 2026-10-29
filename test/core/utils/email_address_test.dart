import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/email_address.dart';

void main() {
  group('isValidEmail', () {
    test('accepts ordinary addresses, trimmed', () {
      for (final email in [
        'amina.wambui@gmail.com',
        'w.kamau@akuh.example',
        'a+tabibu@sub.domain.co.ke',
        ' juma@example.com ',
      ]) {
        expect(isValidEmail(email), isTrue, reason: email);
      }
    });

    test('refuses what is not an address', () {
      for (final email in [
        '',
        'a@b',
        'a b@c.com',
        'a@@b.com',
        'a@b.c',
        '@example.com',
        'amina@',
        'amina.example.com',
        'a..b@example.com',
        'amina@-example.com',
        'amina@example.c0m',
      ]) {
        expect(isValidEmail(email), isFalse, reason: email);
      }
    });
  });

  test('masks all but the first letter and the domain', () {
    expect(maskEmail('amina.wambui@gmail.com'), 'a•••@gmail.com');
    expect(maskEmail('not-an-address'), 'not-an-address');
  });
}
