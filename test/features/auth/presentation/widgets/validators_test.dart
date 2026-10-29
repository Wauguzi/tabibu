import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/auth/presentation/widgets/validators.dart';

void main() {
  group('normalizeKePhone', () {
    test('accepts national digits', () {
      expect(normalizeKePhone('712345678'), '+254712345678');
      expect(normalizeKePhone('712 345 678'), '+254712345678');
    });

    test('accepts 0-prefixed and +254 numbers', () {
      expect(normalizeKePhone('0712345678'), '+254712345678');
      expect(normalizeKePhone('+254 722 118 450'), '+254722118450');
      expect(normalizeKePhone('254722118450'), '+254722118450');
    });

    test('refuses non-mobiles', () {
      expect(normalizeKePhone(''), isNull);
      expect(normalizeKePhone('71234567'), isNull);
      expect(normalizeKePhone('212345678'), isNull);
      expect(normalizeKePhone('+15551234567'), isNull);
      expect(normalizeKePhone('abcdefghij'), isNull);
    });
  });

  group('isValidEmail', () {
    test('checks structure only', () {
      expect(isValidEmail('a@b.co'), isTrue);
      expect(isValidEmail('  a@b.co  '), isTrue);
      expect(isValidEmail('a@b'), isFalse);
      expect(isValidEmail('ab.co'), isFalse);
      expect(isValidEmail(''), isFalse);
    });
  });

  group('isPasswordStrong', () {
    test('needs length, a number and a symbol', () {
      expect(isPasswordStrong('abcdefg1!'), isTrue);
      expect(isPasswordStrong('abcde1!'), isFalse);
      expect(isPasswordStrong('abcdefgh!'), isFalse);
      expect(isPasswordStrong('abcdefg12'), isFalse);
      expect(isPasswordStrong(''), isFalse);
    });
  });
}
