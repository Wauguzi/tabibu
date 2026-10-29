import 'package:flutter/services.dart';
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

  group('KePhoneFormatter', () {
    const formatter = KePhoneFormatter();

    TextEditingValue format(String oldText, String newText) =>
        formatter.formatEditUpdate(
          TextEditingValue(text: oldText),
          TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: newText.length),
          ),
        );

    test('groups digits as typed', () {
      expect(format('', '7').text, '7');
      expect(format('7', '71').text, '71');
      expect(format('71', '712').text, '712');
      expect(format('712', '7123').text, '712 3');
      expect(format('712 34', '712 345').text, '712 345');
      expect(format('712 345', '712 3456').text, '712 345 6');
      expect(format('712 345 67', '712 345 678').text, '712 345 678');
    });

    test('drops anything past nine digits', () {
      expect(format('712 345 678', '712 345 6789').text, '712 345 678');
    });

    test('regroups when deleting', () {
      expect(format('712 345', '712 34').text, '712 34');
      expect(format('712 3', '712 ').text, '712');
      expect(format('712 ', '712').text, '712');
    });

    test('strips a pasted 0 or 254 prefix', () {
      expect(format('', '0712345678').text, '712 345 678');
      expect(format('', '+254712345678').text, '712 345 678');
      expect(format('', '0').text, '');
    });

    test('rests the caret at the end', () {
      final value = format('', '712345678');
      expect(value.text, '712 345 678');
      expect(
        value.selection,
        const TextSelection.collapsed(offset: '712 345 678'.length),
      );
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
